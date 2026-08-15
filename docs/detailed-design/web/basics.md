---
title: Basic usage (web Zod)
description: Define a schema, safeParse untrusted JSON, handle issues, and infer types — as this app actually does
---

# Basic usage (web Zod)

Zod 公式の [Basic usage](https://zod.dev/basics) と同じ順で、このリポジトリの公開クイズ schema を説明する。完全なフィールド一覧と `.refine` は [`quiz-schema.md`](./quiz-schema.md)。

実装: `web/src/schemas/quiz.ts`、`web/src/api/client.ts`  
試し書き: ルート `play.ts`（`npm run play`）

## Defining a schema

公開クイズ 1 件は `quizSchema`。型は schema から取る。

```ts
import { z } from 'zod'
import { quizSchema } from '../../src/schemas/quiz'

type QuizParseSuccess = z.infer<typeof quizSchema>
```

> **Note** — `import * as z from "zod"` への変更は却下。公式の注意は esbuild でバンドルする一部のケース向け。本番は Vite 7 + Rollup。記録は [`../../backlog.md`](../../backlog.md) の REJECTED。

## Parsing data

信頼できない JSON には `.parse` ではなく `.safeParse` を使う。`web/src/api/client.ts` の `requestJson` がこの結果を `ApiError` に正規化する。

```ts
const result = quizSchema.safeParse(input)
if (!result.success) {
  result.error.issues
} else {
  result.data
}
```

> **Note** — このアプリは throw する `.parse()` を公開 API 境界では使わない。失敗時に starter クイズへフォールバックするため。

## Handling errors

失敗時の `issues` は `path` と `message` を持つ。`correctAnswerIndex` が選択肢の個数以上なら refine が `path: ['correctAnswerIndex']` を付ける。

```ts
const result = quizSchema.safeParse(invalidQuiz)
if (!result.success) {
  result.error.issues[0]?.path
  // => ['correctAnswerIndex']
}
```

UI への載せ方は [`error-formatting.md`](./error-formatting.md)。

## Inferring types

```ts
type QuizParseSuccess = z.infer<typeof quizSchema>
```

`as Quiz` で外部 JSON を通さない。入力と出力が分かれる transform は公開 quiz schema では使っていない。
