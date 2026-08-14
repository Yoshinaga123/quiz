import { describe, expect, it } from 'vitest';

import { quizPayloadSchema, quizSchema } from '../../src/schemas/quiz';

const baseQuiz = {
  id: 1,
  section: 'React',
  title: 'useState',
  question: 'What does useState return?',
  options: ['array', 'object'],
  correctAnswerIndex: 0,
  explanation: 'It returns a tuple [state, setState].',
  source: 'https://react.dev/reference/react/useState',
  status: 'published' as const,
  pushEnabled: false,
  createdAt: '2026-01-01T00:00:00Z',
  updatedAt: '2026-01-01T00:00:00Z',
};

const basePayload = {
  section: 'React',
  title: 'useState',
  question: 'What does useState return?',
  code: '',
  options: ['array', 'object'],
  correctAnswerIndex: 0,
  explanation: 'It returns a tuple [state, setState].',
  source: 'https://react.dev/reference/react/useState',
  status: 'published' as const,
  pushEnabled: true,
};

describe('quizSchema', () => {
  it('accepts a valid admin quiz', () => {
    expect(quizSchema.safeParse(baseQuiz).success).toBe(true);
  });

  it('rejects when correctAnswerIndex is out of range', () => {
    const result = quizSchema.safeParse({ ...baseQuiz, correctAnswerIndex: 5 });
    expect(result.success).toBe(false);
    if (!result.success) {
      expect(result.error.issues[0]?.path).toContain('correctAnswerIndex');
    }
  });
});

describe('quizPayloadSchema', () => {
  it('accepts a valid create/update payload', () => {
    expect(quizPayloadSchema.safeParse(basePayload).success).toBe(true);
  });

  it('rejects fewer than two options', () => {
    expect(quizPayloadSchema.safeParse({ ...basePayload, options: ['only'] }).success).toBe(
      false,
    );
  });

  it('rejects empty required strings', () => {
    expect(quizPayloadSchema.safeParse({ ...basePayload, section: '  ' }).success).toBe(false);
    expect(quizPayloadSchema.safeParse({ ...basePayload, source: '' }).success).toBe(false);
  });
});
