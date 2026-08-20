import { describe, expect, it } from 'vitest';

import {
  computeRank,
  nextStreak,
  RANK_LABELS,
  STREAK_CAP,
} from '../../src/lib/rank';

describe('nextStreak', () => {
  it('caps at STREAK_CAP on consecutive correct', () => {
    expect(nextStreak(0, true)).toBe(1);
    expect(nextStreak(1, true)).toBe(2);
    expect(nextStreak(2, true)).toBe(2);
  });

  it('resets to 0 on wrong answer', () => {
    expect(nextStreak(2, false)).toBe(0);
    expect(nextStreak(1, false)).toBe(0);
  });

  it('sanitizes bogus current values', () => {
    expect(nextStreak(Number.NaN, true)).toBe(1);
    expect(nextStreak(-3, true)).toBe(1);
    expect(nextStreak(9, true)).toBe(2);
  });
});

describe('computeRank', () => {
  const quizIds = Array.from({ length: 20 }, (_, i) => i + 1);

  it('returns 4級 for empty streaks', () => {
    const result = computeRank({}, quizIds);
    expect(result.rank).toBe('4級');
    expect(result.index).toBe(0);
    expect(result.mastery).toBe(0);
    expect(result.totalPossible).toBe(40);
    expect(result.nextRank).toBe('3級');
  });

  it('returns 4級 for a brand-new user with empty quiz catalog', () => {
    const result = computeRank({}, []);
    expect(result.rank).toBe('4級');
    expect(result.mastery).toBe(0);
    expect(result.totalPossible).toBe(0);
  });

  it('returns 名人 only at full mastery', () => {
    const perfect: Record<number, number> = {};
    for (const id of quizIds) perfect[id] = STREAK_CAP;
    const result = computeRank(perfect, quizIds);
    expect(result.rank).toBe('名人');
    expect(result.index).toBe(RANK_LABELS.length - 1);
    expect(result.nextRank).toBeNull();
    expect(result.toNextRank).toBe(0);
    expect(result.progress).toBe(1);
  });

  it('does not award 名人 when a single question is short', () => {
    const almost: Record<number, number> = {};
    for (const id of quizIds) almost[id] = STREAK_CAP;
    almost[1] = 1;
    const result = computeRank(almost, quizIds);
    expect(result.rank).not.toBe('名人');
    expect(result.progress).toBeLessThan(1);
  });

  it('ignores streaks for quizzes no longer in the catalog', () => {
    const streaks = { 1: 2, 999: 2 };
    const result = computeRank(streaks, [1, 2, 3]);
    expect(result.mastery).toBe(2);
    expect(result.totalPossible).toBe(6);
  });

  it('clamps streak values above STREAK_CAP', () => {
    const streaks: Record<number, number> = { 1: 5, 2: -1 };
    const result = computeRank(streaks, [1, 2]);
    expect(result.mastery).toBe(STREAK_CAP);
  });

  it('advances one rank as mastery grows', () => {
    // 26 pt of 40 → progress = 0.65 → resolveRankIndex = floor(0.65 * 13) = 8 Levels: 0=4級, 1=3級, 2=2級, 3=1級, 4=初段, 5=二段, 6=三段, 7=四段, 8=五段
    const streaks: Record<number, number> = {};
    let pt = 0;
    for (const id of quizIds) {
      if (pt + 2 <= 26) {
        streaks[id] = 2;
        pt += 2;
      } else if (pt < 26) {
        streaks[id] = 26 - pt;
        pt = 26;
      }
    }
    const result = computeRank(streaks, quizIds);
    expect(result.mastery).toBe(26);
    expect(result.rank).toBe('五段');
  });
});
