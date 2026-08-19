CREATE TABLE IF NOT EXISTS answer_history (
    id             BIGSERIAL   PRIMARY KEY,
    member_id      UUID        NOT NULL REFERENCES members(id) ON DELETE CASCADE,
    quiz_id        BIGINT      NOT NULL REFERENCES quizzes(id) ON DELETE CASCADE,
    selected_index INT         NOT NULL CHECK (selected_index >= 0),
    answered_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_answer_history_member_answered
    ON answer_history (member_id, answered_at DESC);

CREATE INDEX IF NOT EXISTS idx_answer_history_member_quiz
    ON answer_history (member_id, quiz_id);
