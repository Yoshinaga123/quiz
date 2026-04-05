interface DeleteQuizDialogProps {
  open: boolean
  quizTitle: string
  errorMessage: string | null
  isDeleting: boolean
  onCancel: () => void
  onConfirm: () => void
}

function DeleteQuizDialog({
  open,
  quizTitle,
  errorMessage,
  isDeleting,
  onCancel,
  onConfirm,
}: DeleteQuizDialogProps) {
  if (!open) {
    return null
  }

  return (
    <div
      className="fixed inset-0 z-40 grid place-items-center bg-navy/42 p-6 backdrop-blur-md"
      onClick={isDeleting ? undefined : onCancel}
      role="presentation"
    >
      <div
        aria-labelledby="delete-quiz-title"
        aria-modal="true"
        className="w-full max-w-[520px] rounded-card border border-[#b42318]/18 bg-[#fffaf8] p-7 shadow-card"
        onClick={(event) => event.stopPropagation()}
        role="dialog"
      >
        <p className="m-0 text-[0.8rem] uppercase tracking-[0.14em] text-[#b42318]">Delete Quiz</p>
        <h2 className="mt-2.5 mb-3 text-[clamp(1.4rem,2vw,1.8rem)] font-semibold" id="delete-quiz-title">
          「{quizTitle}」を削除しますか
        </h2>
        <p className="m-0 text-[#4f5d75]">
          この操作は元に戻せません。公開対象のクイズを消す前に、必要なら内容を別の問題へ移してください。
        </p>

        {errorMessage ? (
          <p className="mt-4 rounded-[10px] bg-[#b42318]/10 px-3.5 py-3 text-[#7a271a]">
            {errorMessage}
          </p>
        ) : null}

        <div className="mt-6 flex flex-col-reverse gap-3 sm:flex-row sm:justify-end">
          <button
            className="inline-flex items-center justify-center rounded-full border border-navy/12 bg-white px-[18px] py-3 transition duration-150 hover:-translate-y-0.5 hover:shadow-float-sm disabled:cursor-progress disabled:opacity-60 disabled:hover:translate-y-0 disabled:hover:shadow-none"
            disabled={isDeleting}
            onClick={onCancel}
            type="button"
          >
            キャンセル
          </button>
          <button
            className="inline-flex items-center justify-center rounded-full bg-[#b42318] px-[18px] py-3 text-white transition duration-150 hover:-translate-y-0.5 hover:shadow-float-sm disabled:cursor-progress disabled:opacity-60 disabled:hover:translate-y-0 disabled:hover:shadow-none"
            disabled={isDeleting}
            onClick={onConfirm}
            type="button"
          >
            {isDeleting ? '削除中...' : '削除する'}
          </button>
        </div>
      </div>
    </div>
  )
}

export default DeleteQuizDialog
