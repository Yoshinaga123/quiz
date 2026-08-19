import { useEffect, useState } from 'react';
import { Link, useSearchParams } from 'react-router-dom';
import { consumeEmailVerification } from '../api/member';

type Status = 'idle' | 'pending' | 'success' | 'error';

function VerifyEmailPage() {
  const [params] = useSearchParams();
  const token = params.get('token') ?? '';
  const hasToken = token !== '';
  const [status, setStatus] = useState<Status>(hasToken ? 'pending' : 'error');
  const [message, setMessage] = useState<string | null>(
    hasToken ? null : 'URL に検証トークンが含まれていません。',
  );

  useEffect(() => {
    if (!hasToken) return undefined;
    const controller = new AbortController();
    consumeEmailVerification(token, controller.signal)
      .then(() => {
        if (!controller.signal.aborted) {
          setStatus('success');
          setMessage('メールアドレスの検証が完了しました。');
        }
      })
      .catch((error: unknown) => {
        if (controller.signal.aborted) return;
        setStatus('error');
        setMessage(
          error instanceof Error
            ? error.message
            : '検証に失敗しました。リンクの有効期限が切れているか、既に使用済みの可能性があります。',
        );
      });
    return () => controller.abort();
  }, [hasToken, token]);

  return (
    <div className="mx-auto grid max-w-[420px] gap-6">
      <section className="grid gap-2">
        <p className="m-0 text-[0.78rem] uppercase tracking-[0.18em] text-accent">Account</p>
        <h1 className="m-0 text-[clamp(1.4rem,2.4vw,1.8rem)] font-semibold">メールアドレスの検証</h1>
      </section>

      <section className="rounded-card border border-navy/12 bg-white/86 p-card shadow-card grid gap-3">
        {status === 'pending' ? <p className="m-0 text-sm text-[#4f5d75]">検証中...</p> : null}
        {status === 'success' && message !== null ? (
          <p className="m-0 rounded-surface border border-correct/16 bg-correct-bg px-3 py-2 text-sm text-correct" role="status">
            {message}
          </p>
        ) : null}
        {status === 'error' && message !== null ? (
          <p className="m-0 rounded-surface border border-incorrect/16 bg-incorrect-bg px-3 py-2 text-sm text-incorrect" role="alert">
            {message}
          </p>
        ) : null}

        <p className="m-0 text-sm text-[#4f5d75]">
          <Link to="/me" className="font-semibold text-accent hover:underline">
            プロフィールに戻る
          </Link>
        </p>
      </section>
    </div>
  );
}

export default VerifyEmailPage;
