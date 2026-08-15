# scratch

バンドルサイズ（kB）実験用。入口の名前は [`docs/adr/0010-scratch-input-bundle-size.md`](../docs/adr/0010-scratch-input-bundle-size.md) で **`input.ts`** に固定している。

```bash
npm run scratch:measure
```

`input.ts` は本番と同じ `import { z } from "zod"`。比較用の `import * as z` は計測スクリプトが一時ファイルでだけ使う。`web/` / `admin-web/` は書き換えない。

結果は [`RESULTS.md`](./RESULTS.md)。出力 JS（`out_rollup.js` など）は gitignore。

振る舞いの試し書きはここではなく、ルートの `play.ts` や `web/scripts/` へ。
