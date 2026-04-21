import { useEffect } from 'react'
import { Link } from 'react-router-dom'

const pillButtonClassName =
  'inline-flex items-center justify-center rounded-full px-5 py-3 text-sm font-semibold transition duration-150 hover:-translate-y-0.5 hover:shadow-float'

function NotFoundPage() {
  useEffect(() => {
    /*
     * Search Central 準拠ポリシー（docs/implement-policy.md ポリシー5）に従い、
     * クライアント側で 404 ステータスを返せない代替として noindex を伝える。
     */
    const meta = document.createElement('meta')
    meta.name = 'robots'
    meta.content = 'noindex'
    document.head.append(meta)
    return () => {
      meta.remove()
    }
  }, [])

  return (
    <div className="grid min-h-[60vh] place-items-center">
      <div className="grid max-w-[520px] gap-3 rounded-card border border-navy/12 bg-white/90 p-card text-center shadow-card">
        <p className="m-0 text-[0.78rem] uppercase tracking-[0.18em] text-accent">404</p>
        <h1 className="m-0 text-[1.6rem] font-semibold">ページが見つかりません</h1>
        <p className="m-0 text-[#4f5d75]">
          URL が変更されたか、削除された可能性があります。
        </p>
        <div className="mt-2 flex flex-wrap justify-center gap-3">
          <Link to="/" className={`${pillButtonClassName} bg-linear-to-br from-accent to-accent-strong text-white`}>
            ホームへ戻る
          </Link>
          <Link to="/history" className={`${pillButtonClassName} border border-navy/12 bg-white/90 text-navy`}>
            履歴を見る
          </Link>
        </div>
      </div>
    </div>
  )
}

export default NotFoundPage
