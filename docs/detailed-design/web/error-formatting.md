---
title: Error formatting (web)
description: How Zod issues become ApiError and a UI fallback, instead of raw ZodError
---

# Error formatting (web)

Zod 公式の [Formatting errors](https://zod.dev/error-formatting) に相当する、このアプリ側の正規化。

実装: `packages/web/src/api/client.ts`、`packages/web/src/hooks/useQuizCatalog.ts`

## 境界で止める

`requestJson` は `schema.safeParse(payload)` の失敗を throw しない ZodError のまま渡さず、`ApiError` にする。

```ts
const result = schema.safeParse(payload)
if (!result.success) {
  throw new ApiError(
    `API response validation failed: ${result.error.message}`,
    response.status,
    payload,
  )
}
```

`result.error.message` は Zod の連結メッセージ。`result.error.issues` はログやテストで `path` を見るときに使う。

## UI

`useQuizCatalog` は API 検証失敗を catch し、starter クイズへ戻す。ユーザーには `errorMessage` を出し、不正 JSON を画面に描画しない。

> **Note** — 管理画面のフォームエラーは日本語メッセージ（`admin-web` の `quizPayloadSchema`）。公開 API の refine メッセージは英語（`correctAnswerIndex is out of range`）。混ぜない。
