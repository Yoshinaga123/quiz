# quizzes.json 品質レビュー

対象:

- `packages/admin-web/src/data/quizzes.json`

レビュー日:

- 2026-05-06

## 結論

構造面の品質は良い。

- JSON として妥当
- `lint_quizzes.py` は通過
- ID 重複なし
- `(section, title)` 重複なし

一方で、**内容品質は `source` の扱いに大きな課題がある**。

特に問題なのは次の 3 点。

1. 出典が URL ではなく曖昧な短いラベルのものが大量にある
2. 出典がリポジトリ内ファイル名になっているものが多い
3. 日付やバージョンを含む時事性のある主張なのに、出典から検証できないものがある

## 機械集計

- 総問題数: 586
- `search_fallback` 扱いの `source`: 491
  - `sourceLinks.ts` にマッピングがなく、プレビューでは DuckDuckGo 検索リンクにフォールバックする値
- リポジトリ内ファイル参照を含む `source`: 126
- 直接 URL の `source`: 82
- `sourceLinks.ts` で明示マップ済みのラベル: 13
- 時事性ありと判定した問題: 8
- 選択肢数が 4 件でない問題: 1

## 優先度

### P1: 先に直すべきもの

#### 1. 出典と主張が噛み合っていない問題

- `id: 225`
  - タイトル: `Googlebot の JS レンダリング ファイルサイズ制限の変更`
  - 行: `3587`
  - 問題: 2026年2月に 15MB から 50MB へ変更と断定しているが、記載された出典 URL からその事実を検証できない

これは単なる「出典が雑」ではなく、**正誤判定の根拠が崩れている**ので最優先。

#### 2. リポジトリ内ファイルを出典にしている問題群

代表例:

- `id: 31` 行 `483`
- `id: 33` 行 `515`
- `id: 37` 行 `579`
- `id: 129` 行 `2051`
- `id: 133` 行 `2115`
- `id: 146` 行 `2323`
- `id: 152` 行 `2419`
- `id: 163` 行 `2595`
- `id: 166` 行 `2643`
- `id: 221` 行 `3523`

問題:

- `view-counter/frontend/src/components/ViewCounter.tsx`
- `packages/backend/main.go - main()`
- `packages/admin-web/src/layouts/AdminLayout.tsx / packages/admin-web/src/App.tsx`

のような書き方は、問題文の元ネタではあっても、**出典**としては弱い。
要件では高品質なドキュメント由来が求められているため、少なくとも次のどちらかに統一したほうがよい。

- 公式ドキュメント URL を `source` に置く
- ローカル実装を題材にする場合でも、根拠となる仕様 URL を併記する

#### 3. 時事性があるのに URL で固定されていない問題

代表例:

- `id: 163`
  - `Go 1.22 release notes` を文字列で参照しているが URL ではない
- `id: 461`
  - `Python 3.13 以降の GIL の扱い`
  - `PEP 703 / Python 3.13 release notes` という文字列のみ
- `id: 571`
  - `Python 3.14 の NotImplemented の真偽値評価`
  - `Python 3.14 data model / built-in constants / NotImplemented` という文字列のみ

時事性がある問題は将来の再検証が必要になるため、検索ワードではなく固定 URL にすべき。

### P2: 次に直すべきもの

#### 4. `sourceLinks.ts` に依存した曖昧ラベルの大量利用

例:

- `React Official Documentation`
- `TypeScript Handbook`
- `React StrictMode`
- `Build Optimization`
- `JavaScript Async`

これらは人間には意味が通るが、**データ単体では URL に解決できない**。
しかも現状、`sourceLinks.ts` のマップで拾えるのは一部だけで、ほとんどは検索フォールバックになる。

改善方針:

- `source` 自体を URL に寄せる
- もしくは `sourceLabel` と `sourceUrl` を分離する

#### 5. 選択肢数が 3 件の問題

- `id: 29`
  - 行: `452`

構造上は許容されているが、他がほぼ 4 択なので体験が不揃い。

### P3: 余裕があれば直すもの

#### 6. `code` フィールド省略の揺れ

- `code: ""` の問題と、`code` 自体が存在しない問題が混在している

スキーマ上は許容されているため不具合ではないが、運用は揃えたほうがよい。

## 修正順の提案

1. `id: 225` を修正または一時除外
2. `source` がリポジトリ内ファイル参照の 126 件を URL ベースへ差し替え
3. バージョン・年月を含む問題の `source` を固定 URL に置換
4. `sourceLinks.ts` 依存の曖昧ラベルを削減
5. `id: 29` の選択肢数を 4 件に揃える

## 実務上の提案

今の `source: string` 1 本だと、表示名と検証用 URL の責務が混ざっている。

長期的には次の形がよい。

```json
{
  "sourceLabel": "React StrictMode",
  "sourceUrl": "https://react.dev/reference/react/StrictMode"
}
```

この形にすると:

- データ単体で監査できる
- UI で検索フォールバックに頼らずリンク化できる
- 「高品質なドキュメントから引用」の要件を保ちやすい
