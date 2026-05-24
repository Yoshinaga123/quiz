# 実装ポリシー1: 外部APIレスポンスの検証

## 基本方針
他社が提供している外部APIを利用する場合は、レスポンスをそのまま信用せず、Zod または TypeScript ベースのランタイムバリデーションで検証する。

## なぜ必要か
- TypeScriptの型保証はコンパイル時のみ有効で、実行時データの型は保証しない
- API仕様変更やエラー発生で、期待しない値が返ってくる可能性がある
- 早い段階で不正データを検知し、障害を早期に食い止める

## 運用ルール
- `fetch`の直後で Zod の `safeParse()` または TypeScript の型ガード/アサーション関数による検証を実行する
- 失敗時はUIにフォールバック表示を行い、ログを残す
- 外部APIのレスポンス型は Zod の `z.infer<typeof Schema>` または TypeScript の `type` / `interface` と型ガードから導出する
- `as SomeType` のみで通過させない

## 最小実装例
```ts
type User = {
	id: number;
	name: string;
};

function isUser(value: unknown): value is User {
	if (typeof value !== "object" || value === null) {
		return false;
	}

	const candidate = value as Record<string, unknown>;
	return typeof candidate.id === "number" && typeof candidate.name === "string";
}

export async function fetchUser(apiUrl: string): Promise<User> {
	const res = await fetch(apiUrl);
	if (!res.ok) {
		throw new Error(`HTTP error: ${res.status}`);
	}

	const json: unknown = await res.json();
	if (!isUser(json)) {
		throw new Error("Invalid API response format");
	}

	return json;
}
```

## 例外
完全に自社管理のAPIでも、境界（BFF/外部接続）を跨ぐ場合は原則バリデーションする。

# 実装ポリシー2: フロントエンドアーキテクチャ選定

## 基本方針
徹底的なパフォーマンス最適化を行う。ただし、特定技術を先に決め打ちせず、プロダクト特性（コンテンツ駆動 / インタラクション駆動）に合わせてアーキテクチャを選定する。

## なぜ必要か
- アーキテクチャには銀の弾丸がなく、用途不一致は実装コストと運用コストを増やす
- 体感速度は「初回表示」だけでなく「操作時の応答性」に強く依存する
- 適材適所で選定すると、最小の複雑性で最大の効果を得られる

## 選定ルール
- コンテンツ駆動（記事・商品一覧中心、更新頻度低め）:
	Next.js App Router（RSC）や Astro を優先検討する
- インタラクション駆動（フォーム、管理画面、クイズ等で state 更新が多い）:
	Vite + React SPA を第一候補にする
- ほぼ静的で一部だけ動的:
	Astro Islands を検討する
- RSC は「ゼロHydration」ではなく「選択的Hydration」が正確な理解である

## 技術別の要点
- Vite + React SPA:
	開発体験が良く、状態管理中心のUIで実装が素直
- Next.js + RSC:
	Server Components で使用するライブラリをクライアントへ送らず、バンドル削減に効く
- Astro:
	静的配信を主軸に、必要箇所のみインタラクティブ化できる

## このプロジェクトでの判断
- 対象: クイズアプリ（回答、採点、フィードバックなど操作中心）
- 判定: インタラクション駆動のため Vite + React SPA を採用する
- 理由:
	問題データが静的 JSON であり、RSC の DB 直アクセスメリットが小さい
	画面の多くが動的更新されるため Astro Islands の恩恵が限定的

## 実装順序（最適化の優先度）
1. まず SPA 構成を維持したまま計測する（LCP, INP, bundle size）
2. `React.memo` / `useMemo` / `React.lazy`（コード分割）を適用する
3. それでも要件を満たせない場合のみ、RSC や Astro への移行を検討する

## 施策採用基準（計測前提）
- State Colocation:
	良い習慣だが、パフォーマンス改善として採用する場合は「不要な再レンダリング伝播」が実測で確認できていることを前提にする
- Zustand/Jotai などのグローバル状態管理:
	強推奨しない。共有状態の複雑性が実際のボトルネックだと確認できた場合のみ導入を検討する
- Code Splitting:
	方向性は正しいが、効果はアプリ規模に依存する。初期バンドルサイズや LCP/INP の悪化が計測で確認できた場合に優先して実施する

## アンチパターン
- 計測なしで状態管理ライブラリを先に導入する
- 「最新技術だから」という理由だけでアーキテクチャを変更する
- 小規模アプリで分割しすぎ、通信回数増加で逆効果にする

# 実装ポリシー3: 設定管理

## 基本方針
- 環境ごとに変わる設定値はコードへ直書きせず、コード外へ分離する
- 原則は The Twelve-Factor App の Config に従う
- 参照: https://12factor.net/ja/config

## このプロジェクトで外出しする対象
- `DB_HOST` / `DB_PORT` / `DB_USER` / `DB_PASSWORD` / `DB_NAME`
- `ADMIN_USER` / `ADMIN_PASSWORD`
- `JWT_SECRET`
- `QUIZ_SEED_GENERATOR_SCRIPT`
- frontend の API base URL など、環境によって変わる接続先

## コードに置いてよいもの
- ルーティングや初期化順序など、アプリの構造そのもの
- ドメインルールや固定仕様
- seed データそのもの (`quizzes.production.json` など)

## 運用ルール
- ローカル開発では `.env.example` を配布し、各自が `.env` を作る
- 本番機密値はリポジトリに commit しない
- `dev/stg/prod` のような環境名で設定をグルーピングせず、変数を独立に管理する
- デフォルト値をコードに置く場合は、ローカル開発で安全な値に限定する

## エラーメッセージ方針
- エラーメッセージは verbose に記述する
- 英語と日本語を併記し、英語を先、日本語を後に置く
- 英語は検索性・ログ解析を優先し、日本語は開発者への説明を補う
- 可能なら 1 行目に英語の要約、2 行目に日本語の説明を書く
- 対処方法が明確な場合は、日本語で次の行動も補足する

# 実装ポリシー4: コーディング方針

## 基本方針
- ソースコードは AI が好むモダンで宣言的な記法を是とする
- ただし、パフォーマンスは徹底的にやる。妥協しない
- 個人開発なので、可読性という物差しは排除する
- 徹底的に省メモリ開発を行う

## React原則

### 高パフォーマンス実現の7原則
1. メモ化
`memo` / `useMemo` / `useCallback` で再計算・再レンダリングを防ぐ

2. 状態の最小化
派生データは state に持たず、`useMemo` で計算する

3. 不変性の徹底
直接変更せず、`filter` / `map` / `reduce` で新しい値を返す

4. 遅延評価
重い初期値は `useState(() => expensiveInit())` で初回だけ計算する

5. 更新関数パターン
`setCount(prev => prev + 1)` の形で常に最新の値を参照する

6. 早期リターン
ネストを排除してフラットに書く

7. 型による最適化
`as const` で不変オブジェクトを明示し、型を厳密に保つ

## TypeScript原則
- 型推論に頼りすぎず、戻り値の型は明示する
- `any` を禁止する
- `as const` で不変オブジェクトを明示する

## Go原則
- エラーは必ず処理する。無視しない
- 早期リターンでネストを排除する
- インターフェースは小さく保つ
- ゴルーチンは `context` でキャンセル可能にする
- 責務でパッケージを分ける

## C++原則
C++ Core Guidelines に準拠する。

- 定数は `#define` を使わず `constexpr` で定義する（Con.5, ES.31）
- `enum class` を使う。単純な `enum` は使わない（Enum.1, Enum.3）
- `enum class` の基底型はデフォルト（`int`）を使い、変える理由がある場合のみ変更する（Enum.6）
- 外部に公開しない要素（定数・関数・型）はすべて無名名前空間に入れる（SF.22）
- 変数名の長さはスコープの大きさに比例させる（NL.7）
- 一貫した命名スタイルを使う（NL.8）

## ファイル・コンポーネント設計の方針
- 1ファイル1コンポーネントを原則とする
- ロジックはカスタムフックに切り出す
- UI とロジックを分離する
- 「使い回せそう」という理由だけで `utils/` などの共有ディレクトリへ移さず、利用元と同じディレクトリにユーティリティ関数を置く。元ファイルが削除された際にユーティリティとテストだけが残る事故を防ぎ、必要な場所から存在を即座に確認できるようにする

## 計測に関する方針
- 最適化の前に React DevTools Profiler で計測する
- 体感できない最適化はしない

## 状態管理の方針
- グローバル state は最小限にする
- サーバーの状態とクライアントの状態を分けて考える

# 実装ポリシー5: Google Search Central 準拠

## 基本方針
公開 Web アプリは、Google Search Central のガイドラインに準拠することを前提に設計・実装する。特に JavaScript を多用する画面では、「Google に発見される URL 構造」「クロール可能なリンク」「適切なインデックス制御」を最初から要件に含める。

## なぜ必要か
- JavaScript アプリでも、検索エンジンに発見・クロール・理解される前提を外すと、公開ページの流入と到達性を損なう
- Google Search Central は、SPA でもフラグメントではなく History API を使うこと、意味のある HTTP ステータスコードを返すことなどを明示している
- SEO は検索順位だけでなく、検索エンジンが URL と内容を正しく解釈できる最低限の技術要件でもある

## 実装ルール
- 公開ページの内部導線は、`href` を持つ `<a>` 要素でクロール可能にする
- SPA のクライアントルーティングでは、`#/path` のようなフラグメント遷移ではなく History API ベースの URL を使う
- 404 / 401 / 301 など、ページ状態に応じた意味のある HTTP ステータスコードを返す
- CSR で適切なステータスコードが返せないエラーページは、少なくとも `noindex` などで誤インデックスを防ぐ
- 初期 HTML とレンダリング後 HTML の両方で、検索対象コンテンツが確認できるようにする
- タイトル、メタデータ、構造化データ、内部リンクを公開ページごとに設計する
- コンテンツは search engine-first ではなく people-first を原則とする

## アーキテクチャ判断ルール
- 管理画面や認証必須画面のように検索流入が不要な UI は、このポリシーの優先度を下げてよい
- 一方で公開ページ、LP、記事、商品・サービス詳細など検索流入が要件に入る画面では、このポリシーを必須要件とする
- SPA で Search Central 準拠を満たしにくい場合は、SSR / SSG / prerender を含めて構成を再評価する

## 参照
- Google Search Central: JavaScript SEO basics
  https://developers.google.com/search/docs/crawling-indexing/javascript/javascript-seo-basics
- Google Search Central: SEO Starter Guide
  https://developers.google.com/search/docs/fundamentals/seo-starter-guide
- Google Search Central: Creating helpful, reliable, people-first content
  https://developers.google.com/search/docs/fundamentals/creating-helpful-content

# 実装ポリシー6: 入力バリデーションとエラー契約

## 基本方針
クイズアプリの入力検証は、`admin-web` と `mobile` では UX 改善のために、`backend` ではセキュリティと整合性保証のために行う。最終判定は常に `backend` が担当する。

## なぜ必要か
- `admin-web` や `mobile` のローカル検証だけでは改ざんや不正リクエストを防げない
- クエリパラメータ、JSON ボディ、API レスポンスは境界をまたぐため shape の崩れが障害になりやすい
- 入力ミスと一時的障害を分けて扱わないと、UI も運用ログも不安定になる

## 実装ルール
- フォーム入力は `admin-web` で Zod による事前検証を行う
- API レスポンスは `admin-web` 側でランタイム検証する
- `backend` はパス、クエリ、JSON ボディを入口で検証し、業務ルール検証はその先で行う
- 書き込み系 API は未知フィールド拒否を基本とする
- エラーは利用者向け `message` と機械可読な `code` を持たせる
- `required`、`optional`、`nullable` を区別し、何でも `null` 許容にしない

## 詳細
詳細ルールは [validation-policy.md](./validation-policy.md) を参照する。

# 実装ポリシー7: 初期化の責務と順序

## 基本方針
初期化は暗黙依存にせず、どこで何を初期化するかを明示する。constructor や build/render に重い初期化や非同期 I/O を押し込まない。

## なぜ必要か
- 起動順序が曖昧だと、`late` 未初期化やセッション復元漏れが起きやすい
- `admin-web`、`backend`、`mobile` で初期化境界が違うため、ルールがないと責務が混ざる
- テスト時に依存差し替えしにくくなる

## 実装ルール
- 非同期初期化は `init()`、factory、loader、provider など明示的な境界で行う
- 起動不能な初期化失敗は握りつぶさず停止または再試行へ寄せる
- グローバル状態や singleton の初期化箇所は 1 か所に固定する
- `late` は代入前に読まれないことを保証できる場合だけ使う

## 詳細
詳細ルールは [initializer.md](./initializer.md) を参照する。
