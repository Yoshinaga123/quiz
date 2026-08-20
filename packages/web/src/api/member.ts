import { ApiConfigError, ApiError, getApiBaseUrl, requestJson, type RequestOptions } from './client';
import {
  answerHistoryCreateRequestSchema,
  answerHistoryEntrySchema,
  answerHistoryListResponseSchema,
  masteryResponseSchema,
  memberRegisterRequestSchema,
  memberRegisterResponseSchema,
  memberSessionRequestSchema,
  memberSessionResponseSchema,
  passwordResetConsumeRequestSchema,
  passwordResetRequestSchema,
  publicMemberSchema,
  setMemberEmailRequestSchema,
  type AnswerHistoryCreateRequest,
  type AnswerHistoryEntry,
  type AnswerHistoryListResponse,
  type MasteryResponse,
  type MemberRegisterRequest,
  type MemberRegisterResponse,
  type MemberSessionResponse,
  type PasswordResetConsumeRequest,
  type PasswordResetRequest,
  type PublicMember,
  type SetMemberEmailRequest,
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
): Promise<MemberRegisterResponse> => {
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

export const fetchMastery = async (opts: AuthOptions): Promise<MasteryResponse> =>
  requestJson('/api/me/mastery', masteryResponseSchema, {
    method: 'GET',
    headers: authHeaders(opts.token),
    ...withSignal(opts.signal),
  });

// Fire-and-forget wrapper for the play flow; swallows errors so a network hiccup does not disrupt the quiz UI. Local history remains the primary record.
export const createAnswerHistoryBestEffort = async (
  token: string,
  payload: AnswerHistoryCreateRequest,
): Promise<void> => {
  try {
    await createAnswerHistory({ token }, payload);
  } catch {
    // Intentionally ignored: server-side history is a secondary source.
  }
};

// ADR 0018 §3 系エンドポイントは 202/204 を返し JSON body を持たない。 requestJson は JSON パースを要求するため、ここでは fetch を直接叩く。
async function fetchNoContent(
  path: string,
  init: RequestInit,
  acceptStatuses: readonly number[],
  errorLabel: string,
): Promise<void> {
  const base = getApiBaseUrl();
  if (base === null) {
    throw new ApiConfigError('VITE_API_BASE_URL is not configured.');
  }
  const response = await fetch(`${base}${path}`, {
    ...init,
    headers: {
      Accept: 'application/json',
      ...(init.body !== undefined ? { 'Content-Type': 'application/json' } : {}),
      ...(init.headers ?? {}),
    },
  });
  if (acceptStatuses.includes(response.status)) return;
  const text = await response.text();
  throw new ApiError(
    `${errorLabel} failed: ${response.status} ${response.statusText}`,
    response.status,
    text,
  );
}

export const setMemberEmail = async (
  opts: AuthOptions,
  payload: SetMemberEmailRequest,
): Promise<void> => {
  const validated = setMemberEmailRequestSchema.parse(payload);
  const init: RequestInit = {
    method: 'POST',
    headers: authHeaders(opts.token),
    body: JSON.stringify(validated),
  };
  if (opts.signal !== undefined) {
    init.signal = opts.signal;
  }
  await fetchNoContent('/api/me/email', init, [202], 'POST /api/me/email');
};

export const consumeEmailVerification = async (
  token: string,
  signal?: AbortSignal,
): Promise<void> => {
  if (token === '') {
    throw new ApiError('Verification token is empty', 400, null);
  }
  const init: RequestInit = { method: 'POST' };
  if (signal !== undefined) init.signal = signal;
  await fetchNoContent(
    `/api/email-verifications/${encodeURIComponent(token)}`,
    init,
    [204],
    'POST /api/email-verifications/{token}',
  );
};

// ADR 0018 §3: 常に 202 を返すため、成否を UI に伝えない (列挙対策)。
export const requestPasswordReset = async (
  payload: PasswordResetRequest,
  signal?: AbortSignal,
): Promise<void> => {
  const validated = passwordResetRequestSchema.parse(payload);
  const init: RequestInit = {
    method: 'POST',
    body: JSON.stringify(validated),
  };
  if (signal !== undefined) init.signal = signal;
  await fetchNoContent('/api/password-resets', init, [202], 'POST /api/password-resets');
};

export const consumePasswordReset = async (
  token: string,
  payload: PasswordResetConsumeRequest,
  signal?: AbortSignal,
): Promise<void> => {
  if (token === '') {
    throw new ApiError('Reset token is empty', 400, null);
  }
  const validated = passwordResetConsumeRequestSchema.parse(payload);
  const init: RequestInit = {
    method: 'POST',
    body: JSON.stringify(validated),
  };
  if (signal !== undefined) init.signal = signal;
  await fetchNoContent(
    `/api/password-resets/${encodeURIComponent(token)}`,
    init,
    [204],
    'POST /api/password-resets/{token}',
  );
};
