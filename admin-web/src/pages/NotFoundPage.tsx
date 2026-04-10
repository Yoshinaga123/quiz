import { Link } from 'react-router-dom'

function NotFoundPage() {
  return (
    <div className="grid min-h-screen place-items-center px-6 py-24">
      <div className="grid justify-items-center gap-4 text-center">
        <p className="text-[5rem] font-bold leading-none text-[#1768ac]/20">404</p>
        <h1 className="text-[clamp(1.6rem,3vw,2.2rem)] font-semibold text-navy">
          ページが見つかりません
        </h1>
        <p className="max-w-[480px] text-[#4f5d75]">
          お探しのページは存在しないか、移動した可能性があります。
        </p>
        <Link
          className="mt-2 inline-flex items-center justify-center rounded-full bg-linear-to-br from-[#1768ac] to-[#0f4c81] px-5 py-3 text-sm font-medium text-white transition duration-150 hover:-translate-y-0.5 hover:shadow-[0_12px_24px_rgba(20,33,61,0.12)]"
          to="/quizzes"
        >
          クイズ一覧へ戻る
        </Link>
      </div>
    </div>
  )
}

export default NotFoundPage
