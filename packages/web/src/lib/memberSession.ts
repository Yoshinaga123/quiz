const STORAGE_KEY = 'quzzes:member-session:v1';

export interface MemberSession {
  token: string;
  memberId: string;
  handle: string;
}

const isMemberSession = (value: unknown): value is MemberSession => {
  if (typeof value !== 'object' || value === null) return false;
  const record = value as Record<string, unknown>;
  return (
    typeof record.token === 'string' &&
    record.token !== '' &&
    typeof record.memberId === 'string' &&
    record.memberId !== '' &&
    typeof record.handle === 'string' &&
    record.handle !== ''
  );
};

export const loadMemberSession = (): MemberSession | null => {
  if (typeof window === 'undefined') return null;
  try {
    const raw = window.localStorage.getItem(STORAGE_KEY);
    if (raw === null || raw === '') return null;
    const parsed: unknown = JSON.parse(raw);
    return isMemberSession(parsed) ? parsed : null;
  } catch {
    return null;
  }
};

export const saveMemberSession = (session: MemberSession): void => {
  if (typeof window === 'undefined') return;
  try {
    window.localStorage.setItem(STORAGE_KEY, JSON.stringify(session));
  } catch {
    // localStorage may be disabled (Safari private, quota); UI stays logged-in until reload.
  }
};

export const clearMemberSession = (): void => {
  if (typeof window === 'undefined') return;
  try {
    window.localStorage.removeItem(STORAGE_KEY);
  } catch {
    // Nothing to do if we cannot clear; caller has already cleared in-memory state.
  }
};
