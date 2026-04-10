DELETE FROM quizzes WHERE id >= 128;
SELECT setval('quizzes_id_seq', (SELECT COALESCE(MAX(id), 1) FROM quizzes));
