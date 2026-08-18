import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';

import {
  createMemberSession,
  deleteMe,
  fetchMe,
  listAnswerHistory,
  registerMember,
} from '../../src/api/member';

const TOKEN = 'test.jwt.token';

const setBaseUrl = (value: string | undefined): void => {
  vi.stubEnv('VITE_API_BASE_URL', value ?? '');
};

const jsonResponse = (status: number, body: unknown): Response =>
  new Response(JSON.stringify(body), {
    status,
    headers: { 'Content-Type': 'application/json' },
  });

beforeEach(() => {
  setBaseUrl('https://api.test');
});

afterEach(() => {
  vi.restoreAllMocks();
  vi.unstubAllEnvs();
});

describe('registerMember', () => {
  it('POSTs handle + password and parses the response', async () => {
    const fetchMock = vi.fn(async () =>
      jsonResponse(201, {
        id: '0192b6f7-4c50-73b1-8b71-11223344aabb',
        handle: 'quiztaker_01',
      }),
    );
    globalThis.fetch = fetchMock;

    const result = await registerMember({ handle: 'quiztaker_01', password: 'correcthorse' });
    expect(result.handle).toBe('quiztaker_01');

    const [url, init] = fetchMock.mock.calls[0] as [string, RequestInit];
    expect(url).toBe('https://api.test/api/members');
    expect(init.method).toBe('POST');
    expect(JSON.parse(init.body as string)).toEqual({ handle: 'quiztaker_01', password: 'correcthorse' });
  });

  it('rejects short passwords at the client boundary', async () => {
    await expect(
      registerMember({ handle: 'quiztaker_01', password: 'short' }),
    ).rejects.toThrow();
  });
});

describe('createMemberSession + fetchMe', () => {
  it('POSTs /api/session and then GETs /api/me with the bearer', async () => {
    const fetchMock = vi
      .fn()
      .mockResolvedValueOnce(jsonResponse(200, { token: TOKEN }))
      .mockResolvedValueOnce(
        jsonResponse(200, {
          id: '0192b6f7-4c50-73b1-8b71-11223344aabb',
          handle: 'quiztaker_01',
        }),
      );
    globalThis.fetch = fetchMock;

    const login = await createMemberSession('quiztaker_01', 'correcthorse');
    expect(login.token).toBe(TOKEN);

    const me = await fetchMe({ token: login.token });
    expect(me.handle).toBe('quiztaker_01');

    const [, meInit] = fetchMock.mock.calls[1] as [string, RequestInit];
    const headers = new Headers(meInit.headers);
    expect(headers.get('Authorization')).toBe(`Bearer ${TOKEN}`);
  });
});

describe('deleteMe', () => {
  it('sends DELETE with bearer and resolves on 204', async () => {
    const fetchMock = vi.fn(async () => new Response(null, { status: 204 }));
    globalThis.fetch = fetchMock;

    await expect(deleteMe({ token: TOKEN })).resolves.toBeUndefined();
    const [url, init] = fetchMock.mock.calls[0] as [string, RequestInit];
    expect(url).toBe('https://api.test/api/me');
    expect(init.method).toBe('DELETE');
  });

  it('throws on non-204 responses', async () => {
    globalThis.fetch = vi.fn(async () =>
      jsonResponse(401, { code: 'unauthorized', message: 'no' }),
    );
    await expect(deleteMe({ token: TOKEN })).rejects.toThrow();
  });
});

describe('listAnswerHistory', () => {
  it('builds the querystring for quizId + limit', async () => {
    const fetchMock = vi.fn(async () => jsonResponse(200, { items: [] }));
    globalThis.fetch = fetchMock;

    await listAnswerHistory({ token: TOKEN }, { quizId: 42, limit: 5 });
    const [url] = fetchMock.mock.calls[0] as [string, RequestInit];
    expect(url).toBe('https://api.test/api/me/answers?quizId=42&limit=5');
  });

  it('omits the querystring when no params are given', async () => {
    const fetchMock = vi.fn(async () => jsonResponse(200, { items: [] }));
    globalThis.fetch = fetchMock;

    await listAnswerHistory({ token: TOKEN });
    const [url] = fetchMock.mock.calls[0] as [string, RequestInit];
    expect(url).toBe('https://api.test/api/me/answers');
  });
});
