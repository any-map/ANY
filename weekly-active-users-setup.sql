-- WEEKLY ACTIVE USERS SETUP
-- À exécuter dans Supabase > SQL Editor
-- Ajoute le suivi de dernière connexion (profiles.last_seen_at) et deux RPC
-- pour la bande d'info admin en haut de l'app : le nombre d'utilisateurs
-- uniques connectés sur les 7 derniers jours, et le détail (pseudo + date).
-- Idempotent (peut être relancé sans risque, y compris si déjà exécuté avant).

ALTER TABLE profiles ADD COLUMN IF NOT EXISTS last_seen_at TIMESTAMPTZ;

CREATE INDEX IF NOT EXISTS profiles_last_seen_idx ON profiles(last_seen_at);

-- Un utilisateur connecté peut mettre à jour SA PROPRE date de dernière connexion
DROP POLICY IF EXISTS "update own last_seen_at" ON profiles;
CREATE POLICY "update own last_seen_at" ON profiles
  FOR UPDATE TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- Nombre d'utilisateurs uniques vus dans les 7 derniers jours
-- (même style que get_registered_users_count / get_new_users_count : le filtrage
-- admin/modérateur se fait côté client comme pour ces deux RPC existantes)
CREATE OR REPLACE FUNCTION get_weekly_active_users_count()
RETURNS INTEGER
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT COUNT(DISTINCT user_id)::int
  FROM profiles
  WHERE last_seen_at >= NOW() - INTERVAL '7 days';
$$;

-- Détail (pseudo + date de dernière connexion) — expose des infos par utilisateur,
-- donc vérification admin côté serveur en plus du filtrage côté client
CREATE OR REPLACE FUNCTION admin_get_weekly_active_users()
RETURNS TABLE(username TEXT, last_seen_at TIMESTAMPTZ)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM trusted_users WHERE trusted_users.user_id = auth.uid() AND role = 'admin') THEN
    RAISE EXCEPTION 'not authorized';
  END IF;
  RETURN QUERY
    SELECT profiles.username, profiles.last_seen_at
    FROM profiles
    WHERE profiles.last_seen_at >= NOW() - INTERVAL '7 days'
    ORDER BY profiles.last_seen_at DESC;
END;
$$;
