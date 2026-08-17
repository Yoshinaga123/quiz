import { readFileSync } from 'node:fs'
import path from 'node:path'
import { fileURLToPath } from 'node:url'
import { Bench } from 'tinybench'
import { quizSchema, quizzesSchema } from '../web/src/schemas/quiz.ts'

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../..')
const quizRaw = readFileSync(path.join(root, 'docs/api/fixtures/quiz.json'), 'utf8')
const listRaw = readFileSync(path.join(root, 'docs/api/fixtures/quiz-list.json'), 'utf8')
const quiz = JSON.parse(quizRaw) as unknown
const list = JSON.parse(listRaw) as { quizzes: unknown }

const bench = new Bench({ name: 'public quiz Zod parse', time: 500 })

bench
  .add('JSON.parse quiz.json', () => {
    JSON.parse(quizRaw)
  })
  .add('quizSchema.parse', () => {
    quizSchema.parse(quiz)
  })
  .add('quizSchema.safeParse', () => {
    quizSchema.safeParse(quiz)
  })
  .add('quizzesSchema.parse list', () => {
    quizzesSchema.parse(list.quizzes)
  })

await bench.run()
console.log(bench.name)
console.table(bench.table())
