import { z } from 'zod'
// Zod は TypeScript/JavaScript でデータ構造（スキーマ）を定義し、実行時のデータ検証を行うライブラリ
// 型定義をSingle Source of Truthとして管理できる。 

function hasValidCorrectAnswerIndex(correctAnswerIndex: number, optionCount: number): boolean {
  return correctAnswerIndex >= 0 && correctAnswerIndex < optionCount
}
// 正解番号が選択肢の範囲内か見ます。
// JSONの各問では選択肢は固定だが、問によって個数が違うので、関数は個数を外から受け取る設計にしている

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
  // クイズ一件の各項目の型定義
  .refine(
    ({ correctAnswerIndex, options }) => hasValidCorrectAnswerIndex(correctAnswerIndex, options.length),
    {
      path: ['correctAnswerIndex'],
      message: 'correctAnswerIndex is out of range',
    },
  )
  // correctAnswerIndex のout of rangeエラーを報告する

  export const quizzesSchema = z.array(quizSchema)
  // クイズ配列用の Zod スキーマ（実行時検証）
  
  export type QuizParseSuccess = z.infer<typeof quizSchema>
  // quizSchema 検証成功時の1件分の型
