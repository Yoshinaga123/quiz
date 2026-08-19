CREATE EXTENSION IF NOT EXISTS citext;

CREATE TABLE IF NOT EXISTS members (
    id            UUID        PRIMARY KEY,
    handle        CITEXT      NOT NULL,
    password_hash TEXT        NOT NULL,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at    TIMESTAMPTZ
);

-- Handle uniqueness applies only to non-deleted members; ADR 0016 §5 allows re-use after soft-delete.
CREATE UNIQUE INDEX IF NOT EXISTS members_handle_active_uniq
    ON members (handle)
    WHERE deleted_at IS NULL;
