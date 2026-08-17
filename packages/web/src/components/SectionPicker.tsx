import type { SectionSummary } from '../types/quiz'

interface SectionPickerProps {
  sections: readonly SectionSummary[]
  totalCount: number
  selected: string | null
  onSelect: (section: string | null) => void
}

const baseClassName =
  'inline-flex items-center justify-center gap-2 rounded-full px-4 py-2.5 text-sm font-medium transition duration-150 hover:-translate-y-0.5 hover:shadow-float'

function SectionPicker({ sections, totalCount, selected, onSelect }: SectionPickerProps) {
  return (
    <div className="flex flex-wrap gap-2.5">
      <button
        type="button"
        onClick={() => onSelect(null)}
        className={
          selected === null
            ? `${baseClassName} bg-linear-to-br from-accent to-accent-strong text-white`
            : `${baseClassName} border border-navy/12 bg-white/90 text-navy`
        }
      >
        すべて
        <span className="rounded-full bg-navy/10 px-2 py-0.5 text-xs font-semibold">
          {totalCount}
        </span>
      </button>
      {sections.map(({ section, count }) => (
        <button
          type="button"
          key={section}
          onClick={() => onSelect(section)}
          className={
            selected === section
              ? `${baseClassName} bg-linear-to-br from-accent to-accent-strong text-white`
              : `${baseClassName} border border-navy/12 bg-white/90 text-navy`
          }
        >
          {section}
          <span className="rounded-full bg-navy/10 px-2 py-0.5 text-xs font-semibold">
            {count}
          </span>
        </button>
      ))}
    </div>
  )
}

export default SectionPicker
