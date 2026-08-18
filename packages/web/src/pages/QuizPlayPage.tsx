import { useCallback, useMemo, useState } from 'react'
import { Link, useNavigate, useSearchParams } from 'react-router-dom'
import AnswerOption from '../components/AnswerOption'
import { createAnswerHistoryBestEffort } from '../api/member'
import { submitAttemptBestEffort } from '../api/quiz'
import CodeBlock from '../components/CodeBlock'
import ProgressBar from '../components/ProgressBar'
import { useHistory } from '../contexts/HistoryContext'
import { useMemberSession } from '../contexts/MemberSessionContext'
import { useQuizCatalog } from '../hooks/useQuizCatalog'
import {
  findQuiz,
  generateSessionId,
  isAnswerCorrect,
  nowIso,
  pickQuizIds,
} from '../lib/quizUtils'
import type { HistoryRecord, Quiz, QuizAnswer } from '../types/quiz'

const DEFAULT_LIMIT = 10
const MAX_LIMIT = 100

interface SessionState {
  id: string
  sectionFilter: string | null
  startedAt: string
  quizIds: number[]
}

const pillButtonClassName =
  'inline-flex items-center justify-center rounded-full px-5 py-3 text-sm font-semibold transition duration-150 hover:-translate-y-0.5 hover:shadow-float disabled:cursor-not-allowed disabled:opacity-55 disabled:hover:translate-y-0 disabled:hover:shadow-none'

function parseLimit(raw: string | null): number {
  if (raw === null) return DEFAULT_LIMIT
  const parsed = Number.parseInt(raw, 10)
  if (Number.isNaN(parsed) || parsed <= 0) return DEFAULT_LIMIT
  return Math.min(parsed, MAX_LIMIT)
}

function QuizPlayPage() {
  const { quizzes, isLoading } = useQuizCatalog()

  if (isLoading) {
    return (
      <div className="rounded-card border border-navy/12 bg-white/86 p-card text-center shadow-card">
        <h1 className="m-0 text-[1.4rem] font-semibold">問題を読み込んでいます</h1>
        <p className="mt-2 mb-0 text-[#4f5d75]">Public API からクイズを取得中です。</p>
      </div>
    )
  }

  return <QuizSession quizzes={quizzes} />
}

// The session snapshots quiz ids once, so it must mount only after the catalog
// settled: starter-pack ids and Public API ids do not overlap.
function QuizSession({ quizzes }: { quizzes: readonly Quiz[] }) {
  const [searchParams] = useSearchParams()
  const navigate = useNavigate()
  const { appendRecord } = useHistory()
  const { session: memberSession } = useMemberSession()

  const initialSection = searchParams.get('section')
  const initialLimit = parseLimit(searchParams.get('limit'))

  const [session] = useState<SessionState>(() => ({
    id: generateSessionId(),
    sectionFilter: initialSection,
    startedAt: nowIso(),
    quizIds: pickQuizIds(quizzes, initialSection, initialLimit),
  }))

  const [currentIndex, setCurrentIndex] = useState(0)
  const [selectedIndex, setSelectedIndex] = useState<number | null>(null)
  const [revealed, setRevealed] = useState(false)
  const [answers, setAnswers] = useState<QuizAnswer[]>([])

  const currentQuiz = useMemo<Quiz | undefined>(() => {
    const quizId = session.quizIds[currentIndex]
    if (quizId === undefined) return undefined
    return findQuiz(quizzes, quizId)
  }, [quizzes, session.quizIds, currentIndex])

  const totalQuestions = session.quizIds.length

  const handleSelect = useCallback(
    (index: number) => {
      if (revealed) return
      setSelectedIndex(index)
    },
    [revealed],
  )

  const handleSubmit = useCallback(() => {
    if (selectedIndex === null || currentQuiz === undefined || revealed) return
    const correct = isAnswerCorrect(currentQuiz, selectedIndex)
    setAnswers((prev) => [
      ...prev,
      { quizId: currentQuiz.id, selectedIndex, correct },
    ])
    setRevealed(true)
    if (memberSession !== null) {
      void createAnswerHistoryBestEffort(memberSession.token, {
        quizId: currentQuiz.id,
        selectedIndex,
      })
    }
  }, [selectedIndex, currentQuiz, revealed, memberSession])

  const finalizeAndGo = useCallback(
    (allAnswers: readonly QuizAnswer[]) => {
      const correctCount = allAnswers.reduce((sum, answer) => sum + (answer.correct ? 1 : 0), 0)
      const record: HistoryRecord = {
        id: session.id,
        sectionFilter: session.sectionFilter,
        total: totalQuestions,
        correct: correctCount,
        startedAt: session.startedAt,
        completedAt: nowIso(),
        answers: [...allAnswers],
      }
      appendRecord(record)
      void submitAttemptBestEffort(record)
      navigate(`/result/${record.id}`, { state: { record }, replace: true })
    },
    [session.id, session.sectionFilter, session.startedAt, totalQuestions, appendRecord, navigate],
  )

  const handleNext = useCallback(() => {
    if (!revealed) return
    const isLast = currentIndex >= totalQuestions - 1
    if (isLast) {
      finalizeAndGo(answers)
      return
    }
    setCurrentIndex((prev) => prev + 1)
    setSelectedIndex(null)
    setRevealed(false)
  }, [revealed, currentIndex, totalQuestions, answers, finalizeAndGo])

  if (totalQuestions === 0) {
    return (
      <div className="rounded-card border border-navy/12 bg-white/86 p-card text-center shadow-card">
        <h1 className="m-0 text-[1.4rem] font-semibold">出題できる問題がありません</h1>
        <p className="mt-2 mb-5 text-[#4f5d75]">
          選択したセクションには問題が登録されていません。別のセクションを選んでください。
        </p>
        <Link to="/" className={`${pillButtonClassName} bg-linear-to-br from-accent to-accent-strong text-white`}>
          ホームに戻る
        </Link>
      </div>
    )
  }

  if (currentQuiz === undefined) {
    return (
      <div className="rounded-card border border-navy/12 bg-white/86 p-card text-center shadow-card">
        <h1 className="m-0 text-[1.4rem] font-semibold">問題を読み込めません</h1>
        <p className="mt-2 mb-5 text-[#4f5d75]">
          セッションの状態が壊れています。最初からやり直してください。
        </p>
        <Link to="/" className={`${pillButtonClassName} bg-linear-to-br from-accent to-accent-strong text-white`}>
          ホームに戻る
        </Link>
      </div>
    )
  }

  return (
    <div className="grid gap-6">
      <ProgressBar current={currentIndex + (revealed ? 1 : 0)} total={totalQuestions} />

      <article className="grid gap-stack rounded-card border border-navy/12 bg-white/92 p-card shadow-card">
        <header className="grid gap-2">
          <p className="m-0 text-[0.78rem] uppercase tracking-[0.18em] text-accent">
            {currentQuiz.section}
          </p>
          <h1 className="m-0 text-[clamp(1.3rem,2.4vw,1.7rem)] font-semibold">{currentQuiz.title}</h1>
          <p className="m-0 whitespace-pre-line text-[#1f2a44]">{currentQuiz.question}</p>
        </header>

        {currentQuiz.code !== undefined && currentQuiz.code !== '' ? (
          <CodeBlock code={currentQuiz.code} ariaLabel={`${currentQuiz.title} のコード`} />
        ) : null}

        <div className="grid gap-2.5">
          {currentQuiz.options.map((option, index) => (
            <AnswerOption
              key={option}
              index={index}
              label={option}
              disabled={revealed}
              variant={resolveVariant({
                index,
                selectedIndex,
                correctIndex: currentQuiz.correctAnswerIndex,
                revealed,
              })}
              onSelect={handleSelect}
            />
          ))}
        </div>

        {revealed ? (
          <Feedback quiz={currentQuiz} selectedIndex={selectedIndex} />
        ) : null}

        <div className="flex flex-wrap items-center justify-between gap-3">
          <Link to="/" className="text-sm font-medium text-[#4f5d75] hover:text-accent">
            セッションを中断してホームへ戻る
          </Link>
          {revealed ? (
            <button
              type="button"
              onClick={handleNext}
              className={`${pillButtonClassName} bg-linear-to-br from-accent to-accent-strong text-white`}
            >
              {currentIndex >= totalQuestions - 1 ? '結果を見る' : '次の問題へ'}
            </button>
          ) : (
            <button
              type="button"
              onClick={handleSubmit}
              disabled={selectedIndex === null}
              className={`${pillButtonClassName} bg-linear-to-br from-accent to-accent-strong text-white`}
            >
              回答する
            </button>
          )}
        </div>
      </article>
    </div>
  )
}

function resolveVariant({
  index,
  selectedIndex,
  correctIndex,
  revealed,
}: {
  index: number
  selectedIndex: number | null
  correctIndex: number
  revealed: boolean
}): 'idle' | 'selected' | 'correct' | 'incorrect' | 'reveal-correct' {
  if (!revealed) {
    return selectedIndex === index ? 'selected' : 'idle'
  }
  if (index === correctIndex && selectedIndex === index) return 'correct'
  if (index === selectedIndex) return 'incorrect'
  if (index === correctIndex) return 'reveal-correct'
  return 'idle'
}

function Feedback({ quiz, selectedIndex }: { quiz: Quiz; selectedIndex: number | null }) {
  if (selectedIndex === null) return null
  const correct = isAnswerCorrect(quiz, selectedIndex)
  return (
    <div
      className={
        correct
          ? 'grid gap-2 rounded-surface border border-correct/30 bg-correct-bg px-4 py-3.5 text-correct'
          : 'grid gap-2 rounded-surface border border-incorrect/30 bg-incorrect-bg px-4 py-3.5 text-incorrect'
      }
      role="status"
    >
      <p className="m-0 text-sm font-semibold">{correct ? '正解！' : '不正解'}</p>
      <p className="m-0 text-sm leading-relaxed text-navy">{quiz.explanation}</p>
      <p className="m-0 text-xs text-[#4f5d75]">出典: {quiz.source}</p>
    </div>
  )
}

export default QuizPlayPage
