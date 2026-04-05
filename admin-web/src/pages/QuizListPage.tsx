import { useCallback, useEffect, useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { deleteQuiz, listQuizzes } from '../api/admin'
import { getErrorMessage } from '../api/errors'
import { handleUnauthorized } from '../auth/session'
import DeleteQuizDialog from '../components/DeleteQuizDialog'
import JsonQuizPreviewSection from '../components/JsonQuizPreviewSection'
import type { Quiz } from '../types/admin'

const updatedAtFormatter = new Intl.DateTimeFormat('ja-JP', {
  dateStyle: 'medium',
  timeStyle: 'short',
})

const pillButtonClassName =
  'inline-flex items-center justify-center rounded-full px-4 py-3 text-sm font-medium transition duration-150 hover:-translate-y-0.5 hover:shadow-float'

function formatUpdatedAt(value: string): string {
  return updatedAtFormatter.format(new Date(value))
}

function QuizListPage() {
  const [quizzes, setQuizzes] = useState<Quiz[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [errorMessage, setErrorMessage] = useState<string | null>(null)
  const [deleteErrorMessage, setDeleteErrorMessage] = useState<string | null>(null)
  const [quizToDelete, setQuizToDelete] = useState<Quiz | null>(null)
  const [isDeleting, setIsDeleting] = useState(false)
  const navigate = useNavigate()

  const loadQuizzes = useCallback(async () => {
    setIsLoading(true)
    setErrorMessage(null)

    try {
      const items = await listQuizzes()
      setQuizzes(items)
    } catch (error) {
      if (handleUnauthorized(error, navigate)) {
        return
      }

      setErrorMessage(getErrorMessage(error))
    } finally {
      setIsLoading(false)
    }
  }, [navigate])

  useEffect(() => {
    void loadQuizzes()
  }, [loadQuizzes])

  const handleDeleteConfirm = async () => {
    if (!quizToDelete) {
      return
    }

    setIsDeleting(true)
    setDeleteErrorMessage(null)

    try {
      await deleteQuiz(quizToDelete.id)
      setQuizzes((current) => current.filter((quiz) => quiz.id !== quizToDelete.id))
      setQuizToDelete(null)
    } catch (error) {
      if (handleUnauthorized(error, navigate)) {
        return
      }

      setDeleteErrorMessage(getErrorMessage(error))
    } finally {
      setIsDeleting(false)
    }
  }

  return (
    <>
      <section className="mb-[22px] flex flex-col gap-5 xl:flex-row xl:items-end xl:justify-between">
        <div>
          <p className="m-0 mb-2.5 text-[0.78rem] uppercase tracking-[0.18em] text-[#1768ac]">Quiz Inventory</p>
          <h2 className="m-0 text-[clamp(1.8rem,3vw,2.4rem)] font-semibold">登録済みクイズ</h2>
          <p className="mt-3 mb-0 max-w-[700px] text-[#4f5d75]">
            出典付きの問題データを一か所で管理します。更新の新しい順に並べています。
          </p>
        </div>

        <div className="flex flex-wrap gap-3">
          <button
            className={`${pillButtonClassName} border border-navy/12 bg-white/92 text-navy`}
            onClick={() => void loadQuizzes()}
            type="button"
          >
            再読み込み
          </button>
          <Link
            className={`${pillButtonClassName} bg-linear-to-br from-[#1768ac] to-[#0f4c81] text-white`}
            to="/quizzes/new"
          >
            新規作成
          </Link>
        </div>
      </section>

      <section className="rounded-card border border-navy/12 bg-white/86 p-card shadow-card">
        <div className="mb-stack flex flex-col gap-3 md:flex-row md:items-center md:justify-between">
          <span className="inline-flex w-fit items-center rounded-full bg-[#1768ac]/12 px-3.5 py-2.5 font-semibold text-[#0f4c81]">
            {quizzes.length} quizzes
          </span>
          <span className="text-[#4f5d75]">管理画面から直接 CRUD 可能です。</span>
        </div>

        {errorMessage ? (
          <div className="mb-stack flex flex-col gap-3 rounded-surface bg-[#b42318]/10 p-4 text-[#7a271a] md:flex-row md:items-center md:justify-between">
            <p className="m-0">{errorMessage}</p>
            <button
              className={`${pillButtonClassName} border border-navy/12 bg-white/92 text-navy`}
              onClick={() => void loadQuizzes()}
              type="button"
            >
              再試行
            </button>
          </div>
        ) : null}

        {isLoading ? (
          <div className="grid min-h-[260px] place-items-center rounded-surface border border-dashed border-navy/16 px-8 py-6 text-center text-[#4f5d75]">
            読み込み中...
          </div>
        ) : quizzes.length === 0 ? (
          <div className="grid min-h-[260px] place-items-center gap-3 rounded-surface border border-dashed border-navy/16 px-8 py-6 text-center">
            <p className="m-0 text-[1.3rem] font-semibold text-navy">まだクイズがありません</p>
            <p className="m-0 max-w-[520px] text-[#4f5d75]">
              最初の1件を作成して、管理画面から編集フローを確認してください。
            </p>
            <Link
              className={`${pillButtonClassName} bg-linear-to-br from-[#1768ac] to-[#0f4c81] text-white`}
              to="/quizzes/new"
            >
              クイズを作成
            </Link>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="min-w-full border-collapse">
              <thead>
                <tr className="text-left text-[0.82rem] uppercase tracking-[0.08em] text-[#4f5d75]">
                  <th className="border-b border-navy/8 px-3 py-4 font-medium">タイトル</th>
                  <th className="border-b border-navy/8 px-3 py-4 font-medium">セクション</th>
                  <th className="border-b border-navy/8 px-3 py-4 font-medium">出典</th>
                  <th className="border-b border-navy/8 px-3 py-4 font-medium">更新日時</th>
                  <th className="border-b border-navy/8 px-3 py-4 font-medium">操作</th>
                </tr>
              </thead>
              <tbody>
                {quizzes.map((quiz) => (
                  <tr key={quiz.id}>
                    <td className="border-b border-navy/8 px-3 py-4 align-top">
                      <div className="grid gap-2">
                        <strong>{quiz.title}</strong>
                        <span className="text-[#4f5d75]">{quiz.question}</span>
                      </div>
                    </td>
                    <td className="border-b border-navy/8 px-3 py-4 align-top">{quiz.section}</td>
                    <td className="border-b border-navy/8 px-3 py-4 align-top">{quiz.source}</td>
                    <td className="border-b border-navy/8 px-3 py-4 align-top">{formatUpdatedAt(quiz.updatedAt)}</td>
                    <td className="border-b border-navy/8 px-3 py-4 align-top">
                      <div className="flex flex-wrap gap-2.5">
                        <Link
                          className={`${pillButtonClassName} border border-navy/12 bg-white/92 text-navy`}
                          to={`/quizzes/${quiz.id}/edit`}
                        >
                          編集
                        </Link>
                        <button
                          className={`${pillButtonClassName} bg-[#b42318]/12 text-[#b42318]`}
                          onClick={() => {
                            setDeleteErrorMessage(null)
                            setQuizToDelete(quiz)
                          }}
                          type="button"
                        >
                          削除
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </section>

      <JsonQuizPreviewSection />

      <DeleteQuizDialog
        errorMessage={deleteErrorMessage}
        isDeleting={isDeleting}
        onCancel={() => {
          setDeleteErrorMessage(null)
          setQuizToDelete(null)
        }}
        onConfirm={() => void handleDeleteConfirm()}
        open={quizToDelete !== null}
        quizTitle={quizToDelete?.title ?? ''}
      />
    </>
  )
}

export default QuizListPage
