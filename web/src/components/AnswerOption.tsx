import type { ReactNode } from 'react'

type Variant = 'idle' | 'selected' | 'correct' | 'incorrect' | 'reveal-correct'

interface AnswerOptionProps {
  index: number
  label: string
  variant: Variant
  disabled: boolean
  onSelect: (index: number) => void
}

const optionLabels = ['A', 'B', 'C', 'D', 'E', 'F'] as const

const variantClassName: Record<Variant, string> = {
  idle: 'border-navy/14 bg-white/92 text-navy hover:-translate-y-0.5 hover:shadow-float',
  selected: 'border-accent/50 bg-accent/8 text-accent-strong shadow-float',
  correct: 'border-correct/40 bg-correct-bg text-correct shadow-float',
  incorrect: 'border-incorrect/40 bg-incorrect-bg text-incorrect shadow-float',
  'reveal-correct': 'border-correct/40 bg-correct-bg text-correct',
}

const indicatorByVariant: Record<Variant, ReactNode> = {
  idle: null,
  selected: null,
  correct: <span aria-hidden="true">○</span>,
  incorrect: <span aria-hidden="true">×</span>,
  'reveal-correct': <span aria-hidden="true">○</span>,
}

function AnswerOption({ index, label, variant, disabled, onSelect }: AnswerOptionProps) {
  const safeLabel = optionLabels[index] ?? String(index + 1)

  return (
    <button
      type="button"
      disabled={disabled}
      onClick={() => onSelect(index)}
      className={`flex w-full items-start gap-3 rounded-surface border px-4 py-3.5 text-left transition disabled:cursor-not-allowed ${variantClassName[variant]}`}
      aria-pressed={variant === 'selected'}
    >
      <span className="mt-0.5 inline-flex h-7 w-7 shrink-0 items-center justify-center rounded-full border border-current text-xs font-semibold">
        {safeLabel}
      </span>
      <span className="flex-1 text-sm leading-relaxed">{label}</span>
      <span className="ml-2 text-lg font-bold leading-none">{indicatorByVariant[variant]}</span>
    </button>
  )
}

export default AnswerOption
