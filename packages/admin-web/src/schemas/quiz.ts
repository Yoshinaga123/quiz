import { z } from 'zod'

function hasValidCorrectAnswerIndex(correctAnswerIndex: number, optionCount: number): boolean {
  return correctAnswerIndex >= 0 && correctAnswerIndex < optionCount
}

export const quizSchema = z
  .object({
    id: z.number().int().positive(),
    section: z.string().min(1),
    title: z.string().min(1),
    question: z.string().min(1),
    code: z.string().optional(),
    options: z.array(z.string().min(1)).min(2),
    correctAnswerIndex: z.number().int().nonnegative(),
    explanation: z.string().min(1),
    source: z.string().min(1),
    status: z.enum(['published', 'unpublished']),
    pushEnabled: z.boolean(),
    createdAt: z.string().min(1),
    updatedAt: z.string().min(1),
  })
  .refine(
    ({ correctAnswerIndex, options }) => hasValidCorrectAnswerIndex(correctAnswerIndex, options.length),
    {
      path: ['correctAnswerIndex'],
      message: 'correctAnswerIndex is out of range',
    },
  )

export const quizzesSchema = z.array(quizSchema)

export const quizListResponseSchema = z.object({
  items: quizzesSchema,
  total: z.number().int().nonnegative(),
  page: z.number().int().positive(),
  perPage: z.number().int().positive(),
  totalPages: z.number().int().nonnegative(),
})

export const productionQuizSyncResponseSchema = z.object({
  seededCount: z.number().int().nonnegative(),
  deletedCount: z.number().int().nonnegative(),
  source: z.string().min(1),
  migrationVersion: z.number().int().positive(),
  upPath: z.string().min(1),
  downPath: z.string().min(1),
})

export const quizPayloadSchema = z
  .object({
    section: z.string().trim().min(1, 'セクションは必須です'),
    title: z.string().trim().min(1, 'タイトルは必須です'),
    question: z.string().trim().min(1, '問題文は必須です'),
    code: z.string().trim(),
    options: z.array(z.string().trim().min(1, '選択肢は空にできません')).min(2, '選択肢は2件以上必要です'),
    correctAnswerIndex: z.number().int().nonnegative(),
    explanation: z.string().trim().min(1, '解説は必須です'),
    source: z.string().trim().min(1, '出典は必須です'),
    status: z.enum(['published', 'unpublished']),
    pushEnabled: z.boolean(),
  })
  .refine(
    ({ correctAnswerIndex, options }) => hasValidCorrectAnswerIndex(correctAnswerIndex, options.length),
    {
      path: ['correctAnswerIndex'],
      message: '正解の選択肢を指定してください',
    },
  )
