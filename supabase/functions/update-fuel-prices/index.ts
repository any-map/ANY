import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const FUEL_URL = 'https://www.data.gouv.fr/api/1/datasets/r/b0561905-7b5e-4f38-be50-df05708acb80'

function buildDesc(s: any): string {
  const parts: string[] = []
  if (s.adresse) parts.push(`${s.adresse}${s.cp ? ' ' + s.cp : ''}${s.ville ? ' ' + s.ville : ''}`)
  if (s.gazole_prix) parts.push(`Gazole : ${s.gazole_prix}€`)
  if (s.sp95_prix)   parts.push(`SP95 : ${s.sp95_prix}€`)
  if (s.sp98_prix)   parts.push(`SP98 : ${s.sp98_prix}€`)
  if (s.e10_prix)    parts.push(`E10 : ${s.e10_prix}€`)
  if (s.e85_prix)    parts.push(`E85 : ${s.e85_prix}€`)
  if (s.gplc_prix)   parts.push(`GPL : ${s.gplc_prix}€`)
  parts.push(`id_gouv:${s.id}`)
  return parts.join(' | ')
}

Deno.serve(async (_req) => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  )

  // 1. Télécharger les prix depuis data.gouv.fr
  const resp = await fetch(FUEL_URL)
  if (!resp.ok) return new Response('Erreur téléchargement: ' + resp.status, { status: 500 })
  const stations: any[] = await resp.json()

  // 2. Construire les mises à jour
  const updates = stations
    .filter(s => s.id)
    .map(s => ({ id_gouv: String(s.id), description: buildDesc(s) }))

  // 3. Mise à jour en lots via fonction SQL
  let updated = 0, errors = 0
  const BATCH = 200
  for (let i = 0; i < updates.length; i += BATCH) {
    const batch = updates.slice(i, i + BATCH)
    const { error } = await supabase.rpc('bulk_update_fuel_descriptions', { updates: batch })
    if (error) { errors += batch.length; console.error(error.message) }
    else updated += batch.length
  }

  return new Response(
    JSON.stringify({ ok: true, updated, errors, total: updates.length }),
    { headers: { 'Content-Type': 'application/json' } }
  )
})
