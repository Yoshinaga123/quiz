import { useEffect, useState } from 'react'
import { NavLink, Outlet } from 'react-router-dom'
import { useMemberSession } from '../contexts/MemberSessionContext'

const navLinkBaseClassName =
  'inline-flex items-center justify-center rounded-full px-4 py-2.5 text-sm font-medium transition duration-150 hover:-translate-y-0.5 hover:shadow-float'

interface BannerNotice {
  id: number
  message: string
}

function AppLayout() {
  const [notice, setNotice] = useState<BannerNotice | null>(null)
  const { session } = useMemberSession()

  useEffect(() => {
    function pushNotice(event: Event) {
      const detail = (event as CustomEvent<{ message: string }>).detail
      if (typeof detail?.message !== 'string') return
      setNotice({ id: Date.now(), message: detail.message })
    }

    window.addEventListener('quzzes:history:corrupted', pushNotice)
    window.addEventListener('quzzes:history:persist-failed', pushNotice)
    return () => {
      window.removeEventListener('quzzes:history:corrupted', pushNotice)
      window.removeEventListener('quzzes:history:persist-failed', pushNotice)
    }
  }, [])

  return (
    <>
      <header className="sticky top-0 z-10 border-b border-navy/8 bg-[#fffaf0]/80 backdrop-blur-[18px]">
        <div className="mx-auto w-full max-w-[1100px] px-4 py-5 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between gap-4">
            <NavLink to="/" className="flex items-baseline gap-3">
              <span className="text-[1.15rem] font-bold tracking-wide text-navy">quzzes</span>
              <span className="text-[0.75rem] uppercase tracking-[0.18em] text-accent">IT Quiz Web</span>
            </NavLink>
            <nav className="flex flex-wrap gap-2">
              <NavLink
                end
                to="/"
                className={({ isActive }) =>
                  isActive
                    ? `${navLinkBaseClassName} bg-linear-to-br from-accent to-accent-strong text-white`
                    : `${navLinkBaseClassName} border border-navy/12 bg-white/80 text-navy`
                }
              >
                ホーム
              </NavLink>
              <NavLink
                to="/history"
                className={({ isActive }) =>
                  isActive
                    ? `${navLinkBaseClassName} bg-linear-to-br from-accent to-accent-strong text-white`
                    : `${navLinkBaseClassName} border border-navy/12 bg-white/80 text-navy`
                }
              >
                履歴
              </NavLink>
              {session === null ? (
                <NavLink
                  to="/login"
                  className={({ isActive }) =>
                    isActive
                      ? `${navLinkBaseClassName} bg-linear-to-br from-accent to-accent-strong text-white`
                      : `${navLinkBaseClassName} border border-navy/12 bg-white/80 text-navy`
                  }
                >
                  ログイン
                </NavLink>
              ) : (
                <NavLink
                  to="/me"
                  className={({ isActive }) =>
                    isActive
                      ? `${navLinkBaseClassName} bg-linear-to-br from-accent to-accent-strong text-white`
                      : `${navLinkBaseClassName} border border-navy/12 bg-white/80 text-navy`
                  }
                >
                  {session.handle}
                </NavLink>
              )}
            </nav>
          </div>
        </div>
      </header>

      <main className="mx-auto w-full max-w-[1100px] px-4 py-8 pb-16 sm:px-6 lg:px-8">
        {notice ? (
          <div
            key={notice.id}
            className="mb-5 flex items-start justify-between gap-4 rounded-card border border-incorrect/16 bg-incorrect-bg px-4 py-3.5 text-incorrect shadow-float"
            role="alert"
          >
            <p className="m-0 font-medium">{notice.message}</p>
            <button
              type="button"
              className="inline-flex shrink-0 items-center justify-center rounded-full border border-incorrect/14 bg-white/80 px-3 py-1.5 text-sm font-medium text-incorrect"
              onClick={() => setNotice(null)}
            >
              閉じる
            </button>
          </div>
        ) : null}

        <Outlet />
      </main>

      <footer className="border-t border-navy/8 bg-white/40">
        <div className="mx-auto w-full max-w-[1100px] px-4 py-6 text-sm text-[#4f5d75] sm:px-6 lg:px-8">
          <p className="m-0">
            問題は MDN Web Docs / React 公式 / RFC など一次情報からの引用に基づく。詳細な出典は各クイズの「出典」を参照。
          </p>
        </div>
      </footer>
    </>
  )
}

export default AppLayout
