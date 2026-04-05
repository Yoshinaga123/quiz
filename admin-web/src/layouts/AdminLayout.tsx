import { NavLink, Outlet, useNavigate } from 'react-router-dom'
import { clearAuthToken } from '../auth/session'

const navLinkBaseClassName =
  'inline-flex items-center justify-center rounded-full px-4 py-3 text-sm font-medium transition duration-150 hover:-translate-y-0.5 hover:shadow-[0_12px_24px_rgba(20,33,61,0.12)]'

function AdminLayout() {
  const navigate = useNavigate()

  const handleLogout = () => {
    clearAuthToken()
    navigate('/login', { replace: true })
  }

  return (
    <div className="min-h-screen">
      <header className="sticky top-0 z-10 border-b border-[#14213d]/8 bg-[#fffaf0]/78 backdrop-blur-[18px]">
        <div className="mx-auto w-full max-w-[1200px] px-4 py-5 sm:px-6 lg:px-8">
          <div className="grid gap-2">
            <p className="m-0 text-[0.78rem] uppercase tracking-[0.18em] text-[#1768ac]">Admin Console</p>
            <h1 className="m-0 text-[clamp(1.8rem,3vw,2.8rem)] leading-[1.04] font-semibold">
              Quiz Operations Desk
            </h1>
            <p className="m-0 max-w-[720px] text-[#4f5d75]">
              問題データの品質を保ちながら、一覧・作成・編集・削除をひと通り回せる管理画面です。
            </p>
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

      <main className="mx-auto w-full max-w-[1200px] px-4 py-7 pb-14 sm:px-6 lg:px-8">
        <Outlet />
      </main>
    </div>
  )
}

export default AdminLayout
