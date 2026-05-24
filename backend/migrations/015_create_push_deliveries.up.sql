CREATE TABLE IF NOT EXISTS push_deliveries (
    id           BIGSERIAL   PRIMARY KEY,
    quiz_id      BIGINT      NOT NULL REFERENCES quizzes(id),
    channel      VARCHAR(20) NOT NULL DEFAULT 'mock',
    target_count INT         NOT NULL DEFAULT 0,
    status       VARCHAR(20) NOT NULL,
    error_detail TEXT,
    sent_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_push_deliveries_sent_at ON push_deliveries (sent_at DESC);
CREATE INDEX idx_push_deliveries_quiz_id ON push_deliveries (quiz_id);
