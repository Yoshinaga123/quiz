import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { z } from 'zod';

import { submitAttemptBestEffort } from '../../src/api/quiz';
import { ApiConfigError, ApiError, getApiBaseUrl, requestJson } from '../../src/api/client';

const responseSchema = z.object({ value: z.number() });

const setBaseUrl = (value: string | undefined): void => {
  vi.stubEnv('VITE_API_BASE_URL', value ?? '');
};

beforeEach(() => {
  setBaseUrl('https://api.test/');
});

afterEach(() => {
  vi.restoreAllMocks();
  vi.unstubAllEnvs();
});

describe('getApiBaseUrl', () => {
  it('strips trailing slashes', () => {
    setBaseUrl('https://api.test///');
    expect(getApiBaseUrl()).toBe('https://api.test');
  });

  it('returns null when env is empty', () => {
    setBaseUrl('');
    expect(getApiBaseUrl()).toBeNull();
  });
});

describe('requestJson', () => {
  it('returns parsed body for 2xx responses', async () => {
    globalThis.fetch = vi.fn(async () =>
      new Response(JSON.stringify({ value: 42 }), {
        status: 200,
        headers: { 'Content-Type': 'application/json' },
      }),
    );

    const result = await requestJson('/v1/example', responseSchema, { method: 'GET' });
    expect(result).toEqual({ value: 42 });
  });

  it('throws ApiError on non-2xx', async () => {
    globalThis.fetch = vi.fn(async () =>
      new Response(JSON.stringify({ code: 'BAD', message: 'no' }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' },
      }),
    );

    await expect(
      requestJson('/v1/example', responseSchema, { method: 'GET' }),
    ).rejects.toBeInstanceOf(ApiError);
  });

  it('throws ApiError when schema validation fails', async () => {
    globalThis.fetch = vi.fn(async () =>
      new Response(JSON.stringify({ value: 'not-a-number' }), {
        status: 200,
        headers: { 'Content-Type': 'application/json' },
      }),
    );

    await expect(
      requestJson('/v1/example', responseSchema, { method: 'GET' }),
    ).rejects.toBeInstanceOf(ApiError);
  });

  it('throws ApiConfigError when base URL is missing', async () => {
    setBaseUrl('');
    await expect(
      requestJson('/v1/example', responseSchema, { method: 'GET' }),
    ).rejects.toBeInstanceOf(ApiConfigError);
  });
});

describe('submitAttemptBestEffort', () => {
  const record = {
    id: '550e8400-e29b-41d4-a716-446655440000',
    sectionFilter: 'React',
    total: 1,
    correct: 1,
    startedAt: '2026-01-15T10:00:00.000Z',
    completedAt: '2026-01-15T10:30:00.000Z',
    answers: [{ quizId: 1, selectedIndex: 0, correct: true }],
  };

  it('swallows API failures so the UI can continue', async () => {
    globalThis.fetch = vi.fn(async () =>
      new Response(JSON.stringify({ code: 'bad_request', message: 'no' }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' },
      }),
    );

    await expect(submitAttemptBestEffort(record)).resolves.toBeUndefined();
  });
});
