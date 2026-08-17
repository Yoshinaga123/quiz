# Linting Policy

## 品質方針

本プロジェクトは、金融・医療などの **品質要件が極めて高い領域** を想定して実装します。
そのため、可読性よりも安全性・予測可能性・保守性を優先し、静的解析で検出できるリスクは原則としてビルド前に排除します。
また、高パフォーマンス要件を満たすためにも lint 設定を緩和せず、設計時点で不要な再実行・暗黙的な変換・運用時デバッグコードの混入を防止します。

この方針に基づき、次を必須運用とします。

- `npm run lint` が 0 errors であること
- TypeScript の strict モードを維持すること
- non-null assertion (`!`)・`any`・暗黙的な型変換に依存しないこと
- 本番コードへの `console` 出力を残さないこと

## 概要

このプロジェクトでは ESLint + TypeScript ESLint を使用してコード品質を担保します。
`eslint.config.js` は **strict モード**で構成されており、`recommended` より多くのルールをエラーとして扱います。

---

## 使用プリセット

| プリセット | 説明 |
|---|---|
| `js.configs.recommended` | ESLint 組み込みの基本ルール |
| `tseslint.configs.strict` | `recommended` より厳格。`any` 禁止・non-null assertion 禁止など |
| `tseslint.configs.stylistic` | インポート型の一貫性・配列型記法など、スタイル統一ルール |
| `reactHooks.configs.flat.recommended` | `useEffect` 依存配列の漏れ検出など React Hooks ルール |
| `reactRefresh.configs.vite` | Vite HMR との互換性チェック |

---

## カスタムルール一覧

### TypeScript

| ルール | レベル | 理由 |
|---|---|---|
| `@typescript-eslint/no-explicit-any` | error | `any` は型安全を破壊するため禁止 |
| `@typescript-eslint/consistent-type-imports` | error | `import type` を強制してバンドルサイズ最適化 |
| `@typescript-eslint/no-non-null-assertion` | error | `!` による非 null アサーションは実行時エラーの温床 |
| `@typescript-eslint/no-unused-vars` | error | 使われていない変数・引数は削除する |

### JavaScript 汎用

| ルール | レベル | 理由 |
|---|---|---|
| `eqeqeq` | error | `==` の暗黙型変換バグを防ぐ。`===` を強制 |
| `no-console` | error | 本番コードへの `console.log` 混入を禁止 |
| `no-implicit-coercion` | error | 暗黙的な型変換を避け、可読性と予測可能性を担保 |
| `no-restricted-syntax` (for...in) | error | オブジェクトの意図しないプロトタイプチェーン列挙を防ぐ |

---

## TypeScript コンパイラ設定

共有の [`../tsconfig.base.json`](../tsconfig.base.json) は Zod の [`.configs/tsconfig.base.json`](https://github.com/colinhacks/zod/blob/main/.configs/tsconfig.base.json) と同じフラグを置く。`exclude` は `node_modules`。`packages/web/` と `packages/admin-web/` の `tsconfig.app.json` がこれを継承し、Vite 用に `moduleResolution: "bundler"` と `jsx: "react-jsx"` だけ上書きする。

| オプション | 値 | 効果 |
|---|---|---|
| `strict` | `true` | strictNullChecks / noImplicitAny などを一括有効化 |
| `alwaysStrict` | `true` | 各ファイルを strict mode として扱う（`strict` に含まれる） |
| `noUncheckedIndexedAccess` | `false` | 添字アクセスに `| undefined` を足さない（Zod と同じ） |
| `exactOptionalPropertyTypes` | `true` | 任意プロパティへ `undefined` を代入しない。無いキーは省略する |
| `noImplicitReturns` | `true` | 戻り値の抜けをエラー |
| `noImplicitOverride` | `true` | 上書きには `override` を要求 |
| `noUnusedLocals` | `true` | 未使用ローカル変数をエラー |
| `noUnusedParameters` | `true` | 未使用パラメータをエラー |
| `noFallthroughCasesInSwitch` | `true` | switch のフォールスルーをエラー |
| `noUncheckedSideEffectImports` | `true` | 副作用 import の未チェックを検出（Vite 側） |
| `erasableSyntaxOnly` | `true` | 型消去できない構文（enum 等）を禁止（Vite 側） |

---

## lint の実行

```bash
# 静的解析のみ
npm run lint

# 自動修正可能なものを修正
npm run lint -- --fix
```
