-- ============================================================
-- RÉORGANISATION CATÉGORIES VAN LIFE & CAMPING-CAR
-- À exécuter dans Supabase SQL Editor
-- ============================================================

-- 1. Supprimer les lieux de l'ancienne catégorie "Aire de camping-car officielle"
DELETE FROM places WHERE category_id = '44501646-b700-4739-808a-309ca5705bc0';

-- 2. Supprimer l'ancienne catégorie
DELETE FROM categories WHERE id = '44501646-b700-4739-808a-309ca5705bc0';

-- 3. Déplacer "Spot de nuit" → Van Life & Camping-car
UPDATE categories
SET main_category_id = 'a4733e63-489d-4608-8109-85dc2d0a9e55'
WHERE id = '5a0e2084-afb1-476e-94f4-661c54f6fea3';

-- 4. Déplacer + renommer "Aire de vidange camping-car" → "Aire de service camping-car"
UPDATE categories
SET main_category_id = 'a4733e63-489d-4608-8109-85dc2d0a9e55',
    name = 'Aire de service camping-car',
    icon = '🚿'
WHERE id = '7d96fb5f-504e-43c3-b7e1-79c9befd5dcc';

-- 5. Créer les nouvelles catégories sous Van Life & Camping-car
INSERT INTO categories (id, name, icon, main_category_id, allow_photos) VALUES
  ('a4730001-0000-0000-0000-000000000001', 'Aire de camping-car officielle',  '🅿️', 'a4733e63-489d-4608-8109-85dc2d0a9e55', true),
  ('a4730002-0000-0000-0000-000000000002', 'Camping traditionnel',             '⛺', 'a4733e63-489d-4608-8109-85dc2d0a9e55', true),
  ('a4730003-0000-0000-0000-000000000003', 'Aire naturelle / petit camping',   '🌿', 'a4733e63-489d-4608-8109-85dc2d0a9e55', true),
  ('a4730004-0000-0000-0000-000000000004', 'Bivouac / Spot sauvage',           '🏕️', 'a4733e63-489d-4608-8109-85dc2d0a9e55', true),
  ('a4730005-0000-0000-0000-000000000005', 'Parking autorisé camping-car',     '🚐', 'a4733e63-489d-4608-8109-85dc2d0a9e55', false),
  ('a4730006-0000-0000-0000-000000000006', 'Parking autorisé la nuit',         '🌙', 'a4733e63-489d-4608-8109-85dc2d0a9e55', false),
  ('a4730007-0000-0000-0000-000000000007', 'Aire de repos (autoroute)',        '🛣️', 'a4733e63-489d-4608-8109-85dc2d0a9e55', true),
  ('a4730008-0000-0000-0000-000000000008', 'Station de vidange',               '🗑️', 'a4733e63-489d-4608-8109-85dc2d0a9e55', false);
