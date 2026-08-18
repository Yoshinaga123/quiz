import { useEffect, useState } from 'react'
import { Link, useNavigate, useSearchParams } from 'react-router-dom'
import {
  deleteQuiz,
  dispatchMockPush,
  fetchPushDeliveries,
  syncProductionQuizzes,
  toggleQuizPush,
  toggleQuizStatus,
} from '../api/admin'
import { ApiError, getErrorMessage } from '../api/errors'
import { handleUnauthorized } from '../auth/session'
import DeleteQuizDialog from '../components/DeleteQuizDialog'
import JsonQuizPreviewSection from '../components/JsonQuizPreviewSection'
import { useFlash } from '../contexts/FlashContext'
import { useQuizzes } from '../hooks/useQuizzes'
import type { PushDelivery, Quiz, QuizSearchParams, QuizSort } from '../types/admin'

const formatter = new Intl.DateTimeFormat('ja-JP', {
  dateStyle: 'long',
  timeStyle: 'short',
})

const DEFAULT_SORT: QuizSort = 'updated_newest'

const pillButtonClassName =
  'inline-flex items-center justify-center rounded-full px-4 py-3 text-sm font-medium transition duration-150 hover:-translate-y-0.5 hover:shadow-float'

interface SearchDraft {
  title: string
  section: string
  status: '' | 'published' | 'unpublished'
  sort: QuizSort
}

function formatDateTime(value: string): string {
  return formatter.format(new Date(value))
}

function getSyncProductionErrorMessage(error: unknown): string {
  if (error instanceof ApiError) {
    switch (error.status) {
      case 400:
        return `反映リクエストが不正です: ${error.message}`
      case 401:
        return '認証が切れています。再ログインしてから再実行してください。'
      case 403:
        return 'この操作を実行する権限がありません。'
      case 404:
        return `quizzes.json が見つかりません: ${error.message}`
      case 409:
        return `同期ジョブの競合または dirty database により反映できません: ${error.message}`
      case 422:
        return `quizzes.json の内容が不正です: ${error.message}`
      case 500:
        return `サーバー内部で反映に失敗しました: ${error.message}`
      case 502:
      case 503:
      case 504:
        return `バックエンドが一時的に利用できません: ${error.message}`
      default:
        return `quizzes.json の反映に失敗しました (${error.status}): ${error.message}`
    }
  }

  if (error instanceof TypeError) {
    return 'バックエンドへ接続できません。API サーバーが起動しているか確認してください。'
  }

  return `quizzes.json の反映に失敗しました: ${getErrorMessage(error)}`
}

function createDraft(searchParams: URLSearchParams): SearchDraft {
  const status = searchParams.get('status')
  const sort = searchParams.get('sort')

  return {
    title: searchParams.get('title') ?? '',
    section: searchParams.get('section') ?? '',
    status: status === 'published' || status === 'unpublished' ? status : '',
    sort:
      sort === 'updated_oldest' || sort === 'created_newest' || sort === 'created_oldest'
        ? sort
        : DEFAULT_SORT,
  }
}

function createQueryParams(draft: SearchDraft, page = 1): URLSearchParams {
  const nextParams = new URLSearchParams()

  if (draft.title.trim() !== '') {
    nextParams.set('title', draft.title.trim())
  }
  if (draft.section.trim() !== '') {
    nextParams.set('section', draft.section.trim())
  }
  if (draft.status !== '') {
    nextParams.set('status', draft.status)
  }
  if (draft.sort !== DEFAULT_SORT) {
    nextParams.set('sort', draft.sort)
  }
  if (page > 1) {
    nextParams.set('page', String(page))
  }

  return nextParams
}

function createQueryState(searchParams: URLSearchParams): QuizSearchParams {
  const draft = createDraft(searchParams)
  const rawPage = Number.parseInt(searchParams.get('page') ?? '1', 10)

  return {
    title: draft.title || undefined,
    section: draft.section || undefined,
    status: draft.status,
    sort: draft.sort,
    page: Number.isNaN(rawPage) || rawPage < 1 ? 1 : rawPage,
  }
}

function getPaginationItems(currentPage: number, totalPages: number): (number | 'ellipsis')[] {
  if (totalPages <= 7) {
    return Array.from({ length: totalPages }, (_, index) => index + 1)
  }

  if (currentPage <= 4) {
    return [1, 2, 3, 4, 5, 'ellipsis', totalPages]
  }

  if (currentPage >= totalPages - 3) {
    return [1, 'ellipsis', totalPages - 4, totalPages - 3, totalPages - 2, totalPages - 1, totalPages]
  }

  return [1, 'ellipsis', currentPage - 1, currentPage, currentPage + 1, 'ellipsis', totalPages]
}

function StatusBadge({ status, onClick }: { status: Quiz['status']; onClick: () => void }) {
  if (status === 'published') {
    return (
      <button className="inline-flex rounded-full bg-[#10b981]/12 px-3 py-1 text-xs font-semibold text-[#047857] transition hover:bg-[#10b981]/22" onClick={onClick} type="button">
        公開
      </button>
    )
  }

  return (
    <button className="inline-flex rounded-full bg-[#94a3b8]/16 px-3 py-1 text-xs font-semibold text-[#475569] transition hover:bg-[#94a3b8]/28" onClick={onClick} type="button">
      非公開
    </button>
  )
}

function PushBadge({ pushEnabled, onClick }: { pushEnabled: boolean; onClick: () => void }) {
  if (pushEnabled) {
    return (
      <button className="inline-flex rounded-full bg-[#1768ac]/12 px-3 py-1 text-xs font-semibold text-[#0f4c81] transition hover:bg-[#1768ac]/22" onClick={onClick} type="button">
        ON
      </button>
    )
  }

  return (
    <button className="inline-flex rounded-full bg-[#94a3b8]/16 px-3 py-1 text-xs font-semibold text-[#475569] transition hover:bg-[#94a3b8]/28" onClick={onClick} type="button">
      OFF
    </button>
  )
}

function QuizListPage() {
  const [searchParams, setSearchParams] = useSearchParams()
  const [draft, setDraft] = useState<SearchDraft>(() => createDraft(searchParams))
  const searchKey = searchParams.toString()
  const [draftSearchKey, setDraftSearchKey] = useState(searchKey)
  if (searchKey !== draftSearchKey) {
    setDraftSearchKey(searchKey)
    setDraft(createDraft(searchParams))
  }
  const query = createQueryState(searchParams)
  const { quizzes, total, page, totalPages, error, errorMessage, isLoading, mutate } = useQuizzes(query)
  const [deleteErrorMessage, setDeleteErrorMessage] = useState<string | null>(null)
  const [quizToDelete, setQuizToDelete] = useState<Quiz | null>(null)
  const [isDeleting, setIsDeleting] = useState(false)
  const [isSyncingProduction, setIsSyncingProduction] = useState(false)
  const [pushDeliveries, setPushDeliveries] = useState<PushDelivery[]>([])
  const [isDispatchingPush, setIsDispatchingPush] = useState(false)
  const [isLoadingDeliveries, setIsLoadingDeliveries] = useState(true)
  const navigate = useNavigate()
  const { showFlash } = useFlash()

  useEffect(() => {
    if (error) {
      handleUnauthorized(error, navigate)
    }
  }, [error, navigate])

  const loadPushDeliveries = async () => {
    setIsLoadingDeliveries(true)
    try {
      const response = await fetchPushDeliveries()
      setPushDeliveries(response.items)
    } catch (err) {
      if (handleUnauthorized(err, navigate)) return
      showFlash(`Push配信履歴の取得に失敗しました: ${getErrorMessage(err)}`)
    } finally {
      setIsLoadingDeliveries(false)
    }
  }

  useEffect(() => {
    let cancelled = false

    const loadInitialDeliveries = async () => {
      try {
        const response = await fetchPushDeliveries()
        if (cancelled) {
          return
        }
        setPushDeliveries(response.items)
      } catch (err) {
        if (cancelled) {
          return
        }
        if (handleUnauthorized(err, navigate)) {
          return
        }
        showFlash(`Push配信履歴の取得に失敗しました: ${getErrorMessage(err)}`)
      } finally {
        if (!cancelled) {
          setIsLoadingDeliveries(false)
        }
      }
    }

    void loadInitialDeliveries()
    return () => {
      cancelled = true
    }
    // 初回表示時だけ履歴を読む。認証エラー処理のため navigate は依存に含める。
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [navigate])

  const handleFilterSubmit = (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault()
    setSearchParams(createQueryParams(draft))
  }

  const handleResetFilters = () => {
    setDraft({
      title: '',
      section: '',
      status: '',
      sort: DEFAULT_SORT,
    })
    setSearchParams(new URLSearchParams())
  }

  const handlePageChange = (nextPage: number) => {
    setSearchParams(createQueryParams(draft, nextPage))
  }

  const handleToggleStatus = async (quizId: number) => {
    try {
      await toggleQuizStatus(quizId)
      await mutate()
    } catch (err) {
      if (handleUnauthorized(err, navigate)) return
      showFlash(`ステータス変更に失敗しました: ${getErrorMessage(err)}`)
    }
  }

  const handleTogglePush = async (quizId: number) => {
    try {
      await toggleQuizPush(quizId)
      await mutate()
    } catch (err) {
      if (handleUnauthorized(err, navigate)) return
      showFlash(`PUSH設定変更に失敗しました: ${getErrorMessage(err)}`)
    }
  }

  const handleDeleteConfirm = async () => {
    if (!quizToDelete) {
      return
    }

    setIsDeleting(true)
    setDeleteErrorMessage(null)

    try {
      await deleteQuiz(quizToDelete.id)
      await mutate()
      showFlash(`ID ${quizToDelete.id} を削除しました。`)
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

  const handleSyncProduction = async () => {
    const shouldSync = window.confirm(
      'quizzes.json の published: true からマイグレーションを生成し、DB を完全同期します。シード対象にないクイズは削除されます。続行しますか？',
    )
    if (!shouldSync) {
      return
    }

    setIsSyncingProduction(true)
    try {
      const result = await syncProductionQuizzes()
      await mutate()
      showFlash(
        `migration ${result.migrationVersion} を生成・適用しました。反映 ${result.seededCount}件 / 削除 ${result.deletedCount}件 / up: ${result.upPath}`,
      )
    } catch (err) {
      if (handleUnauthorized(err, navigate)) return
      showFlash(getSyncProductionErrorMessage(err))
    } finally {
      setIsSyncingProduction(false)
    }
  }

  const handleDispatchMockPush = async () => {
    const shouldDispatch = window.confirm(
      'Push が ON かつ公開中のクイズから1件を選び、mock 配信履歴を作成します。続行しますか？',
    )
    if (!shouldDispatch) {
      return
    }

    setIsDispatchingPush(true)
    try {
      const result = await dispatchMockPush()
      await loadPushDeliveries()
      showFlash(`mock Push を送信しました: #${result.quizId} ${result.title}`)
    } catch (err) {
      if (handleUnauthorized(err, navigate)) return
      if (err instanceof ApiError && err.status === 422) {
        showFlash('送信候補がありません。公開中かつ Push ON のクイズを用意してください。')
        return
      }
      showFlash(`mock Push 送信に失敗しました: ${getErrorMessage(err)}`)
    } finally {
      setIsDispatchingPush(false)
    }
  }

  const paginationItems = getPaginationItems(page, totalPages)

  return (
    <>
      <section className="mb-6 flex flex-col gap-5 xl:flex-row xl:items-end xl:justify-between">
        <div>
          <p className="m-0 mb-2.5 text-[0.78rem] uppercase tracking-[0.18em] text-[#1768ac]">Quiz Inventory</p>
          <h2 className="m-0 text-[clamp(1.8rem,3vw,2.4rem)] font-semibold">クイズ一覧</h2>
          <p className="mt-3 mb-0 max-w-[700px] text-[#4f5d75]">
            検索、公開状態、PUSH 対象を横断で確認しながら問題データを管理します。
          </p>
        </div>

        <div className="flex flex-wrap gap-3">
          <button
            className={`${pillButtonClassName} border border-[#8b5e00]/20 bg-[#f9c952]/12 text-[#7a5a00] disabled:cursor-not-allowed disabled:opacity-55 disabled:hover:translate-y-0 disabled:hover:shadow-none`}
            disabled={isSyncingProduction}
            onClick={() => void handleSyncProduction()}
            type="button"
          >
            {isSyncingProduction ? 'DB反映中...' : 'quizzes.json を DB 反映'}
          </button>
          <button
            className={`${pillButtonClassName} border border-[#1768ac]/20 bg-[#1768ac]/10 text-[#0f4c81] disabled:cursor-not-allowed disabled:opacity-55 disabled:hover:translate-y-0 disabled:hover:shadow-none`}
            disabled={isDispatchingPush}
            onClick={() => void handleDispatchMockPush()}
            type="button"
          >
            {isDispatchingPush ? 'mock Push 送信中...' : 'mock Push 送信'}
          </button>
          <button
            className={`${pillButtonClassName} border border-navy/12 bg-white/92 text-navy`}
            onClick={() => void mutate()}
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

      <section className="mb-6 rounded-card border border-navy/12 bg-white/86 p-card shadow-card">
        <div className="mb-4 flex flex-col gap-3 md:flex-row md:items-center md:justify-between">
          <div>
            <h3 className="m-0 text-xl font-semibold text-navy">mock Push 配信履歴</h3>
            <p className="mt-2 mb-0 text-sm text-[#4f5d75]">
              Push が ON の公開クイズだけが送信候補です。mobile は最新履歴を `/v1/push/feed` から取得します。
            </p>
          </div>
          <button
            className={`${pillButtonClassName} border border-navy/12 bg-white/92 text-navy disabled:cursor-not-allowed disabled:opacity-55`}
            disabled={isLoadingDeliveries}
            onClick={() => void loadPushDeliveries()}
            type="button"
          >
            {isLoadingDeliveries ? '履歴読み込み中...' : '履歴を再読み込み'}
          </button>
        </div>

        {pushDeliveries.length === 0 ? (
          <p className="m-0 rounded-surface border border-dashed border-navy/16 p-4 text-[#4f5d75]">
            まだ mock Push 配信履歴はありません。
          </p>
        ) : (
          <div className="overflow-x-auto">
            <table className="min-w-full border-collapse">
              <thead>
                <tr className="bg-[#f8fafc] text-left text-[0.78rem] uppercase tracking-[0.08em] text-[#4f5d75]">
                  <th className="border-b border-navy/8 px-3 py-3 font-medium">Delivery</th>
                  <th className="border-b border-navy/8 px-3 py-3 font-medium">Quiz</th>
                  <th className="border-b border-navy/8 px-3 py-3 font-medium">Status</th>
                  <th className="border-b border-navy/8 px-3 py-3 font-medium">Target</th>
                  <th className="border-b border-navy/8 px-3 py-3 font-medium">Sent At</th>
                </tr>
              </thead>
              <tbody>
                {pushDeliveries.slice(0, 10).map((delivery) => (
                  <tr className="transition hover:bg-[#f8fafc]" key={delivery.deliveryId}>
                    <td className="border-b border-navy/8 px-3 py-3 font-semibold text-navy">#{delivery.deliveryId}</td>
                    <td className="border-b border-navy/8 px-3 py-3">
                      <div className="grid gap-1">
                        <strong>#{delivery.quizId} {delivery.title}</strong>
                        <span className="text-xs text-[#4f5d75]">{delivery.channel}</span>
                      </div>
                    </td>
                    <td className="border-b border-navy/8 px-3 py-3">{delivery.status}</td>
                    <td className="border-b border-navy/8 px-3 py-3">{delivery.targetCount}</td>
                    <td className="border-b border-navy/8 px-3 py-3 text-sm">{formatDateTime(delivery.sentAt)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </section>

      <section className="mb-6 rounded-card border border-navy/12 bg-white/86 p-card shadow-card">
        <form className="grid gap-4 lg:grid-cols-[minmax(0,1.4fr)_minmax(0,1fr)_220px_220px_auto]" onSubmit={handleFilterSubmit}>
          <label className="grid gap-2">
            <span className="text-sm font-semibold text-navy">タイトル</span>
            <input
              className="rounded-surface border border-navy/14 bg-white/92 px-4 py-3 text-navy"
              onChange={(event) => setDraft((current) => ({ ...current, title: event.target.value }))}
              placeholder="タイトルで部分一致"
              type="text"
              value={draft.title}
            />
          </label>

          <label className="grid gap-2">
            <span className="text-sm font-semibold text-navy">セクション</span>
            <input
              className="rounded-surface border border-navy/14 bg-white/92 px-4 py-3 text-navy"
              onChange={(event) => setDraft((current) => ({ ...current, section: event.target.value }))}
              placeholder="セクション名"
              type="text"
              value={draft.section}
            />
          </label>

          <label className="grid gap-2">
            <span className="text-sm font-semibold text-navy">公開状態</span>
            <select
              className="rounded-surface border border-navy/14 bg-white/92 px-4 py-3 text-navy"
              onChange={(event) =>
                setDraft((current) => ({
                  ...current,
                  status: event.target.value === 'published' || event.target.value === 'unpublished' ? event.target.value : '',
                }))
              }
              value={draft.status}
            >
              <option value="">すべて</option>
              <option value="published">公開</option>
              <option value="unpublished">非公開</option>
            </select>
          </label>

          <label className="grid gap-2">
            <span className="text-sm font-semibold text-navy">並び順</span>
            <select
              className="rounded-surface border border-navy/14 bg-white/92 px-4 py-3 text-navy"
              onChange={(event) =>
                setDraft((current) => ({
                  ...current,
                  sort: event.target.value as QuizSort,
                }))
              }
              value={draft.sort}
            >
              <option value="updated_newest">更新日時の新しい順</option>
              <option value="updated_oldest">更新日時の古い順</option>
              <option value="created_newest">作成日時の新しい順</option>
              <option value="created_oldest">作成日時の古い順</option>
            </select>
          </label>

          <div className="flex flex-wrap items-end gap-3">
            <button
              className={`${pillButtonClassName} bg-linear-to-br from-[#1768ac] to-[#0f4c81] text-white`}
              type="submit"
            >
              検索
            </button>
            <button
              className={`${pillButtonClassName} border border-navy/12 bg-white/92 text-navy`}
              onClick={handleResetFilters}
              type="button"
            >
              クリア
            </button>
          </div>
        </form>
      </section>

      <section className="rounded-card border border-navy/12 bg-white/86 p-card shadow-card">
        <div className="mb-stack flex flex-col gap-3 md:flex-row md:items-center md:justify-between">
          <span className="inline-flex w-fit items-center rounded-full bg-[#1768ac]/12 px-3.5 py-2.5 font-semibold text-[#0f4c81]">
            {total} quizzes
          </span>
          <span className="text-[#4f5d75]">
            {totalPages > 0 ? `${page} / ${totalPages} ページ` : '該当データなし'}
          </span>
        </div>

        {errorMessage ? (
          <div className="mb-stack flex flex-col gap-3 rounded-surface bg-[#b42318]/10 p-4 text-[#7a271a] md:flex-row md:items-center md:justify-between">
            <p className="m-0">{errorMessage}</p>
            <button
              className={`${pillButtonClassName} border border-navy/12 bg-white/92 text-navy`}
              onClick={() => void mutate()}
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
            <p className="m-0 text-[1.3rem] font-semibold text-navy">
              {total === 0 && (draft.title !== '' || draft.section !== '' || draft.status !== '')
                ? '条件に一致するクイズがありません'
                : 'まだクイズがありません'}
            </p>
            <p className="m-0 max-w-[520px] text-[#4f5d75]">
              {total === 0 && (draft.title !== '' || draft.section !== '' || draft.status !== '')
                ? '検索条件を変更するか、フィルターをクリアして再確認してください。'
                : '最初の1件を作成して、管理画面から編集フローを確認してください。'}
            </p>
            <div className="flex flex-wrap justify-center gap-3">
              <button
                className={`${pillButtonClassName} border border-navy/12 bg-white/92 text-navy`}
                onClick={handleResetFilters}
                type="button"
              >
                フィルターをクリア
              </button>
              <Link
                className={`${pillButtonClassName} bg-linear-to-br from-[#1768ac] to-[#0f4c81] text-white`}
                to="/quizzes/new"
              >
                クイズを作成
              </Link>
            </div>
          </div>
        ) : (
          <>
            <div className="overflow-x-auto">
              <table className="min-w-full border-collapse">
                <thead>
                  <tr className="bg-[#f8fafc] text-left text-[0.82rem] uppercase tracking-[0.08em] text-[#4f5d75]">
                    <th className="border-b border-navy/8 px-3 py-4 font-medium">ID</th>
                    <th className="border-b border-navy/8 px-3 py-4 font-medium">タイトル</th>
                    <th className="border-b border-navy/8 px-3 py-4 font-medium">セクション</th>
                    <th className="border-b border-navy/8 px-3 py-4 font-medium">出典</th>
                    <th className="border-b border-navy/8 px-3 py-4 font-medium">公開状態</th>
                    <th className="border-b border-navy/8 px-3 py-4 font-medium">PUSH</th>
                    <th className="border-b border-navy/8 px-3 py-4 font-medium">作成日時</th>
                    <th className="border-b border-navy/8 px-3 py-4 font-medium">更新日時</th>
                    <th className="border-b border-navy/8 px-3 py-4 font-medium">操作</th>
                  </tr>
                </thead>
                <tbody>
                  {quizzes.map((quiz) => (
                    <tr className="transition hover:bg-[#f8fafc]" key={quiz.id}>
                      <td className="border-b border-navy/8 px-3 py-4 align-top font-semibold text-navy">{quiz.id}</td>
                      <td className="border-b border-navy/8 px-3 py-4 align-top">
                        <div className="grid gap-1.5">
                          <strong>{quiz.title}</strong>
                          <span className="max-w-[320px] text-sm text-[#4f5d75]">{quiz.question}</span>
                        </div>
                      </td>
                      <td className="border-b border-navy/8 px-3 py-4 align-top">{quiz.section}</td>
                      <td className="border-b border-navy/8 px-3 py-4 align-top break-all text-sm">{quiz.source}</td>
                      <td className="border-b border-navy/8 px-3 py-4 align-top">
                        <StatusBadge onClick={() => void handleToggleStatus(quiz.id)} status={quiz.status} />
                      </td>
                      <td className="border-b border-navy/8 px-3 py-4 align-top">
                        <PushBadge onClick={() => void handleTogglePush(quiz.id)} pushEnabled={quiz.pushEnabled} />
                      </td>
                      <td className="border-b border-navy/8 px-3 py-4 align-top text-sm">{formatDateTime(quiz.createdAt)}</td>
                      <td className="border-b border-navy/8 px-3 py-4 align-top text-sm">{formatDateTime(quiz.updatedAt)}</td>
                      <td className="border-b border-navy/8 px-3 py-4 align-top">
                        <div className="flex min-w-[160px] flex-wrap gap-2.5">
                          <Link
                            className={`${pillButtonClassName} border border-navy/12 bg-white/92 text-navy`}
                            to={`/quizzes/${quiz.id}/edit`}
                          >
                            編集
                          </Link>
                          <button
                            className={`${pillButtonClassName} border border-[#b42318]/12 bg-[#b42318]/10 text-[#7a271a]`}
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

            {totalPages > 1 ? (
              <div className="mt-6 flex flex-wrap items-center justify-between gap-4">
                <p className="m-0 text-sm text-[#4f5d75]">
                  {Math.min((page - 1) * 20 + 1, total)} - {Math.min(page * 20, total)} / {total} 件
                </p>
                <nav aria-label="クイズ一覧ページネーション" className="flex flex-wrap items-center gap-2">
                  <button
                    className={`${pillButtonClassName} border border-navy/12 bg-white/92 px-3 py-2 text-navy disabled:cursor-not-allowed disabled:opacity-45 disabled:hover:translate-y-0 disabled:hover:shadow-none`}
                    disabled={page <= 1}
                    onClick={() => handlePageChange(page - 1)}
                    type="button"
                  >
                    前へ
                  </button>
                  {paginationItems.map((item, index) =>
                    item === 'ellipsis' ? (
                      <span className="px-2 text-[#4f5d75]" key={`ellipsis-${index}`}>
                        ...
                      </span>
                    ) : (
                      <button
                        className={
                          item === page
                            ? `${pillButtonClassName} bg-linear-to-br from-[#1768ac] to-[#0f4c81] px-3 py-2 text-white`
                            : `${pillButtonClassName} border border-navy/12 bg-white/92 px-3 py-2 text-navy`
                        }
                        key={item}
                        onClick={() => handlePageChange(item)}
                        type="button"
                      >
                        {item}
                      </button>
                    ),
                  )}
                  <button
                    className={`${pillButtonClassName} border border-navy/12 bg-white/92 px-3 py-2 text-navy disabled:cursor-not-allowed disabled:opacity-45 disabled:hover:translate-y-0 disabled:hover:shadow-none`}
                    disabled={page >= totalPages}
                    onClick={() => handlePageChange(page + 1)}
                    type="button"
                  >
                    次へ
                  </button>
                </nav>
              </div>
            ) : null}
          </>
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
        quiz={quizToDelete}
      />
    </>
  )
}

export default QuizListPage
