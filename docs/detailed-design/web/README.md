---
title: web
description: Detailed design for the user-facing React quiz UI
---

# web

ユーザー向け Web（`web/`）の詳細設計を置く。

基本設計: [`../../adr/0005-user-facing-web-quiz-app.md`](../../adr/0005-user-facing-web-quiz-app.md)、[`../../api/public-quiz-api.yaml`](../../api/public-quiz-api.yaml)、[`../../implement-policy.md`](../../implement-policy.md)

実装: `web/src/`

| ページ | 概要 |
| --- | --- |
| [`basics.md`](./basics.md) | Zod 公式 Basics 相当（safeParse / infer / issues） |
| [`quiz-schema.md`](./quiz-schema.md) | 公開クイズ Zod（OpenAPI に書けない `.refine`） |
| [`error-formatting.md`](./error-formatting.md) | Zod issues → `ApiError` → UI フォールバック |
| [`public-contract.md`](./public-contract.md) | OpenAPI / fixtures / Zod / Go を同じ PR で直す |
