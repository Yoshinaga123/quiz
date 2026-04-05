import type { FormEvent } from 'react'
import { Link } from 'react-router-dom'
import type { QuizFormValues } from '../types/admin'

type QuizFormField = Exclude<keyof QuizFormValues, 'correctAnswerIndex' | 'options'>

interface QuizFormProps {
  heading: string
  description: string
  submitLabel: string
  values: QuizFormValues
  errorMessage: string | null
  isSubmitting: boolean
  onSubmit: (event: FormEvent<HTMLFormElement>) => void
  onFieldChange: (field: QuizFormField, value: string) => void
  onOptionChange: (index: number, value: string) => void
  onCorrectAnswerChange: (index: number) => void
  onAddOption: () => void
  onRemoveOption: (index: number) => void
}

const inputClassName =
  'w-full rounded-surface border border-navy/14 bg-white/90 px-4 py-3.5 text-navy transition focus:border-[#1768ac]/50 focus:outline-none focus:ring-4 focus:ring-[#1768ac]/16'

const pillButtonClassName =
  'inline-flex items-center justify-center rounded-full px-4 py-3 text-sm font-medium transition duration-150 hover:-translate-y-0.5 hover:shadow-float'

function QuizForm({
  heading,
  description,
  submitLabel,
  values,
  errorMessage,
  isSubmitting,
  onSubmit,
  onFieldChange,
  onOptionChange,
  onCorrectAnswerChange,
  onAddOption,
  onRemoveOption,
}: QuizFormProps) {
  return (
    <form
      className="rounded-card border border-navy/12 bg-white/86 p-card-lg shadow-card"
      onSubmit={onSubmit}
    >
      <header className="mb-7 flex flex-wrap justify-between gap-4">
        <div>
          <p className="m-0 text-[0.8rem] uppercase tracking-[0.16em] text-[#1768ac]">Quiz Editor</p>
          <h1 className="mt-2.5 mb-0 text-[clamp(1.9rem,3vw,2.6rem)] font-semibold">{heading}</h1>
          <p className="mt-3 mb-0 max-w-[720px] text-[#4f5d75]">{description}</p>
        </div>
      </header>

      {errorMessage ? (
        <p className="mb-6 rounded-[10px] bg-[#b42318]/10 px-4 py-3.5 text-[#7a271a]">{errorMessage}</p>
      ) : null}

      <div className="grid gap-5 md:grid-cols-2">
        <label className="grid gap-2.5">
          <span className="font-semibold">セクション</span>
          <input
            className={inputClassName}
            onChange={(event) => onFieldChange('section', event.target.value)}
            placeholder="React Hooks"
            required
            type="text"
            value={values.section}
          />
        </label>

        <label className="grid gap-2.5">
          <span className="font-semibold">出典</span>
          <input
            className={inputClassName}
            onChange={(event) => onFieldChange('source', event.target.value)}
            placeholder="React Docs - useEffect"
            required
            type="text"
            value={values.source}
          />
        </label>

        <label className="grid gap-2.5 md:col-span-2">
          <span className="font-semibold">タイトル</span>
          <input
            className={inputClassName}
            onChange={(event) => onFieldChange('title', event.target.value)}
            placeholder="依存配列の評価タイミング"
            required
            type="text"
            value={values.title}
          />
        </label>

        <label className="grid gap-2.5 md:col-span-2">
          <span className="font-semibold">問題文</span>
          <textarea
            className={`${inputClassName} min-h-[120px]`}
            onChange={(event) => onFieldChange('question', event.target.value)}
            placeholder="このコードが実行されるタイミングとして最も正しいものを選んでください。"
            required
            rows={5}
            value={values.question}
          />
        </label>

        <label className="grid gap-2.5 md:col-span-2">
          <span className="font-semibold">コード断片</span>
          <textarea
            className={`${inputClassName} min-h-[180px] font-mono text-sm`}
            onChange={(event) => onFieldChange('code', event.target.value)}
            placeholder={"useEffect(() => {\n  fetchData()\n}, [userId])"}
            rows={8}
            value={values.code}
          />
          <span className="text-[0.92rem] text-[#4f5d75]">
            任意項目です。問題文だけで成立する場合は空欄で構いません。
          </span>
        </label>

        <div className="grid gap-2.5 md:col-span-2">
          <div className="flex flex-col gap-3 sm:flex-row sm:items-start sm:justify-between">
            <div>
              <span className="font-semibold">選択肢</span>
              <p className="mt-1 text-[0.92rem] text-[#4f5d75]">
                正解のラジオボタンを一つだけ選択してください。
              </p>
            </div>
            <button
              className={`${pillButtonClassName} bg-[#1768ac]/12 text-[#0f4c81]`}
              onClick={onAddOption}
              type="button"
            >
              選択肢を追加
            </button>
          </div>

          <div className="grid gap-3">
            {values.options.map((option, index) => (
              <div className="grid gap-3 md:grid-cols-[auto_minmax(0,1fr)_auto] md:items-center" key={`option-${index}`}>
                <label className="inline-flex min-w-[84px] items-center gap-2 text-[#4f5d75]">
                  <input
                    checked={values.correctAnswerIndex === index}
                    className="accent-[#1768ac]"
                    name="correctAnswerIndex"
                    onChange={() => onCorrectAnswerChange(index)}
                    type="radio"
                  />
                  <span>正解</span>
                </label>
                <input
                  className={inputClassName}
                  onChange={(event) => onOptionChange(index, event.target.value)}
                  placeholder={`選択肢 ${index + 1}`}
                  required
                  type="text"
                  value={option}
                />
                <button
                  className={`${pillButtonClassName} bg-[#b42318]/12 text-[#b42318] disabled:cursor-not-allowed disabled:opacity-55 disabled:hover:translate-y-0 disabled:hover:shadow-none`}
                  disabled={values.options.length <= 2}
                  onClick={() => onRemoveOption(index)}
                  type="button"
                >
                  削除
                </button>
              </div>
            ))}
          </div>
        </div>

        <label className="grid gap-2.5 md:col-span-2">
          <span className="font-semibold">解説</span>
          <textarea
            className={`${inputClassName} min-h-[140px]`}
            onChange={(event) => onFieldChange('explanation', event.target.value)}
            placeholder="依存配列に userId が入っているため、初回マウント時と userId 更新時に再実行されます。"
            required
            rows={6}
            value={values.explanation}
          />
        </label>
      </div>

      <div className="mt-7 flex flex-col gap-3 sm:flex-row sm:justify-end">
        <Link className={`${pillButtonClassName} border border-navy/12 bg-white/90`} to="/quizzes">
          一覧へ戻る
        </Link>
        <button
          className={`${pillButtonClassName} bg-linear-to-br from-[#1768ac] to-[#0f4c81] text-white disabled:cursor-progress disabled:opacity-60 disabled:hover:translate-y-0 disabled:hover:shadow-none`}
          disabled={isSubmitting}
          type="submit"
        >
          {isSubmitting ? '保存中...' : submitLabel}
        </button>
      </div>
    </form>
  )
}

export default QuizForm
