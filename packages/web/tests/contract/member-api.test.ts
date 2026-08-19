import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

import { describe, expect, it } from 'vitest';

import {
  answerHistoryCreateRequestSchema,
  answerHistoryListResponseSchema,
  masteryResponseSchema,
  publicMemberSchema,
} from '../../src/schemas/member';

const fixturesDir = path.resolve(
  path.dirname(fileURLToPath(import.meta.url)),
  '../../../../docs/api/fixtures',
);

const readFixture = (name: string): unknown =>
  JSON.parse(fs.readFileSync(path.join(fixturesDir, name), 'utf8')) as unknown;

describe('member API fixtures (ADR 0016)', () => {
  it('parses member-self.json with publicMemberSchema', () => {
    const result = publicMemberSchema.safeParse(readFixture('member-self.json'));
    expect(result.success).toBe(true);
  });

  it('rejects publicMember with password_hash (ADR 0016 §6)', () => {
    const forbidden = { ...(readFixture('member-self.json') as object), password_hash: 'bcrypt$...' };
    const result = publicMemberSchema.safeParse(forbidden);
    expect(result.success).toBe(false);
  });

  it('rejects publicMember with createdAt (ADR 0016 §6)', () => {
    const forbidden = { ...(readFixture('member-self.json') as object), createdAt: '2026-08-18T00:00:00.000Z' };
    const result = publicMemberSchema.safeParse(forbidden);
    expect(result.success).toBe(false);
  });

  it('rejects publicMember with raw email (ADR 0018 §6)', () => {
    const forbidden = { ...(readFixture('member-self.json') as object), email: 'user@example.com' };
    const result = publicMemberSchema.safeParse(forbidden);
    expect(result.success).toBe(false);
  });

  it('exposes hasVerifiedEmail boolean (ADR 0018 §6)', () => {
    const result = publicMemberSchema.safeParse(readFixture('member-self.json'));
    expect(result.success).toBe(true);
    if (result.success) {
      expect(result.data.hasVerifiedEmail).toBe(false);
    }
  });

  it('parses answer-history-create.json with answerHistoryCreateRequestSchema', () => {
    const result = answerHistoryCreateRequestSchema.safeParse(readFixture('answer-history-create.json'));
    expect(result.success).toBe(true);
  });

  it('parses answer-history-list.json with answerHistoryListResponseSchema', () => {
    const result = answerHistoryListResponseSchema.safeParse(readFixture('answer-history-list.json'));
    expect(result.success).toBe(true);
  });

  it('rejects answer-history-invalid-selected-index.json', () => {
    const result = answerHistoryCreateRequestSchema.safeParse(
      readFixture('answer-history-invalid-selected-index.json'),
    );
    expect(result.success).toBe(false);
    if (!result.success) {
      expect(result.error.issues[0]?.path).toContain('selectedIndex');
    }
  });

  it('parses mastery-empty.json with masteryResponseSchema', () => {
    const result = masteryResponseSchema.safeParse(readFixture('mastery-empty.json'));
    expect(result.success).toBe(true);
    if (result.success) {
      expect(result.data.items).toEqual([]);
      expect(result.data.rank.rank).toBe('4級');
    }
  });

  it('parses mastery-list.json with masteryResponseSchema', () => {
    const result = masteryResponseSchema.safeParse(readFixture('mastery-list.json'));
    expect(result.success).toBe(true);
    if (result.success) {
      expect(result.data.items).toHaveLength(3);
      expect(result.data.streakCap).toBe(2);
      expect(result.data.rank.rank).toBe('初段');
    }
  });

  it('rejects mastery-invalid-streak-over-cap.json (ADR 0016 §4 streakCap = 2)', () => {
    const result = masteryResponseSchema.safeParse(
      readFixture('mastery-invalid-streak-over-cap.json'),
    );
    expect(result.success).toBe(false);
    if (!result.success) {
      expect(result.error.issues[0]?.path).toContain('streak');
    }
  });
});
