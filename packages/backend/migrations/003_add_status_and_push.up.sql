ALTER TABLE quizzes
    ADD COLUMN status       VARCHAR(20) NOT NULL DEFAULT 'unpublished',
    ADD COLUMN push_enabled BOOLEAN     NOT NULL DEFAULT false;
