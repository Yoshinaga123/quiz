import { z } from 'zod'

export const loginRequestSchema = z.object({
  username: z.string().trim().min(1, 'ユーザー名は必須です'),
  password: z.string().trim().min(1, 'パスワードは必須です'),
})

export const loginVerificationSchema = loginRequestSchema.extend({
  challengeId: z.string().trim().min(1, '確認コードを送信してください'),
  verificationCode: z
    .string()
    .trim()
    .min(6, '確認コードを入力してください')
    .max(6, '確認コードは6桁です'),
})

export const loginResponseSchema = z.object({
  token: z.string().min(1),
})

export const loginChallengeResponseSchema = z.object({
  message: z.string().min(1),
  challengeId: z.string().min(1),
  code: z.string().optional(),
})
