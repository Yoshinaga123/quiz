CREATE TABLE IF NOT EXISTS attempts (
    client_session_id UUID PRIMARY KEY,
    section           TEXT,
    completed_at      TIMESTAMPTZ NOT NULL,
    total_count       INT         NOT NULL,
    correct_count     INT         NOT NULL,
    created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS attempt_answers (
    client_session_id UUID    NOT NULL REFERENCES attempts(client_session_id) ON DELETE CASCADE,
    quiz_id           BIGINT  NOT NULL REFERENCES quizzes(id),
    selected_index    INT     NOT NULL,
    is_correct        BOOLEAN NOT NULL,
    answered_at       TIMESTAMPTZ,
    PRIMARY KEY (client_session_id, quiz_id)
);

CREATE INDEX idx_attempt_answers_quiz_id ON attempt_answers (quiz_id);
