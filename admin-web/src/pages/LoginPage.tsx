import { type FormEvent, useState } from 'react'
import { Navigate, useLocation, useNavigate } from 'react-router-dom'
import { login } from '../api/admin'
import { getErrorMessage } from '../api/errors'
import { getAuthToken, setAuthToken } from '../auth/session'
import { loginRequestSchema } from '../schemas/auth'
import type { LoginCredentials } from '../types/admin'

interface LoginLocationState {
  from?: string
}

const initialCredentials: LoginCredentials = {
  username: '',
  password: '',
}

const inputClassName =
  'w-full rounded-[16px] border border-[#14213d]/14 bg-white/96 px-4 py-[15px] text-[#14213d] transition focus:border-[#1768ac]/50 focus:outline-none focus:ring-4 focus:ring-[#1768ac]/16'

function LoginPage() {
  const [credentials, setCredentials] = useState<LoginCredentials>(initialCredentials)
  const [errorMessage, setErrorMessage] = useState<string | null>(null)
  const [isSubmitting, setIsSubmitting] = useState(false)
  const location = useLocation()
  const navigate = useNavigate()

  if (getAuthToken()) {
    return <Navigate replace to="/quizzes" />
  }

  const nextPath =
    typeof location.state === 'object' &&
    location.state !== null &&
    'from' in location.state &&
    typeof (location.state as LoginLocationState).from === 'string'
      ? (location.state as LoginLocationState).from ?? '/quizzes'
      : '/quizzes'

  const handleSubmit = async (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault()
    setErrorMessage(null)

    const parsed = loginRequestSchema.safeParse(credentials)
    if (!parsed.success) {
      setErrorMessage(parsed.error.issues[0]?.message ?? '入力内容を確認してください')
      return
    }

    setIsSubmitting(true)

    try {
      const token = await login(parsed.data)
      setAuthToken(token)
      navigate(nextPath, { replace: true })
    } catch (error) {
      setErrorMessage(getErrorMessage(error))
    } finally {
      setIsSubmitting(false)
    }
  }

  return (
    <main className="grid min-h-screen place-items-center p-6">
      <section className="w-full max-w-[480px] rounded-[28px] border border-[#14213d]/12 bg-linear-to-br from-white/96 to-[#fffaf0]/92 p-[clamp(28px,5vw,40px)] shadow-[0_22px_48px_rgba(20,33,61,0.12)]">
        <div className="mb-7 grid gap-2.5">
          <p className="m-0 text-[0.78rem] uppercase tracking-[0.18em] text-[#1768ac]">Quiz Admin</p>
          <h1 className="m-0 text-[clamp(2.1rem,5vw,3rem)] leading-[1.02] font-semibold">クイズ管理画面</h1>
          <p className="m-0 text-[#4f5d75]">
            管理者ログイン後に、問題データの追加・編集・削除を行えます。API 側の開発デフォルト認証情報は
            `admin / password` です。
          </p>
        </div>

        {errorMessage ? (
          <p className="mb-[18px] rounded-[10px] bg-[#b42318]/10 px-4 py-3.5 text-[#7a271a]">{errorMessage}</p>
        ) : null}

        <form className="grid gap-4" onSubmit={handleSubmit}>
          <label className="grid gap-2.5">
            <span className="font-semibold">ユーザー名</span>
            <input
              autoComplete="username"
              className={inputClassName}
              onChange={(event) =>
                setCredentials((current) => ({
                  ...current,
                  username: event.target.value,
                }))
              }
              placeholder="admin"
              type="text"
              value={credentials.username}
            />
          </label>

          <label className="grid gap-2.5">
            <span className="font-semibold">パスワード</span>
            <input
              autoComplete="current-password"
              className={inputClassName}
              onChange={(event) =>
                setCredentials((current) => ({
                  ...current,
                  password: event.target.value,
                }))
              }
              placeholder="password"
              type="password"
              value={credentials.password}
            />
          </label>

          <button
            className="mt-2 inline-flex items-center justify-center rounded-full bg-linear-to-br from-[#1768ac] to-[#0f4c81] px-[18px] py-3.5 text-white transition duration-150 hover:-translate-y-0.5 hover:shadow-[0_14px_28px_rgba(23,104,172,0.22)] disabled:cursor-progress disabled:opacity-60 disabled:hover:translate-y-0 disabled:hover:shadow-none"
            disabled={isSubmitting}
            type="submit"
          >
            {isSubmitting ? 'ログイン中...' : 'ログイン'}
          </button>
        </form>
      </section>
    </main>
  )
}

export default LoginPage
