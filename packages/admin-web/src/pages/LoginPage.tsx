import { type FormEvent, useState } from 'react'
import { Navigate, useLocation, useNavigate } from 'react-router-dom'
import { login, requestLoginVerification } from '../api/admin'
import { getErrorMessage } from '../api/errors'
import { getAuthToken, setAuthToken } from '../auth/session'
import { loginRequestSchema, loginVerificationSchema } from '../schemas/auth'
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
const verificationMessage =
  'quzzesアカウントの安全性を確保するために、IDを確認する必要があります。確認コードを送信してください。'

function LoginPage() {
  const [credentials, setCredentials] = useState<LoginCredentials>(initialCredentials)
  const [errorMessage, setErrorMessage] = useState<string | null>(null)
  const [infoMessage, setInfoMessage] = useState<string | null>(null)
  const [isSubmitting, setIsSubmitting] = useState(false)
  const [stage, setStage] = useState<'credentials' | 'code'>('credentials')
  const [challengeId, setChallengeId] = useState<string | null>(null)
  const [verificationCode, setVerificationCode] = useState('')
  const [devCode, setDevCode] = useState<string | null>(null)
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

    if (stage === 'credentials') {
      const parsed = loginRequestSchema.safeParse(credentials)
      if (!parsed.success) {
        setErrorMessage(parsed.error.issues[0]?.message ?? '入力内容を確認してください')
        return
      }

      setIsSubmitting(true)
      try {
        const result = await requestLoginVerification(parsed.data)
        setChallengeId(result.challengeId)
        setStage('code')
        setInfoMessage(result.message)
        setDevCode(result.code ?? null)
        setVerificationCode('')
      } catch (error) {
        setErrorMessage(getErrorMessage(error))
      } finally {
        setIsSubmitting(false)
      }
      return
    }

    const parsed = loginVerificationSchema.safeParse({
      ...credentials,
      challengeId: challengeId ?? '',
      verificationCode,
    })
    if (!parsed.success) {
      setErrorMessage(parsed.error.issues[0]?.message ?? '確認コードを入力してください')
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

  const handleResendCode = async () => {
    setErrorMessage(null)
    const parsed = loginRequestSchema.safeParse(credentials)
    if (!parsed.success) {
      setErrorMessage(parsed.error.issues[0]?.message ?? '入力内容を確認してください')
      return
    }
    setIsSubmitting(true)
    try {
      const result = await requestLoginVerification(parsed.data)
      setChallengeId(result.challengeId)
      setInfoMessage(result.message)
      setDevCode(result.code ?? null)
      setVerificationCode('')
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
            管理者ログイン後に、問題データの追加・編集・削除を行えます。管理者から提供された認証情報を入力してください。
          </p>
        </div>

        {errorMessage ? (
          <p className="mb-[18px] rounded-[10px] bg-[#b42318]/10 px-4 py-3.5 text-[#7a271a]">{errorMessage}</p>
        ) : null}
        {infoMessage ? (
          <p className="mb-[18px] rounded-[10px] bg-[#16a34a]/10 px-4 py-3.5 text-[#166534]">{infoMessage}</p>
        ) : null}
        {devCode ? (
          <p className="mb-[18px] rounded-[10px] bg-[#fef3c7] px-4 py-3.5 text-[#92400e]">
            開発用確認コード: <span className="font-semibold">{devCode}</span>
          </p>
        ) : null}
        {stage === 'code' ? (
          <p className="mb-[18px] rounded-[10px] bg-[#1768ac]/10 px-4 py-3.5 text-[#0f4c81]">{verificationMessage}</p>
        ) : null}

        <form className="grid gap-4" onSubmit={handleSubmit}>
          <label className="grid gap-2.5">
            <span className="font-semibold">ユーザー名</span>
            <input
              autoComplete="username"
              className={inputClassName}
              disabled={stage === 'code'}
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
              disabled={stage === 'code'}
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

          {stage === 'code' ? (
            <label className="grid gap-2.5">
              <span className="font-semibold">確認コード</span>
              <input
                autoComplete="one-time-code"
                className={inputClassName}
                onChange={(event) => setVerificationCode(event.target.value)}
                placeholder="123456"
                type="text"
                value={verificationCode}
              />
            </label>
          ) : null}

          <button
            className="mt-2 inline-flex items-center justify-center rounded-full bg-linear-to-br from-[#1768ac] to-[#0f4c81] px-[18px] py-3.5 text-white transition duration-150 hover:-translate-y-0.5 hover:shadow-[0_14px_28px_rgba(23,104,172,0.22)] disabled:cursor-progress disabled:opacity-60 disabled:hover:translate-y-0 disabled:hover:shadow-none"
            disabled={isSubmitting}
            type="submit"
          >
            {isSubmitting
              ? '処理中...'
              : stage === 'credentials'
                ? '確認コードを送信'
                : '確認してログイン'}
          </button>

          {stage === 'code' ? (
            <button
              className="inline-flex items-center justify-center rounded-full border border-[#1768ac]/30 px-[18px] py-3.5 text-[#1768ac]"
              disabled={isSubmitting}
              onClick={(event) => {
                event.preventDefault()
                void handleResendCode()
              }}
              type="button"
            >
              確認コードを再送
            </button>
          ) : null}
        </form>
      </section>
    </main>
  )
}

export default LoginPage
