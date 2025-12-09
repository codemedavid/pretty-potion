-- Add/update Pretty Potion product price list
DO $$
DECLARE
  tirz_id UUID;
  gluta_id UUID;
  nad_id UUID;
BEGIN
  -- Ensure base category exists
  INSERT INTO categories (id, name, icon, sort_order, active)
  VALUES ('research', 'Research Peptides', 'FlaskConical', 1, true)
  ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    icon = EXCLUDED.icon,
    sort_order = EXCLUDED.sort_order,
    active = EXCLUDED.active;

  -- Tirzepatide with variations
  SELECT id INTO tirz_id FROM products WHERE name = 'Tirzepatide';
  IF tirz_id IS NULL THEN
    INSERT INTO products (
      name, description, category, base_price,
      discount_price, discount_start_date, discount_end_date, discount_active,
      purity_percentage, molecular_weight, cas_number, sequence, storage_conditions,
      stock_quantity, available, featured, image_url, safety_sheet_url, inclusions
    )
    VALUES (
      'Tirzepatide',
      'Multi-dose peptide pen with weight support focus.',
      'research',
      3500,
      NULL, NULL, NULL, false,
      99.0, NULL, NULL, NULL, 'Store refrigerated',
      0, true, true, NULL, NULL, ARRAY['Pen cap','Instructions']
    )
    RETURNING id INTO tirz_id;
  END IF;

  -- Replace variations for Tirzepatide
  DELETE FROM product_variations WHERE product_id = tirz_id;
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES
    (tirz_id, '15mg', 15, 3500, 0),
    (tirz_id, '20mg', 20, 4500, 0),
    (tirz_id, '30mg', 30, 5500, 0);

  -- AOD-9604
  INSERT INTO products (
    name, description, category, base_price,
    discount_price, discount_start_date, discount_end_date, discount_active,
    purity_percentage, molecular_weight, cas_number, sequence, storage_conditions,
    stock_quantity, available, featured, image_url, safety_sheet_url, inclusions
  )
  SELECT
    'AOD-9604',
    'Peptide support formula.',
    'research',
    4000,
    NULL, NULL, NULL, false,
    99.0, NULL, NULL, NULL, 'Store refrigerated',
    0, true, false, NULL, NULL, NULL
  WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'AOD-9604');

  -- Glutathione 1500mg
  SELECT id INTO gluta_id FROM products WHERE name = 'Glutathione';
  IF gluta_id IS NULL THEN
    INSERT INTO products (
      name, description, category, base_price,
      discount_price, discount_start_date, discount_end_date, discount_active,
      purity_percentage, molecular_weight, cas_number, sequence, storage_conditions,
      stock_quantity, available, featured, image_url, safety_sheet_url, inclusions
    )
    VALUES (
      'Glutathione',
      'Antioxidant support vial.',
      'research',
      3500,
      NULL, NULL, NULL, false,
      99.0, NULL, NULL, NULL, 'Store refrigerated',
      0, true, false, NULL, NULL, NULL
    )
    RETURNING id INTO gluta_id;
  END IF;
  DELETE FROM product_variations WHERE product_id = gluta_id;
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES
    (gluta_id, '1500mg', 1500, 3500, 0);

  -- NAD+ 500
  SELECT id INTO nad_id FROM products WHERE name = 'NAD+';
  IF nad_id IS NULL THEN
    INSERT INTO products (
      name, description, category, base_price,
      discount_price, discount_start_date, discount_end_date, discount_active,
      purity_percentage, molecular_weight, cas_number, sequence, storage_conditions,
      stock_quantity, available, featured, image_url, safety_sheet_url, inclusions
    )
    VALUES (
      'NAD+',
      'NAD+ support vial.',
      'research',
      3500,
      NULL, NULL, NULL, false,
      99.0, NULL, NULL, NULL, 'Store refrigerated',
      0, true, false, NULL, NULL, NULL
    )
    RETURNING id INTO nad_id;
  END IF;
  DELETE FROM product_variations WHERE product_id = nad_id;
  INSERT INTO product_variations (product_id, name, quantity_mg, price, stock_quantity) VALUES
    (nad_id, '500mg', 500, 3500, 0);

  -- Simple single-price items (no variations)
  INSERT INTO products (
    name, description, category, base_price,
    discount_price, discount_start_date, discount_end_date, discount_active,
    purity_percentage, molecular_weight, cas_number, sequence, storage_conditions,
    stock_quantity, available, featured, image_url, safety_sheet_url, inclusions
  )
  SELECT
    p.name, p.description, 'research', p.price,
    NULL, NULL, NULL, false,
    99.0, NULL, NULL, NULL, 'Store refrigerated',
    0, true, false, NULL, NULL, NULL
  FROM (VALUES
    ('Klow', 'Klow peptide support', 3000),
    ('Glow', 'Glow peptide support', 3000),
    ('Cagri', 'Cagrilintide-inspired support', 3500),
    ('Lemon Bottle', 'Lemon Bottle formulation', 5500)
  ) AS p(name, description, price)
  WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = p.name);
END $$;

