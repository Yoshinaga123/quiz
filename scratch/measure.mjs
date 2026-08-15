/**
 * Bundle scratch/input.ts twice: named import (committed) vs namespace import (temp).
 * Writes scratch/RESULTS.md. Does not change web/ or admin-web/.
 */
import { writeFileSync, readFileSync, unlinkSync } from 'node:fs'
import path from 'node:path'
import { fileURLToPath } from 'node:url'
import { gzipSync } from 'node:zlib'

import commonjs from '@rollup/plugin-commonjs'
import resolve from '@rollup/plugin-node-resolve'
import typescript from '@rollup/plugin-typescript'
import { rollup } from 'rollup'

const scratchDir = path.dirname(fileURLToPath(import.meta.url))
const repoRoot = path.resolve(scratchDir, '..')
const inputPath = path.join(scratchDir, 'input.ts')
const namedOut = path.join(scratchDir, 'out_rollup.js')
const namespaceOut = path.join(scratchDir, 'out_rollup_namespace.js')
const namespaceInput = path.join(scratchDir, '.input-namespace.ts')
const resultsPath = path.join(scratchDir, 'RESULTS.md')

const NAMED = `import { z } from 'zod'`
const NAMESPACE = `import * as z from 'zod'`

const kb = (bytes) => (bytes / 1024).toFixed(2)

const plugins = () => [
  resolve({ rootDir: repoRoot }),
  commonjs(),
  typescript({
    tsconfig: path.join(scratchDir, 'tsconfig.json'),
    noEmit: false,
    declaration: false,
  }),
]

async function bundle(input, output) {
  const built = await rollup({
    input,
    plugins: plugins(),
    treeshake: { preset: 'smallest', annotations: true },
  })
  await built.write({ file: output, format: 'esm' })
  await built.close()
  const raw = readFileSync(output)
  return { raw: raw.length, gzip: gzipSync(raw).length }
}

const source = readFileSync(inputPath, 'utf8')
if (!source.includes(NAMED)) {
  throw new Error(`scratch/input.ts must contain ${NAMED} (production style)`)
}

const named = await bundle(inputPath, namedOut)

writeFileSync(namespaceInput, source.replace(NAMED, NAMESPACE), 'utf8')
let namespace
try {
  namespace = await bundle(namespaceInput, namespaceOut)
} finally {
  try {
    unlinkSync(namespaceInput)
  } catch {
    // ignore
  }
}

const rawDelta = namespace.raw - named.raw
const gzipDelta = namespace.gzip - named.gzip
const measuredAt = new Date().toISOString().slice(0, 10)

const report = `# scratch bundle size results

Measured: ${measuredAt}  
Bundler: Rollup \`treeshake.preset: "smallest"\` + ESM (same conditions as Zod's treeshake lab).  
Entry usage: public-quiz-shaped \`quizSchema\` + \`safeParse\` (mirrors \`web/src/schemas/quiz.ts\`).  
Decision: **unchanged**. \`web/\` and \`admin-web/\` keep \`import { z } from "zod"\`. This file is a post-hoc check of that call (ADR 0002 measure-first, after the fact).

| Import | Raw | gzip | file |
| --- | --- | --- | --- |
| \`import { z } from "zod"\` (production / \`input.ts\`) | ${named.raw} B (${kb(named.raw)} kB) | ${named.gzip} B (${kb(named.gzip)} kB) | \`scratch/out_rollup.js\` |
| \`import * as z from "zod"\` (comparison only) | ${namespace.raw} B (${kb(namespace.raw)} kB) | ${namespace.gzip} B (${kb(namespace.gzip)} kB) | \`scratch/out_rollup_namespace.js\` |
| Delta (namespace − named) | ${rawDelta} B | ${gzipDelta} B | |

gzip 差が 0 に近い、または named のほうが小さいなら、esbuild 向け注意はこの計測条件（Rollup）では当てはまらない。

Re-run: \`npm run scratch:measure\`
`

writeFileSync(resultsPath, report, 'utf8')
process.stdout.write(report)
