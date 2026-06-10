const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

const VALHALLA_SERVERS = [
  "https://valhalla1.openstreetmap.de/route",
  "https://valhalla.openstreetmap.de/route",
];

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return new Response("Method Not Allowed", { status: 405, headers: corsHeaders });

  try {
    const body = await req.json();

    for (const server of VALHALLA_SERVERS) {
      try {
        const vRes = await fetch(server, {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify(body),
          signal: AbortSignal.timeout(15000),
        });
        const data = await vRes.json();
        return new Response(JSON.stringify(data), {
          headers: { ...corsHeaders, "Content-Type": "application/json" },
          status: vRes.status,
        });
      } catch (_) { /* try next server */ }
    }

    return new Response(JSON.stringify({ error: "All Valhalla servers failed" }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 502,
    });
  } catch (err) {
    return new Response(JSON.stringify({ error: String(err) }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 500,
    });
  }
});
