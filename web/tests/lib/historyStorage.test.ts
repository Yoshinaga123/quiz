import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';

import { clearHistory, loadHistory, saveHistory } from '../../src/lib/historyStorage';
import type { HistoryRecord } from '../../src/types/quiz';

const STORAGE_KEY = 'quzzes:history:v1';

const validRecord: HistoryRecord = {
  id: '00000000-0000-4000-8000-000000000001',
  sectionFilter: null,
  total: 2,
  correct: 1,
  startedAt: '2026-04-21T00:00:00.000Z',
  completedAt: '2026-04-21T00:00:30.000Z',
  answers: [
    { quizId: 1, selectedIndex: 0, correct: true },
    { quizId: 2, selectedIndex: 1, correct: false },
  ],
};

beforeEach(() => {
  window.localStorage.clear();
});

afterEach(() => {
  vi.restoreAllMocks();
});

describe('saveHistory / loadHistory', () => {
  it('round-trips a valid record', () => {
    saveHistory([validRecord]);
    expect(loadHistory()).toEqual([validRecord]);
  });

  it('returns empty when storage is empty', () => {
    expect(loadHistory()).toEqual([]);
  });

  it('clears stored data', () => {
    saveHistory([validRecord]);
    clearHistory();
    expect(loadHistory()).toEqual([]);
  });
});

describe('loadHistory error handling', () => {
  it('returns empty and dispatches a corrupted event when JSON is invalid', () => {
    const dispatchSpy = vi.spyOn(window, 'dispatchEvent');
    window.localStorage.setItem(STORAGE_KEY, '{not json');

    const result = loadHistory();

    expect(result).toEqual([]);
    expect(dispatchSpy).toHaveBeenCalledTimes(1);
    const event = dispatchSpy.mock.calls[0][0] as CustomEvent;
    expect(event.type).toBe('quzzes:history:corrupted');
  });

  it('returns empty and dispatches a corrupted event when schema fails', () => {
    const dispatchSpy = vi.spyOn(window, 'dispatchEvent');
    window.localStorage.setItem(STORAGE_KEY, JSON.stringify([{ bogus: true }]));

    const result = loadHistory();

    expect(result).toEqual([]);
    expect(dispatchSpy).toHaveBeenCalledTimes(1);
    expect((dispatchSpy.mock.calls[0][0] as CustomEvent).type).toBe(
      'quzzes:history:corrupted',
    );
  });
});
