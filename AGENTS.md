# Agent operating manual

This file is the first document for coding agents working in this repository.
Humans can follow it too. Claude-specific notes live in [`CLAUDE.md`](./CLAUDE.md).

## What this repo is

Socrates Quiz is an application monorepo, not a published library.

| Path | Role |
| --- | --- |
| `packages/web/` | User quiz UI (React 19 + Vite + Zod) |
| `packages/admin-web/` | Admin CRUD + mock Push (JWT) |
| `packages/mobile/` | Flutter client for the public API |
| `packages/backend/` | Go `net/http` API (`package main` split across files) |
| `packages/bench/` | Runtime speed (ops/sec) for the public Zod parse. Not a product app |
| `docs/` | Manuals only (OpenAPI, detailed-design, ADR, linting). Not inside a product |
| `scratch/` | Local bundle-size lab (gitignored, same as Zod). Entry name is `input.ts` |
| `samples/` | Local learning clones (gitignored). Not in the published tree |
| `archive/` | Isolation note for local-only learning / diagnostics |

Production host: `https://socrates-quiz.jp` on one AWS Lightsail instance (ADR 0015). Dev API: host `8082` → container `8080`.

## Non-negotiable: public JSON contract

Changing the public JSON shape requires **the same PR** to update all of:

1. `docs/api/public-quiz-api.yaml`
2. `docs/api/fixtures/`
3. `packages/web/src/schemas/quiz.ts` and `packages/web/src/api/quiz.ts`
4. `packages/backend/types.go` (`publicQuiz` / `publicQuizListResponse`) and handlers
5. `docs/detailed-design/web/quiz-schema.md` (especially `.refine`)
6. `docs/detailed-design/web/public-contract.md` if the process changes
7. `packages/web/tests/contract/`, `packages/backend/public_contract_test.go`, `scripts/check_public_contract.py`
8. `packages/mobile/lib/layers/data/dto/public_quiz_dto.dart` when the DTO fields change

OpenAPI cannot express `.refine`. Those rules belong in detailed-design, with a failing fixture (`quiz-invalid-answer-index.json`).

Do not expose admin fields (`status`, `pushEnabled`, `createdAt`, `updatedAt`) on `publicQuiz`.

## Source of truth

| Concern | SSOT |
| --- | --- |
| Quiz body in production | PostgreSQL `quizzes` |
| Public HTTP shape | OpenAPI + `docs/api/fixtures/` |
| Runtime parse (web) | handwritten Zod |
| Admin input | `packages/admin-web/src/schemas/` |
| Why a long-lived, cross-cutting decision exists | `docs/adr/` |
| Why a local tooling or experiment decision exists | GitHub Issue / implementation PR |

Do not generate Zod from OpenAPI. Dual-write both (ADR 0006).

## Where to put code

- Scratch / experiments: `play.ts` (repo root), `packages/web/scripts/`, `packages/admin-web/scripts/`, `packages/backend/play.go` (`//go:build ignore`). Never leave experiments in `src/` or in a `package main` file that `go build` compiles.
- Bundle-size (kB) experiments use a **local** `scratch/input.ts`. The `scratch/` directory is gitignored, same as Zod. Do not invent another entry name. Do not commit that folder. Do not import it from `packages/web/src/` or `packages/admin-web/src/`.
- Runtime speed (ops/sec) lives in `packages/bench`. Run `npm run bench`. Do not put ArkType / Valibot there. Do not add it to npm workspaces.
- Tests live next to the API they protect: `packages/web/tests/schemas/`, `packages/web/tests/contract/`, `packages/admin-web/tests/schemas/`, `packages/backend/*_test.go`.
- A schema or contract change without a success **and** failure test is unfinished.
- Documentation examples are executable. If you change a fenced TypeScript block in `docs/detailed-design/`, update `packages/web/tests/contract/docs-examples.test.ts` (and the implementation) in the same diff.
- New detailed-design pages must be kebab-case English, have YAML `title` + `description` frontmatter, and be listed in both `docs/detailed-design/meta.json` and the package folder `meta.json`. Then run `npm run docs:llms`.
- Follow `docs/detailed-design/writing.md`. Do not add a Fumadocs/Next docs site.

## Commands

From the repo root (Node 22, see `.nvmrc`):

```bash
npm i                    # root workspaces: packages/web + packages/admin-web
npm test                 # public contract + web + Go + admin-web
npm run test:contract    # OpenAPI/fixtures/Zod/Go only
npm run lint             # web, admin-web, gofmt
npm run fix              # eslint --fix + gofmt -w
npm run check:circular   # madge on web + admin-web
npm run check:docs       # frontmatter, orphans, links, llms drift
npm run docs:llms        # regenerate docs/llms.txt and docs/llms-full.txt
npm run play             # root play.ts scratch pad
npm run scratch:measure  # local scratch/input.ts kB (folder is gitignored)
npm run bench            # packages/bench ops/sec (public quiz Zod parse)
```

Husky runs `lint-staged` on commit and `npm run test:contract` on push.

## Do not

- Switch the package manager (npm stays). Do not rewrite Go into `internal/` packages, unless a human explicitly asks.
- Do not migrate ESLint → Biome now. Future intent is `docs/backlog.md` TASK-005. Do not start it unless a human opens that task.
- Do not add `package-lock.json` under `packages/web` or `packages/admin-web`. Install from the repo root (`npm i`).
- Do not empty `.devcontainer` features to match Zod. Keep Node 22, Go, Python, Docker-in-Docker, and `npm`.
- Do not copy Zod's `.vscode/launch.json` (`--conditions=@zod/source`). Debug pads with `npm run play` / `go run`.
- Commit `samples/`, juice-shop dumps, or diagnostic transcripts in a product PR.
- Commit `.env`, credentials, or real JWT secrets.
- Invent a public field that is not in OpenAPI + fixtures + Zod + Go in the same change.
- Use `as SomeType` to bypass runtime validation of external JSON.
- Do not rewrite `import { z } from "zod"` to `import * as z from "zod"`. That warning is for esbuild bundling in some cases. Production here is Vite 7 + Rollup. See `docs/backlog.md` (REJECTED).

## PR shape

One purpose per PR. Public-contract edits must include the checklist in `.github/PULL_REQUEST_TEMPLATE.md`.

## Code Review Rules

Codex Cloud reviews pull requests. It reads this file, not Zod's `claude-code-review.yml`. Do not ask for `gh pr comment` or Claude OAuth. Post a normal GitHub review. Flag P0/P1 only. Leave lint, format, and `npm test` to CI.

### Public contract

If the public JSON shape changes and the same PR does not update OpenAPI, fixtures, handwritten Zod, and Go `publicQuiz`, that is a defect. Safe path: the checklist in `.github/PULL_REQUEST_TEMPLATE.md`.

Do not expose `status`, `pushEnabled`, `createdAt`, or `updatedAt` on `publicQuiz`.

### Tooling this repo does not want

Treat these as defects unless a human explicitly asked for them:

- Switching npm to pnpm, or adding `package-lock.json` under `packages/web` or `packages/admin-web`
- Emptying `.devcontainer` features to match Zod
- Rewriting `import { z } from "zod"` to `import * as z from "zod"`
- Generating Zod from OpenAPI

### Secrets and product boundary

Flag committed `.env`, JWT secrets, or `samples/` / juice-shop dumps in a product PR.
