/**
 * クイズアプリ用 ユーティリティ関数
 * 純粋関数のみ定義する。
 */

import type { Quiz, QuizzesData, QuizWithAnswer } from '../../types/quiz'
import quizzesData from '../../data/quizzes.json'

/**
 * すべてのクイズを取得
 */
export function getAllQuizzes(): Quiz[] {
  return (quizzesData as QuizzesData).quizzes
}

/**
 * ID でクイズを取得
 */
export function getQuizById(id: number): Quiz | undefined {
  return getAllQuizzes().find((quiz) => quiz.id === id)
}

/**
 * セクション別にクイズをグループ化
 */
export function groupQuizzesBySection(): Map<string, Quiz[]> {
  const grouped = new Map<string, Quiz[]>()
  getAllQuizzes().forEach((quiz) => {
    const existing = grouped.get(quiz.section) ?? []
    existing.push(quiz)
    grouped.set(quiz.section, existing)
  })
  return grouped
}

/**
 * ランダムにクイズを取得
 */
export function getRandomQuizzes(count?: number): Quiz[] {
  const allQuizzes = getAllQuizzes()
  const shuffled = [...allQuizzes].sort(() => Math.random() - 0.5)
  const quizCount = count ?? allQuizzes.length
  return shuffled.slice(0, Math.min(quizCount, allQuizzes.length))
}

/**
 * クイズの正解が正しいかチェック
 */
export function isAnswerCorrect(quiz: Quiz, userAnswerIndex: number): boolean {
  return quiz.correctAnswerIndex === userAnswerIndex
}

/**
 * クイズの選択肢とユーザー回答を合わせた型を生成
 */
export function enrichQuizWithAnswer(
  quiz: Quiz,
  userAnswer?: number | null
): QuizWithAnswer {
  return {
    ...quiz,
    userAnswer,
    isCorrect: userAnswer !== null && userAnswer !== undefined
      ? isAnswerCorrect(quiz, userAnswer)
      : undefined,
  }
}

/**
 * セクション別の統計を計算
 */
export function calculateSectionStatistics(
  answeredQuizzes: Map<number, number>
) {
  const sections = new Map<string, { correct: number; total: number }>()

  answeredQuizzes.forEach((answerIndex, quizId) => {
    const quiz = getQuizById(quizId)
    if (!quiz) return

    if (!sections.has(quiz.section)) {
      sections.set(quiz.section, { correct: 0, total: 0 })
    }

    const stats = sections.get(quiz.section)
    if (!stats) return
    stats.total++
    if (isAnswerCorrect(quiz, answerIndex)) {
      stats.correct++
    }
  })

  return sections
}

/**
 * スコア（正解率）を計算
 */
export function calculateScore(
  answeredQuizzes: Map<number, number>,
  totalQuizzes: number
): number {
  if (totalQuizzes === 0) return 0
  let correctCount = 0

  answeredQuizzes.forEach((answerIndex, quizId) => {
    const quiz = getQuizById(quizId)
    if (quiz && isAnswerCorrect(quiz, answerIndex)) {
      correctCount++
    }
  })

  return Math.round((correctCount / totalQuizzes) * 100)
}
