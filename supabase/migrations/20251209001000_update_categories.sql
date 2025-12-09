-- Align categories with peptide/wellness catalog and deactivate legacy coffee categories
DO $$
DECLARE
  new_categories CONSTANT JSONB := '[
    {"id":"all","name":"All Products","icon":"Grid","sort_order":0,"active":true},
    {"id":"research","name":"Research Peptides","icon":"FlaskConical","sort_order":1,"active":true},
    {"id":"cosmetic","name":"Cosmetic & Beauty","icon":"Sparkles","sort_order":2,"active":true},
    {"id":"wellness","name":"Wellness & Recovery","icon":"HeartPulse","sort_order":3,"active":true},
    {"id":"weight","name":"Weight Management","icon":"Activity","sort_order":4,"active":true},
    {"id":"supplies","name":"Supplies & Accessories","icon":"Package","sort_order":5,"active":true}
  ]'::jsonb;
BEGIN
  -- Ensure categories table exists
  IF NOT EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'categories') THEN
    CREATE TABLE categories (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      icon TEXT NOT NULL,
      sort_order INTEGER DEFAULT 0,
      active BOOLEAN DEFAULT true,
      created_at TIMESTAMPTZ DEFAULT NOW(),
      updated_at TIMESTAMPTZ DEFAULT NOW()
    );
  END IF;

  -- Upsert new categories
  INSERT INTO categories (id, name, icon, sort_order, active)
  SELECT
    (cat->>'id')::text,
    cat->>'name',
    cat->>'icon',
    (cat->>'sort_order')::int,
    (cat->>'active')::boolean
  FROM jsonb_array_elements(new_categories) AS cat
  ON CONFLICT (id) DO UPDATE
  SET
    name = EXCLUDED.name,
    icon = EXCLUDED.icon,
    sort_order = EXCLUDED.sort_order,
    active = EXCLUDED.active,
    updated_at = NOW();

  -- Deactivate any legacy categories not in the new list
  UPDATE categories
  SET active = false, updated_at = NOW()
  WHERE id NOT IN (
    SELECT cat_obj->>'id'
    FROM jsonb_array_elements(new_categories) AS cat_obj
  );

  -- Normalize products assigned to legacy categories: move to research
  UPDATE products
  SET category = 'research'
  WHERE category NOT IN (
    SELECT cat_obj->>'id'
    FROM jsonb_array_elements(new_categories) AS cat_obj
  );
END $$;

