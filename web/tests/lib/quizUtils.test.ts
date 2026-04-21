import { describe, expect, it, vi } from 'vitest';

import {
  calculateAccuracy,
  filterBySection,
  findQuiz,
  isAnswerCorrect,
  listSections,
  pickQuizIds,
  shuffle,
} from '../../src/lib/quizUtils';
import type { Quiz } from '../../src/types/quiz';

const sampleQuizzes: Quiz[] = [
  {
    id: 1,
    section: 'React Hooks',
    title: 'useEffect',
    question: 'q1',
    options: ['a', 'b'],
    correctAnswerIndex: 0,
    explanation: 'e1',
    source: 's1',
  },
  {
    id: 2,
    section: 'React Hooks',
    title: 'useMemo',
    question: 'q2',
    options: ['a', 'b'],
    correctAnswerIndex: 1,
    explanation: 'e2',
    source: 's2',
  },
  {
    id: 3,
    section: 'TypeScript',
    title: 'narrowing',
    question: 'q3',
    options: ['a', 'b'],
    correctAnswerIndex: 0,
    explanation: 'e3',
    source: 's3',
  },
];

describe('listSections', () => {
  it('counts quizzes per section', () => {
    expect(listSections(sampleQuizzes)).toEqual([
      { section: 'React Hooks', count: 2 },
      { section: 'TypeScript', count: 1 },
    ]);
  });

  it('returns empty for empty input', () => {
    expect(listSections([])).toEqual([]);
  });
});

describe('filterBySection', () => {
  it('returns all quizzes when section is null or empty', () => {
    expect(filterBySection(sampleQuizzes, null)).toHaveLength(3);
    expect(filterBySection(sampleQuizzes, '')).toHaveLength(3);
  });

  it('filters by exact section', () => {
    expect(filterBySection(sampleQuizzes, 'TypeScript')).toEqual([sampleQuizzes[2]]);
  });
});

describe('shuffle', () => {
  it('returns a permutation without mutating input', () => {
    const input = [1, 2, 3, 4, 5];
    const snapshot = [...input];
    const result = shuffle(input);
    expect(input).toEqual(snapshot);
    expect(result).toHaveLength(snapshot.length);
    expect([...result].sort()).toEqual([...snapshot].sort());
  });
});

describe('pickQuizIds', () => {
  it('returns at most `limit` ids from the matching pool', () => {
    const ids = pickQuizIds(sampleQuizzes, 'React Hooks', 5);
    expect(ids).toHaveLength(2);
    expect(ids.every((id) => id === 1 || id === 2)).toBe(true);
  });

  it('returns empty when limit is 0 or pool empty', () => {
    expect(pickQuizIds(sampleQuizzes, 'Unknown', 5)).toEqual([]);
    expect(pickQuizIds(sampleQuizzes, null, 0)).toEqual([]);
  });

  it('is deterministic when Math.random is stubbed', () => {
    const spy = vi.spyOn(Math, 'random').mockReturnValue(0);
    try {
      const ids = pickQuizIds(sampleQuizzes, null, 3);
      expect(ids).toHaveLength(3);
    } finally {
      spy.mockRestore();
    }
  });
});

describe('findQuiz / isAnswerCorrect', () => {
  it('finds by id', () => {
    expect(findQuiz(sampleQuizzes, 2)?.title).toBe('useMemo');
    expect(findQuiz(sampleQuizzes, 999)).toBeUndefined();
  });

  it('checks selected index against correctAnswerIndex', () => {
    const quiz = sampleQuizzes[0];
    expect(isAnswerCorrect(quiz, 0)).toBe(true);
    expect(isAnswerCorrect(quiz, 1)).toBe(false);
  });
});

describe('calculateAccuracy', () => {
  it('rounds to nearest integer percent', () => {
    expect(calculateAccuracy(0, 0)).toBe(0);
    expect(calculateAccuracy(1, 3)).toBe(33);
    expect(calculateAccuracy(2, 3)).toBe(67);
    expect(calculateAccuracy(5, 5)).toBe(100);
  });
});
