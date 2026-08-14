import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

import { describe, expect, it } from 'vitest';

import { quizListResponseSchema } from '../../src/api/quiz';
import { quizSchema } from '../../src/schemas/quiz';

const fixturesDir = path.resolve(
  path.dirname(fileURLToPath(import.meta.url)),
  '../../../docs/api/fixtures',
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
});
