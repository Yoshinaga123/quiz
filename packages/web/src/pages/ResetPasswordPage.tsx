import { useState, type FormEvent } from 'react';
import { Link, useNavigate, useSearchParams } from 'react-router-dom';
import { consumePasswordReset } from '../api/member';
import { passwordResetConsumeRequestSchema } from '../schemas/member';

const inputClassName =
  'w-full rounded-surface border border-navy/12 bg-white/90 px-4 py-2.5 text-navy focus:outline-none focus:ring-2 focus:ring-accent/40';

const buttonClassName =
  'inline-flex items-center justify-center rounded-full bg-linear-to-br from-accent to-accent-strong px-5 py-3 text-sm font-semibold text-white transition hover:-translate-y-0.5 hover:shadow-float disabled:cursor-not-allowed disabled:opacity-55 disabled:hover:translate-y-0 disabled:hover:shadow-none';

function ResetPasswordPage() {
  const [params] = useSearchParams();
  const token = params.get('token') ?? '';
  const navigate = useNavigate();
  const [newPassword, setNewPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setErrorMessage(null);
    if (token === '') {
      setErrorMessage('URL に再設定トークンが含まれていません。メールのリンクを再度確認してください。');
      return;
    }
    if (newPassword !== confirmPassword) {
      setErrorMessage('新しいパスワードと確認用パスワードが一致しません');
      return;
    }
    const parsed = passwordResetConsumeRequestSchema.safeParse({ newPassword });
    if (!parsed.success) {
      setErrorMessage('パスワードは 8-128 文字で入力してください');
      return;
    }
    setIsSubmitting(true);
    try {
      await consumePasswordReset(token, parsed.data);
      navigate('/login', {
        replace: true,
        state: { notice: 'パスワードを再設定しました。新しいパスワードでログインしてください。' },
      });
    } catch (error) {
      setErrorMessage(
        error instanceof Error
          ? error.message
          : 'パスワードの再設定に失敗しました。リンクの有効期限が切れているか、既に使用済みの可能性があります。',
      );
      setIsSubmitting(false);
    }
  }

  return (
    <div className="mx-auto grid max-w-[420px] gap-6">
      <section className="grid gap-2">
        <p className="m-0 text-[0.78rem] uppercase tracking-[0.18em] text-accent">Account</p>
        <h1 className="m-0 text-[clamp(1.4rem,2.4vw,1.8rem)] font-semibold">パスワードの再設定</h1>
      </section>

      <form className="grid gap-4 rounded-card border border-navy/12 bg-white/86 p-card shadow-card" onSubmit={handleSubmit}>
        <label className="grid gap-1.5 text-sm font-medium text-navy">
          新しいパスワード（8-128 文字）
          <input
            className={inputClassName}
            type="password"
            name="newPassword"
            autoComplete="new-password"
            minLength={8}
            maxLength={128}
            required
            value={newPassword}
            onChange={(e) => setNewPassword(e.target.value)}
          />
        </label>

        <label className="grid gap-1.5 text-sm font-medium text-navy">
          新しいパスワード（確認用）
          <input
            className={inputClassName}
            type="password"
            name="confirmPassword"
            autoComplete="new-password"
            minLength={8}
            maxLength={128}
            required
            value={confirmPassword}
            onChange={(e) => setConfirmPassword(e.target.value)}
          />
        </label>

        {errorMessage !== null ? (
          <p className="m-0 rounded-surface border border-incorrect/16 bg-incorrect-bg px-3 py-2 text-sm text-incorrect" role="alert">
            {errorMessage}
          </p>
        ) : null}

        <button className={buttonClassName} type="submit" disabled={isSubmitting || token === ''}>
          {isSubmitting ? '更新中...' : 'パスワードを更新'}
        </button>

        <p className="m-0 text-center text-sm text-[#4f5d75]">
          <Link to="/login" className="font-semibold text-accent hover:underline">
            ログインに戻る
          </Link>
        </p>
      </form>
    </div>
  );
}

export default ResetPasswordPage;
