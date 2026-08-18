import { describe, expect, it } from 'vitest';

import {
  loginChallengeResponseSchema,
  loginRequestSchema,
  loginVerificationSchema,
} from '../../src/schemas/auth';

describe('loginRequestSchema', () => {
  it('accepts username and password', () => {
    expect(
      loginRequestSchema.safeParse({ username: 'admin', password: 'secret' }).success,
    ).toBe(true);
  });

  it('rejects blank fields', () => {
    expect(loginRequestSchema.safeParse({ username: '  ', password: 'secret' }).success).toBe(
      false,
    );
    expect(loginRequestSchema.safeParse({ username: 'admin', password: '' }).success).toBe(false);
  });
});

describe('loginVerificationSchema', () => {
  it('accepts a 6-digit code', () => {
    expect(
      loginVerificationSchema.safeParse({
        username: 'admin',
        password: 'secret',
        challengeId: 'chal-1',
        verificationCode: '123456',
      }).success,
    ).toBe(true);
  });

  it('rejects codes that are not 6 digits', () => {
    expect(
      loginVerificationSchema.safeParse({
        username: 'admin',
        password: 'secret',
        challengeId: 'chal-1',
        verificationCode: '12',
      }).success,
    ).toBe(false);
  });
});

describe('loginChallengeResponseSchema', () => {
  it('accepts a challenge without a verification code', () => {
    expect(
      loginChallengeResponseSchema.safeParse({
        message: 'confirm your ID',
        challengeId: 'chal-1',
      }).success,
    ).toBe(true);
  });

  it('accepts an optional development code', () => {
    expect(
      loginChallengeResponseSchema.safeParse({
        message: 'confirm your ID',
        challengeId: 'chal-1',
        code: '123456',
      }).success,
    ).toBe(true);
  });
});
