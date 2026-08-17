const allowed = new Set(['quiz-parse'])
const name = process.argv[2] ?? 'quiz-parse'

if (!allowed.has(name)) {
  throw new Error(`unknown bench: ${name}. try: ${[...allowed].join(', ')}`)
}

await import(`./${name}.ts`)
