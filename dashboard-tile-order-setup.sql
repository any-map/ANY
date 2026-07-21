-- DASHBOARD TILE ORDER SETUP
-- À exécuter dans Supabase > SQL Editor
-- Permet de mémoriser l'ordre des tuiles du panneau admin (Mon espace),
-- partagé entre tous les admins/modérateurs, réorganisable par appui long + glisser-déposer.

CREATE TABLE IF NOT EXISTS dashboard_settings (
  id INT PRIMARY KEY DEFAULT 1,
  tile_order JSONB NOT NULL DEFAULT '[]'::jsonb,
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT dashboard_settings_singleton CHECK (id = 1)
);

INSERT INTO dashboard_settings (id, tile_order)
VALUES (1, '[]'::jsonb)
ON CONFLICT (id) DO NOTHING;

ALTER TABLE dashboard_settings ENABLE ROW LEVEL SECURITY;

-- Lecture réservée admin/modérateur
CREATE POLICY "select admin/mod dashboard_settings" ON dashboard_settings
  FOR SELECT TO authenticated
  USING (EXISTS (SELECT 1 FROM trusted_users WHERE user_id = auth.uid() AND role IN ('admin','moderator')));

-- Modification réservée admin/modérateur
CREATE POLICY "update admin/mod dashboard_settings" ON dashboard_settings
  FOR UPDATE TO authenticated
  USING (EXISTS (SELECT 1 FROM trusted_users WHERE user_id = auth.uid() AND role IN ('admin','moderator')))
  WITH CHECK (EXISTS (SELECT 1 FROM trusted_users WHERE user_id = auth.uid() AND role IN ('admin','moderator')));
