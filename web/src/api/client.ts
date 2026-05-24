import type { z } from 'zod';

/**
 * 公開 API 呼び出しの薄いクライアント。
 *
 * 設計方針（docs/implement-policy.md 準拠）:
 *  - 外部から取得するレスポンスは必ず Zod で実行時検証する
 *  - エラーは ApiError で正規化し、UI 側で type narrow しやすくする
 *  - `VITE_API_BASE_URL` が未設定の場合は明示的に例外を投げる
 *    （呼び出し側でフォールバック実装に切り替える判断ができるようにする）
 */

export class ApiError extends Error {
  readonly status: number;
  readonly body: unknown;

  constructor(message: string, status: number, body: unknown) {
    super(message);
    this.name = 'ApiError';
    this.status = status;
    this.body = body;
  }
}

export class ApiConfigError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'ApiConfigError';
  }
}

export interface RequestOptions extends Omit<RequestInit, 'body'> {
  body?: unknown;
  signal?: AbortSignal;
}

const trimSlash = (value: string): string => value.replace(/\/+$/u, '');

export const getApiBaseUrl = (): string | null => {
  const raw = import.meta.env.VITE_API_BASE_URL;
  if (typeof raw !== 'string' || raw.trim() === '') {
    return null;
  }
  return trimSlash(raw.trim());
};

const buildUrl = (path: string): string => {
  const base = getApiBaseUrl();
  if (base === null) {
    throw new ApiConfigError(
      'VITE_API_BASE_URL is not configured. Falling back to local starter quizzes.',
    );
  }
  const normalizedPath = path.startsWith('/') ? path : `/${path}`;
  return `${base}${normalizedPath}`;
};

const parseJsonSafe = async (response: Response): Promise<unknown> => {
  const text = await response.text();
  if (text.length === 0) {
    return null;
  }
  try {
    return JSON.parse(text);
  } catch {
    throw new ApiError(
      `Failed to parse JSON response (${response.status})`,
      response.status,
      text,
    );
  }
};

export const requestJson = async <T>(
  path: string,
  schema: z.ZodType<T>,
  options: RequestOptions = {},
): Promise<T> => {
  const { body, headers, ...rest } = options;
  const init: RequestInit = {
    ...rest,
    headers: {
      Accept: 'application/json',
      ...(body !== undefined ? { 'Content-Type': 'application/json' } : {}),
      ...(headers ?? {}),
    },
    body: body !== undefined ? JSON.stringify(body) : undefined,
  };

  const response = await fetch(buildUrl(path), init);
  const payload = await parseJsonSafe(response);

  if (!response.ok) {
    throw new ApiError(
      `API request failed: ${response.status} ${response.statusText}`,
      response.status,
      payload,
    );
  }

  const result = schema.safeParse(payload);
  if (!result.success) {
    throw new ApiError(
      `API response validation failed: ${result.error.message}`,
      response.status,
      payload,
    );
  }
  return result.data;
};
