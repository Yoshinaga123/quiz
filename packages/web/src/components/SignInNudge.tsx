import { Link } from 'react-router-dom';
import { useMemberSession } from '../contexts/MemberSessionContext';

// Prompts anonymous users to sign in so answer history is preserved
// server-side (POST /api/me/answers) rather than only in localStorage.
function SignInNudge() {
  const { session } = useMemberSession();
  if (session !== null) return null;

  return (
    <aside
      className="rounded-surface border border-accent/20 bg-white/70 px-4 py-3 text-sm text-navy"
      role="note"
      data-testid="sign-in-nudge"
    >
      <div className="flex flex-wrap items-center justify-between gap-3">
        <p className="m-0">
          <span className="mr-1 font-semibold text-accent">Tip:</span>
          ログインすると、クイズの回答履歴が端末を越えて保存されます。
        </p>
        <div className="flex flex-wrap gap-2">
          <Link
            to="/login"
            className="inline-flex items-center rounded-full border border-navy/16 bg-white/80 px-3 py-1.5 text-xs font-semibold text-navy hover:-translate-y-0.5 hover:shadow-float"
          >
            ログイン
          </Link>
          <Link
            to="/register"
            className="inline-flex items-center rounded-full bg-linear-to-br from-accent to-accent-strong px-3 py-1.5 text-xs font-semibold text-white hover:-translate-y-0.5 hover:shadow-float"
          >
            会員登録
          </Link>
        </div>
      </div>
    </aside>
  );
}

export default SignInNudge;
