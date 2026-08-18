import { afterEach, beforeEach, describe, expect, it } from 'vitest';

import {
  clearMemberSession,
  loadMemberSession,
  saveMemberSession,
  type MemberSession,
} from '../../src/lib/memberSession';

const STORAGE_KEY = 'quzzes:member-session:v1';

const validSession: MemberSession = {
  token: 'jwt-token',
  memberId: '0192b6f7-4c50-73b1-8b71-11223344aabb',
  handle: 'quiztaker_01',
};

beforeEach(() => {
  window.localStorage.clear();
});

afterEach(() => {
  window.localStorage.clear();
});

describe('memberSession storage', () => {
  it('returns null when nothing is stored', () => {
    expect(loadMemberSession()).toBeNull();
  });

  it('roundtrips a valid session', () => {
    saveMemberSession(validSession);
    expect(loadMemberSession()).toEqual(validSession);
  });

  it('clears the stored session', () => {
    saveMemberSession(validSession);
    clearMemberSession();
    expect(loadMemberSession()).toBeNull();
  });

  it('returns null when the stored JSON is malformed', () => {
    window.localStorage.setItem(STORAGE_KEY, '{not-json');
    expect(loadMemberSession()).toBeNull();
  });

  it('returns null when a required field is missing', () => {
    window.localStorage.setItem(
      STORAGE_KEY,
      JSON.stringify({ token: 'x', memberId: '' }),
    );
    expect(loadMemberSession()).toBeNull();
  });
});
