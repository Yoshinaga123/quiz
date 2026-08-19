import { useState, type FormEvent } from 'react';
import { Link, useLocation, useNavigate } from 'react-router-dom';
import { createMemberSession, fetchMe } from '../api/member';
import { useMemberSession } from '../contexts/MemberSessionContext';

const inputClassName =
  'w-full rounded-surface border border-navy/12 bg-white/90 px-4 py-2.5 text-navy focus:outline-none focus:ring-2 focus:ring-accent/40';

const buttonClassName =
  'inline-flex items-center justify-center rounded-full bg-linear-to-br from-accent to-accent-strong px-5 py-3 text-sm font-semibold text-white transition hover:-translate-y-0.5 hover:shadow-float disabled:cursor-not-allowed disabled:opacity-55 disabled:hover:translate-y-0 disabled:hover:shadow-none';

function MemberLoginPage() {
  const { setSession } = useMemberSession();
  const navigate = useNavigate();
  const location = useLocation();
  const notice =
    typeof (location.state as { notice?: unknown } | null)?.notice === 'string'
      ? (location.state as { notice: string }).notice
      : null;
  const [handle, setHandle] = useState('');
  const [password, setPassword] = useState('');
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setErrorMessage(null);
    setIsSubmitting(true);
    try {
      const { token } = await createMemberSession(handle, password);
      const me = await fetchMe({ token });
      setSession({ token, memberId: me.id, handle: me.handle });
      navigate('/me', { replace: true });
    } catch (error) {
      const message = error instanceof Error ? error.message : 'ログインに失敗しました';
      setErrorMessage(message);
    } finally {
      setIsSubmitting(false);
    }
  }

  return (
    <div className="mx-auto grid max-w-[420px] gap-6">
      <section className="grid gap-2">
        <p className="m-0 text-[0.78rem] uppercase tracking-[0.18em] text-accent">Account</p>
        <h1 className="m-0 text-[clamp(1.4rem,2.4vw,1.8rem)] font-semibold">ログイン</h1>
      </section>

      <form className="grid gap-4 rounded-card border border-navy/12 bg-white/86 p-card shadow-card" onSubmit={handleSubmit}>
        <label className="grid gap-1.5 text-sm font-medium text-navy">
          ハンドル名
          <input
            className={inputClassName}
            type="text"
            name="handle"
            autoComplete="username"
            required
            value={handle}
            onChange={(e) => setHandle(e.target.value)}
          />
        </label>

        <label className="grid gap-1.5 text-sm font-medium text-navy">
          パスワード
          <input
            className={inputClassName}
            type="password"
            name="password"
            autoComplete="current-password"
            required
            value={password}
            onChange={(e) => setPassword(e.target.value)}
          />
        </label>

        {errorMessage !== null ? (
          <p className="m-0 rounded-surface border border-incorrect/16 bg-incorrect-bg px-3 py-2 text-sm text-incorrect" role="alert">
            {errorMessage}
          </p>
        ) : null}

        {notice !== null ? (
          <p className="m-0 rounded-surface border border-correct/16 bg-correct-bg px-3 py-2 text-sm text-correct" role="status">
            {notice}
          </p>
        ) : null}

        <button className={buttonClassName} type="submit" disabled={isSubmitting}>
          {isSubmitting ? '確認中...' : 'ログイン'}
        </button>

        <p className="m-0 text-center text-sm text-[#4f5d75]">
          未登録? <Link to="/register" className="font-semibold text-accent hover:underline">会員登録</Link>
        </p>
        <p className="m-0 text-center text-sm text-[#4f5d75]">
          <Link to="/forgot-password" className="font-semibold text-accent hover:underline">
            パスワードを忘れた場合
          </Link>
        </p>
      </form>
    </div>
  );
}

export default MemberLoginPage;
