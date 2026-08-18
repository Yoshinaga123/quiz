import { ApiConfigError, ApiError, getApiBaseUrl, requestJson, type RequestOptions } from './client';
import {
  answerHistoryCreateRequestSchema,
  answerHistoryEntrySchema,
  answerHistoryListResponseSchema,
  memberRegisterRequestSchema,
  memberRegisterResponseSchema,
  memberSessionRequestSchema,
  memberSessionResponseSchema,
  publicMemberSchema,
  type AnswerHistoryCreateRequest,
  type AnswerHistoryEntry,
  type AnswerHistoryListResponse,
  type MemberRegisterRequest,
  type MemberSessionResponse,
  type PublicMember,
} from '../schemas/member';

interface AuthOptions {
  token: string;
  signal?: AbortSignal | undefined;
}

const authHeaders = (token: string): Record<string, string> => ({
  Authorization: `Bearer ${token}`,
});

const withSignal = (signal?: AbortSignal): Pick<RequestOptions, 'signal'> =>
  signal !== undefined ? { signal } : {};

export const registerMember = async (
  payload: MemberRegisterRequest,
  signal?: AbortSignal,
): Promise<PublicMember> => {
  const validated = memberRegisterRequestSchema.parse(payload);
  return requestJson('/api/members', memberRegisterResponseSchema, {
    method: 'POST',
    body: validated,
    ...withSignal(signal),
  });
};

export const createMemberSession = async (
  handle: string,
  password: string,
  signal?: AbortSignal,
): Promise<MemberSessionResponse> => {
  const validated = memberSessionRequestSchema.parse({ handle, password });
  return requestJson('/api/session', memberSessionResponseSchema, {
    method: 'POST',
    body: validated,
    ...withSignal(signal),
  });
};

export const fetchMe = async (opts: AuthOptions): Promise<PublicMember> =>
  requestJson('/api/me', publicMemberSchema, {
    method: 'GET',
    headers: authHeaders(opts.token),
    ...withSignal(opts.signal),
  });

// DELETE /api/me returns 204 No Content; requestJson expects a JSON body, so we call fetch directly.
export const deleteMe = async (opts: AuthOptions): Promise<void> => {
  const base = getApiBaseUrl();
  if (base === null) {
    throw new ApiConfigError('VITE_API_BASE_URL is not configured.');
  }
  const init: RequestInit = {
    method: 'DELETE',
    headers: { ...authHeaders(opts.token), Accept: 'application/json' },
  };
  if (opts.signal !== undefined) {
    init.signal = opts.signal;
  }
  const response = await fetch(`${base}/api/me`, init);
  if (response.status === 204) return;
  const text = await response.text();
  throw new ApiError(
    `DELETE /api/me failed: ${response.status} ${response.statusText}`,
    response.status,
    text,
  );
};

export interface ListAnswerHistoryParams {
  quizId?: number | undefined;
  limit?: number | undefined;
}

export const listAnswerHistory = async (
  opts: AuthOptions,
  params: ListAnswerHistoryParams = {},
): Promise<AnswerHistoryListResponse> => {
  const search = new URLSearchParams();
  if (typeof params.quizId === 'number' && Number.isInteger(params.quizId) && params.quizId >= 1) {
    search.set('quizId', String(params.quizId));
  }
  if (
    typeof params.limit === 'number' &&
    Number.isInteger(params.limit) &&
    params.limit >= 1 &&
    params.limit <= 100
  ) {
    search.set('limit', String(params.limit));
  }
  const suffix = search.toString();
  const path = suffix === '' ? '/api/me/answers' : `/api/me/answers?${suffix}`;
  return requestJson(path, answerHistoryListResponseSchema, {
    method: 'GET',
    headers: authHeaders(opts.token),
    ...withSignal(opts.signal),
  });
};

export const createAnswerHistory = async (
  opts: AuthOptions,
  payload: AnswerHistoryCreateRequest,
): Promise<AnswerHistoryEntry> => {
  const validated = answerHistoryCreateRequestSchema.parse(payload);
  return requestJson('/api/me/answers', answerHistoryEntrySchema, {
    method: 'POST',
    body: validated,
    headers: authHeaders(opts.token),
    ...withSignal(opts.signal),
  });
};
