import { useMemo } from 'react'
import { Link, useLocation, useParams } from 'react-router-dom'
import CodeBlock from '../components/CodeBlock'
import { useHistory } from '../contexts/HistoryContext'
import { useQuizCatalog } from '../hooks/useQuizCatalog'
import { calculateAccuracy, findQuiz } from '../lib/quizUtils'
import type { HistoryRecord } from '../types/quiz'

const pillButtonClassName =
  'inline-flex items-center justify-center rounded-full px-5 py-3 text-sm font-semibold transition duration-150 hover:-translate-y-0.5 hover:shadow-float'

function QuizResultPage() {
  const { recordId } = useParams<{ recordId: string }>()
  const { records } = useHistory()
  const location = useLocation()
  const { quizzes } = useQuizCatalog()

  const fallbackRecord = (location.state as { record?: HistoryRecord } | null)?.record
  const record = useMemo<HistoryRecord | undefined>(() => {
    if (recordId === undefined) return fallbackRecord
    return records.find((entry) => entry.id === recordId) ?? fallbackRecord
  }, [recordId, records, fallbackRecord])

  if (record === undefined) {
    return (
      <div className="rounded-card border border-navy/12 bg-white/86 p-card text-center shadow-card">
        <h1 className="m-0 text-[1.4rem] font-semibold">結果が見つかりません</h1>
        <p className="mt-2 mb-5 text-[#4f5d75]">
          履歴が削除されたか、リンクの ID が無効です。
        </p>
        <Link to="/" className={`${pillButtonClassName} bg-linear-to-br from-accent to-accent-strong text-white`}>
          ホームに戻る
        </Link>
      </div>
    )
  }

  const accuracy = calculateAccuracy(record.correct, record.total)
  const completedDate = new Date(record.completedAt)

  return (
    <div className="grid gap-6">
      <section className="rounded-card border border-navy/12 bg-white/92 p-card shadow-card">
        <p className="m-0 text-[0.78rem] uppercase tracking-[0.18em] text-accent">Result</p>
        <h1 className="mt-1 mb-3 text-[clamp(1.6rem,2.8vw,2.1rem)] font-semibold">
          {record.correct} / {record.total} 問正解
        </h1>
        <p className="m-0 text-[#4f5d75]">
          セクション: {record.sectionFilter ?? 'すべて'} ・ 完了:{' '}
          {completedDate.toLocaleString('ja-JP')}
        </p>

        <div className="mt-stack grid grid-cols-2 gap-4 sm:grid-cols-3">
          <ScoreCard label="正解" value={`${record.correct}`} unit="問" tone="correct" />
          <ScoreCard label="不正解" value={`${record.total - record.correct}`} unit="問" tone="incorrect" />
          <ScoreCard label="正答率" value={`${accuracy}`} unit="%" tone="accent" />
        </div>

        <div className="mt-stack flex flex-wrap gap-3">
          <Link to="/" className={`${pillButtonClassName} bg-linear-to-br from-accent to-accent-strong text-white`}>
            もう一度挑戦する
          </Link>
          <Link to="/history" className={`${pillButtonClassName} border border-navy/12 bg-white/90 text-navy`}>
            履歴へ
          </Link>
        </div>
      </section>

      <section className="grid gap-4">
        <h2 className="m-0 text-[1.15rem] font-semibold text-navy">解答の詳細</h2>
        {record.answers.map((answer, index) => {
          const quiz = findQuiz(quizzes, answer.quizId)
          if (quiz === undefined) {
            return (
              <article
                key={`missing-${answer.quizId}-${index}`}
                className="rounded-card border border-navy/12 bg-white/86 p-card shadow-card"
              >
                <p className="m-0 text-[#4f5d75]">
                  問題 ID {answer.quizId} のデータが見つかりません（カタログから削除された可能性があります）。
                </p>
              </article>
            )
          }

          return (
            <article
              key={`${answer.quizId}-${index}`}
              className={
                answer.correct
                  ? 'grid gap-3 rounded-card border border-correct/30 bg-white/92 p-card shadow-card'
                  : 'grid gap-3 rounded-card border border-incorrect/30 bg-white/92 p-card shadow-card'
              }
            >
              <header className="grid gap-1.5">
                <p className="m-0 text-xs font-semibold uppercase tracking-[0.16em] text-[#4f5d75]">
                  Q{index + 1} ・ {quiz.section}
                </p>
                <h3 className="m-0 text-[1.05rem] font-semibold text-navy">{quiz.title}</h3>
                <p className="m-0 whitespace-pre-line text-[#1f2a44]">{quiz.question}</p>
              </header>

              {quiz.code !== undefined && quiz.code !== '' ? (
                <CodeBlock code={quiz.code} ariaLabel={`${quiz.title} のコード`} />
              ) : null}

              <dl className="grid gap-1.5 text-sm">
                <div className="flex flex-wrap gap-2">
                  <dt className="font-semibold text-[#4f5d75]">あなたの回答:</dt>
                  <dd
                    className={
                      answer.correct
                        ? 'm-0 font-semibold text-correct'
                        : 'm-0 font-semibold text-incorrect'
                    }
                  >
                    {quiz.options[answer.selectedIndex] ?? '（不明）'}
                  </dd>
                </div>
                {!answer.correct ? (
                  <div className="flex flex-wrap gap-2">
                    <dt className="font-semibold text-[#4f5d75]">正解:</dt>
                    <dd className="m-0 font-semibold text-correct">
                      {quiz.options[quiz.correctAnswerIndex] ?? '（不明）'}
                    </dd>
                  </div>
                ) : null}
              </dl>

              <p className="m-0 rounded-surface border border-navy/8 bg-white/70 px-4 py-3 text-sm leading-relaxed text-navy">
                {quiz.explanation}
              </p>
              <p className="m-0 text-xs text-[#4f5d75]">出典: {quiz.source}</p>
            </article>
          )
        })}
      </section>
    </div>
  )
}

function ScoreCard({
  label,
  value,
  unit,
  tone,
}: {
  label: string
  value: string
  unit: string
  tone: 'correct' | 'incorrect' | 'accent'
}) {
  const toneClassName =
    tone === 'correct'
      ? 'border-correct/30 bg-correct-bg text-correct'
      : tone === 'incorrect'
        ? 'border-incorrect/30 bg-incorrect-bg text-incorrect'
        : 'border-accent/30 bg-accent/8 text-accent-strong'

  return (
    <div className={`rounded-surface border px-4 py-3 ${toneClassName}`}>
      <p className="m-0 text-xs font-semibold uppercase tracking-[0.12em]">{label}</p>
      <p className="mt-1.5 mb-0 text-[1.6rem] font-bold">
        {value}
        <span className="ml-1 text-sm font-medium opacity-80">{unit}</span>
      </p>
    </div>
  )
}

export default QuizResultPage
