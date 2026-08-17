# bench

Zod の [`packages/bench`](https://github.com/colinhacks/zod/tree/main/packages/bench) と同じ置き場。測るのは実行速度（ops/sec）であり、バンドルサイズ（kB）ではない。kB は手元の `scratch/input.ts`（[ADR 0010](../../docs/adr/0010-scratch-input-bundle-size.md)）。

```bash
npm run bench
npm run bench -- quiz-parse
```

公開契約の fixture を、本番と同じ `packages/web` の `quizSchema` で parse する。Valibot / ArkType は入れない。このアプリが使う Zod だけを測る。
