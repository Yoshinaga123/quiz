-- Existing quizzes tables created by 001 have no status/push_enabled.
-- IF NOT EXISTS lets this re-apply when schema_migrations is missing or dirty.
ALTER TABLE quizzes ADD COLUMN IF NOT EXISTS status VARCHAR(20) NOT NULL DEFAULT 'unpublished';
ALTER TABLE quizzes ADD COLUMN IF NOT EXISTS push_enabled BOOLEAN NOT NULL DEFAULT false;
