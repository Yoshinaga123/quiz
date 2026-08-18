ALTER TABLE members
    ADD COLUMN IF NOT EXISTS email             CITEXT,
    ADD COLUMN IF NOT EXISTS email_verified_at TIMESTAMPTZ;

-- Partial unique index: email is only enforced unique for active members with a value.
CREATE UNIQUE INDEX IF NOT EXISTS members_email_active_uniq
    ON members (email)
    WHERE deleted_at IS NULL AND email IS NOT NULL;
