import { z } from 'zod'

export const quizAnswerSchema = z.object({
  quizId: z.number().int().positive(),
  selectedIndex: z.number().int().nonnegative(),
  correct: z.boolean(),
})

export const historyRecordSchema = z.object({
  id: z.string().min(1),
  sectionFilter: z.string().min(1).nullable(),
  total: z.number().int().positive(),
  correct: z.number().int().nonnegative(),
  startedAt: z.string().min(1),
  completedAt: z.string().min(1),
  answers: z.array(quizAnswerSchema),
})

export const historyRecordsSchema = z.array(historyRecordSchema)
