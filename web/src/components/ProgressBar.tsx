interface ProgressBarProps {
  current: number
  total: number
}

function ProgressBar({ current, total }: ProgressBarProps) {
  const ratio = total <= 0 ? 0 : Math.min(1, Math.max(0, current / total))
  const percentage = Math.round(ratio * 100)

  return (
    <div className="grid gap-2">
      <div className="flex items-center justify-between text-xs font-medium uppercase tracking-[0.16em] text-[#4f5d75]">
        <span>進捗</span>
        <span aria-live="polite">{current} / {total}</span>
      </div>
      <div
        role="progressbar"
        aria-valuemin={0}
        aria-valuemax={total}
        aria-valuenow={current}
        className="h-2 overflow-hidden rounded-full bg-navy/8"
      >
        <div
          className="h-full rounded-full bg-linear-to-r from-accent to-accent-strong transition-[width]"
          style={{ width: `${percentage}%` }}
        />
      </div>
    </div>
  )
}

export default ProgressBar
