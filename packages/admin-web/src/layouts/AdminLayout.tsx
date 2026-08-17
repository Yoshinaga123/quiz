import { NavLink, Outlet, useNavigate } from 'react-router-dom'
import { clearAuthToken } from '../auth/session'
import ViewCounter from '../components/ViewCounter'
import { useFlash } from '../contexts/FlashContext'

const navLinkBaseClassName =
  'inline-flex items-center justify-center rounded-full px-4 py-3 text-sm font-medium transition duration-150 hover:-translate-y-0.5 hover:shadow-[0_12px_24px_rgba(20,33,61,0.12)]'

function AdminLayout() {
  const navigate = useNavigate()
  const { message, clearFlash } = useFlash()

  const handleLogout = () => {
    clearAuthToken()
    navigate('/login', { replace: true })
  }

  return (
    <>
      <header className="sticky top-0 z-10 border-b border-[#14213d]/8 bg-[#fffaf0]/78 backdrop-blur-[18px]">
        <div className="mx-auto w-full max-w-[1600px] px-4 py-5 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between gap-4">
            <p className="m-0 text-[0.78rem] uppercase tracking-[0.18em] text-[#1768ac]">Admin Console</p>
            <ViewCounter />
          </div>

          <div className="mt-[18px] flex flex-col gap-4 md:flex-row md:items-center md:justify-between">
            <nav className="flex flex-wrap gap-2.5">
              <NavLink
                className={({ isActive }) =>
                  isActive
                    ? `${navLinkBaseClassName} bg-linear-to-br from-[#1768ac] to-[#0f4c81] text-white shadow-[0_14px_28px_rgba(23,104,172,0.24)]`
                    : `${navLinkBaseClassName} border border-[#14213d]/12 bg-white/80 text-[#14213d]`
                }
                end
                to="/quizzes"
              >
                一覧
              </NavLink>
              <NavLink
                className={({ isActive }) =>
                  isActive
                    ? `${navLinkBaseClassName} bg-linear-to-br from-[#1768ac] to-[#0f4c81] text-white shadow-[0_14px_28px_rgba(23,104,172,0.24)]`
                    : `${navLinkBaseClassName} border border-[#14213d]/12 bg-white/80 text-[#14213d]`
                }
                to="/quizzes/new"
              >
                新規作成
              </NavLink>
            </nav>

            <button
              className={`${navLinkBaseClassName} bg-[#14213d]/8 text-[#14213d]`}
              onClick={handleLogout}
              type="button"
            >
              ログアウト
            </button>
          </div>
        </div>
      </header>

      <main className="mx-auto w-full max-w-[1600px] px-4 py-7 pb-14 sm:px-6 lg:px-8">
        {message ? (
          <div className="mb-5 flex items-start justify-between gap-4 rounded-card border border-[#1768ac]/16 bg-[#1768ac]/8 px-4 py-3.5 text-[#0f4c81] shadow-[0_12px_24px_rgba(23,104,172,0.12)]">
            <p className="m-0 font-medium">{message}</p>
            <button
              className="inline-flex shrink-0 items-center justify-center rounded-full border border-[#1768ac]/14 bg-white/80 px-3 py-1.5 text-sm font-medium text-[#0f4c81]"
              onClick={clearFlash}
              type="button"
            >
              閉じる
            </button>
          </div>
        ) : null}
        <Outlet />
      </main>
    </>
  )
}

export default AdminLayout
