# Changelog

All notable changes to this project are documented in this file.  
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## Unreleased

### Added

- `packages/bench` runs public-quiz Zod parse speed (`npm run bench`). Bundle size stays in local `scratch/` (ADR 0013).
- Backlog TASK-005: ESLint → Biome is a future migration. ESLint stays until a human opens that task.
- ADR 0012: do not copy Zod's VS Code `launch.json` (`@zod/source`). Debug pads with `npm run play` / `go run`.
- Quality CI runs root `npm ci` + `npm test` on every PR, and circular import check after install. Mobile CI runs `flutter analyze` / `flutter test`. Frontend and backend push also cover `develop`.
- npm workspaces at the repo root so `npm i` installs `packages/web` and `packages/admin-web`. Dev Container `postCreateCommand` is `npm i`.
- ADR 0011: Dev Container keeps the runtimes this repo actually uses (Node 22, Go, Python, Docker-in-Docker, npm). Do not copy Zod's empty `features`.
- Scratch Rollup measure (`npm run scratch:measure`) records named vs namespace Zod kB in `scratch/RESULTS.md` without changing the import decision.
- Rejected rewriting `import { z } from "zod"` to namespace import; the esbuild locale warning does not apply to Vite 7 + Rollup production.
- Backlog TASK-004: Zod Mini migration is optional and deferred (classic `zod` stays).
- ADR 0010: bundle-size experiments use `scratch/input.ts` (not `play.ts`).
- Zod-inspired docs: YAML frontmatter, per-package `meta.json`, `docs/llms.txt` catalog + `docs/llms-full.txt`, `writing.md` / `packages/web/basics.md` / `packages/web/error-formatting.md`, and `scripts/check_docs.py`.
- Zod-inspired repo ops: `AGENTS.md`, Contributor Covenant, `.editorconfig`, `.nvmrc`, husky / lint-staged, Dependabot, Dev Container, issue templates, and docs-example tests.
- Public contract fixtures (`docs/api/fixtures/`) plus CI that runs OpenAPI, Zod, and Go on the same examples.
- Root README, MIT LICENSE, CONTRIBUTING, SECURITY, and changelog for OSS hygiene.
- `archive/` note separating learning materials from the product tree.
- Vitest for `packages/web/` and `packages/admin-web/` schema tests.
- Backend split from a single `main.go` into package-main files.

### Changed

- `quiz.md` aligned with the implemented stack (React 19, Go `net/http`, mock Push Phase A).
