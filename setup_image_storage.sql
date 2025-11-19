-- ============================================
-- COMPLETE IMAGE STORAGE SETUP FOR PEPTIVATE
-- ============================================
-- Run this in Supabase SQL Editor to fix all image storage issues
-- This creates both storage buckets and all necessary policies
-- Safe to run multiple times (uses ON CONFLICT and IF EXISTS)

-- ============================================
-- PART 1: ENSURE DATABASE COLUMN EXISTS
-- ============================================
DO $$ 
BEGIN
    -- Add image_url column to products if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'products' 
        AND column_name = 'image_url'
    ) THEN
        ALTER TABLE products ADD COLUMN image_url TEXT;
        RAISE NOTICE '✅ Added image_url column to products table';
    ELSE
        RAISE NOTICE '✅ image_url column already exists';
    END IF;
    
    -- Ensure it's TEXT type (supports long URLs)
    ALTER TABLE products ALTER COLUMN image_url TYPE TEXT;
END $$;

-- ============================================
-- PART 2: CREATE MENU-IMAGES BUCKET
-- ============================================
-- This bucket stores product/peptide images
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'menu-images',
  'menu-images',
  true,  -- Public bucket (important for displaying images!)
  5242880,  -- 5MB limit
  ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/webp', 'image/gif', 'image/bmp', 'image/tiff', 'image/svg+xml', 'image/heic', 'image/heif']
) ON CONFLICT (id) DO UPDATE
SET 
  public = true,
  file_size_limit = 10485760,  -- Increased to 10MB for larger images
  allowed_mime_types = ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/webp', 'image/gif', 'image/bmp', 'image/tiff', 'image/svg+xml', 'image/heic', 'image/heif'];

-- ============================================
-- PART 3: CREATE COA-IMAGES BUCKET
-- ============================================
-- This bucket stores COA (Certificate of Analysis) lab report images
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'coa-images',
  'coa-images',
  true,  -- Public bucket (important for displaying images!)
  10485760,  -- 10MB limit (COA reports can be larger)
  ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/webp', 'image/gif', 'image/bmp', 'image/tiff', 'image/svg+xml', 'image/heic', 'image/heif']
) ON CONFLICT (id) DO UPDATE
SET 
  public = true,
  file_size_limit = 10485760,
  allowed_mime_types = ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/webp', 'image/gif', 'image/bmp', 'image/tiff', 'image/svg+xml', 'image/heic', 'image/heif'];

-- ============================================
-- PART 4: STORAGE POLICIES FOR MENU-IMAGES
-- ============================================

-- Allow public read access (so images can be displayed on website)
DROP POLICY IF EXISTS "Public read access for menu images" ON storage.objects;
CREATE POLICY "Public read access for menu images"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'menu-images');

-- Allow anyone to upload (for admin panel)
DROP POLICY IF EXISTS "Anyone can upload menu images" ON storage.objects;
CREATE POLICY "Anyone can upload menu images"
ON storage.objects
FOR INSERT
TO public
WITH CHECK (bucket_id = 'menu-images');

-- Allow updates (for replacing images)
DROP POLICY IF EXISTS "Anyone can update menu images" ON storage.objects;
CREATE POLICY "Anyone can update menu images"
ON storage.objects
FOR UPDATE
TO public
USING (bucket_id = 'menu-images')
WITH CHECK (bucket_id = 'menu-images');

-- Allow deletes (for removing images)
DROP POLICY IF EXISTS "Anyone can delete menu images" ON storage.objects;
CREATE POLICY "Anyone can delete menu images"
ON storage.objects
FOR DELETE
TO public
USING (bucket_id = 'menu-images');

-- ============================================
-- PART 5: STORAGE POLICIES FOR COA-IMAGES
-- ============================================

-- Allow public read access (so COA images can be displayed)
DROP POLICY IF EXISTS "Public read access for coa images" ON storage.objects;
CREATE POLICY "Public read access for coa images"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'coa-images');

-- Allow anyone to upload (for admin panel)
DROP POLICY IF EXISTS "Anyone can upload coa images" ON storage.objects;
CREATE POLICY "Anyone can upload coa images"
ON storage.objects
FOR INSERT
TO public
WITH CHECK (bucket_id = 'coa-images');

-- Allow updates (for replacing images)
DROP POLICY IF EXISTS "Anyone can update coa images" ON storage.objects;
CREATE POLICY "Anyone can update coa images"
ON storage.objects
FOR UPDATE
TO public
USING (bucket_id = 'coa-images')
WITH CHECK (bucket_id = 'coa-images');

-- Allow deletes (for removing images)
DROP POLICY IF EXISTS "Anyone can delete coa images" ON storage.objects;
CREATE POLICY "Anyone can delete coa images"
ON storage.objects
FOR DELETE
TO public
USING (bucket_id = 'coa-images');

-- ============================================
-- PART 6: VERIFICATION
-- ============================================
-- Check if buckets were created successfully
SELECT 
    '=== STORAGE BUCKETS ===' as check_type,
    id as bucket_id,
    name,
    public,
    file_size_limit,
    CASE 
        WHEN id IS NULL THEN '❌ FAILED - Bucket not created'
        WHEN public = false THEN '⚠️ WARNING - Bucket is private (should be public)'
        ELSE '✅ SUCCESS - Bucket exists and is public'
    END as status
FROM storage.buckets
WHERE id IN ('menu-images', 'coa-images')
ORDER BY id;

-- Check storage policies
SELECT 
    '=== STORAGE POLICIES ===' as check_type,
    policyname,
    cmd as operation,
    CASE 
        WHEN cmd = 'SELECT' THEN '✅ Read policy'
        WHEN cmd = 'INSERT' THEN '✅ Upload policy'
        WHEN cmd = 'UPDATE' THEN '✅ Update policy'
        WHEN cmd = 'DELETE' THEN '✅ Delete policy'
        ELSE 'ℹ️ Other policy'
    END as status
FROM pg_policies
WHERE schemaname = 'storage' 
AND tablename = 'objects'
AND (policyname LIKE '%menu-images%' OR policyname LIKE '%coa-images%' OR policyname LIKE '%menu%' OR policyname LIKE '%coa%')
ORDER BY policyname, cmd;

-- Check database column
SELECT 
    '=== DATABASE COLUMN ===' as check_type,
    column_name,
    data_type,
    CASE 
        WHEN column_name IS NULL THEN '❌ FAILED - Column does not exist'
        WHEN data_type != 'text' THEN '⚠️ WARNING - Wrong type: ' || data_type
        ELSE '✅ SUCCESS - Column exists and is TEXT type'
    END as status
FROM information_schema.columns
WHERE table_name = 'products' 
AND column_name = 'image_url';

-- ============================================
-- PART 7: FINAL SUMMARY
-- ============================================
SELECT 
    '=== SETUP SUMMARY ===' as summary_type,
    CASE 
        WHEN EXISTS (SELECT 1 FROM storage.buckets WHERE id = 'menu-images' AND public = true)
            AND EXISTS (SELECT 1 FROM storage.buckets WHERE id = 'coa-images' AND public = true)
            AND EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'products' AND column_name = 'image_url')
            AND EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'storage' AND tablename = 'objects' AND cmd = 'INSERT' AND (policyname LIKE '%menu-images%' OR policyname LIKE '%menu%'))
            AND EXISTS (SELECT 1 FROM pg_policies WHERE schemaname = 'storage' AND tablename = 'objects' AND cmd = 'INSERT' AND (policyname LIKE '%coa-images%' OR policyname LIKE '%coa%'))
        THEN '✅ ALL CHECKS PASSED - Image storage is ready!'
        ELSE '⚠️ SOME CHECKS FAILED - Review the verification results above'
    END as overall_status;

-- ============================================
-- ✅ DONE! 
-- ============================================
-- If you see "ALL CHECKS PASSED" above, image storage is ready!
-- 
-- Next steps:
-- 1. Go to /admin in your app
-- 2. Try uploading an image to a product
-- 3. Try uploading a COA report image
-- 4. Check browser console (F12) for any errors
-- 5. Images should now upload and save successfully!
--
-- If you still have issues:
-- 1. Check the browser console for specific error messages
-- 2. Verify buckets exist in Supabase Dashboard → Storage
-- 3. Make sure both buckets are set to "Public"
-- 4. Try the URL input method as a fallback

