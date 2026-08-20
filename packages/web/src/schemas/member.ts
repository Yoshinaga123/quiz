import { z } from 'zod';

// ADR 0016 §3 と OpenAPI docs/api/member-api.yaml と一対一で対応させる。 shape を変えたら YAML・fixtures・packages/backend/me.go・テストを同じ PR で直す。

const memberHandleSchema = z
  .string()
  .min(3)
  .max(32)
  .regex(/^[a-zA-Z0-9_]+$/);

export const memberRegisterRequestSchema = z.object({
  handle: memberHandleSchema,
  password: z.string().min(8).max(128),
});

export const memberRegisterResponseSchema = z.object({
  id: z.string().uuid(),
  handle: memberHandleSchema,
});

export const memberSessionRequestSchema = z.object({
  handle: z.string().min(1),
  password: z.string().min(1),
});

export const memberSessionResponseSchema = z.object({
  token: z.string().min(1),
});

// publicMember は id と handle と hasVerifiedEmail のみ。ADR 0016 §6 と ADR 0018 §6 の禁止フィールドは strict() で弾く。
export const publicMemberSchema = z
  .object({
    id: z.string().uuid(),
    handle: memberHandleSchema,
    hasVerifiedEmail: z.boolean(),
  })
  .strict();

export const answerHistoryCreateRequestSchema = z.object({
  quizId: z.number().int().positive(),
  selectedIndex: z.number().int().nonnegative(),
});

export const answerHistoryEntrySchema = z.object({
  id: z.number().int().positive(),
  quizId: z.number().int().positive(),
  selectedIndex: z.number().int().nonnegative(),
  isCorrect: z.boolean(),
  answeredAt: z.string().datetime({ offset: true }),
});

export const answerHistoryListResponseSchema = z.object({
  items: z.array(answerHistoryEntrySchema),
});

// ADR 0018 §3: メール登録・検証・パスワードリセット系。 email は RFC 5322 準拠 + 254 文字上限 + 保存時に小文字化（サーバー側で正規化）。
export const setMemberEmailRequestSchema = z.object({
  email: z.string().email().max(254),
});

export const passwordResetRequestSchema = z.object({
  handleOrEmail: z.string().min(1).max(320),
});

export const passwordResetConsumeRequestSchema = z.object({
  newPassword: z.string().min(8).max(128),
});

// ADR 0018 系の派生: 段位計算用に answer_history からサーバー側で導出した streak。
export const masteryEntrySchema = z.object({
  quizId: z.number().int().positive(),
  streak: z.number().int().min(0).max(2),
});

export const masteryRankSchema = z.object({
  rank: z.string().min(1),
  index: z.number().int().min(0),
  mastery: z.number().int().min(0),
  totalPossible: z.number().int().min(0),
  progress: z.number().min(0).max(1),
  nextRank: z.string().min(1).nullable(),
  toNextRank: z.number().int().min(0),
});

export const masteryResponseSchema = z.object({
  items: z.array(masteryEntrySchema),
  streakCap: z.number().int().min(1),
  rank: masteryRankSchema,
});

export type PublicMember = z.infer<typeof publicMemberSchema>;
export type AnswerHistoryEntry = z.infer<typeof answerHistoryEntrySchema>;
export type AnswerHistoryListResponse = z.infer<typeof answerHistoryListResponseSchema>;
export type AnswerHistoryCreateRequest = z.infer<typeof answerHistoryCreateRequestSchema>;
export type MemberRegisterRequest = z.infer<typeof memberRegisterRequestSchema>;
export type MemberRegisterResponse = z.infer<typeof memberRegisterResponseSchema>;
export type MemberSessionResponse = z.infer<typeof memberSessionResponseSchema>;
export type SetMemberEmailRequest = z.infer<typeof setMemberEmailRequestSchema>;
export type PasswordResetRequest = z.infer<typeof passwordResetRequestSchema>;
export type PasswordResetConsumeRequest = z.infer<typeof passwordResetConsumeRequestSchema>;
export type MasteryEntry = z.infer<typeof masteryEntrySchema>;
export type MasteryRank = z.infer<typeof masteryRankSchema>;
export type MasteryResponse = z.infer<typeof masteryResponseSchema>;
