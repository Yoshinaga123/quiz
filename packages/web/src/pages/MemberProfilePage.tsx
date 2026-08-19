import { useCallback, useEffect, useState } from 'react';
import { Navigate } from 'react-router-dom';
import { deleteMe, listAnswerHistory, setMemberEmail } from '../api/member';
import { fetchMe } from '../api/member';
import { setMemberEmailRequestSchema } from '../schemas/member';
import { useMemberSession } from '../contexts/MemberSessionContext';
import type { AnswerHistoryEntry } from '../schemas/member';

const buttonClassName =
  'inline-flex items-center justify-center rounded-full px-4 py-2 text-sm font-medium transition duration-150 hover:-translate-y-0.5 hover:shadow-float disabled:cursor-not-allowed disabled:opacity-55 disabled:hover:translate-y-0 disabled:hover:shadow-none';

function formatAnsweredAt(iso: string): string {
  try {
    return new Date(iso).toLocaleString('ja-JP');
  } catch {
    return iso;
  }
}

function MemberProfilePage() {
  const { session, clearSession } = useMemberSession();
  const [items, setItems] = useState<AnswerHistoryEntry[]>([]);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [isDeleting, setIsDeleting] = useState(false);
  const [reloadKey, setReloadKey] = useState(0);
  const [hasVerifiedEmail, setHasVerifiedEmail] = useState<boolean | null>(null);
  const [emailInput, setEmailInput] = useState('');
  const [emailError, setEmailError] = useState<string | null>(null);
  const [emailNotice, setEmailNotice] = useState<string | null>(null);
  const [isSubmittingEmail, setIsSubmittingEmail] = useState(false);

  useEffect(() => {
    if (session === null) return undefined;
    const controller = new AbortController();

    listAnswerHistory({ token: session.token, signal: controller.signal })
      .then((response) => {
        if (controller.signal.aborted) return;
        setItems(response.items);
        setErrorMessage(null);
      })
      .catch((error: unknown) => {
        if (controller.signal.aborted) return;
        setErrorMessage(error instanceof Error ? error.message : '履歴を取得できませんでした');
      })
      .finally(() => {
        if (!controller.signal.aborted) {
          setIsLoading(false);
        }
      });

    return () => controller.abort();
  }, [session, reloadKey]);

  useEffect(() => {
    if (session === null) return undefined;
    const controller = new AbortController();
    fetchMe({ token: session.token, signal: controller.signal })
      .then((me) => {
        if (!controller.signal.aborted) {
          setHasVerifiedEmail(me.hasVerifiedEmail);
        }
      })
      .catch(() => {
        // hasVerifiedEmail の表示は補助情報。失敗しても UI 全体は停止しない。
      });
    return () => controller.abort();
  }, [session, reloadKey]);

  const reload = useCallback(() => {
    setIsLoading(true);
    setReloadKey((current) => current + 1);
  }, []);

  if (session === null) {
    return <Navigate to="/login" replace />;
  }

  async function handleDelete() {
    if (session === null) return;
    if (!window.confirm('本当に退会しますか? 履歴も併せて削除されます。')) return;
    setIsDeleting(true);
    try {
      await deleteMe({ token: session.token });
      clearSession();
    } catch (error) {
      const message = error instanceof Error ? error.message : '退会に失敗しました';
      setErrorMessage(message);
      setIsDeleting(false);
    }
  }

  async function handleSubmitEmail(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (session === null) return;
    setEmailError(null);
    setEmailNotice(null);
    const parsed = setMemberEmailRequestSchema.safeParse({ email: emailInput });
    if (!parsed.success) {
      setEmailError('メールアドレスの形式が正しくありません');
      return;
    }
    setIsSubmittingEmail(true);
    try {
      await setMemberEmail({ token: session.token }, parsed.data);
      setEmailNotice('確認メールを送信しました（24 時間有効）。受信ボックスをご確認ください。');
      setHasVerifiedEmail(false);
      setEmailInput('');
    } catch (error) {
      setEmailError(error instanceof Error ? error.message : 'メール登録に失敗しました');
    } finally {
      setIsSubmittingEmail(false);
    }
  }

  return (
    <div className="grid gap-8">
      <section className="grid gap-2">
        <p className="m-0 text-[0.78rem] uppercase tracking-[0.18em] text-accent">Your Account</p>
        <h1 className="m-0 text-[clamp(1.4rem,2.4vw,1.8rem)] font-semibold">{session.handle} さん</h1>
        <p className="m-0 text-sm text-[#4f5d75]">ID: <code className="text-navy">{session.memberId}</code></p>
      </section>

      <section className="rounded-card border border-navy/12 bg-white/86 p-card shadow-card">
        <div className="flex items-center justify-between gap-4">
          <h2 className="m-0 text-[1.05rem] font-semibold text-navy">回答履歴</h2>
          <button
            type="button"
            className={`${buttonClassName} border border-navy/12 bg-white/80 text-navy`}
            onClick={reload}
            disabled={isLoading}
          >
            {isLoading ? '取得中...' : '再取得'}
          </button>
        </div>

        {errorMessage !== null ? (
          <p className="mt-3 rounded-surface border border-incorrect/16 bg-incorrect-bg px-3 py-2 text-sm text-incorrect" role="alert">
            {errorMessage}
          </p>
        ) : null}

        {items.length === 0 && !isLoading && errorMessage === null ? (
          <p className="mt-3 text-sm text-[#4f5d75]">まだ回答がありません。</p>
        ) : null}

        {items.length > 0 ? (
          <ul className="mt-4 grid gap-2">
            {items.map((entry) => (
              <li
                key={entry.id}
                className="flex items-center justify-between rounded-surface border border-navy/8 bg-white/70 px-3 py-2 text-sm"
              >
                <span className="font-medium text-navy">Quiz #{entry.quizId}</span>
                <span className={entry.isCorrect ? 'text-correct' : 'text-incorrect'}>
                  {entry.isCorrect ? '正解' : '不正解'} (選択: {entry.selectedIndex})
                </span>
                <span className="text-xs text-[#4f5d75]">{formatAnsweredAt(entry.answeredAt)}</span>
              </li>
            ))}
          </ul>
        ) : null}
      </section>

      <section className="rounded-card border border-navy/12 bg-white/86 p-card shadow-card">
        <h2 className="m-0 text-[1.05rem] font-semibold text-navy">メールアドレス</h2>
        <p className="mt-1 text-sm text-[#4f5d75]">
          パスワードを忘れたときに再設定リンクを送るために利用します。email は他の会員には公開されません。
        </p>
        <p className="mt-2 text-sm text-navy">
          現在の状態:{' '}
          {hasVerifiedEmail === null ? (
            <span className="text-[#4f5d75]">確認中...</span>
          ) : hasVerifiedEmail ? (
            <span className="font-semibold text-correct">検証済み</span>
          ) : (
            <span className="font-semibold text-[#8a5a00]">未検証（または未登録）</span>
          )}
        </p>

        <form className="mt-3 grid gap-3" onSubmit={(event) => void handleSubmitEmail(event)}>
          <label className="grid gap-1.5 text-sm font-medium text-navy">
            新しいメールアドレス
            <input
              className="w-full rounded-surface border border-navy/12 bg-white/90 px-4 py-2.5 text-navy focus:outline-none focus:ring-2 focus:ring-accent/40"
              type="email"
              name="email"
              autoComplete="email"
              inputMode="email"
              maxLength={254}
              required
              value={emailInput}
              onChange={(e) => setEmailInput(e.target.value)}
            />
          </label>

          {emailError !== null ? (
            <p className="m-0 rounded-surface border border-incorrect/16 bg-incorrect-bg px-3 py-2 text-sm text-incorrect" role="alert">
              {emailError}
            </p>
          ) : null}
          {emailNotice !== null ? (
            <p className="m-0 rounded-surface border border-correct/16 bg-correct-bg px-3 py-2 text-sm text-correct" role="status">
              {emailNotice}
            </p>
          ) : null}

          <button
            type="submit"
            className={`${buttonClassName} bg-linear-to-br from-accent to-accent-strong text-white`}
            disabled={isSubmittingEmail}
          >
            {isSubmittingEmail ? '送信中...' : '確認メールを送信'}
          </button>
        </form>
      </section>

      <section className="rounded-card border border-navy/12 bg-white/86 p-card shadow-card">
        <h2 className="m-0 text-[1.05rem] font-semibold text-navy">危険な操作</h2>
        <p className="mt-1 text-sm text-[#4f5d75]">
          退会するとハンドル名は即時に解放され、回答履歴もサーバーから削除されます。
        </p>
        <div className="mt-3 flex flex-wrap gap-3">
          <button
            type="button"
            className={`${buttonClassName} border border-navy/12 bg-white/80 text-navy`}
            onClick={clearSession}
          >
            ログアウト
          </button>
          <button
            type="button"
            className={`${buttonClassName} border border-incorrect/24 bg-incorrect-bg text-incorrect`}
            onClick={() => void handleDelete()}
            disabled={isDeleting}
          >
            {isDeleting ? '退会処理中...' : '退会する'}
          </button>
        </div>
      </section>
    </div>
  );
}

export default MemberProfilePage;
