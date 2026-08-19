import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';

import {
  clearMasteryState,
  loadMasteryState,
  saveMasteryState,
  toNumericStreaks,
} from '../../src/lib/masteryStorage';

const STORAGE_KEY = 'quzzes:mastery:v1';

beforeEach(() => {
  window.localStorage.clear();
});

afterEach(() => {
  vi.restoreAllMocks();
});

describe('mastery storage', () => {
  it('round-trips streaks', () => {
    saveMasteryState({
      streaks: { '1': 2, '5': 1 },
      updatedAt: '2026-08-19T00:00:00.000Z',
    });
    const loaded = loadMasteryState();
    expect(loaded.streaks).toEqual({ '1': 2, '5': 1 });
  });

  it('returns empty state when storage is empty', () => {
    const loaded = loadMasteryState();
    expect(loaded.streaks).toEqual({});
  });

  it('resets to empty when JSON is malformed', () => {
    window.localStorage.setItem(STORAGE_KEY, '{not json');
    const loaded = loadMasteryState();
    expect(loaded.streaks).toEqual({});
  });

  it('drops malformed schema entries', () => {
    window.localStorage.setItem(
      STORAGE_KEY,
      JSON.stringify({ streaks: { '1': 99 }, updatedAt: 'nope' }),
    );
    const loaded = loadMasteryState();
    expect(loaded.streaks).toEqual({});
  });

  it('clears stored data', () => {
    saveMasteryState({
      streaks: { '1': 2 },
      updatedAt: '2026-08-19T00:00:00.000Z',
    });
    clearMasteryState();
    expect(window.localStorage.getItem(STORAGE_KEY)).toBeNull();
  });
});

describe('toNumericStreaks', () => {
  it('projects string keys back to numeric ids and clamps to STREAK_CAP', () => {
    const result = toNumericStreaks({
      streaks: { '1': 2, '2': 1, '3': 0 },
      updatedAt: '2026-08-19T00:00:00.000Z',
    });
    expect(result).toEqual({ 1: 2, 2: 1, 3: 0 });
  });
});
