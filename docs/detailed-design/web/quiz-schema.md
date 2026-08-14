# web quiz Zod schema

基本設計: [`../../api/public-quiz-api.yaml`](../../api/public-quiz-api.yaml)（`Quiz`）、[`../../adr/0006-public-quiz-api.md`](../../adr/0006-public-quiz-api.md)、[`../../implement-policy.md`](../../implement-policy.md)

実装: `web/src/schemas/quiz.ts`  
テスト: `web/tests/schemas/quiz.test.ts`、`web/tests/contract/public-api.test.ts`  
例: [`../../api/fixtures/`](../../api/fixtures/README.md)（`quiz.json` / `quiz-invalid-answer-index.json`）  
試し書き: `web/scripts/try-quiz-parse.ts`（本番スキーマに残さない）

## OpenAPI と 1:1 にできるもの

`id` / `section` / `title` / `question` / `options`（min 2）/ `correctAnswerIndex`（>= 0）/ `explanation` / `source` / 任意の `code`。

型は `z.infer<typeof quizSchema>`（`QuizParseSuccess`）から取る。

## OpenAPI に書けない業務ルール

正解番号は選択肢の個数未満であること。

```ts
.refine(
  ({ correctAnswerIndex, options }) =>
    correctAnswerIndex >= 0 && correctAnswerIndex < options.length,
  { path: ['correctAnswerIndex'], message: 'correctAnswerIndex is out of range' },
)
```

yaml 側は description のみ。shape を変えたら OpenAPI・[`fixtures`](../../api/fixtures/README.md)・このファイル・テストを同じ差分で直す。手順は [`public-contract.md`](./public-contract.md)。
