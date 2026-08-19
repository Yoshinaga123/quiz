---
title: backend package layout
description: package main file split — not internal/ packages — and what each file owns
---

# backend package layout

基本設計: [`../../architecture/backend-flow.md`](../../architecture/backend-flow.md)

`internal/` パッケージには分けず、同じ `package main` のままファイル分割する（`push_mock_test.go` が `server` と `routes()` を直接使うため）。

| ファイル | 責務 |
| --- | --- |
| `main.go` | `withCORS`、`routes()`、`main()` |
| `types.go` | DTO、`server`、定数 |
| `db.go` | env、接続、`//go:embed` migrate |
| `httpx.go` | `writeJSON` / `decodeJSON` / `parseID` / `writePublicError` |
| `auth.go` | JWT、検証コード、ログイン |
| `counter.go` | `/` と `/counter` |
| `admin_quizzes.go` | `/api/admin/quizzes*` |
| `public.go` | `/healthz` と `/v1/*` |
| `attempts.go` | `POST /v1/attempts` の検証と匿名集計保存 |
| `push.go` | mock Push |
| `seed.go` | 本番シード同期と payload 正規化 |
| `quiz_scan.go` | `scanQuiz` / `scanPublicQuiz` |
| `debug.go` | 起動時メモリ診断 |
