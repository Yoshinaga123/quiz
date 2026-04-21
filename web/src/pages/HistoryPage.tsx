import { useMemo, useState } from 'react'
import { Link } from 'react-router-dom'
import { useHistory } from '../contexts/HistoryContext'
import { calculateAccuracy } from '../lib/quizUtils'

const pillButtonClassName =
  'inline-flex items-center justify-center rounded-full px-5 py-3 text-sm font-semibold transition duration-150 hover:-translate-y-0.5 hover:shadow-float'

const formatter = new Intl.DateTimeFormat('ja-JP', {
  dateStyle: 'long',
  timeStyle: 'short',
})

function HistoryPage() {
  const { records, clearAll } = useHistory()
  const [confirming, setConfirming] = useState(false)

  const sortedRecords = useMemo(
    () =>
      [...records].sort((a, b) => {
        return b.completedAt.localeCompare(a.completedAt)
      }),
    [records],
  )

  const totalQuestions = records.reduce((sum, record) => sum + record.total, 0)
  const totalCorrect = records.reduce((sum, record) => sum + record.correct, 0)
  const overallAccuracy = calculateAccuracy(totalCorrect, totalQuestions)

  const sectionAccuracy = useMemo(() => {
    const map = new Map<string, { total: number; correct: number }>()
    for (const record of records) {
      const key = record.sectionFilter ?? '（すべて）'
      const current = map.get(key) ?? { total: 0, correct: 0 }
      current.total += record.total
      current.correct += record.correct
      map.set(key, current)
    }
    return Array.from(map.entries())
      .map(([section, value]) => ({
        section,
        total: value.total,
        correct: value.correct,
        accuracy: calculateAccuracy(value.correct, value.total),
      }))
      .sort((a, b) => b.total - a.total)
  }, [records])

  return (
    <div className="grid gap-6">
      <section className="grid gap-3">
        <p className="m-0 text-[0.78rem] uppercase tracking-[0.18em] text-accent">History</p>
        <h1 className="m-0 text-[clamp(1.6rem,2.8vw,2.1rem)] font-semibold">これまでの挑戦</h1>
        <p className="m-0 max-w-[720px] text-[#4f5d75]">
          ブラウザ内（LocalStorage）に保存された履歴です。キャッシュをクリアすると消えます。
        </p>
      </section>

      <section className="rounded-card border border-navy/12 bg-white/86 p-card shadow-card">
        <div className="grid grid-cols-2 gap-4 sm:grid-cols-4">
          <Stat label="挑戦回数" value={`${records.length}`} unit="回" />
          <Stat label="解答数" value={`${totalQuestions}`} unit="問" />
          <Stat label="正解数" value={`${totalCorrect}`} unit="問" />
          <Stat label="累計正答率" value={`${overallAccuracy}`} unit="%" />
        </div>
      </section>

      {sectionAccuracy.length > 0 ? (
        <section className="rounded-card border border-navy/12 bg-white/86 p-card shadow-card">
          <h2 className="m-0 text-[1.15rem] font-semibold text-navy">セクション別の傾向</h2>
          <ul className="mt-stack m-0 grid gap-2 p-0 list-none">
            {sectionAccuracy.map((entry) => (
              <li
                key={entry.section}
                className="flex flex-wrap items-center justify-between gap-3 rounded-surface border border-navy/8 bg-white/70 px-4 py-3"
              >
                <span className="font-semibold text-navy">{entry.section}</span>
                <span className="text-sm text-[#4f5d75]">
                  {entry.correct} / {entry.total} 問正解 ({entry.accuracy}%)
                </span>
              </li>
            ))}
          </ul>
        </section>
      ) : null}

      <section className="rounded-card border border-navy/12 bg-white/86 p-card shadow-card">
        <div className="mb-stack flex flex-wrap items-center justify-between gap-3">
          <h2 className="m-0 text-[1.15rem] font-semibold text-navy">セッション一覧</h2>
          {records.length > 0 ? (
            confirming ? (
              <div className="flex flex-wrap items-center gap-2.5">
                <span className="text-sm text-incorrect">本当に削除しますか？</span>
                <button
                  type="button"
                  onClick={() => {
                    clearAll()
                    setConfirming(false)
                  }}
                  className={`${pillButtonClassName} bg-incorrect text-white`}
                >
                  すべて削除
                </button>
                <button
                  type="button"
                  onClick={() => setConfirming(false)}
                  className={`${pillButtonClassName} border border-navy/12 bg-white/90 text-navy`}
                >
                  キャンセル
                </button>
              </div>
            ) : (
              <button
                type="button"
                onClick={() => setConfirming(true)}
                className={`${pillButtonClassName} border border-incorrect/20 bg-incorrect-bg text-incorrect`}
              >
                履歴をクリア
              </button>
            )
          ) : null}
        </div>

        {records.length === 0 ? (
          <div className="grid min-h-[200px] place-items-center gap-3 rounded-surface border border-dashed border-navy/16 px-6 py-8 text-center">
            <p className="m-0 text-[1.05rem] font-semibold text-navy">履歴はまだありません</p>
            <p className="m-0 text-sm text-[#4f5d75]">
              まずは 1 セッション挑戦してみましょう。
            </p>
            <Link
              to="/"
              className={`${pillButtonClassName} bg-linear-to-br from-accent to-accent-strong text-white`}
            >
              ホームへ
            </Link>
          </div>
        ) : (
          <ul className="m-0 grid gap-2.5 p-0 list-none">
            {sortedRecords.map((record) => {
              const accuracy = calculateAccuracy(record.correct, record.total)
              return (
                <li
                  key={record.id}
                  className="flex flex-col gap-2 rounded-surface border border-navy/8 bg-white/70 px-4 py-3.5 sm:flex-row sm:items-center sm:justify-between"
                >
                  <div>
                    <p className="m-0 text-sm text-[#4f5d75]">
                      {formatter.format(new Date(record.completedAt))}
                    </p>
                    <p className="m-0 font-semibold text-navy">
                      {record.sectionFilter ?? 'すべて'} ・ {record.correct} / {record.total} 問正解
                      <span className="ml-2 text-sm font-medium text-[#4f5d75]">({accuracy}%)</span>
                    </p>
                  </div>
                  <Link
                    to={`/result/${record.id}`}
                    className={`${pillButtonClassName} border border-navy/12 bg-white/90 text-navy`}
                  >
                    詳細を見る
                  </Link>
                </li>
              )
            })}
          </ul>
        )}
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

export default HistoryPage
