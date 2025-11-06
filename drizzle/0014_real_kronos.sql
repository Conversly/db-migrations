-- ...existing code...
BEGIN;

-- Ensure UUID generator (pgcrypto). If you use uuid-ossp, change to uuid_generate_v4().
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Drop primary key constraint if present
DO $$
DECLARE
  pk text;
BEGIN
  SELECT conname INTO pk
  FROM pg_constraint
  WHERE conrelid = 'messages'::regclass AND contype = 'p';
  IF pk IS NOT NULL THEN
    EXECUTE format('ALTER TABLE "messages" DROP CONSTRAINT %I', pk);
  END IF;
END$$;

-- Drop old id column and add new uuid primary key with default
ALTER TABLE "messages" DROP COLUMN IF EXISTS id;
ALTER TABLE "messages" ADD COLUMN id uuid PRIMARY KEY DEFAULT gen_random_uuid();

COMMIT;
-- ...existing code...