import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

import { describe, expect, it } from 'vitest';

import {
  attemptAcceptedSchema,
  attemptCreateRequestSchema,
  historyRecordToAttempt,
  quizListResponseSchema,
} from '../../src/api/quiz';
import { quizSchema } from '../../src/schemas/quiz';
import type { HistoryRecord } from '../../src/types/quiz';

const fixturesDir = path.resolve(
  path.dirname(fileURLToPath(import.meta.url)),
  '../../../../docs/api/fixtures',
);

const readFixture = (name: string): unknown =>
  JSON.parse(fs.readFileSync(path.join(fixturesDir, name), 'utf8')) as unknown;

describe('public API fixtures', () => {
  it('parses quiz.json with quizSchema', () => {
    const result = quizSchema.safeParse(readFixture('quiz.json'));
    expect(result.success).toBe(true);
  });

  it('rejects quiz-invalid-answer-index.json via refine', () => {
    const result = quizSchema.safeParse(readFixture('quiz-invalid-answer-index.json'));
    expect(result.success).toBe(false);
    if (!result.success) {
      expect(result.error.issues[0]?.path).toContain('correctAnswerIndex');
    }
  });

  it('parses quiz-list.json with quizListResponseSchema', () => {
    const result = quizListResponseSchema.safeParse(readFixture('quiz-list.json'));
    expect(result.success).toBe(true);
  });

  it('keeps quiz-list.json[0] identical to quiz.json', () => {
    const quiz = readFixture('quiz.json');
    const list = readFixture('quiz-list.json') as { quizzes: unknown[] };
    expect(list.quizzes[0]).toEqual(quiz);
  });

  it('parses attempt fixtures with attempt schemas', () => {
    expect(attemptCreateRequestSchema.safeParse(readFixture('attempt-create.json')).success).toBe(true);
    expect(attemptAcceptedSchema.safeParse(readFixture('attempt-accepted.json')).success).toBe(true);
  });

  it('rejects empty attempt answers', () => {
    const result = attemptCreateRequestSchema.safeParse(readFixture('attempt-invalid-empty-answers.json'));
    expect(result.success).toBe(false);
    if (!result.success) {
      expect(result.error.issues[0]?.path).toContain('answers');
    }
  });

  it('maps local history to the attempt request payload', () => {
    const record: HistoryRecord = {
      id: '550e8400-e29b-41d4-a716-446655440000',
      sectionFilter: 'React',
      total: 1,
      correct: 1,
      startedAt: '2026-01-15T10:00:00.000Z',
      completedAt: '2026-01-15T10:30:00.000Z',
      answers: [{ quizId: 1, selectedIndex: 0, correct: true }],
    };

    expect(historyRecordToAttempt(record)).toEqual({
      clientSessionId: record.id,
      completedAt: record.completedAt,
      section: 'React',
      answers: [{ quizId: 1, selectedIndex: 0, isCorrect: true }],
    });
  });
});
