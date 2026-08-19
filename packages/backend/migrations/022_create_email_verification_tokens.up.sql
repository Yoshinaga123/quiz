CREATE TABLE IF NOT EXISTS email_verification_tokens (
    token_hash  TEXT        PRIMARY KEY,
    member_id   UUID        NOT NULL REFERENCES members(id) ON DELETE CASCADE,
    -- The email being verified. Kept even if the member later changes it.
    email       CITEXT      NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expires_at  TIMESTAMPTZ NOT NULL,
    consumed_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_email_verification_tokens_member_created
    ON email_verification_tokens (member_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_email_verification_tokens_expires
    ON email_verification_tokens (expires_at);
