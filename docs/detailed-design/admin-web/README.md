---
title: admin-web
description: Detailed design for the admin CRUD UI and JWT login
---

# admin-web

管理画面（`admin-web/`）の詳細設計を置く。

基本設計: [`../../adr/0004-login-verification-code-flow.md`](../../adr/0004-login-verification-code-flow.md)、[`../../architecture/backend-flow.md`](../../architecture/backend-flow.md)、[`../../validation-policy.md`](../../validation-policy.md)

実装: `admin-web/src/`、スキーマテストは `admin-web/tests/`

| ページ | 概要 |
| --- | --- |
| [`quiz-schema.md`](./quiz-schema.md) | 管理 Zod。公開 `quizSchema` との差と `.refine` |
