import { useMemo, useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import SectionPicker from '../components/SectionPicker'
import { useHistory } from '../contexts/HistoryContext'
import { useMastery } from '../contexts/MasteryContext'
import { useQuizCatalog } from '../hooks/useQuizCatalog'
import { calculateAccuracy, filterBySection, listSections } from '../lib/quizUtils'
import { computeRank } from '../lib/rank'

const QUIZ_LIMIT_OPTIONS = [10, 30, 100] as const

const pillButtonClassName =
  'inline-flex items-center justify-center rounded-full px-5 py-3 text-sm font-semibold transition duration-150 hover:-translate-y-0.5 hover:shadow-float disabled:cursor-not-allowed disabled:opacity-55 disabled:hover:translate-y-0 disabled:hover:shadow-none'

function HomePage() {
  const { quizzes, isLoading, errorMessage, source, reload } = useQuizCatalog()
  const { records } = useHistory()
  const { streaks } = useMastery()
  const navigate = useNavigate()
  const [section, setSection] = useState<string | null>(null)
  const [limit, setLimit] = useState<number>(QUIZ_LIMIT_OPTIONS[1])

  const sections = useMemo(() => listSections(quizzes), [quizzes])
  const availableCount = useMemo(() => filterBySection(quizzes, section).length, [quizzes, section])
  const effectiveLimit = Math.min(limit, availableCount)

  const totalAttempts = records.length
  const lifetimeQuestions = records.reduce((sum, record) => sum + record.total, 0)
  const lifetimeCorrect = records.reduce((sum, record) => sum + record.correct, 0)
  const lifetimeAccuracy = calculateAccuracy(lifetimeCorrect, lifetimeQuestions)

  const quizIds = useMemo(() => quizzes.map((quiz) => quiz.id), [quizzes])
  const rank = useMemo(() => computeRank(streaks, quizIds), [streaks, quizIds])

  function handleStart() {
    if (effectiveLimit <= 0) return
    const params = new URLSearchParams()
    if (section !== null) params.set('section', section)
    params.set('limit', String(effectiveLimit))
    navigate(`/play?${params.toString()}`)
  }

  return (
    <div className="grid gap-8">
      <section className="grid gap-3">
        <p className="m-0 text-[0.78rem] uppercase tracking-[0.18em] text-accent">Today's Challenge</p>
        <h1 className="m-0 text-[clamp(1.8rem,3vw,2.4rem)] font-semibold">高難易度の IT クイズに挑戦する</h1>
        <p className="m-0 max-w-[720px] text-[#4f5d75]">
          MDN Web Docs / React 公式 / RFC など一次情報からの引用に基づいた問題集です。コードの意味、公式英文の和訳、設計上の判断などを横断で出題します。
        </p>
      </section>

      <section className="rounded-card border border-navy/12 bg-white/86 p-card shadow-card">
        {isLoading || errorMessage !== null || source === 'api' ? (
          <div className="mb-5 rounded-surface border border-navy/10 bg-white/70 px-4 py-3 text-sm text-[#4f5d75]">
            {isLoading ? 'Public API からクイズを読み込み中です。' : null}
            {!isLoading && source === 'api' ? 'Public API のクイズデータで動作中です。' : null}
            {!isLoading && errorMessage !== null ? (
              <div className="flex flex-wrap items-center justify-between gap-3">
                <span>Public API から取得できないため starter pack で続行しています。</span>
                <button className="font-semibold text-accent hover:underline" onClick={reload} type="button">
                  再試行
                </button>
              </div>
            ) : null}
          </div>
        ) : null}
        <div className="grid gap-stack">
          <div>
            <h2 className="m-0 text-[1.15rem] font-semibold text-navy">セクションを選ぶ</h2>
            <p className="mt-1 mb-0 text-sm text-[#4f5d75]">
              ジャンルを絞って復習するか、すべてからランダム出題するかを選択できます。
            </p>
          </div>
          <SectionPicker
            sections={sections}
            totalCount={quizzes.length}
            selected={section}
            onSelect={setSection}
          />
        </div>

        <hr className="my-6 border-0 border-t border-navy/8" />

        <div className="grid gap-stack">
          <div>
            <h2 className="m-0 text-[1.15rem] font-semibold text-navy">出題数</h2>
            <p className="mt-1 mb-0 text-sm text-[#4f5d75]">
              現在のセクションには {availableCount} 問あります。
            </p>
          </div>
          <div className="flex flex-wrap gap-2.5">
            {QUIZ_LIMIT_OPTIONS.map((value) => (
              <button
                type="button"
                key={value}
                onClick={() => setLimit(value)}
                className={
                  limit === value
                    ? `${pillButtonClassName} bg-linear-to-br from-accent to-accent-strong text-white`
                    : `${pillButtonClassName} border border-navy/12 bg-white/90 text-navy`
                }
              >
                {value} 問
              </button>
            ))}
          </div>
        </div>

        <hr className="my-6 border-0 border-t border-navy/8" />

        <div className="flex flex-wrap items-center justify-between gap-4">
          <p className="m-0 text-sm text-[#4f5d75]">
            実際に挑戦するのは <strong className="text-navy">{effectiveLimit}</strong> 問です。
          </p>
          <button
            type="button"
            onClick={handleStart}
            disabled={effectiveLimit <= 0}
            className={`${pillButtonClassName} bg-linear-to-br from-accent to-accent-strong text-white`}
          >
            クイズを始める
          </button>
        </div>
      </section>

      <section className="rounded-card border border-navy/12 bg-white/86 p-card shadow-card">
        <div className="flex flex-wrap items-center justify-between gap-3">
          <h2 className="m-0 text-[1.15rem] font-semibold text-navy">現在の段位</h2>
          <Link to="/history" className="text-sm font-medium text-accent hover:underline">
            詳細
          </Link>
        </div>
        <div className="mt-stack grid gap-4 sm:grid-cols-[minmax(0,160px)_1fr] sm:items-center">
          <div className="rounded-surface border border-navy/12 bg-linear-to-br from-white to-[#E8F1FA] px-5 py-5 text-center">
            <p className="m-0 text-xs font-medium uppercase tracking-[0.14em] text-[#4f5d75]">
              Current Rank
            </p>
            <p className="mt-1.5 mb-0 text-[1.9rem] font-bold text-navy">{rank.rank}</p>
            {rank.nextRank !== null ? (
              <p className="m-0 text-xs text-[#4f5d75]">次: {rank.nextRank}</p>
            ) : (
              <p className="m-0 text-xs text-accent">最高位に到達</p>
            )}
          </div>
          <div className="grid gap-2">
            <div className="flex items-center justify-between text-sm text-[#4f5d75]">
              <span>習熟度</span>
              <span>
                {rank.mastery} / {rank.totalPossible} pt
                <span className="ml-1 text-xs">({Math.round(rank.progress * 100)}%)</span>
              </span>
            </div>
            <div className="h-2 overflow-hidden rounded-full bg-navy/8">
              <div
                className="h-full bg-linear-to-r from-accent to-accent-strong"
                style={{ width: `${Math.min(100, rank.progress * 100)}%` }}
                aria-hidden="true"
              />
            </div>
            <p className="m-0 text-xs text-[#4f5d75]">
              各問題を 2 回連続で解くごとに +1 pt。全問制覇で「名人」になります。
            </p>
          </div>
        </div>
      </section>

      <section className="rounded-card border border-navy/12 bg-white/86 p-card shadow-card">
        <div className="flex flex-wrap items-center justify-between gap-3">
          <h2 className="m-0 text-[1.15rem] font-semibold text-navy">あなたの累計</h2>
          <Link
            to="/history"
            className="text-sm font-medium text-accent hover:underline"
          >
            履歴をすべて見る
          </Link>
        </div>
        <div className="mt-stack grid grid-cols-2 gap-4 sm:grid-cols-4">
          <Stat label="挑戦回数" value={`${totalAttempts}`} unit="回" />
          <Stat label="解答数" value={`${lifetimeQuestions}`} unit="問" />
          <Stat label="正解数" value={`${lifetimeCorrect}`} unit="問" />
          <Stat label="累計正答率" value={`${lifetimeAccuracy}`} unit="%" />
        </div>
      </section>
    </div>
  )
}

function Stat({ label, value, unit }: { label: string; value: string; unit: string }) {
  return (
    <div className="rounded-surface border border-navy/8 bg-white/70 px-4 py-3">
      <p className="m-0 text-xs font-medium uppercase tracking-[0.12em] text-[#4f5d75]">{label}</p>
      <p className="mt-1.5 mb-0 text-[1.5rem] font-bold text-navy">
        {value}
        <span className="ml-1 text-sm font-medium text-[#4f5d75]">{unit}</span>
      </p>
    </div>
  )
}

export default HomePage
