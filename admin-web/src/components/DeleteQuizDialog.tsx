import { useEffect, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { getQuiz } from '../api/admin'
import { getErrorMessage } from '../api/errors'
import { handleUnauthorized } from '../auth/session'
import type { Quiz } from '../types/admin'

interface DeleteQuizDialogProps {
  open: boolean
  quiz: Quiz | null
  errorMessage: string | null
  isDeleting: boolean
  onCancel: () => void
  onConfirm: () => void
}

function formatDateTime(value: string): string {
  return new Intl.DateTimeFormat('ja-JP', {
    dateStyle: 'long',
    timeStyle: 'short',
  }).format(new Date(value))
}

function DeleteQuizDialog({
  open,
  quiz,
  errorMessage,
  isDeleting,
  onCancel,
  onConfirm,
}: DeleteQuizDialogProps) {
  const navigate = useNavigate()
  const [detail, setDetail] = useState<Quiz | null>(null)
  const [detailErrorMessage, setDetailErrorMessage] = useState<string | null>(null)
  const [isLoadingDetail, setIsLoadingDetail] = useState(false)
  const [reloadKey, setReloadKey] = useState(0)

  useEffect(() => {
    if (!open || quiz === null) {
      setDetail(null)
      setDetailErrorMessage(null)
      setIsLoadingDetail(false)
      return
    }

    const controller = new AbortController()

    const loadDetail = async () => {
      setDetail(null)
      setIsLoadingDetail(true)
      setDetailErrorMessage(null)

      try {
        const loadedQuiz = await getQuiz(quiz.id, controller.signal)
        if (controller.signal.aborted) {
          return
        }

        setDetail(loadedQuiz)
      } catch (error) {
        if (controller.signal.aborted) {
          return
        }
        if (handleUnauthorized(error, navigate)) {
          return
        }

        setDetail(null)
        setDetailErrorMessage(getErrorMessage(error))
      } finally {
        if (!controller.signal.aborted) {
          setIsLoadingDetail(false)
        }
      }
    }

    void loadDetail()

    return () => {
      controller.abort()
    }
  }, [open, quiz, reloadKey, navigate])

  if (!open || quiz === null) {
    return null
  }

  const activeQuiz = detail?.id === quiz.id ? detail : quiz
  const deleteDisabled = isDeleting || isLoadingDetail || detailErrorMessage !== null

  return (
    <div
      className="fixed inset-0 z-40 grid place-items-center overflow-y-auto bg-navy/42 p-6 backdrop-blur-md"
      onClick={deleteDisabled ? undefined : onCancel}
      role="presentation"
    >
      <div
        aria-labelledby="delete-quiz-title"
        aria-modal="true"
        className="flex max-h-[calc(100vh-3rem)] w-full max-w-[720px] flex-col overflow-hidden rounded-card border border-[#b42318]/18 bg-[#fffaf8] p-7 shadow-card"
        onClick={(event) => event.stopPropagation()}
        role="dialog"
      >
        <div className="min-h-0 flex-1 overflow-y-auto pr-1">
          <p className="m-0 text-[0.8rem] uppercase tracking-[0.14em] text-[#b42318]">Delete Quiz</p>
          <h2 className="mt-2.5 mb-3 text-[clamp(1.4rem,2vw,1.8rem)] font-semibold" id="delete-quiz-title">
            「{activeQuiz.title}」を削除しますか
          </h2>
          <p className="m-0 text-[#4f5d75]">
            削除前に最新データを取得しています。内容を確認したうえで削除してください。この操作は元に戻せません。
          </p>

          {isLoadingDetail ? (
            <div className="mt-4 rounded-surface border border-[#14213d]/10 bg-white/70 px-4 py-3 text-sm text-[#4f5d75]">
              最新のクイズ詳細を取得中...
            </div>
          ) : null}

          {detailErrorMessage ? (
            <div className="mt-4 grid gap-3 rounded-surface border border-[#b42318]/14 bg-[#b42318]/8 p-4">
              <p className="m-0 text-sm text-[#7a271a]">{detailErrorMessage}</p>
              <div className="flex flex-wrap gap-3">
                <button
                  className="inline-flex items-center justify-center rounded-full border border-[#14213d]/12 bg-white px-[18px] py-3 text-sm font-medium transition duration-150 hover:-translate-y-0.5 hover:shadow-float-sm"
                  onClick={() => setReloadKey((current) => current + 1)}
                  type="button"
                >
                  詳細を再取得
                </button>
                <p className="m-0 self-center text-sm text-[#7a271a]">詳細取得に成功するまで削除は無効です。</p>
              </div>
            </div>
          ) : null}

          <div className="mt-4 grid gap-4 lg:grid-cols-[minmax(0,280px)_minmax(0,1fr)]">
            <dl className="grid gap-2 rounded-surface border border-[#14213d]/10 bg-white/70 p-4 text-sm text-[#4f5d75]">
              <div className="grid grid-cols-[96px_minmax(0,1fr)] gap-3">
                <dt className="font-semibold text-navy">ID</dt>
                <dd className="m-0">{activeQuiz.id}</dd>
              </div>
              <div className="grid grid-cols-[96px_minmax(0,1fr)] gap-3">
                <dt className="font-semibold text-navy">セクション</dt>
                <dd className="m-0">{activeQuiz.section}</dd>
              </div>
              <div className="grid grid-cols-[96px_minmax(0,1fr)] gap-3">
                <dt className="font-semibold text-navy">公開状態</dt>
                <dd className="m-0">{activeQuiz.status === 'published' ? '公開' : '非公開'}</dd>
              </div>
              <div className="grid grid-cols-[96px_minmax(0,1fr)] gap-3">
                <dt className="font-semibold text-navy">PUSH</dt>
                <dd className="m-0">{activeQuiz.pushEnabled ? 'ON' : 'OFF'}</dd>
              </div>
              <div className="grid grid-cols-[96px_minmax(0,1fr)] gap-3">
                <dt className="font-semibold text-navy">選択肢数</dt>
                <dd className="m-0">{activeQuiz.options.length} 件</dd>
              </div>
              <div className="grid grid-cols-[96px_minmax(0,1fr)] gap-3">
                <dt className="font-semibold text-navy">作成日時</dt>
                <dd className="m-0">{formatDateTime(activeQuiz.createdAt)}</dd>
              </div>
              <div className="grid grid-cols-[96px_minmax(0,1fr)] gap-3">
                <dt className="font-semibold text-navy">更新日時</dt>
                <dd className="m-0">{formatDateTime(activeQuiz.updatedAt)}</dd>
              </div>
            </dl>

            <div className="grid gap-3 rounded-surface border border-[#14213d]/10 bg-white/70 p-4 text-sm text-[#4f5d75]">
              <div className="grid gap-1.5">
                <p className="m-0 text-xs font-semibold uppercase tracking-[0.12em] text-[#1768ac]">Question</p>
                <p className="m-0 text-navy">{activeQuiz.question}</p>
              </div>
              <div className="grid gap-1.5">
                <p className="m-0 text-xs font-semibold uppercase tracking-[0.12em] text-[#1768ac]">Source</p>
                <p className="m-0 break-all">{activeQuiz.source}</p>
              </div>
              <div className="grid gap-1.5">
                <p className="m-0 text-xs font-semibold uppercase tracking-[0.12em] text-[#1768ac]">Correct Answer</p>
                <p className="m-0">
                  {activeQuiz.correctAnswerIndex + 1}. {activeQuiz.options[activeQuiz.correctAnswerIndex] ?? '未設定'}
                </p>
              </div>
              <div className="grid gap-1.5">
                <p className="m-0 text-xs font-semibold uppercase tracking-[0.12em] text-[#1768ac]">Explanation</p>
                <p className="m-0 whitespace-pre-wrap">{activeQuiz.explanation}</p>
              </div>
              {activeQuiz.code ? (
                <div className="grid gap-1.5">
                  <p className="m-0 text-xs font-semibold uppercase tracking-[0.12em] text-[#1768ac]">Code</p>
                  <pre className="m-0 overflow-x-auto rounded-[14px] bg-[#14213d] px-4 py-3 text-xs text-[#f8fafc]">
                    <code>{activeQuiz.code}</code>
                  </pre>
                </div>
              ) : null}
            </div>
          </div>

          {errorMessage ? (
            <p className="mt-4 rounded-[10px] bg-[#b42318]/10 px-3.5 py-3 text-[#7a271a]">
              {errorMessage}
            </p>
          ) : null}
        </div>

        <div className="mt-6 flex shrink-0 flex-col-reverse gap-3 border-t border-[#14213d]/10 pt-5 sm:flex-row sm:justify-end">
          <button
            className="inline-flex items-center justify-center rounded-full border border-navy/12 bg-white px-[18px] py-3 transition duration-150 hover:-translate-y-0.5 hover:shadow-float-sm disabled:cursor-progress disabled:opacity-60 disabled:hover:translate-y-0 disabled:hover:shadow-none"
            disabled={isDeleting}
            onClick={onCancel}
            type="button"
          >
            キャンセル
          </button>
          <button
            className="inline-flex items-center justify-center rounded-full bg-[#b42318] px-[18px] py-3 text-white transition duration-150 hover:-translate-y-0.5 hover:shadow-float-sm disabled:cursor-progress disabled:opacity-60 disabled:hover:translate-y-0 disabled:hover:shadow-none"
            disabled={deleteDisabled}
            onClick={onConfirm}
            type="button"
          >
            {isDeleting ? '削除中...' : isLoadingDetail ? '詳細取得中...' : '削除する'}
          </button>
        </div>
      </div>
    </div>
  )
}

export default DeleteQuizDialog
