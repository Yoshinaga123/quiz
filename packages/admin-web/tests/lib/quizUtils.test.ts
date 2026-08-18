import { describe, expect, it } from 'vitest';

import { enrichQuizWithAnswer, isAnswerCorrect } from '../../src/components/JsonQuizPreviewSection/quizUtils';
import type { Quiz } from '../../src/types/quiz';

const quiz: Quiz = {
  id: 1,
  section: 'React',
  title: 'useState',
  question: 'q',
  options: ['a', 'b'],
  correctAnswerIndex: 1,
  explanation: 'e',
  source: 's',
  published: true,
};

describe('isAnswerCorrect', () => {
  it('returns true only for the correct index', () => {
    expect(isAnswerCorrect(quiz, 1)).toBe(true);
    expect(isAnswerCorrect(quiz, 0)).toBe(false);
  });
});

describe('enrichQuizWithAnswer', () => {
  it('leaves isCorrect undefined when unanswered', () => {
    expect(enrichQuizWithAnswer(quiz).isCorrect).toBeUndefined();
    expect(enrichQuizWithAnswer(quiz, null).isCorrect).toBeUndefined();
  });

  it('marks a matching answer as correct', () => {
    expect(enrichQuizWithAnswer(quiz, 1).isCorrect).toBe(true);
  });
});
