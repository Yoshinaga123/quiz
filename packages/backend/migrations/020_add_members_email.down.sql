DROP INDEX IF EXISTS members_email_active_uniq;
ALTER TABLE members
    DROP COLUMN IF EXISTS email_verified_at,
    DROP COLUMN IF EXISTS email;
