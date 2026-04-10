CREATE TABLE IF NOT EXISTS login_logs (
    id         BIGSERIAL   PRIMARY KEY,
    username   TEXT        NOT NULL,
    success    BOOLEAN     NOT NULL,
    ip_address TEXT        NOT NULL DEFAULT '',
    user_agent TEXT        NOT NULL DEFAULT '',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_login_logs_created_at ON login_logs (created_at DESC);
