import { useState } from 'react'
import type { Quiz } from '../types/quiz'
import { resolveSourceLinks } from '../utils/sourceLinks'
import {
  calculateScore,
  getAllQuizzes,
  getRandomQuizzes,
  groupQuizzesBySection,
  isAnswerCorrect,
} from '../utils/quizUtils'

const allQuizzes = getAllQuizzes()
const sectionCount = groupQuizzesBySection().size
const quizCountPerSession = allQuizzes.length

const pillButtonClassName =
  'inline-flex items-center justify-center rounded-full px-[18px] py-3 text-sm font-medium transition duration-150 hover:-translate-y-0.5 hover:shadow-float'

function JsonQuizPreviewSection() {
  const [activeQuizzes, setActiveQuizzes] = useState<Quiz[]>([])
  const [currentQuizIndex, setCurrentQuizIndex] = useState(0)
  const [selectedAnswerIndex, setSelectedAnswerIndex] = useState<number | null>(null)
  const [answeredQuizzes, setAnsweredQuizzes] = useState<Map<number, number>>(new Map())
  const [isQuizStarted, setIsQuizStarted] = useState(false)
  const [isQuizFinished, setIsQuizFinished] = useState(false)

  const currentQuiz = activeQuizzes[currentQuizIndex]
  const score = calculateScore(answeredQuizzes, activeQuizzes.length)
  const sourceLinks = currentQuiz ? resolveSourceLinks(currentQuiz.source) : []
  const correctAnswers = activeQuizzes.filter((quiz) => {
    const answer = answeredQuizzes.get(quiz.id)
    return answer !== undefined && isAnswerCorrect(quiz, answer)
  }).length

  const startQuiz = () => {
    setActiveQuizzes(getRandomQuizzes(quizCountPerSession))
    setCurrentQuizIndex(0)
    setSelectedAnswerIndex(null)
    setAnsweredQuizzes(new Map())
    setIsQuizStarted(true)
    setIsQuizFinished(false)
  }

  const handleAnswerSelect = (answerIndex: number) => {
    if (!currentQuiz || selectedAnswerIndex !== null) {
      return
    }

    setSelectedAnswerIndex(answerIndex)
    setAnsweredQuizzes((current) => {
      const next = new Map(current)
      next.set(currentQuiz.id, answerIndex)
      return next
    })
  }

  const handleNextQuiz = () => {
    if (currentQuizIndex >= activeQuizzes.length - 1) {
      setIsQuizFinished(true)
      return
    }

    setCurrentQuizIndex((current) => current + 1)
    setSelectedAnswerIndex(null)
  }

  return (
    <section className="mt-7 rounded-card border border-navy/12 bg-white/72 p-card shadow-card">
      <header className="mb-panel flex flex-col gap-stack xl:flex-row xl:items-start xl:justify-between">
        <div>
          <p className="m-0 mb-2.5 text-[0.78rem] uppercase tracking-[0.18em] text-[#8b5e00]">Local JSON Preview</p>
          <h2 className="m-0 text-[clamp(1.6rem,2.8vw,2.2rem)] font-semibold">`quizzes.json` ローカル出題プレビュー</h2>
          <p className="mt-3 mb-0 max-w-[760px] text-[#4f5d75]">
            `src/data/quizzes.json` を `quizUtils.ts` から直接読み込む、旧デモ相当のローカル出題です。DB や
            管理 API を通さず、フロントだけで確認できます。
          </p>
        </div>
        <div className="flex flex-wrap gap-2.5">
          <span className="inline-flex items-center rounded-full bg-[#f9c952]/18 px-3.5 py-2.5 font-semibold text-[#7a5a00]">
            {allQuizzes.length}問
          </span>
          <span className="inline-flex items-center rounded-full bg-[#f9c952]/18 px-3.5 py-2.5 font-semibold text-[#7a5a00]">
            {sectionCount}セクション
          </span>
        </div>
      </header>

      {!isQuizStarted ? (
        <div className="grid justify-items-start gap-4 rounded-surface border border-dashed border-navy/16 bg-white/70 p-panel">
          <p className="m-0 text-[#4f5d75]">
            ローカル JSON の全 {quizCountPerSession} 問をランダム順で出題します。管理画面の CRUD とは独立した確認用プレビューです。
          </p>
          <button
            className={`${pillButtonClassName} bg-linear-to-br from-[#b88200] to-[#8b5e00] text-white disabled:cursor-not-allowed disabled:opacity-55 disabled:hover:translate-y-0 disabled:hover:shadow-none`}
            disabled={quizCountPerSession === 0}
            onClick={startQuiz}
            type="button"
          >
            クイズを始める
          </button>
        </div>
      ) : null}

      {isQuizStarted && !isQuizFinished && currentQuiz ? (
        <div className="grid gap-stack">
          <p className="m-0 text-[0.92rem] text-[#4f5d75]">
            問題 {currentQuizIndex + 1} / {activeQuizzes.length}
          </p>
          <h3 className="m-0 text-[1.4rem] font-semibold">{currentQuiz.title}</h3>
          <p className="m-0 text-[#4f5d75]">{currentQuiz.question}</p>

          {currentQuiz.code ? (
            <pre className="m-0 overflow-x-auto rounded-surface bg-navy p-stack font-mono text-sm text-[#f8fafc]">
              <code>{currentQuiz.code}</code>
            </pre>
          ) : null}

          {sourceLinks.length > 0 ? (
            <div className="grid gap-2.5 rounded-surface border border-navy/10 bg-white/80 p-4">
              <p className="m-0 font-semibold text-navy">出典リンク</p>
              <div className="flex flex-wrap gap-2.5">
                {sourceLinks.map((link) => (
                  <a
                    className="inline-flex max-w-full items-center rounded-full bg-[#1768ac]/10 px-3.5 py-2.5 text-[#0f4c81] underline underline-offset-2 [overflow-wrap:anywhere]"
                    href={link.href}
                    key={`${currentQuiz.id}-${link.href}`}
                    rel="noreferrer"
                    target="_blank"
                  >
                    {link.label}
                  </a>
                ))}
              </div>
            </div>
          ) : null}

          <div className="grid gap-3">
            {currentQuiz.options.map((option, index) => {
              const isSelected = selectedAnswerIndex === index
              const isCorrectOption =
                selectedAnswerIndex !== null && index === currentQuiz.correctAnswerIndex

              const optionClassName = isCorrectOption
                ? 'w-full rounded-surface border border-[#16a34a]/20 bg-[#dcfce7] px-4 py-3.5 text-left text-[#166534]'
                : isSelected
                  ? 'w-full rounded-surface border border-[#dc2626]/20 bg-[#fee2e2] px-4 py-3.5 text-left text-[#991b1b]'
                  : 'w-full rounded-surface border border-navy/12 bg-white/92 px-4 py-3.5 text-left transition duration-150 hover:-translate-y-0.5 hover:shadow-float'

              return (
                <button
                  className={optionClassName}
                  disabled={selectedAnswerIndex !== null}
                  key={`${currentQuiz.id}-${index}`}
                  onClick={() => handleAnswerSelect(index)}
                  type="button"
                >
                  {index + 1}. {option}
                </button>
              )
            })}
          </div>

          {selectedAnswerIndex !== null ? (
            <div className="grid gap-3 rounded-surface bg-[#1768ac]/8 p-stack">
              <p className="m-0 font-semibold">
                {isAnswerCorrect(currentQuiz, selectedAnswerIndex)
                  ? '正解です。'
                  : `不正解です。正解は「${currentQuiz.options[currentQuiz.correctAnswerIndex]}」です。`}
              </p>
              <p className="m-0 whitespace-pre-line text-[#4f5d75]">{currentQuiz.explanation}</p>
              <button
                className={`${pillButtonClassName} w-fit bg-linear-to-br from-[#b88200] to-[#8b5e00] text-white`}
                onClick={handleNextQuiz}
                type="button"
              >
                {currentQuizIndex === activeQuizzes.length - 1 ? '結果を見る' : '次の問題へ'}
              </button>
            </div>
          ) : null}
        </div>
      ) : null}

      {isQuizFinished ? (
        <div className="grid justify-items-start gap-4 rounded-surface border border-dashed border-navy/16 bg-white/70 p-panel">
          <p className="m-0 text-[#4f5d75]">
            スコア: {score}点（{correctAnswers} / {activeQuizzes.length}問正解）
          </p>
          <div className="flex gap-3">
            <button
              className={`${pillButtonClassName} border border-navy/12 bg-white/92 text-navy`}
              onClick={startQuiz}
              type="button"
            >
              もう一度挑戦する
            </button>
          </div>
        </div>
      ) : null}
    </section>
  )
}

export default JsonQuizPreviewSection
