---
title: admin-web quiz Zod schema
description: Admin quiz Zod including status and pushEnabled, which must not appear on publicQuiz
---

# admin-web quiz Zod schema

基本設計: [`../../validation-policy.md`](../../validation-policy.md)、[`../../adr/0004-login-verification-code-flow.md`](../../adr/0004-login-verification-code-flow.md)

実装: `packages/admin-web/src/schemas/quiz.ts`  
テスト: `packages/admin-web/tests/schemas/quiz.test.ts`  
試し書き: `packages/admin-web/scripts/`（本番スキーマに残さない）

公開 API の `quizSchema`（`packages/web/src/schemas/quiz.ts`）とは別物。管理画面は `status` / `pushEnabled` / `createdAt` / `updatedAt` を持つ。これらのフィールドを `publicQuiz` に出してはならない。

## OpenAPI に書けない業務ルール

正解番号は選択肢の個数未満であること。入力フォーム用 `quizPayloadSchema` のメッセージは日本語。

```ts
.refine(
  ({ correctAnswerIndex, options }) =>
    correctAnswerIndex >= 0 && correctAnswerIndex < options.length,
  { path: ['correctAnswerIndex'], message: '正解の選択肢を指定してください' },
)
```
