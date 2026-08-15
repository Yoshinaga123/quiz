# scratch bundle size results

Measured: 2026-08-15  
Bundler: Rollup `treeshake.preset: "smallest"` + ESM (same conditions as Zod's treeshake lab).  
Entry usage: public-quiz-shaped `quizSchema` + `safeParse` (mirrors `web/src/schemas/quiz.ts`).  
Decision: **unchanged**. `web/` and `admin-web/` keep `import { z } from "zod"`. This file is a post-hoc check of that call (ADR 0002 measure-first, after the fact).

| Import | Raw | gzip | file |
| --- | --- | --- | --- |
| `import { z } from "zod"` (production / `input.ts`) | 163021 B (159.20 kB) | 30391 B (29.68 kB) | `scratch/out_rollup.js` |
| `import * as z from "zod"` (comparison only) | 163021 B (159.20 kB) | 30391 B (29.68 kB) | `scratch/out_rollup_namespace.js` |
| Delta (namespace − named) | 0 B | 0 B | |

gzip 差が 0 に近い、または named のほうが小さいなら、esbuild 向け注意はこの計測条件（Rollup）では当てはまらない。

Re-run: `npm run scratch:measure`
