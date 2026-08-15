---
title: backend
description: Detailed design for the Go net/http API and PostgreSQL access
---

# backend

Go API と DB アクセスの詳細設計を置く。

基本設計: [`../../architecture/backend-flow.md`](../../architecture/backend-flow.md)、[`../../architecture/data-model.md`](../../architecture/data-model.md)、[`../../api/public-quiz-api.yaml`](../../api/public-quiz-api.yaml)、[`../../adr/0006-public-quiz-api.md`](../../adr/0006-public-quiz-api.md)

実装: `backend/*.go`（`package main` を責務別に分割）、`backend/migrations/`

| ページ | 概要 |
| --- | --- |
| [`package-layout.md`](./package-layout.md) | `package main` のファイル分割 |
