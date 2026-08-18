import { useState, type FormEvent } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { createMemberSession, fetchMe, registerMember } from '../api/member';
import { useMemberSession } from '../contexts/MemberSessionContext';

const inputClassName =
  'w-full rounded-surface border border-navy/12 bg-white/90 px-4 py-2.5 text-navy focus:outline-none focus:ring-2 focus:ring-accent/40';

const buttonClassName =
  'inline-flex items-center justify-center rounded-full bg-linear-to-br from-accent to-accent-strong px-5 py-3 text-sm font-semibold text-white transition hover:-translate-y-0.5 hover:shadow-float disabled:cursor-not-allowed disabled:opacity-55 disabled:hover:translate-y-0 disabled:hover:shadow-none';

function MemberRegisterPage() {
  const { setSession } = useMemberSession();
  const navigate = useNavigate();
  const [handle, setHandle] = useState('');
  const [password, setPassword] = useState('');
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setErrorMessage(null);
    setIsSubmitting(true);
    try {
      await registerMember({ handle, password });
      const { token } = await createMemberSession(handle, password);
      const me = await fetchMe({ token });
      setSession({ token, memberId: me.id, handle: me.handle });
      navigate('/me', { replace: true });
    } catch (error) {
      const message = error instanceof Error ? error.message : '登録に失敗しました';
      setErrorMessage(message);
    } finally {
      setIsSubmitting(false);
    }
  }

  return (
    <div className="mx-auto grid max-w-[420px] gap-6">
      <section className="grid gap-2">
        <p className="m-0 text-[0.78rem] uppercase tracking-[0.18em] text-accent">Account</p>
        <h1 className="m-0 text-[clamp(1.4rem,2.4vw,1.8rem)] font-semibold">会員登録</h1>
        <p className="m-0 text-sm text-[#4f5d75]">
          ハンドル名とパスワードだけで登録できます。メールアドレスは保存しません。
        </p>
      </section>

      <form className="grid gap-4 rounded-card border border-navy/12 bg-white/86 p-card shadow-card" onSubmit={handleSubmit}>
        <label className="grid gap-1.5 text-sm font-medium text-navy">
          ハンドル名
          <input
            className={inputClassName}
            type="text"
            name="handle"
            autoComplete="username"
            minLength={3}
            maxLength={32}
            pattern="[a-zA-Z0-9_]+"
            required
            value={handle}
            onChange={(e) => setHandle(e.target.value)}
          />
          <span className="text-xs text-[#4f5d75]">3〜32 文字。英数字と `_` のみ。</span>
        </label>

        <label className="grid gap-1.5 text-sm font-medium text-navy">
          パスワード
          <input
            className={inputClassName}
            type="password"
            name="password"
            autoComplete="new-password"
            minLength={8}
            maxLength={128}
            required
            value={password}
            onChange={(e) => setPassword(e.target.value)}
          />
          <span className="text-xs text-[#4f5d75]">8 文字以上。忘れても再発行はできません（別 ADR 予定）。</span>
        </label>

        {errorMessage !== null ? (
          <p className="m-0 rounded-surface border border-incorrect/16 bg-incorrect-bg px-3 py-2 text-sm text-incorrect" role="alert">
            {errorMessage}
          </p>
        ) : null}

        <button className={buttonClassName} type="submit" disabled={isSubmitting}>
          {isSubmitting ? '登録中...' : '登録してログイン'}
        </button>

        <p className="m-0 text-center text-sm text-[#4f5d75]">
          すでに登録済み? <Link to="/login" className="font-semibold text-accent hover:underline">ログイン</Link>
        </p>
      </form>
    </div>
  );
}

export default MemberRegisterPage;
