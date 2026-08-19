CREATE TABLE IF NOT EXISTS member_login_logs (
    id         BIGSERIAL   PRIMARY KEY,
    -- Handles that do not exist in members are still recorded here.
    handle     CITEXT      NOT NULL,
    success    BOOLEAN     NOT NULL,
    ip_address TEXT        NOT NULL DEFAULT '',
    user_agent TEXT        NOT NULL DEFAULT '',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_member_login_logs_handle_created
    ON member_login_logs (handle, success, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_member_login_logs_ip_created
    ON member_login_logs (ip_address, success, created_at DESC);

-- Extend login_logs (ADR 0004) with the same sliding-window shape.
CREATE INDEX IF NOT EXISTS idx_login_logs_username_success_created
    ON login_logs (username, success, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_login_logs_ip_success_created
    ON login_logs (ip_address, success, created_at DESC);
