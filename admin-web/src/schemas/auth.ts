import { z } from 'zod'

export const loginRequestSchema = z.object({
  username: z.string().trim().min(1, 'ユーザー名は必須です'),
  password: z.string().trim().min(1, 'パスワードは必須です'),
})

export const loginResponseSchema = z.object({
  token: z.string().min(1),
})
