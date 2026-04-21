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
  })
  .refine(
    ({ correctAnswerIndex, options }) => hasValidCorrectAnswerIndex(correctAnswerIndex, options.length),
    {
      path: ['correctAnswerIndex'],
      message: 'correctAnswerIndex is out of range',
    },
  )

export const quizzesSchema = z.array(quizSchema)

export type QuizParseSuccess = z.infer<typeof quizSchema>
