import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { z } from 'zod';

import { ApiConfigError, ApiError, getApiBaseUrl, requestJson } from '../../src/api/client';

const responseSchema = z.object({ value: z.number() });

declare global {
  // ensure fetch can be assigned in test environment
  // eslint-disable-next-line no-var
  var fetch: typeof globalThis.fetch;
}

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
