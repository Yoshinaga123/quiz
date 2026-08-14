import { describe, expect, it } from 'vitest';

import { STARTER_QUIZZES } from '../../src/data/quizzes';
import { quizSchema, quizzesSchema } from '../../src/schemas/quiz';

const baseQuiz = {
  id: 1,
  section: 'React',
  title: 'useState',
  question: 'What does useState return?',
  options: ['array', 'object'],
  correctAnswerIndex: 0,
  explanation: 'It returns a tuple [state, setState].',
  source: 'https://react.dev/reference/react/useState',
};

describe('quizSchema', () => {
  it('accepts a valid quiz', () => {
    expect(quizSchema.safeParse(baseQuiz).success).toBe(true);
  });

  it('rejects when correctAnswerIndex is out of range', () => {
    const result = quizSchema.safeParse({ ...baseQuiz, correctAnswerIndex: 5 });
    expect(result.success).toBe(false);
    if (!result.success) {
      expect(result.error.issues[0]?.path).toContain('correctAnswerIndex');
    }
  });

  it('rejects when options has fewer than 2 entries', () => {
    const result = quizSchema.safeParse({ ...baseQuiz, options: ['only'] });
    expect(result.success).toBe(false);
  });

  it('rejects empty required strings', () => {
    expect(quizSchema.safeParse({ ...baseQuiz, section: '' }).success).toBe(false);
    expect(quizSchema.safeParse({ ...baseQuiz, source: '' }).success).toBe(false);
  });

  it('accepts optional code field as string', () => {
    expect(
      quizSchema.safeParse({ ...baseQuiz, code: 'console.log(1)' }).success,
    ).toBe(true);
  });
});

describe('quizzesSchema', () => {
  it('accepts STARTER_QUIZZES', () => {
    expect(quizzesSchema.safeParse(STARTER_QUIZZES).success).toBe(true);
  });

  it('accepts an empty list', () => {
    expect(quizzesSchema.safeParse([]).success).toBe(true);
  });

  it('rejects a list containing an invalid entry', () => {
    const result = quizzesSchema.safeParse([
      baseQuiz,
      { ...baseQuiz, id: -1 },
    ]);
    expect(result.success).toBe(false);
  });
});
