CREATE TABLE IF NOT EXISTS password_reset_tokens (
    -- SHA-256 hex of the plaintext token. Plaintext is never stored (ADR 0018 §2).
    token_hash  TEXT        PRIMARY KEY,
    member_id   UUID        NOT NULL REFERENCES members(id) ON DELETE CASCADE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expires_at  TIMESTAMPTZ NOT NULL,
    consumed_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_password_reset_tokens_member_created
    ON password_reset_tokens (member_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_password_reset_tokens_expires
    ON password_reset_tokens (expires_at);
