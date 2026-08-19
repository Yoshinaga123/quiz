import { useState, type FormEvent } from 'react';
import { Link } from 'react-router-dom';
import { requestPasswordReset } from '../api/member';
import { passwordResetRequestSchema } from '../schemas/member';

const inputClassName =
  'w-full rounded-surface border border-navy/12 bg-white/90 px-4 py-2.5 text-navy focus:outline-none focus:ring-2 focus:ring-accent/40';

const buttonClassName =
  'inline-flex items-center justify-center rounded-full bg-linear-to-br from-accent to-accent-strong px-5 py-3 text-sm font-semibold text-white transition hover:-translate-y-0.5 hover:shadow-float disabled:cursor-not-allowed disabled:opacity-55 disabled:hover:translate-y-0 disabled:hover:shadow-none';

function ForgotPasswordPage() {
  const [handleOrEmail, setHandleOrEmail] = useState('');
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  // ADR 0018 §3: 常に 202 を返し実在有無を隠す。UI もそれに合わせ「送信済み」表示のみ。
  const [isSubmitted, setIsSubmitted] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setErrorMessage(null);
    const parsed = passwordResetRequestSchema.safeParse({ handleOrEmail });
    if (!parsed.success) {
      setErrorMessage('ハンドル名または email を入力してください');
      return;
    }
    setIsSubmitting(true);
    try {
      await requestPasswordReset(parsed.data);
      setIsSubmitted(true);
    } catch (error) {
      setErrorMessage(error instanceof Error ? error.message : '送信に失敗しました');
    } finally {
      setIsSubmitting(false);
    }
  }

  return (
    <div className="mx-auto grid max-w-[420px] gap-6">
      <section className="grid gap-2">
        <p className="m-0 text-[0.78rem] uppercase tracking-[0.18em] text-accent">Account</p>
        <h1 className="m-0 text-[clamp(1.4rem,2.4vw,1.8rem)] font-semibold">パスワードを忘れた場合</h1>
        <p className="m-0 text-sm text-[#4f5d75]">
          登録済みのメールアドレス、またはハンドル名を入力してください。検証済み email がある場合のみ、
          再設定用のリンクを送信します。
        </p>
      </section>

      <form className="grid gap-4 rounded-card border border-navy/12 bg-white/86 p-card shadow-card" onSubmit={handleSubmit}>
        <label className="grid gap-1.5 text-sm font-medium text-navy">
          ハンドル名 または email
          <input
            className={inputClassName}
            type="text"
            name="handleOrEmail"
            autoComplete="username"
            required
            value={handleOrEmail}
            onChange={(e) => setHandleOrEmail(e.target.value)}
          />
        </label>

        {errorMessage !== null ? (
          <p className="m-0 rounded-surface border border-incorrect/16 bg-incorrect-bg px-3 py-2 text-sm text-incorrect" role="alert">
            {errorMessage}
          </p>
        ) : null}

        {isSubmitted ? (
          <p className="m-0 rounded-surface border border-correct/16 bg-correct-bg px-3 py-2 text-sm text-correct" role="status">
            送信を受け付けました。該当する検証済みメールがあれば、30 分以内に再設定リンクが届きます。
          </p>
        ) : null}

        <button className={buttonClassName} type="submit" disabled={isSubmitting || isSubmitted}>
          {isSubmitting ? '送信中...' : '再設定リンクを送信'}
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

export default ForgotPasswordPage;
