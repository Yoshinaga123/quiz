interface CodeBlockProps {
  code: string
  ariaLabel?: string
}

function CodeBlock({ code, ariaLabel }: CodeBlockProps) {
  return (
    <pre
      aria-label={ariaLabel ?? 'コードブロック'}
      className="m-0 overflow-x-auto rounded-surface border border-navy/12 bg-navy/96 px-4 py-3.5 text-sm leading-relaxed text-[#f8fafc] shadow-float"
    >
      <code>{code}</code>
    </pre>
  )
}

export default CodeBlock
