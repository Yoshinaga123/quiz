import { z } from 'zod';

// ADR 0016 §3 と OpenAPI docs/api/member-api.yaml と一対一で対応させる。
// shape を変えたら YAML・fixtures・packages/backend/me.go・テストを同じ PR で直す。

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

// publicMember は id と handle と hasVerifiedEmail のみ。ADR 0016 §6 と
// ADR 0018 §6 の禁止フィールドは strict() で弾く。
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

export type PublicMember = z.infer<typeof publicMemberSchema>;
export type AnswerHistoryEntry = z.infer<typeof answerHistoryEntrySchema>;
export type AnswerHistoryListResponse = z.infer<typeof answerHistoryListResponseSchema>;
export type AnswerHistoryCreateRequest = z.infer<typeof answerHistoryCreateRequestSchema>;
export type MemberRegisterRequest = z.infer<typeof memberRegisterRequestSchema>;
export type MemberRegisterResponse = z.infer<typeof memberRegisterResponseSchema>;
export type MemberSessionResponse = z.infer<typeof memberSessionResponseSchema>;
