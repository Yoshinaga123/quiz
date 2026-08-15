/**
 * Bundle-size entry (ADR 0010). Production style: import { z } from "zod".
 * Do not import this file from web/src or admin-web/src.
 *
 * Measure both import styles: npm run scratch:measure
 */
import { z } from 'zod'

function hasValidCorrectAnswerIndex(correctAnswerIndex: number, optionCount: number): boolean {
  return correctAnswerIndex >= 0 && correctAnswerIndex < optionCount
}

const quizSchema = z
  .object({
    id: z.number().int().positive(),
    section: z.string().min(1),
    title: z.string().min(1),
    question: z.string().min(1),
    code: z.string().optional(),
    options: z.array(z.string().min(1)).min(2),
    correctAnswerIndex: z.number().int().nonnegative(),
    explanation: z.string().min(1),
    source: z.string().min(1),
  })
  .refine(
    ({ correctAnswerIndex, options }) => hasValidCorrectAnswerIndex(correctAnswerIndex, options.length),
    {
      path: ['correctAnswerIndex'],
      message: 'correctAnswerIndex is out of range',
    },
  )

const result = quizSchema.safeParse({
  id: 1,
  section: 'React',
  title: 'useState',
  question: 'What does useState return?',
  code: 'const [value, setValue] = useState(0);',
  options: ['array', 'object'],
  correctAnswerIndex: 0,
  explanation: 'It returns a tuple [state, setState].',
  source: 'https://react.dev/reference/react/useState',
})

console.log(result.success)
