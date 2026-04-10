CREATE TABLE IF NOT EXISTS views (
    id    INT PRIMARY KEY,
    count INT NOT NULL
);

INSERT INTO views (id, count)
VALUES (1, 0)
ON CONFLICT (id) DO NOTHING;

CREATE TABLE IF NOT EXISTS quizzes (
    id                   BIGSERIAL PRIMARY KEY,
    section              TEXT        NOT NULL,
    title                TEXT        NOT NULL,
    question             TEXT        NOT NULL,
    code                 TEXT,
    options              JSONB       NOT NULL,
    correct_answer_index INT         NOT NULL,
    explanation          TEXT        NOT NULL,
    source               TEXT        NOT NULL,
    created_at           TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at           TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
