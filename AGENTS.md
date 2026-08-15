# Agent operating manual

This file is the first document for coding agents working in this repository.
Humans can follow it too. Claude-specific notes live in [`CLAUDE.md`](./CLAUDE.md).

## What this repo is

Socrates Quiz is an application monorepo, not a published library.

| Path | Role |
| --- | --- |
| `web/` | User quiz UI (React 19 + Vite + Zod) |
| `admin-web/` | Admin CRUD + mock Push (JWT) |
| `mobile/` | Flutter client for the public API |
| `backend/` | Go `net/http` API (`package main` split across files) |
| `docs/api/` | Public OpenAPI + shared fixtures |
| `docs/detailed-design/` | Internal assembly (refine rules, handlers, SQL) |
| `samples/` `archive/` `docs/security-tools/` | Learning / diagnostics — not product |

Production host: `https://socrates-quiz.jp`. Dev API: host `8082` → container `8080`.

## Non-negotiable: public JSON contract

Changing the public JSON shape requires **the same PR** to update all of:

1. `docs/api/public-quiz-api.yaml`
2. `docs/api/fixtures/`
3. `web/src/schemas/quiz.ts` and `web/src/api/quiz.ts`
4. `backend/types.go` (`publicQuiz` / `publicQuizListResponse`) and handlers
5. `docs/detailed-design/web/quiz-schema.md` (especially `.refine`)
6. `docs/detailed-design/web/public-contract.md` if the process changes
7. `web/tests/contract/`, `backend/public_contract_test.go`, `scripts/check_public_contract.py`
8. `mobile/lib/layers/data/dto/public_quiz_dto.dart` when the DTO fields change

OpenAPI cannot express `.refine`. Those rules belong in detailed-design, with a failing fixture (`quiz-invalid-answer-index.json`).

Do not expose admin fields (`status`, `pushEnabled`, `createdAt`, `updatedAt`) on `publicQuiz`.

## Source of truth

| Concern | SSOT |
| --- | --- |
| Quiz body in production | PostgreSQL `quizzes` |
| Public HTTP shape | OpenAPI + `docs/api/fixtures/` |
| Runtime parse (web) | handwritten Zod |
| Admin input | `admin-web/src/schemas/` |
| Why a decision exists | `docs/adr/` |

Do not generate Zod from OpenAPI. Dual-write both (ADR 0006).

## Where to put code

- Scratch / experiments: `play.ts` (repo root), `web/scripts/`, `admin-web/scripts/`, `backend/play.go` (`//go:build ignore`). Never leave experiments in `src/` or in a `package main` file that `go build` compiles.
- Bundle-size (kB) experiments use **`scratch/input.ts` only** (ADR 0010). Do not invent another entry name. Do not import that file from `web/src/` or `admin-web/src/`.
- Tests live next to the API they protect: `web/tests/schemas/`, `web/tests/contract/`, `admin-web/tests/schemas/`, `backend/*_test.go`.
- A schema or contract change without a success **and** failure test is unfinished.
- Documentation examples are executable. If you change a fenced TypeScript block in `docs/detailed-design/`, update `web/tests/contract/docs-examples.test.ts` (and the implementation) in the same diff.
- New detailed-design pages must be kebab-case English, have YAML `title` + `description` frontmatter, and be listed in both `docs/detailed-design/meta.json` and the package folder `meta.json`. Then run `npm run docs:llms`.
- Follow `docs/detailed-design/writing.md`. Do not add a Fumadocs/Next docs site.

## Commands

From the repo root (Node 22, see `.nvmrc`):

```bash
npm test                 # public contract + web + Go + admin-web
npm run test:contract    # OpenAPI/fixtures/Zod/Go only
npm run lint             # web, admin-web, gofmt
npm run fix              # eslint --fix + gofmt -w
npm run check:circular   # madge on web + admin-web
npm run check:docs       # frontmatter, orphans, links, llms drift
npm run docs:llms        # regenerate docs/llms.txt and docs/llms-full.txt
npm run play             # root play.ts scratch pad
npm run scratch:measure  # named vs namespace Zod kB (does not change web/)
```

Husky runs `lint-staged` on commit and `npm run test:contract` on push.

## Do not

- Switch the package manager (npm stays). Do not migrate ESLint → Biome, or rewrite Go into `internal/` packages, unless a human explicitly asks.
- Commit `samples/`, juice-shop dumps, or diagnostic transcripts in a product PR.
- Commit `.env`, credentials, or real JWT secrets.
- Invent a public field that is not in OpenAPI + fixtures + Zod + Go in the same change.
- Use `as SomeType` to bypass runtime validation of external JSON.
- Do not rewrite `import { z } from "zod"` to `import * as z from "zod"`. That warning is for esbuild bundling in some cases. Production here is Vite 7 + Rollup. See `docs/backlog.md` (REJECTED).

## PR shape

One purpose per PR. Public-contract edits must include the checklist in `.github/PULL_REQUEST_TEMPLATE.md`.
