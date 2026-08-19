-- Migration: seed quizzes from quizzes.production.json
-- Generated: 2026-08-19

INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source, status, push_enabled)
VALUES
  (1, 'セクション1: React & TypeScript ', 'useEffect 依存配列と関数参照', '以下のコードについて、最も正しい説明はどれですか？', 'const fetchUser = useCallback(async () => {
  const res = await fetch(`/api/users/${userId}`);
  const data = await res.json();
  setUser(data);
}, [userId]);

useEffect(() => {
  fetchUser();
}, [fetchUser]);', '["`fetchUser` を依存配列に入れると常に無限ループになる", "`useCallback` で `fetchUser` を安定化し、`[fetchUser]` を依存配列に入れると `userId` 変更時に再実行されるため `exhaustive-deps` の意図に沿う", "`useEffect(..., [])` にしても同じ挙動で、常に最新の `userId` を参照できる", "cleanup 関数は初回マウント前に必ず1回実行される"]'::jsonb, 1, '`fetchUser` は `useCallback(..., [userId])` により `userId` が変わると新しい参照になります。Effect 側を `[fetchUser]` にすると、結果として `userId` 変化に追従しつつ、依存関係を正しく宣言できます。`[]` にすると古い `userId` を閉じ込める（stale closure）リスクがあります。', 'https://react.dev/reference/react/useEffect#specifying-reactive-dependencies', 'unpublished', false),
  (2, 'セクション1: React & TypeScript ', '関数型コンポーネントの State 更新', '以下の useState の使用について、誤っているのはどれですか？', 'const [state, setState] = useState({ count: 0, name: "test" });
setState(prev => ({ ...prev, count: 1 }));', '["前のstate とマージしないと、name プロパティが失われる", "setState に更新関数を渡す形式では、直前の state を参照できない", "setState は非同期で実行されるため、即座に state は更新されない", "setState 後、即座に console.log(state) を実行すると古い値が出力される"]'::jsonb, 1, '誤っているのは「更新関数を渡す形式では直前の state を参照できない」という記述です。実際には `setState(prev => ({ ...prev, count: prev.count + 1 }))` のように更新関数の引数 `prev` を通じて直前の state を安全に参照できます（`() => prev` のように引数を取らない書き方では参照できないため、引数を受け取ることが必須です）。残りの選択肢（マージしないと name が失われる／setState は非同期で即時反映されない／直後の console.log は古い値を出力する）はいずれも正しい記述です。', 'https://react.dev/reference/react/useState#updating-state-based-on-the-previous-state', 'unpublished', false),
  (3, 'セクション1: React & TypeScript ', 'TypeScript の Generic について', 'React コンポーネントで Generic を使う際、以下の記述で型推論が正しく機能するのはどれですか？', 'interface Props<T extends { id: number }> {
  items: T[];
  onSelect: (item: T) => void;
}', '["T の型は自動推論される", "T extends { id: number } により、id プロパティを持つ型のみが使用可能", "props の型が正確に定義される", "すべてが正しい"]'::jsonb, 3, '型引数に `T extends { id: number }` の制約を付けると、`id` を持つ型だけを受け付けつつ、`items` の要素型や `onSelect` の引数型を呼び出し側で渡した具体的な型から推論できます。したがって、T は使用時に推論され、id を持つ型のみが許可され、props の型も正確に定まります。よって選択肢はいずれも正しく、答えは『すべて正しい』です。', 'https://www.typescriptlang.org/docs/handbook/2/generics.html', 'unpublished', false),
  (4, 'セクション2: ビルドツール & Asset 管理', 'Vite での Asset 読み込み', '以下のファイル配置について、fetch(''/data.json'') でHTTPアクセス可能なのはどれですか？', '// 例1: public/data.json は HTTP で直接取得できる
const res = await fetch(''/data.json'');

// 例2: src/data/data.json は import で利用する（fetch での直アクセス前提ではない）
import localData from ''./data/data.json'';', '["src/data/data.json", "public/data.json", "dist/data.json", "いずれでも可能"]'::jsonb, 1, 'ソースコードから参照されないアセット、まったく同じファイル名を保つ必要があるアセット、または URL を得るためだけに最初に import したくないアセットは、プロジェクトルート配下の特別な `public` ディレクトリに置くことができます。このディレクトリ内のアセットは、開発時にはルートパス `/` で配信され、`dist` ディレクトリのルートへそのままコピーされます。`public` アセットは常にルート絶対パスで参照する必要があるため、`public/data.json` は `/data.json` として取得します。', 'https://vite.dev/guide/assets#the-public-directory', 'unpublished', false),
  (5, 'セクション2: ビルドツール & Asset 管理', 'src vs public 方式の使い分け', '動的にコンテンツを読み込みたい場合、最適な配置方式はどちらですか？', '// 複数の quiz.json from サーバー', '["src/data/ にすべてバンドル", "public/ フォルダに複数ファイル保存", "バックエンド API から取得", "TypeScript enum で定義"]'::jsonb, 2, 'Vite の `public` ディレクトリは、「ソースコードから参照されないアセット」「まったく同じファイル名を保つ必要があるアセット」「URL を得るためだけに import したくないアセット」を置くためのものです。一方で Fetch API は、「ネットワーク越しを含むリソースを取得するためのインターフェース」を提供します。したがって、内容が固定ファイルではなく動的に変わるコンテンツを読み込みたい場合は、`public` に複数 JSON を置くより、バックエンド API から取得する方が問題文の意図に合っています。', 'https://vite.dev/guide/assets#the-public-directory', 'unpublished', false),
  (6, 'セクション2: ビルドツール & Asset 管理', 'モジュールと非モジュール読み込み', 'JSON を import vs fetch で読み込む場合の違いはどれですか？', 'import quizzes from ''./quizzes.json'';
const res = await fetch(''/api/quizzes.json'');', '["取得タイミングが異なる", "バンドルサイズが変わる", "ビルド時最適化が異なる", "すべて正しい"]'::jsonb, 3, 'import はビルド時に解析され、fetch は実行時に取得します。バンドルサイズと最適化方法が異なります。', 'https://vite.dev/guide/features#json', 'unpublished', false),
  (7, 'セクション3: コンポーネント設計', 'Props Drilling 問題', '深くネストされたコンポーネント構造で、親の state を孫に渡す際の推奨方法はどれですか？', '// 3層のコンポーネントがある場合', '["複数の Props でバケツリレーする", "Context API を使用する", "Redux などの状態管理ツール", "React.memo でラップする"]'::jsonb, 1, '深くネストされた構造で親の state を孫へ渡す場合は、Props drilling を避けるため Context API が有力です。Redux などの状態管理ツールは、より広域で複雑な共有状態がある場合の選択肢であり、この問いの第一回答ではありません。React.memo は再レンダリング最適化の手段であり、state の受け渡し方法そのものではありません。

浅いツリーの場合の具体コード:
function Parent() {
  const [count, setCount] = useState(0)
  return <Child count={count} setCount={setCount} />
}

function Child({ count, setCount }) {
  return <GrandChild count={count} setCount={setCount} />
}

function GrandChild({ count, setCount }) {
  return <button onClick={() => setCount(count + 1)}>{count}</button>
}

深いツリーの場合の具体コード:
const CountContext = createContext(null)

function Parent() {
  const [count, setCount] = useState(0)
  return (
    <CountContext.Provider value={{ count, setCount }}>
      <Child />
    </CountContext.Provider>
  )
}

function GrandChild() {
  const { count, setCount } = useContext(CountContext)
  return <button onClick={() => setCount(count + 1)}>{count}</button>
}

複雑状態での具体コード:
const useQuizStore = create((set) => ({
  count: 0,
  selectedIds: [],
  increment: () => set((state) => ({ count: state.count + 1 })),
  toggleSelected: (id) =>
    set((state) => ({
      selectedIds: state.selectedIds.includes(id)
        ? state.selectedIds.filter((item) => item !== id)
        : [...state.selectedIds, id],
    })),
}))

function GrandChild() {
  const count = useQuizStore((state) => state.count)
  const increment = useQuizStore((state) => state.increment)
  return <button onClick={increment}>{count}</button>
}', 'https://react.dev/learn/passing-data-deeply-with-context', 'unpublished', false),
  (8, 'セクション3: コンポーネント設計', 'Controlled vs Uncontrolled Component', 'フォーム入力を React で管理する際、state で値を制御する方式の名称はどれですか？', '<input value={name} onChange={(e) => setName(e.target.value)} />', '["Uncontrolled Component", "Controlled Component", "Ref Component", "Form Component"]'::jsonb, 1, 'state で値を管理し、onChange で更新する方式が Controlled Component です。', 'https://react.dev/reference/react-dom/components/input#controlling-an-input-with-a-state-variable', 'unpublished', false),
  (9, 'セクション3: コンポーネント設計', 'React.memo の使用シーン', 'React.memo でコンポーネントをラップする場合の効果はどれですか？', 'const MemoizedList = React.memo(ListComponent);', '["props が同じなら再レンダリングをスキップ", "必ずレンダリングスキップされる", "メモリ使用量が削減される", "TypeScript の型チェックが厳しくなる"]'::jsonb, 0, 'React.memo は props の浅い比較で再レンダリングをスキップします。', 'https://react.dev/reference/react/memo', 'unpublished', false),
  (10, 'セクション4: 非同期処理パターン', 'Promise.all vs Promise.allSettled', '複数の API 呼び出しについて、全件の成功を待ち、1つでも失敗したら全体を reject したい場合に使うメソッドはどれですか？', 'Promise.all([fetch(url1), fetch(url2), fetch(url3)])', '["Promise.race", "Promise.all", "Promise.any", "Promise.allSettled"]'::jsonb, 1, 'Promise.all は、すべての入力 Promise が fulfill されたときにのみ fulfill され、1つでも reject されると即座に reject されます。一方 Promise.allSettled は、成功・失敗にかかわらずすべての Promise が settle するまで待ち、各結果を配列で返します。', 'https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise/all', 'unpublished', false),
  (11, 'セクション4: 非同期処理パターン', 'async/await のエラーハンドリング', '複数の async 処理をシーケンシャルに実行し、エラーが発生した時点で停止する場合の書き方は？', 'try {
  const data = await fetchUser();
  const posts = await fetchPosts(data.id);
} catch (err) { ... }', '["Promise チェーン", "async/await + try/catch", "async/await + catch メソッド", "コールバック地獄"]'::jsonb, 1, 'async/await + try/catch は読みやすく、エラーハンドリングが容易です。', 'https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/async_function', 'unpublished', false),
  (12, 'セクション5: TypeScript 型システム', 'Union Type vs Intersection Type', '以下の型定義について、値が持つべきプロパティはどれですか？', 'type A = { name: string; age: number };
type B = { email: string };
type Result = A & B;', '["name か email のいずれか", "name, age, email のすべて", "age のみ", "name のみ"]'::jsonb, 1, 'Intersection Type (A & B) は両方の型を『すべて』持つ必要があります。', 'https://www.typescriptlang.org/docs/handbook/2/objects.html#intersection-types', 'unpublished', false),
  (13, 'セクション5: TypeScript 型システム', 'Partial と Required ユーティリティ型', 'すべてのプロパティをオプショナルにするユーティリティ型はどれですか？', 'type User = { name: string; age: number };
type OptionalUser = Partial<User>;', '["Required", "Partial", "Pick", "Record"]'::jsonb, 1, 'Partial<T> はすべてのプロパティをオプショナル（? がつく）に変換します。', 'https://www.typescriptlang.org/docs/handbook/utility-types.html#partialtype', 'unpublished', false),
  (14, 'セクション5: TypeScript 型システム', 'keyof と Mapped Type', '`User` 型の各キーをそのまま使い、値の型だけをすべて `boolean` にした新しい型を作るには？', 'type User = { name: string; age: number };
type Flags = { [K in keyof User]: boolean };', '["Pick", "Omit", "Mapped Type", "Union"]'::jsonb, 2, '`keyof User` で `name | age` のようなキーのユニオン型を取り出し、`[K in keyof User]` で各キーを順にたどれます。そこで各プロパティの値の型を `boolean` に置き換えると、`{ name: boolean; age: boolean }` のような新しい型を作れます。これは Mapped Type の基本パターンです。

ユーザー目線で実現できる機能の例:
- プロフィール編集画面で、各項目が「編集中かどうか」を `name: true`, `age: false` のように管理できる
- バリデーション結果を、各入力欄ごとに「エラーあり / なし」で持てる
- 管理画面で、各列や各設定項目の ON/OFF 状態を元のデータ構造に合わせて安全に管理できる
- フォーム送信時に、どの項目を変更したか、どの項目を無効化するかを同じキー構造で扱える

つまり Mapped Type を使うと、元データと同じ項目構成を保ったまま、UI 用の状態や設定フラグを自動的に作れるため、画面機能を増やしても型のズレを減らせます。', 'https://www.typescriptlang.org/docs/handbook/2/mapped-types.html', 'unpublished', false),
  (15, 'セクション6: エラーハンドリング戦略', 'try/catch で複数エラー型を処理', 'fetch エラーと JSON parse エラーを区別する方法はどれですか？', 'try { ... } catch (err) { if (err instanceof SyntaxError) ... }', '["Error.message で文字列判定", "instanceof で型チェック", "err.code を参照", "手動で throw-catch"]'::jsonb, 1, 'instanceof はエラーの実際の型をチェックできます。', 'https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/instanceof', 'unpublished', false),
  (16, 'セクション6: エラーハンドリング戦略', 'カスタムエラークラス', 'ビジネスロジック固有のエラーを表現するための推奨パターンは？', 'class ValidationError extends Error { constructor(msg) { super(msg); } }', '["Error を拡張してカスタムクラスを作成", "単なる Error を throw する", "文字列を throw する", "undefined を throw する"]'::jsonb, 0, 'Error を継承してカスタムクラスを作ることで、エラーの種類を明確にできます。', 'https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Error', 'unpublished', false),
  (17, 'セクション7: パフォーマンス最適化', 'useMemo vs useCallback', '関数の参照を保持して再作成を避けたい場合に使用するフックはどれですか？', 'const memoizedCallback = useCallback(() => { doSomething() }, [dep]);', '["useMemo", "useCallback", "useRef", "useReducer"]'::jsonb, 1, 'useCallback は関数の参照を保持し、不必要な再作成を避けます。', 'https://react.dev/reference/react/useCallback', 'unpublished', false),
  (18, 'セクション7: パフォーマンス最適化', 'バンドルサイズの最適化', '不要な npm パッケージを削除した際、最初に確認すべき項目はどれですか？', 'npm install @large/library  // 削除', '["ビルドファイルサイズ", "package.json の記録", "node_modules の削除", "すべて"]'::jsonb, 3, 'パッケージ管理、依存関係、ビルド出力のサイズ確認が重要です。', 'https://vite.dev/guide/build', 'unpublished', false),
  (19, 'セクション8: テスト戦略', 'ユニットテストの対象', 'React コンポーネントのテストで最優先すべき項目はどれですか？', '// テスト対象の優先順位', '["UI の見た目", "ユーザーの入力と出力", "内部実装の詳細", "CSS の正確性"]'::jsonb, 1, 'ユーザー視点での入出力と振る舞いをテストすることが重要です。', 'https://testing-library.com/docs/guiding-principles/', 'unpublished', false),
  (20, 'セクション8: テスト戦略', 'マッチャーの選択', '要素が DOM に存在することをテストする場合の推奨マッチャーは？', 'expect(screen.getByText(''Hello'')).toBeInTheDocument();', '["toBeTruthy", "toBeInTheDocument", "toBeVisible", "toHaveLength"]'::jsonb, 1, 'toBeInTheDocument は DOM の存在を確認する明示的な方法です。', 'https://github.com/testing-library/jest-dom#tobeinthedocument', 'unpublished', false),
  (21, 'セクション9: API 統合パターン', 'CORS の仕組み', 'ブラウザから別オリジンの API にリクエストを送る際、サーバーが返すべきヘッダーはどれですか？', '// ブラウザ制限を回避するには', '["Access-Control-Allow-Origin", "Authorization", "X-API-Key", "Content-Type"]'::jsonb, 0, 'サーバーが Access-Control-Allow-Origin ヘッダーを返して CORS を許可します。', 'https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/CORS', 'unpublished', false),
  (22, 'セクション9: API 統合パターン', '認証トークンの管理', 'JWT トークンを localStorage に保存する方法の安全性は？', 'localStorage.setItem(''token'', jwtToken);', '["最も安全な方法", "XSS 攻撃のリスクあり", "完全に安全", "サーバー側のみで管理すべき"]'::jsonb, 1, 'localStorage は XSS 攻撃で奪われるリスクがあります。より安全な方法はタブ内のメモリや HttpOnly Cookie です。', 'https://developer.mozilla.org/en-US/docs/Web/API/Window/localStorage', 'unpublished', false),
  (23, 'セクション10: デバッグとロギング', 'console.log vs console.table', 'オブジェクト配列 `users` を DevTools 上で列形式で見やすく確認したい。`console.log(users)` の代わりとして最も適切なのはどれですか？', 'const users = [{id: 1, name: ''A''}, {id: 2, name: ''B''}];
console.log(users);', '["console.log", "console.table", "JSON.stringify", "alert"]'::jsonb, 1, 'console.table は配列のオブジェクトをテーブル形式で表示して可視化しやすくします。', 'https://developer.mozilla.org/en-US/docs/Web/API/console/table_static', 'unpublished', false),
  (24, 'セクション11: モジュールシステム', 'CommonJS vs ES Modules', '最新の JavaScript プロジェクトで推奨されるモジュールシステムはどれですか？', 'import { Component } from ''./component.js'';
const { Component } = require(''./component.js'');', '["CommonJS", "ES Modules", "どちらでも同じ", "環境に依存"]'::jsonb, 1, 'ES Modules は標準化され、ツールの最適化も充実しているため npm @latest では推奨されます。', 'https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Modules', 'unpublished', false),
  (25, 'セクション11: モジュールシステム', 'デフォルトエクスポート vs 名前付きエクスポート', '複数の関数をエクスポートする場合、推奨するパターンはどれですか？', 'export const func1 = () => {};
export const func2 = () => {};', '["デフォルトエクスポート", "名前付きエクスポート", "どちらでも同じ", "別ファイルに分割"]'::jsonb, 1, '複数のエクスポートは名前付きエクスポートを使うことで、import する側が柔軟に選択できます。', 'https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/export', 'unpublished', false),
  (26, 'セクション12: React StrictMode', 'StrictMode の役割', 'React.StrictMode は開発環境で何を行いますか？', '<React.StrictMode>
  <App />
</React.StrictMode>', '["エラーをキャッチして本番環境を保護", "不純な関数を検出して2回レンダリング", "パフォーマンスを向上させる", "バンドルサイズを削減"]'::jsonb, 1, 'StrictMode は意図しない副作用を検出するため、開発環境でコンポーネントを2回マウント・レンダリングします。', 'https://react.dev/reference/react/StrictMode', 'unpublished', false),
  (27, 'セクション12: React StrictMode', 'StrictMode による useEffect の重複実行', 'StrictMode で useEffect が異なる結果を返すコードはどれですか？', 'useEffect(() => {
  array.push(1);  // 破壊的変更
}, []);', '["純粋なデータ変換", "破壊的な変更（配列 push など）", "fetch による外部データ取得", "console.log による出力"]'::jsonb, 1, '配列の push などの破壊的な変更は、2回実行されると異なる結果になり、StrictMode で検出されます。', 'https://react.dev/reference/react/StrictMode', 'unpublished', false),
  (28, 'セクション12: React StrictMode', 'StrictMode でハイライトされるバグ', 'useEffect の重複実行で検出される『不純な関数』の特徴はどれですか？', 'useEffect(() => {
  globalCounter++;  // グローバル変数変更
}, []);', '["入出力が確定している", "同じ入力なら同じ出力を返す", "外部状態を変更する", "すべてが A と B"]'::jsonb, 2, '不純な関数は外部状態を変更し、「同じ入力 → 異なる出力」となってバグの原因になります。', 'https://react.dev/reference/react/StrictMode', 'unpublished', false),
  (29, 'セクション12: React StrictMode', 'StrictMode による double-render の合図', 'DOMに値が2倍になって表示される場合、疑うべき関数の特徴は？', 'const Counter = () => {
  const [count, setCount] = useState(0);
  // レンダー結果を変更する処理が含まれている', '["fetch エラー", "破壊的な props", "不純なレンダー（pure でない関数）によるバグ"]'::jsonb, 2, '公式ドキュメントより：「Strict Mode calls some of your functions (only the ones that should be pure) twice in development.」不純な関数を早期に検出します。', 'https://react.dev/reference/react/StrictMode', 'unpublished', false),
  (30, 'セクション12: React StrictMode', 'StrictMode での console エラー重複', 'StrictMode で console.error や console.warn が2回出力されるのはなぜですか？', 'useEffect(() => {
  console.warn(''Warning'');
}, []);', '["バグの報告がある", "不純な関数の検出のため2回実行", "メモリリークのサイン", "ネットワークエラーの再実行"]'::jsonb, 1, 'StrictMode はコンポーネントの2重実行で不純な関数を検出するため、console 出力も2回経験します。', 'https://react.dev/reference/react/StrictMode', 'unpublished', false),
  (31, 'セクション13: useEffect と副作用・データ取得パターン', 'useEffect の依存配列 [] の意味', '以下のコードで、空の依存配列 [] を指定した useEffect はどのタイミングで実行されますか？（本番挙動ベースで回答）', 'useEffect(() => {
  fetch(API_URL).then(res => res.json()).then(data => setCount(data.count));
}, []);', '["毎回のレンダリングのたびに実行される", "マウント時とアンマウント時だけに実行される", "マウント時だけ1回実行される", "state が更新されるたびに実行される"]'::jsonb, 2, '空の依存配列 [] は、Effect を初回マウント時に実行する意図を表します。本番ビルドでは通常1回です。なお開発環境で React StrictMode が有効な場合は副作用検出のために追加実行され、結果として2回観測されることがあります。', 'https://react.dev/reference/react/useEffect', 'unpublished', false),
  (32, 'セクション13: useEffect と副作用・データ取得パターン', '外部データ取得を『副作用』と呼ぶ理由', '以下の説明の中で、『副作用（side effect）』の定義として最も正確なものはどれですか？', 'useEffect(() => {
  fetch(API_URL)
  .then(data => setCount(data.count));
}, []);', '["コンポーネントのレンダリング結果に直接反映されない処理", "レンダー関数内で実行されると問題が生じる処理（データ取得、イベントリスナー登録など）", "props や state に基づかない処理", "エラーを発生させる可能性のある処理"]'::jsonb, 1, '『副作用』とは、『コンポーネントの pure なレンダリングプロセスの外で実行される処理』を指します。これらをレンダー関数内で直接実行するとバグの原因になります。', 'https://react.dev/reference/react/useEffect', 'unpublished', false),
  (33, 'セクション13: useEffect と副作用・データ取得パターン', 'useEffect に直接 async を書けない理由と cleanup', '以下のコードが推奨されていない理由は何ですか？', 'useEffect(async () => {
  const res = await fetch(API_URL);
  const data = await res.json();
  setCount(data.count);
}, []);', '["非同期処理のため、cleanup 関数が実行できなくなる", "async 関数は自動的に Promise を返すが、useEffect は関数かクリーンアップ関数の返却を期待しており、Promise の返却は型に矛盾するから", "useState の呼び出しが許可されないから", "fetch API は useEffect 内では使用禁止だから"]'::jsonb, 1, 'useEffect の第1引数は『関数 → (クリーンアップ関数 | undefined)』の型を期待しています。async 関数は必ず Promise を返すため、型が合致しません。正しいパターンは『内部に async 関数を定義して呼び出す』方式です。', 'https://react.dev/reference/react/useEffect', 'unpublished', false),
  (34, 'セクション13: useEffect と副作用・データ取得パターン', 'fetch API と res.ok チェックの重要性', '以下のコードで res.ok を確認する理由は何ですか？', 'const res = await fetch(API_URL);
if (!res.ok) throw new Error(`HTTP error: ${res.status}`);
const data = await res.json();', '["fetch が失敗しても Promise は reject されず、HTTP エラーステータス（404, 500など）は成功値として返されるから", "res.json() 呼び出し時に必ず IOException が発生するから", "JSON パースエラーを事前に防ぐため", "TypeScript の型チェックで必須だから"]'::jsonb, 0, 'fetch API の重要な特性：『ネットワークエラーのみで Promise を reject する』。HTTP エラーステータスでも fetch は成功値を返すため、res.ok チェックが必須です。', 'https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API/Using_Fetch#checking_response_status', 'unpublished', false),
  (35, 'セクション13: useEffect と副作用・データ取得パターン', 'TypeScript 型アサーション (as) の役割', '以下のコードで as ViewData を使用する理由は何ですか？', 'const data = (await res.json()) as ViewData;

type ViewData = {
  count: number;
};', '["res.json() は any 型を返し、TypeScript は data.count がどの型なのか推測できないため、開発者が『これは ViewData 型です』と明示する", "型アサーションで実行時のデータ検証が自動的に行われる", "as を使うことで fetch エラーが自動的にハンドルされる", "JSON のパース速度が向上する"]'::jsonb, 0, 'res.json() は Promise<any> を返します。型アサーション (as ViewData) は『このデータは ViewData 型である』と TypeScript コンパイラに通知し、型チェックを可能にします。ただし実行時のデータ検証は行われません。', 'https://www.typescriptlang.org/docs/handbook/2/everyday-types.html#type-assertions', 'unpublished', false),
  (36, 'セクション13: useEffect と副作用・データ取得パターン', 'try/catch でのエラーハンドリングと型ガード', '以下のコードで err instanceof Error を確認する理由は何ですか？', 'try {
  const data = (await res.json()) as ViewData;
  setCount(data.count);
} catch (err) {
  setError(err instanceof Error ? err.message : "Unknown error");
}', '["catch ブロックの err 変数は unknown 型であり、Error 型とは限らず、throw \"string\" や throw 123 などの任意の値も catch される可能性があるから", "await 式でのみ例外が発生し、それ以外では発生しないから", "catch で捕捉されたすべてのエラーは自動的に Error 型", "「型ガード」は TypeScript だけの機能で、JavaScript では無関係"]'::jsonb, 0, 'JavaScript では `throw new Error(...)` の他に、`throw "string"` や `throw 123` など任意の値を throw できます。そのため catch 時に `err instanceof Error` で検証し、堅牢な実装をします。', 'https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/try...catch', 'unpublished', false),
  (37, 'セクション14: CORS とセキュリティ', 'CORS エラーの原因特定', '以下のエラーが発生した原因として正しいものはどれですか？

Access to fetch at ''http://localhost:8080/api/views'' from origin ''http://localhost:5174'' has been blocked by CORS policy: The ''Access-Control-Allow-Origin'' header has a value ''http://localhost:5173'' that is not equal to the supplied origin.', '// Go バックエンド
w.Header().Set("Access-Control-Allow-Origin", "http://localhost:5173")

// フロントエンドは http://localhost:5174 で起動中', '["フロントエンドのコードに誤りがある", "バックエンドの CORS 許可オリジンが 5173 固定のため、5174 で起動した Vite からのリクエストが拒否された", "fetch の URL が間違っている", "ブラウザのキャッシュが原因"]'::jsonb, 1, 'CORS は『ブラウザが』リクエスト元のオリジン（プロトコル + ホスト + ポート）とサーバーが返す Access-Control-Allow-Origin を比較し、一致しない場合にブロックします。Vite は 5173 が使用中のとき自動的に 5174 に切り替えるため、固定値のままでは起動のたびに壊れます。', 'https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/CORS', 'unpublished', false),
  (38, 'セクション14: CORS とセキュリティ', 'Origin をそのまま返す修正のセキュリティリスク', '以下の修正はポート問題を解決しますが、本番環境でのセキュリティリスクはどれですか？', '// 修正後
if origin := r.Header.Get("Origin"); origin != "" {
    w.Header().Set("Access-Control-Allow-Origin", origin)
}', '["リスクなし。Origin ヘッダーはブラウザが自動で付与するので安全", "任意のオリジンからのリクエストを許可することになり、悪意あるサイトから API を叩かれる可能性がある", "パフォーマンスが低下する", "localhost でしか動かなくなる"]'::jsonb, 1, 'Origin をそのまま返すのは実質的に「全オリジン許可（* と同等）」です。さらに Access-Control-Allow-Credentials: true が加わると、Cookie や認証情報も外部サイトから送信可能になり深刻なリスクになります。

本番環境での正しい対応：許可するオリジンをホワイトリストで管理する。

// 本番向け例
allowed := map[string]bool{
    "https://example.com": true,
}
if allowed[r.Header.Get("Origin")] {
    w.Header().Set("Access-Control-Allow-Origin", r.Header.Get("Origin"))
}

今回のケースは localhost 開発環境専用かつ Credentials なしのため実害はありませんが、本番コードに流用しないよう注意が必要です。', 'https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/CORS', 'unpublished', false),
  (39, 'セクション15: フロントエンドアーキテクチャ選定', 'SPA / RSC / Astro の使い分け', '「徹底的なパフォーマンス最適化」を目指す場合、アーキテクチャ選定の基準として最も正確な説明はどれですか？', '// A: Vite + React SPA
// B: Next.js App Router (RSC)
// C: Astro (Islands Architecture)', '["RSC は常に最速なので、すべてのプロジェクトで採用すべき", "プロダクトの性質（コンテンツ駆動 vs インタラクション駆動）によって最適解は変わるため、銀の弾丸はない", "Astro は静的サイト専用で、動的コンテンツには使えない", "SPA はパフォーマンスが劣るため、現代では使うべきではない"]'::jsonb, 1, 'アーキテクチャ選定はユースケース依存です。

・SPA（Vite + React）: インタラクションが密なアプリ（クイズ、管理画面など）に適切
・RSC（Next.js）: データ取得が多くインタラクションが少ないコンテンツ駆動サイトで効果的。ライブラリがバンドルに含まれず転送量が削減される
・Astro（Islands）: ほぼ静的で一部だけインタラクティブなサイトに最適

「銀の弾丸はない」がアーキテクチャ設計の大原則です。', 'https://docs.astro.build/en/concepts/why-astro/', 'unpublished', false),
  (40, 'セクション15: フロントエンドアーキテクチャ選定', 'React Server Components (RSC) の特徴', 'React Server Components (RSC) がクライアントバンドルサイズを削減できる理由はどれですか？', '// Server Component（サーバー側のみで実行）
async function ProductList() {
  const data = await db.query(...)  // DBに直接アクセス可
  return <ul>{data.map(...)}</ul>
}
// このコンポーネントで使ったライブラリはブラウザに送られない', '["コードを自動的に圧縮するから", "Server Components はサーバー側のみで実行され、そこで使ったライブラリはクライアントの JavaScript バンドルに含まれないから", "画像を自動的に最適化するから", "不要な CSS を削除するから"]'::jsonb, 1, 'Server Components はサーバー側でのみ実行されます。使ったライブラリ（例: 巨大な日付フォーマットライブラリ）はブラウザに一切送信されず、ネットワーク転送量を削減できます。

ただし Hydration がゼロになるわけではなく「選択的 Hydration」が正確な表現です。''use client'' がついた Client Components は従来通り Hydration されます。', 'https://react.dev/reference/rsc/server-components', 'unpublished', false),
  (41, 'セクション15: フロントエンドアーキテクチャ選定', 'クイズアプリに最適なアーキテクチャ', '今回開発しているクイズアプリ（ユーザーが問題を選択・回答し、リアルタイムでフィードバックを受ける）に最も適したアーキテクチャはどれですか？', '// クイズアプリの特性
// - 問題選択・回答 → state 管理が必要
// - 正解/不正解フィードバック → リアルタイムな UI 更新
// - 問題データは静的 JSON', '["Next.js (RSC): サーバー側レンダリングで SEO を最適化すべき", "Astro (Islands): 静的コンテンツが多いので Islands が最適", "Vite + React SPA: インタラクションが密でほぼ全域が動的なため SPA が素直に合う", "どれでも同じなので、チームの慣れで決めればよい"]'::jsonb, 2, 'クイズアプリはインタラクション駆動型の典型例です。

・問題の選択・回答・フィードバックはすべて state で管理
・ほぼ全域が動的なため Astro の Islands の旨味がない
・問題データが静的 JSON なので RSC の「DB直接アクセス」の恩恵も薄い

Vite + React SPA が最もシンプルで適切です。パフォーマンス改善が必要な場合は RSC より先に React.memo / useMemo / React.lazy（コード分割）を検討するのが現実的です。', 'https://react.dev/reference/rsc/server-components', 'unpublished', false),
  (42, 'セクション16: パフォーマンス最適化の判断基準', '主張評価: 計測前提での最適化判断', '次の評価のうち、最も妥当なものはどれですか？

A. State Colocation 推奨
B. Zustand/Jotai 強推奨
C. Code Splitting 推奨', '// 前提: クイズアプリ (Vite + React SPA)
// 目的: パフォーマンス最適化方針の妥当性を評価する', '["A, B, C すべて無条件で正しい", "A は良い習慣だが前提条件が必要、B は計測なき最適化になりやすく注意、C は方向性は正しいが効果はアプリ規模に依存", "B だけが唯一正しく、まずグローバル状態管理ライブラリを導入すべき", "C は不要で、コード分割は現代のビルドツールなら自動で最適化される"]'::jsonb, 1, '実務では『計測なき最適化』を避けることが重要です。

・State Colocation: 不要な再レンダリング伝播が原因と確認できた場合に有効
・Zustand/Jotai: 共有状態の複雑化が実際にボトルネックになってから検討
・Code Splitting: 初期バンドルや LCP/INP の実測悪化がある場合に効果が出る

結論として、最適化施策は常に計測結果とアプリ規模を前提に採用判断する。', 'https://developer.mozilla.org/en-US/docs/Web/Performance', 'unpublished', false),
  (43, 'セクション17: Go の並行処理と排他制御', 'sync.Mutex の英文読解', '次の Go 公式ドキュメントの英文から読み取れる `Mutex` の説明として、最も適切なものはどれですか？', 'A Mutex is a mutual exclusion lock.
The zero value for a Mutex is an unlocked mutex.
A Mutex must not be copied after first use.
Lock locks m. If the lock is already in use, the calling goroutine blocks until the mutex is available.', '["Mutex は最初から lock 済みで、コピーして使い回すことが推奨される", "Mutex は相互排他ロックで、初期状態は unlocked。すでに使用中なら利用可能になるまで goroutine は待機する", "Mutex は goroutine ごとの専用ロックで、Lock した goroutine 以外は Unlock できない", "Mutex は読み取り専用ロックなので、共有データの書き込み保護には向かない"]'::jsonb, 1, '`A Mutex is a mutual exclusion lock.` は「Mutex は相互排他ロックである」という意味です。つまり、同じ共有データに複数の goroutine が同時に入らないように制御します。`The zero value for a Mutex is an unlocked mutex.` は「初期値の Mutex は未ロック状態」という意味で、宣言直後から使えます。`A Mutex must not be copied after first use.` は「使い始めた後はコピーしてはいけない」という注意です。さらに `If the lock is already in use, the calling goroutine blocks until the mutex is available.` から、すでに誰かが Lock している間は、次の goroutine は利用可能になるまで待機すると読み取れます。', 'https://pkg.go.dev/sync#Mutex', 'unpublished', false),
  (44, 'セクション18: Docker Compose とビルド設定', 'failed to read dockerfile の原因と対処', '次のエラーが発生した。最も適切な原因と解決策の組み合わせはどれですか？

failed to solve: failed to read dockerfile: open Dockerfile: no such file or directory', '# 前提
# - docker-compose.yml の api に build: ./backend を指定
# - backend/ に Dockerfile は存在しない
# - 実行場所: vite-quiz-app/backend', '["原因: ポート 8080 が競合している。解決: ports を 8081:8080 に変更する", "原因: build コンテキスト内に Dockerfile がない。解決: Dockerfile を配置し、compose の build.context / dockerfile を正しいパスに合わせる", "原因: depends_on の順序が逆。解決: db を削除して api 単体起動にする", "原因: Vite が起動している。解決: npm run dev を停止すれば Dockerfile なしでもビルドできる"]'::jsonb, 1, 'このエラーは Docker がビルド時に Dockerfile を見つけられないときに発生します。`build: ./backend` は compose ファイルの配置位置を基準に解決されるため、意図と異なるディレクトリを参照することがあります。対策は (1) Dockerfile をビルドコンテキストに置く、(2) `build.context` と `build.dockerfile` を実ディレクトリ構成に合わせて明示する、の2点です。', 'https://docs.docker.com/reference/compose-file/build/', 'unpublished', false),
  (45, 'セクション19: DB マイグレーション運用', '本番マイグレーションでの IF EXISTS/IF NOT EXISTS', 'CI/CD 前提の本番マイグレーションで、再実行可能性（冪等性）を高める方針として最も適切なのはどれですか？', '-- 例
DROP TABLE IF EXISTS temp_table;
CREATE TABLE IF NOT EXISTS users (...);', '["本番では失敗を早く検知するため、IF EXISTS は使わないのが常に正解", "本番では IF EXISTS / IF NOT EXISTS を適切に使い、アトミックかつリバーシブルなマイグレーションにする", "IF EXISTS は開発環境でのみ有効で、本番SQLでは無効", "IF EXISTS を使うとロールバック不能になるため禁止すべき"]'::jsonb, 1, 'モダンな CI/CD では、デプロイやロールバックの再試行可能性が重要です。`IF EXISTS` / `IF NOT EXISTS` は環境差分や途中失敗後の再実行でスクリプト全体のクラッシュを防ぎやすくし、冪等性の実装に寄与します。', 'https://github.com/golang-migrate/migrate/blob/master/GETTING_STARTED.md', 'unpublished', false),
  (46, 'セクション20: Flutter 実行環境トラブルシュート', 'No supported devices found の原因', '以下の実行で `No supported devices found with name or id matching ...` が出た。最も適切な対処はどれですか？', 'flutter run -d 8D8A5796-D4C7-4BB9-B135-
DBF87FC258BA --dart-define-from-file=dart-defines.json', '["UUID を途中改行で分断しない。Simulator を boot してから `flutter devices` で認識を確認する", "`--dart-define-from-file` を削除すれば必ずデバイス認識される", "`flutter run` の代わりに `npm run dev` を使う", "UUID は不要で、常に `-d ios` 固定が正解"]'::jsonb, 0, 'ログでは UUID が改行で分断され、`zsh: command not found` も発生しています。まず UUID を1行で渡し、必要なら `xcrun simctl boot <UUID>` と `open -a Simulator` 後に `flutter devices` で対象が見えることを確認します。', 'https://docs.flutter.dev/', 'unpublished', false),
  (47, 'セクション21: Node.js 環境トラブルシュート', 'npm EACCES と root-owned cache', '`npm ERR! code EACCES` と `Your cache folder contains root-owned files` が出た場合の実務的な対処として最も適切なのはどれですか？', 'npm ERR! Your cache folder contains root-owned files ...
npm ERR! To permanently fix this problem, run: sudo chown -R ... ~/.npm', '["毎回 `sudo npm install` で実行し続ける", "案内された通り `.npm` キャッシュ所有者を現在ユーザーへ戻し、以後は通常ユーザーで npm を実行する", "node_modules を削除するだけで必ず解決する", "OS を再起動すれば再発しない"]'::jsonb, 1, '原因はキャッシュ配下の所有権不整合です。まず所有者を修正し、以後 `sudo npm` を常用しない運用へ戻すのが再発防止に有効です。', 'https://docs.npmjs.com/resolving-eacces-permissions-errors-when-installing-packages-globally', 'unpublished', false),
  (48, 'セクション22: Docker Compose とビルド反映', 'docker compose up だけでは反映されない理由', 'Go アプリを Dockerfile で `go build -o server .` している構成で、`main.go` に `fmt.Printf(...)` を追加したのに `docker compose logs api` に出ない。最も適切な説明と対処はどれですか？', 'FROM golang:1.26-alpine AS build-env
COPY . /app
WORKDIR /app
RUN go mod download
RUN go build -o server .

FROM alpine:3.19
COPY --from=build-env /app/server /app/server
CMD ["./server"]', '["`fmt.Printf` は Docker では常に捨てられるので、`log.Printf` に変えない限り `docker compose logs` には出ない", "既存コンテナは以前ビルドした `server` バイナリを実行している。ソース変更を反映するには `docker compose up --build` でイメージを再ビルドする", "`docker compose up` は毎回自動で再ビルドするが、Go の `runtime.NumCPU()` だけはログ出力されない", "PostgreSQL の checkpoint ログが大量に出ると API ログは非表示になるため、db コンテナを停止してから起動する"]'::jsonb, 1, 'この構成ではコンテナ内で実行されるのはソースコードではなく、ビルド済みの `server` バイナリです。`main.go` を編集しても既存イメージや既存コンテナには自動反映されません。`docker compose up --build` あるいは `docker compose build` 後に再起動して、最新ソースからバイナリを作り直す必要があります。`fmt.Printf` 自体は標準出力に出るため、再ビルド後であれば `docker compose logs api` で確認できます。', 'https://docs.docker.com/reference/cli/docker/compose/up/', 'unpublished', false),
  (49, 'セクション23: air による Go 開発環境', 'air で自動再起動させるための条件', 'Go API を Docker 上で `air` により自動再起動させたい。最も適切な構成はどれですか？', 'services:
  api:
    build:
      context: .
      target: dev
    volumes:
      - .:/app
    command: ["air", "-c", ".air.toml"]', '["本番用のビルド済みバイナリを実行するだけでよく、ソースコードの volume mount も `air` 設定も不要", "`air` をコンテナ内に入れ、ソースコードを volume mount し、`air` を PID 1 として起動する", "PostgreSQL コンテナに `air` を入れれば、`api` コンテナも自動で再起動する", "`docker compose logs -f api` を開いておけば、ファイル変更時に自動再起動される"]'::jsonb, 1, '`air` はファイル監視ツールなので、監視対象のソースコードがコンテナ内から見えている必要があります。そのため、開発用コンテナには `air` のインストール、ソースコードの bind mount、`air` を起動コマンドにする設定が必要です。単にビルド済みバイナリを実行するだけの構成では自動再起動されません。', 'https://github.com/air-verse/air', 'unpublished', false),
  (50, 'セクション23: air による Go 開発環境', 'air.toml の root と tmp_dir の意味', '次の `air` 設定について、`root` と `tmp_dir` の説明として最も適切なのはどれですか？', 'root = "."
tmp_dir = "tmp"

[build]
cmd = "go build -o ./tmp/server ."
entrypoint = "./tmp/server"
include_ext = ["go"]
exclude_dir = ["tmp"]', '["`root` は Go module 名、`tmp_dir` は Docker volume 名である", "`root` は `air` が監視とビルドの基準にする作業ディレクトリ、`tmp_dir` は再ビルド時の一時成果物を置くディレクトリである", "`root` は実行バイナリ名、`tmp_dir` は PostgreSQL のデータ保存先である", "`root` は常に `/` 固定で、`tmp_dir` は指定しても無視される"]'::jsonb, 1, '`root` は `air` がプロジェクトの基準ディレクトリとして扱う場所です。この例では `.` なので、`air` を起動した現在ディレクトリを基準に監視・ビルドします。`tmp_dir` は再ビルドした実行ファイルなどの一時ファイル置き場で、この設定では `./tmp` 配下が使われます。', 'https://github.com/air-verse/air', 'unpublished', false),
  (51, 'セクション23: air による Go 開発環境', 'air の build 設定と typo の見分け方', '次の設定断片を見たときの判断として最も適切なのはどれですか？', '[build]
cmd = "go build -o ./tmp/server ."
bin = "./tmp/server ."
include_ext = ["go"]
exclude_dir = ["tmp"]', '["`bin` の値に余分な ` .` が入っており不自然で、実行パス指定として typo を疑うべきである", "`bin = \"./tmp/server .\"` は Go の標準的な書き方で、末尾の `.` は必須である", "`cmd` の `go build` は不要で、`air` はソースコードを直接実行するため常に `bin` だけあればよい", "`exclude_dir = [\"tmp\"]` を入れると `cmd` は実行されなくなる"]'::jsonb, 0, '`cmd` の末尾の `.` は `go build` のビルド対象として自然ですが、`bin` や実行パスに `./tmp/server .` のような値が入るのは不自然です。実行ファイルの指定なら通常は `./tmp/server` で、末尾の空白と `.` は typo を疑うのが妥当です。現行設定では deprecated な `bin` ではなく `entrypoint = "./tmp/server"` を使う形にしています。', 'https://github.com/air-verse/air', 'unpublished', false),
  (52, 'セクション23: air による Go 開発環境', 'include_ext と exclude_dir を両方入れる理由', '次の `air` 設定で `include_ext` と `exclude_dir` を両方指定する主な理由として最も適切なのはどれですか？', '[build]
cmd = "go build -o ./tmp/server ."
entrypoint = "./tmp/server"
include_ext = ["go"]
exclude_dir = ["tmp"]', '["`.go` の変更だけを監視しつつ、ビルド成果物のある `tmp` を監視対象から外して不要な再検知ループを防ぐため", "Go は `include_ext` と `exclude_dir` を必ず同時に書かないとコンパイルできないため", "`exclude_dir = [\"tmp\"]` を入れると `tmp` 配下にだけ変更を限定して高速化できるため", "`include_ext = [\"go\"]` はログの色を変える設定で、監視とは無関係であるため"]'::jsonb, 0, '`include_ext = ["go"]` により、Go ソースの変更に絞って監視できます。一方 `exclude_dir = ["tmp"]` を入れておかないと、`cmd` が生成した `./tmp/server` などの成果物まで再度検知して、無駄な再ビルドや再起動ループの原因になります。', 'https://github.com/air-verse/air', 'unpublished', false),
  (53, 'セクション23: air による Go 開発環境', '開発用 air 構成と本番用バイナリ構成の違い', 'Go API の Docker 構成について、開発用 `air` 構成と本番用ビルド済みバイナリ構成の違いとして最も適切なのはどれですか？', '# development
api:
  build:
    context: .
    target: dev
  volumes:
    - .:/app

# production image
FROM golang:1.26-alpine AS build-env
RUN go build -o server .
FROM alpine:3.19 AS runtime
CMD ["./server"]', '["開発用はソースを mount して `air` で変更を監視するが、本番用はビルド済みバイナリを固定イメージとして実行する", "開発用と本番用の違いはポート番号だけで、再ビルド反映の考え方は同じである", "本番用のほうが `air` による自動再起動が強く有効になる", "開発用は必ず `docker compose up --build` が必要で、本番用は不要である"]'::jsonb, 0, '開発用構成は bind mount したソースコードを `air` が監視し、その場で再ビルド・再起動します。一方、本番用は Docker build 時に作ったバイナリを含むイメージを実行する構成で、起動後にソース変更を自動反映する仕組みは持ちません。目的が異なるため、同じ運用を期待しないことが重要です。', 'https://github.com/air-verse/air', 'unpublished', false),
  (54, 'セクション23: air による Go 開発環境', 'docker compose up --build が要る場合と要らない場合', 'Go プロジェクトで、どのような場合に `docker compose up --build` が必要になりやすいですか？', '# A: source mounted + air
volumes:
  - .:/app
command: ["air", "-c", ".air.toml"]

# B: built binary only
RUN go build -o server .
CMD ["./server"]', '["A のように `air` でソースを監視する開発構成では毎回必須で、B では不要である", "B のようにビルド済みバイナリをイメージへ閉じ込める構成ではソース変更反映に再ビルドが必要だが、A のような開発構成では通常不要である", "どちらの構成でも `docker compose up` は必ず自動再ビルドするので `--build` は意味がない", "`--build` は PostgreSQL コンテナにだけ影響し、Go API には無関係である"]'::jsonb, 1, '正解は B です。

理由の全体像:
- A は開発用の "ソースをマウントして air で監視する" 構成です。
- B は "Docker イメージ作成時に Go バイナリを焼き込み、そのバイナリを実行する" 構成です。
- `docker compose up --build` が必要になりやすいのは、ソース変更を反映するためにイメージの作り直しが必要な B 側です。

`volumes:` の意味:
- `- .:/app` は bind mount です。
- ホスト側の現在ディレクトリ `.` を、コンテナ内の `/app` にそのまま見せます。
- つまりローカルで `main.go` や `go.mod` を編集すると、コンテナ内 `/app` からも最新ファイルとして見えます。
- そのため、コンテナ内ツールがファイル変更を監視する構成なら、毎回イメージを作り直さなくても反映できます。

`command: ["air", "-c", ".air.toml"]` の意味:
- Docker イメージに元々設定されているデフォルトコマンドを上書きして、起動時に `air` を実行します。
- `-c .air.toml` は air の設定ファイルとして `.air.toml` を使う指定です。
- air は Go ソースの変更を監視し、変更があれば再ビルドしてプロセスを再起動します。
- そのため A のような開発構成では、通常のソース変更だけなら `docker compose up --build` を毎回打つ必要はありません。

`RUN go build -o server .` の意味:
- これは Dockerfile のビルド時に実行される命令です。
- `.` を Go モジュールのビルド対象としてコンパイルし、出力ファイル名を `server` にしています。
- ここで作られた `server` バイナリは、その時点のソースコードのスナップショットです。
- 後からホスト側のソースを編集しても、すでに作成済みのイメージ内バイナリは自動では更新されません。

`CMD ["./server"]` の意味:
- これはコンテナ起動時のデフォルト実行コマンドです。
- つまりコンテナは、イメージ内に保存されている `./server` バイナリをそのまま起動します。
- 実行されるのはソースコードではなく、以前 `RUN go build ...` で作られた成果物です。

なぜ B で `--build` が必要になりやすいのか:
- B では実行対象が焼き込み済みバイナリなので、ソースを変えてもコンテナの中身は変わりません。
- したがって最新ソースを反映したければ、`docker compose up --build` か `docker compose build` でイメージを再ビルドする必要があります。

A でも `--build` が要ることがある例:
- Dockerfile 自体を変更したとき
- ベースイメージや Go バージョンを変えたとき
- `air` や OS パッケージなど、イメージに焼き込んだツールを更新したいとき
- bind mount ではなく、イメージに COPY したファイル内容へ依存する部分を変えたとき

要するに:
- ソースをマウントして監視する開発構成なら、普段のコード修正は air に任せられる
- イメージ内バイナリを直接動かす構成なら、ソース修正の反映に再ビルドが必要
- そのため `docker compose up --build` が必要になりやすいのは B です。', 'https://github.com/air-verse/air', 'unpublished', false),
  (55, 'セクション23: air による Go 開発環境', 'root = "." を別ディレクトリに変えたときの影響', '`air` 設定で `root = "."` を `root = "./handlers"` に変更した。下の設定断片を前提に、最も起きやすい影響はどれですか？', 'root = "./handlers"
tmp_dir = "tmp"

[build]
cmd = "go build -o ./tmp/server ."
entrypoint = "./tmp/server"', '["`air` の基準ディレクトリが `./handlers` になり、監視範囲や `cmd` の相対パス解決が変わってビルド対象がズレる可能性がある", "`root` はログ表示用の文字列なので、実際の動作には影響しない", "`root` を変えると PostgreSQL の接続先も自動で切り替わる", "`root` をサブディレクトリにすると `air` は必ずすべての親ディレクトリも自動監視するので問題は起きない"]'::jsonb, 0, '`root` は `air` の作業基準ディレクトリです。ここをサブディレクトリへ変えると、監視対象の範囲だけでなく、`cmd` や `entrypoint` の相対パス解決基準も変わります。その結果、本来プロジェクトルートで実行したい `go build` が別ディレクトリ基準になり、ビルド失敗や意図しない監視範囲になることがあります。', 'https://github.com/air-verse/air', 'unpublished', false),
  (56, 'セクション23: air による Go 開発環境', 'exclude_dir = ["tmp"] を消したときの不具合', '次の設定のように `exclude_dir = ["tmp"]` を削除したとき、最も起きやすい不具合はどれですか？', 'tmp_dir = "tmp"

[build]
cmd = "go build -o ./tmp/server ."
entrypoint = "./tmp/server"
include_ext = ["go"]', '["`./tmp/server` などの生成物まで監視対象に入り、再ビルドのたびに再検知して無駄な再起動やループの原因になりやすい", "`air` が `.go` ファイルを監視しなくなり、変更しても何も起きなくなる", "`tmp` ディレクトリが自動で PostgreSQL 用 volume に変換される", "`exclude_dir` を省略すると `entrypoint` が無視されて `cmd` だけが 1 回実行される"]'::jsonb, 0, 'この構成では `cmd` が `./tmp/server` を更新します。`tmp` を除外しないと、その生成物への変更まで `air` が検知してしまい、再ビルド後の成果物をまた変更と見なして、不要な再起動やループを引き起こしやすくなります。', 'https://github.com/air-verse/air', 'unpublished', false),
  (57, 'セクション23: air による Go 開発環境', 'entrypoint と cmd の役割分担', '次の `build` 設定における `cmd` と `entrypoint` の役割分担として、最も適切なのはどれですか？', '[build]
cmd = "go build -o ./tmp/server ."
entrypoint = "./tmp/server"', '["`cmd` は再ビルド時に実行するコマンド、`entrypoint` はビルド後に起動する実行ファイルやコマンドを指す", "`cmd` と `entrypoint` は完全に同義で、どちらを書いても内部的に同じ処理になる", "`cmd` は Docker Compose 用、`entrypoint` は PostgreSQL 接続用の設定である", "`entrypoint` は監視拡張子の一覧を表し、`cmd` はログの出力形式を表す"]'::jsonb, 0, '`cmd` はソース変更時に何でビルドするかを定義する項目です。この例では `go build -o ./tmp/server .` がそれに当たります。一方 `entrypoint` は、そのビルド成果物として何を実行するかを表し、ここでは `./tmp/server` を起動します。つまり、`cmd` は作る処理、`entrypoint` は動かす対象です。', 'https://github.com/air-verse/air', 'unpublished', false),
  (58, 'セクション24: Codex 設定トラブルシュート', 'unknown variant xhigh の直接原因', '次のエラーの直接原因として最も適切なのはどれですか？', 'Error loading configuration: unknown variant ''xhigh'' ... expected one of minimal, low, medium, high', '["Codex 本体のバイナリ破損", "`model_reasoning_effort` に許可されていない値 `xhigh` が設定されていた", "ネットワークがオフラインだった", "API トークンの期限切れ"]'::jsonb, 1, 'このエラーは設定値の列挙型チェックで発生しています。`model_reasoning_effort` が受け付ける値は `minimal | low | medium | high` だけで、`xhigh` はスキーマ外です。', 'https://github.com/openai/codex', 'unpublished', false),
  (59, 'セクション24: Codex 設定トラブルシュート', 'なぜ xhigh が入りやすいか', '`xhigh` のような無効値が設定に残る経路として、最も現実的なのはどれですか？', 'model_reasoning_effort = "xhigh"', '["過去の会話ログや内部表現（例: reasoning_effort）をそのまま `config.toml` に転記した", "TOML では high が自動的に xhigh に変換される", "Go のバージョンが古いと high が xhigh に展開される", "Docker Compose が起動時に設定文字列を改変する"]'::jsonb, 0, '設定エラーの多くは『別コンテキストで使われていた値やサンプルをそのまま貼る』ことで起きます。TOML や Docker が自動変換した可能性は低く、手動転記ミスのほうが説明力があります。', 'https://github.com/openai/codex', 'unpublished', false),
  (60, 'セクション24: Codex 設定トラブルシュート', 'なぜ high への変更で直るのか', '`model_reasoning_effort = "high"` に修正すると起動できる主な理由はどれですか？', 'model_reasoning_effort = "high"', '["`high` が許可済みの列挙値で、設定パーサーのバリデーションを通過するため", "`high` だと認証をスキップできるため", "`high` だと自動でネットワーク設定が修正されるため", "`high` だと API エンドポイントが localhost に変わるため"]'::jsonb, 0, '今回の失敗点は設定読み込み段階の enum 不一致でした。許可された値に戻すことで、起動前バリデーションが通り CLI が通常起動します。', 'https://github.com/openai/codex', 'unpublished', false),
  (61, 'セクション24: Codex 設定トラブルシュート', '再発防止の確認コマンド', '設定修正後に再発防止の観点で最初に実行する確認として適切なのはどれですか？', 'codex --help', '["ヘルプ表示などの軽量コマンドで設定読み込みに失敗しないことを先に確認する", "いきなり長時間の本番バッチを実行する", "設定ファイルを削除して毎回再生成する", "エラーが出なくても毎回 Docker を再ビルドする"]'::jsonb, 0, '`codex --help` は副作用が少なく、設定パースの成否をすぐ確認できます。まず軽量コマンドで健全性を確認してから本処理へ進むのが安全です。', 'https://github.com/openai/codex', 'unpublished', false),
  (62, 'セクション24: Codex 設定トラブルシュート', '切り分け時の探索対象', 'ワークスペース内に該当設定が見つからない場合、次に優先して調べるべき場所はどれですか？', '# workspace で見つからない場合', '["ユーザーホーム配下の `~/.codex/config.toml`", "`node_modules` の任意ライブラリ", "Docker コンテナ内の `/var/lib/postgresql/data`", "ブラウザの localStorage"]'::jsonb, 0, 'Codex CLI の恒久設定はユーザースコープに置かれることが多く、ワークスペース外の `~/.codex/config.toml` が原因点になるケースがあります。今回もここが実際の修正箇所でした。', 'https://github.com/openai/codex', 'unpublished', false),
  (63, 'セクション25: Go 標準ライブラリ読解', 'LookupEnv の戻り値の意味', '次のコードについて、最も正しい説明はどれですか？', 'func LookupEnv(key string) (string, bool) {
	testlog.Getenv(key)
	return syscall.Getenv(key)
}', '["環境変数が未設定でも常に `(\"\", true)` を返す", "第2戻り値は『キーが存在したか』を表し、値が空文字でも存在していれば true になる", "`testlog.Getenv` が環境変数の実体を読み取り、第1戻り値として返している", "`LookupEnv` は値だけを返し、bool は常に false になる"]'::jsonb, 1, '`LookupEnv` は `(value, found)` を返す API です。ここでは最終的に `syscall.Getenv(key)` の結果をそのまま返しています。`found` は『環境変数が存在するか』を表すため、値が空文字でもキーが設定済みなら true です。未設定の場合のみ false になります。`testlog.Getenv(key)` はテスト用ログフックで、戻り値の意味そのものは `syscall.Getenv` に依存します。', 'https://pkg.go.dev/os#LookupEnv', 'unpublished', false),
  (64, 'セクション26: Go runtime 診断出力', 'runtime.NumCPU の意味', '次のコード断片における `runtime.NumCPU()` の説明として最も適切なのはどれですか？', 'fmt.Printf("Number of CPUs: %d\n", runtime.NumCPU())', '["現在の goroutine 数を返す", "実行可能な論理CPU数を返し、Goプロセスが使う並列数そのものとは限らない", "常に物理CPUソケット数を返す", "Goのバージョン文字列を返す"]'::jsonb, 1, '`runtime.NumCPU()` はマシンの論理CPU数を返します。ただし実際の並列実行上限は `GOMAXPROCS` によって制御されるため、`NumCPU` と実効並列度は常に一致するとは限りません。', 'https://pkg.go.dev/runtime', 'unpublished', false),
  (65, 'セクション26: Go runtime 診断出力', 'runtime.GOMAXPROCS(0) の読み取り', '`runtime.GOMAXPROCS(0)` をログ表示に使う主な意図はどれですか？', 'fmt.Printf("GOMAXPROCS: %d\n", runtime.GOMAXPROCS(0))', '["GOMAXPROCS を 0 に設定して無効化するため", "現在値を変更せずに、並列実行に使う OS スレッド数の上限を取得するため", "goroutine をすべて停止するため", "CPU 使用率をパーセントで取得するため"]'::jsonb, 1, '`GOMAXPROCS(n)` は通常『設定して旧値を返す』APIですが、`n=0` のときは設定変更せず現在値を返します。診断ログでは副作用なく現設定を確認できるため有用です。', 'https://pkg.go.dev/runtime', 'unpublished', false),
  (66, 'セクション26: Go runtime 診断出力', 'runtime.NumGoroutine の解釈', '`runtime.NumGoroutine()` の値を監視する際の注意点として最も適切なのはどれですか？', 'fmt.Printf("Number of Goroutines: %d\n", runtime.NumGoroutine())', '["この値は常に 1 で固定される", "この値は現在生存している goroutine 数のスナップショットで、負荷やタイミングで変動する", "この値は OS スレッド数と必ず同じ", "この値はメモリ使用量(MB)を示す"]'::jsonb, 1, '`NumGoroutine` は瞬間値です。リクエスト処理中やバックグラウンドタスクの有無で増減します。単発値だけでなく時系列で見るとリーク検知に役立ちます。', 'https://pkg.go.dev/runtime', 'unpublished', false),
  (67, 'セクション26: Go runtime 診断出力', 'runtime.Version の用途', '起動時に `runtime.Version()` を出力する主なメリットはどれですか？', 'fmt.Printf("Go Version: %s\n", runtime.Version())', '["アプリのビジネスロジックを高速化するため", "実行バイナリがどの Go ランタイムで動作しているかを運用時に追跡するため", "JWT の署名方式を選択するため", "DB 接続数を自動調整するため"]'::jsonb, 1, '運用環境での不具合調査では『どの Go バージョンで動いているか』の可観測性が重要です。`runtime.Version()` のログは再現性確認やデプロイ差分の切り分けに有効です。', 'https://pkg.go.dev/runtime', 'unpublished', false),
  (68, 'セクション26: Go runtime 診断出力', 'runtime.GOOS / GOARCH の意味', '`runtime.GOOS` と `runtime.GOARCH` を同時にログ出力する目的として最も適切なのはどれですか？', 'fmt.Printf("OS/Arch: %s/%s\n", runtime.GOOS, runtime.GOARCH)', '["HTTP レスポンスの Content-Type を決めるため", "実行バイナリの対象プラットフォーム（OS/アーキテクチャ）を明示し、環境差異を診断しやすくするため", "データベース方言を切り替えるため", "CORS 設定を自動生成するため"]'::jsonb, 1, '`GOOS/GOARCH` は実行環境の識別子です。コンテナやクロスビルド環境では想定外の組み合わせで動くことがあるため、起動時に可視化しておくと障害対応が速くなります。', 'https://pkg.go.dev/runtime', 'unpublished', false),
  (69, 'セクション27: runtime 診断ログの実践読解', 'NumCPU と GOMAXPROCS が同じ値の意味', '次の起動ログから読み取れる状態として最も適切なのはどれですか？', 'Number of CPUs: 12
GOMAXPROCS: 12', '["CPU制限が設定されておらず、Goプロセスはすべての論理CPUを使用可能", "Go プロセス用に意図的に 6 つの CPU が割り当てられている", "マシンに物理 CPU ソケットが 6 個ある", "このプロセスは単一スレッドで動く"]'::jsonb, 0, 'NumCPU と GOMAXPROCS が同じ値なら、デフォルト設定で全論理CPU を並列実行に使えます。Docker 環境なら cpus 制限がない状態、物理マシンならマシン全体で並列実行できます。', 'https://pkg.go.dev/runtime', 'unpublished', false),
  (70, 'セクション27: runtime 診断ログの実践読解', '起動直後の Goroutines: 1 の状態', '起動直後に Goroutines: 1 と表示される状態から、リクエスト受信中にこの数が増える主な原因はどれですか？', 'Number of Goroutines: 1  // 起動直後
// リクエスト受信後は増加する', '["メモリリークがある", "HTTP リクエストハンドラーが新しい goroutine を起動しているか、バックグラウンドタスクが実行されている", "CPU 使用率が上がった", "Go のバージョンが古い"]'::jsonb, 1, '起動直後は main goroutine だけで 1 ですが、http.ListenAndServe でリクエスト受信時に handler goroutine が生成され、数が増えます。多数の同時リクエストやバック側タスク実行で、さらに増加します。', 'https://pkg.go.dev/runtime', 'unpublished', false),
  (71, 'セクション27: runtime 診断ログの実践読解', 'NumCPU=12, GOMAXPROCS=12, Goroutines=1 の組み合わせから判断できること', '次のログを見たときの状態判断として最も適切なのはどれですか？', 'Number of CPUs: 12
GOMAXPROCS: 12
Number of Goroutines: 1', '["CPU リソースは十分で、並列度は高いが、起動直後でまだリクエストを受け取っていない状態", "CPU が過負荷で、Goroutine が 1 つだけしか作成できない", "Go プロセスはシングルスレッド", "ネットワークが遮断されている"]'::jsonb, 0, '全 CPU が利用可能で並列実行可能な環境「なのに」 Goroutines が 1 つとは、まさに起動直後やアイドル状態を意味します。反対に数百～千の Goroutine がいれば、高負荷状態です。', 'https://pkg.go.dev/runtime', 'unpublished', false),
  (72, 'セクション27: runtime 診断ログの実践読解', 'OS/Arch: linux/amd64 の環境判断', 'OS/Arch: linux/amd64 というログから推測できる運用環境として、最も可能性が高いのはどれですか？', 'OS/Arch: linux/amd64', '["Windows Server 環境で WSL を使用している", "Apple Silicon Mac（ARM64）上での実行", "Docker コンテナ内での実行、Linux サーバー、または Linux VM", "Raspberry Pi や組み込みデバイス"]'::jsonb, 2, 'linux/amd64 は x86-64 CPU をもつ標準的な Linux 実行環境です。Docker、クラウド環境、Linux サーバーの大多数がこの組み合わせで、ARM や Windows では異なります。', 'https://pkg.go.dev/runtime', 'unpublished', false),
  (73, 'セクション27: runtime 診断ログの実践読解', '起動ログから推測できる Docker コンテナ構成', '次のログが Docker コンテナ起動時に見える状況を診断するうえで、最も重要な観点はどれですか？', 'api-1  | Number of CPUs: 12
api-1  | GOMAXPROCS: 12
api-1  | Go Version: go1.26.1
api-1  | OS/Arch: linux/amd64', '["コンテナに CPU 制限（--cpus 等）が設定されておらず、ホストのすべての CPU にアクセス可能な状態", "コンテナは ARM ビルド", "Go のバージョンが最新ではない", "アプリケーションに必ずバグがある"]'::jsonb, 0, '12 CPU すべてが見える＝CPU 制限なし。実運用では resource limits を設定して過剰リソース消費を防ぐため、この状況が見えたら限度設定の見直し対象です。', 'https://pkg.go.dev/runtime', 'unpublished', false),
  (74, 'セクション28: PostgreSQL ログ読解', 'checkpoint complete の意味', '次のログの `checkpoint complete` が示す状態として最も適切なのはどれですか？', 'db-1 | LOG: checkpoint complete: wrote 13 buffers (0.1%); ...', '["WAL が破損したため DB が強制終了した", "チェックポイント処理が正常に完了し、dirty page の一部がディスクへ書き出された", "すべてのテーブルが VACUUM された", "クライアント接続がすべて切断された"]'::jsonb, 1, '`checkpoint complete` は障害ではなく、PostgreSQL の定期的な永続化処理の完了ログです。メモリ上の変更（dirty buffers）をディスクへ反映し、リカバリ起点を進めます。', 'https://www.postgresql.org/docs/current/wal-configuration.html', 'unpublished', false),
  (75, 'セクション28: PostgreSQL ログ読解', 'wrote 13 buffers (0.1%) の読み方', '`wrote 13 buffers (0.1%)` という値の解釈として最も適切なのはどれですか？', '... checkpoint complete: wrote 13 buffers (0.1%); ...', '["13 個の接続を切断した", "チェックポイント対象のうち実際に書き込んだバッファが少量で、負荷は比較的軽い", "13 個の WAL ファイルを新規作成した", "13 秒間ロックを保持した"]'::jsonb, 1, '`buffers` は共有バッファ中の書き出し対象ページ数を示します。0.1% と小さいため、このチェックポイントでの書き込み負荷は低めと読めます。', 'https://www.postgresql.org/docs/current/wal-configuration.html', 'unpublished', false),
  (76, 'セクション28: PostgreSQL ログ読解', 'WAL file(s) added/removed/recycled が 0 の意味', '次のログ断片の解釈として最も適切なのはどれですか？', '... 0 WAL file(s) added, 0 removed, 0 recycled; ...', '["WAL 機能が無効化されている", "そのチェックポイント区間では WAL ファイルの増減・再利用イベントが発生しなかった", "レプリケーションが停止している", "トランザクションが 0 件だった"]'::jsonb, 1, 'この値は WAL 管理イベントの件数です。すべて 0 でも異常とは限らず、単にその期間にファイル追加・削除・再利用が不要だったことを示します。', 'https://www.postgresql.org/docs/current/wal-configuration.html', 'unpublished', false),
  (77, 'セクション28: PostgreSQL ログ読解', 'write / sync / total の関係', '`write=1.221 s, sync=0.019 s, total=1.274 s` の関係として正しい説明はどれですか？', '... write=1.221 s, sync=0.019 s, total=1.274 s; ...', '["total は常に write + sync と完全一致する", "total はチェックポイント全体時間で、write/sync 以外の処理時間も含みうる", "sync はネットワーク同期時間を示す", "write が 1 秒を超えると必ず障害である"]'::jsonb, 1, '`total` はチェックポイント処理全体で、`write` と `sync` のほか管理オーバーヘッドを含むことがあります。したがって厳密一致しない場合があります。', 'https://www.postgresql.org/docs/current/wal-configuration.html', 'unpublished', false),
  (78, 'セクション28: PostgreSQL ログ読解', 'lsn と redo lsn の読み方', '`lsn=0/19B0628, redo lsn=0/19B05F0` から読み取れる内容として最も適切なのはどれですか？', '... lsn=0/19B0628, redo lsn=0/19B05F0', '["redo lsn は現在 lsn より常に大きい", "redo lsn はクラッシュリカバリ開始位置を示し、通常は最新 lsn 以下になる", "lsn は CPU 使用率、redo lsn はメモリ使用率を示す", "この値が表示されると必ず WAL 破損を意味する"]'::jsonb, 1, '`LSN` は WAL 上の位置を示す識別子です。`redo lsn` はリカバリ再生の起点で、一般には最新 `lsn` より前方にあります。差分はリカバリ時に再生対象となる範囲の目安になります。', 'https://www.postgresql.org/docs/current/wal-configuration.html', 'unpublished', false),
  (79, 'セクション29: runtime.NumGoroutine の実践', '初期ゴルーチン数を保存する理由', '次のコードで `initial := runtime.NumGoroutine()` を先に保存している主な理由として、最も適切なのはどれですか？', 'initial := runtime.NumGoroutine()
done := make(chan struct{})

for i := 0; i < 10; i++ {
  go func() {
    time.Sleep(10 * time.Millisecond)
    done <- struct{}{}
  }()
}

for i := 0; i < 10; i++ {
  <-done
}

time.Sleep(50 * time.Millisecond)
final := runtime.NumGoroutine()
if final > initial {
  fmt.Printf("warning: possible goroutine leak: %d\n", final-initial)
}', '["最初に取得しないと `NumGoroutine()` が正しい値を返さなくなるため", "処理前の基準値を保存し、処理完了後に goroutine 数が戻るか比較してリークの目安にするため", "OS スレッド数を取得して `GOMAXPROCS` を自動設定するため", "goroutine を 1 個ずつ停止するための ID を保存するため"]'::jsonb, 1, '`NumGoroutine()` はその瞬間に生存している goroutine 数のスナップショットです。`initial` を処理前の基準値として保存しておくと、処理後の `final` と比較し、終了したはずの goroutine が残っていないかを大まかに確認できます。なお、ランタイム内部 goroutine や計測タイミングの影響があるため、これは厳密なリーク判定ではなく目安として使います。', 'https://pkg.go.dev/runtime#NumGoroutine', 'unpublished', false),
  (80, 'セクション30: Tailwind CSS クラス読解', 'section の className から見た目を読む', '次の Tailwind CSS の `className` が適用された `<section>` の見た目として、最も適切なのはどれですか？', '<section className="mt-7 rounded-[24px] border border-[#14213d]/12 bg-white/72 p-[clamp(20px,4vw,32px)] shadow-[0_22px_48px_rgba(20,33,61,0.12)]">', '["上に余白があり、24px の角丸、薄いボーダー、少し透けた白背景、20px から 32px の可変 padding、柔らかい影が付いたカード状の見た目", "上余白はなく、角丸もなく、濃い紺色の背景に太い実線ボーダーが付き、padding は 0 で影もない", "背景は完全に透明で、hover 時だけ影と padding が付与される。通常時はボーダーも角丸もない", "50% の丸い角丸と固定 4px の padding が付き、背景色は黒、ボーダーは二重線になる"]'::jsonb, 0, '`mt-7` は上側にマージンを付けます。`rounded-[24px]` は任意値による 24px の角丸です。`border` はボーダーを表示し、`border-[#14213d]/12` はカスタム色 `#14213d` を 12% の不透明度で適用します。`bg-white/72` は白背景に 72% の不透明度を指定しています。`p-[clamp(20px,4vw,32px)]` は画面幅に応じて 20px から 32px の間で変化する padding を与えます。`shadow-[0_22px_48px_rgba(20,33,61,0.12)]` は任意値による柔らかいドロップシャドウです。全体として、少し浮いたカード状のセクションに見えます。', 'https://tailwindcss.com/docs/styling-with-utility-classes', 'unpublished', false),
  (81, 'セクション30: Tailwind CSS クラス読解', 'header のレスポンシブ配置を読む', '以下のコードを見て、この `header` の見た目として正しいものはどれですか？', '<header className="mb-[22px] flex flex-col gap-[18px] xl:flex-row xl:items-start xl:justify-between">', '["画面サイズに関わらず、要素は常に横並びに表示される", "小さい画面では縦並び、xl（1280px以上）になると横並びに切り替わり、両端に要素が配置される", "小さい画面では横並び、xl になると縦並びに切り替わる", "画面サイズに関わらず、要素は常に縦並びで中央揃えになる"]'::jsonb, 1, '`flex` で flex コンテナになり、通常は `flex-col` により縦並びです。`gap-[18px]` は子要素間の間隔を 18px にします。`mb-[22px]` は下側マージン 22px です。`xl:flex-row` は xl ブレークポイント以上で横並びへ切り替える指定です。さらに `xl:items-start` で交差軸方向の開始位置に揃え、`xl:justify-between` で主軸方向に要素を両端配置します。したがって、小さい画面では縦並び、xl 以上では横並びで左右に分かれたレイアウトになります。', 'https://tailwindcss.com/docs/styling-with-utility-classes', 'unpublished', false),
  (82, 'セクション31: Tailwind CSS ビルド最適化', '未使用クラスの自動削除', 'Tailwind CSS のビルド時パージ（未使用クラスの自動削除）について、最も適切な説明はどれですか？', 'Tailwind はビルド時に使っていないクラスを自動で削除する。
開発時: 数MB（全クラス入り）
本番ビルド後: 数KB〜数十KB（使ったクラスだけ）
Tailwind v3 以降ではデフォルトで自動なので、基本的に追加意識は不要。', '["本番ビルドでも全クラスをそのまま含むため、CSS サイズはほとんど変わらない", "Tailwind はソースファイル内のクラスを検出して必要なスタイルだけを生成するため、本番 CSS を小さくできる", "未使用クラスの削除はブラウザ実行時に JavaScript が動的に行う", "Tailwind v3 以降では未使用クラス削除機能は廃止され、手動で purge ツールを入れる必要がある"]'::jsonb, 1, 'Tailwind のドキュメントでは、Tailwind はプロジェクト内のソースファイルをスキャンしてクラス名を探し、対応するスタイルを生成すると説明されています。つまり、実際に使ったクラスだけが最終 CSS に含まれるため、本番ビルドの CSS サイズを小さくできます。Tailwind CSS v3 の説明でも、同じ CSS を共有しつつ、ほとんどの Tailwind プロジェクトは非常に小さな CSS を配信できるとされています。要するに、未使用クラスの除去は本番ビルド時に自動で効く最適化です。', 'https://tailwindcss.com/docs/detecting-classes-in-source-files', 'unpublished', false),
  (83, 'セクション31: Tailwind CSS ビルド最適化', '手動で CSS の膨張を抑える方法', 'Tailwind CSS で、手動で CSS の膨張や保守コストを抑える方法として最も適切なのはどれですか？', '// ❌ これが多いとCSSが膨らむ
p-[17px] p-[23px] p-[31px]

// ✅ デザイントークンに統一する
p-4 p-6 p-8

// ❌ 同じクラスが色んな場所に散らばる
<div className="rounded-2xl bg-white shadow-md p-6">
<div className="rounded-2xl bg-white shadow-md p-6">

// ✅ コンポーネントにまとめる
<Card> // 内部でクラスを管理', '["任意値をできるだけ増やし、同じクラス列も各画面に直接書いたほうが最適化しやすい", "任意値を減らしてデザイントークンへ寄せ、重複するクラスの組み合わせはコンポーネントへまとめる", "CSS の膨張を避けるには Tailwind をやめて、すべて inline style に置き換えるのが最善", "同じクラス文字列を何度も書くほど Tailwind が自動でより強く圧縮してくれる"]'::jsonb, 1, 'Tailwind では未使用クラスの自動削除が効きますが、任意値を細かく増やし続けると生成されるユーティリティの種類が増えやすくなります。そのため、`p-[17px]` のような個別値を乱立させるより、`p-4` `p-6` `p-8` のようにデザイントークンへ寄せた方が設計を揃えやすく、出力も管理しやすくなります。また、`rounded-2xl bg-white shadow-md p-6` のような同じクラスの組み合わせが各所に散らばると、見た目の変更やレビューがしづらくなります。`<Card>` のようなコンポーネントへまとめると、内部でクラスを一元管理でき、保守性と再利用性を上げられます。', 'https://tailwindcss.com/docs/detecting-classes-in-source-files', 'unpublished', false),
  (84, 'セクション32: Tailwind v4 CSS-first 構成', 'v4 での CSS-first 設定の正解', 'Tailwind v4 の CSS-first 構成として、最も適切な説明はどれですか？', '/* app.css */
@import "tailwindcss";

@theme {
  --color-brand-500: oklch(0.72 0.11 221.19);
}

/* HTML */
<div class="bg-brand-500">...</div>', '["`@theme` は通常の `:root` と同じで、Tailwind のユーティリティ生成には影響しない", "`@import \"tailwindcss\";` を CSS で読み込み、`@theme` をトップレベルで定義すると、対応するユーティリティ（例: `bg-brand-500`）が使える", "v4 では CSS に何も書かず、`tailwind.config.js` だけが唯一の設定方法である", "`@theme` は任意のセレクタ内（例: `.card { ... }`）にネストして定義するのが推奨される"]'::jsonb, 1, 'Tailwind v4 では CSS-first の設計が中心で、`@import "tailwindcss";` で Tailwind を読み込みます。`@theme` で定義したテーマ変数は単なる CSS 変数ではなく、Tailwind のユーティリティ生成にも使われます。公式ドキュメントでも `--color-*` などのテーマ変数により `bg-*` 等のクラスが有効になること、`@theme` はトップレベルで定義することが示されています。', 'https://tailwindcss.com/docs/theme', 'unpublished', false),
  (85, 'セクション33: ES Modules 基礎', 'export default の性質', '次の `export default` の説明として最も適切なのはどれですか？', '// Button.tsx
export default function Button() {
  return <button>OK</button>;
}

// App.tsx
import PrimaryButton from ''./Button'';', '["1つのモジュールで `export default` は複数定義できる", "`export default` で公開した値は、import 側で任意の名前で受け取れる", "`export default` は必ず中括弧付きで import しなければならない", "`export default` は関数には使えず、クラスでしか使えない"]'::jsonb, 1, 'ES Modules では 1 モジュールにつき default export は 1 つだけ定義できます。default export は import 側で `import AnyName from ''...''` のように任意の識別子名で受け取れます。一方、`{ ... }` を使うのは named export を import する場合です。', 'https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Modules', 'unpublished', false),
  (86, 'セクション34: Go Runtime Monitoring 戦略', '本番監視の導入順と閾値設計', 'Go アプリケーションの本番監視方針として、次の結論の要点を最も正しくまとめたものはどれですか？', 'Monitoring Go runtime metrics is essential for maintaining healthy, performant applications in production.

Start with the default Go collector metrics, then add custom metrics as you learn your application''s specific patterns and requirements.

Remember that thresholds should be adjusted based on your application''s characteristics.
Establish baselines during normal operation and set alerts based on meaningful deviations from those baselines.', '["最初から細かい custom metrics と固定しきい値を大量投入し、どのサービスでも同じ alert 条件を使うのが最善", "まず標準の Go runtime 指標を監視し、必要に応じて Prometheus や OpenTelemetry の custom metrics を足し、しきい値はアプリ固有の通常時ベースラインから調整する", "runtime.NumGoroutine() と runtime.ReadMemStats() は開発時だけに使い、本番ではアプリ独自ログだけ見れば十分", "高スループットなバッチ処理と軽量 API では同じ goroutine 数・GC pause しきい値を共有すべき"]'::jsonb, 1, '結論の中心は、「Go runtime の監視は本番で重要であり、まずは標準の runtime 指標から始める」という点です。そのうえで、Prometheus や OpenTelemetry を使って可視化を広げ、必要になったところだけ custom metrics を追加していくのが推奨されています。また、goroutine 数、メモリ使用量、GC pause などの警告しきい値は全サービス共通の固定値ではなく、アプリの特性によって調整すべきだと述べています。つまり、通常運転時のベースラインを先に観測し、そこから意味のある逸脱に対して alert を張る、という運用方針が正解です。', 'https://pkg.go.dev/runtime/metrics', 'unpublished', false),
  (87, 'セクション35: 英単語 × CSS カラー', '「navy」の英単語の意味', 'CSS で `--color-navy: #14213d;` のように使われる「navy」という英単語の本来の意味として正しいものはどれですか？', '/* index.css */
@theme {
  --color-navy: #14213d; /* 深い紺色 */
}', '["空軍（航空戦力）", "海軍（海上の軍隊）", "陸軍（地上部隊）", "海兵隊（水陸両用部隊）"]'::jsonb, 1, '"navy" の本来の意味は「海軍」です。語源はラテン語の "navis"（船）に由来します。色名としての「ネイビーブルー（navy blue）」はイギリス海軍の制服の色（深い紺色）に由来しており、そこから転じて深い紺色全般を指す色名にもなりました。CSS では `#14213d` のような暗い紺色を `navy` と命名するケースが多いのはこの背景からです。', 'https://developer.mozilla.org/en-US/docs/Web/CSS/named-color', 'unpublished', false),
  (88, 'セクション36: React モジュールスコープ', 'コンポーネント外の定数宣言', '次のコードで `allQuizzes` をコンポーネント関数の外（モジュールスコープ）で宣言している主な理由として最も適切なものはどれですか？', '// モジュールスコープ（コンポーネント外）
const allQuizzes = getAllQuizzes()
const sectionCount = groupQuizzesBySection().size
const quizCountPerSession = allQuizzes.length

function JsonQuizPreviewSection() {
  // ...
}', '["React の規約でデータ取得は必ずコンポーネント外で行わなければならない", "コンポーネントの再レンダリングのたびに再計算されないよう、初回モジュール読み込み時に1度だけ評価するため", "`const` はコンポーネント内では使えないため", "ESLint の react-hooks/exhaustive-deps ルールに違反しないようにするため"]'::jsonb, 1, 'モジュールスコープに宣言すると、そのファイルがはじめて import された時点で1度だけ評価されます。コンポーネント内に書いてしまうと、state 変化などで再レンダリングが起きるたびに `getAllQuizzes()` が呼ばれてしまいます。クイズデータのように「変化しない重い初期化」はモジュールスコープに置くことでコストを抑えられます。なお、値が変化しうる場合は `useState` や `useMemo` を使う方が適切です。', 'https://react.dev/learn/keeping-components-pure', 'unpublished', false),
  (89, 'セクション37: 技術英語読解', '`recommended` の意味', '技術ドキュメントで `It is strongly recommended to restart the server after changing this setting.` と書かれているとき、`recommended` の意味として最も適切なのはどれですか？', 'It is strongly recommended to restart the server after changing this setting.', '["再起動は禁止されている", "再起動が推奨されている", "再起動は必須で、省略すると設定は保存されない", "サーバーは自動的に再起動される"]'::jsonb, 1, '`recommended` は「推奨されている」という意味です。Cambridge Dictionary では、`recommended` は「ある目的や仕事にとって良い・適切だと提案されている、または実行すべき行動として提案されている」と説明されています。したがってこの文は、「この設定を変更したあと、サーバーを再起動するのが強く勧められる」という意味です。`must` のような絶対必須までは言っていませんが、従うべき実務上の推奨として読むのが自然です。', 'https://dictionary.cambridge.org/dictionary/english/recommended', 'unpublished', false),
  (90, 'セクション38: React / TypeScript 英文読解', '`createRoot(container!)` コメントの読解', '次の React 18 の GitHub Issue コメントの意味として、最も適切なものはどれですか？', 'The issue here is that `container` is potentially null. `createRoot(null)` would throw at runtime and therefore rightfully does not compile. If you''re sure it''s not nullable then you can use the `!` operator: `createRoot(container!)`.', '["`container` は常に null ではないので、TypeScript のエラーは誤検知である", "`container` は null の可能性があるため、そのままではコンパイルできないのは正しい。null ではないと確信できるなら `!` で非 null として扱える", "`createRoot(null)` は実行時に安全に無視されるので、`!` は不要である", "`!` 演算子を使うと DOM 要素が自動生成されるので、`getElementById(''root'')` の結果確認は不要になる"]'::jsonb, 1, 'このコメントは、「問題は `container` が null かもしれないことだ」と述べています。`createRoot(null)` は実行時に例外になるため、TypeScript がそのコードを拒否するのは正しい、という意味です。そのうえで、呼び出し側が `container` は null ではないと本当に保証できるなら、non-null assertion の `!` を使って `createRoot(container!)` と書ける、という説明です。つまり、型エラーを黙らせるために無条件で `!` を付けるのではなく、null にならない根拠がある場合だけ使うべき、という文脈です。', 'https://www.typescriptlang.org/docs/handbook/2/everyday-types.html#non-null-assertion-operator-postfix-', 'unpublished', false),
  (91, 'セクション39: ESLint / TypeScript ルール読解', '`@typescript-eslint/no-non-null-assertion: ''error''` の意味', '次の ESLint 設定の意味として最も適切なのはどれですか？', '"@typescript-eslint/no-non-null-assertion": "error"', '["postfix `!` を使う non-null assertion を禁止し、違反は ESLint の error として扱われる", "`x!` は `null` と `undefined` を型から除外し、出力される JavaScript では `!` が削除される", "`warn` は違反を報告するが exit code には影響しない", "このルールはオプションで細かく挙動を調整できる"]'::jsonb, 0, '`@typescript-eslint/no-non-null-assertion` は、`!` postfix を使った non-null assertion を禁止するルールです。typesript-eslint の公式 docs でも `Disallow non-null assertions using the ! postfix operator.` と説明されています。さらに ESLint では、ルールを `"error"` にすると違反は error として扱われ、トリガー時は exit code が 1 になります。一方、TypeScript の docs にある「`x!` は `null` / `undefined` を型から除外し、JavaScript 出力では消える」という説明は演算子自体の性質であり、この ESLint 設定の意味そのものではありません。また、この rule は typescript-eslint docs 上で `This rule is not configurable.` とされています。', 'https://typescript-eslint.io/rules/no-non-null-assertion/', 'unpublished', false),
  (92, 'セクション40: TypeScript / Vite エラー対応', 'vite/client 型定義エラーの原因', '次の TypeScript エラーの原因として最も適切なのはどれですか？

Cannot find type definition file for ''vite/client''.
The file is in the program because:
Entry point of type library ''vite/client'' specified in compilerOptions', '// tsconfig.app.json
{
  "compilerOptions": {
    "types": ["vite/client"]
  }
}', '["`types` で `vite/client` を指定しているが、Vite 依存関係の解決に失敗して型定義を見つけられていない", "`vite/client` は TypeScript で使えない予約語である", "`types` 配列に 1 つしか指定できないため発生する", "JSON ファイルの読み込み設定が不足しているため発生する"]'::jsonb, 0, 'このエラーは、`compilerOptions.types` に `vite/client` を指定しているのに、TypeScript が該当型定義を解決できないときに発生します。多くの場合は依存関係の未インストールや壊れた `node_modules` が原因です。', 'https://vite.dev/guide/features#client-types', 'unpublished', false),
  (93, 'セクション41: TypeScript エラー切り分け', '最初の確認対象', '`Cannot find type definition file for ''vite/client''` が出たとき、最初に確認すべき対象として最も適切なのはどれですか？', '// tsconfig.app.json
{
  "compilerOptions": {
    "types": ["vite/client"]
  }
}', '["tsconfig の `types` 設定が何を要求しているかを確認する", "まず CSS の import を削除する", "React のバージョンを下げる", "eslint.config.js を削除する"]'::jsonb, 0, '切り分けの第一歩は、設定が何を解決しようとしているかを把握することです。`types` に `vite/client` があるなら、TypeScript はその型定義の解決を試みます。', 'https://vite.dev/guide/features#client-types', 'unpublished', false),
  (94, 'セクション41: TypeScript エラー切り分け', 'package.json と実体の差分', '`package.json` に `vite` が定義されているのに `npm ls vite --depth=0` が `(empty)` になる状況の説明として正しいのはどれですか？', '// package.json には vite がある
"devDependencies": {
  "vite": "^7.3.1"
}

// ただし npm ls では empty', '["依存定義はあるが、インストールされていない（node_modules が未構築）", "vite は npm ls で表示されない仕様", "TypeScript 5.9 では vite が無効化される", "ESM プロジェクトでは devDependencies が無視される"]'::jsonb, 0, '`package.json` は要求仕様、`node_modules` は実体です。要求があっても install されていなければ解決できません。', 'https://docs.npmjs.com/cli/v10/commands/npm-ls', 'unpublished', false),
  (95, 'セクション41: TypeScript エラー切り分け', 'npm install の役割', '今回のケースで `npm install` を実行する主目的として最も適切なのはどれですか？', 'npm install', '["未導入の依存関係を node_modules に展開し、`vite/client` 型定義を解決可能にする", "tsconfig のエラーを自動で書き換える", "ESLint ルールを自動修正する", "build 出力を dist から削除する"]'::jsonb, 0, '今回の欠損は設定ではなく依存実体です。`npm install` により Vite 本体と型定義ファイルが利用可能になります。', 'https://docs.npmjs.com/cli/v10/commands/npm-install', 'unpublished', false),
  (96, 'セクション41: TypeScript エラー切り分け', '存在確認コマンドの意味', '`test -f node_modules/vite/client.d.ts` を実行する意義として最も適切なのはどれですか？', 'test -f node_modules/vite/client.d.ts && echo ''vite-client-types-ok''', '["TypeScript が参照する型定義ファイルの実在を直接検証する", "tsconfig の JSON 構文を検証する", "Vite の開発サーバーを起動する", "ESLint の警告を無効化する"]'::jsonb, 0, 'ファイルの存在確認は、推測ではなく事実で切り分けるための最短手段です。', 'https://vite.dev/guide/features#client-types', 'unpublished', false),
  (97, 'セクション41: TypeScript エラー切り分け', '修正完了の判定', 'この問題に対する最終的な完了判定として最も妥当なのはどれですか？', 'npm run build', '["`npm run build` が成功し、TypeScript で同エラーが再現しない", "`package.json` を開いて確認しただけで完了", "`node_modules` が存在すれば無条件で完了", "エディタの表示を閉じれば完了"]'::jsonb, 0, '最終判定は実行結果です。設定確認と依存導入の後、ビルド成功で再現性のある完了確認になります。', 'https://vite.dev/guide/build', 'unpublished', false),
  (98, 'セクション42: Docker トラブルシュート', 'Cannot connect to the Docker daemon の意味', '次のエラーメッセージの意味として最も適切なのはどれですか？

Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?', 'docker ps', '["Docker CLI は動いているが、接続先の Docker デーモン（バックグラウンドサービス）に接続できていない", "コンテナ数が多すぎて `docker ps` がタイムアウトした", "Dockerfile が見つからないため `docker ps` が失敗した", "イメージの pull が未完了なため必ず出る正常メッセージ"]'::jsonb, 0, 'このエラーは、`docker` コマンド自体ではなく、裏で動く Docker デーモンに接続できない状態を示します。代表例は Docker Desktop が未起動、デーモン停止、またはソケット権限の問題です。', 'https://docs.docker.com/engine/daemon/troubleshoot/', 'unpublished', false),
  (99, 'セクション42: Docker トラブルシュート', 'コンテナが Exited (255) になる理由', 'リポジトリのコンテナが `Exited (255)` になっている。原因切り分けとして最も適切な最初の行動はどれですか？', 'docker ps -a
docker logs <container_name>', '["終了コードだけでは原因を断定できないため、まず `docker logs` で起動時エラー（環境変数不足、接続失敗、実行ファイルエラーなど）を確認する", "Exited (255) は常にポート競合なので、ポート番号だけ変更すればよい", "Exited (255) は正常終了の意味なので、対応は不要", "コンテナを再作成せずに、OS を再起動すれば必ず解決する"]'::jsonb, 0, '`255` は一般的に異常終了を示しますが、理由はアプリごとに異なります。まずは `docker logs` と `docker inspect` で実際のエラーメッセージを確認し、設定不足・接続先未起動・コマンド実行失敗などを切り分けるのが正攻法です。', 'https://docs.docker.com/reference/cli/docker/container/logs/', 'unpublished', false),
  (100, 'セクション43: DBマイグレーション運用', 'dirty 状態の意味', 'DBマイグレーション文脈で `dirty` 状態と表示されたときの意味として最も適切なのはどれですか？', 'error: Dirty database version 12. Fix and force version.', '["あるマイグレーションが途中で失敗し、スキーマ整合性が不確定なため後続マイグレーションが停止される状態", "DBに不要データが多いので VACUUM が必要な状態", "マイグレーションが完全成功したことを示す正常状態", "SQLファイル名に誤字があるだけで、実行には影響しない警告状態"]'::jsonb, 0, '`dirty` は途中失敗の保護状態です。まず失敗理由と実DB状態を確認し、必要に応じて手動修正してから履歴バージョンと dirty フラグを整合させて再開します。', 'https://github.com/golang-migrate/migrate/blob/master/GETTING_STARTED.md', 'unpublished', false),
  (101, 'セクション43: DBマイグレーション運用', '000016失敗後に force 16 する意図', '次の対応の説明として最も適切なのはどれですか？

000016 は `information.image_url` が既に存在していたため失敗。
000016 はカラム追加1文のみだったので実体反映済みと判断し、`force 16` で履歴を整えた後に 000017 を適用した。', '-- 000016: ALTER TABLE information ADD COLUMN image_url ...
-- 実DBには既に image_url が存在
-- migration tool: force 16
-- then apply 000017', '["実DBスキーマは16相当まで進んでいると確認できたため、履歴テーブルだけを16に合わせて dirty/不整合を解消し、後続の000017を再開した", "000016 のSQLを自動的にロールバックして、DBを15に完全復元した", "000016 と000017 を同時にスキップし、次回デプロイでまとめて実行する設定にした", "`force 16` はDB実体を自動変更する機能なので、検証なしで使って問題ない"]'::jsonb, 0, 'この対応は『実体と履歴の再同期』です。000016 は「既存カラムのため失敗」だったが、内容がその1文のみで実体が既に満たされていると確認できたため、履歴だけ16に進めて不整合を解消し、次の000017を適用しています。ポイントは force が履歴操作であり、実体変更の代替ではないことです。', 'https://github.com/golang-migrate/migrate/blob/master/GETTING_STARTED.md', 'unpublished', false),
  (102, 'セクション44: SQL データ操作', 'DELETE + サブクエリの対象理解', '次の SQL クエリの目的として最も適切なものはどれですか？', 'DELETE FROM user_favorite_stores
WHERE user_id IN (SELECT id FROM users WHERE email IN (''user1@example.com'', ''user2@example.com'', ''user3@example.com''));', '["指定メールアドレスのユーザー本体を users テーブルから削除する", "指定メールアドレスのユーザーに紐づく user_favorite_stores の行を削除する", "user_favorite_stores に新しい行を追加する", "users テーブルのメールアドレスを一括更新する"]'::jsonb, 1, '内側のサブクエリで、指定メールアドレスに一致する `users.id` を取得し、外側の DELETE でその `id` を `user_id` に持つ `user_favorite_stores` の行を削除します。削除対象は users 本体ではなく関連テーブルです。', 'https://www.postgresql.org/docs/current/sql-delete.html', 'unpublished', false),
  (103, 'セクション45: Linux コマンド基礎', 'wc コマンドの意味', '`wc -l src/data/quizzes.json` で使われている `wc` の意味として最も適切なのはどれですか？', 'wc -l src/data/quizzes.json', '["テキストの行数・単語数・バイト数などを数えるコマンド", "ファイルの所有者を変更するコマンド", "ディレクトリ構造をツリー表示するコマンド", "ファイルを圧縮するコマンド"]'::jsonb, 0, '`wc` は word count の略で、入力テキストの統計情報（行数・単語数・バイト数など）を表示するコマンドです。', 'https://man7.org/linux/man-pages/man1/wc.1.html', 'unpublished', false),
  (104, 'セクション45: Linux コマンド基礎', '`-l` オプションの意味', '`wc -l src/data/quizzes.json` の `-l` オプションが表すものはどれですか？', 'wc -l src/data/quizzes.json', '["ファイルの行数（line count）を表示する", "ファイルの最終更新日時を表示する", "ファイルサイズを人間向け表示にする", "隠しファイルも含めて一覧表示する"]'::jsonb, 0, '`-l` は line の意味で、改行区切りの行数を表示します。今回の出力 `1440 src/data/quizzes.json` はそのファイルが 1440 行であることを示します。', 'https://man7.org/linux/man-pages/man1/wc.1.html', 'unpublished', false),
  (105, 'セクション46: Docker Compose エラー読解', '設定ファイルが見つからないエラーの意味', '次のエラーメッセージの意味として最も適切なものはどれですか？

can''t find a suitable configuration file in this directory or any parent: not found', 'docker compose up', '["現在のディレクトリか親ディレクトリに、利用可能な Compose 設定ファイル（例: docker-compose.yml）が見つからない", "Compose ファイルは見つかったが、ポート競合で起動に失敗している", "Docker デーモンが停止しているため、ソケット接続に失敗している", "イメージのビルドは成功したが、コンテナのヘルスチェックだけ失敗している"]'::jsonb, 0, 'このエラーは、実行場所のパスに Compose 設定ファイルが無いことを示します。`docker compose up` は通常、カレントディレクトリまたは親ディレクトリから `compose.yaml` / `docker-compose.yml` などを探します。', 'https://docs.docker.com/reference/cli/docker/compose/up/', 'unpublished', false),
  (106, 'セクション47: Node.js / JSON 検証', 'JSON.parse で構文検証するコマンドの意味', '次のコマンドの目的として最も適切なものはどれですか？

node -e "JSON.parse(require(''fs'').readFileSync(''src/data/quizzes.json'',''utf8'')); console.log(''quizzes.json valid'')"', 'node -e "JSON.parse(require(''fs'').readFileSync(''src/data/quizzes.json'',''utf8'')); console.log(''quizzes.json valid'')"', '["quizzes.json を読み込んで JSON 構文が正しいか確認し、成功時にメッセージを表示する", "quizzes.json の内容を自動整形して上書き保存する", "quizzes.json を gzip 圧縮して容量を確認する", "quizzes.json の行数を数えて表示する"]'::jsonb, 0, '`readFileSync` で文字列として読み込んだ JSON を `JSON.parse` しており、構文エラーがあれば例外で失敗します。例外が出なければ `console.log(''quizzes.json valid'')` が表示されるため、簡易的なJSON妥当性チェックとして使えます。', 'https://nodejs.org/api/cli.html', 'unpublished', false),
  (107, 'セクション48: React exhaustive-deps 実践', '欠けた依存配列が生む不具合', '`useEffect` / `useMemo` / `useCallback` で依存配列に必要な値を入れ忘れたとき、最も起きやすい問題はどれですか？', 'useEffect(() => {
  console.log(count);
}, []); // count を参照しているのに依存配列にない', '["stale closure により古い値を参照し続け、想定した再同期が起きない", "React が自動で依存を補完するので問題は起きない", "依存を省略すると常に最適化されて再レンダリングが減る", "依存配列は本番ビルドでだけ評価される"]'::jsonb, 0, '依存配列は『Effect が参照する値』を宣言するためのものです。参照値を漏らすと、値が変わっても Effect が再実行されず、古いクロージャを掴んだままになります。', 'https://react.dev/reference/react/useEffect', 'unpublished', false),
  (108, 'セクション48: React exhaustive-deps 実践', '関数依存で無限ループになる理由', '次のパターンで `useEffect` がループしやすい主な理由はどれですか？', 'const logItems = () => console.log(items);
useEffect(() => {
  logItems();
}, [logItems]);', '["毎レンダーで `logItems` の参照が新しくなり、依存変化として Effect が再実行されるため", "`console.log` は非同期なので必ず再レンダーが起きるため", "依存配列に関数を入れると React が例外を投げるため", "`useEffect` はデフォルトで 2 回しか実行されないため"]'::jsonb, 0, '関数をインライン定義すると参照が毎回変わります。Effect がその関数参照に依存していると、依存が毎回変化したと判断され再実行ループにつながります。必要なら `useCallback` で参照を安定化します。', 'https://react.dev/reference/react/useEffect', 'unpublished', false),
  (109, 'セクション48: React exhaustive-deps 実践', '"一度だけ実行"したいときの設計', '`userId` を使う analytics 送信を『実質1回』にしたい。lint を回避せずに実装する方針として最も適切なのはどれですか？', 'useEffect(() => {
  sendAnalytics(userId);
}, []); // lint で userId 不足を指摘', '["`[userId]` を依存に含め、必要なら `useRef` ガードで重複送信を制御する", "eslint-disable コメントで exhaustive-deps を無効化する", "依存配列を削除して毎レンダー送信する", "`userId` を state から外しグローバル変数にする"]'::jsonb, 0, '基本は依存を正しく宣言することです。"一度だけ"の要件がある場合は、依存を隠すのではなく `useRef` などで実行制御を行うのが安全です。', 'https://react.dev/reference/react/useEffect', 'unpublished', false),
  (110, 'セクション48: React exhaustive-deps 実践', 'カスタム Effect Hook の lint 対象化', '`useMyEffect` のようなカスタム Hook も exhaustive-deps のチェック対象に含めたい。設定として最も適切なのはどれですか？', '// ESLint settings または rule-level option で正規表現を指定する', '["`settings.react-hooks.additionalEffectHooks` か rule-level の `additionalHooks` に regex を設定する", "TypeScript の `types` 配列に Hook 名を追加する", "Vite config の plugins に Hook 名を列挙する", "React コンポーネント名を PascalCase にすれば自動で検出される"]'::jsonb, 0, 'eslint-plugin-react-hooks では、カスタム Effect Hook を正規表現で指定して依存配列チェック対象に含められます。共有 settings と rule-level option の両方が用意されています。', 'https://github.com/facebook/react/tree/main/packages/eslint-plugin-react-hooks', 'unpublished', false),
  (111, 'セクション1: React & TypeScript', 'useEffect の依存配列と関数の扱い方', '以下のコードにはバグがあります。React公式の推奨に最も沿った修正はどれですか？', 'function ProductPage({ productId }) {
  const [product, setProduct] = useState(null);

  async function fetchProduct() {
    const res = await fetch(''/api/product/'' + productId);
    const json = await res.json();
    setProduct(json);
  }

  useEffect(() => {
    fetchProduct();
  }, []); // ← バグ
}', '["exhaustive-deps の警告を eslint-disable コメントで無効化する", "fetchProduct を useCallback でラップし、依存配列に [productId] を指定した上で useEffect の依存配列に [fetchProduct] を追加する", "fetchProduct をそのまま useEffect の依存配列に追加する（[fetchProduct]）", "fetchProduct の定義を useEffect の内部に移動し、依存配列を [productId] にする"]'::jsonb, 3, 'React公式（Hooks FAQ）は「関数をEffect内に移動する」を第一の推奨としています。こうすることでfetchProductが依存配列の問題を引き起こさず、productIdが変わるたびに正しく再実行されます。useCallbackを使う方法（選択肢2）も正しく動作しますが、公式はメモ化より先に「関数をEffect内に移動する」シンプルな解決策を優先しています。選択肢1はuseCallbackなしで関数参照が毎レンダーで変わるため無限ループになります。選択肢0はバグを隠蔽するだけで根本的な解決になりません。', 'https://react.dev/reference/react/useEffect#specifying-reactive-dependencies', 'unpublished', false),
  (112, 'セクション49: TypeScript JSX 読解', 'Intrinsic elements の基本訳', '`Intrinsic elements are looked up on the special interface JSX.IntrinsicElements.` の日本語訳として最も適切なのはどれですか？', 'Intrinsic elements are looked up on the special interface JSX.IntrinsicElements.', '["intrinsic elements は、特別なインターフェース JSX.IntrinsicElements 上で参照される。", "intrinsic elements は、JSX.IntrinsicElements を自動生成する。", "intrinsic elements は、特別なインターフェースを常に無視する。", "intrinsic elements は、JSX.IntrinsicElements に変換される。"]'::jsonb, 0, 'looked up はこの文脈では『参照される』『検索される』の意味で、intrinsic elements が JSX.IntrinsicElements を基準に扱われることを述べています。', 'https://www.typescriptlang.org/docs/handbook/jsx.html', 'unpublished', false),
  (113, 'セクション49: TypeScript JSX 読解', 'By default の意味', '本文中の `By default` の意味として最も適切なのはどれですか？', 'By default, if this interface is not specified, then anything goes and intrinsic elements will not be type checked.', '["例外的に", "初期状態では", "明示的に", "結果として"]'::jsonb, 1, '`By default` は『特別な設定がなければ通常は』『初期状態では』という意味で使われています。', 'https://www.typescriptlang.org/docs/handbook/jsx.html', 'unpublished', false),
  (114, 'セクション49: TypeScript JSX 読解', 'if this interface is not specified の訳', '`if this interface is not specified` の日本語訳として最も適切なのはどれですか？', 'By default, if this interface is not specified, then anything goes and intrinsic elements will not be type checked.', '["このインターフェースが自動生成される場合", "このインターフェースが指定されていない場合", "このインターフェースを削除した場合", "このインターフェースを継承した場合"]'::jsonb, 1, '`is not specified` は『指定されていない』を意味します。ここでは JSX.IntrinsicElements が定義されていないケースを指しています。', 'https://www.typescriptlang.org/docs/handbook/jsx.html', 'unpublished', false),
  (115, 'セクション49: TypeScript JSX 読解', '指定されていない場合の挙動', '本文では、`JSX.IntrinsicElements` が指定されていない場合、intrinsic elements はどう扱われると述べられていますか？', 'By default, if this interface is not specified, then anything goes and intrinsic elements will not be type checked.', '["常に厳密に型チェックされる", "自動的に DOM API に変換される", "何でも許され、型チェックされない", "JSX 構文エラーとして扱われる"]'::jsonb, 2, '本文の `anything goes and intrinsic elements will not be type checked` がそのまま根拠で、制約なしに受け入れられ型チェックも行われません。', 'https://www.typescriptlang.org/docs/handbook/jsx.html', 'unpublished', false),
  (116, 'セクション49: TypeScript JSX 読解', 'However の役割', '本文中の `However` はどのような役割をしていますか？', 'However, if JSX.IntrinsicElements is present, then the name of the intrinsic element is looked up as a property on the JSX.IntrinsicElements interface.', '["具体例の追加", "理由の説明", "対比の導入", "結論の強調"]'::jsonb, 2, '前文では『指定されない場合』を説明し、この文では『存在する場合』を説明しているため、However は対比を導入しています。', 'https://www.typescriptlang.org/docs/handbook/jsx.html', 'unpublished', false),
  (117, 'セクション49: TypeScript JSX 読解', 'property on the interface の訳', '`the name of the intrinsic element is looked up as a property on the JSX.IntrinsicElements interface` の日本語訳として最も適切なのはどれですか？', 'However, if JSX.IntrinsicElements is present, then the name of the intrinsic element is looked up as a property on the JSX.IntrinsicElements interface.', '["intrinsic element の名前は、JSX.IntrinsicElements を置き換えるプロパティになる。", "intrinsic element の名前は、JSX.IntrinsicElements インターフェース上のプロパティとして参照される。", "intrinsic element の名前は、プロパティではなく型引数として扱われる。", "intrinsic element の名前は、JSX.IntrinsicElements とは無関係に評価される。"]'::jsonb, 1, '`as a property on ... interface` は『そのインターフェース上のプロパティとして』という意味です。', 'https://www.typescriptlang.org/docs/handbook/jsx.html', 'unpublished', false),
  (118, 'セクション49: TypeScript JSX 読解', '本文内容との一致', '本文の内容に合うものを次から1つ選びなさい。', 'By default, if this interface is not specified, then anything goes and intrinsic elements will not be type checked. However, if JSX.IntrinsicElements is present, then the name of the intrinsic element is looked up as a property on the JSX.IntrinsicElements interface.', '["JSX.IntrinsicElements がなくても常に厳密な型チェックが行われる。", "JSX.IntrinsicElements が存在すると、要素名はそのインターフェースのプロパティとして調べられる。", "Intrinsic elements は JSX.IntrinsicElements とは無関係である。", "JSX.IntrinsicElements があると型チェックは無効になる。"]'::jsonb, 1, '本文後半がそのまま根拠です。JSX.IntrinsicElements がある場合は、要素名をそのプロパティとして照合します。', 'https://www.typescriptlang.org/docs/handbook/jsx.html', 'unpublished', false),
  (119, 'セクション49: TypeScript JSX 読解', '英文全体の要約', 'この英文全体の内容を1文で要約したものとして最も適切なのはどれですか？', 'By default, if this interface is not specified, then anything goes and intrinsic elements will not be type checked. However, if JSX.IntrinsicElements is present, then the name of the intrinsic element is looked up as a property on the JSX.IntrinsicElements interface.', '["JSX の intrinsic elements は常にランタイムでのみ処理され、型とは関係ない。", "JSX.IntrinsicElements の有無によって、intrinsic elements の型チェック方法が変わる。", "JSX.IntrinsicElements は React 専用であり、TypeScript では使用されない。", "intrinsic elements は必ずクラスコンポーネントとして解釈される。"]'::jsonb, 1, '前半は『未指定なら型チェックしない』、後半は『存在すればそのプロパティとして照合する』であり、要約すると型チェック方法が変わるという内容です。', 'https://www.typescriptlang.org/docs/handbook/jsx.html', 'unpublished', false),
  (120, 'セクション49: TypeScript JSX 読解', 'TOEIC風: By default most nearly mean', 'What does the phrase `By default` most nearly mean in this passage?', 'By default, if this interface is not specified, then anything goes and intrinsic elements will not be type checked.', '["In advance", "Normally", "By mistake", "In detail"]'::jsonb, 1, '`By default` means `normally` or `in the standard case` in this passage.', 'https://www.typescriptlang.org/docs/handbook/jsx.html', 'unpublished', false),
  (121, 'セクション49: TypeScript JSX 読解', 'TOEIC風: interface is not specified', 'What happens if the interface is not specified?', 'By default, if this interface is not specified, then anything goes and intrinsic elements will not be type checked.', '["Intrinsic elements are deleted automatically.", "Intrinsic elements are converted into properties.", "Intrinsic elements are not type checked.", "Intrinsic elements become invalid syntax."]'::jsonb, 2, 'The passage explicitly says `intrinsic elements will not be type checked.`', 'https://www.typescriptlang.org/docs/handbook/jsx.html', 'unpublished', false),
  (122, 'セクション49: TypeScript JSX 読解', 'TOEIC風: However の役割', 'What is the role of `However` in the passage?', 'However, if JSX.IntrinsicElements is present, then the name of the intrinsic element is looked up as a property on the JSX.IntrinsicElements interface.', '["It introduces a similar example.", "It adds technical detail.", "It shows a contrast.", "It repeats the previous idea."]'::jsonb, 2, '`However` marks a contrast between the case where the interface is absent and the case where it is present.', 'https://www.typescriptlang.org/docs/handbook/jsx.html', 'unpublished', false),
  (123, 'セクション49: TypeScript JSX 読解', 'TOEIC風: interface が存在する場合', 'According to the passage, what happens when `JSX.IntrinsicElements` is present?', 'However, if JSX.IntrinsicElements is present, then the name of the intrinsic element is looked up as a property on the JSX.IntrinsicElements interface.', '["The intrinsic element name is checked as a property of the interface.", "All intrinsic elements are ignored by the compiler.", "The interface is removed from the program.", "JSX syntax is disabled."]'::jsonb, 0, 'The passage states that the intrinsic element name is looked up as a property on the interface.', 'https://www.typescriptlang.org/docs/handbook/jsx.html', 'unpublished', false),
  (124, 'セクション49: TypeScript JSX 読解', 'TOEIC風: 最も正確な要約', 'Which of the following is most accurate according to the passage?', 'By default, if this interface is not specified, then anything goes and intrinsic elements will not be type checked. However, if JSX.IntrinsicElements is present, then the name of the intrinsic element is looked up as a property on the JSX.IntrinsicElements interface.', '["Type checking always happens, whether the interface exists or not.", "The interface is only used for runtime execution.", "The presence of the interface affects how intrinsic elements are checked.", "Intrinsic elements cannot be used with interfaces."]'::jsonb, 2, 'This is the best summary of the passage: whether the interface exists changes how TypeScript checks intrinsic elements.', 'https://www.typescriptlang.org/docs/handbook/jsx.html', 'unpublished', false),
  (125, 'セクション50: Flutter 情報一覧ロジック', 'isNew 判定の条件', '次のコードにおいて `isNew` が `true` になる条件として最も正しいものはどれですか？', 'final now = DateTime.now();
final newCutoff = now.subtract(Duration(days: _newThresholdDays));
final isDateInNewRange =
    !displayDate.isBefore(newCutoff) && !displayDate.isAfter(now);
final isNew = _currentPage == 1 && isDateInNewRange;

// 未読判定: 既読IDセットに含まれていなければ未読
final isUnread = !_readIds.contains(information.id);

// --- デザイン定数（変更しやすいよう集約） ---
const unreadTitleStyle = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.bold,
  color: Color(0xFF1A1A1A),
);
const readTitleStyle = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.normal,
  color: Color(0xFF888888),
);
const unreadDateStyle = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.bold,
  color: Color(0xFF1A1A1A),
);
const readDateStyle = TextStyle(
  fontSize: 14,
  color: Color(0xFF888888),
);
const newBadgeColor = Color(0xFFFFD600);
const newBadgeTextColor = Color(0xFF1A1A1A);', '["_currentPage が 1 以外でも、displayDate が now より後なら true", "_currentPage が 1 で、displayDate が newCutoff から now の範囲内なら true", "displayDate が newCutoff より前でも _readIds に含まれなければ true", "_readIds に含まれていても newBadgeColor が黄色なら true"]'::jsonb, 1, '`isNew` は `_currentPage == 1` かつ `isDateInNewRange` のAND条件です。`isDateInNewRange` は `displayDate` が `newCutoff` 以上 `now` 以下のとき true になります。', 'https://api.dart.dev/stable/dart-core/DateTime-class.html', 'unpublished', false),
  (126, 'セクション51: TypeScript Property Key', 'Quoted Property Key と keyof', '次の型定義において `type K = keyof Settings;` の結果として最も正しいものはどれですか？', 'type Settings = {
  "api-key": string;
  retryCount: number;
};

type K = keyof Settings;', '["`string`", "`\"api-key\" | \"retryCount\"`", "`\"api-key\" & \"retryCount\"`", "`number`"]'::jsonb, 1, 'quoted property key で定義した `"api-key"` も通常のプロパティキーとして扱われるため、`keyof Settings` は `"api-key" | "retryCount"` になります。なお値としてアクセスする際は `settings["api-key"]` のようにブラケット記法を使うのが基本です。', 'https://www.typescriptlang.org/docs/handbook/2/keyof-types.html', 'unpublished', false),
  (127, 'セクション52: Claude Code アップデート案内', 'Claude Code のバージョン更新', '次のメッセージが表示されたとき、最も適切な対応はどれですか？', 'It looks like your version of Claude Code (1.0.37) needs an update.
A newer version (1.0.88 or higher) is required to continue.

To update, please run:
    claude update', '["`claude update` を実行して必要なバージョンへ更新する", "`git pull` を実行すれば Claude Code も更新される", "そのまま `claude code` を再実行すれば自動で続行できる", "`npm install` を実行すれば必ず解決する"]'::jsonb, 0, 'このメッセージは、現在の Claude Code が `1.0.37` で、継続には `1.0.88` 以上が必要だと明示しています。したがって案内どおり `claude update` を実行して CLI 自体を更新するのが正しい対応です。', 'https://docs.anthropic.com/en/docs/claude-code/overview', 'unpublished', false),
  (128, 'セクション53: JavaScript 英語表現', '組み込みオブジェクトの英訳', '`組み込みオブジェクト` を英語で表すものとして最も適切なのはどれですか？', '// JavaScript で Array, Date, Math などを指す文脈', '["built-in object", "embedded property", "internal variable", "default instance"]'::jsonb, 0, '`組み込みオブジェクト` は英語で一般に `built-in object` と表現します。JavaScript では `Array` や `Date` など、言語や実行環境にあらかじめ備わっているオブジェクトを指す文脈で使われます。', 'https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects', 'unpublished', false),
  (129, 'セクション54: Go ランタイム メモリ統計', 'runtime.MemStats の Alloc フィールド', '以下のコードで `stats.Alloc` が表す値はどれですか？', 'var stats runtime.MemStats
runtime.ReadMemStats(&stats)
fmt.Printf("Alloc: %s\n", formatBytes(stats.Alloc))', '["OSからGoランタイムに割り当てられた総メモリ量", "現在ヒープに使用中のメモリ量（GCされていないオブジェクト）", "プログラム開始からの累計アロケーション量", "スタック領域の使用量"]'::jsonb, 1, '`Alloc` は現在ヒープ上で生きているオブジェクトが使用中のバイト数です。GCが走るたびに減少します。累計アロケーション量は `TotalAlloc`、OSから取得した総量は `Sys` です。', 'https://pkg.go.dev/runtime#MemStats', 'unpublished', false),
  (130, 'セクション54: Go ランタイム メモリ統計', 'TotalAlloc と Alloc の違い', '`stats.TotalAlloc` と `stats.Alloc` の違いとして正しいものはどれですか？', 'fmt.Printf("Alloc（ヒープ使用中）: %s\n", formatBytes(stats.Alloc))
fmt.Printf("TotalAlloc（累計）: %s\n", formatBytes(stats.TotalAlloc))', '["`TotalAlloc` はGC後に減少し、`Alloc` は単調増加する", "`Alloc` はGC後に減少するが、`TotalAlloc` はプログラム開始からの累計で減少しない", "両者は常に同じ値を返す", "`TotalAlloc` はスタックとヒープの合計、`Alloc` はヒープのみ"]'::jsonb, 1, '`Alloc` はGCが走るとオブジェクトが回収されるため減少します。`TotalAlloc` はプログラム開始から確保されたバイト数の累計で、単調増加のみです。メモリ圧力を測るには `Alloc` を、アロケーション頻度を測るには `TotalAlloc` の変化量を見ます。', 'https://pkg.go.dev/runtime#MemStats', 'unpublished', false),
  (131, 'セクション54: Go ランタイム メモリ統計', 'HeapIdle と HeapInuse', '`HeapIdle` が大きい場合、何を意味しますか？', 'fmt.Printf("HeapIdle: %s\n", formatBytes(stats.HeapIdle))
fmt.Printf("HeapInuse: %s\n", formatBytes(stats.HeapInuse))', '["ヒープのメモリ不足が近い", "Goランタイムが確保しているがオブジェクトに使われていないスパンが多い", "GCが全く動いていない", "スタックが大きく成長している"]'::jsonb, 1, '`HeapIdle` はOSから確保済みだがオブジェクトが入っていないスパンの合計です。大きい場合はメモリをOSに返せる余地があります。`debug.FreeOSMemory()` を呼ぶか、`GOGC` を下げると解放されます。`HeapInuse` は実際にオブジェクトが入っているスパンです。', 'https://pkg.go.dev/runtime#MemStats', 'unpublished', false),
  (132, 'セクション54: Go ランタイム メモリ統計', 'NumGC の意味', '`stats.NumGC` が表す値はどれですか？', 'fmt.Printf("NumGC（GCサイクル数）: %d\n", stats.NumGC)', '["現在実行中のGCゴルーチン数", "プログラム開始からの完了したGCサイクル数", "次のGCが発動するまでの残りサイクル数", "強制GC（runtime.GC()）の呼び出し回数のみ"]'::jsonb, 1, '`NumGC` はプログラム開始から完了したGCサイクルの総数です。自動GC・強制GCどちらもカウントされます。強制GCのみのカウントは `NumForcedGC` が別途あります。', 'https://pkg.go.dev/runtime#MemStats', 'unpublished', false),
  (133, 'セクション54: Go ランタイム メモリ統計', 'StackInuse とゴルーチン数の関係', '以下のコードで平均スタックサイズを計算しているとき、`numGoroutines` が増えると `avgStack` はどうなりますか？', 'numGoroutines := runtime.NumGoroutine()
if numGoroutines > 0 {
    avgStack := stats.StackInuse / uint64(numGoroutines)
    fmt.Printf("Average Stack per Goroutine: %s\n", formatBytes(avgStack))
}', '["numGoroutines が増えると avgStack は増加する", "numGoroutines が増えると avgStack は減少する（分母が増えるため）", "numGoroutines と avgStack は無関係", "StackInuse は変化しないため avgStack は常に一定"]'::jsonb, 1, '`avgStack = StackInuse / numGoroutines` なので、分母の `numGoroutines` が増えると `avgStack` は小さくなります。ただし実際はゴルーチンが増えると `StackInuse` も増加するため、実運用での `avgStack` の変化は必ずしも単調ではありません。', 'https://pkg.go.dev/runtime#MemStats', 'unpublished', false),
  (134, 'セクション54: Go ランタイム メモリ統計', 'MSpanInuse とは', '`stats.MSpanInuse` が表すものはどれですか？', 'fmt.Printf("MSpanInuse: %s\n", formatBytes(stats.MSpanInuse))
fmt.Printf("MSpanSys: %s\n", formatBytes(stats.MSpanSys))', '["ヒープオブジェクトのメモリ量", "mspan 構造体（ヒープスパン管理メタデータ）が使用しているメモリ量", "ミューテックスのスピン待機に使われているメモリ量", "OSのメモリマップに使われているメモリ量"]'::jsonb, 1, '`MSpanInuse` はGoランタイムがヒープスパンを管理するための `mspan` 構造体が実際に使用しているメモリ量です。`MSpanSys` はOSから確保した総量で、`MSpanSys - MSpanInuse` がアイドル分になります。', 'https://pkg.go.dev/runtime#MemStats', 'unpublished', false),
  (135, 'セクション54: Go ランタイム メモリ統計', 'formatBytes 関数の動作', '以下の `formatBytes` 関数に `1500` を渡した場合の出力はどれですか？', 'func formatBytes(bytes uint64) string {
    const unit = 1024
    if bytes < unit {
        return fmt.Sprintf("%d B", bytes)
    }
    div, exp := uint64(unit), 0
    for n := bytes / unit; n >= unit; n /= unit {
        div *= unit
        exp++
    }
    return fmt.Sprintf("%.2f %cB", float64(bytes)/float64(div), "KMGTPE"[exp])
}', '["\"1500 B\"", "\"1.46 KB\"", "\"1.50 KB\"", "\"0.00 MB\""]'::jsonb, 1, '1500 >= 1024 なのでKB換算になります。`1500 / 1024 = 1.46484...` なので `"1.46 KB"` です。ループは `n = 1500/1024 = 1` で `1 < 1024` のため即終了し `exp=0`（K）になります。', 'https://pkg.go.dev/runtime#MemStats', 'unpublished', false),
  (136, 'セクション54: Go ランタイム メモリ統計', 'BuckHashSys の用途', '`stats.BuckHashSys` が表すものはどれですか？', 'fmt.Printf("BuckHashSys: %s\n", formatBytes(stats.BuckHashSys))', '["バケットソートに使われるメモリ量", "プロファイリング用バケットハッシュテーブルが使用しているメモリ量", "ハッシュマップの全エントリのメモリ量", "GCのマークビットマップに使われているメモリ量"]'::jsonb, 1, '`BuckHashSys` はGoランタイムがpprof等のプロファイリングデータを管理するバケットハッシュテーブルに使用するメモリ量です。通常は数百KB以下で、アプリのメモリ問題の主因にはなりません。', 'https://pkg.go.dev/runtime#MemStats', 'unpublished', false),
  (137, 'セクション55: Go GC 統計', 'LastGC の型と変換', '以下のコードで `stats.LastGC` を時刻に変換しているとき、`stats.LastGC` の型はどれですか？', 'if stats.LastGC > 0 {
    lastGCTime := time.Unix(0, int64(stats.LastGC))
    fmt.Printf("Last GC: %s\n", lastGCTime.Format(time.RFC3339))
}', '["time.Time", "int64（Unix秒）", "uint64（Unixナノ秒）", "float64（Unix秒の小数）"]'::jsonb, 2, '`MemStats.LastGC` は `uint64` 型で、最後のGCが完了したUnixナノ秒を表します。`time.Unix(0, int64(stats.LastGC))` で `time.Time` に変換します。`time.Unix(sec, nsec)` の第1引数をゼロにし、第2引数にナノ秒を渡すのがポイントです。', 'https://pkg.go.dev/runtime#MemStats', 'unpublished', false),
  (138, 'セクション55: Go GC 統計', 'PauseTotalNs と平均ポーズ時間', '以下のコードで平均GCポーズ時間を計算するとき、`stats.NumGC` がゼロの場合に除算しない理由はどれですか？', 'if stats.NumGC > 0 {
    avgPause := time.Duration(stats.PauseTotalNs / uint64(stats.NumGC))
    fmt.Printf("Average GC Pause: %s\n", avgPause)
}', '["NumGC がゼロだとPauseTotalNsも必ずゼロになるから", "ゼロ除算でパニックが発生するのを防ぐため", "uint64 の除算ではゼロ除算が無視されるから", "NumGC はゼロになり得ないから"]'::jsonb, 1, 'Goでは整数のゼロ除算は実行時パニック（`runtime error: integer divide by zero`）になります。`stats.NumGC > 0` のガードで安全に除算しています。なお `PauseTotalNs` が0でも除算は問題なく0を返すため、ガードは `NumGC` のみで十分です。', 'https://pkg.go.dev/runtime#MemStats', 'unpublished', false),
  (139, 'セクション55: Go GC 統計', 'GCCPUFraction の意味', '`stats.GCCPUFraction` が `0.05` のとき、何を意味しますか？', 'fmt.Printf("GC CPU Fraction: %.4f%%\n", stats.GCCPUFraction*100)

// gcTuningReport() より
if stats.GCCPUFraction > 0.05 {
    fmt.Println("WARNING: GC overhead is high (>5%)")
}', '["GCが5%の確率で実行される", "プログラム実行時間の5%をGCが消費している", "ヒープの5%がGC対象になっている", "GCが毎秒5回実行されている"]'::jsonb, 1, '`GCCPUFraction` は直近のGCサイクルでGCがCPU時間の何割を使ったかを表す `float64`（0〜1）です。`0.05` なら5%のCPU時間をGCが使用しています。5%超は高負荷の目安とされ、`GOGC` を上げる（GC頻度を下げる）か、アロケーション量を減らすことが推奨されます。', 'https://pkg.go.dev/runtime#MemStats', 'unpublished', false),
  (140, 'セクション55: Go GC 統計', 'PauseNs 配列とインデックス計算', '以下のコードで最新のGCポーズ時間を取得するインデックス計算の意味はどれですか？', 'idx := int((stats.NumGC - uint32(i) - 1 + 256) % 256)', '["256サイクル分の循環バッファから最新順にインデックスを計算している", "ランダムなサンプリング位置を計算している", "256で割った余りを使って配列の境界外アクセスを防いでいるだけ", "NumGCを256進数に変換している"]'::jsonb, 0, '`PauseNs` は256要素の循環バッファで、インデックスは `NumGC % 256` の位置に最新値が入ります。`(NumGC - i - 1 + 256) % 256` で i=0が最新、i=1が一つ前…と逆順にアクセスできます。`+256` はアンダーフロー防止です。', 'https://pkg.go.dev/runtime#MemStats', 'unpublished', false),
  (141, 'セクション55: Go GC 統計', 'パーセンタイル計算（P50/P90/P99）', '以下のP99計算コードで `len(pauses)*99/100` を使う理由はどれですか？', 'sort.Slice(pauses, func(i, j int) bool {
    return pauses[i] < pauses[j]
})

p50 := pauses[len(pauses)*50/100]
p90 := pauses[len(pauses)*90/100]
p99 := pauses[len(pauses)*99/100]', '["浮動小数点演算を避けて整数インデックスを求めるため", "配列を256要素に正規化するため", "sort.Sliceが1-basedインデックスを使うため", "99番目の要素だけを取り出すため"]'::jsonb, 0, 'スライスのインデックスは整数なので `int(float64(len)*0.99)` より整数演算 `len*99/100` の方がシンプルです。ソート済み配列の `len*99/100` 番目が99パーセンタイル（下から99%の位置）に相当します。厳密な実装ではなく近似値ですが、GCポーズの傾向把握には十分です。', 'https://pkg.go.dev/runtime#MemStats', 'unpublished', false),
  (142, 'セクション55: Go GC 統計', 'debug.SetGCPercent の使い方', '以下のコードで `debug.SetGCPercent(-1)` を呼んだ後に再度 `debug.SetGCPercent(gcPercent)` を呼ぶ理由はどれですか？', 'gcPercent := debug.SetGCPercent(-1)
debug.SetGCPercent(gcPercent)
if gcPercent < 0 {
    fmt.Println("GOGC: off (GC disabled)")
} else {
    fmt.Printf("GOGC: %d%%\n", gcPercent)
}', '["GCを一時的に無効化して値を読み取るため", "`SetGCPercent` は現在値を返すので `-1` で読み取り専用アクセスし、元の値に戻している", "GCを2回トリガーするため", "負の値を渡すとGCが強制実行されるため"]'::jsonb, 1, '`debug.SetGCPercent(n)` は新しい値を設定し**直前の値**を返します。`-1` を渡すとGCが無効化されてしまうため、返ってきた元の値を即座に再設定して副作用を打ち消しています。現在値だけを読み取る専用関数がないため、このパターンが慣用的です。', 'https://pkg.go.dev/runtime/debug#SetGCPercent', 'unpublished', false),
  (143, 'セクション55: Go GC 統計', 'GOMEMLIMIT の未設定検出', '以下のコードで `unlimitedMemLimit` を `1<<63 - 1` と定義している理由はどれですか？', 'memLimit := debug.SetMemoryLimit(-1)
const unlimitedMemLimit int64 = 1<<63 - 1
if memLimit == unlimitedMemLimit {
    fmt.Println("GOMEMLIMIT: not set")
}', '["int64の最大値がGOMEMLIMIT未設定時のデフォルト値だから", "負の値を表現するため", "メモリ上限を1PBに制限するため", "オーバーフローのチェック用マジックナンバーだから"]'::jsonb, 0, '`debug.SetMemoryLimit` はGOMEMLIMITが設定されていない場合に `math.MaxInt64`（= `1<<63 - 1`）を返します。これはGoの仕様で「上限なし」を意味するセンチネル値です。この値と比較することでGOMEMLIMITが明示設定されているかを判定できます。', 'https://pkg.go.dev/runtime/debug#SetMemoryLimit', 'unpublished', false),
  (144, 'セクション55: Go GC 統計', 'NextGC とヒープ成長比率', '`stats.NextGC / stats.HeapAlloc` が `2.0` のとき、何を意味しますか？', 'if stats.HeapAlloc > 0 && stats.NextGC > 0 {
    growthRatio := float64(stats.NextGC) / float64(stats.HeapAlloc)
    fmt.Printf("Heap Growth Ratio (NextGC/HeapAlloc): %.2fx\n", growthRatio)
}', '["次のGCまでにヒープが2倍になると予測されている", "現在のヒープの2倍に達したときに次のGCが発動する", "GCが2サイクル後に実行される", "ヒープ効率が50%である"]'::jsonb, 1, '`NextGC` は次のGCが発動するヒープサイズの目標値です。デフォルトの `GOGC=100` では前回GC後のヒープサイズの2倍が `NextGC` になります。`NextGC/HeapAlloc = 2.0` は「現在の2倍になったらGC」という状態を表し、デフォルト動作です。', 'https://pkg.go.dev/runtime#MemStats', 'unpublished', false),
  (145, 'セクション55: Go GC 統計', 'NumForcedGC の意味', '`stats.NumForcedGC` が `stats.NumGC` より小さい場合、何を意味しますか？', 'fmt.Printf("Completed GC Cycles: %d\n", stats.NumGC)
fmt.Printf("Forced GC Cycles: %d\n", stats.NumForcedGC)', '["強制GCの一部が失敗した", "自動GC（ランタイムによるトリガー）が発生している", "GCが無効化されている", "NumForcedGCのカウントにバグがある"]'::jsonb, 1, '`NumGC` は全GCサイクル数、`NumForcedGC` は `runtime.GC()` 等で明示的に呼んだGCの回数です。`NumForcedGC < NumGC` はランタイムが自動でGCを実行したサイクルが存在することを意味します。通常の運用では `NumForcedGC` はほぼゼロで、`NumGC` の大半は自動GCです。', 'https://pkg.go.dev/runtime#MemStats', 'unpublished', false),
  (146, 'セクション56: Go ゴルーチン管理', 'runtime.NumGoroutine の用途', '以下のコードで `initial` と `final` を比較している目的はどれですか？', 'initial := runtime.NumGoroutine()

done := make(chan bool)
for i := 0; i < 10; i++ {
    go func(id int) {
        time.Sleep(2 * time.Second)
        done <- true
    }(i)
}

for i := 0; i < 10; i++ {
    <-done
}

time.Sleep(100 * time.Millisecond)
final := runtime.NumGoroutine()

if final > initial {
    fmt.Printf("警告: ゴルーチンリークの可能性を検出！リーク数: %d\n", final-initial)
}', '["ゴルーチンの実行速度を計測するため", "ゴルーチンリークを検出するため", "チャネルのバッファサイズを確認するため", "OSスレッド数の上限を確認するため"]'::jsonb, 1, 'ゴルーチンが適切に終了していれば、全ワーカー完了後のゴルーチン数は起動前の値に戻るはずです。`final > initial` の場合、いずれかのゴルーチンが終了していない（リーク）可能性を示します。テストでは `goleak` パッケージが同様の検出を行います。', 'https://pkg.go.dev/runtime#NumGoroutine', 'unpublished', false),
  (147, 'セクション56: Go ゴルーチン管理', 'ゴルーチンのクロージャと引数渡し', '以下のコードで `go func(id int) { ... }(i)` のように引数で `i` を渡している理由はどれですか？', 'for i := 0; i < 10; i++ {
    go func(id int) {
        time.Sleep(2 * time.Second)
        done <- true
    }(i)
}', '["goroutineにIDを渡してデバッグログを出力するため", "クロージャがループ変数 i を共有するstale closure問題を避けるため", "time.Sleepに引数として使うため", "done チャネルへの送信順序を制御するため"]'::jsonb, 1, 'クロージャが `i` を直接参照すると、全ゴルーチンが同じ変数を共有しループ終了後の値（10）を見てしまいます（stale closure）。引数 `id int` として値コピーを渡すことで各ゴルーチンが独立した値を持ちます。Go 1.22以降はループ変数のスコープが変わりこの問題が緩和されましたが、明示的な引数渡しは可読性のために推奨されます。', 'https://pkg.go.dev/runtime#NumGoroutine', 'unpublished', false),
  (148, 'セクション56: Go ゴルーチン管理', 'time.Sleep(100 * time.Millisecond) の役割', '全ワーカーの完了を `<-done` で待った後に `time.Sleep(100 * time.Millisecond)` を挟んでいる理由はどれですか？', 'for i := 0; i < 10; i++ {
    <-done
}

time.Sleep(100 * time.Millisecond)
final := runtime.NumGoroutine()', '["次のGCサイクルを発生させるため", "ランタイムがゴルーチンのクリーンアップを完了する時間を与えるため", "チャネルのバッファをフラッシュするため", "OSスレッドのスケジューリングを安定させるため"]'::jsonb, 1, '`done <- true` を送信しても、送信側ゴルーチンがスケジューラによって完全に終了・回収されるまでわずかな時間がかかります。即座に `NumGoroutine()` を呼ぶとまだ終了処理中のゴルーチンがカウントされ誤検知になることがあります。短いスリープでランタイムのクリーンアップを待ちます。', 'https://pkg.go.dev/runtime#NumGoroutine', 'unpublished', false),
  (149, 'セクション56: Go ゴルーチン管理', 'runtime.GOMAXPROCS の意味', '`runtime.GOMAXPROCS(0)` を呼び出したとき何が返りますか？', 'fmt.Printf("GOMAXPROCS: %d\n", runtime.GOMAXPROCS(0))', '["GOMAXPROCSを0に設定して以前の値を返す", "現在のGOMAXPROCS値を変更せず返す", "利用可能なCPUコア数を返す", "実行中のOSスレッド数を返す"]'::jsonb, 1, '`GOMAXPROCS(n)` はn>0なら値を設定して以前の値を返し、n=0なら設定を変更せず現在値を返します。読み取り専用アクセスに `0` を使うのは慣用パターンです。初期値は `runtime.NumCPU()` と同じです。', 'https://pkg.go.dev/runtime#NumGoroutine', 'unpublished', false),
  (150, 'セクション56: Go ゴルーチン管理', 'unbuffered channel でのワーカー同期', '以下のコードで `done` チャネルをバッファなし（`make(chan bool)`）にしている場合、ワーカーが `done <- true` を送信するタイミングはどれですか？', 'done := make(chan bool)
for i := 0; i < 10; i++ {
    go func(id int) {
        time.Sleep(2 * time.Second)
        done <- true
    }(i)
}
for i := 0; i < 10; i++ {
    <-done
}', '["受信側が <-done を呼ぶ準備ができるまでワーカーはブロックされる", "ワーカーは done <- true を非同期で送信してすぐ終了する", "バッファなしチャネルへの送信は常にパニックになる", "メインゴルーチンが <-done を呼ぶ前にバッファに積まれる"]'::jsonb, 0, 'バッファなしチャネルは送受信が必ずランデブー（同期）します。送信側（ワーカー）は受信側（メインゴルーチン）が `<-done` を呼ぶまでブロックされます。これにより「10回 `<-done` を受け取る = 10ワーカーが全員完了」という同期が実現します。', 'https://pkg.go.dev/runtime#NumGoroutine', 'unpublished', false),
  (151, 'セクション56: Go ゴルーチン管理', 'ワーカー生成後のゴルーチン数', '以下のコードで `afterSpawn` の値として期待される値はどれですか（初期ゴルーチン数が1の場合）？', 'initial := runtime.NumGoroutine()  // 1

for i := 0; i < 10; i++ {
    go func(id int) {
        time.Sleep(2 * time.Second)
        done <- true
    }(i)
}

afterSpawn := runtime.NumGoroutine()
fmt.Printf("ワーカー生成後: %d\n", afterSpawn)', '["1（ゴルーチンはまだ起動していない）", "10（ワーカーのみ）", "11（メイン + 10ワーカー）", "不定（スケジューラ次第）"]'::jsonb, 2, '`go func()` でゴルーチンを起動すると即座にスケジューラに登録されます。メインゴルーチン(1) + 10ワーカー = 11 が期待値です。ただし `NumGoroutine()` はランタイムの内部ゴルーチン（GC補助など）も含む場合があり、環境によって±数個の誤差がありえます。', 'https://pkg.go.dev/runtime#NumGoroutine', 'unpublished', false),
  (152, 'セクション57: Go JWT 認証', 'jwt.RegisteredClaims の ExpiresAt', '以下のコードで発行されるJWTの有効期限はどれですか？', 'claims := jwt.RegisteredClaims{
    Subject:   s.adminUser,
    IssuedAt:  jwt.NewNumericDate(time.Now()),
    ExpiresAt: jwt.NewNumericDate(time.Now().Add(24 * time.Hour)),
}
token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
return token.SignedString(s.jwtSecret)', '["発行から1時間", "発行から24時間", "発行から7日間", "無期限"]'::jsonb, 1, '`time.Now().Add(24 * time.Hour)` で現在時刻から24時間後を `ExpiresAt` に設定しています。`jwt.NewNumericDate` はGoの `time.Time` をJWT仕様の NumericDate（Unixタイムスタンプ）に変換します。', 'https://pkg.go.dev/github.com/golang-jwt/jwt/v5', 'unpublished', false),
  (153, 'セクション57: Go JWT 認証', 'Bearer トークンの検証フロー', '以下の `requireAuth` ミドルウェアで `strings.HasPrefix(header, "Bearer ")` を最初に確認する理由はどれですか？', 'header := r.Header.Get("Authorization")
if !strings.HasPrefix(header, "Bearer ") {
    writeError(w, http.StatusUnauthorized, "missing bearer token")
    return
}
tokenString := strings.TrimPrefix(header, "Bearer ")
claims := &jwt.RegisteredClaims{}
token, err := jwt.ParseWithClaims(tokenString, claims, func(token *jwt.Token) (any, error) {
    if token.Method != jwt.SigningMethodHS256 {
        return nil, fmt.Errorf("unexpected signing method: %s", token.Method.Alg())
    }
    return s.jwtSecret, nil
})', '["JWTの署名を事前検証するため", "Authorizationヘッダーが存在しない・形式が違う場合を早期リターンするため", "Base64デコードを行うため", "トークンの有効期限を確認するため"]'::jsonb, 1, '`Bearer ` プレフィックスがない場合はJWT自体が存在しないか形式が不正です。`jwt.ParseWithClaims` を呼ぶ前に早期リターンすることで不要なパース処理を省き、エラーメッセージも明確になります。', 'https://pkg.go.dev/github.com/golang-jwt/jwt/v5', 'unpublished', false),
  (154, 'セクション57: Go JWT 認証', '署名アルゴリズムの検証', '以下のキー関数で署名アルゴリズムを確認している理由はどれですか？', 'func(token *jwt.Token) (any, error) {
    if token.Method != jwt.SigningMethodHS256 {
        return nil, fmt.Errorf("unexpected signing method: %s", token.Method.Alg())
    }
    return s.jwtSecret, nil
}', '["パフォーマンス最適化のため", "alg:none 攻撃など意図しないアルゴリズムによる検証バイパスを防ぐため", "HS256以外ではシークレットキーが不要なため", "jwt.ParseWithClaims がアルゴリズムを自動検出できないため"]'::jsonb, 1, '攻撃者がヘッダーの `alg` を `none` に書き換えると、ライブラリによっては署名検証をスキップします。キー関数内で期待するアルゴリズムを明示的に確認することで、このアルゴリズム混同攻撃を防止します。これはJWT利用時のセキュリティベストプラクティスです。', 'https://pkg.go.dev/github.com/golang-jwt/jwt/v5', 'unpublished', false),
  (155, 'セクション57: Go JWT 認証', 'http.Handle と requireAuth の合成', '以下のルーティングで `s.requireAuth(http.HandlerFunc(s.handleListQuizzes))` のように2つの型変換を行っている理由はどれですか？', 'mux.Handle(
    "GET /api/admin/quizzes",
    s.requireAuth(http.HandlerFunc(s.handleListQuizzes)),
)', '["s.handleListQuizzes はメソッドなので直接 http.Handler として渡せないため、http.HandlerFunc でラップする", "requireAuth がメソッドを受け取れないため", "mux.Handle が関数ポインタを受け取らないため", "http.HandlerFunc はパフォーマンス最適化のためのラッパー"]'::jsonb, 0, '`s.handleListQuizzes` は `func(http.ResponseWriter, *http.Request)` 型のメソッド値です。`mux.Handle` は `http.Handler` インターフェース（`ServeHTTP` メソッドを持つ型）を要求します。`http.HandlerFunc` は関数を `http.Handler` に変換する型エイリアスで、`ServeHTTP` が定義されています。', 'https://pkg.go.dev/net/http#HandlerFunc', 'unpublished', false),
  (156, 'セクション57: Go JWT 認証', 'handleLogin での認証情報比較', '以下の認証処理で `payload.Username != s.adminUser || payload.Password != s.adminPassword` の条件が真の場合、HTTPステータスコードはどれですか？', 'if payload.Username != s.adminUser || payload.Password != s.adminPassword {
    writeError(w, http.StatusUnauthorized, "invalid credentials")
    return
}', '["400 Bad Request", "401 Unauthorized", "403 Forbidden", "404 Not Found"]'::jsonb, 1, '認証情報が不正（ユーザー名・パスワードの不一致）は `401 Unauthorized` です。`403 Forbidden` は認証済みだがアクセス権限がない場合、`400 Bad Request` はリクエスト形式が不正な場合に使います。RFC 7235に基づき、認証失敗は401が正しい選択です。', 'https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Status/401', 'unpublished', false),
  (157, 'セクション58: Go HTTP & CORS', 'withCORS の Origin 動的設定', '以下の CORS ミドルウェアで `Access-Control-Allow-Origin` を固定値 `*` ではなくリクエストの `Origin` ヘッダーで動的に設定している理由はどれですか？', 'origin := r.Header.Get("Origin")
if origin != "" {
    w.Header().Set("Access-Control-Allow-Origin", origin)
    w.Header().Set("Vary", "Origin")
}', '["* ではCookieや認証ヘッダーを含むリクエストが許可されないため", "* はChromiumブラウザで動作しないため", "動的設定の方がパフォーマンスが高いため", "* はHTTPSでのみ使用できないため"]'::jsonb, 0, '`Access-Control-Allow-Credentials: true` と組み合わせる場合、`Access-Control-Allow-Origin: *` はブラウザに拒否されます。Cookieや `Authorization` ヘッダーを含む認証リクエストでは、オリジンを明示する必要があります。`Vary: Origin` はキャッシュがオリジンごとに別々のレスポンスを保持するよう指示します。', 'https://pkg.go.dev/net/http', 'unpublished', false),
  (158, 'セクション58: Go HTTP & CORS', 'OPTIONS プリフライトリクエストの処理', '以下のコードで `OPTIONS` メソッドを特別に処理している理由はどれですか？', 'if r.Method == http.MethodOptions {
    w.WriteHeader(http.StatusNoContent)
    return
}
next.ServeHTTP(w, r)', '["OPTIONS は危険なメソッドなので即座に遮断するため", "ブラウザがCORSプリフライトとして OPTIONS を送るため、本処理前に204を返す必要があるため", "OPTIONSレスポンスはボディを含めてはいけないため", "mux が OPTIONS を認識しないため"]'::jsonb, 1, 'ブラウザはクロスオリジンリクエストの前に `OPTIONS` メソッドでプリフライトリクエストを送り、サーバーが許可しているかを確認します。CORSヘッダーを付けた `204 No Content` を返すことでブラウザに「許可済み」を伝え、本リクエストの送信に進ませます。', 'https://pkg.go.dev/net/http', 'unpublished', false),
  (159, 'セクション58: Go HTTP & CORS', 'writeJSON でのエンコード', '以下の `writeJSON` で `json.NewEncoder(w).Encode(payload)` を使う利点はどれですか？', 'func writeJSON(w http.ResponseWriter, status int, payload any) {
    w.Header().Set("Content-Type", "application/json")
    w.WriteHeader(status)
    if payload == nil {
        return
    }
    if err := json.NewEncoder(w).Encode(payload); err != nil {
        log.Printf("encode response: %v", err)
    }
}', '["`json.Marshal` より高速なため", "メモリに全データをバッファせず `http.ResponseWriter` に直接ストリーム書き込みできるため", "文字コードを自動変換するため", "`any` 型を受け取れるのは `Encoder` だけのため"]'::jsonb, 1, '`json.Marshal` は全データをメモリ上の `[]byte` に一度展開してから書き込みます。`json.NewEncoder(w).Encode` は `io.Writer`（ここでは `http.ResponseWriter`）に直接ストリーム出力するためメモリ効率が良いです。大きなレスポンスで特に有効です。', 'https://pkg.go.dev/net/http', 'unpublished', false),
  (160, 'セクション58: Go HTTP & CORS', 'io.LimitReader によるリクエストボディ制限', '以下のコードで `io.LimitReader(r.Body, 1<<20)` を使う理由はどれですか？', 'decoder := json.NewDecoder(io.LimitReader(r.Body, 1<<20))
decoder.DisallowUnknownFields()', '["JSONのパース速度を向上させるため", "1MB超のリクエストボディによるメモリ枯渇・DoS攻撃を防ぐため", "r.Body をコピーして再利用できるようにするため", "Content-Length ヘッダーの検証をするため"]'::jsonb, 1, '`1<<20` は 1MB（1,048,576バイト）です。制限なしで `r.Body` を読むと、巨大なボディを送りつけるDoS攻撃でサーバーメモリを枯渇させられます。`LimitReader` で上限を設けることで安全にボディを処理できます。', 'https://pkg.go.dev/net/http', 'unpublished', false),
  (161, 'セクション58: Go HTTP & CORS', 'DisallowUnknownFields の効果', '`decoder.DisallowUnknownFields()` を設定した場合、JSONに未知フィールドが含まれていたときどうなりますか？', 'decoder := json.NewDecoder(io.LimitReader(r.Body, 1<<20))
decoder.DisallowUnknownFields()
if err := decoder.Decode(dst); err != nil {
    return err
}', '["未知フィールドは無視されてデコード成功", "デコードエラーが返される", "未知フィールドのみ別の変数に格納される", "パニックが発生する"]'::jsonb, 1, 'デフォルトでは `json.Decoder` は未知フィールドを無視します。`DisallowUnknownFields()` を呼ぶと、構造体に対応するフィールドが存在しないJSONキーがあった場合にエラーを返します。タイポや意図しないフィールドを早期検出するためのバリデーション手段です。', 'https://pkg.go.dev/net/http', 'unpublished', false),
  (162, 'セクション58: Go HTTP & CORS', '2回目の Decode で io.EOF を確認', '以下のコードで2回目の `decoder.Decode(&extra)` を行う目的はどれですか？', 'if err := decoder.Decode(dst); err != nil {
    return err
}
var extra json.RawMessage
if err := decoder.Decode(&extra); err != io.EOF {
    return errors.New("request body must contain a single JSON object")
}', '["追加フィールドをキャプチャするため", "リクエストボディに複数のJSONオブジェクトが含まれていないか確認するため", "デコードのキャッシュをクリアするため", "r.Body を閉じるため"]'::jsonb, 1, '1回目の `Decode` 後に `io.EOF` 以外が返る場合、ボディにまだデータが残っています。`{...}{...}` のように複数のJSONオブジェクトを連結して送る攻撃や誤りを検出できます。正常なリクエストなら2回目の `Decode` は `io.EOF` を返します。', 'https://pkg.go.dev/net/http', 'unpublished', false),
  (163, 'セクション58: Go HTTP & CORS', 'r.PathValue によるパスパラメータ取得', '以下のコードで `r.PathValue("id")` を使っています。これはGoのどのバージョンから使えますか？', 'func (s *server) handleGetQuiz(w http.ResponseWriter, r *http.Request) {
    quizID, err := parseID(r.PathValue("id"))
    if err != nil {
        writeError(w, http.StatusBadRequest, err.Error())
        return
    }
}', '["Go 1.18（Generics導入時）", "Go 1.20", "Go 1.22", "Go 1.19"]'::jsonb, 2, '`http.Request.PathValue` と `ServeMux` のパターンマッチング（`{id}` 記法）はGo 1.22で標準ライブラリに追加されました。それ以前はパスパラメータの取得に `gorilla/mux` や `chi` などサードパーティのルーターが必要でした。', 'https://pkg.go.dev/net/http', 'unpublished', false),
  (164, 'セクション59: Go SQL & JSONB', 'sql.NullString の使い方', '以下のコードで `code` フィールドに `sql.NullString` を使っている理由はどれですか？', 'var item quiz
var code sql.NullString

err := scanner.Scan(
    &item.ID,
    // ...
    &code,
    // ...
)

if code.Valid {
    item.Code = &code.String
}', '["NullStringはStringより高速にスキャンできるため", "DBのNULL値をGoの nil として安全に扱うため", "Stringではマルチバイト文字を扱えないため", "sql.Scanがstring型を直接受け取れないため"]'::jsonb, 1, 'DBのカラムが NULL の場合、`string` に直接スキャンするとエラーになります。`sql.NullString` は `{String string; Valid bool}` を持ち、`Valid=false` のとき NULL を表します。スキャン後に `code.Valid` を確認して `*string`（nil or 値）に変換しています。', 'https://pkg.go.dev/database/sql', 'unpublished', false),
  (165, 'セクション59: Go SQL & JSONB', 'JSONB カラムのスキャン', '以下のコードで `options` を `[]byte` でスキャンしてから `json.Unmarshal` している理由はどれですか？', 'var optionsJSON []byte
err := scanner.Scan(
    // ...
    &optionsJSON,
    // ...
)
json.Unmarshal(optionsJSON, &item.Options)', '["[]stringには直接スキャンできないため、[]byteで受けてからGoの型に変換する", "PostgreSQLのJSONBはバイナリ形式で返されるため", "json.Unmarshalの方がsql.Scanより速いため", "[]stringはsql.Scanでnilになるため"]'::jsonb, 0, '`database/sql` は `[]string` 型への直接スキャンをサポートしていません。PostgreSQLのJSONBカラムをスキャンするには一旦 `[]byte` または `string` で受け取り、`json.Unmarshal` でGoの型に変換するのが標準的なパターンです。', 'https://pkg.go.dev/database/sql', 'unpublished', false),
  (166, 'セクション59: Go SQL & JSONB', 'ON CONFLICT DO NOTHING の使い所', '以下のSQLで `ON CONFLICT (id) DO NOTHING` を指定した場合の動作はどれですか？', 'INSERT INTO quizzes (id, section, title, ...)
VALUES ($1, $2, $3, ...)
ON CONFLICT (id) DO NOTHING;', '["同じidが存在するとエラーが発生する", "同じidが存在する場合は既存行を上書きする", "同じidが存在する場合はINSERTをスキップして正常終了する", "同じidが存在する場合はNULLを挿入する"]'::jsonb, 2, '`ON CONFLICT (id) DO NOTHING` は競合（主キー重複など）が発生した場合にエラーを発生させずスキップします。冪等なシード処理に適しています。上書きしたい場合は `ON CONFLICT DO UPDATE SET ...`（UPSERT）を使います。', 'https://www.postgresql.org/docs/current/sql-insert.html#SQL-ON-CONFLICT', 'unpublished', false),
  (167, 'セクション59: Go SQL & JSONB', 'RETURNING 句の活用', '以下のINSERT文で `RETURNING` 句を使っている理由はどれですか？', 'item, err := scanQuiz(s.db.QueryRow(`
    INSERT INTO quizzes (...)
    VALUES ($1, $2, ...)
    RETURNING
        id,
        section,
        created_at,
        updated_at
`, ...))', '["INSERTの実行確認のため", "INSERT後にSELECTを別途発行せずに挿入された行のデータを1回のクエリで取得するため", "トランザクションを自動コミットするため", "created_at のデフォルト値を上書きするため"]'::jsonb, 1, '`RETURNING` はINSERT/UPDATE/DELETEで変更された行のカラム値を返すPostgreSQL拡張です。`INSERT ... RETURNING id, created_at` とすることで、DB側で生成された `BIGSERIAL` のIDやデフォルト値 `NOW()` の `created_at` を別途SELECTなしで取得できます。', 'https://www.postgresql.org/docs/current/sql-insert.html#SQL-INSERT-RETURNING', 'unpublished', false),
  (168, 'セクション59: Go SQL & JSONB', 'rows.Err() の確認', '以下のコードで `rows.Close()` の後に `rows.Err()` を確認している理由はどれですか？', 'rows, err := s.db.Query(`SELECT ...`)
if err != nil { ... }
defer rows.Close()

for rows.Next() {
    // ...
}

if err := rows.Err(); err != nil {
    writeError(w, http.StatusInternalServerError, err.Error())
    return
}', '["rows.Closeのエラーを確認するため", "ループ中に発生したDBエラー（ネットワーク断など）を検出するため", "結果セットが空かどうかを確認するため", "rows.Nextの戻り値を再確認するため"]'::jsonb, 1, '`rows.Next()` がfalseを返した理由は「全行読み終わった」または「エラー発生」の2つです。`rows.Err()` でイテレーション中のエラーを確認しないと、DBサーバーとの通信断などで途中で切れた結果を正常として返してしまうバグが起きます。', 'https://pkg.go.dev/database/sql', 'unpublished', false),
  (169, 'セクション59: Go SQL & JSONB', 'sql.ErrNoRows の判定', '以下のコードで `errors.Is(err, sql.ErrNoRows)` を使っている理由はどれですか？', 'item, err := scanQuiz(s.db.QueryRow(`SELECT ... WHERE id = $1`, quizID))
if err != nil {
    if errors.Is(err, sql.ErrNoRows) {
        writeError(w, http.StatusNotFound, "quiz not found")
        return
    }
    writeError(w, http.StatusInternalServerError, err.Error())
    return
}', '["QueryRowは必ずエラーを返すため", "レコードが見つからない場合と内部エラーを区別して適切なHTTPステータスを返すため", "sql.ErrNoRowsはpanicを防ぐためのセンチネル値のため", "errors.Isを使わないと型アサーションが失敗するため"]'::jsonb, 1, '`db.QueryRow` はレコードが0件のとき `sql.ErrNoRows` を返します。これを区別しないと「存在しないID」へのリクエストに `500 Internal Server Error` を返してしまいます。`errors.Is` でエラーの種類を判定し、`404 Not Found` と `500` を正しく使い分けます。', 'https://pkg.go.dev/database/sql', 'unpublished', false),
  (170, 'セクション59: Go SQL & JSONB', 'setval でシーケンスをリセット', 'マイグレーションのシードSQL末尾にある以下のSQL文の目的はどれですか？', 'SELECT setval(''quizzes_id_seq'', (SELECT MAX(id) FROM quizzes));', '["シーケンスを1にリセットして最初からIDを採番し直すため", "INSERT後にシーケンスの現在値を最大IDに合わせ、次の自動採番が重複しないようにするため", "quizzes_id_seqテーブルを初期化するため", "MAX(id)の値をログに出力するため"]'::jsonb, 1, '`BIGSERIAL` のシーケンスは通常INSERTのたびにインクリメントされますが、`id` を明示指定したINSERT（シードデータ）ではシーケンスが進みません。このため次の通常INSERTが既存IDと重複する可能性があります。`setval` でシーケンスを `MAX(id)` に合わせることで重複を防ぎます。', 'https://pkg.go.dev/database/sql', 'unpublished', false),
  (171, 'セクション60: Go embed & golang-migrate', '//go:embed ディレクティブ', '以下のコードで `//go:embed migrations/*.sql` を使う目的はどれですか？', '//go:embed migrations/*.sql
var migrationsFS embed.FS', '["実行時にファイルシステムからSQLを読み込むため", "ビルド時にSQLファイルをバイナリに埋め込み、デプロイ時に別途ファイルを配置不要にするため", "SQLファイルを暗号化するため", "マイグレーションを自動実行するため"]'::jsonb, 1, '`//go:embed` はビルド時に指定したファイルをGoバイナリに埋め込みます。`migrations/*.sql` をバイナリに含めることで、デプロイ先サーバーにSQLファイルを別途配置する必要がなくなります。`embed.FS` は組み込みファイルへの読み取り専用アクセスを提供します。', 'https://pkg.go.dev/embed', 'unpublished', false),
  (172, 'セクション60: Go embed & golang-migrate', 'migrate.ErrNoChange の処理', '以下のコードで `errors.Is(err, migrate.ErrNoChange)` を無視している理由はどれですか？', 'if err := m.Up(); err != nil && !errors.Is(err, migrate.ErrNoChange) {
    return err
}
return nil', '["ErrNoChange はフォーマットエラーのため無視できる", "全マイグレーション適用済みの場合 ErrNoChange が返り、これはエラーではなく正常状態のため", "ErrNoChange はGoの標準エラーではないため比較できないから", "m.Up() は常にエラーを返すため"]'::jsonb, 1, '`m.Up()` は全マイグレーションが既に適用されている場合（追加変更なし）に `migrate.ErrNoChange` を返します。これはエラーではなく「何もすることがない」という正常な状態です。サーバー再起動のたびに `Up()` を呼ぶ構成ではこの処理が必須です。', 'https://github.com/golang-migrate/migrate', 'unpublished', false),
  (173, 'セクション60: Go embed & golang-migrate', 'schema_migrations テーブルの役割', 'golang-migrate が自動作成する `schema_migrations` テーブルの役割はどれですか？', '-- golang-migrate が内部で管理するテーブル
SELECT version, dirty FROM schema_migrations;
--  version | dirty
-- ---------+-------
--        2 | f', '["マイグレーションSQLの内容を保存するため", "どのバージョンのマイグレーションまで適用済みかを追跡するため", "ロールバック用にデータのスナップショットを保存するため", "マイグレーションの実行時間を記録するため"]'::jsonb, 1, '`schema_migrations` は適用済みマイグレーションのバージョン番号と `dirty`（失敗フラグ）を管理します。`version=2` なら `002_` までが適用済みを意味します。`dirty=true` はマイグレーション途中で失敗した状態を示し、手動修正が必要になります。', 'https://github.com/golang-migrate/migrate', 'unpublished', false),
  (174, 'セクション60: Go embed & golang-migrate', 'iofs.New の第2引数', '以下のコードで `iofs.New(migrationsFS, "migrations")` の第2引数 `"migrations"` は何を意味しますか？', 'srcDriver, err := iofs.New(migrationsFS, "migrations")', '["マイグレーション名のプレフィックス", "embed.FS 内でSQLファイルを探すディレクトリパス", "データベース名", "マイグレーションのバージョン番号"]'::jsonb, 1, '`iofs.New` の第2引数は `embed.FS` 内のどのディレクトリをルートとしてマイグレーションファイルを探すかを指定します。`//go:embed migrations/*.sql` で埋め込んだファイルは `migrations/` ディレクトリ構造で `embed.FS` に入るため、`"migrations"` を指定することで `001_create_tables.up.sql` 等が正しく検出されます。', 'https://github.com/golang-migrate/migrate', 'unpublished', false),
  (175, 'セクション60: Go embed & golang-migrate', 'up.sql と down.sql の命名規則', 'golang-migrate のファイル命名規則として正しいものはどれですか？', 'migrations/
  001_create_tables.up.sql
  001_create_tables.down.sql
  002_seed_quizzes.up.sql
  002_seed_quizzes.down.sql', '["{version}_{description}.{direction}.sql（バージョンは連番、direction は up または down）", "{description}_{version}.sql（方向はファイル内のコメントで指定）", "{version}.sql と {version}_rollback.sql のペア", "任意のファイル名でよく、ファイル内のコメントで方向を指定"]'::jsonb, 0, 'golang-migrate の標準命名規則は `{version}_{description}.{direction}.sql` です。`version` は数値の連番（`001`, `002`...）、`direction` は `up`（適用）または `down`（ロールバック）です。バージョン番号の順序でマイグレーションが実行されます。', 'https://pkg.go.dev/embed', 'unpublished', false),
  (176, 'セクション61: Go 環境変数 & サーバー構造体', 'getEnv のフォールバックパターン', '以下の `getEnv` 関数で環境変数が空文字列 `""` の場合、`fallback` が返されますか？', 'func getEnv(key, fallback string) string {
    if value := os.Getenv(key); value != "" {
        return value
    }
    return fallback
}', '["はい、空文字列は falsy として扱われ fallback が返る", "いいえ、空文字列は設定済みとして扱われ空文字列が返る", "os.Getenv は空文字列を返さない", "パニックが発生する"]'::jsonb, 0, '`value != ""` の条件なので、環境変数が設定されていても値が空文字列の場合は `fallback` が返ります。`os.Getenv` は未設定・空設定どちらも空文字列を返すため、この実装では「未設定」と「空文字列に設定」を区別しません。区別が必要なら `os.LookupEnv` を使います。', 'https://pkg.go.dev/os#LookupEnv', 'unpublished', false),
  (177, 'セクション61: Go 環境変数 & サーバー構造体', 'server 構造体への依存注入', '以下の `server` 構造体に `db`・`adminUser`・`jwtSecret` 等をフィールドとして持たせている設計上の利点はどれですか？', 'type server struct {
    db            *sql.DB
    adminUser     string
    adminPassword string
    jwtSecret     []byte
}

s := &server{
    db:            db,
    adminUser:     getEnv("ADMIN_USER", "admin"),
    adminPassword: getEnv("ADMIN_PASSWORD", "password"),
    jwtSecret:     []byte(getEnv("JWT_SECRET", "dev-only-secret")),
}', '["グローバル変数より読み書きが速いため", "テスト時にモックDBや異なる設定を注入しやすく、グローバル状態を避けられるため", "Goではメソッドに引数を渡せないため", "フィールドは自動的にgoroutine-safeになるため"]'::jsonb, 1, '依存関係を構造体フィールドに持たせる「依存性注入（DI）」パターンです。グローバル変数と違い、テスト時に `server{db: mockDB}` のように差し替えやすく、並行テストでの競合も避けられます。ハンドラがすべてメソッドとして `*server` に紐づくためコンテキストも明確です。', 'https://pkg.go.dev/os#LookupEnv', 'unpublished', false),
  (178, 'セクション61: Go 環境変数 & サーバー構造体', 'jwtSecret を []byte で保持する理由', '`jwtSecret` を `string` ではなく `[]byte` で保持している理由はどれですか？', 'jwtSecret: []byte(getEnv("JWT_SECRET", "dev-only-secret")),

// 使用箇所
return token.SignedString(s.jwtSecret)', '["[]byteの方がメモリ効率が良いため", "jwt.SignedStringが[]byteを要求し、文字列より安全にゼロクリアできるため", "環境変数はバイト列で返されるため", "Goではstring型の比較ができないため"]'::jsonb, 1, '`jwt.Token.SignedString` はHMAC系アルゴリズムで `[]byte` を要求します。また `[]byte` はメモリ上でゼロクリア（`for i := range secret { secret[i] = 0 }`）が可能ですが、Goの `string` はイミュータブルなためクリアできません。シークレット情報を `[]byte` で扱うのはセキュリティ上の慣行です。', 'https://pkg.go.dev/os#LookupEnv', 'unpublished', false),
  (179, 'セクション61: Go 環境変数 & サーバー構造体', 'defer db.Close() のタイミング', '以下のコードで `defer db.Close()` を呼んでいるとき、`db.Close()` が実行されるタイミングはどれですか？', 'db, err := initDB()
if err != nil {
    log.Fatal(err)
}
defer db.Close()

// ... サーバー起動
if err := http.ListenAndServe(":8080", s.routes()); err != nil {
    log.Fatal(err)
}', '["initDB() の直後", "main() 関数が返るとき（サーバーが停止したとき）", "各HTTPリクエスト処理後", "GCが実行されたとき"]'::jsonb, 1, '`defer` は宣言した関数（ここでは `main`）が返るときに実行されます。`http.ListenAndServe` はサーバーが停止するまでブロックするため、通常は `db.Close()` は呼ばれません。サーバーがシャットダウンしたとき（エラーまたはシグナル）に `main` が返り、`defer db.Close()` が実行されます。', 'https://pkg.go.dev/os#LookupEnv', 'unpublished', false),
  (180, 'セクション61: Go 環境変数 & サーバー構造体', 'log.Fatal の動作', '`log.Fatal(err)` と `log.Print(err); os.Exit(1)` の動作の違いはどれですか？', 'db, err := initDB()
if err != nil {
    log.Fatal(err)
}', '["log.Fatal はパニックを起こすが log.Print はログのみ", "実質同じ動作（ログ出力 + os.Exit(1)）。ただし log.Fatal は defer を実行しない", "log.Fatal は終了コード 0 で終了する", "log.Fatal はゴルーチンをすべて待ってから終了する"]'::jsonb, 1, '`log.Fatal` は内部で `log.Print + os.Exit(1)` を呼びます。`os.Exit` は `defer` を実行せずに即終了します。そのため `defer db.Close()` が登録済みでも `log.Fatal` で終了すると実行されません。グレースフルシャットダウンが必要な場合は `os.Exit` を避け、エラーを上位に返す設計が推奨されます。', 'https://pkg.go.dev/os#LookupEnv', 'unpublished', false),
  (181, 'セクション62: Go バリデーション & 文字列処理', 'strings.TrimSpace の活用', '以下の `normalizeQuizPayload` で各フィールドに `strings.TrimSpace` を適用している理由はどれですか？', 'func normalizeQuizPayload(payload *quizPayload) error {
    payload.Section = strings.TrimSpace(payload.Section)
    payload.Title = strings.TrimSpace(payload.Title)
    payload.Question = strings.TrimSpace(payload.Question)
    // ...
    if payload.Section == "" {
        return errors.New("section is required")
    }
}', '["SQLインジェクションを防ぐため", "前後の空白のみのデータが「空」として正しく検出されるようにするため", "全角スペースを除去するため", "文字列を小文字に変換するため"]'::jsonb, 1, '`TrimSpace` なしで `"  "`（空白のみ）を `== ""` で比較すると空と判定されません。バリデーション前に `TrimSpace` を適用することで「空白のみ入力」を「空」として検出します。また `payload` はポインタ渡しなので `TrimSpace` 後の値が呼び出し元にも反映されます。', 'https://pkg.go.dev/strings', 'unpublished', false),
  (182, 'セクション62: Go バリデーション & 文字列処理', 'CorrectAnswerIndex の範囲チェック', '以下の範囲チェックで `payload.CorrectAnswerIndex >= len(payload.Options)` を含める理由はどれですか？', 'if payload.CorrectAnswerIndex < 0 || payload.CorrectAnswerIndex >= len(payload.Options) {
    return errors.New("correctAnswerIndex is out of range")
}', '["Goの配列は1始まりのため", "インデックスは0始まりなのでlen(options)はインデックスとして無効な値のため", "len()が負の値を返すことがあるため", "Options が空の場合のみチェックするため"]'::jsonb, 1, 'Goのスライスインデックスは0始まりなので、有効な範囲は `0` 〜 `len-1` です。`CorrectAnswerIndex == len(options)` は1つ外（out of bounds）になります。`< 0` と `>= len` の両方をチェックすることで配列外アクセスによるパニックを防ぎます。', 'https://pkg.go.dev/strings', 'unpublished', false),
  (183, 'セクション62: Go バリデーション & 文字列処理', 'parseID での strconv.ParseInt', '以下の `parseID` で `strconv.ParseInt(raw, 10, 64)` を使っている理由はどれですか？', 'func parseID(raw string) (int64, error) {
    id, err := strconv.ParseInt(raw, 10, 64)
    if err != nil || id <= 0 {
        return 0, errors.New("invalid quiz id")
    }
    return id, nil
}', '["URLパスパラメータは常に16進数のため", "パスパラメータは文字列なので10進整数として安全にパースし、quiz.ID（int64）型に合わせるため", "int32では値が溢れる可能性があるため、パフォーマンスのためにint64を使う", "strconvの方がfmtパッケージより速いため"]'::jsonb, 1, '`r.PathValue` は常に文字列を返すため数値変換が必要です。`ParseInt(raw, 10, 64)` の第2引数 `10` は10進数、第3引数 `64` はビットサイズ（`int64`）を指定します。`quiz.ID` が `int64` 型なので合わせています。また `id <= 0` チェックで負数や0の無効なIDを弾きます。', 'https://pkg.go.dev/strconv#ParseInt', 'unpublished', false),
  (184, 'セクション62: Go バリデーション & 文字列処理', 'options の空スライス初期化', '以下の `handleListQuizzes` で `make([]quiz, 0)` を使う理由はどれですか？', 'items := make([]quiz, 0)
for rows.Next() {
    item, err := scanQuiz(rows)
    // ...
    items = append(items, item)
}
writeJSON(w, http.StatusOK, items)', '["var items []quiz と全く同じため、どちらでもよい", "var で宣言するとnil スライスになりJSONで null になるが、make([]quiz, 0)は空配列 [] になるため", "make の方がappendのパフォーマンスが良いため", "nil スライスへの append はパニックになるため"]'::jsonb, 1, '`var items []quiz` は `nil` スライスを作るため `json.Marshal` すると `null` になります。`make([]quiz, 0)` は空（長さ0）の非nilスライスを作るため `[]` になります。クイズが0件のとき `null` ではなく `[]` を返す方がAPIクライアントにとって扱いやすいため、`make` を使っています。', 'https://pkg.go.dev/strings', 'unpublished', false),
  (185, 'セクション62: Go バリデーション & 文字列処理', 'code フィールドの nil 判定', '以下のコードで `payload.Code == ""` のとき `codeValue = nil` にしている理由はどれですか？', 'var codeValue any
if payload.Code == "" {
    codeValue = nil
} else {
    codeValue = payload.Code
}

item, err := scanQuiz(s.db.QueryRow(`
    INSERT INTO quizzes (..., code, ...) VALUES (..., $4, ...)
`, ..., codeValue, ...))', '["空文字列のSQLパラメータはエラーになるため", "DBスキーマでcodeはNULL許容（TEXT, not NOT NULL）なので、コードなしのクイズはNULLを格納するため", "PostgreSQLでは空文字列とNULLは同じ扱いのため", "nil を渡すとPostgreSQLが自動でDEFAULT値を使うため"]'::jsonb, 1, 'DBスキーマで `code TEXT`（`NOT NULL` なし）のため NULL が許容されます。コードブロックがないクイズで空文字列 `""` を格納するよりも `NULL` を格納する方が「値なし」の意味が明確です。Go の `nil` を `any` 型で渡すと `database/sql` が SQL の `NULL` に変換します。', 'https://pkg.go.dev/strings', 'unpublished', false),
  (186, 'セクション62: Go バリデーション & 文字列処理', 'RowsAffected による削除確認', '以下の削除処理で `rowsAffected == 0` のとき 404 を返している理由はどれですか？', 'result, err := s.db.Exec(`DELETE FROM quizzes WHERE id = $1`, quizID)
rowsAffected, err := result.RowsAffected()
if rowsAffected == 0 {
    writeError(w, http.StatusNotFound, "quiz not found")
    return
}
writeJSON(w, http.StatusNoContent, nil)', '["DELETEは常に少なくとも1行削除するため0は異常", "存在しないIDへのDELETEはエラーを返さず0行削除するため、404で存在しないことを伝える", "rowsAffectedが0の場合DBエラーが発生するため", "PostgreSQLはrowsAffectedを返さないため"]'::jsonb, 1, '`DELETE WHERE id = $1` は条件に一致する行がなくてもエラーにならず、`RowsAffected()` が `0` を返します。クライアントに「そのIDは存在しなかった」と伝えるため `404 Not Found` を返します。削除成功時は `204 No Content`（ボディなし）がRESTの慣行です。', 'https://pkg.go.dev/strings', 'unpublished', false),
  (187, 'セクション63: SPA と SEO', 'GoogleボットのJSレンダリング問題', 'Vite + React で構築したSPAをそのまま公開した場合、SEO上の問題として最も正確なものはどれですか？', '// SPAの初期HTML（Vite build 後）
<!DOCTYPE html>
<html>
  <head><title>Quiz App</title></head>
  <body>
    <div id="root"></div>
    <script type="module" src="/assets/index-abc123.js"></script>
  </body>
</html>', '["GoogleボットはJSを一切実行できないため、全コンテンツがインデックスされない", "GoogleボットはJSを実行できるが、クロールキューに入るまで遅延があり、インデックスが遅れたりコンテンツが見逃される可能性がある", "SPAはHTTPSでないとインデックスされない", "Viteのビルド出力はGoogleに対応していない"]'::jsonb, 1, 'GoogleボットはChromiumベースでJSを実行できますが、「第2波クロール」と呼ばれる遅延レンダリングキューに入るため、インデックス反映が数日〜数週間遅れることがあります。また動的に生成されるコンテンツが正しく解釈されない場合もあります。HTMLに最初からコンテンツが含まれているSSR/SSGと比べてSEO上不利です。', 'https://developers.google.com/search/docs/crawling-indexing/javascript/javascript-seo-basics', 'unpublished', false),
  (188, 'セクション63: SPA と SEO', 'SSR と SSG の違い', 'Next.js における SSR（Server-Side Rendering）と SSG（Static Site Generation）の違いとして正しいものはどれですか？', '// SSR: リクエストのたびにサーバーでHTMLを生成
export async function getServerSideProps() {
  const data = await fetchQuizzes()
  return { props: { data } }
}

// SSG: ビルド時にHTMLを生成
export async function getStaticProps() {
  const data = await fetchQuizzes()
  return { props: { data } }
}', '["SSRはビルド時、SSGはリクエスト時にHTMLを生成する", "SSRはリクエスト時にサーバーでHTMLを生成し、SSGはビルド時にHTMLを生成する", "SSRとSSGは同じもので、フレームワークによって名称が異なる", "SSGはJavaScriptを使わない静的サイトのことで、Reactは使えない"]'::jsonb, 1, 'SSRはリクエストのたびにサーバーがHTMLを生成して返すため、常に最新データを返せますがサーバー負荷がかかります。SSGはビルド時に全ページのHTMLを生成するため高速・低コストですが、データ更新にはリビルドが必要です。クイズ一覧のような更新頻度の低いコンテンツはSSGが適しています。', 'https://developers.google.com/search/docs/crawling-indexing/javascript/javascript-seo-basics', 'unpublished', false),
  (189, 'セクション63: SPA と SEO', 'Core Web Vitals とSEO', 'Google検索のランキング要因になっている Core Web Vitals の3指標として正しい組み合わせはどれですか？', '// Lighthouseで計測できる主要指標
// LCP: ページ内の最大コンテンツが表示されるまでの時間
// CLS: レイアウトのズレ（累積レイアウトシフト）
// INP: ユーザー操作に対する応答性（旧FID）', '["FCP・TTI・TBT", "LCP・CLS・INP", "TTFB・FCP・TTI", "SEO・Performance・Accessibility"]'::jsonb, 1, 'Core Web Vitals は LCP（Largest Contentful Paint）・CLS（Cumulative Layout Shift）・INP（Interaction to Next Paint、2024年3月にFIDから移行）の3指標です。Googleは2021年よりこれらを検索ランキングの要因に組み込んでいます。SPAはJSバンドルが大きくなりがちなためLCPが悪化しやすい点に注意が必要です。', 'https://web.dev/articles/vitals', 'unpublished', false),
  (190, 'セクション63: SPA と SEO', 'React SPA から Next.js への移行の主なメリット', 'Vite + React SPA を Next.js に移行する最大のSEO上のメリットはどれですか？', '// Before: SPAの初期HTML
<div id="root"></div> // コンテンツなし

// After: Next.js SSGの初期HTML
<h1>Reactの基礎</h1>
<p>以下の問題に答えてください...</p>
// コンテンツがHTMLに含まれる', '["TypeScriptが使えるようになる", "初期HTMLにコンテンツが含まれるためGoogleボットがJSレンダリングを待たずにインデックスできる", "CSSのバンドルサイズが小さくなる", "APIルートが使えるためバックエンドが不要になる"]'::jsonb, 1, 'Next.js のSSR/SSGでは初期レスポンスのHTMLにすでにコンテンツが含まれます。Googleボットはこれを即座にパースしてインデックスできるため、SPAの「遅延レンダリング問題」が解消されます。クイズタイトル・問題文・解説がHTMLに含まれることで、検索結果にコンテンツが反映されやすくなります。', 'https://nextjs.org/docs/app/getting-started', 'unpublished', false),
  (191, 'セクション63: SPA と SEO', '動的メタタグと og:title', 'クイズ詳細ページ（`/quizzes/123`）でSNSシェア時に正しいタイトルを表示するために必要な対応はどれですか？', '// SPAでは全ページ共通のmetaになってしまう
<meta property="og:title" content="Quiz App" />

// Next.jsではページごとに動的に設定できる
export const metadata = {
  title: quiz.title,
  openGraph: { title: quiz.title }
}', '["JavaScriptでdocument.titleを書き換えれば十分", "SNSクローラーはJSを実行しないため、SSR/SSGでHTMLにog:titleを埋め込む必要がある", "og:titleはGoogleのみが参照するためSEOには影響しない", "React HelmetでSPAでも同じ効果が得られる"]'::jsonb, 1, 'Twitter・Facebook等のSNSクローラーはJavaScriptを実行せず、HTMLのみを解析します。SPAでJSから `og:title` を動的に設定しても、クローラーには初期HTMLの値しか見えません。Next.jsのSSR/SSGでは各ページのHTMLに正しい `og:title` が埋め込まれるため、シェア時に適切なプレビューが表示されます。', 'https://developers.google.com/search/docs/crawling-indexing/javascript/javascript-seo-basics', 'unpublished', false),
  (192, 'セクション63: SPA と SEO', 'sitemap.xml の役割', 'クイズアプリに `sitemap.xml` を設置する目的として正しいものはどれですか？', '<!-- sitemap.xml の例 -->
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url>
    <loc>https://example.com/quizzes/1</loc>
    <lastmod>2026-04-07</lastmod>
  </url>
  <url>
    <loc>https://example.com/quizzes/2</loc>
    <lastmod>2026-04-07</lastmod>
  </url>
</urlset>', '["サイトのデザインをGoogleに伝えるため", "GoogleボットにクロールすべきURLを明示的に伝え、インデックス漏れを防ぐため", "sitemap.xml があるとCore Web Vitalsのスコアが上がるため", "ユーザーへのナビゲーションメニューを提供するため"]'::jsonb, 1, '`sitemap.xml` はGoogleボットにサイト内の全URLを伝えるファイルです。特に内部リンクが少ないページや新しいコンテンツをGoogleに発見させる手助けになります。クイズが100問以上ある場合、全問題ページのURLをsitemapに列挙することで、クロール漏れを防げます。Next.jsでは `next-sitemap` パッケージで自動生成できます。', 'https://developers.google.com/search/docs/crawling-indexing/sitemaps/overview', 'unpublished', false),
  (193, 'セクション63: SPA と SEO', '構造化データ（Quiz スキーマ）', 'クイズアプリで以下のような構造化データを設置する目的はどれですか？', '{
  "@context": "https://schema.org",
  "@type": "Quiz",
  "name": "useEffect 依存配列と関数参照",
  "hasPart": [{
    "@type": "Question",
    "text": "以下のコードについて、最も正しい説明はどれですか？",
    "acceptedAnswer": {
      "@type": "Answer",
      "text": "useCallbackでfetchUserを安定化し..."
    }
  }]
}', '["Googleがページをブロックしないようにするため", "Googleがコンテンツの意味を理解しやすくなり、リッチリザルト（検索結果での特別な表示）が得られる可能性があるため", "ページの読み込み速度を向上させるため", "構造化データはアクセシビリティのためのものでSEOとは無関係"]'::jsonb, 1, '構造化データ（JSON-LD形式のschema.org）を設置するとGoogleがコンテンツの種類・意味を機械的に理解できます。QuizやQ&Aスキーマを使うと検索結果ページにリッチリザルト（問題文や回答が直接表示）が表示される可能性があり、クリック率の向上が期待できます。', 'https://developers.google.com/search/docs/appearance/structured-data/intro-structured-data', 'unpublished', false),
  (194, 'セクション64: CSR を示すコード読解', 'createRoot はCSRの証拠', '以下の `main.tsx` のコードがCSR（クライアントサイドレンダリング）であることを示す根拠はどれですか？', '// main.tsx
const rootElement = document.getElementById(''root'')
if (!rootElement) throw new Error(''Root element #root not found'')

createRoot(rootElement).render(
  <StrictMode>
    <App />
  </StrictMode>,
)', '["StrictMode を使っているため", "document.getElementById と createRoot によりブラウザのDOMにReactツリーをマウントしており、サーバーではなくブラウザ上でレンダリングが行われるため", "StrictModeはサーバーでは動作しないため", "App コンポーネントをラップしているため"]'::jsonb, 1, '`document.getElementById` は `document` オブジェクトを参照しており、これはブラウザ環境のみに存在します。`createRoot` でブラウザのDOM要素にReactをマウントすることがCSRの本質です。SSRでは `hydrateRoot` を使い、サーバーで生成済みのHTMLにイベントを付与します。', 'https://react.dev/reference/react-dom/client/createRoot', 'unpublished', false),
  (195, 'セクション64: CSR を示すコード読解', 'BrowserRouter はCSRのルーター', '以下の `App.tsx` で `BrowserRouter` を使っていることがCSRを示す理由はどれですか？', '// App.tsx
import { BrowserRouter, Navigate, Route, Routes } from ''react-router-dom''

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/quizzes" element={<QuizListPage />} />
        {/* ... */}
      </Routes>
    </BrowserRouter>
  )
}', '["BrowserRouter は React Router v6 以降でしか使えないため", "BrowserRouter は window.history API を使ってブラウザ上でルーティングを管理するため、サーバーではなくブラウザがページ遷移を制御するCSRの仕組み", "Routes コンポーネントはサーバーで動作しないため", "BrowserRouter を使うと自動的にSSRが無効になるため"]'::jsonb, 1, '`BrowserRouter` は `window.history.pushState` を使ってURLを書き換え、ブラウザ側でルーティングを管理します。Next.jsではサーバーが各URLに対応するHTMLを返しますが、SPAではどのURLへのアクセスも同じ `index.html` を返し、その後JavaScriptがURLに応じたコンポーネントを表示します。', 'https://react.dev/reference/react-dom/client/createRoot', 'unpublished', false),
  (196, 'セクション64: CSR を示すコード読解', 'useEffect + fetch はCSRのデータ取得', '以下の `ViewCounter.tsx` のデータ取得パターンがCSRであることを示す根拠はどれですか？', '// ViewCounter.tsx
useEffect(() => {
  const fetchViews = async () => {
    const res = await fetch(API_URL)
    const data = await res.json()
    setCount(data.count)
  }
  fetchViews()
}, [])', '["useEffect はサーバーで実行されないため、データ取得がブラウザ上でマウント後に行われる", "fetch はブラウザAPIのため", "async/await はサーバーで使えないため", "setCount はブラウザのみで動作するため"]'::jsonb, 0, '`useEffect` はコンポーネントのマウント後（ブラウザ上）にのみ実行されます。サーバーサイドでは実行されません。このため初期HTMLには `count` の値が含まれず、ブラウザでJSが実行されて初めてデータが表示されます。SSGなら `getStaticProps`、SSRなら `getServerSideProps` でビルド時・リクエスト時にデータを取得してHTMLに埋め込みます。', 'https://react.dev/reference/react-dom/client/createRoot', 'unpublished', false),
  (197, 'セクション64: CSR を示すコード読解', 'window.localStorage はブラウザ専用API', '以下の `session.ts` のコードがCSR環境前提である証拠はどれですか？', '// auth/session.ts
const TOKEN_STORAGE_KEY = ''quiz-admin-token''

export function getAuthToken(): string | null {
  return window.localStorage.getItem(TOKEN_STORAGE_KEY)
}

export function setAuthToken(token: string): void {
  window.localStorage.setItem(TOKEN_STORAGE_KEY, token)
}', '["localStorage は文字列のみ保存できるため", "window.localStorage はブラウザ専用APIであり、Node.js（SSR）環境では window が存在しないためエラーになる", "TOKEN_STORAGE_KEY を定数にしているため", "getAuthToken が null を返す可能性があるため"]'::jsonb, 1, '`window.localStorage` はブラウザ専用のWeb APIです。Next.jsのSSR環境（Node.js）では `window` は未定義のため、このコードをサーバーサイドで実行すると `ReferenceError: window is not defined` が発生します。Next.jsに移行する場合、`typeof window !== ''undefined''` のガードや `useEffect` 内への移動が必要です。', 'https://react.dev/reference/react-dom/client/createRoot', 'unpublished', false),
  (198, 'セクション64: CSR を示すコード読解', 'isLoading state はCSRのUXパターン', '以下の `QuizListPage.tsx` で `isLoading` state が必要になる根本的な理由はどれですか？', '// QuizListPage.tsx
const [quizzes, setQuizzes] = useState<Quiz[]>([])
const [isLoading, setIsLoading] = useState(true)

// ...
{isLoading ? (
  <div>読み込み中...</div>
) : (
  <table>...</table>
)}', '["useState の初期値に空配列を使っているため", "CSRではページ表示後にブラウザからAPIを叩くため、データ取得中の空白期間が生まれUXのためローディング表示が必要になる", "React の仕様でテーブルは非同期でレンダリングされるため", "APIが遅いため"]'::jsonb, 1, 'CSRではブラウザがJSを実行してからAPIリクエストを送るため、必ずデータ取得前の「空の状態」が存在します。SSGであればビルド時にデータ取得済みのHTMLが返るため、初期表示時にローディング状態が不要になります。`isLoading` の存在自体がCSRのデータ取得パターンの証拠です。', 'https://react.dev/reference/react-dom/client/createRoot', 'unpublished', false),
  (199, 'セクション64: CSR を示すコード読解', 'ProtectedRoute はクライアント側認証', '以下の `ProtectedRoute` コンポーネントがCSR前提である理由はどれですか？', '// components/ProtectedRoute.tsx
import { Navigate } from ''react-router-dom''
import { getAuthToken } from ''../auth/session''

export default function ProtectedRoute({ children }) {
  if (!getAuthToken()) {
    return <Navigate to="/login" replace />
  }
  return children
}', '["Navigate コンポーネントを使っているため", "getAuthToken() が window.localStorage を参照しており、認証チェックがブラウザ上のJS実行時に行われるため、サーバーでは保護できない", "children props を受け取っているため", "replace オプションを使っているため"]'::jsonb, 1, '`getAuthToken()` は `window.localStorage` を参照するCSRの実装です。SSRでは初期HTMLレスポンス時点でサーバー側が認証状態を確認してリダイレクトできますが、この実装ではブラウザでJSが実行されるまで保護ページのHTMLが一瞬表示される可能性（フラッシュ）があります。Next.jsではMiddlewareやサーバーコンポーネントでサーバー側認証が可能です。', 'https://react.dev/reference/react-dom/client/createRoot', 'unpublished', false),
  (200, 'セクション64: CSR を示すコード読解', 'Next.js移行時の window 対応', 'CSRの `session.ts` を Next.js に移行する際、`window.localStorage` が原因でSSRエラーになる場合の正しい対処法はどれですか？', '// 現在のコード（SSR環境でエラー）
export function getAuthToken(): string | null {
  return window.localStorage.getItem(''quiz-admin-token'')
}

// Next.js 移行後の対応例
export function getAuthToken(): string | null {
  if (typeof window === ''undefined'') return null
  return window.localStorage.getItem(''quiz-admin-token'')
}', '["window を global に置き換える", "typeof window === ''undefined'' でサーバー実行時を判定してnullを返す", "localStorage を sessionStorage に置き換える", "useEffect 内でのみ localStorage を使い、それ以外では Cookie を使う"]'::jsonb, 1, '`typeof window === ''undefined''` はサーバーサイド（Node.js）では `true` になります。このガードを追加することでSSRビルドエラーを回避できます。より本格的な対応としては、Cookie-based認証に切り替えてサーバーサイドでもトークンを読めるようにする方法が推奨されます（Next.js の `cookies()` API等）。', 'https://react.dev/reference/react-dom/client/createRoot', 'unpublished', false),
  (201, 'セクション65: React Router v7 移行', 'Viteプラグインの変更', '現在のプロジェクトを React Router v7 フレームワークモードに移行するとき `vite.config.ts` の変更として正しいものはどれですか？', '// 移行前
import react from ''@vitejs/plugin-react''
import { defineConfig } from ''vite''

export default defineConfig({
  plugins: [react()]
})

// 移行後
import { reactRouter } from ''@react-router/dev/vite''
import { defineConfig } from ''vite''

export default defineConfig({
  plugins: [reactRouter()]
})', '["@vitejs/plugin-react を残したまま reactRouter() を追加する", "@vitejs/plugin-react を削除し reactRouter() に置き換える", "vite.config.ts は変更不要で package.json のみ変更する", "reactRouter() は vite.config.ts ではなく react-router.config.ts に書く"]'::jsonb, 1, '`reactRouter()` は `@react-router/dev/vite` が提供するViteプラグインで、`@vitejs/plugin-react` の機能を内包しています。両方を同時に使うと競合するため、`@vitejs/plugin-react` を削除して置き換えます。合わせて `npm install -D @react-router/dev` と `npm install @react-router/node` が必要です。', 'https://reactrouter.com/start/framework/installation', 'unpublished', false),
  (202, 'セクション65: React Router v7 移行', 'createRoot から hydrateRoot への変更', 'React Router v7 フレームワークモードに移行するとき `main.tsx` の変更として正しいものはどれですか？', '// 移行前 (main.tsx)
import { createRoot } from ''react-dom/client''
createRoot(document.getElementById(''root'')!).render(
  <StrictMode><App /></StrictMode>
)

// 移行後 (entry.client.tsx)
import { hydrateRoot } from ''react-dom/client''
import { HydratedRouter } from ''react-router/dom''

hydrateRoot(
  document,
  <StrictMode><HydratedRouter /></StrictMode>
)', '["createRoot のまま App を HydratedRouter に変えるだけでよい", "createRoot を hydrateRoot に変え、App を HydratedRouter に置き換え、マウント対象を document 全体にする", "main.tsx は削除してよく、entry.client.tsx は自動生成される", "hydrateRoot は SSR が有効なときのみ必要で、SPA モードなら createRoot のまま"]'::jsonb, 1, '`hydrateRoot` はサーバーで生成済みのHTMLにReactのイベントを付与（ハイドレーション）します。`createRoot` は空のDOMにゼロからレンダリングするCSRの方式です。マウント対象が `document.getElementById(''root'')` から `document` 全体になる点も重要な変更です。`<HydratedRouter>` がルーティングを管理するため `<App>` は不要になります。', 'https://reactrouter.com/start/framework/installation', 'unpublished', false),
  (203, 'セクション65: React Router v7 移行', 'BrowserRouter から routes.ts への移行', '現在の `App.tsx` のルート定義を React Router v7 の `routes.ts` に移行したとき、正しい記述はどれですか？', '// 移行前 App.tsx
<Routes>
  <Route path="/quizzes" element={<QuizListPage />} />
  <Route path="/quizzes/new" element={<QuizFormPage mode="create" />} />
  <Route path="/quizzes/:id/edit" element={<QuizFormPage mode="edit" />} />
  <Route path="/login" element={<LoginPage />} />
</Routes>

// 移行後 routes.ts
import { type RouteConfig, route } from ''@react-router/dev/routes''

export default [
  route(''/quizzes'', ''./pages/QuizListPage.tsx''),
  route(''/quizzes/new'', ''./pages/QuizFormPage.tsx''),
  route(''/quizzes/:id/edit'', ''./pages/QuizFormPage.tsx''),
  route(''/login'', ''./pages/LoginPage.tsx''),
] satisfies RouteConfig', '["routes.ts では element プロパティで JSX を直接渡す", "routes.ts ではファイルパスの文字列でルートモジュールを指定し、コンポーネントは各ファイルの default export になる", "routes.ts は JSON 形式で記述する", "BrowserRouter を残したまま routes.ts を追加できる"]'::jsonb, 1, 'React Router v7 の `routes.ts` ではJSXではなくファイルパスの文字列でルートを定義します。各ページファイルが「ルートモジュール」となり、`default export` がコンポーネント、`loader` がデータ取得、`action` がフォーム送信処理を担います。自動コード分割もこの構造によって実現されます。', 'https://reactrouter.com/start/framework/installation', 'unpublished', false),
  (204, 'セクション65: React Router v7 移行', 'loader によるSSRデータ取得', '現在の `QuizListPage.tsx` の `useEffect` + `fetch` によるデータ取得を React Router v7 の `loader` に移行したとき、SEO上の利点はどれですか？', '// 移行前: CSR（useEffect内でデータ取得）
useEffect(() => {
  void loadQuizzes()
}, [loadQuizzes])

// 移行後: SSR（loaderでサーバー取得）
export async function loader() {
  const quizzes = await listQuizzes()
  return { quizzes }
}

export default function QuizListPage({ loaderData }) {
  const { quizzes } = loaderData
  // isLoading state が不要になる
  return <table>...</table>
}', '["loader は並列実行されるためパフォーマンスが上がる", "初期HTMLにクイズデータが含まれるためGoogleボットがJSを待たずにインデックスでき、isLoading状態も不要になる", "loader はキャッシュが自動で効くためAPIリクエストが減る", "loader はTypeScriptの型推論が強化されるためバグが減る"]'::jsonb, 1, '`loader` はサーバーサイドで実行されるため、レスポンスのHTMLにクイズデータが含まれます。Googleボットはこれを即座にインデックスできます。また `useEffect` でのデータ取得がなくなるため `isLoading` state も不要になり、コードがシンプルになります。', 'https://reactrouter.com/start/framework/installation', 'unpublished', false),
  (205, 'セクション65: React Router v7 移行', 'react-router.config.ts の ssr オプション', '以下の `react-router.config.ts` で `ssr: false` と `ssr: true` の違いはどれですか？', '// SPA モード（移行初期段階）
export default {
  ssr: false,
} satisfies Config

// SSR モード（本格対応）
export default {
  ssr: true,
  async prerender() {
    return [''/'', ''/quizzes'']
  },
} satisfies Config', '["ssr: false はビルドが速くなるだけで動作は同じ", "ssr: false はCSRのまま（既存SPAと同等）で移行の足がかりになり、ssr: true にするとSSR/SSGが有効になる", "ssr: true にするとReact Server Componentsが使えるようになる", "ssr: false は開発環境のみ有効でプロダクションでは自動でtrueになる"]'::jsonb, 1, '`ssr: false` はSPAモードで、フレームワーク機能（routes.ts、loader等）は使えますがサーバーレンダリングはしません。既存SPAからの段階的移行の足がかりとして使えます。`ssr: true` にするとサーバーレンダリングが有効になります。`prerender` で特定URLを静的HTML生成（SSG相当）することもできます。', 'https://reactrouter.com/start/framework/installation', 'unpublished', false),
  (206, 'セクション65: React Router v7 移行', 'root.tsx の役割', 'React Router v7 の `root.tsx` に含まれる `<Scripts />` コンポーネントの役割はどれですか？', '// src/root.tsx
import { Links, Meta, Outlet, Scripts, ScrollRestoration } from ''react-router''

export function Layout({ children }) {
  return (
    <html lang="ja">
      <head>
        <Meta />
        <Links />
      </head>
      <body>
        {children}
        <ScrollRestoration />
        <Scripts />
      </body>
    </html>
  )
}', '["外部CDNのスクリプトを読み込む", "Viteがバンドルしたクライアント側JavaScriptをHTMLに挿入し、ハイドレーションを可能にする", "Google Analyticsを自動挿入する", "サーバーサイドのスクリプトを実行する"]'::jsonb, 1, '`<Scripts />` はViteがビルドしたJSバンドルを `<script>` タグとして自動挿入するコンポーネントです。これがないとブラウザにJSが読み込まれずインタラクティブなUIが動きません。`<Meta />` はルートの `meta` エクスポート、`<Links />` はCSSリンク、`<ScrollRestoration />` はナビゲーション時のスクロール位置復元を担います。', 'https://reactrouter.com/start/framework/installation', 'unpublished', false),
  (207, 'セクション65: React Router v7 移行', 'catchall.tsx による段階的移行', '移行初期に `routes.ts` で `route(''*?'', ''catchall.tsx'')` を定義し、`catchall.tsx` で既存の `<App>` を返す理由はどれですか？', '// routes.ts（移行初期）
export default [
  route(''*?'', ''catchall.tsx''),
] satisfies RouteConfig

// catchall.tsx
import App from ''./App''
export default function Component() {
  return <App />
}', '["App.tsx を削除するための準備として使う", "既存の Routes/BrowserRouter をそのまま動かしながらフレームワークモードに移行し、その後ルートを1つずつ routes.ts に移行できる", "catchall は 404 ページ専用の規約のため", "全 URL を App にフォールバックすることでSSRが自動有効になる"]'::jsonb, 1, 'catchall（`*?`）で全URLを既存の `<App>` に委譲することで、フレームワークモードへの移行初日から既存機能を壊さず動かせます。その後 `routes.ts` にルートを1つずつ追加し、`App.tsx` の対応する `<Route>` を削除していく段階的移行が可能です。ドキュメントでも「最初の数ルートが最も大変」と記載されています。', 'https://reactrouter.com/start/framework/installation', 'unpublished', false),
  (208, 'セクション66: SWR & コード分割', 'SWR のキャッシュキー', '以下の `useQuizzes` カスタムフックで `useSWR` の第1引数 `''/api/admin/quizzes''` が果たす役割はどれですか？', 'export function useQuizzes() {
  const { data, error, isLoading, mutate } = useSWR<Quiz[]>(
    ''/api/admin/quizzes'',
    () => listQuizzes(),
    {
      revalidateOnFocus: false,
      revalidateOnReconnect: true,
    },
  )
  return { quizzes: data ?? [], errorMessage: error instanceof Error ? error.message : null, isLoading, mutate }
}', '["fetch に渡す URL", "SWR がデータをキャッシュ・重複排除するためのキーで、同じキーを使うコンポーネントはキャッシュを共有する", "ローカルストレージの保存キー", "API のエンドポイントを自動検出するための型情報"]'::jsonb, 1, 'SWR の第1引数はキャッシュキーです。同じキーを持つ `useSWR` は複数のコンポーネントから呼ばれてもリクエストが1回に重複排除（dedup）されます。第2引数の fetcher 関数が実際のデータ取得を行うため、キーはURLである必要はありませんが、慣習的にAPIパスを使います。', 'https://swr.vercel.app/docs/getting-started', 'unpublished', false),
  (209, 'セクション66: SWR & コード分割', 'revalidateOnFocus: false の効果', '`revalidateOnFocus: false` を指定する理由として最も適切なものはどれですか？', 'useSWR<Quiz[]>(
  ''/api/admin/quizzes'',
  () => listQuizzes(),
  {
    revalidateOnFocus: false,
    revalidateOnReconnect: true,
  },
)', '["フォーカスイベントが発生するたびにフェッチすると入力中のフォームがリセットされるため", "タブ切り替えのたびに不要なAPIリクエストが発生し、管理画面では頻繁な再取得が不要なため", "revalidateOnFocus はモバイルブラウザで動作しないため", "false にしないと SWR のキャッシュが無効になるため"]'::jsonb, 1, 'SWR はデフォルトでブラウザタブにフォーカスが戻るたびにデータを再取得します。管理画面のクイズ一覧ではタブ切り替えのたびにAPIを叩く必要はありません。`revalidateOnReconnect: true` はネットワーク復帰時の再取得で、オフライン→オンラインの遷移では再取得が有用です。', 'https://swr.vercel.app/docs/getting-started', 'unpublished', false),
  (210, 'セクション66: SWR & コード分割', 'mutate による楽観的更新', '以下の削除処理で `mutate(filteredData, false)` の第2引数 `false` の意味はどれですか？', 'await deleteQuiz(quizToDelete.id)
await mutate(
  quizzes.filter((quiz) => quiz.id !== quizToDelete.id),
  false
)', '["エラーハンドリングを無効にする", "キャッシュを更新した後にサーバーへの再検証（再フェッチ）をスキップする", "mutate の戻り値を Promise ではなく boolean にする", "削除操作をキャンセルする"]'::jsonb, 1, '`mutate(data, false)` の第2引数は `revalidate` オプションです。`false` にするとローカルキャッシュを更新するだけでサーバーへの再フェッチを行いません。すでに `deleteQuiz` でサーバーの削除は完了しているため、改めてリスト全体を取得し直す必要がなく、UIが即座に反映されます。', 'https://swr.vercel.app/docs/getting-started', 'unpublished', false),
  (211, 'セクション66: SWR & コード分割', 'SWR 導入で削除されたコード', 'SWR 導入前の `QuizListPage` にあった以下のコードのうち、SWR 導入後に不要になったのはどれですか？', 'const [quizzes, setQuizzes] = useState<Quiz[]>([])
const [isLoading, setIsLoading] = useState(true)
const [errorMessage, setErrorMessage] = useState<string | null>(null)

const loadQuizzes = useCallback(async () => {
  setIsLoading(true)
  setErrorMessage(null)
  try {
    const items = await listQuizzes()
    setQuizzes(items)
  } catch (error) {
    setErrorMessage(getErrorMessage(error))
  } finally {
    setIsLoading(false)
  }
}, [navigate])

useEffect(() => {
  void loadQuizzes()
}, [loadQuizzes])', '["useState の deleteErrorMessage のみ", "quizzes・isLoading・errorMessage の3つの useState と、loadQuizzes の useCallback と、useEffect のすべて", "useEffect のみ", "useState のみ"]'::jsonb, 1, 'SWR は `data`（quizzes）・`isLoading`・`error` を内部で管理し、マウント時の自動フェッチも行います。そのため `useState` x3 + `useCallback` + `useEffect` の計5つのフックが `useQuizzes()` の1行に置き換わりました。削除関連の `deleteErrorMessage`・`quizToDelete`・`isDeleting` は SWR とは無関係なため残ります。', 'https://swr.vercel.app/docs/getting-started', 'unpublished', false),
  (212, 'セクション66: SWR & コード分割', 'React.lazy によるコード分割', '以下のコードで `lazy(() => import(''./pages/QuizListPage''))` を使ったとき、ビルド出力にどのような変化が起きますか？', '// 変更前: 静的インポート
import QuizListPage from ''./pages/QuizListPage''
import QuizFormPage from ''./pages/QuizFormPage''

// 変更後: 動的インポート
const QuizListPage = lazy(() => import(''./pages/QuizListPage''))
const QuizFormPage = lazy(() => import(''./pages/QuizFormPage''))', '["ビルド出力に変化はない", "QuizListPage と QuizFormPage が別チャンクに分離され、該当ページへの遷移時に初めてダウンロードされる", "全ページが1つのチャンクにまとめられてバンドルサイズが増える", "lazy を使うと開発時のHMRが無効になる"]'::jsonb, 1, '`React.lazy` + 動的 `import()` により Vite がページ単位の別チャンクを生成します。実際のビルド出力では `QuizListPage-xxx.js`（261KB）と `QuizFormPage-xxx.js`（8KB）が分離され、初期バンドル `index-xxx.js`（304KB）には含まれません。ログインページを開いたときにクイズ関連のJSをダウンロードしなくて済み、初期表示が高速化します。', 'https://swr.vercel.app/docs/getting-started', 'unpublished', false),
  (213, 'セクション66: SWR & コード分割', 'Suspense の fallback', '以下の `Suspense` の `fallback` が表示されるのはどのタイミングですか？', '<Suspense fallback={<div>読み込み中...</div>}>
  <Routes>
    <Route path="/quizzes" element={<QuizListPage />} />
  </Routes>
</Suspense>', '["QuizListPage が API からデータを取得している間", "React.lazy で分割されたチャンク（QuizListPage の JS ファイル）がダウンロード完了するまで", "React の初回レンダリング中に常に表示される", "エラーが発生したときのフォールバック表示"]'::jsonb, 1, '`Suspense` は `React.lazy` で分割されたコンポーネントのJSチャンクがネットワークからダウンロードされるまでの間に `fallback` を表示します。一度ダウンロードされればキャッシュされるため、2回目以降は fallback は表示されません。APIのデータ取得待ちは SWR の `isLoading` で別途ハンドリングします。', 'https://swr.vercel.app/docs/getting-started', 'unpublished', false),
  (214, 'セクション66: SWR & コード分割', 'data ?? [] の nullish coalescing', '以下のコードで `data ?? []` を使っている理由はどれですか？', 'const { data, error, isLoading, mutate } = useSWR<Quiz[]>(
  ''/api/admin/quizzes'',
  () => listQuizzes(),
)

return {
  quizzes: data ?? [],
}', '["data が空配列 [] のとき [] に変換するため", "data が undefined（初回フェッチ前）のとき空配列を返すことで、呼び出し側で undefined チェックを不要にするため", "data が null のとき SWR がエラーを投げるのを防ぐため", "TypeScript の型エラーを回避するためのキャスト"]'::jsonb, 1, 'SWR の `data` は初回フェッチが完了するまで `undefined` です。`??`（nullish coalescing）は左辺が `null` または `undefined` のとき右辺を返します。これにより `useQuizzes()` の戻り値 `quizzes` は常に `Quiz[]` 型が保証され、呼び出し側で `quizzes?.map(...)` のようなオプショナルチェーンが不要になります。', 'https://swr.vercel.app/docs/getting-started', 'unpublished', false),
  (215, 'セクション67: Tailwind CSS レイアウト', 'min-h-screen の役割', '以下の `AdminLayout` で外側の `<div>` に `min-h-screen` を付けている目的はどれですか？', '// AdminLayout.tsx
<div className="min-h-screen">
  <header>ナビゲーション</header>
  <main>
    <Outlet />
  </main>
</div>

// min-h-screen なしの場合:
// ┌──────────────────────┐ ← 画面の上端
// │ header               │
// ├──────────────────────┤
// │ main（短いコンテンツ）│
// ├──────────────────────┤ ← div がここで終わる
// │                      │
// │ （背景色が届かない） │
// │                      │
// └──────────────────────┘ ← 画面の下端
//
// min-h-screen ありの場合:
// ┌──────────────────────┐ ← 画面の上端
// │ header               │
// ├──────────────────────┤
// │ main（短いコンテンツ）│
// │                      │
// │ （div が画面下端まで  │
// │   伸びている）        │
// │                      │
// └──────────────────────┘ ← 画面の下端 = div の下端', '["header を画面上部に固定するため", "コンテンツが少なくても div がビューポート全体の高さを確保し、背景色やレイアウトが画面下端まで適用されるようにするため", "スクロールバーを常に表示するため", "main の幅を画面幅に合わせるため"]'::jsonb, 1, '`min-h-screen` は `min-height: 100vh` に相当し、「この要素の高さは最低でもビューポート（画面）と同じにする」という意味です。クイズが0件など中身が短い場合でも、外側の `<div>` が画面下端まで伸びるため背景色やレイアウトが途切れません。中身が画面より長い場合は自然にスクロールされます。', 'https://tailwindcss.com/docs/styling-with-utility-classes', 'unpublished', false),
  (216, 'セクション67: Tailwind CSS レイアウト', 'sticky top-0 の動作', '以下の `header` に付いている `sticky top-0` の動作はどれですか？', '<header className="sticky top-0 z-10 border-b border-[#14213d]/8 bg-[#fffaf0]/78 backdrop-blur-[18px]">
  <!-- ナビゲーション -->
</header>', '["header が常に画面最上部に固定され、コンテンツの上に重なる（position: fixed と同じ）", "スクロールして header が画面上端に達したとき、そこに貼り付いてスクロールに追従する", "header がページの一番上に配置されるだけで固定はされない", "top-0 は header の上部余白を 0 にするだけ"]'::jsonb, 1, '`sticky` は `position: sticky` に相当し、通常のフロー内に配置されますが、スクロールで `top: 0` の位置に達すると画面上端に貼り付きます。`fixed` と違い、最初はコンテンツの流れに沿って配置されるため他の要素を押し出しません。`backdrop-blur-[18px]` で半透明の背景ぼかし効果を加え、下のコンテンツがうっすら透けて見えるデザインになっています。', 'https://tailwindcss.com/docs/styling-with-utility-classes', 'unpublished', false),
  (217, 'セクション67: Tailwind CSS レイアウト', 'mx-auto max-w-[1200px] の組み合わせ', '以下のクラスの組み合わせが実現するレイアウトはどれですか？', '<div className="mx-auto w-full max-w-[1200px] px-4 sm:px-6 lg:px-8">
  <!-- コンテンツ -->
</div>', '["幅 1200px で左寄せされる", "幅が最大 1200px で中央寄せされ、画面幅が狭い場合はレスポンシブに縮む", "常に画面幅いっぱいに広がる", "1200px 未満の画面ではコンテンツが非表示になる"]'::jsonb, 1, '`w-full` で親の幅いっぱいに広がりつつ、`max-w-[1200px]` で上限を制限します。`mx-auto` は左右マージンを auto にして中央寄せします。`px-4 sm:px-6 lg:px-8` はブレークポイントごとにパディングを変えるレスポンシブ対応です。この3点セットは中央寄せコンテナの定型パターンです。', 'https://tailwindcss.com/docs/styling-with-utility-classes', 'unpublished', false),
  (218, 'セクション67: Tailwind CSS レイアウト', 'backdrop-blur の効果', '`backdrop-blur-[18px]` と `bg-[#fffaf0]/78` を組み合わせた header の視覚効果はどれですか？', '<header className="sticky top-0 z-10 bg-[#fffaf0]/78 backdrop-blur-[18px]">
  <!-- ナビゲーション -->
</header>', '["header の文字がぼやけて読みにくくなる", "header の背景が半透明（78%不透明度）で、背後のコンテンツが18pxのぼかしで透けて見えるすりガラス効果", "header の影が18pxぼかされる", "header の下のコンテンツが非表示になる"]'::jsonb, 1, '`bg-[#fffaf0]/78` は背景色を78%の不透明度で適用し、`backdrop-blur-[18px]` は要素の背後にある領域を18pxぼかします。スクロール時に下のコンテンツがすりガラス越しにうっすら見える効果が生まれます。`z-10` で他のコンテンツより前面に表示されることが保証されます。', 'https://tailwindcss.com/docs/styling-with-utility-classes', 'unpublished', false),
  (219, 'セクション67: Tailwind CSS レイアウト', 'NavLink の isActive による動的クラス', '以下の `NavLink` で `className` に関数を渡している理由はどれですか？', '<NavLink
  className={({ isActive }) =>
    isActive
      ? `${navLinkBaseClassName} bg-linear-to-br from-[#1768ac] to-[#0f4c81] text-white`
      : `${navLinkBaseClassName} border border-[#14213d]/12 bg-white/80 text-[#14213d]`
  }
  end
  to="/quizzes"
>
  一覧
</NavLink>', '["React Router が className に文字列を受け取れないため", "現在のURLと NavLink の to が一致（アクティブ）しているかどうかで、スタイルを動的に切り替えるため", "アニメーションのために関数が必要なため", "TypeScript の型推論のため"]'::jsonb, 1, 'React Router の `NavLink` は `className` に関数を渡すと `{ isActive, isPending }` を引数で受け取れます。現在の URL が `/quizzes` なら `isActive: true` になり青いグラデーション背景が適用され、そうでなければ白い背景のスタイルが適用されます。`end` プロパティは完全一致のみアクティブにする指定で、`/quizzes/new` のとき「一覧」がアクティブにならないようにします。', 'https://tailwindcss.com/docs/styling-with-utility-classes', 'unpublished', false),
  (220, 'セクション67: Tailwind CSS レイアウト', 'Outlet コンポーネントの役割', '以下の `<Outlet />` が表示する内容はどれですか？', '// AdminLayout.tsx
<div className="min-h-screen">
  <header>...</header>
  <main>
    <Outlet />
  </main>
</div>

// App.tsx のルート定義
<Route element={<AdminLayout />}>
  <Route path="/quizzes" element={<QuizListPage />} />
  <Route path="/quizzes/new" element={<QuizFormPage />} />
</Route>', '["AdminLayout 自身を再帰的にレンダリングする", "URL に応じた子ルートのコンポーネント（/quizzes なら QuizListPage、/quizzes/new なら QuizFormPage）を表示する", "常に全子ルートを同時に表示する", "404 ページのフォールバックを表示する"]'::jsonb, 1, '`<Outlet />` は React Router のネストされたルート構造で、現在の URL に一致する子ルートのコンポーネントを描画する「穴」です。`AdminLayout` は header + main の共通レイアウトを提供し、`<Outlet />` の部分だけがページ遷移で入れ替わります。これにより header のナビゲーションは再レンダリングされず、ページコンテンツだけが切り替わります。', 'https://tailwindcss.com/docs/styling-with-utility-classes', 'unpublished', false),
  (221, 'セクション68: CSS テーブルレイアウト', 'table-fixed と table-auto の違い', '以下のテーブルに `table-fixed` を追加した場合の動作変化はどれですか？', '// 変更前: 列幅がセル内容で自動決定
<table className="min-w-full border-collapse">

// 変更後: 列幅が th の width 指定で固定
<table className="min-w-full border-collapse table-fixed">', '["テーブルの高さが固定される", "列幅の計算方法が「セル内容の長さベース」から「th の width 指定ベース」に変わり、長いテキストは改行される", "テーブルがスクロール不可になる", "border-collapse が無効になる"]'::jsonb, 1, '`table-fixed` は `table-layout: fixed` に相当します。デフォルトの `table-layout: auto` はセル内容の長さに応じて列幅が決まりますが、`fixed` では最初の行（通常 `<th>`）の `width` 指定で列幅が決まります。長いテキスト（例:「セクション52: Claude Code アップデート案内」）は列幅に収まるよう自動改行されます。', 'https://developer.mozilla.org/en-US/docs/Web/CSS/table-layout', 'unpublished', false),
  (222, 'セクション68: CSS テーブルレイアウト', 'w-1/6 で均等列幅', '6列のテーブルで各 `<th>` に `w-1/6` を指定した場合、各列の幅はどうなりますか？', '<table className="min-w-full border-collapse table-fixed">
  <thead>
    <tr>
      <th className="w-1/6">タイトル</th>
      <th className="w-1/6">セクション</th>
      <th className="w-1/6">出典</th>
      <th className="w-1/6">作成日時</th>
      <th className="w-1/6">更新日時</th>
      <th className="w-1/6">操作</th>
    </tr>
  </thead>
</table>', '["各列が 1/6（約16.67%）で均等幅になる", "最初の列だけが 1/6 で残りは自動調整される", "w-1/6 は 6px を意味するため非常に狭くなる", "table-fixed がないと w-1/6 は無視される"]'::jsonb, 0, '`w-1/6` は `width: 16.666667%` に相当します。6列 × 16.67% = 100% で均等に分割されます。`table-fixed` と組み合わせることで、セル内容の長さに関係なく列幅が固定されます。`table-fixed` がなくても `w-1/6` は適用されますが、セル内容が長いと `auto` レイアウトに上書きされることがあります。', 'https://developer.mozilla.org/en-US/docs/Web/CSS/table-layout', 'unpublished', false),
  (223, 'セクション68: CSS テーブルレイアウト', 'table-layout: fixed のパフォーマンス', '`table-layout: fixed` が `table-layout: auto` よりレンダリングが速い理由はどれですか？', '// auto: 全セルの内容を読んでから列幅を計算
<table className="border-collapse"> <!-- table-layout: auto -->

// fixed: 最初の行だけ見て列幅を決定
<table className="border-collapse table-fixed">', '["fixed はブラウザキャッシュを使うため", "fixed は最初の行の幅情報だけで列幅を確定でき、全行のセル内容を先読みする必要がないため", "fixed は CSS を省略できるため", "fixed はテーブルの行数を制限するため"]'::jsonb, 1, '`table-layout: auto` はブラウザが全行の全セルを読み込んでから最適な列幅を計算するため、行数が多いとレンダリングが遅くなります。`table-layout: fixed` は最初の行（`<th>`）の `width` だけで列幅を確定するため、残りの行は逐次描画できます。クイズ一覧のように行数が多いテーブルでは体感速度の差が出ます。', 'https://developer.mozilla.org/en-US/docs/Web/CSS/table-layout', 'unpublished', false),
  (224, 'セクション69: React Fragments', 'Fragments が導入された歴史的動機', 'React 公式ドキュメントの Fragments の説明で、Fragments が導入された動機として最も適切なものはどれですか？', 'function Table() {
  return (
    <table>
      <tr>
        <Columns />
      </tr>
    </table>
  )
}

function Columns() {
  return (
    <div>
      <td>Hello</td>
      <td>World</td>
    </div>
  )
}', '["コンポーネントから複数要素を返したいが、`div` で包むと `table > tr > td` のような正しい HTML 構造を壊すため", "React が `div` 要素を将来的に廃止する予定だったため", "JSX では `td` 要素を2つ以上書けない仕様だったため", "Fragments は DOM ノード数を常に 0 にし、イベント処理も完全に無効化するため"]'::jsonb, 0, 'React の旧公式 Fragments ドキュメントでは、余計なラッパー要素を入れると表のような文脈で不正な HTML になることが導入の動機として説明されています。Fragments は複数要素をグループ化しつつ、DOM に不要なラッパーノードを追加しないため、この問題を避けられます。現行の react.dev でも、Fragment は wrapper node なしで要素をまとめる手段として説明されています。', 'https://react.dev/reference/react/Fragment', 'unpublished', false),
  (225, 'セクション70: Googlebot と JavaScript レンダリング', 'Googlebot の JS レンダリング ファイルサイズ制限の変更', 'Googlebot が JavaScript をレンダリングする際、2026年2月に変更されたファイルサイズ制限は何 MB から何 MB になりましたか？', NULL, '["10MB から 20MB", "15MB から 50MB", "50MB から 100MB", "制限なしから 15MB に新設された"]'::jsonb, 1, '2026年2月、Google は Web Rendering Service (WRS) のリソースサイズ上限を従来の 15MB から 50MB に引き上げました。これにより、大規模な SPA バンドルでもレンダリング対象に入りやすくなりましたが、レンダリングキューの遅延（数時間〜数日）は依然として存在するため、SEO が重要なページでは SSR/SSG が推奨されます。', 'https://developers.google.com/search/docs/crawling-indexing/javascript/javascript-seo-basics', 'unpublished', false),
  (226, 'セクション70: Googlebot と JavaScript レンダリング', 'ダイナミックレンダリングの代替手法', 'Google 公式ドキュメントで、ダイナミックレンダリング（User-Agent によるサーバー側切替）の代わりに推奨されている3つの手法の組み合わせとして正しいものはどれですか？', NULL, '["SSR（サーバーサイドレンダリング）、SSG（静的サイト生成）、ハイドレーション", "CSR（クライアントサイドレンダリング）、ISR（インクリメンタル静的再生成）、Edge Functions", "プリレンダリング、AMP、Service Worker キャッシュ", "Headless Chrome、Puppeteer、Lighthouse CI"]'::jsonb, 0, 'Google の JavaScript SEO ドキュメントでは、ダイナミックレンダリングは「回避策 (workaround)」であり長期的な解決策ではないとされています。代わりに SSR（サーバーサイドレンダリング）、SSG（静的サイト生成）、ハイドレーション（SSR で生成した HTML にクライアント側で JS を接続する手法）の3つが推奨されています。', 'https://developers.google.com/search/docs/crawling-indexing/javascript/javascript-seo-basics', 'unpublished', false),
  (227, 'セクション71: SWR（stale-while-revalidate）', 'SWR の名前の由来', 'SWR という名前の由来となった HTTP キャッシュ戦略の正式名称はどれですか？', NULL, '["stale-while-revalidate", "service-worker-refresh", "synchronous-web-request", "server-wide-replication"]'::jsonb, 0, 'SWR は HTTP の Cache-Control ヘッダーで使われる `stale-while-revalidate` 戦略に由来します。RFC 5861 で定義されたこの戦略は、キャッシュが stale（期限切れ）でもまず古いデータを返し（stale）、バックグラウンドで最新データを取得（revalidate）するというものです。Vercel の SWR ライブラリはこの考え方をクライアント側データフェッチに応用しています。', 'https://swr.vercel.app/docs/getting-started', 'unpublished', false),
  (228, 'セクション71: SWR（stale-while-revalidate）', 'SEO と SWR の相性', 'SEO が重要なコンテンツに SWR（CSR でのデータフェッチ）を使うべきでない理由として最も適切なものはどれですか？', NULL, '["SWR はデータを暗号化するため、検索エンジンがコンテンツを読めなくなる", "SWR は初回レンダリング時に HTML が空であり、Googlebot の JS レンダリングキューに依存するためインデックスが遅延する", "SWR はサーバーサイドでしか動作しないため、ブラウザに HTML が届かない", "SWR のキャッシュ戦略が robots.txt と競合するため"]'::jsonb, 1, 'SWR を CSR で使う場合、初期 HTML は `<div id="root"></div>` のような空の状態でブラウザに届きます。コンテンツは JavaScript 実行後に描画されるため、Googlebot は JS レンダリングキュー（数時間〜数日の遅延）を経由してからでないとコンテンツを認識できません。また、Twitter や Slack 等のクローラーは JS を実行しないため、OGP タグも機能しません。ただし、ログイン必須の管理画面のように SEO が不要な画面では SWR + CSR で問題ありません。', 'https://swr.vercel.app/docs/getting-started', 'unpublished', false),
  (229, 'セクション72: CSS position: sticky と関連プロパティ', 'top: 0 の 0 に単位は必要か', 'Tailwind CSS の `top-0` は `top: 0px` を生成します。CSS の仕様上、`top: 0` と `top: 0px` の違いについて MDN Web Docs の記述に基づく正しい説明はどれですか？', '/* Tailwind が生成する CSS */
.top-0 {
  top: 0px;
}

/* 手書きでも有効な CSS */
.header {
  top: 0;
}', '["`top: 0` は無効な CSS であり、必ず `top: 0px` のように単位を付けなければならない", "`0` は次元を持たない特別な値なので単位を省略でき、`top: 0` と `top: 0px` は同じ意味になる", "`top: 0` は `top: 0%` と解釈されるため、`top: 0px` とは異なる", "`top: 0` は `top: auto` のエイリアスとして扱われる"]'::jsonb, 1, 'MDN Web Docs によると、CSS の `<length>` 値には通常単位が必要ですが、値が `0` の場合は例外です。0 はどの単位でも同じ距離（ゼロ）を表すため、単位を省略できます。したがって `top: 0` と `top: 0px` は完全に等価です。Tailwind CSS は明示的に `0px` を生成しますが、手書き CSS では `top: 0` で問題ありません。', 'https://developer.mozilla.org/en-US/docs/Web/CSS/position', 'unpublished', false),
  (230, 'セクション72: CSS position: sticky と関連プロパティ', 'z-index の値は相対的か絶対的か', '管理画面のヘッダーに `z-10`（`z-index: 10`）が設定されています。これを `z-5`（`z-index: 5`）に変更しても問題ないかを判断するために、MDN Web Docs の z-index の説明に基づく正しい理解はどれですか？', '/* 現在の設定 */
header { z-index: 10; }

/* 変更案 */
header { z-index: 5; }', '["z-index の数値は CSS 仕様で用途ごとに予約されており、ヘッダーには必ず 10 以上を使わなければならない", "z-index は同一スタッキングコンテキスト内での相対的な順序を決めるだけなので、他の要素より大きければ 5 でも 10 でも結果は同じ", "z-index: 5 は z-index: 10 の半分の透明度で描画される", "z-index は 0〜9 の範囲しか有効でないため、10 は実質 0 と同じ扱いになる"]'::jsonb, 1, 'MDN Web Docs によると、z-index はスタッキングコンテキスト内での要素の重なり順を決める整数値であり、数値自体に絶対的な意味はありません。重要なのは同じスタッキングコンテキスト内の他の要素との相対的な大小関係です。ヘッダーより前面に出る要素がなければ z-index: 5 でも z-index: 10 でも視覚的な結果は同じです。ただし、将来モーダル（z-40）やドロップダウンメニュー（z-20）を追加する可能性を考慮して、ヘッダーに z-10 程度の余裕を持たせるのが一般的な慣習です。', 'https://developer.mozilla.org/en-US/docs/Web/CSS/position', 'unpublished', false),
  (231, 'セクション72: CSS position: sticky と関連プロパティ', 'position: sticky が機能する条件', 'MDN Web Docs によると、`position: sticky` を指定した要素が「張り付く」動作をするために必須の条件はどれですか？', '/* パターン A: 動作する */
header {
  position: sticky;
  top: 0;
}

/* パターン B: 動作しない */
header {
  position: sticky;
  /* top, right, bottom, left いずれも未指定 */
}', '["z-index を 1 以上に設定する", "top, right, bottom, left のうち少なくとも1つを auto 以外の値に設定する", "親要素に overflow: hidden を設定する", "display: flex または display: grid を親要素に設定する"]'::jsonb, 1, 'MDN Web Docs には「少なくとも1つの inset プロパティ（top, right, bottom, left 等）を auto 以外の値に設定する必要がある。両方の inset プロパティが auto の場合、その軸では sticky ではなく relative として振る舞う」と明記されています。つまり `position: sticky` だけ書いても、top 等の閾値を指定しなければ張り付き動作は発生しません。管理画面の `sticky top-0` は top: 0 を指定しているため正しく機能します。', 'https://developer.mozilla.org/en-US/docs/Web/CSS/position', 'unpublished', false),
  (232, 'セクション72: CSS position: sticky と関連プロパティ', 'z-index: auto と z-index: 0 の違い', 'MDN Web Docs によると、`z-index: auto`（デフォルト値）と `z-index: 0` の違いとして正しいものはどれですか？', NULL, '["まったく同じであり、どちらもスタッキングコンテキストを生成する", "auto はスタッキングコンテキストを生成しないが、0 は新しいスタッキングコンテキストを生成する", "auto はスタック順が 0 になるが、0 はスタック順が -1 になる", "auto は positioned 要素にのみ有効で、0 は static 要素にも有効"]'::jsonb, 1, 'MDN Web Docs によると、z-index: auto のスタックレベルは 0 ですが、新しいスタッキングコンテキストは生成しません。一方 z-index: 0（整数値）はスタックレベルが 0 であると同時に、新しいローカルスタッキングコンテキストを生成します。この違いは子要素の重なり順に影響します。auto の場合、子要素の z-index は親の外側の要素と直接比較されますが、0 の場合は新しいスタッキングコンテキスト内に閉じ込められます。', 'https://developer.mozilla.org/en-US/docs/Web/CSS/position', 'unpublished', false),
  (233, 'セクション72: CSS position: sticky と関連プロパティ', 'position: static で top が効かない理由', '次の CSS で `.box` が 30px 下にずれない理由として、MDN Web Docs の記述に基づく正しい説明はどれですか？', '.box {
  /* position 未指定 → デフォルトは static */
  top: 30px;
  left: 20px;
}', '["top と left を同時に指定しているため、値が打ち消し合ってゼロになる", "position が static（デフォルト）の場合、top / right / bottom / left プロパティは効果を持たない", "px 単位は position と併用できず、% 単位でなければならない", "top: 30px は構文エラーであり、ブラウザに無視される"]'::jsonb, 1, 'MDN Web Docs の top プロパティのページでは、position の値ごとの効果が明記されています。position: static の場合、top プロパティは「has no effect（効果なし）」です。top / right / bottom / left が機能するのは position が relative, absolute, fixed, sticky のいずれかの場合に限られます。CSS として記述すること自体は有効ですが、static 要素に対しては完全に無視されます。', 'https://developer.mozilla.org/en-US/docs/Web/CSS/position', 'unpublished', false),
  (234, 'セクション72: CSS position: sticky と関連プロパティ', 'position: relative の実務上の主な用途', '`position: relative` を指定しつつ top / left 等を指定しないケースが実務では多く見られます。この場合の主な目的として最も適切なものはどれですか？', '/* 親 */
.card {
  position: relative; /* top 等は指定しない */
}

/* 子 */
.badge {
  position: absolute;
  top: 0;
  right: 0;
}', '["relative を指定すると要素の描画が GPU アクセラレーションされ、パフォーマンスが向上するため", "子要素の position: absolute の基準点（containing block）にするため", "スクロール時に要素が画面上部に固定されるようにするため", "要素のデフォルトの margin と padding をリセットするため"]'::jsonb, 1, 'MDN Web Docs によると、position: absolute の要素は最寄りの positioned 祖先（static 以外の position を持つ祖先）を基準に配置されます。親に position: relative を指定することで、absolute な子要素の基準点（containing block）として機能させるのが実務上最も一般的な用途です。relative 自体は top 等を指定しなければ見た目に変化はなく、ドキュメントフローにも影響しません。', 'https://developer.mozilla.org/en-US/docs/Web/CSS/position', 'unpublished', false),
  (235, 'セクション73: Dart late と null safety', 'late がコンパイル時ではなくランタイムで制約を強制する意味', 'Dart 公式 docs では `late` について “enforce this variable''s constraints at runtime instead of at compile time” と説明されています。次の宣言に対する理解として最も正しいものはどれですか？', 'late SharedPreferences sharedPref;', '["宣言と同時に `SharedPreferences.getInstance()` が自動実行され、`sharedPref` に即座に値が入る", "コンパイル時の definite assignment チェックの代わりに、未初期化のまま読み出したときにランタイムで検査される", "`late` を付けると変数自体が存在しなくなり、初回代入時までメモリは一切使われない", "`late` を付けた変数は暗黙に nullable になり、未代入時は常に `null` を返す"]'::jsonb, 1, '`late` は「あとで必ず初期化する」という前提で、コンパイル時の初期化保証を緩め、その代わりに実行時チェックへ回す仕組みです。このため `late SharedPreferences sharedPref;` という宣言だけでは `SharedPreferences` の取得処理は走りません。実際の値は後で代入する必要があり、代入前に読み出すと `LateInitializationError` になります。', 'https://dart.dev/null-safety', 'unpublished', false),
  (236, 'セクション73: Dart late と null safety', 'preferences と references の意味の違い', '`late SharedPreferences sharedPref;` を説明する文脈で、`preferences` と `references` の違いとして最も正しいものはどれですか？', 'late SharedPreferences sharedPref;', '["`preferences` は参照、`references` は設定値を意味するので、2語はほぼ同義で入れ替えてよい", "`preferences` は設定や選好、`references` は参照を意味するため、`SharedPreferences` を「設定保存」と説明しつつ、変数にはオブジェクトへの reference が入ると区別するのが正しい", "`preferences` はメモリアドレス、`references` はディスク領域を意味する技術用語である", "`references` は Dart では予約語なので、公式 docs では `preferences` の代わりに使われている"]'::jsonb, 1, '`preferences` は一般英語として「設定・好み・選好」を表します。一方 `references` は「参照」です。したがって `SharedPreferences` という API 名は「共有設定」を指しており、変数 `sharedPref` に入るものを説明する時は「SharedPreferences オブジェクトへの参照が入る」と言うのが正確です。名前に `Preferences` が含まれていることと、実行時に変数が保持する reference は別概念です。', 'https://dart.dev/null-safety', 'unpublished', false),
  (237, 'セクション74: Flutter プラットフォームとバインディング', 'Flutter における「プラットフォーム」の意味', 'Flutter の文脈で「プラットフォーム側」とは何を指すか。', NULL, '["Dart で記述された UI コンポーネント群", "Android・iOS など OS 側のネイティブ環境", "Flutter SDK のビルドツールチェーン", "pub.dev で配布されるパッケージ群"]'::jsonb, 1, 'Flutter では Dart で UI を記述するが、SharedPreferences・カメラ・通知・位置情報など端末固有の機能を使う際は OS 側（Android、iOS、Web、macOS 等）とやり取りする。この OS 側のネイティブ環境を「プラットフォーム」と呼ぶ。', 'https://docs.flutter.dev/', 'unpublished', false),
  (238, 'セクション74: Flutter プラットフォームとバインディング', 'WidgetsFlutterBinding.ensureInitialized() の役割', 'main() 関数内で runApp() より前に WidgetsFlutterBinding.ensureInitialized() を呼ぶ必要があるのはどのような場合か。', NULL, '["StatefulWidget を使用する場合", "runApp() の前にプラットフォーム側の機能（SharedPreferences 等）を利用する場合", "複数の MaterialApp を定義する場合", "リリースビルドを行う場合"]'::jsonb, 1, 'WidgetsFlutterBinding.ensureInitialized() は Flutter の Dart コードと OS 側のネイティブ機能をつなぐバインディングを初期化する。runApp() は内部でこれを自動的に行うが、runApp() より前に SharedPreferences などプラットフォーム機能を使う場合は、明示的に呼び出して先にバインディングを確立する必要がある。', 'https://docs.flutter.dev/', 'unpublished', false),
  (239, 'セクション74: Flutter プラットフォームとバインディング', 'Flutter の共通コードとプラットフォーム固有コードの関係', 'Flutter アプリにおいて、Dart で書かれた共通コードからカメラや通知などの OS 固有機能を利用する仕組みとして正しいものはどれか。', NULL, '["Dart コードから直接 OS の API を呼び出す", "プラットフォームチャネルを介して Dart 側と OS 側が通信する", "OS 固有機能は Flutter では利用できない", "ビルド時に Dart コードがネイティブコードに完全変換される"]'::jsonb, 1, 'Flutter は Platform Channels という仕組みで Dart 側とプラットフォーム側（Android/iOS 等）を接続する。SharedPreferences、SystemChrome、カメラ、通知、位置情報などの OS 固有機能はすべてこの通信機構を通じて利用される。Dart コードが直接 OS の API を呼ぶわけではない。', 'https://docs.flutter.dev/', 'unpublished', false),
  (240, 'セクション75: Docker / Migration トラブルシュート', 'ERR_EMPTY_RESPONSE の背後にあった本当の原因', '管理画面で `http://localhost:8082/api/admin/quizzes?sort=updated_newest&page=1` へのアクセス時に `Failed to load resource: net::ERR_EMPTY_RESPONSE` が出ていました。調査すると backend のログには `duplicate key value violates unique constraint "quizzes_pkey"` と `Dirty database version 4. Fix and force version.` が出ていました。この状況の原因と解決策として最も適切なものはどれですか？', '// browser
:8082/api/admin/quizzes?sort=updated_newest&page=1
Failed to load resource: net::ERR_EMPTY_RESPONSE

// backend log
migration failed: duplicate key value violates unique constraint "quizzes_pkey"
Dirty database version 4. Fix and force version.', '["Vite の proxy 設定不足が原因なので、vite.config.ts に proxy を追加するだけで直る", "認証トークン切れが原因なので、再ログインだけで直る", "seed migration が既存の quizzes データと主キー衝突して backend が起動失敗し、HTTP 応答を返せていなかった。重複しない形に migration を直し、dirty な schema_migrations を修復して再起動する必要がある", "ブラウザキャッシュ破損が原因なので、ハードリロードで backend の migration も自動修復される"]'::jsonb, 2, '`ERR_EMPTY_RESPONSE` はフロントの fetch 記述ミスではなく、接続先サーバーが正常な HTTP レスポンスを返す前に落ちている時にも発生します。今回の実原因は seed migration 004 が `quizzes` テーブルの既存データと主キー衝突を起こし、その途中で DB が `version=4, dirty=true` になって backend が起動失敗していたことです。対処としては、migration を再実行可能な形に修正し、`schema_migrations` の dirty 状態を解消した上で backend を再起動します。その後は `ERR_EMPTY_RESPONSE` ではなく、未認証なら `401` のような通常の HTTP 応答が返るようになります。', 'https://docs.docker.com/reference/dockerfile/', 'unpublished', false),
  (241, 'セクション76: Matt Pocock - TypeScript の実践', 'TypeScript 採用による Airbnb のバグ防止率', 'Matt Pocock が紹介した事例によると、Airbnb が TypeScript に移行した際、防止可能だったバグの割合はどのくらいか。', NULL, '["約 15%", "約 25%", "約 38%", "約 50%"]'::jsonb, 2, 'Matt Pocock は Kent C. Dodds との対談で Airbnb の TypeScript 移行事例を引用し、''I can''t remember what the exact figure was, but it was something like 38%'' と述べている。Matt 本人が概算と断っている数値だが、TypeScript の型システムがコンパイル時に多くのバグを検出できることを示す事例として紹介された。', 'https://www.totaltypescript.com/', 'unpublished', false),
  (242, 'セクション76: Matt Pocock - TypeScript の実践', '外部データ境界における Zod の推奨理由', 'Matt Pocock と Kent C. Dodds が fetch のレスポンスに対してジェネリクスで型を付ける手法を危険だと警告している理由はどれか。', 'const data = await fetch(''/api/user'').then(r => r.json()) as User;', '["ジェネリクスを使うとバンドルサイズが増大するため", "実行時にはデータの中身を検証しておらず、any を隠しているだけだから", "TypeScript コンパイラがジェネリクスを最適化できないため", "fetch API がジェネリクスをサポートしていないため"]'::jsonb, 1, 'fetch のレスポンスを as User やジェネリクスで型付けしても、実行時のデータが本当にその型に合致するかは検証されない。見た目は型安全だが、内部的には any を隠しているだけである。Matt Pocock はこの問題の代替案として Zod などのランタイム検証ツールでデータ境界を実際にチェックすることを推奨している。', 'https://www.totaltypescript.com/', 'unpublished', false),
  (243, 'セクション76: Matt Pocock - TypeScript の実践', 'interface と type のパフォーマンス差', 'Matt Pocock が指摘した、TypeScript における interface が交差型（& 演算子による type）よりパフォーマンス上有利な理由はどれか。', '// interface
interface User extends Base {
  name: string;
}

// type + 交差型
type User = Base & {
  name: string;
};', '["interface は JavaScript にコンパイルされるが type はされないため", "interface extends による名前付け継承で TypeScript のキャッシュ効率が向上するため", "interface は V8 エンジンの隠しクラスに直接マッピングされるため", "type は毎回新しいオブジェクトをヒープに確保するため"]'::jsonb, 1, 'Matt Pocock によると、interface extends は名前付け継承として TypeScript コンパイラがキャッシュしやすい。一方、交差型（&）は毎回型の合成を評価する必要があり、キャッシュ効率が劣る。ただし Matt は「両者は第一級プリミティブであり、一貫性強制は不要」とも述べている。', 'https://www.totaltypescript.com/', 'unpublished', false),
  (244, 'セクション76: Matt Pocock - TypeScript の実践', 'interface の宣言マージの落とし穴', 'TypeScript で同名の interface を2回宣言した場合、どのような挙動になるか。', 'interface Config {
  host: string;
}

interface Config {
  port: number;
}', '["コンパイルエラーになる", "後の宣言が前の宣言を上書きする", "自動的にマージされ、host と port の両方を持つ型になる", "どちらの宣言も無視される"]'::jsonb, 2, 'TypeScript の interface には宣言マージ（declaration merging）という機能があり、同名の interface は自動的に統合される。これは意図的に使う場面もあるが、意図せず同名にしてしまった場合、バグの原因になる。Matt Pocock はこれを interface の落とし穴として指摘している。type の場合は同名で重複宣言するとコンパイルエラーになるため、この問題は起きない。', 'https://www.totaltypescript.com/', 'unpublished', false),
  (245, 'セクション76: Matt Pocock - TypeScript の実践', 'Matt Pocock の戻り値型アノテーションに対する見解', 'Matt Pocock は関数の戻り値型を常に明示すべきだと考えているか。', NULL, '["常に明示すべき。型推論に頼るのは危険である", "常に省略すべき。TypeScript の型推論は十分に正確である", "常に明示すべきではないが、必要で意味がある場面では明示すべき", "ライブラリ開発でのみ明示し、アプリケーションコードでは常に省略すべき"]'::jsonb, 2, 'Matt Pocock は ''I think you shouldn''t always require explicit return types. I still think you should use return types when you need to and when it makes sense'' と述べている。「常に明示」ルールには反対だが、必要に応じて明示する柔軟な姿勢である。具体的にどの場面で必要かについて厳密な分類は示しておらず、文脈次第としている。', 'https://www.totaltypescript.com/', 'unpublished', false),
  (246, 'セクション77: コード設計原則', 'Zod スキーマとサンプルデータのコロケーション', '次のように `IntroSchema` と `introToYourselfSample` を同じファイルに置く方針の主目的として最も適切なのはどれですか？', 'const IntroSchema = z.object({
  name: z.string(),
  age: z.number().int(),
  // ...
});

export type IntroToYourself = z.infer<typeof IntroSchema>;

export const introToYourselfSample: IntroToYourself = {
  name: ''Kosuke'',
  age: 30,
  // ...
};', '["schema とサンプルを同居させると、フィールドを追加した瞬間にサンプル側が型エラーになり、セットで修正すべきことがすぐ分かるから", "TypeScript は別ファイルから z.infer を実行できないため", "Zod は単一ファイル内でしか import/export できないため", "Vite は JSON や Zod を複数ファイルで扱うとバンドルできないため"]'::jsonb, 0, 'Kent C. Dodds が提唱する Colocation では、一緒に変更されるものは同じ場所に置きます。Zod スキーマと代表サンプルを同じファイルに置くと、フィールドを追加・削除した際にサンプルが即座にコンパイルエラーになり、両者を同時に更新することが明確になります。また shape に関する単一の情報源として読めるため理解が速くなります。', 'https://developer.mozilla.org/en-US/docs/Web', 'unpublished', false),
  (247, 'セクション78: GitHub SSH 認証', 'SSH 接続時の認証キー', 'SSH 経由で GitHub に接続する際、認証に使用されるのはどちらのキーか？', NULL, '["公開鍵（public key）", "秘密鍵（private key）", "パスフレーズ", "Personal Access Token"]'::jsonb, 1, 'GitHub 公式ドキュメントには ''When you connect via SSH, you authenticate using a private key file on your local machine.'' と記載されている。SSH 接続時の認証には秘密鍵が使用され、公開鍵は GitHub アカウント側に登録するものである。', 'https://docs.github.com/en/authentication/connecting-to-github-with-ssh', 'unpublished', false),
  (248, 'セクション78: GitHub SSH 認証', '未使用 SSH キーの自動削除', 'GitHub は、セキュリティ上の理由から1年間使用されなかった SSH キーをどうするか？', NULL, '["無効化して通知する", "自動的に削除する", "読み取り専用に変更する", "パスフレーズのリセットを要求する"]'::jsonb, 1, 'GitHub 公式ドキュメントには ''If you haven''t used your SSH key for a year, then GitHub will automatically delete your inactive SSH key as a security precaution.'' と記載されている。セキュリティ予防措置として、1年間使用されなかった SSH キーは自動的に削除される。', 'https://docs.github.com/en/authentication/connecting-to-github-with-ssh', 'unpublished', false),
  (249, 'セクション78: GitHub SSH 認証', '推奨 SSH キーアルゴリズム', 'GitHub 公式ドキュメントで新しい SSH キーを生成する際に推奨されているアルゴリズムはどれか？', 'ssh-keygen -t ??? -C "your_email@example.com"', '["rsa", "dsa", "ed25519", "ecdsa"]'::jsonb, 2, '公式ドキュメントのコマンド例は `ssh-keygen -t ed25519 -C "your_email@example.com"` であり、Ed25519 が推奨されている。Ed25519 をサポートしないレガシシステムでのみ RSA（4096ビット）が代替として案内されている。', 'https://docs.github.com/en/authentication/connecting-to-github-with-ssh', 'unpublished', false),
  (250, 'セクション78: GitHub SSH 認証', 'DSA キーのサポート廃止', 'GitHub が 2022年3月15日以降サポートを廃止した SSH キーの種類はどれか？', NULL, '["RSA キー (`ssh-rsa`)", "Ed25519 キー (`ssh-ed25519`)", "DSA キー (`ssh-dss`)", "ECDSA キー (`ssh-ecdsa`)"]'::jsonb, 2, '公式ドキュメントに『それ以降、DSA キー (`ssh-dss`) はサポートされなくなりました。GitHub の個人用アカウントに新しい DSA キーを追加することはできません。』と記載されている。セキュリティ強化の一環としての措置である。', 'https://docs.github.com/en/authentication/connecting-to-github-with-ssh', 'unpublished', false),
  (251, 'セクション78: GitHub SSH 認証', 'ssh-agent の役割', 'SSH キーのパスフレーズを毎回入力したくない場合、どのツールにキーを追加すればよいか？', NULL, '["git-credential-manager", "ssh-agent", "gpg-agent", "keychain"]'::jsonb, 1, '公式ドキュメントに『キーにパスフレーズがあり、キーを使用するたびにパスフレーズを入力したくない場合は、SSH エージェントにキーを追加できます。SSH エージェントでは SSH キーを管理し、パスフレーズを記憶します。』と記載されている。', 'https://docs.github.com/en/authentication/connecting-to-github-with-ssh', 'unpublished', false),
  (252, 'セクション78: GitHub SSH 認証', 'RSA キーの SHA-2 要件', '2021年11月2日以降に生成された RSA キーが満たさなければならない要件はどれか？', NULL, '["鍵長が 8192 ビット以上であること", "SHA-2 署名アルゴリズムを使用すること", "パスフレーズが必須であること", "ハードウェアセキュリティキーと併用すること"]'::jsonb, 1, '公式ドキュメントに『その日以降に生成される RSA キーは、SHA-2 署名アルゴリズムを使用する必要があります。SHA-2 署名を使用するには、一部の古いクライアントをアップグレードする必要があります。』と記載されている。', 'https://docs.github.com/en/authentication/connecting-to-github-with-ssh', 'unpublished', false),
  (253, 'セクション78: GitHub SSH 認証', 'SSH キーの用途選択', 'GitHub アカウントに SSH 公開鍵を追加する際、キーの用途として選択できるのはどれか？', NULL, '["認証（authentication）または署名（signing）", "暗号化（encryption）または復号（decryption）", "プッシュ（push）またはプル（pull）", "読み取り（read）または書き込み（write）"]'::jsonb, 0, '公式ドキュメントに『キーの種類として、認証または署名のいずれかを選びます。』と記載されている。認証と署名の両方に同じ SSH キーを使用する場合は、2回アップロードする必要がある。', 'https://docs.github.com/en/authentication/connecting-to-github-with-ssh', 'unpublished', false),
  (254, 'セクション78: GitHub SSH 認証', 'SSH 公式英文の日本語訳', '以下の英文の正しい日本語訳はどれか？

''You must also add the public SSH key to your account on GitHub before you use the key to authenticate or sign commits.''', NULL, '["SSH キーを使用して認証やコミット署名を行う前に、秘密鍵を GitHub アカウントに追加する必要がある", "SSH キーを使用して認証やコミット署名を行った後に、公開鍵を GitHub アカウントに追加する必要がある", "SSH キーを使用して認証やコミット署名を行う前に、公開鍵を GitHub アカウントに追加する必要がある", "SSH キーを使用して認証やコミット署名を行うには、秘密鍵と公開鍵の両方を GitHub に追加する必要がある"]'::jsonb, 2, '''public SSH key'' が公開鍵、''before'' が『〜する前に』を意味する。秘密鍵はローカルに保持し、公開鍵のみ GitHub に登録する。誤訳選択肢は秘密鍵・公開鍵の取り違え、before/after の誤訳をそれぞれ含んでいる。', 'https://docs.github.com/en/authentication/connecting-to-github-with-ssh', 'unpublished', false),
  (255, 'セクション78: GitHub SSH 認証', 'ハードウェアセキュリティキー用コマンド', 'ハードウェアセキュリティキー用の SSH キーを生成する際、Ed25519 アルゴリズムをサポートしていない場合に使用すべきコマンドはどれか？', NULL, '["`ssh-keygen -t rsa -b 4096 -C \"email@example.com\"`", "`ssh-keygen -t ecdsa-sk -C \"email@example.com\"`", "`ssh-keygen -t dsa -C \"email@example.com\"`", "`ssh-keygen -t ed25519 -C \"email@example.com\"`"]'::jsonb, 1, '公式ドキュメントに『コマンドが失敗し、エラー invalid format または feature not supported を受け取る場合は、Ed25519 アルゴリズムをサポートしていないハードウェアセキュリティキーを使っている可能性があります。代わりに ssh-keygen -t ecdsa-sk -C ... を入力します。』と記載されている。-sk サフィックスはセキュリティキー対応を示す。', 'https://docs.github.com/en/authentication/connecting-to-github-with-ssh', 'unpublished', false),
  (256, 'セクション78: GitHub SSH 認証', 'SAML SSO 環境での SSH キー承認', 'SAML シングルサインオンを使用する Organization のリポジトリに SSH キーでアクセスするために必要な追加手順は何か？', NULL, '["SSH キーを再生成する", "SSH キーを承認（authorize）する", "SSH キーにパスフレーズを追加する", "SSH キーを管理者に送信する"]'::jsonb, 1, '公式ドキュメントに ''To use your SSH key with a repository owned by an organization that uses SAML single sign-on, you must authorize the key.'' と記載されている。キーの再生成やパスフレーズ追加は不要で、既存のキーを Organization 向けに承認する操作が必要である。', 'https://docs.github.com/en/authentication/connecting-to-github-with-ssh', 'unpublished', false),
  (257, 'セクション79: クイズ同期 & 管理画面運用', 'production JSON の役割', '`backend/seeds/quizzes.production.json` の役割として最も適切なものはどれですか？', NULL, '["管理画面の見た目だけを調整する Tailwind 設定ファイル", "本番反映対象のクイズを保持し、DB 同期やマイグレーション生成の入力に使う JSON", "ログイン用 JWT の秘密鍵を保存する JSON", "React Router のルーティング定義ファイル"]'::jsonb, 1, '`backend/seeds/quizzes.production.json` は本番反映対象のクイズデータを持つテンプレートであり、管理画面の同期 API や seed SQL 生成の入力として使われる。', 'https://vite.dev/guide/assets#the-public-directory', 'unpublished', false),
  (258, 'セクション79: クイズ同期 & 管理画面運用', 'generate_migration.py の責務', '`python3 scripts/generate_migration.py < backend/seeds/quizzes.production.json` の説明として正しいものはどれですか？', NULL, '["マイグレーション番号を自動採番して DB へ即時適用する", "JSON を読み取って SQL テキストを stdout に出力する", "quizzes.production.json を React 用 JSX に変換する", "DB の既存クイズを JSON に書き戻す"]'::jsonb, 1, '`generate_migration.py` は seed JSON を読み取り、`INSERT ... ON CONFLICT ...` などの SQL テキストを標準出力へ出す。ファイル作成や採番は別処理で行う。', 'https://vite.dev/guide/assets#the-public-directory', 'unpublished', false),
  (259, 'セクション79: クイズ同期 & 管理画面運用', 'golang-migrate create の役割', '`migrate create -ext sql -dir backend/migrations -seq -digits 3 seed_quizzes` を使う主目的はどれですか？', 'migrate create -ext sql -dir backend/migrations -seq -digits 3 seed_quizzes', '["既存マイグレーションを自動的にロールバックするため", "番号付きの `up.sql` / `down.sql` 雛形を正しい命名規則で作るため", "PostgreSQL のテーブル定義を JSON に変換するため", "React 管理画面の API クライアントを生成するため"]'::jsonb, 1, '`golang-migrate create` は連番付きの `NNN_name.up.sql` / `NNN_name.down.sql` を生成し、採番やファイル名の管理を肩代わりする。', 'https://vite.dev/guide/assets#the-public-directory', 'unpublished', false),
  (260, 'セクション79: クイズ同期 & 管理画面運用', 'Upsert の更新条件', '`ON CONFLICT (id) DO UPDATE` に変更した後の挙動として正しいものはどれですか？', NULL, '["同じ ID が存在しても常に挿入をスキップする", "同じ ID の行があれば、タイトルや選択肢が少しでも違うと更新される", "同じ ID があると必ずエラーになる", "ID が同じ場合は `created_at` だけ更新される"]'::jsonb, 1, '`ON CONFLICT (id) DO UPDATE SET ...` では競合した ID の行を上書き更新する。`section`、`title`、`question`、`options` など指定したカラムが新しい値へ更新される。', 'https://vite.dev/guide/assets#the-public-directory', 'unpublished', false),
  (261, 'セクション79: クイズ同期 & 管理画面運用', 'down.sql の性質', '今回の seed 用 `down.sql` の性質として最も適切なのはどれですか？', NULL, '["更新前のレコード内容を完全に復元できる", "今回の seed 対象 ID を削除する簡易ロールバックであり、更新前データまでは戻さない", "DB スキーマを 001 の状態まで戻す", "マイグレーションの `dirty` フラグだけを消す"]'::jsonb, 1, 'この `down.sql` は seed 対象 ID の削除が主目的であり、Upsert 前の値をスナップショットから復元する仕組みは持たない。', 'https://vite.dev/guide/assets#the-public-directory', 'unpublished', false),
  (262, 'セクション79: クイズ同期 & 管理画面運用', '管理画面ボタンの呼び先', '管理画面の `production.json を DB 反映` ボタンを押したとき、最初にフロントが呼ぶ API はどれですか？', NULL, '["`POST /api/admin/quizzes/sync-production`", "`GET /api/admin/quizzes`", "`PATCH /api/admin/quizzes/{id}/status`", "`POST /api/admin/login/verification`"]'::jsonb, 0, '一覧画面の同期ボタンは `syncProductionQuizzes()` を呼び、認証付きで `POST /api/admin/quizzes/sync-production` を送る。', 'https://vite.dev/guide/assets#the-public-directory', 'unpublished', false),
  (263, 'セクション79: クイズ同期 & 管理画面運用', '同期 API が読むファイル', '管理画面の同期 API が既定で読み込むファイルパスはどれですか？', NULL, '["`admin-web/src/data/quizzes.json`", "`backend/seeds/quizzes.production.json`", "`backend/migrations/006_seed_quizzes.up.sql`", "`docs/quiz-data-workflow.md`"]'::jsonb, 1, 'バックエンドは既定で `seeds/quizzes.production.json` を読み込む。リポジトリ上では `backend/seeds/quizzes.production.json` に相当する。', 'https://vite.dev/guide/assets#the-public-directory', 'unpublished', false),
  (264, 'セクション79: クイズ同期 & 管理画面運用', 'replace モードの意味', '管理画面ボタンの同期仕様が replace モードに変更された後、正しい説明はどれですか？', NULL, '["JSON にある ID だけ追加し、JSON にない ID はそのまま残す", "JSON にある ID は Upsert し、JSON にない ID は DB から削除する", "JSON の内容は無視して常に DB 全件を保持する", "JSON にない ID だけを別テーブルへ移動する"]'::jsonb, 1, 'replace モードでは `quizzes.production.json` を正とみなし、存在しない ID を削除することで DB と JSON の内容を一致させる。', 'https://vite.dev/guide/assets#the-public-directory', 'unpublished', false),
  (265, 'セクション79: クイズ同期 & 管理画面運用', '空配列での replace 同期', '`quizzes.production.json` の中身が次のように正しい JSON で、`quizzes` 配列が空だった場合の挙動はどれですか？

`{"quizzes": []}`', NULL, '["422 で拒否され、DB は変更されない", "`quizzes` テーブルが全件削除される", "最新 1 件だけが残る", "`schema_migrations` テーブルだけが削除される"]'::jsonb, 1, 'replace モードでは JSON を正として扱うため、`quizzes` 配列が空なら DB 側の `quizzes` テーブルも空に同期される。', 'https://vite.dev/guide/assets#the-public-directory', 'unpublished', false),
  (266, 'セクション79: クイズ同期 & 管理画面運用', '同期時の status / push の扱い', '管理画面ボタンの同期 API が `status` と `push_enabled` を扱う方法として正しいものはどれですか？', NULL, '["既存行でも毎回 `published` / `true` に上書きする", "既存行では保持し、新規行だけ `unpublished` / `false` で挿入する", "常に JSON から `status` と `push_enabled` を読む", "同期時には `status` と `push_enabled` を NULL にする"]'::jsonb, 1, 'production seed JSON には `status` と `push_enabled` を持たせていないため、既存行では現在値を保持し、新規行のみ既定値 `unpublished` / `false` で作成する。', 'https://vite.dev/guide/assets#the-public-directory', 'unpublished', false),
  (267, 'セクション79: クイズ同期 & 管理画面運用', '422 エラーの意味', '管理画面の同期 API が 422 を返すケースとして最も適切なものはどれですか？', NULL, '["JWT が期限切れで再ログインが必要なとき", "`quizzes.production.json` の JSON 構文が壊れている、またはクイズデータが不正なとき", "API サーバーが起動していないとき", "削除モーダルのスクロールが足りないとき"]'::jsonb, 1, '422 は入力データが妥当でないことを表す。今回の実装では、壊れた JSON、重複 ID、必須項目不足、`correctAnswerIndex` の範囲外などが該当する。', 'https://vite.dev/guide/assets#the-public-directory', 'unpublished', false),
  (268, 'セクション79: クイズ同期 & 管理画面運用', '削除モーダルのスクロール修正', '削除モーダルで長い内容を安全に表示するために行った修正として正しいものはどれですか？', NULL, '["モーダルを `position: static` に変更した", "オーバーレイに `overflow-y-auto`、ダイアログ本文に `max-height` と内部スクロールを追加した", "コードブロックをすべて削除した", "モーダルを別ページ遷移に置き換えた"]'::jsonb, 1, 'モーダル本体を viewport 高さ内に収め、本文領域だけをスクロール可能にすることで、長い問題文やコードを含んでも操作ボタンが見失われにくくなった。', 'https://vite.dev/guide/assets#the-public-directory', 'unpublished', false),
  (269, 'セクション80: Docker & ファイルパーミッション', 'コンテナ内で生成されたファイルの削除', 'バインドマウント（`- .:/app`）でホストとコンテナがファイルを共有している環境で、コンテナ内の root プロセスが生成した migration ファイルを削除する際に `docker compose exec api rm ...` を使用しました。ホスト側から直接 `rm` せずコンテナ内で実行した理由として正しいものはどれですか？', NULL, '["バインドマウントは読み取り専用なのでホスト側からは削除できない", "コンテナ内のプロセス（root）が作成したファイルはホスト側でも root 所有になるため、一般ユーザーでは削除できない", "コンテナ内のファイルシステムはホストとは独立しているため、ホスト側からは見えない", "golang-migrate がファイルをロックしているため、同じプロセス空間から削除する必要がある"]'::jsonb, 1, 'コンテナ内で migrate create を実行したプロセスは root で動いているため、生成されたファイルはホスト側でも root:root の所有になる。一般ユーザー（uid=1000）ではホスト側から rm しても Permission denied になる。docker compose exec api rm ... ならコンテナ内で root として実行されるので削除できる。ホスト側から削除するなら sudo rm が必要。', 'https://docs.docker.com/engine/storage/bind-mounts/', 'unpublished', false),
  (270, 'セクション81: Python 辞書と型システム', 'dict.get() の役割', '以下のコードで `data.get(''quizzes'')` を使っている理由として正しいものはどれですか？

```python
data = json.load(file)
quizzes = data.get(''quizzes'')
if not isinstance(quizzes, list):
    raise ValueError("JSON must contain a ''quizzes'' array.")
```', NULL, '["data はリスト型なので、インデックスではなくキーでアクセスするために get() を使っている", "get() はクラスメソッドであり、インスタンスからは呼べないため特別な構文が必要", "キーが存在しない場合に KeyError ではなく None を返すため、次の isinstance チェックで丁寧にエラーメッセージを出せる", "get() は辞書を深いコピーして返すため、元の data を壊さない"]'::jsonb, 2, 'dict.get() はキーが存在しなければ None を返す辞書のインスタンスメソッド。data[''quizzes''] だとキーがない場合に KeyError が発生するが、get() なら None が返り、次の isinstance チェックで ValueError として分かりやすいメッセージを出せる。', 'https://docs.python.org/3/library/stdtypes.html#mapping-types-dict', 'unpublished', false),
  (271, 'セクション81: Python 辞書と型システム', 'json.load() の戻り値の型', '`json.load()` の戻り値について正しい説明はどれですか？

```python
data = json.load(file)
data.get(''quizzes'')
```', NULL, '["静的型は dict[str, Any] であり、常に辞書が返ることが型レベルで保証されている", "静的型は Any であり型は確定していないが、実行時に辞書を含む JSON を読めば動的に dict 型になる", "戻り値は str 型であり、json.loads() で再度パースする必要がある", "静的型は object であり、.get() を呼ぶにはキャストが必須"]'::jsonb, 1, 'json.load() の戻り値の型定義は Any である。静的には型が確定しないが、実行時に JSON の内容に応じて dict や list などの Python オブジェクトになる。そのため isinstance() による実行時の型チェックが重要な役割を果たす。', 'https://docs.python.org/3/library/stdtypes.html#mapping-types-dict', 'unpublished', false),
  (272, 'セクション81: Python 辞書と型システム', 'isinstance による実行時型チェック', '以下のコードで `isinstance(quizzes, list)` によるチェックが重要な理由として最も適切なものはどれですか？

```python
data: Any = json.load(file)
quizzes = data.get(''quizzes'')
if not isinstance(quizzes, list):
    raise ValueError("JSON must contain a ''quizzes'' array.")
```', NULL, '["Python の型注釈は実行時に型を強制するため、isinstance は冗長だが可読性のために書いている", "json.load() の戻り値は Any で静的に型が確定せず、型注釈だけでは実行時の保証がないため、isinstance で実際の型を検証する必要がある", "isinstance は型注釈を自動的に更新するために使われている", "data.get() が常にリストを返すことを確認するための形式的なチェック"]'::jsonb, 1, 'Python の型注釈はあくまで開発者とエディタへのヒントであり、実行時には型を強制しない。json.load() が返す Any 型のデータが期待通りのリストであることを保証するには、isinstance() による実行時チェックが不可欠。これにより不正な JSON に対して分かりやすい ValueError を返せる。', 'https://docs.python.org/3/library/stdtypes.html#mapping-types-dict', 'unpublished', false),
  (273, 'セクション82: os.fspath と __fspath__ プロトコル', 'os.fspath() が内部で呼ぶもの', '以下のコードで `os.fspath(p)` は内部で何を呼びますか？

```python
from pathlib import Path
import os

p = Path(''data/quizzes.json'')
result = os.fspath(p)
```', NULL, '["p.__str__() を呼んで文字列に変換する", "p.__fspath__() を呼んでパス文字列を取得する", "p.__repr__() を呼んでオブジェクトの表現を返す", "p.__path__() を呼んでファイルの絶対パスを返す"]'::jsonb, 1, 'os.fspath() は引数が str/bytes ならそのまま返し、それ以外の場合は __fspath__() メソッドを呼ぶ。Path は __fspath__() を定義しているため、os.fspath(p) は p.__fspath__() を呼んでパス文字列を返す。', 'https://docs.python.org/3/library/os.html#os.fspath', 'unpublished', false),
  (274, 'セクション82: os.fspath と __fspath__ プロトコル', 'os.fspath() の引数ごとの動作', '以下の3つの `os.fspath()` 呼び出しについて、動作の組み合わせとして正しいものはどれですか？

```python
os.fspath(''file.txt'')    # (A)
os.fspath(b''file.txt'')   # (B)
os.fspath(123)           # (C)
```', NULL, '["(A) ''file.txt'' (B) TypeError (C) TypeError", "(A) ''file.txt'' (B) ''file.txt'' (C) ''123''", "(A) ''file.txt'' (B) b''file.txt'' (C) TypeError", "(A) b''file.txt'' (B) b''file.txt'' (C) TypeError"]'::jsonb, 2, 'os.fspath() は str と bytes はそのまま通す。__fspath__() も定義していない型（int など）には TypeError を発生させる。str → str、bytes → bytes でそれぞれ型を保持して返す。', 'https://docs.python.org/3/library/os.html#os.fspath', 'unpublished', false),
  (275, 'セクション82: os.fspath と __fspath__ プロトコル', 'os.fspath() が存在する理由', '`os.fspath()` と `__fspath__` プロトコルが Python に用意されている理由として最も適切なものはどれですか？', NULL, '["Path オブジェクトを JSON にシリアライズするため", "ファイルの存在確認を行うため", "str, bytes, Path など様々なパス表現を統一的に str/bytes に変換し、低レベル関数との互換性を確保するため", "ファイルパスをバリデーションしてセキュリティを担保するため"]'::jsonb, 2, 'os.open() など C 由来の低レベル関数は文字列しか受け付けない。Path オブジェクトなど様々なパス表現を安全に str/bytes に変換する共通インターフェースとして os.fspath() と __fspath__ プロトコルが用意されている。', 'https://docs.python.org/3/library/os.html#os.fspath', 'unpublished', false),
  (276, 'セクション82: os.fspath と __fspath__ プロトコル', 'PathLike による型安全なパス表現', '以下のコードはすべて `open()` に渡せてしまいます。

```python
open(str(None))   # → open(''None'')
open(str(123))    # → open(''123'')
open(''John'')      # → ''John'' というファイルが作られる
```

`__fspath__` プロトコル（PEP 519）がこの問題に対して提供する解決策として最も適切なものはどれですか？', NULL, '["open() が受け付ける文字列をファイル名として有効なもののみに制限する", "str 型を廃止し、すべてのパスを Path オブジェクトで表現することを強制する", "PathLike を実装したオブジェクトだけが「パスである」と明示的に宣言でき、ただの文字列とパスを型レベルで区別できるようにする", "open() に渡す前にファイルの存在確認を自動で行い、存在しなければ TypeError を発生させる"]'::jsonb, 2, 'str 型はあらゆる文字列を表すため、パスとして意図していない値でも open() に渡せてしまう。PEP 519 の __fspath__ プロトコルにより、PathLike を実装したオブジェクトだけが「これはパスである」と型レベルで宣言できる。後方互換のため str/bytes も引き続き受け付けるが、新しいコードでは Path を使うことで意図を明示できる。', 'https://docs.python.org/3/library/os.html#os.fspath', 'unpublished', false),
  (277, 'セクション83: pathlib と作業ディレクトリ', 'Path.cwd() の意味', '以下のコードが返すものとして正しいものはどれですか？

```python
from pathlib import Path

current = Path.cwd()
```', NULL, '["スクリプトファイル自身が置かれているディレクトリ（__file__ と同じ）", "プロセスの現在の作業ディレクトリ（Current Working Directory）— コマンドを実行した場所", "ユーザーのホームディレクトリ", "一時ファイル用のディレクトリ（/tmp など）"]'::jsonb, 1, 'Path.cwd() は Current Working Directory の略で、プロセスが現在の作業ディレクトリとしているパスを返す。これはコマンドを実行した場所に依存するため、同じスクリプトでも実行ディレクトリが変わると結果が変わる。スクリプト自身の場所が欲しい場合は Path(__file__).parent を使う。', 'https://docs.python.org/3/library/pathlib.html', 'unpublished', false),
  (278, 'セクション83: pathlib と作業ディレクトリ', 'Path.cwd() と Path(__file__).parent の違い', '以下のコードを `/home/user/project` で `python3 scripts/tool.py` として実行した場合、`a` と `b` の値として正しいものはどれですか？

```python
# /home/user/project/scripts/tool.py
from pathlib import Path

a = Path.cwd()
b = Path(__file__).parent
```', NULL, '["a = /home/user/project, b = /home/user/project/scripts", "a = /home/user/project/scripts, b = /home/user/project", "a も b も /home/user/project/scripts", "a も b も /home/user/project"]'::jsonb, 0, 'Path.cwd() はコマンドを実行したディレクトリ（/home/user/project）を返す。Path(__file__).parent はスクリプトファイル自身の置き場所（/home/user/project/scripts）を返す。両者は実行位置とスクリプト位置が違うと異なる値になるため、用途に応じて使い分ける必要がある。', 'https://docs.python.org/3/library/pathlib.html', 'unpublished', false),
  (279, 'セクション84: Python isinstance と型チェック', 'isinstance() の基本動作', 'Python の組み込み関数 `isinstance()` の説明として、最も正しいものはどれですか？

```python
class Animal: pass
class Dog(Animal): pass

d = Dog()
print(isinstance(d, Animal))  # ?
```', NULL, '["引数のオブジェクトが指定したクラス、またはそのサブクラスのインスタンスである場合に True を返す", "指定したクラスと完全に同一の型の場合のみ True を返し、サブクラスは常に False になる", "オブジェクトが指定した属性（attribute）を持っているかを判定する関数である", "継承関係を無視し、クラス名の文字列を比較して一致するかを返す"]'::jsonb, 0, 'isinstance(obj, cls) は、obj が cls のインスタンス、または cls のサブクラスのインスタンスであれば True を返す組み込み関数。継承階層を考慮するため、厳密な型一致のみを判定する type(obj) is cls と異なり、派生クラスも含めた柔軟な型チェックが可能になる。上の例では Dog が Animal のサブクラスなので True を返す。', 'https://docs.python.org/3/library/functions.html#isinstance', 'unpublished', false),
  (280, 'セクション85: JSON と Python の型マッピング', 'json.load() が返す型', '以下の JSON を `json.load()` で読み込んだとき、`data` と `data[''items'']` の Python での型として正しい組み合わせはどれですか？

```json
{
  "items": [1, 2, 3]
}
```

```python
import json
with open(''data.json'') as f:
    data = json.load(f)
```', NULL, '["data は list、data[''items''] は dict", "data は dict、data[''items''] は list", "data は tuple、data[''items''] は set", "data も data[''items''] も str"]'::jsonb, 1, 'Python 標準ライブラリの json モジュールは、JSON の object を dict に、JSON の array を list に変換する。したがって最外側の `{...}` は dict、その値 `[1, 2, 3]` は list になる。他にも JSON の string は str、number は int/float、true/false は True/False、null は None に対応する。', 'https://docs.python.org/3/library/json.html#json-to-py-table', 'unpublished', false),
  (281, 'セクション84: Python isinstance と型チェック', 'isinstance() と type() の違い・classinfo タプル', '以下のコードの出力として正しいものはどれですか？

```python
class Animal: pass
class Dog(Animal): pass

d = Dog()

a = isinstance(d, Animal)
b = type(d) is Animal
c = isinstance(d, (int, Animal))
```', NULL, '["a=True,  b=True,  c=True", "a=True,  b=False, c=True", "a=False, b=False, c=False", "a=True,  b=True,  c=False"]'::jsonb, 1, 'isinstance() は継承階層を考慮し、d が Animal のサブクラス Dog のインスタンスであるため True。一方 type(d) is Animal は厳密な型一致のみを見るため、実際の型 Dog とは一致せず False。isinstance の第2引数にタプルを渡すと、いずれかに該当すれば True を返すため、(int, Animal) でも Animal に該当して True となる。通常の型チェックでは継承を考慮できる isinstance が推奨される。', 'https://docs.python.org/3/library/functions.html#isinstance', 'unpublished', false),
  (282, 'セクション86: Python の None 判定と truthy / falsy', '`if x is not None:` と `if x:` の違い', '以下のコードの A, B の出力結果として正しい組み合わせはどれですか？

```python
input_path = ""

if input_path is not None:
    print("A")

if input_path:
    print("B")
```', NULL, '["A も B も出力される", "A のみ出力される", "B のみ出力される", "どちらも出力されない"]'::jsonb, 1, '`is not None` は値が None かどうかだけを厳密に判定する。空文字列 `""` は None ではないので A は出力される。一方 `if input_path:` は truthy / falsy 判定で、空文字・0・空リスト・None などはすべて falsy として扱われるため B は出力されない。CLI の `--input` のように「指定されたかどうか」を判定したい場面では、空文字を「未指定」と誤判定しないよう `is not None` を使うのが安全。PEP 8 でも None との比較は `is` / `is not` を使うことが推奨されている。', 'https://docs.python.org/3/library/stdtypes.html#truth-value-testing', 'unpublished', false),
  (283, 'セクション87: Python 標準ライブラリ select モジュール', 'select モジュールの役割とプラットフォーム差', 'Python 公式ドキュメントの次の記述について、内容の説明として最も適切なものはどれですか？

> This module provides access to the select() and poll() functions available in most operating systems, devpoll() available on Solaris and derivatives, epoll() available on Linux 2.5+ and kqueue() available on most BSD. Note that on Windows, it only works for sockets; on other operating systems, it also works for other file types (in particular, on Unix, it works on pipes). It cannot be used on regular files to determine whether a file has grown since it was last read.', NULL, '["OS が提供する I/O 多重化プリミティブ (select / poll / epoll / kqueue / devpoll) への薄いラッパーで、Windows ではソケットのみ、Unix ではパイプなど他のファイル種別にも使えるが、通常ファイルに対して「前回読み込み以降に拡張されたか」を知る用途には使えない", "すべての OS において、通常ファイルを含むあらゆるファイル種別に対して使用でき、ファイルが追記されたかどうかを監視するために利用できる", "epoll と kqueue は Python が独自実装したクロスプラットフォームな API であり、Windows でもソケット以外のファイルを監視できる", "select モジュールは非同期 I/O ライブラリ asyncio の代替であり、通常ファイルのサイズ変化を検知するために設計されている"]'::jsonb, 0, 'select モジュールは OS が提供する I/O 多重化の仕組みへのアクセスを提供するもので、具体的には POSIX 系の `select()` / `poll()`、Solaris 系の `devpoll()`、Linux 2.5+ の `epoll()`、BSD 系の `kqueue()` をラップする。Windows では実装の制約からソケットに対してのみ動作し、Unix 系ではパイプなどソケット以外のファイル種別にも使える。重要な制限として、通常ファイル (regular files) は常に「読み書き可能」として扱われるため、`select` 系 API で監視しても tail -f 的な「最後に読んだ位置からファイルが増えたかどうか」を知る用途には使えない。その用途には inotify や kqueue の EVFILT_VNODE、あるいは watchdog のようなファイルシステムイベント監視が必要になる。', 'https://docs.python.org/3/library/select.html#select.select', 'unpublished', false),
  (284, 'セクション88: Unix 系 OS と BSD', 'BSD とは何か', 'Python 公式ドキュメントの select モジュールの説明に「kqueue() available on most BSD」という記述があります。ここでいう **BSD** の説明として最も適切なものはどれですか？', NULL, '["Microsoft が開発した Windows 向けのネットワークスタックの略称で、主にソケット通信 API を指す", "カリフォルニア大学バークレー校 (UCB) で開発された Unix 派生系 OS、およびそこから派生した FreeBSD / OpenBSD / NetBSD / macOS (Darwin) などの Unix 系 OS 群の総称。ソケット API や TCP/IP 実装の起源としても知られ、緩いライセンス (BSD ライセンス) でも有名", "Linux カーネル 2.5 以降で導入された、epoll の後継となる I/O 多重化 API の規格名", "POSIX 標準の正式名称で、すべての Unix 系 OS が従うべき API 仕様を定めた国際規格"]'::jsonb, 1, '**BSD** は **Berkeley Software Distribution** の略で、1970〜80 年代にカリフォルニア大学バークレー校が AT&T Unix をベースに独自拡張を加えて配布した Unix 派生系 OS、およびそこから枝分かれした一連の Unix 系 OS (FreeBSD / OpenBSD / NetBSD / DragonFly BSD など) の総称。現代の TCP/IP 実装や BSD ソケット API、vi、C シェルなどは BSD 由来であり、macOS / iOS のカーネル (Darwin) も FreeBSD 由来のコードを多数取り込んでいる。ライセンスも緩い「BSD ライセンス」として知られる。Python ドキュメントの `kqueue() available on most BSD` は、FreeBSD を起点に多くの BSD 系 OS (macOS を含む) で使える I/O 多重化機構を指しており、Linux の epoll に相当する。', 'https://man7.org/linux/man-pages/', 'unpublished', false),
  (285, 'セクション89: Python select.select の仕様', 'select.select の戻り値・timeout・Windows の制約', 'Python 公式ドキュメントの `select.select(rlist, wlist, xlist, timeout=None)` の説明として **誤っているもの** はどれですか？', NULL, '["戻り値は (rlist_ready, wlist_ready, xlist_ready) の 3 つのリストで、それぞれ引数で渡したイテラブルのサブセット (準備完了したもののみ) になる。タイムアウトした場合は 3 つとも空リストになる", "timeout に None を渡すと、少なくとも 1 つの fd が ready になるまでブロックする。0 を渡すとブロックせずに現在の状態を返すポーリングになる", "Windows では通常のファイルオブジェクトは渡せず、ソケットのみ受け付ける (内部で WinSock の select を使うため、WinSock 由来でない fd は扱えない)", "Python 3.5 以降、シグナルで select がブロック中断された場合、常に InterruptedError が送出されるようになり、呼び出し側で必ずリトライ処理を書く必要がある"]'::jsonb, 3, 'Python 3.5 以降は **PEP 475** によって逆の挙動に変わっており、**シグナル (EINTR) で中断された場合は残り時間を再計算して自動的にリトライする** ようになった (シグナルハンドラ自身が Python 例外を送出した場合を除く)。これにより呼び出し側で EINTR をハンドリングする定型コードが不要になった、というのがポイント。他の選択肢は正しい: (1) 戻り値は引数のサブセットで、タイムアウト時は 3 つとも空リスト。(2) `timeout=None` は無限ブロック、`0` はノンブロッキングのポーリング。(3) Windows では WinSock 制約によりソケットのみ対応し、ファイルオブジェクトは渡せない。また引数は「fd の整数」か「`fileno()` を持つオブジェクト」を受け取り、3 つとも空の iterable を渡すのは Unix のみ許容される (Windows 不可) という点も覚えておくとよい。', 'https://docs.python.org/3/library/select.html#select.select', 'unpublished', false),
  (286, 'セクション90: 英文読解 (Python チュートリアル)', '構文エラーと例外の導入文を読む', 'Python 公式チュートリアル「Errors and Exceptions」冒頭の次の英文の趣旨として最も適切なものはどれですか？

> Until now error messages haven''t been more than mentioned, but if you have tried out the examples you have probably seen some. There are (at least) two distinguishable kinds of errors: syntax errors and exceptions.', NULL, '["これまではエラーメッセージについて簡単に触れる程度だったが、例を実際に試していればいくつか目にしているはずだ。エラーには少なくとも 2 種類、区別できるものがある: 構文エラーと例外だ", "これまでエラーメッセージについては一切説明してこなかったので、読者はまだ一度もエラーを見ていないはずだ。エラーは構文エラーと例外の 2 つだけに厳密に分類される", "これまで紹介した例はすべてエラーなしで動作するよう設計されている。エラーには構文エラーと例外があるが、両者に実質的な違いはない", "これから紹介する例を実行するとかならずエラーが出る。エラーは構文エラー・例外・警告の 3 種類に正確に分けられる"]'::jsonb, 0, '原文のポイントは 3 つ。(a) `haven''t been more than mentioned` = 「言及される以上のことはされていない」= これまでは軽く触れる程度だった、という含意。(b) `if you have tried out the examples you have probably seen some` = 「例を試していたならおそらくいくつか (エラーを) 見たことがあるはず」という読者への呼びかけ。(c) `(at least) two distinguishable kinds of errors: syntax errors and exceptions` = 「少なくとも区別できる 2 種類のエラーがある: 構文エラーと例外」で、`at least` は「他にも分類はあり得るが、大きく分けて最低でも 2 種類」というニュアンス。したがって選択肢 1 が正解。選択肢 2 は `haven''t been more than mentioned` を「全く説明してこなかった」と誤読し、かつ `at least` を無視して「2 つだけに厳密分類」と言っている点が誤り。3 は「両者に違いはない」が原文と逆 (原文は `distinguishable = 区別できる` と明言)。4 は「警告を含む 3 種類」という原文にない情報を追加しており誤り。', 'https://docs.python.org/3/', 'unpublished', false),
  (287, 'セクション90: 英文読解 (Python チュートリアル)', '構文エラー (parsing error) の定義文を読む', 'Python 公式チュートリアル「Errors and Exceptions」の次の英文の意味として最も適切なものはどれですか？

> Syntax errors, also known as parsing errors, are perhaps the most common kind of complaint you get while you are still learning Python.', NULL, '["構文エラー (syntax errors) はパースエラー (parsing errors) とも呼ばれ、Python を学び始めたばかりの頃に遭遇する「文句を言われる」タイプのエラーとしては、おそらく最もよく見かけるものだ", "構文エラーとパースエラーは別物であり、Python 学習者はまずパースエラーに遭遇し、その後に構文エラーを学ぶことになる", "構文エラーは Python を十分に習熟した上級者だけが遭遇するまれなエラーで、初心者にはほとんど見る機会がない", "構文エラーは常にランタイム (実行時) に発生するエラーであり、プログラムの実行を途中まで進めた後にはじめて検出される"]'::jsonb, 0, 'ポイントは (a) `also known as parsing errors` = 「パースエラーとも呼ばれる」で、構文エラーとパースエラーは **同じもの** (同義) であること。(b) `perhaps the most common kind of complaint you get` の `complaint` はここではインタプリタから出される「苦情 = エラーメッセージ」の比喩で、「最もよくある種類のエラー」と解釈するのが自然。(c) `while you are still learning Python` = 「Python をまだ学んでいる間に」= 学習初期に特によく見る、というニュアンス。よって選択肢 1 が正解。選択肢 2 は「別物」が誤り (`also known as` は同義)。3 は「上級者のみ」が原文の `while you are still learning` と真逆。4 は「ランタイムに発生」が誤りで、構文エラーは **コードを実行する前のパース (字句・構文解析) 段階** で検出される (これに対して例外は実行時に発生する、というのがチュートリアル全体のコントラスト)。', 'https://docs.python.org/3/', 'unpublished', false),
  (288, 'セクション91: Python SyntaxError の見分け方', 'while True print(...) が出すエラーの種類', '次の Python インタプリタの出力について、このエラーはどの種類のエラーに該当しますか？

```text
>>> while True print(''Hello world'')
  File "<stdin>", line 1
    while True print(''Hello world'')
               ^^^^^
SyntaxError: invalid syntax
```', NULL, '["構文エラー (SyntaxError / parsing error)。`while` 文のヘッダの末尾に必要なコロン `:` が欠けており、パース段階で検出されるため、print は一度も実行されない", "実行時例外 (RuntimeError)。while ループが無限に回ってしまうことをインタプリタが検出して停止させた結果出力されたエラー", "名前エラー (NameError)。`print` という関数名がスコープ内で見つからないことによるエラー", "型エラー (TypeError)。`True` と文字列を比較しようとして型の不一致が起きた"]'::jsonb, 0, 'このエラーは **SyntaxError (構文エラー / parsing error)** で、原因は `while True` の直後にコロン `:` が欠けている点。正しくは `while True: print(''Hello world'')` と書く必要がある。パーサがトークンを読んでいる途中で「`while` 文のヘッダが閉じられていない」と判断し、最初に異常を検出した位置 (ここでは `print`) に `^^^^^` を当ててエラーメッセージを表示する。構文エラーはコード実行前の **パース (字句・構文解析) 段階** で検出されるため、`print(''Hello world'')` は一度も実行されない。選択肢 2 (RuntimeError) は誤り: そもそも実行に到達していないし、Python は無限ループそのものをエラーにしない。3 (NameError) は誤り: `print` は組み込み関数として常に参照可能で、エラーメッセージも `invalid syntax` であって `name ''print'' is not defined` ではない。4 (TypeError) も誤り: 比較や演算は行われていない。`File "<stdin>", line 1` と `SyntaxError:` というラベル、そして `^^^^^` が当たっている位置から「文法ミス」と読み取るのがポイント。

**補足 (公式チュートリアルより):** 「パーサは問題のある行 (offending line) を繰り返し表示し、**エラーが検出された位置** を指す小さな矢印を表示する。ただし、その位置が必ずしも修正すべき場所とは限らないことに注意。この例ではエラーは `print()` の位置で検出されているが、実際の原因はその直前にコロン `:` が欠けていることにある。」── つまり **矢印 `^` が指すのは「容疑者の位置 (= 検出位置)」であって「真犯人の位置 (= 修正すべき場所)」ではない**。パーサは「ここまでは文法的に OK、ここで急に合わなくなった」という検出時点を示すだけなので、矢印の **1〜数トークン手前** を疑うのが鉄則。

**ファイル名と行番号について:** 出力の先頭に表示される `File "<stdin>", line 1` の **ファイル名と行番号** は、入力がファイル由来だった場合にどこを見ればよいかを教えるためのもの。`<stdin>` は対話モード (REPL) で入力された行であることを示す特別な名称で、`< >` で囲まれているのは「実ファイルではない」というマーカー (同様に `<string>` は `exec()` / `eval()` に渡した文字列、`<module>` はモジュールトップレベルを示す)。スクリプトファイルから実行した場合はここが `File "/path/to/script.py", line 42` のような **実パス + 行番号** になり、エディタで該当行に直接ジャンプできる。矢印 `^` が指す検出位置と、この行番号の組み合わせが「どこから原因を追えばよいか」の出発点になる。', 'https://docs.python.org/3/library/exceptions.html#SyntaxError', 'unpublished', false),
  (289, 'セクション90: 英文読解 (Python チュートリアル)', '例外 (Exceptions) の導入文を読む', 'Python 公式チュートリアル「Errors and Exceptions」の次の英文の趣旨として最も適切なものはどれですか？

> Even if a statement or expression is syntactically correct, it may cause an error when an attempt is made to execute it. Errors detected during execution are called exceptions and are not unconditionally fatal: you will soon learn how to handle them in Python programs. Most exceptions are not handled by programs, however, and result in error messages as shown here.', NULL, '["構文的に正しい文や式でも実行時にエラーになることがあり、そうした実行時検出エラーを「例外」と呼ぶ。例外は必ずしもプログラムを終了させるわけではなく、Python プログラム内で処理 (ハンドリング) できる。ただし多くの例外は処理されず、結果としてエラーメッセージとして表示される", "構文エラーと例外は同じものであり、どちらもパース段階で検出される。Python プログラムでは例外を処理する手段が存在しないため、発生すると常にプログラムが強制終了する", "例外は常にプログラムを致命的 (fatal) に停止させる。したがってエラーメッセージが表示された時点で、プログラム側で復旧することは原理的に不可能である", "構文的に正しいコードは実行時にエラーを出すことが絶対にない。実行時エラーが出た場合は必ず構文の書き直しが必要である"]'::jsonb, 0, '原文のキーとなる 3 つの対比・限定を押さえるのがポイント。(a) `Even if ... syntactically correct, it may cause an error when ... execute it` = 「構文的に正しくても、実行時にエラーになることがある」→ 構文エラーと例外はタイミングが違う (構文エラーはパース時、例外は実行時)。(b) `not unconditionally fatal` = 「無条件に致命的ではない」→ `try` / `except` で捕まえれば回復でき、常にプログラムが死ぬわけではない。(c) `Most exceptions are not handled by programs, however, and result in error messages` = 「ただし実際には多くの例外は処理されず、エラーメッセージとして表示される」→ ハンドリング可能であることと、実際にされているかは別問題。以上から選択肢 1 が正解。選択肢 2 は「構文エラーと例外は同じ」「処理する手段が存在しない」が誤り (むしろチュートリアルは両者を明確に区別し、処理方法を学ぶと予告している)。3 は `not unconditionally fatal` を真逆に解釈しており誤り。4 は「構文的に正しいコードは実行時エラーを出さない」がまさに原文の `Even if ... it may cause an error` と矛盾する。', 'https://docs.python.org/3/', 'unpublished', false),
  (290, 'セクション92: Python 組み込み例外の見分け方', 'Traceback から例外クラスを当てる', 'Python インタプリタで以下の 3 つの式をそれぞれ実行しました。A・B・C の Traceback で発生している例外クラスの組み合わせとして正しいものはどれですか？

```text
# A
>>> 10 * (1/0)
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
???: division by zero

# B
>>> 4 + spam*3
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
???: name ''spam'' is not defined

# C
>>> ''2'' + 2
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
???: can only concatenate str (not "int") to str
```', NULL, '["A: ZeroDivisionError / B: NameError / C: TypeError", "A: ArithmeticError / B: SyntaxError / C: ValueError", "A: ZeroDivisionError / B: TypeError / C: NameError", "A: RuntimeError / B: NameError / C: TypeError"]'::jsonb, 0, 'いずれも **構文は正しいが実行時に失敗する** 典型的な組み込み例外の例。(A) `1/0` は 0 による除算で **`ZeroDivisionError: division by zero`**。`ZeroDivisionError` は `ArithmeticError` のサブクラスなので「より具体的な方」を選ぶのが正解 (選択肢 2 の `ArithmeticError` は間違いではないが出力されるクラス名とは異なる)。(B) `spam` という名前はどのスコープにも定義されていないため **`NameError: name ''spam'' is not defined`**。構文的には識別子として正しいのでパースは通り、**実行時に名前解決で失敗** する点がポイント (SyntaxError ではない)。(C) `str` と `int` を `+` で連結しようとしたため **`TypeError: can only concatenate str (not "int") to str`**。Python は暗黙の型変換をしないので、文字列結合したいなら `''2'' + str(2)`、数値加算したいなら `int(''2'') + 2` のように明示変換が必要。したがって正解は選択肢 1。Traceback の最終行 `例外クラス名: メッセージ` の形式を覚えておけば、メッセージ部分から例外クラスを逆引きできる。', 'https://docs.python.org/3/library/exceptions.html', 'unpublished', false),
  (291, 'セクション92: Python 組み込み例外の見分け方', 'Traceback 最終行のフォーマット', 'Python 公式チュートリアルには「The last line of the error message indicates what happened.」という記述があります。この **Traceback の最終行** が「何が起こったか」を示す際の **フォーマット (書式)** として正しいものはどれですか？

例:
```text
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
ZeroDivisionError: division by zero
```', NULL, '["`例外クラス名: エラーメッセージ` の形式で 1 行にまとめて出力される (例: `ZeroDivisionError: division by zero`)。クラス名とメッセージはコロン + 半角スペースで区切られる", "`File \"<ファイル名>\", line <行番号>` の形式で、どのファイルの何行目でエラーが起きたかのみが出力される", "`Traceback (most recent call last):` の形式で、スタックの一番上 (最も古い呼び出し) のみを示す", "JSON 形式 `{\"type\": \"ZeroDivisionError\", \"message\": \"division by zero\"}` で機械可読な構造化データとして出力される"]'::jsonb, 0, 'Python の Traceback の最終行は **`例外クラス名: エラーメッセージ`** という書式で、クラス名とメッセージは `: ` (コロン + 半角スペース) で区切られる。例えば `ZeroDivisionError: division by zero`、`NameError: name ''spam'' is not defined`、`TypeError: can only concatenate str (not "int") to str` など。この一行を読めば「**どの種類の例外が** (クラス名) **なぜ起きたか** (メッセージ)」がほぼ分かるように設計されている。選択肢 2 の `File "...", line N` は **スタックフレーム行** (最終行より上に出る、どこで起きたかを示す行) であって、「何が起こったか」を示す最終行ではない。3 の `Traceback (most recent call last):` は **ヘッダ行** (最初の行) で、これから呼び出し履歴を出すという宣言にすぎない。4 の JSON 形式は誤り ── Python 標準の Traceback はプレーンテキストで出力される (構造化ログが欲しい場合は `traceback` モジュールや `logging` の設定で自分で整形する必要がある)。Traceback を読むときは **「一番下の行 = What happened」「その上のフレーム = Where it happened」** と覚えておくとよい。', 'https://docs.python.org/3/library/exceptions.html', 'unpublished', false),
  (292, 'セクション92: Python 組み込み例外の見分け方', '「何を間違えたか」で Python 組み込み例外を分類する', '次の A〜D のコードを実行したとき、それぞれ発生する **組み込み例外** の組み合わせとして最も適切なものはどれですか？「**何を間違えたか**」というメンタルモデル (名前 / 型 / 値 / 位置 / リソース) で考えてください。

```python
# A: 存在しない dict キーにアクセス
d = {"x": 1}
_ = d["y"]

# B: 型が合わない演算 (None に対してメソッド呼び出し)
obj = None
obj.lower()

# C: 型は合うが値が不正な変換
_ = int("abc")

# D: list の範囲外インデックスアクセス
xs = [1, 2, 3]
_ = xs[10]
```', NULL, '["A: KeyError (位置/キーの間違い) / B: AttributeError (名前・属性の間違い) / C: ValueError (値の間違い) / D: IndexError (位置の間違い)", "A: IndexError / B: TypeError / C: TypeError / D: KeyError", "A: NameError / B: NameError / C: SyntaxError / D: ZeroDivisionError", "A: KeyError / B: TypeError / C: ValueError / D: NameError"]'::jsonb, 0, '「**何を間違えたか**」で覚えると迷いにくい: **名前 (identifier)** を間違えた → `NameError` / `AttributeError` / `ImportError`、**型 (type)** を間違えた → `TypeError`、**値 (value)** を間違えた → `ValueError` / `ZeroDivisionError`、**位置 (index/key)** を間違えた → `IndexError` (list) / `KeyError` (dict)、**リソース** が無い → `FileNotFoundError` など。

本問の対応は以下のとおり。
(A) `d["y"]` — dict に存在しないキーでアクセス → **`KeyError: ''y''`** (「位置/キー」の間違い。dict はハッシュでキーを引くため IndexError ではない)。
(B) `None.lower()` — `None` は `lower` 属性を持たないので **`AttributeError: ''NoneType'' object has no attribute ''lower''`** (「名前・属性」の間違い。**`TypeError` ではない** 点に注意 ── Python では「属性アクセスの失敗」は `AttributeError` に分類される)。
(C) `int("abc")` — 型 (str) は `int()` が受け付けるが、その **値が整数として不正** → **`ValueError: invalid literal for int() with base 10: ''abc''`** (「値」の間違い。型は合っている)。
(D) `xs[10]` — list の長さを超えるインデックス → **`IndexError: list index out of range`** (「位置」の間違い)。

したがって正解は選択肢 1。選択肢 2 は A と D が dict/list で入れ替わっており誤り。3 は全く見当違い。4 は D を `NameError` とする点が誤り (`xs` はちゃんと定義されている)。なお (B) を `TypeError` としがちな誤答の典型例: Python は **属性ルックアップの失敗を `AttributeError`** に分類し、引数の型ミスマッチや演算子対応不可 (`''a'' + 1` など) を **`TypeError`** に分類するという使い分けがある。', 'https://docs.python.org/3/library/exceptions.html', 'unpublished', false),
  (293, 'セクション93: Python 例外クラス階層', 'Exception hierarchy — 親クラスはどれか', 'Python 公式ドキュメント `Built-in exceptions` の `Exception hierarchy` には、組み込み例外の継承関係が以下のように記載されています (抜粋)。

```text
BaseException
 ├── BaseExceptionGroup
 ├── GeneratorExit
 ├── KeyboardInterrupt
 ├── SystemExit
 └── Exception
      ├── ArithmeticError
      │    ├── FloatingPointError
      │    ├── OverflowError
      │    └── ZeroDivisionError
      ├── AssertionError
      ├── AttributeError
      ├── LookupError
      │    ├── IndexError
      │    └── KeyError
      ├── NameError
      │    └── UnboundLocalError
      ├── OSError
      │    ├── FileNotFoundError
      │    ├── PermissionError
      │    └── TimeoutError
      ├── TypeError
      ├── ValueError
      │    └── UnicodeError
      └── ...
```

この階層図に基づく記述として **正しいもの** はどれですか？', NULL, '["`except LookupError:` を書くと、`IndexError` と `KeyError` の両方を一括して捕捉できる。また `except Exception:` は `KeyboardInterrupt` と `SystemExit` を **捕捉しない** (これらは `Exception` ではなく `BaseException` の直下にあるため)", "`KeyboardInterrupt` と `SystemExit` は `Exception` のサブクラスなので、`except Exception:` で意図せず捕捉されてしまう。これを避けるには必ず `except BaseException:` を使う必要がある", "`ZeroDivisionError` は `Exception` の直接の子クラスであり、`ArithmeticError` とは無関係である。したがって `except ArithmeticError:` で `ZeroDivisionError` を捕捉することはできない", "`FileNotFoundError` は `Exception` の直接の子クラスであり、`except OSError:` では捕捉できない"]'::jsonb, 0, '公式の `Exception hierarchy` で継承関係を正しく読み取れば答えは選択肢 1。

(1) **正しい**: `IndexError` と `KeyError` はいずれも **`LookupError` のサブクラス** として記載されているため、`except LookupError:` で両方まとめて捕捉できる。また `KeyboardInterrupt` / `SystemExit` / `GeneratorExit` / `BaseExceptionGroup` は **`Exception` ではなく `BaseException` の直下** にあるため、`except Exception:` では捕捉されない ── これが「通常は `except Exception:` を使う」とされる根拠 (Ctrl+C や `sys.exit()` を誤って握りつぶさないため)。

(2) **誤り**: `KeyboardInterrupt` と `SystemExit` は `Exception` の子ではなく **`BaseException` 直下**。したがって `except Exception:` では **捕捉されない** (これは安全な挙動)。`except BaseException:` を使う必要があるのはむしろ **避けるべきケース**。

(3) **誤り**: 階層図の通り `ZeroDivisionError` は **`ArithmeticError` のサブクラス** (`ArithmeticError ├── ZeroDivisionError`)。`except ArithmeticError:` で `ZeroDivisionError` / `OverflowError` / `FloatingPointError` をまとめて捕捉できる。

(4) **誤り**: 階層図の通り `FileNotFoundError` は **`OSError` のサブクラス**。`except OSError:` で `FileNotFoundError` / `PermissionError` / `TimeoutError` などをまとめて捕捉できる (Python 3.3 以降、旧 `IOError` / `EnvironmentError` は `OSError` に統合された)。

**実務ポイント**: 「どのサブクラスが来ても対応が同じ」なら親 (`OSError`, `LookupError`, `ArithmeticError`) で一括 catch、対応を分けたいなら具体例外で個別 catch、プロセス境界のセーフティネットでは `except Exception:` を使い、`except BaseException:` や裸の `except:` は避ける、が鉄則。', 'https://docs.python.org/3/library/exceptions.html#exception-hierarchy', 'unpublished', false),
  (294, 'セクション94: Python try / except サンプル読解', 'except (ValueError, TypeError) as e の意味', '次のコード片にある `except (ValueError, TypeError) as e:` の説明として最も正しいものはどれですか？

```python
try:
    x = int(input("Please enter a number: "))
    break
except (ValueError, TypeError) as e:
    print("Oops! That was no valid number. Try again...")
```', 'try:
    x = int(input("Please enter a number: "))
    break
except (ValueError, TypeError) as e:
    print("Oops! That was no valid number. Try again...")', '["`ValueError` または `TypeError` のどちらが起きても同じ except 節で捕捉し、例外オブジェクトは `e` に束縛される", "`ValueError` と `TypeError` が同時に 2 つ起きた場合だけ except 節が実行される", "タプルに入れた例外は継承関係がないと書けない", "`as e` を書くと例外は握りつぶされず、必ず自動で再送出される"]'::jsonb, 0, 'except に例外クラスのタプルを書くと、そのいずれかにマッチした場合に同じハンドラが実行される。`as e` は捕捉した例外インスタンスを変数 `e` で参照するための構文で、メッセージや `.args` を取り出せる。', 'https://docs.python.org/3/tutorial/errors.html#handling-exceptions', 'unpublished', false),
  (295, 'セクション94: Python try / except サンプル読解', 'while True ループを抜ける条件', '次のコードで `while True` ループが `break` によって終了するのはどんなときですか？

```python
while True:
    try:
        x = int(input("Please enter a number: "))
        break
    except (ValueError, TypeError):
        print("Oops! That was no valid number. Try again...")
```', 'while True:
    try:
        x = int(input("Please enter a number: "))
        break
    except (ValueError, TypeError):
        print("Oops! That was no valid number. Try again...")', '["`int(...)` が成功し、例外が発生しなかったとき", "`ValueError` が起きた直後", "ユーザーが Ctrl+C を押したとき", "入力が空文字だったときは必ず `break` する"]'::jsonb, 0, '`break` は try 節の中にあり、`int(input(...))` が正常に整数へ変換できた場合だけ到達する。`ValueError` や `TypeError` が起きると except に飛ぶのでループは継続する。', 'https://docs.python.org/3/tutorial/errors.html#handling-exceptions', 'unpublished', false),
  (296, 'セクション94: Python try / except サンプル読解', 'KeyboardInterrupt を個別に処理する意図', '次のコードで `except KeyboardInterrupt:` を別に書いている理由として最も適切なものはどれですか？

```python
except KeyboardInterrupt:
    print("\nInput cancelled by user. Exiting.")
    traceback.print_exc()
    exit()
```', 'except KeyboardInterrupt:
    print("\nInput cancelled by user. Exiting.")
    traceback.print_exc()
    exit()', '["Ctrl+C による中断を入力値エラーとは分けて扱い、メッセージ表示後に終了するため", "`KeyboardInterrupt` は `ValueError` のサブクラスなので、先に書かないと捕捉できないため", "`KeyboardInterrupt` を捕捉すると Python は必ず再起動するため", "これを書かないと `int()` は一切例外を投げなくなるため"]'::jsonb, 0, 'Ctrl+C で発生する `KeyboardInterrupt` は、単なる入力ミス (`ValueError`) とは意味が違う。サンプルではユーザー中断として明示的に扱い、メッセージとトレースバックを出して終了している。', 'https://docs.python.org/3/library/traceback.html', 'unpublished', false),
  (297, 'セクション94: Python try / except サンプル読解', 'print(e) と print(e.args) の違い', '例外を `except ValueError as e:` で受けたとき、`print(e)` と `print(e.args)` の関係として正しいものはどれですか？', 'except ValueError as e:
    print(e)
    print(e.args)', '["`print(e)` は人向けの文字列表現を表示し、`print(e.args)` は例外に渡された引数のタプルを表示する", "どちらも常に同じ型・同じ内容を表示する", "`e.args` は整数しか入れられないので文字列エラーでは使えない", "`print(e)` は例外クラス名だけを表示し、メッセージ本文は出ない"]'::jsonb, 0, '組み込み例外は通常 `__str__()` を定義しているため、`print(e)` では読みやすいメッセージが出る。一方 `e.args` はコンストラクタに渡された生の引数群で、タプルとして保持される。', 'https://docs.python.org/3/tutorial/errors.html#handling-exceptions', 'unpublished', false),
  (298, 'セクション94: Python try / except サンプル読解', 'Exception(''spam'', ''eggs'') の args', '次のコードを実行したとき、`inst.args` の値として正しいものはどれですか？

```python
try:
    raise Exception(''spam'', ''eggs'')
except Exception as inst:
    print(inst.args)
```', 'try:
    raise Exception(''spam'', ''eggs'')
except Exception as inst:
    print(inst.args)', '["`(''spam'', ''eggs'')`", "`[''spam'', ''eggs'']`", "`''spam eggs''`", "`None`"]'::jsonb, 0, '例外インスタンスに渡した複数引数は `.args` にタプルで保存される。サンプルではその後 `x, y = inst.args` とアンパックしている。', 'https://docs.python.org/3/tutorial/errors.html#handling-exceptions', 'unpublished', false),
  (299, 'セクション94: Python try / except サンプル読解', 'x, y = inst.args の意味', '次のコードで `x` と `y` には最終的に何が入りますか？

```python
try:
    raise Exception(''spam'', ''eggs'')
except Exception as inst:
    x, y = inst.args
```', 'try:
    raise Exception(''spam'', ''eggs'')
except Exception as inst:
    x, y = inst.args', '["`x` に `''spam''`、`y` に `''eggs''` が入る", "`x` に `(''spam'', ''eggs'')`、`y` に `None` が入る", "`x` に例外クラス、`y` に例外メッセージが入る", "アンパックできず `TypeError` になる"]'::jsonb, 0, '`.args` は 2 要素タプル `(''spam'', ''eggs'')` なので、そのまま順番に `x`, `y` へアンパックできる。', 'https://docs.python.org/3/tutorial/errors.html#handling-exceptions', 'unpublished', false),
  (300, 'セクション94: Python try / except サンプル読解', 'ファイル読込サンプルで ValueError が起きる条件', '次のサンプルでは、どのようなときに `except ValueError:` が実行されますか？

```python
try:
    f = open(''myfile.txt'', mode=''r'')
    s = f.readline()
    i = int(s.strip())
except OSError as err:
    print(''OS error:'', err)
except ValueError:
    print(''Could not convert data to an integer.'')
```', 'try:
    f = open(''myfile.txt'', mode=''r'')
    s = f.readline()
    i = int(s.strip())
except OSError as err:
    print(''OS error:'', err)
except ValueError:
    print(''Could not convert data to an integer.'')', '["ファイルは開けたが、読み込んだ文字列を `int(...)` に変換できなかったとき", "ファイルそのものが存在しないとき", "`open()` が成功したときは必ず ValueError になる", "`strip()` は常に `OSError` を送出するので ValueError にはならない"]'::jsonb, 0, '`OSError` はファイル操作レベルの失敗、`ValueError` は値変換の失敗。サンプルは「開けない」「開けるが中身が整数ではない」を分けて処理している。', 'https://docs.python.org/3/tutorial/errors.html#handling-exceptions', 'unpublished', false),
  (301, 'セクション94: Python try / except サンプル読解', 'for ループ内の else が実行される条件', '次のコードの `else:` 節が実行される条件として正しいものはどれですか？

```python
for arg in sys.argv[1:]:
    try:
        f = open(arg, ''r'')
    except OSError:
        print(''cannot open'', arg)
    else:
        print(arg, ''has'', len(f.readlines()), ''lines'')
        f.close()
```', 'for arg in sys.argv[1:]:
    try:
        f = open(arg, ''r'')
    except OSError:
        print(''cannot open'', arg)
    else:
        print(arg, ''has'', len(f.readlines()), ''lines'')
        f.close()', '["その反復で try 節に例外が発生しなかったとき", "例外が発生した直後に自動で実行される", "`except OSError` が実行された後に必ず続けて実行される", "for ループが最後まで回り切ったあと 1 回だけ実行される"]'::jsonb, 0, 'try/except の `else` は「例外が起きなかったときだけ」実行される。`for ... else` とは別物で、このサンプルでは各ファイルを正常に開けた場合だけ行数を表示している。', 'https://docs.python.org/3/tutorial/errors.html#handling-exceptions', 'unpublished', false),
  (302, 'セクション94: Python try / except サンプル読解', 'this_fails() が送出する例外', '次の関数呼び出しで捕捉される例外として正しいものはどれですか？

```python
def this_fails():
    x = 1 / 0

try:
    this_fails()
except ZeroDivisionError as err:
    print(''Handling run-time error:'', err)
```', 'def this_fails():
    x = 1 / 0

try:
    this_fails()
except ZeroDivisionError as err:
    print(''Handling run-time error:'', err)', '["`ZeroDivisionError`", "`ValueError`", "`ArithmeticException`", "`RuntimeError`"]'::jsonb, 0, '`1 / 0` は Python では `ZeroDivisionError` を送出する。関数の中で起きても、呼び出し元の try/except まで例外が伝播するので捕捉できる。', 'https://docs.python.org/3/tutorial/errors.html#handling-exceptions', 'unpublished', false),
  (303, 'セクション94: Python try / except サンプル読解', '例外は関数境界を越えて伝播する', 'サンプルの次のコメントの趣旨として最も適切なものはどれですか？

> Exception handlers do not handle only exceptions that occur immediately in the try clause

```python
def this_fails():
    x = 1 / 0

try:
    this_fails()
except ZeroDivisionError:
    ...
```', 'def this_fails():
    x = 1 / 0

try:
    this_fails()
except ZeroDivisionError:
    ...', '["try 節の中で直接書いた式だけでなく、その中で呼び出した関数から伝播してきた例外も捕捉できる", "except 節は関数内で起きた例外を絶対に捕捉できない", "関数呼び出しが 1 段でも入ると Python の例外処理は無効になる", "伝播した例外は必ず `RuntimeError` に変換される"]'::jsonb, 0, '例外はコールスタックをさかのぼって伝播する。したがって try 節の中で呼んだ関数内の `ZeroDivisionError` も、呼び出し元の `except ZeroDivisionError` で捕捉できる。', 'https://docs.python.org/3/tutorial/errors.html#handling-exceptions', 'unpublished', false),
  (304, 'セクション95: Python 独自例外と継承', '例外クラス継承の基本', '次の定義に基づく説明として最も正しいものはどれですか？

```python
class GrandFather(Exception):
    pass

class Father(GrandFather):
    pass

class Son(Father):
    pass
```', 'class GrandFather(Exception):
    pass

class Father(GrandFather):
    pass

class Son(Father):
    pass', '["`Son` は `Father` と `GrandFather` の両方のサブクラスでもある", "`Son` は `Father` のサブクラスだが `GrandFather` とは無関係である", "`Father` は `Exception` を継承していないので raise できない", "独自例外クラスは必ずメソッドを 1 つ以上定義しないと使えない"]'::jsonb, 0, '継承は連鎖するので、`Son` は `Father` の子であり、同時に `GrandFather` と `Exception` のサブクラスでもある。そのため親クラスの except でも捕捉できる。', 'https://docs.python.org/3/tutorial/errors.html#user-defined-exceptions', 'unpublished', false),
  (305, 'セクション95: Python 独自例外と継承', 'except の順序が結果を変える', '次の 1 つ目のループで、`raise Son()` のときに出力されるものはどれですか？

```python
try:
    raise Son()
except Son:
    print(''son'')
except Father:
    print(''Father'')
except GrandFather:
    print(''GrandFather'')
```', 'try:
    raise Son()
except Son:
    print(''son'')
except Father:
    print(''Father'')
except GrandFather:
    print(''GrandFather'')', '["`son`", "`Father`", "`GrandFather`", "どの except にも一致せず未処理例外になる"]'::jsonb, 0, '`Son` 自身に一致する最初の except が実行される。より具体的な例外を先に書いているため、親クラスのハンドラまで落ちない。', 'https://docs.python.org/3/tutorial/errors.html#user-defined-exceptions', 'unpublished', false),
  (306, 'セクション95: Python 独自例外と継承', '親クラスを先に書くとどうなるか', '次の 2 つ目のループでは、`GrandFather` を最初に捕捉しています。このとき `raise Son()` で何が出力されますか？

```python
try:
    raise Son()
except GrandFather:
    print(''GrandFather'')
except Son:
    print(''son'')
except Father:
    print(''Father'')
```', 'try:
    raise Son()
except GrandFather:
    print(''GrandFather'')
except Son:
    print(''son'')
except Father:
    print(''Father'')', '["`GrandFather`", "`son`", "`Father`", "捕捉されず例外終了する"]'::jsonb, 0, '`Son` は `GrandFather` のサブクラスでもあるため、先に書かれた `except GrandFather` がマッチしてしまう。except は上から順に評価され、最初に一致したものだけが実行される。', 'https://docs.python.org/3/tutorial/errors.html#user-defined-exceptions', 'unpublished', false),
  (307, 'セクション95: Python 独自例外と継承', '2つ目のループの出力パターン', '次のループを `GrandFather`, `Father`, `Son` の順に `raise` したとき、出力の並びとして正しいものはどれですか？

```python
for c in [GrandFather, Father, Son]:
    try:
        raise c()
    except GrandFather:
        print(''GrandFather'')
    except Son:
        print(''son'')
    except Father:
        print(''Father'')
```', 'for c in [GrandFather, Father, Son]:
    try:
        raise c()
    except GrandFather:
        print(''GrandFather'')
    except Son:
        print(''son'')
    except Father:
        print(''Father'')', '["`GrandFather`, `GrandFather`, `GrandFather`", "`GrandFather`, `Father`, `son`", "`GrandFather`, `son`, `Father`", "`son`, `Father`, `GrandFather`"]'::jsonb, 0, '先頭の `except GrandFather` が親クラスとして 3 種類すべてに一致するため、後ろの `except Son` と `except Father` は到達しない。', 'https://docs.python.org/3/tutorial/errors.html#user-defined-exceptions', 'unpublished', false),
  (308, 'セクション96: Python raise と再送出', 'raise ValueError の意味', '次の説明として正しいものはどれですか？

```python
raise ValueError
```', 'raise ValueError', '["例外クラスをそのまま渡しており、Python が引数なしで暗黙にインスタンス化して送出する", "`ValueError` という文字列を送出している", "`ValueError` は `BaseException` のサブクラスではないので実行時に SyntaxError になる", "この書き方では必ず `ValueError()` と `TypeError()` が同時に送出される"]'::jsonb, 0, 'raise には例外インスタンスだけでなく例外クラスも渡せる。クラスを渡した場合、Python はコンストラクタを引数なしで呼んで例外オブジェクトを作る。', 'https://docs.python.org/3/tutorial/errors.html#raising-and-handling-multiple-unrelated-exceptions', 'unpublished', false),
  (309, 'セクション96: Python raise と再送出', 'bare raise の意味', '次の except 節にある `raise` 単独記法の意味として最も適切なものはどれですか？

```python
try:
    raise NameError(''HiThere'')
except NameError:
    print(''An exception flew by!'')
    raise
```', 'try:
    raise NameError(''HiThere'')
except NameError:
    print(''An exception flew by!'')
    raise', '["現在処理中の同じ例外をそのまま再送出する", "`NameError` を `RuntimeError` に自動変換して送出する", "except 節の中で発生した新しい例外だけを送出する", "例外を握りつぶして正常終了に変える"]'::jsonb, 0, 'except 節の中で引数なし `raise` を使うと、今まさに捕捉している例外を再送出する。ログを出してから上位へ伝播させたいときによく使う。', 'https://docs.python.org/3/tutorial/errors.html#raising-and-handling-multiple-unrelated-exceptions', 'unpublished', false),
  (310, 'セクション96: Python raise と再送出', '再送出後の最終結果', '次のコードをそのまま実行した場合、最終的な挙動として正しいものはどれですか？

```python
try:
    raise NameError(''HiThere'')
except NameError:
    print(''An exception flew by!'')
    raise
```', 'try:
    raise NameError(''HiThere'')
except NameError:
    print(''An exception flew by!'')
    raise', '["メッセージを 1 回表示した後、`NameError` が再び未処理例外として表に出る", "print された時点で例外は消えるので正常終了する", "最終的に `ValueError` へ変換される", "`raise` 行は except 節の中では無視される"]'::jsonb, 0, '`print` でメッセージを出しただけでは例外は解決しない。引数なし `raise` により同じ `NameError(''HiThere'')` が再送出され、上位で捕捉されなければトレースバック付きで終了する。', 'https://docs.python.org/3/tutorial/errors.html#raising-and-handling-multiple-unrelated-exceptions', 'unpublished', false),
  (311, 'セクション96: Python raise と再送出', 'どんなものを raise できるか', 'サンプル冒頭の説明に沿うと、`raise` に渡せるものとして正しい組み合わせはどれですか？', '# raise には何を渡せるか？', '["例外インスタンス、または `BaseException` 系を継承した例外クラス", "任意の文字列と整数だけ", "関数オブジェクトだけ", "辞書やリストだけ"]'::jsonb, 0, 'Python の `raise` は、例外インスタンスか例外クラスを受け取る。クラスであれば `BaseException` のサブクラスである必要がある。', 'https://docs.python.org/3/tutorial/errors.html#raising-and-handling-multiple-unrelated-exceptions', 'unpublished', false),
  (312, 'セクション97: Python 例外連鎖', '例外連鎖サンプルの最終例外', '次のコードを実行したとき、最終的に外へ出る例外はどれですか？

```python
try:
    open(''database.sqlite'')
except OSError:
    raise RuntimeError(''unable to handle error'')
```', 'try:
    open(''database.sqlite'')
except OSError:
    raise RuntimeError(''unable to handle error'')', '["`RuntimeError(''unable to handle error'')`", "`OSError` だけが出て `RuntimeError` は無視される", "`NameError`", "例外は消えて正常終了する"]'::jsonb, 0, 'except 節の中で新しく `RuntimeError` を送出しているので、最終的に外へ出るのはそちら。ただし元の `OSError` も文脈情報として例外連鎖に残る。', 'https://docs.python.org/3/tutorial/errors.html#raising-and-handling-multiple-unrelated-exceptions', 'unpublished', false),
  (313, 'セクション97: Python 例外連鎖', 'During handling of the above exception の意味', '次のサンプルで `open(''database.sqlite'')` が失敗したあとに `RuntimeError` を送出すると、トレースバック中に現れる `During handling of the above exception, another exception occurred:` という表示の意味として最も適切なものはどれですか？', 'try:
    open(''database.sqlite'')
except OSError:
    raise RuntimeError(''unable to handle error'')', '["最初の例外 (`OSError`) を処理している最中に、別の例外 (`RuntimeError`) が発生したという暗黙の例外連鎖を示す", "2 つの例外が完全に無関係に並行実行されたことを示す", "`RuntimeError` が `OSError` のサブクラスであることを示す", "Python が例外メッセージを自動で翻訳したことを示す"]'::jsonb, 0, 'これは implicit exception chaining の表示で、元の例外が `__context__` としてぶら下がっていることを表す。『最初の失敗を処理しようとしていたら、さらに別の例外が起きた』という文脈が保持される。', 'https://docs.python.org/3/tutorial/errors.html#raising-and-handling-multiple-unrelated-exceptions', 'unpublished', false),
  (314, 'セクション98: Python with 文とクリーンアップ', 'The problem with this code の意味', '次の英文の意味として最も適切なものはどれですか？

> The problem with this code is that it leaves the file open for an indeterminate amount of time after this part of the code has finished executing.', 'for line in open("myfile.txt"):
    print(line, end="")', '["このコードの問題は、この部分のコードの実行が終わったあとも、ファイルをどれだけの時間開いたままにするのか分からない状態にしてしまうことだ", "このコードの問題は、ファイルを開く前に必ず `print` が失敗することだ", "このコードの問題は、ファイルを閉じるのが早すぎてループが1回も回らないことだ", "このコードの問題は、ファイルの内容を自動的に削除してしまうことだ"]'::jsonb, 0, '`The problem with this code` は『このコードの問題』、`leaves the file open` は『ファイルを開いたままにする』、`for an indeterminate amount of time` は『どれくらいの長さか定まらない時間のあいだ』という意味。つまり、ループ本体の実行が終わってもファイルクローズのタイミングが明示されず、後始末が遅れる可能性を指摘している。こうしたケースでは `with open(...) as f:` を使うと、ブロックを抜けた時点でファイルが確実に閉じられる。', 'https://docs.python.org/3/reference/compound_stmts.html#the-with-statement', 'unpublished', false),
  (315, 'セクション99: 英文読解 (接続詞と文構造)', 'but は何をつないでいるか', '次の英文について、`but` の文法的な説明として最も適切なものはどれですか？

> This is not an issue in simple scripts, but can be a problem for larger applications.', 'This is not an issue in simple scripts, but can be a problem for larger applications.', '["`but` は等位接続詞で、前半の節と後半の節を対比的につないでいる。後半では主語 `this` が省略されていると考えられる", "`but` は前置詞で、直後の `can be a problem` を名詞句にしている", "`but` は従属接続詞で、後半全体を原因を表す副詞節にしている", "`but` は関係代名詞で、直前の `scripts` を修飾している"]'::jsonb, 0, 'この `but` は等位接続詞で、`This is not an issue in simple scripts` と `(This) can be a problem for larger applications` を対比的に結んでいる。後半は前半と同じ主語 `This` が省略された形と考えると理解しやすい。したがって文全体は『これは単純なスクリプトでは問題ではないが、より大きなアプリケーションでは問題になりうる』という意味になる。', 'https://docs.python.org/3/tutorial/', 'unpublished', false),
  (316, 'セクション99: 英文読解 (接続詞と文構造)', 'allow A to do の基本構文', '次の英文に出てくる `allows objects like files to be used ...` の文法説明として最も適切なものはどれですか？

> The with statement allows objects like files to be used in a way that ensures they are always cleaned up promptly and correctly.', 'The with statement allows objects like files to be used in a way that ensures they are always cleaned up promptly and correctly.', '["`allow A to do` の形で、『A が〜できるようにする』を表している。ここでは受け身の `to be used` になっている", "`allow` は自動詞で、`objects like files` は副詞句として働いている", "`to be used` は `statement` を修飾する形容詞的用法の不定詞である", "`like files` は動詞 `allows` を修飾する副詞句である"]'::jsonb, 0, 'この文の中心は `allow A to do` で、『A が〜するのを可能にする』という構文。ここでは `A = objects like files`、`to do = to be used ...` で、受け身になっているため『ファイルのようなオブジェクトが、そのようなやり方で使われることを可能にする』という意味になる。`like files` は `objects` を後ろから説明する句である。', 'https://docs.python.org/3/tutorial/', 'unpublished', false),
  (317, 'セクション99: 英文読解 (接続詞と文構造)', '条件・譲歩の副詞節を見抜く', '次の英文で、条件・譲歩を表す副詞節に当たる部分はどれですか？

> After the statement is executed, the file f is always closed, even if a problem was encountered while processing the lines.', 'After the statement is executed, the file f is always closed, even if a problem was encountered while processing the lines.', '["`After the statement is executed`", "`the file f is always closed`", "`even if a problem was encountered while processing the lines`", "`while processing the lines`"]'::jsonb, 2, '`even if ...` は『たとえ〜でも』を表す接続表現で、条件・譲歩の副詞節を導く。この文では `After the statement is executed` が時を表す副詞節、`the file f is always closed` が主節、`while processing the lines` は `encountered` にかかる時の副詞句に近い働きで、条件・譲歩を表している中心部分は `even if a problem was encountered while processing the lines` である。', 'https://docs.python.org/3/tutorial/', 'unpublished', false),
  (318, 'セクション99: 英文読解 (接続詞と文構造)', '時の副詞節を見抜く', '次の英文で、時を表す副詞節に当たる部分はどれですか？

> After the statement is executed, the file f is always closed, even if a problem was encountered while processing the lines.', 'After the statement is executed, the file f is always closed, even if a problem was encountered while processing the lines.', '["`After the statement is executed`", "`the file f is always closed`", "`even if a problem was encountered while processing the lines`", "`a problem was encountered`"]'::jsonb, 0, '`After ...` は『〜のあとで』を表し、時の副詞節を導く。この文では `After the statement is executed` が『その文が実行されたあとで』という時間関係を示し、主節 `the file f is always closed` にかかっている。一方、`even if ...` は条件・譲歩の副詞節であり、`a problem was encountered` はそれ単体では従属接続詞を含まないため、この文の時の副詞節そのものではない。', 'https://docs.python.org/3/tutorial/', 'unpublished', false),
  (319, 'セクション99: 英文読解 (接続詞と文構造)', 'leave the file open の構文', '次の英文の下線部 `leaves the file open` の文法的な構造として正しいものはどれですか？

> The problem with this code is that it leaves the file open for an indeterminate amount of time.', 'The problem with this code is that it leaves the file open for an indeterminate amount of time.', '["SVO構文で、`open` は副詞として `leaves` を修飾している", "SVOC構文で、`the file` が目的語、`open` が目的語補語（形容詞）である", "SVC構文で、`the file open` が補語のかたまりになっている", "SVO構文で、`open` は `the file` を後置修飾する形容詞である"]'::jsonb, 1, '`leave + O + C` で『O を C の状態のままにしておく』という SVOC の形。ここでは `the file` が目的語、`open` が目的語補語の形容詞で、『ファイルを開いたままにしておく』という意味になる。`open` は副詞ではなく、また `the file open` 全体が補語になっているわけでもない。', 'https://docs.python.org/3/tutorial/', 'unpublished', false),
  (320, 'セクション99: 英文読解 (接続詞と文構造)', 'The problem is that の構文', '次の文の空欄に入る最も適切なものはどれですか？

> The problem with this code is ___ it leaves the file open for an indeterminate amount of time.', 'The problem with this code is ___ it leaves the file open for an indeterminate amount of time.', '["`what`", "`which`", "`that`", "`how`"]'::jsonb, 2, '`The problem is that ...` は『問題は〜ということだ』という基本構文で、`that` 節が内容を表す名詞節として補語の役割を果たす。`what` や `which` はここでは関係代名詞・疑問詞の用法になってしまい不自然で、`how` も『どのように』という意味になって文意に合わない。', 'https://docs.python.org/3/tutorial/', 'unpublished', false),
  (321, 'セクション99: 英文読解 (接続詞と文構造)', 'even if と置き換えられないもの', '次の文の `even if` と置き換えられないものはどれですか？

> the file f is always closed, even if a problem was encountered', 'the file f is always closed, even if a problem was encountered', '["`even though`", "`unless`", "`regardless of whether`", "`no matter if`"]'::jsonb, 1, '`even if` は『たとえ〜でも』という譲歩を表す。`unless` は『〜でない限り』という条件を表し、意味の向きが逆になるため置き換えられない。一方、`even though`・`regardless of whether`・`no matter if` は細かなニュアンス差はあるものの、この文脈では近い発想で使える。', 'https://docs.python.org/3/tutorial/', 'unpublished', false),
  (322, 'セクション99: 英文読解 (接続詞と文構造)', 'while processing the lines の省略', '次の文の `while processing the lines` について、最も自然な補い方として適切なものはどれですか？

> even if a problem was encountered while processing the lines', 'even if a problem was encountered while processing the lines', '["`it was`", "`a problem was being`", "`there was`", "`one is`"]'::jsonb, 0, '`while processing the lines` は、文脈上『`(it was) processing the lines`』のように主語と `be` 動詞が省略された形と考えるのが最も自然。ここでの `it` はコードや処理の流れを受ける一般的な主語として理解できる。`a problem was being ...` と補うのは不自然で、`there was` や `one is` も文意に合わない。', 'https://docs.python.org/3/tutorial/', 'unpublished', false),
  (323, 'セクション100: 英文読解 (Python ExceptionGroup)', '形式主語 it を見抜く', '次の文の `it` が指すものとして正しいものはどれですか？

> There are situations where it is necessary to report several exceptions that have occurred.', 'There are situations where it is necessary to report several exceptions that have occurred.', '["`situations`", "`exceptions`", "形式主語（意味上の主語は `to report` 以下）", "`This`"]'::jsonb, 2, '`it is necessary to ...` の `it` は形式主語で、真主語は後ろの `to report several exceptions that have occurred`。英語では長い不定詞句を後ろへ回し、前にダミーの `it` を置くことがよくある。したがって `it` が具体的に `situations` や `exceptions` を指しているわけではない。', 'https://docs.python.org/3/library/exceptions.html#ExceptionGroup', 'unpublished', false),
  (324, 'セクション100: 英文読解 (Python ExceptionGroup)', 'may have failed の時制と意味', '次の文の `may have failed` の文法的な意味として正しいものはどれですか？

> when several tasks may have failed in parallel', 'when several tasks may have failed in parallel', '["現在の推量（〜かもしれない）", "未来の可能性（〜するかもしれない）", "過去の推量（〜したかもしれない）", "過去の習慣（〜したものだ）"]'::jsonb, 2, '`may have + 過去分詞` は『〜したかもしれない』という過去に対する推量を表す。ここでは `failed` が過去分詞なので、『複数のタスクが並行して失敗したかもしれないとき』という意味になる。単なる現在や未来の可能性ではない。', 'https://docs.python.org/3/library/exceptions.html#ExceptionGroup', 'unpublished', false),
  (325, 'セクション100: 英文読解 (Python ExceptionGroup)', 'rather than の後ろの形', '次の文の `rather than` の後に続く動詞の形として最も適切なものはどれですか？

> it is desirable to continue execution and collect multiple errors rather than ___ the first exception.', 'it is desirable to continue execution and collect multiple errors rather than ___ the first exception.', '["`raising`", "`to raise`", "`having raised`", "`raise`"]'::jsonb, 3, 'ここでは `to continue execution and collect multiple errors rather than raise the first exception` のように、前の動詞句と並列になる原形 `raise` が最も自然。`rather than` の後ろは文脈によって動名詞もあり得るが、この文では `continue / collect / raise` の並列関係を見るのがポイント。', 'https://docs.python.org/3/library/exceptions.html#ExceptionGroup', 'unpublished', false),
  (326, 'セクション100: 英文読解 (Python ExceptionGroup)', 'where の用法を見分ける', '次の 2 つの `where` の用法の組み合わせとして正しいものはどれですか？

(A) `situations where it is necessary to report several exceptions`
(B) `other use cases where it is desirable to continue execution`', '(A) situations where it is necessary to report several exceptions
(B) other use cases where it is desirable to continue execution', '["(A) 関係代名詞　(B) 関係副詞", "(A) 接続詞　(B) 関係代名詞", "(A) 関係副詞　(B) 関係副詞", "(A) 関係副詞　(B) 接続詞"]'::jsonb, 2, 'どちらの `where` も先行詞 `situations` / `use cases` を修飾する関係副詞。`where` は具体的な場所だけでなく、`situation` や `case` のような抽象的な場面・状況を表す名詞にも使える。したがって両方とも『〜のような状況で』という意味合いを作っている。', 'https://docs.python.org/3/library/exceptions.html#ExceptionGroup', 'unpublished', false),
  (327, 'セクション100: 英文読解 (Python ExceptionGroup)', 'This is often the case の意味', '次の文で `This is often the case` の意味として最も適切なものはどれですか？

> This is often the case in concurrency frameworks.', 'This is often the case in concurrency frameworks.', '["これは並行処理フレームワークにおいて問題となることが多い", "これは並行処理フレームワークでよく当てはまる", "これは並行処理フレームワークで頻繁に起きる例外だ", "これは並行処理フレームワークで必要とされることが多い"]'::jsonb, 1, '`this is the case` は『これが当てはまる』『これが実情だ』という慣用表現。`often` が入ると『よく当てはまる』となる。`happen` や `occur` のように出来事が起こること自体を言うのではなく、ある説明や状況が特定の文脈で妥当することを述べている。', 'https://docs.python.org/3/library/exceptions.html#ExceptionGroup', 'unpublished', false),
  (328, 'セクション101: 英文法 (形式主語 it)', 'It is important that の形', '次の空欄に入る最も適切なものはどれですか？

> It is important ___ you study every day.', 'It is important ___ you study every day.', '["`for`", "`of`", "`that`", "`what`"]'::jsonb, 2, '`It is important that ...` の形で、`that` 節が形式主語 `it` の内容を表す。`for` や `of` では後ろに完全な節をそのまま続けられず、`what` だと『何が』の意味になって不自然。', 'https://dictionary.cambridge.org/grammar/british-grammar/', 'unpublished', false),
  (329, 'セクション101: 英文法 (形式主語 it)', 'It is no use doing の真主語', '次の文の形式主語 `it` の真主語として正しいものはどれですか？

> It is no use trying to persuade him.', 'It is no use trying to persuade him.', '["`to persuade him`", "`trying to persuade him`", "`him`", "`persuade him`"]'::jsonb, 1, '`It is no use doing ...` は『〜しても無駄だ』という慣用表現で、真主語は動名詞句 `trying to persuade him`。`to persuade him` ではなく、`trying` を含む動名詞全体が内容を担っている。', 'https://dictionary.cambridge.org/grammar/british-grammar/', 'unpublished', false),
  (330, 'セクション101: 英文法 (形式主語 it)', 'whether が導く名詞節', '次の文の空欄に入る最も適切なものはどれですか？

> It remains unclear ___ the new policy will succeed.', 'It remains unclear ___ the new policy will succeed.', '["`that`", "`what`", "`whether`", "`which`"]'::jsonb, 2, 'ここでは『新しい方針が成功するかどうか』という意味が必要なので `whether` が適切。`that` は事実内容をそのまま述べるときに使い、`what` や `which` は選択や内容そのものを問う語で、この文意には合わない。', 'https://dictionary.cambridge.org/grammar/british-grammar/', 'unpublished', false),
  (331, 'セクション101: 英文法 (形式主語 it)', '文法的に誤っている文を選ぶ', '次の 4 つの文のうち、文法的に誤っているものはどれですか？', '1. It is easy to forget her name.
2. It is surprising that he passed the exam.
3. It is no use to cry over spilt milk.
4. It is uncertain how the situation will develop.', '["`It is easy to forget her name.`", "`It is surprising that he passed the exam.`", "`It is no use to cry over spilt milk.`", "`It is uncertain how the situation will develop.`"]'::jsonb, 2, '`It is no use ...` の後ろは通常、動名詞を用いて `It is no use crying over spilt milk.` とする。不定詞 `to cry` はこの慣用表現では不自然。他の 3 文は、形式主語 `it` の後に不定詞・that節・疑問詞節が続く正しい形。', 'https://dictionary.cambridge.org/grammar/british-grammar/', 'unpublished', false),
  (332, 'セクション101: 英文法 (形式主語 it)', 'how が導く疑問詞節', '次の文の空欄に入る最も適切なものはどれですか？

> It is amazing ___ she managed to finish the project alone.', 'It is amazing ___ she managed to finish the project alone.', '["`what`", "`how`", "`whether`", "`which`"]'::jsonb, 1, 'ここでは『彼女がどのようにして一人でそのプロジェクトを終えたか』という意味になるため、方法を表す `how` が最適。`whether` は『〜かどうか』、`what` や `which` は内容や選択肢を問う語であり、文意に合わない。', 'https://dictionary.cambridge.org/grammar/british-grammar/', 'unpublished', false),
  (333, 'セクション100: 英文読解 (Python ExceptionGroup)', 'where の用法を見抜く', '次の文の `where` の用法として正しいものはどれですか？

> There are situations where it is necessary to report several exceptions.', 'There are situations where it is necessary to report several exceptions.', '["疑問副詞（『どこで』の意味）", "接続詞（『〜のところに』の意味）", "関係代名詞（`situations` を目的語として修飾）", "関係副詞（`situations` を先行詞として修飾）"]'::jsonb, 3, '`where` は場所を表す名詞だけでなく、`situation` や `case` のような抽象名詞も先行詞にとれる。この文では `situations where ...` 全体で『〜のような状況』を表しており、`where` の後ろは `it is necessary ...` という完全な節になっているため、関係副詞と考えるのが適切。', 'https://docs.python.org/3/library/exceptions.html#ExceptionGroup', 'unpublished', false),
  (334, 'セクション100: 英文読解 (Python ExceptionGroup)', '形式主語文の書き換え', '次の文を書き換えたとき、空欄に入る最も適切なものはどれですか？

> It is necessary to report several exceptions that have occurred.
> = ___ several exceptions that have occurred is necessary.', 'It is necessary to report several exceptions that have occurred.
= ___ several exceptions that have occurred is necessary.', '["`Report`", "`Reported`", "`Reporting`", "`To have reported`"]'::jsonb, 2, '形式主語 `it` の真主語は `to report ...` だが、同じ内容を主語位置に置き換えるときは動名詞 `Reporting ...` でも自然な英文になる。`To report ...` も文法的には可能だが選択肢にないため、ここでは `Reporting` が最も適切。`To have reported` は完了不定詞で時制の意味がずれてしまう。', 'https://docs.python.org/3/library/exceptions.html#ExceptionGroup', 'unpublished', false),
  (335, 'セクション100: 英文読解 (Python ExceptionGroup)', 'that have occurred を省けない理由', '次の文の `that have occurred` を省略できない理由として最も適切なものはどれですか？

> it is necessary to report several exceptions that have occurred', 'it is necessary to report several exceptions that have occurred', '["`that` が形式主語だから", "`exceptions` が抽象名詞だから", "`that have occurred` が `exceptions` の範囲を限定しているから", "現在完了形は省略できないというルールがあるから"]'::jsonb, 2, '`that have occurred` は限定用法の関係詞節で、『発生した例外』というように `exceptions` の範囲を絞っている。これをまるごと省くと、単に『例外一般』を報告するという意味に変わってしまうため、そのままでは省略できない。', 'https://docs.python.org/3/library/exceptions.html#ExceptionGroup', 'unpublished', false),
  (336, 'セクション100: 英文読解 (Python ExceptionGroup)', 'where を in which に書き換える', '次の文の `There are situations where ...` とほぼ同じ意味になるように書き換えたとき、最も適切なものはどれですか？

> There are situations where it is necessary to report several exceptions.', 'There are situations where it is necessary to report several exceptions.', '["`There are situations which it is necessary to report several exceptions.`", "`There are situations that it is necessary to report several exceptions.`", "`There are situations in which it is necessary to report several exceptions.`", "`There are situations what it is necessary to report several exceptions.`"]'::jsonb, 2, '関係副詞 `where` は、`in which` のような『前置詞 + 関係代名詞』に書き換えられることがある。この文では `situations where ...` = `situations in which ...` と考えられる。`which` や `that` だけでは前置詞が欠け、`what` は先行詞を含む語なので不適切。', 'https://docs.python.org/3/library/exceptions.html#ExceptionGroup', 'unpublished', false),
  (337, 'セクション100: 英文読解 (Python ExceptionGroup)', 'have occurred の現在完了の意味', '次の文で現在完了形 `have occurred` が使われている理由として最も適切なものはどれですか？

> it is necessary to report several exceptions that have occurred', 'it is necessary to report several exceptions that have occurred', '["過去の推量を表すため", "未来の予定を表すため", "現在進行中の動作を表すため", "過去に発生し現在も関連している状態を表すため"]'::jsonb, 3, '現在完了形は、過去に起きた出来事が現在の状況とつながっていることを表す。`have occurred` は『すでに発生していて、今その報告が必要な例外』というニュアンスを持つ。単純過去 `occurred` だと、現在とのつながりがやや弱くなる。', 'https://docs.python.org/3/library/exceptions.html#ExceptionGroup', 'unpublished', false),
  (338, 'セクション100: 英文読解 (Python ExceptionGroup)', 'may have failed の近い言い換え', '次の文の `may have failed` を別の表現に書き換えたとき、意味が最も近いものはどれか。

> when several tasks may have failed in parallel', 'when several tasks may have failed in parallel', '["`when several tasks should have failed in parallel`", "`when several tasks must have failed in parallel`", "`when several tasks might have failed in parallel`", "`when several tasks would have failed in parallel`"]'::jsonb, 2, '`may have failed` は過去の推量『失敗したかもしれない』を表す。`might have failed` もほぼ同義で、`might` のほうがわずかに可能性が低いニュアンスを持つ。一方 `must have failed` は『失敗したに違いない』、`should have failed` は『失敗すべきだった』、`would have failed` は仮定法的な『失敗しただろう』であり意味が異なる。', 'https://docs.python.org/3/library/exceptions.html#ExceptionGroup', 'unpublished', false),
  (339, 'セクション100: 英文読解 (Python ExceptionGroup)', 'rather than の後ろで許される形', '次の文の `rather than` の後に続く動詞の形として文法的に正しいものをすべて選んだ組み合わせはどれか。

> it is desirable to continue execution and collect multiple errors rather than ___ the first exception.', 'it is desirable to continue execution and collect multiple errors rather than ___ the first exception.', '["`raise` のみ", "`raising` のみ", "`raise` と `raising` の両方", "`to raise` のみ"]'::jsonb, 2, '`rather than` の後ろには原形 `raise` も動名詞 `raising` も文法的に現れうる。ただし、この文では前の `to continue` / `collect` との並列を考えると原形 `raise` がより自然。`to raise` は一般に `rather than` の直後では選ばれにくい。', 'https://docs.python.org/3/library/exceptions.html#ExceptionGroup', 'unpublished', false),
  (340, 'セクション100: 英文読解 (Python ExceptionGroup)', 'where の言い換え', '次の文の `where` を別の表現に書き換えたとき、最も適切なものはどれか。

> there are also other use cases where it is desirable to continue execution', 'there are also other use cases where it is desirable to continue execution', '["`there are also other use cases which it is desirable to continue execution`", "`there are also other use cases that it is desirable to continue execution`", "`there are also other use cases in which it is desirable to continue execution`", "`there are also other use cases what it is desirable to continue execution`"]'::jsonb, 2, '関係副詞 `where` は `前置詞 + 関係代名詞` に書き換えられ、この場合は `in which` が対応する。`which` や `that` だけでは前置詞が欠け、`what` は先行詞を含む語なので使えない。', 'https://docs.python.org/3/library/exceptions.html#ExceptionGroup', 'unpublished', false),
  (341, 'セクション100: 英文読解 (Python ExceptionGroup)', 'the case の同じ意味', '次の文の `This is often the case` の `case` と同じ意味で使われているものはどれか。

> This is often the case in concurrency frameworks', 'This is often the case in concurrency frameworks', '["`He bought a new case for his smartphone.`", "`The doctor examined a serious medical case.`", "`That is not the case at all.`", "`We need to make a strong case for the proposal.`"]'::jsonb, 2, 'ここでの `the case` は『実情・事実・当てはまること』という慣用表現。`That is not the case at all.` の `case` も同じで『それは事実ではない』という意味になる。他の選択肢はそれぞれ『入れ物』『症例』『主張・論拠』で意味が異なる。', 'https://docs.python.org/3/library/exceptions.html#ExceptionGroup', 'unpublished', false),
  (342, 'セクション100: 英文読解 (Python ExceptionGroup)', '文全体の対比構造', '次の文全体の構造として最も正しいものはどれか。

> This is often the case in concurrency frameworks, when several tasks may have failed in parallel, but there are also other use cases where it is desirable to continue execution and collect multiple errors rather than raise the first exception.', 'This is often the case in concurrency frameworks, when several tasks may have failed in parallel, but there are also other use cases where it is desirable to continue execution and collect multiple errors rather than raise the first exception.', '["主語 + 動詞 + 目的語 の単文", "条件節 + 主節 の複文", "等位接続詞 `but` による 2 つの節の対比構造", "関係副詞節が主節を修飾する複文"]'::jsonb, 2, '文全体は `This is often the case ...` という前半と、`but there are also other use cases ...` という後半が、等位接続詞 `but` で結ばれた対比構造。前半は『並行処理フレームワークではよく当てはまる』、後半は『ただし他のユースケースもある』という対照を示している。', 'https://docs.python.org/3/library/exceptions.html#ExceptionGroup', 'unpublished', false),
  (343, 'セクション100: 英文読解 (Python ExceptionGroup)', 'it is desirable to の真主語', '次の文の形式主語構文において、真主語として正しいものはどれか。

> it is desirable to continue execution and collect multiple errors rather than raise the first exception', 'it is desirable to continue execution and collect multiple errors rather than raise the first exception', '["`it`", "`desirable`", "`execution`", "`to continue execution and collect multiple errors rather than raise the first exception`"]'::jsonb, 3, '`it is desirable to ...` の `it` は形式主語で、真主語は後ろの不定詞句全体。ここでは `to continue execution` と `collect multiple errors` が並列し、さらに `rather than raise the first exception` が加わって、『最初の例外を送出するのではなく実行を続けて複数のエラーを集めること』全体が内容になっている。', 'https://docs.python.org/3/library/exceptions.html#ExceptionGroup', 'unpublished', false),
  (344, 'セクション102: Python 実行環境と alternatives', 'update-alternatives --install の引数', '次のコマンドにおける 4 つの位置引数の説明として最も正しいものはどれですか？

> sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1', 'sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1', '["`/usr/bin/python3` は実体バイナリ、`python3` は実行ユーザー名、`/usr/bin/python3.11` はリンクグループ名、`1` は Python のメジャーバージョンを表す", "`/usr/bin/python3` は master link、`python3` は alternatives 名、`/usr/bin/python3.11` は候補パス、`1` は優先度を表す", "`/usr/bin/python3` は `PATH` 追加先、`python3` はシェル組み込み名、`/usr/bin/python3.11` は shebang 用エイリアス、`1` は CPU アーキテクチャを表す", "`/usr/bin/python3` は alternatives 名、`python3` は候補パス、`/usr/bin/python3.11` は slave link、`1` は root 権限レベルを表す"]'::jsonb, 1, '`update-alternatives --install <link> <name> <path> <priority>` の形。ここでは `/usr/bin/python3` が総称リンク (master link)、`python3` が alternatives のグループ名、`/usr/bin/python3.11` が登録する実体パス、`1` が優先度。優先度は auto モード時の選択に使われ、数値が大きい候補が優先される。', 'https://docs.python.org/3/using/cmdline.html', 'unpublished', false),
  (345, 'セクション102: Python 実行環境と alternatives', 'python3 実行時の参照経路', 'このコマンドで `python3` の alternatives グループが管理されているとき、`/usr/bin/python3` と実体バイナリの関係として最も適切なものはどれですか？', 'sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1', '["`/usr/bin/python3` は常に通常ファイルのままで、毎回 `python3.11` がメモリ上に直接マッピングされる", "`/usr/bin/python3` は通常 `/etc/alternatives/python3` を指すシンボリックリンクになり、その先が選択中の実体 (`/usr/bin/python3.11` など) を指す", "`/usr/bin/python3` は bash の alias に置き換えられるため、シンボリックリンクは関係しない", "`/usr/bin/python3` は `pip3` が存在するときだけ `python3.11` へリンクされる"]'::jsonb, 1, 'Debian 系の `update-alternatives` は、総称名 (`/usr/bin/python3`) を `/etc/alternatives/python3` に向け、その先を選択中の候補へ向ける二段階リンクで管理するのが基本。これにより候補の差し替えを一元管理できる。', 'https://docs.python.org/3/using/cmdline.html', 'unpublished', false),
  (346, 'セクション102: Python 実行環境と alternatives', '影響を受けない起動方法', '`/usr/bin/python3` の alternatives だけを `python3.11` に切り替えた場合、通常この変更の影響を直接は受けないものはどれですか？', 'sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1', '["シェルで `python3 script.py` を実行する", "shebang が `#!/usr/bin/python3` のスクリプトを実行する", "shebang が `#!/usr/bin/env python3` のスクリプトを、`PATH` に `/usr/bin` がある通常環境で実行する", "shebang が `#!/usr/bin/python3.10` のスクリプトを実行する"]'::jsonb, 3, '`#!/usr/bin/python3.10` のように特定バージョンの実行ファイルを絶対パスで指定している場合、`/usr/bin/python3` の総称リンクを書き換えても参照先は変わらない。一方 `python3` コマンド、`#!/usr/bin/python3`、`#!/usr/bin/env python3` は環境次第で総称名 `python3` の変更の影響を受ける。', 'https://docs.python.org/3/using/cmdline.html', 'unpublished', false),
  (347, 'セクション102: Python 実行環境と alternatives', '既存 virtualenv / venv への影響', 'すでに作成済みの Python 仮想環境 (`venv`) がある状態で、このコマンドによりシステムの `/usr/bin/python3` の alternatives を変更したときの説明として最も適切なものはどれですか？', 'sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1', '["既存のすべての `venv` は自動的に再生成され、内部 Python も必ず `3.11` に置き換わる", "既存の `venv` は作成時に結び付いた実行環境を基本的に保持するため、システム側の `python3` 切り替えだけで中身が自動アップグレードされるわけではない", "既存の `venv` は以後すべて壊れ、起動不能になる", "`venv` は常に `/usr/bin/python3` を毎回たどる設計なので、切り替え直後から必ず新バージョンを使う"]'::jsonb, 1, '仮想環境は作成時の Python 実行環境に基づいて構成される。システムの総称名 `python3` を切り替えても、既存の `venv` の interpreter や site-packages が自動で別バージョンへ移行されるわけではない。必要なら新しい interpreter で作り直すのが安全。', 'https://docs.python.org/3/using/cmdline.html', 'unpublished', false),
  (348, 'セクション102: Python 実行環境と alternatives', 'pip の食い違いを避ける方法', '`update-alternatives` で `python3` の向き先を変えたあと、`pip3` が別 interpreter を向いている可能性を避けつつ、『今 `python3` として選ばれている interpreter』に対して確実にパッケージを入れたい。最も安全なコマンドはどれですか？', 'sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1', '["`pip3 install <package>`", "`python3 -m pip install <package>`", "`/etc/alternatives/python3 install <package>`", "`update-alternatives --config pip3`"]'::jsonb, 1, '`pip3` というコマンド名は、`python3` の向き先と必ずしも一致しない。`python3 -m pip` の形にすると、実際に起動された `python3` 自身の `pip` モジュールを使うため、interpreter と package install 先の食い違いを避けやすい。', 'https://docs.python.org/3/using/cmdline.html', 'unpublished', false),
  (349, 'セクション102: Python 実行環境と alternatives', 'priority と auto モードの挙動', '`python3` の alternatives グループが auto モードで、すでに `/usr/bin/python3.12` が priority `2` で登録済みだとする。この状態で次のコマンドを実行した直後、選ばれる候補として最も可能性が高いものはどれですか？

> sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1', 'sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1', '["新しく追加した `/usr/bin/python3.11` が必ず選ばれる", "priority がより高い `/usr/bin/python3.12` が選ばれ続ける", "`python3.11` と `python3.12` がラウンドロビンで交互に選ばれる", "priority は `--install` では無視されるため、どちらが選ばれるか未定である"]'::jsonb, 1, 'auto モードでは、通常は優先度が最も高い候補が選ばれる。したがって priority `2` の `/usr/bin/python3.12` がすでにあるなら、priority `1` の `/usr/bin/python3.11` を追加しても自動では 3.11 に切り替わらない。手動で切り替えるなら `update-alternatives --config python3` などを使う。', 'https://docs.python.org/3/using/cmdline.html', 'unpublished', false),
  (350, 'セクション100: 英文読解 (Python ExceptionGroup)', 'wraps a list ... so that の和訳', '次の文を日本語に訳したとき、最も適切なものはどれか。

> The builtin ExceptionGroup wraps a list of exception instances so that they can be raised together.', 'The builtin ExceptionGroup wraps a list of exception instances so that they can be raised together.', '["組み込みの ExceptionGroup は、例外インスタンスのリストを一緒に発生させるためにラップされる。", "組み込みの ExceptionGroup は、例外インスタンスのリストをまとめて発生させられるようにラップする。", "組み込みの ExceptionGroup は、例外インスタンスのリストをラップするので、それらは一緒に発生する。", "組み込みの ExceptionGroup は、例外インスタンスのリストをラップしたあと、それらをまとめて発生させる。"]'::jsonb, 1, '`so that they can be raised together` は目的を表す副詞節で、『それらをまとめて送出できるように』という意味。したがって、ExceptionGroup が例外インスタンスのリストをラップする目的を表した選択肢が正しい。受動態にしてしまう訳や、単なる結果・時系列として読む訳は不適切。', 'https://docs.python.org/3/library/exceptions.html#ExceptionGroup', 'unpublished', false),
  (351, 'セクション100: 英文読解 (Python ExceptionGroup)', 'itself の強調を訳す', '次の文を日本語に訳したとき、`itself` の訳として最も適切なものはどれか。

> It is an exception itself, so it can be caught like any other exception.', 'It is an exception itself, so it can be caught like any other exception.', '["それ自体が例外に似ているため、他の例外と同様に捕捉できる。", "それは例外そのものではないが、他の例外と同様に捕捉できる。", "それ自体が例外であるため、他のあらゆる例外と同様に捕捉できる。", "それは例外の一種であるため、一部の例外と同様に捕捉できる。"]'::jsonb, 2, '`itself` は強調の再帰代名詞で、『それ自体が』『まさにそれ自身が』の意味。`It is an exception itself` は『それ自体が例外である』となる。意味を弱めて『似ている』にしたり、否定にしたり、`any other exception` を『一部の例外』と狭めるのは不正確。', 'https://docs.python.org/3/library/exceptions.html#ExceptionGroup', 'unpublished', false),
  (352, 'セクション100: 英文読解 (Python ExceptionGroup)', 'so の訳し分け', '次の文の `so` の訳として最も適切なものはどれか。

> It is an exception itself, so it can be caught like any other exception.', 'It is an exception itself, so it can be caught like any other exception.', '["〜できるように", "〜にもかかわらず", "〜の場合は", "だから・したがって"]'::jsonb, 3, 'ここでの `so` は結果を表す接続詞で、『だから』『したがって』と訳すのが自然。`〜できるように` は `so that` の訳であり、単独の `so` とは異なる。譲歩や条件の意味でもない。', 'https://docs.python.org/3/library/exceptions.html#ExceptionGroup', 'unpublished', false),
  (353, 'セクション100: 英文読解 (Python ExceptionGroup)', '2文全体の和訳', '次の文全体の日本語訳として最も適切なものはどれか。

> The builtin ExceptionGroup wraps a list of exception instances so that they can be raised together. It is an exception itself, so it can be caught like any other exception.', 'The builtin ExceptionGroup wraps a list of exception instances so that they can be raised together. It is an exception itself, so it can be caught like any other exception.', '["組み込みの ExceptionGroup は例外インスタンスのリストをラップする。それは例外ではないが、他の例外と同様に捕捉できる。", "組み込みの ExceptionGroup は例外インスタンスのリストをまとめて発生させる。それ自体も例外であるが、他の例外とは異なる方法で捕捉する必要がある。", "組み込みの ExceptionGroup は例外インスタンスのリストをラップし、それらをまとめて発生させたあとに捕捉する。", "組み込みの ExceptionGroup は、例外インスタンスのリストをまとめて発生させられるようにラップする。それ自体が例外であるため、他のあらゆる例外と同様に捕捉することができる。"]'::jsonb, 3, '第1文の `so that ...` は目的『〜できるように』、第2文の `so ...` は結果『だから』『そのため』を表す。この2つを正しく訳し分け、`itself` を『それ自体が』、`like any other exception` を『他のあらゆる例外と同様に』と自然に処理している選択肢が最適。', 'https://docs.python.org/3/library/exceptions.html#ExceptionGroup', 'unpublished', false),
  (354, 'セクション100: 英文読解 (Python ExceptionGroup)', 'like any other exception の和訳', '次の文の `like any other exception` の訳として最も適切なものはどれか。

> it can be caught like any other exception', 'it can be caught like any other exception', '["ある例外と同じように", "どの例外とも異なるように", "いくつかの例外と同様に", "他のあらゆる例外と同様に"]'::jsonb, 3, '`any other ...` は『他のどの〜でも』『他のあらゆる〜』という広い範囲を指す。したがって `like any other exception` は『他のあらゆる例外と同様に』が最も適切。範囲を狭めて『ある例外』『いくつかの例外』とする訳は不正確。', 'https://docs.python.org/3/library/exceptions.html#ExceptionGroup', 'unpublished', false),
  (355, 'セクション100: 英文読解 (Python ExceptionGroup)', 'extracts from the group の和訳', '次の文を日本語に訳したとき、最も適切なものはどれか。

> each except* clause extracts from the group exceptions of a certain type', 'each except* clause extracts from the group exceptions of a certain type', '["各 `except*` 節はグループ内のすべての例外を特定の型に変換する。", "各 `except*` 節はグループから特定の型の例外を削除する。", "各 `except*` 節はグループから特定の型の例外を抽出する。", "各 `except*` 節は特定の型の例外をグループにまとめる。"]'::jsonb, 2, '`extracts from the group` は『グループから抽出する』、`exceptions of a certain type` は『特定の型の例外』という意味。`of a certain type` は `exceptions` を修飾する前置詞句であり、変換・削除・追加を意味しているわけではない。', 'https://docs.python.org/3/library/exceptions.html#ExceptionGroup', 'unpublished', false),
  (356, 'セクション100: 英文読解 (Python ExceptionGroup)', 'which shows ... の用法', '次の文の `which` の用法と訳として最も適切なものはどれか。

> In the following example, which shows a nested exception group, each except* clause extracts〜', 'In the following example, which shows a nested exception group, each except* clause extracts ...', '["限定用法の関係代名詞で『ネストされた例外グループを示す例において』", "疑問代名詞で『どの例がネストされた例外グループを示すか』", "非限定用法の関係代名詞で『次の例はネストされた例外グループを示しているが』", "限定用法の関係代名詞で『ネストされた例外グループを示す次の例において』"]'::jsonb, 2, 'コンマに挟まれた `which` は非限定用法の関係代名詞で、先行詞 `the following example` に補足説明を加えている。限定用法のように先行詞の範囲を絞るのではなく、『そしてその例は〜を示している』という補足的なニュアンスで訳すのが自然。', 'https://docs.python.org/3/library/exceptions.html#ExceptionGroup', 'unpublished', false),
  (357, 'セクション100: 英文読解 (Python ExceptionGroup)', 'while letting ... propagate の和訳', '次の文の `while letting all other exceptions propagate` の訳として最も適切なものはどれか。

> while letting all other exceptions propagate to other clauses', 'while letting all other exceptions propagate to other clauses', '["他のすべての例外が他の節へ伝播するのを防ぎながら", "他のすべての例外が他の節へ伝播した後で", "他のすべての例外が他の節へ伝播するかどうかを確認しながら", "他のすべての例外が他の節へ伝播するままにしながら"]'::jsonb, 3, '`let + O + 原形不定詞` は『O が〜するままにする』『O に〜させる』という形。ここでは `letting all other exceptions propagate` で『他のすべての例外が伝播するままにして』という意味になる。`while` は『〜する一方で』という対比を表し、防ぐという意味ではない。', 'https://docs.python.org/3/library/exceptions.html#ExceptionGroup', 'unpublished', false),
  (358, 'セクション100: 英文読解 (Python ExceptionGroup)', 'eventually to be reraised の和訳', '次の文の `eventually to be reraised` の訳として最も適切なものはどれか。

> letting all other exceptions propagate to other clauses and eventually to be reraised', 'letting all other exceptions propagate to other clauses and eventually to be reraised', '["最終的に再送出されることなく", "最終的に再送出されるべきではなく", "すぐに再送出されるために", "最終的に再送出されるために"]'::jsonb, 3, '`eventually` は『最終的に・いずれは』、`to be reraised` は受動態の不定詞で『再送出されること』を表す。ここでは『他の節へ伝播し、最終的には再送出される』という流れを述べており、否定や『すぐに』の意味は含まれない。', 'https://docs.python.org/3/library/exceptions.html#ExceptionGroup', 'unpublished', false),
  (359, 'セクション100: 英文読解 (Python ExceptionGroup)', 'except* 節の説明文全体の和訳', '次の文全体の日本語訳として最も適切なものはどれか。

> In the following example, which shows a nested exception group, each except* clause extracts from the group exceptions of a certain type while letting all other exceptions propagate to other clauses and eventually to be reraised.', 'In the following example, which shows a nested exception group, each except* clause extracts from the group exceptions of a certain type while letting all other exceptions propagate to other clauses and eventually to be reraised.', '["次の例はネストされた例外グループを示しており、各 `except*` 節はグループ内のすべての例外を抽出し、特定の型の例外だけを他の節へ伝播させる。", "次の例はネストされた例外グループを示しており、各 `except*` 節は特定の型の例外をグループに追加する一方で、他のすべての例外が最終的に再送出されるのを防ぐ。", "次の例はネストされた例外グループを示しており、各 `except*` 節はグループから特定の型の例外を抽出し、他のすべての例外を最終的に削除する。", "次の例はネストされた例外グループを示しており、各 `except*` 節はグループから特定の型の例外を抽出する一方で、他のすべての例外が他の節へ伝播し最終的に再送出されるままにする。"]'::jsonb, 3, '`extracts ...` と `while letting ...` の対比構造を保ちながら、`which shows ...` を補足説明として自然に処理している訳が正しい。`except*` 節は特定の型を抽出し、それ以外は他の節へ伝播し、最終的には再送出される、という説明になっている。', 'https://docs.python.org/3/library/exceptions.html#ExceptionGroup', 'unpublished', false),
  (360, 'セクション103: 英文読解 (Python 例外オブジェクト)', 'in order to be raised の和訳', '次の文の `in order to be raised` の訳として最も適切なものはどれか。

> When an exception is created in order to be raised', 'When an exception is created in order to be raised', '["送出されたために", "送出されることなく", "送出されるかどうかを確認するために", "送出されるために"]'::jsonb, 3, '`in order to ...` は目的を表す不定詞句で『〜するために』。ここでは `to be raised` が受動態の不定詞なので、『送出されるために』となる。過去の理由や否定の意味は含まれない。', 'https://docs.python.org/3/', 'unpublished', false),
  (361, 'セクション103: 英文読解 (Python 例外オブジェクト)', 'initialize with の with の用法', '次の文の `with information` の `with` の用法として最も適切なものはどれか。

> it is usually initialized with information that describes the error', 'it is usually initialized with information that describes the error', '["対立『〜に反して』", "原因『〜のせいで』", "付帯・手段『〜を使って・〜とともに』", "譲歩『〜にもかかわらず』"]'::jsonb, 2, 'ここでの `with` は、付帯・手段を表す前置詞で、『情報とともに』『情報を用いて』という意味。`initialize with ...` は技術文脈でよく見られる『〜で初期化する』という表現で、対立・原因・譲歩ではない。', 'https://docs.python.org/3/', 'unpublished', false),
  (362, 'セクション103: 英文読解 (Python 例外オブジェクト)', '関係代名詞節の数を数える', '次の文に含まれる関係代名詞節の数として正しいものはどれか。

> it is usually initialized with information that describes the error that has occurred', 'it is usually initialized with information that describes the error that has occurred', '["0個", "1個", "2個", "3個"]'::jsonb, 2, '`that describes the error` が `information` を修飾する関係詞節、`that has occurred` が `the error` を修飾する関係詞節で、合計 2 個ある。後ろの関係詞節が前の関係詞節の中の名詞をさらに修飾する、入れ子に近い形になっている。', 'https://docs.python.org/3/', 'unpublished', false),
  (363, 'セクション103: 英文読解 (Python 例外オブジェクト)', 'has occurred の現在完了の意味', '次の文の `that has occurred` に現在完了形が使われている理由として最も適切なものはどれか。

> information that describes the error that has occurred', 'information that describes the error that has occurred', '["未来に発生する予定のエラーを表すため", "現在進行中のエラーを表すため", "過去の推量を表すため", "過去に発生し現在も関連しているエラーを表すため"]'::jsonb, 3, '現在完了形 `has occurred` は、過去に起きた出来事が現在と結び付いていることを表す。ここでは『すでに発生しており、その内容を今説明する必要があるエラー』というニュアンスになり、単純過去より現在との関連が強い。', 'https://docs.python.org/3/', 'unpublished', false),
  (364, 'セクション103: 英文読解 (Python 例外オブジェクト)', '例外生成文全体の和訳', '次の文全体の日本語訳として最も適切なものはどれか。

> When an exception is created in order to be raised, it is usually initialized with information that describes the error that has occurred.', 'When an exception is created in order to be raised, it is usually initialized with information that describes the error that has occurred.', '["例外が送出された後、発生したエラーを説明する情報とともに通常初期化される。", "例外が生成されるとき、それは送出されるために発生したエラーの情報を削除する。", "例外が送出されるために生成される場合、それは発生したエラーを説明する情報なしに初期化されることが多い。", "例外が送出されるために生成される場合、通常、発生したエラーを説明する情報とともに初期化される。"]'::jsonb, 3, '`When ...` の副詞節は『送出されるために生成される場合』、主節の `is usually initialized` は『通常初期化される』、`with information that describes ...` は『〜を説明する情報とともに』となる。これらを過不足なく自然にまとめているのが正解。', 'https://docs.python.org/3/', 'unpublished', false),
  (365, 'セクション104: 英文読解 (Python add_note と traceback)', 'cases where の where の用法', '次の文の `where` の用法として正しいものはどれか。

> There are cases where it is useful to add information after the exception was caught.', 'There are cases where it is useful to add information after the exception was caught.', '["疑問副詞（『どこで』の意味）", "関係代名詞（`cases` を目的語として修飾）", "接続詞（『〜のところに』の意味）", "関係副詞（`cases` を先行詞として修飾）"]'::jsonb, 3, '`where` は `cases` のような抽象名詞も先行詞にとれる関係副詞。`where` の後ろは `it is useful to add information` という完全な節になっており、関係代名詞のように欠けた要素がない点が見分け方のポイント。', 'https://docs.python.org/3/library/exceptions.html#BaseException.add_note', 'unpublished', false),
  (366, 'セクション104: 英文読解 (Python add_note と traceback)', 'it is useful to の真主語', '次の文の形式主語構文において、真主語として正しいものはどれか。

> there are cases where it is useful to add information after the exception was caught', 'there are cases where it is useful to add information after the exception was caught', '["`it`", "`cases`", "`information`", "`to add information after the exception was caught`"]'::jsonb, 3, '`it is useful to ...` の `it` は形式主語で、真主語は後ろの不定詞句全体。ここでは `after the exception was caught` まで含めて『例外が捕捉された後で情報を追加すること』が内容になっている。', 'https://docs.python.org/3/library/exceptions.html#BaseException.add_note', 'unpublished', false),
  (367, 'セクション104: 英文読解 (Python add_note と traceback)', 'add_note(note) を説明する関係詞節', '次の文の関係代名詞節が修飾している名詞として正しいものはどれか。

> exceptions have a method add_note(note) that accepts a string and adds it to the exception''s notes list', 'exceptions have a method add_note(note) that accepts a string and adds it to the exception''s notes list', '["`exceptions`", "`a method add_note(note)`", "`a string`", "`the exception''s notes list`"]'::jsonb, 1, '関係代名詞 `that` の先行詞は直前の `a method add_note(note)`。`that accepts a string and adds it to ...` という節全体が、このメソッドの機能を説明している。`exceptions` は文全体の主語であり、先行詞ではない。', 'https://docs.python.org/3/library/exceptions.html#BaseException.add_note', 'unpublished', false),
  (368, 'セクション104: 英文読解 (Python add_note と traceback)', 'adds it to ... の it が指すもの', '次の文の `it` が指すものとして正しいものはどれか。

> that accepts a string and adds it to the exception''s notes list', 'that accepts a string and adds it to the exception''s notes list', '["`the method`", "`the exception`", "`the notes list`", "`a string`"]'::jsonb, 3, '`accepts a string` と `adds it to ...` が `and` で並列になっており、`it` は直前の目的語 `a string` を受けている。意味は『文字列を受け取り、それを例外の notes list に追加する』。', 'https://docs.python.org/3/library/exceptions.html#BaseException.add_note', 'unpublished', false),
  (369, 'セクション104: 英文読解 (Python add_note と traceback)', 'in the order they were added の役割', '次の文の `in the order they were added` の文法的な役割として最も適切なものはどれか。

> The standard traceback rendering includes all notes, in the order they were added, after the exception.', 'The standard traceback rendering includes all notes, in the order they were added, after the exception.', '["主語を修飾する形容詞句", "動詞 `includes` の目的語", "`all notes` の様態を表す挿入句", "文全体の条件を表す副詞節"]'::jsonb, 2, 'コンマで挟まれた `in the order they were added` は、`all notes` がどのような順序で含まれるかを補足する挿入句。取り除いても文は成立し、`they` は `all notes` を、`were added` は受動態を表している。', 'https://docs.python.org/3/library/exceptions.html#BaseException.add_note', 'unpublished', false),
  (370, 'セクション104: 英文読解 (Python add_note と traceback)', '受動態になっている表現を選ぶ', '次の文の受動態として使われている表現をすべて選んだ組み合わせとして正しいものはどれか。

> There are cases where it is useful to add information after the exception was caught.
> The standard traceback rendering includes all notes, in the order they were added, after the exception.', 'There are cases where it is useful to add information after the exception was caught.
The standard traceback rendering includes all notes, in the order they were added, after the exception.', '["`was caught` のみ", "`were added` のみ", "`was caught` と `were added` と `is useful`", "`was caught` と `were added`"]'::jsonb, 3, '`was caught` と `were added` はどちらも `be + 過去分詞` の受動態。`is useful` は `be動詞 + 形容詞` で、受動態ではなく形式主語構文の述語部分である。受動態と形容詞述語を区別するのがポイント。', 'https://docs.python.org/3/library/exceptions.html#BaseException.add_note', 'unpublished', false),
  (371, 'セクション105: 英文読解 (Python ExceptionGroup と文脈情報)', 'when collecting ... の役割', '次の文の `when collecting exceptions into an exception group` の文法的な役割として正しいものはどれか。

> when collecting exceptions into an exception group, we may want to add context information', 'when collecting exceptions into an exception group, we may want to add context information', '["主語を修飾する形容詞句", "時・条件を表す分詞構文", "目的を表す不定詞句", "結果を表す副詞節"]'::jsonb, 1, '`when + 現在分詞` の形で、完全な形は `when we are collecting exceptions into an exception group` と考えられる。主語 `we` と `be動詞` が省略された分詞構文で、時や条件のニュアンスを表す。', 'https://docs.python.org/3/library/exceptions.html#ExceptionGroup', 'unpublished', false),
  (372, 'セクション105: 英文読解 (Python ExceptionGroup と文脈情報)', 'may want to add の意味', '次の文の `may want to add` の意味として最も適切なものはどれか。

> we may want to add context information for the individual errors', 'we may want to add context information for the individual errors', '["必ず追加しなければならない", "追加するべきではないかもしれない", "追加することができない", "追加したいと思うかもしれない"]'::jsonb, 3, '`may` は可能性や控えめな推量を表し、`want to ...` は『〜したい』を表す。合わせて `may want to ...` は『〜したいと思うかもしれない』『〜したくなる場合がある』という控えめな表現になる。', 'https://docs.python.org/3/library/exceptions.html#ExceptionGroup', 'unpublished', false),
  (373, 'セクション105: 英文読解 (Python ExceptionGroup と文脈情報)', 'indicating ... の修飾先', '次の文の `indicating when this error has occurred` の文法的な役割として正しいものはどれか。

> each exception in the group has a note indicating when this error has occurred', 'each exception in the group has a note indicating when this error has occurred', '["主語 `each exception` を修飾する現在分詞句", "動詞 `has` を修飾する副詞句", "目的語 `a note` を修飾する現在分詞句", "文全体の結果を表す分詞構文"]'::jsonb, 2, '`indicating ...` は現在分詞句で、直前の名詞 `a note` を後ろから修飾している。意味は『このエラーがいつ発生したかを示すノート』で、関係詞節 `a note that indicates ...` に近い働き。', 'https://docs.python.org/3/library/exceptions.html#ExceptionGroup', 'unpublished', false),
  (374, 'セクション105: 英文読解 (Python ExceptionGroup と文脈情報)', 'when this error has occurred の役割', '次の文の `when this error has occurred` の文法的な役割として正しいものはどれか。

> a note indicating when this error has occurred', 'a note indicating when this error has occurred', '["時を表す副詞節", "条件を表す副詞節", "`a note` を修飾する関係副詞節", "`indicating` の目的語となる間接疑問文（名詞節）"]'::jsonb, 3, 'ここでの `when` は『いつ〜したか』を表す間接疑問文を導いており、節全体で名詞節として `indicating` の内容になっている。時を表す副詞節の `when` ではない点が重要。', 'https://docs.python.org/3/library/exceptions.html#ExceptionGroup', 'unpublished', false),
  (375, 'セクション105: 英文読解 (Python ExceptionGroup と文脈情報)', 'each exception in the group の一致', '次の文の `each exception in the group` について、動詞の形として正しいものはどれか。

> ___ each exception in the group has a note', '___ each exception in the group has a note', '["`Each exceptions in the group have`", "`Each exceptions in the group has`", "`Each exception in the group have`", "`Each exception in the group has`"]'::jsonb, 3, '`each` は常に単数扱いなので、名詞は単数形 `exception`、動詞も三人称単数の `has` になる。`in the group` は修飾句であって、動詞の数には影響しない。', 'https://docs.python.org/3/library/exceptions.html#ExceptionGroup', 'unpublished', false),
  (376, 'セクション105: 英文読解 (Python ExceptionGroup と文脈情報)', 'context information 文全体の和訳', '次の文全体の日本語訳として最も適切なものはどれか。

> For example, when collecting exceptions into an exception group, we may want to add context information for the individual errors. In the following each exception in the group has a note indicating when this error has occurred.', 'For example, when collecting exceptions into an exception group, we may want to add context information for the individual errors. In the following each exception in the group has a note indicating when this error has occurred.', '["例えば、例外グループから例外を取り出す際に、すべてのエラーに共通のコンテキスト情報を追加しなければならない。以下の例では、グループ内のすべての例外が発生したエラーの内容を示すノートを持っている。", "例えば、例外を例外グループに収集する際に、個々のエラーに対してコンテキスト情報を削除したい場合がある。以下の例では、グループ内のそれぞれの例外がエラーの種類を示すノートを持っている。", "例えば、例外を例外グループに収集する際に、個々のエラーに対してコンテキスト情報を追加したい場合がある。以下の例では、グループ内のそれぞれの例外がこのエラーがいつ発生したかを示すノートを持っている。", "例えば、例外グループを収集する際に、個々のエラーに対してコンテキスト情報を追加する必要はない。以下の例では、グループ内のいくつかの例外がエラーの発生時刻を示すノートを持っている。"]'::jsonb, 2, '`when collecting exceptions into an exception group` は『例外を例外グループに収集する際に』、`may want to add` は『追加したい場合がある』、`indicating when this error has occurred` は『このエラーがいつ発生したかを示す』となる。これらをすべて自然に反映している選択肢が正解。', 'https://docs.python.org/3/library/exceptions.html#ExceptionGroup', 'unpublished', false),
  (377, 'セクション106: 英文読解 (Python 自動化とスクリプト)', 'find that の that の役割', '次の文の `that` の文法的な役割として正しいものはどれか。

> you find that there''s some task you''d like to automate', 'you find that there''s some task you''d like to automate', '["関係代名詞（`task` を修飾）", "指示代名詞（『それ』の意味）", "関係副詞（`find` を修飾）", "接続詞（`find` の目的語となる名詞節を導く）"]'::jsonb, 3, '`find that ...` の `that` は名詞節を導く接続詞で、`find` の目的語になっている。後ろには `there''s some task ...` という完全な節が続いており、関係代名詞のように欠けた要素はない。', 'https://docs.python.org/3/', 'unpublished', false),
  (378, 'セクション106: 英文読解 (Python 自動化とスクリプト)', 'you''d like to automate の修飾関係', '次の文の `you''d like to automate` の文法的な役割として正しいものはどれか。

> there''s some task you''d like to automate', 'there''s some task you''d like to automate', '["`there''s` の補語となる形容詞節", "`task` を修飾する関係代名詞節（目的格の関係代名詞が省略）", "`task` を修飾する関係副詞節", "時を表す副詞節"]'::jsonb, 1, '完全な形は `some task (that/which) you''d like to automate`。`automate` の目的語が欠けているので、目的格の関係代名詞 `that/which` が省略された関係詞節と判断できる。', 'https://docs.python.org/3/', 'unpublished', false),
  (379, 'セクション106: 英文読解 (Python 自動化とスクリプト)', 'or と and の並列構造', '次の文の並列構造として正しいものはどれか。

> you may wish to perform a search-and-replace over a large number of text files, or rename and rearrange a bunch of photo files in a complicated way', 'you may wish to perform a search-and-replace over a large number of text files, or rename and rearrange a bunch of photo files in a complicated way', '["`perform` と `rename` のみが並列", "`perform`・`rename`・`rearrange` の3つが並列", "`perform a search-and-replace ...` と `rename and rearrange a bunch of photo files ...` の2つが `or` で並列、かつ `rename` と `rearrange` が `and` で並列", "`search`・`replace`・`rename`・`rearrange` の4つが並列"]'::jsonb, 2, '`may wish to` に続く動作として、`perform ...` と `rename and rearrange ...` が `or` で並列になっている。さらに後半では `rename` と `rearrange` が `and` で並列になっており、入れ子の並列構造を作っている。', 'https://docs.python.org/3/', 'unpublished', false),
  (380, 'セクション106: 英文読解 (Python 自動化とスクリプト)', 'eventually の和訳', '次の文の `eventually` の訳として最も適切なものはどれか。

> If you do much work on computers, eventually you find that there''s some task you''d like to automate.', 'If you do much work on computers, eventually you find that there''s some task you''d like to automate.', '["突然", "めったに", "すでに", "やがて・最終的に"]'::jsonb, 3, '`eventually` は『やがて』『最終的に』『いずれは』を表す副詞で、時間の経過の中でそうなるというニュアンスを持つ。`suddenly`・`rarely`・`already` とは意味が異なる。', 'https://docs.python.org/3/', 'unpublished', false),
  (381, 'セクション106: 英文読解 (Python 自動化とスクリプト)', 'over a large number of text files の和訳', '次の文の `over a large number of text files` の訳として最も適切なものはどれか。

> you may wish to perform a search-and-replace over a large number of text files', 'you may wish to perform a search-and-replace over a large number of text files', '["多数のテキストファイルを超えて", "多数のテキストファイルの上に", "多数のテキストファイルに対して・わたって", "多数のテキストファイルの代わりに"]'::jsonb, 2, 'ここでの `over` は物理的な『上に』ではなく、範囲・対象を表して『〜に対して』『〜にわたって』の意味。`perform a search-and-replace over ...` で『多数のファイルに対して検索置換を行う』となる。', 'https://docs.python.org/3/', 'unpublished', false),
  (382, 'セクション106: 英文読解 (Python 自動化とスクリプト)', '自動化紹介文全体の和訳', '次の文全体の日本語訳として最も適切なものはどれか。

> If you do much work on computers, eventually you find that there''s some task you''d like to automate. For example, you may wish to perform a search-and-replace over a large number of text files, or rename and rearrange a bunch of photo files in a complicated way. Perhaps you''d like to write a small custom database, or a specialized GUI application, or a simple game.', 'If you do much work on computers, eventually you find that there''s some task you''d like to automate. For example, you may wish to perform a search-and-replace over a large number of text files, or rename and rearrange a bunch of photo files in a complicated way. Perhaps you''d like to write a small custom database, or a specialized GUI application, or a simple game.', '["コンピュータで少し作業をすれば、すぐに自動化できないタスクがあることに気づく。例えば、少数のテキストファイルを検索したり、写真ファイルを簡単に整理したりすることができる。また、大規模なデータベースや複雑なGUIアプリケーションを作りたいと思うかもしれない。", "コンピュータで多くの作業をするなら、突然自動化したいタスクが見つかるだろう。例えば、多数のテキストファイルを削除したり、たくさんの写真ファイルを複雑な方法でコピーしたりすることがある。おそらく、大きなデータベースや汎用のGUIアプリケーション、または複雑なゲームを書きたいと思うだろう。", "コンピュータで多くの作業をするなら、やがて自動化すべきタスクが必ず見つかる。例えば、少数のテキストファイルに検索と置換を実行したり、写真ファイルを単純な方法で名前変更したりする必要がある。また、大きなデータベースや専用のGUIアプリケーションを書かなければならない。", "コンピュータで多くの作業をするなら、やがて自動化したいタスクが出てくることに気づくだろう。例えば、多数のテキストファイルに対して検索と置換を実行したり、たくさんの写真ファイルを複雑な方法で名前変更・並べ替えしたりしたい場合があるかもしれない。あるいは、小さなカスタムデータベース、専用のGUIアプリケーション、またはシンプルなゲームを作りたいと思うかもしれない。"]'::jsonb, 3, '`eventually`、`you''d like to automate`、`may wish to`、`a bunch of`、`in a complicated way`、`Perhaps` をすべて自然に訳し、`rename and rearrange` の並列も正しく反映しているのが正解。他の選択肢は `much work`・`eventually`・動詞の意味・助動詞のニュアンスを取り違えている。', 'https://docs.python.org/3/', 'unpublished', false),
  (383, 'セクション107: 英文読解 (Python 拡張と言語設計)', 'may have to work ... but find ... の構造', '次の文の `may have to work〜 but find〜` の構造として正しいものはどれか。

> you may have to work with several C/C++/Java libraries but find the usual write/compile/test/re-compile cycle is too slow', 'you may have to work with several C/C++/Java libraries but find the usual write/compile/test/re-compile cycle is too slow', '["`may have to work` と `but find` が異なる主語を持つ2つの独立した文", "`may` が `have to work` にのみかかり、`find` は別の助動詞を持つ", "`have to work` と `find` が `but` で対比される独立した節", "`may` が `have to work` と `find` の両方にかかり、`but` で対比される並列構造"]'::jsonb, 3, '構造としては `you may have to work ... but (may) find ...` と考えるのが自然で、2つ目の `may` は省略されている。したがって `but` は『作業しなければならないかもしれないが、一方で〜と感じるかもしれない』という対比を作っている。', 'https://docs.python.org/3/', 'unpublished', false),
  (384, 'セクション107: 英文読解 (Python 拡張と言語設計)', 'find writing ... a tedious task の SVOC', '次の文の `find writing the testing code a tedious task` の SVOC 構造として正しいものはどれか。

> find writing the testing code a tedious task', 'find writing the testing code a tedious task', '["S=`you`, V=`find`, O=`the testing code`, C=`a tedious task`", "S=`you`, V=`find writing`, O=`the testing code`, C=`a tedious task`", "S=`you`, V=`find`, O=`a tedious task`, C=`writing the testing code`", "S=`you`, V=`find`, O=`writing the testing code`, C=`a tedious task`"]'::jsonb, 3, '`find + O + C` の SVOC 構文で、『O を C だと感じる』の意味になる。ここでは `writing the testing code` という動名詞句全体が目的語、`a tedious task` が目的語補語。動名詞句を途中で分割しないことがポイント。', 'https://docs.python.org/3/', 'unpublished', false),
  (385, 'セクション107: 英文読解 (Python 拡張と言語設計)', 'could use の could のニュアンス', '次の文の `that could use an extension language` の `could` の意味として最も適切なものはどれか。

> you''ve written a program that could use an extension language', 'you''ve written a program that could use an extension language', '["過去の能力『使うことができた』", "過去の習慣『使うことがあった』", "可能性・仮定『使えると便利な・使えるかもしれない』", "過去の推量『使ったに違いない』"]'::jsonb, 2, 'ここでの `could` は過去の能力ではなく、仮定的・可能性的なニュアンスで、『拡張言語を使えると便利な』『使えるかもしれない』という意味に近い。`must have` のような過去の強い推量でもない。', 'https://docs.python.org/3/', 'unpublished', false),
  (386, 'セクション107: 英文読解 (Python 拡張と言語設計)', 'a whole new language の whole の役割', '次の文の `a whole new language` の `whole` の役割として正しいものはどれか。

> you don''t want to design and implement a whole new language for your application', 'you don''t want to design and implement a whole new language for your application', '["名詞（『全体』の意味）", "副詞（『まったく・完全に』という強調）", "形容詞（『全体の』という意味で `language` を修飾）", "形容詞（`new` を強調し『まったく新しい』という意味）"]'::jsonb, 3, '`a whole new ...` の `whole` は、`new` を強めて『まったく新しい』という意味合いを作る。語法上は `brand new` に近い強調で、単に『全体の言語』という意味ではない。', 'https://docs.python.org/3/', 'unpublished', false),
  (387, 'セクション107: 英文読解 (Python 拡張と言語設計)', 'may have to の和訳', '次の文の `may have to` の訳として最も適切なものはどれか。

> you may have to work with several C/C++/Java libraries', 'you may have to work with several C/C++/Java libraries', '["〜するべきだ", "〜することができる", "〜する必要はない", "〜しなければならないかもしれない"]'::jsonb, 3, '`may` は可能性・推量、`have to` は義務を表すため、合わせると『〜しなければならないかもしれない』という控えめな義務になる。`should`・`can`・`don''t have to` とは意味が異なる。', 'https://docs.python.org/3/', 'unpublished', false),
  (388, 'セクション107: 英文読解 (Python 拡張と言語設計)', '拡張と言語設計の段落全体の和訳', '次の文全体の日本語訳として最も適切なものはどれか。

> If you''re a professional software developer, you may have to work with several C/C++/Java libraries but find the usual write/compile/test/re-compile cycle is too slow. Perhaps you''re writing a test suite for such a library and find writing the testing code a tedious task. Or maybe you''ve written a program that could use an extension language, and you don''t want to design and implement a whole new language for your application.', 'If you''re a professional software developer, you may have to work with several C/C++/Java libraries but find the usual write/compile/test/re-compile cycle is too slow. Perhaps you''re writing a test suite for such a library and find writing the testing code a tedious task. Or maybe you''ve written a program that could use an extension language, and you don''t want to design and implement a whole new language for your application.', '["プロのソフトウェア開発者であれば、いくつかのC/C++/Javaライブラリを使って作業しなければならず、通常のサイクルが速すぎると感じるかもしれない。おそらくそのようなライブラリのテストスイートを書いていて、テストコードを書くことを楽しい作業だと感じているだろう。もしくは、拡張言語を必要としないプログラムを書いたが、まったく新しい言語を設計・実装したいという場合もあるだろう。", "プロのソフトウェア開発者でなくても、いくつかのC/C++/Javaライブラリを使って作業する必要があり、通常の書く・コンパイル・テスト・再コンパイルのサイクルが遅すぎると感じることがある。おそらくそのようなライブラリのテストスイートを読んでいて、テストコードを書くことを重要な作業だと感じているかもしれない。", "プロのソフトウェア開発者であれば、いくつかのC/C++/Javaライブラリを削除しなければならない一方で、通常のサイクルが遅すぎると感じるかもしれない。おそらくそのようなライブラリのテストスイートを書いていて、テストコードを書くことを重要な作業だと感じているだろう。もしくは、拡張言語を使えるプログラムをすでに書いたが、新しい言語を設計したいという場合もあるだろう。", "プロのソフトウェア開発者であれば、いくつかのC/C++/Javaライブラリを使って作業しなければならない一方で、通常の書く・コンパイル・テスト・再コンパイルのサイクルが遅すぎると感じるかもしれない。あるいは、そのようなライブラリのテストスイートを書いていて、テストコードを書くことを退屈な作業だと感じているかもしれない。もしくは、拡張言語を使えると便利なプログラムをすでに書いたものの、アプリケーションのためにまったく新しい言語を設計・実装したくないという場合もあるだろう。"]'::jsonb, 3, '`may have to work ... but find ...`、`a tedious task`、`could use`、`a whole new language`、`don''t want to` をすべて自然に訳しているのが正解。誤答は `too slow` を逆に訳したり、`tedious` を肯定的に解したり、`work with` を別の動作へすり替えたりしている。', 'https://docs.python.org/3/', 'unpublished', false),
  (389, 'セクション108: 英文読解 (Python の特徴と比較)', 'offering ... の分詞句の役割', '次の文の `offering much more structure and support for large programs` の文法的な役割として正しいものはどれか。

> it is a real programming language, offering much more structure and support for large programs than shell scripts or batch files can offer', 'it is a real programming language, offering much more structure and support for large programs than shell scripts or batch files can offer', '["主語 `it` を修飾する形容詞句", "動詞 `is` の目的語となる動名詞句", "時を表す分詞構文", "`a real programming language` を補足説明する現在分詞句"]'::jsonb, 3, 'コンマの後の `offering ...` は現在分詞句で、直前の `a real programming language` を補足説明している。意味としては `which offers ...` に近く、動名詞のように文の要素として目的語になるわけではない。', 'https://docs.python.org/3/', 'unpublished', false),
  (390, 'セクション108: 英文読解 (Python の特徴と比較)', 'being a very-high-level language の意味役割', '次の文の `being a very-high-level language` の文法的な役割として正しいものはどれか。

> being a very-high-level language, it has high-level data types built in', 'being a very-high-level language, it has high-level data types built in', '["時を表す分詞構文（『〜のとき』）", "条件を表す分詞構文（『〜であれば』）", "譲歩を表す分詞構文（『〜にもかかわらず』）", "理由を表す分詞構文（『〜であるため』）"]'::jsonb, 3, 'ここでは `because it is a very-high-level language` に近い理由の意味で使われている。『非常に高水準な言語であるため、高水準のデータ型が組み込まれている』という因果関係が自然。', 'https://docs.python.org/3/', 'unpublished', false),
  (391, 'セクション108: 英文読解 (Python の特徴と比較)', 'has high-level data types built in の構造', '次の文の `has high-level data types built in` の文法構造として正しいものはどれか。

> it has high-level data types built in', 'it has high-level data types built in', '["S=`it`, V=`has built`, O=`high-level data types`, 副詞=`in`", "S=`it`, V=`has`, O=`built`, C=`high-level data types`", "S=`it`, V=`has`, O=`high-level data types`, C=`built in`（SVOC構文）", "S=`it`, V=`has in`, O=`high-level data types`, 形容詞=`built`"]'::jsonb, 2, '`have + O + past participle` の形で、『O が〜された状態にある』『O を〜してある』を表す SVOC 構文。ここでは `high-level data types` が目的語、`built in` がその状態を表す目的語補語になっている。', 'https://docs.python.org/3/', 'unpublished', false),
  (392, 'セクション108: 英文読解 (Python の特徴と比較)', 'yet の用法', '次の文の `yet` の用法として正しいものはどれか。

> Python is applicable to a much larger problem domain than Awk or even Perl, yet many things are at least as easy in Python as in those languages.', 'Python is applicable to a much larger problem domain than Awk or even Perl, yet many things are at least as easy in Python as in those languages.', '["副詞（『まだ』の意味）", "副詞（『すでに』の意味）", "副詞（『さらに』の意味）", "逆接の接続詞（『それでも・しかし』の意味）"]'::jsonb, 3, 'ここでの `yet` は `but` に近い逆接の接続詞で、『それでも』『しかし』の意味を表す。副詞の `yet`（まだ）は別用法。前半と後半の内容を逆説的につないでいるのがポイント。', 'https://docs.python.org/3/', 'unpublished', false),
  (393, 'セクション108: 英文読解 (Python の特徴と比較)', 'at least as easy ... の和訳', '次の文の `at least as easy in Python as in those languages` の訳として最も適切なものはどれか。

> many things are at least as easy in Python as in those languages', 'many things are at least as easy in Python as in those languages', '["Pythonではそれらの言語よりも簡単なことが多い", "Pythonではそれらの言語よりも難しいことが多い", "Pythonではそれらの言語と同じくらい難しいことが多い", "Pythonではそれらの言語と少なくとも同じくらい簡単なことが多い"]'::jsonb, 3, '`as ... as` は同等比較で『同じくらい〜』、`at least` は『少なくとも』。合わせると『少なくとも同じくらい簡単』となり、『同等以上に簡単』という含みを持つ。', 'https://docs.python.org/3/', 'unpublished', false),
  (394, 'セクション108: 英文読解 (Python の特徴と比較)', 'Python の特徴説明全体の和訳', '次の文全体の日本語訳として最も適切なものはどれか。

> Python is simple to use, but it is a real programming language, offering much more structure and support for large programs than shell scripts or batch files can offer. On the other hand, Python also offers much more error checking than C, and, being a very-high-level language, it has high-level data types built in, such as flexible arrays and dictionaries. Because of its more general data types Python is applicable to a much larger problem domain than Awk or even Perl, yet many things are at least as easy in Python as in those languages.', 'Python is simple to use, but it is a real programming language, offering much more structure and support for large programs than shell scripts or batch files can offer. On the other hand, Python also offers much more error checking than C, and, being a very-high-level language, it has high-level data types built in, such as flexible arrays and dictionaries. Because of its more general data types Python is applicable to a much larger problem domain than Awk or even Perl, yet many things are at least as easy in Python as in those languages.', '["Pythonは使いにくいが本格的なプログラミング言語であり、シェルスクリプトやバッチファイルと同程度の構造とサポートを提供する。一方でPythonはCよりもエラーチェックが少なく、低水準な言語であるため、低水準なデータ型が組み込まれている。より限定的なデータ型を持つためPythonはAwkやPerlよりも狭い問題領域にしか適用できず、多くのことがそれらの言語よりも難しい。", "Pythonは使いやすく、シェルスクリプトやバッチファイルと同じ程度の構造とサポートしか提供しない簡易的な言語だ。一方でPythonはCと同程度のエラーチェックを提供し、高水準なデータ型が組み込まれている。より汎用的なデータ型を持つためPythonはAwkやPerlと同じ問題領域に適用でき、多くのことがそれらの言語よりも難しい。", "Pythonは使いやすいが本格的なプログラミング言語であり、シェルスクリプトやバッチファイルよりも少ない構造とサポートを提供する。一方でPythonはCよりもエラーチェックが多く、高水準なデータ型が組み込まれている。より汎用的なデータ型を持つためPythonはAwkやPerlよりも広い問題領域に適用できるが、多くのことがそれらの言語よりも難しい。", "Pythonは使いやすいが本格的なプログラミング言語であり、シェルスクリプトやバッチファイルよりも大規模なプログラムに対してはるかに多くの構造とサポートを提供する。一方でPythonはCよりもはるかに多くのエラーチェックを提供し、非常に高水準な言語であるため柔軟な配列や辞書のような高水準なデータ型が組み込まれている。より汎用的なデータ型を持つためPythonはAwkはおろかPerlよりもはるかに広い問題領域に適用できるが、それでも多くのことはPythonではそれらの言語と少なくとも同じくらい簡単だ。"]'::jsonb, 3, '`much more structure and support`、`much more error checking`、`being a very-high-level language`、`even Perl`、`yet`、`at least as easy` をすべて正確に訳しているのが正解。誤答は比較や逆接、理由、語彙の強さを取り違えている。', 'https://docs.python.org/3/', 'unpublished', false),
  (395, 'セクション109: 英文読解 (Python モジュールと標準ライブラリ)', 'allows you to split の構造', '次の文の `allows you to split` の文法構造として正しいものはどれか。

> Python allows you to split your program into modules', 'Python allows you to split your program into modules', '["S=`Python`, V=`allows`, O=`to split`, C=`you`", "S=`Python`, V=`allows to split`, O=`you`, C=`your program`", "S=`Python`, V=`allows`, O=`your program`, C=`to split`", "S=`Python`, V=`allows`, O=`you`, C=`to split your program into modules`（SVOC構文）"]'::jsonb, 3, '`allow + O + to不定詞` の形で、『O が〜することを可能にする』を表す。ここでは `you` が目的語、`to split your program into modules` が目的語補語。`split A into B` で『A を B に分割する』という表現にもなっている。', 'https://docs.python.org/3/', 'unpublished', false),
  (396, 'セクション109: 英文読解 (Python モジュールと標準ライブラリ)', 'that can be reused ... の修飾先', '次の文の `that can be reused in other Python programs` の文法的な役割として正しいものはどれか。

> modules that can be reused in other Python programs', 'modules that can be reused in other Python programs', '["`Python` を修飾する関係代名詞節", "`program` を修飾する関係代名詞節", "文全体の結果を表す副詞節", "`modules` を修飾する関係代名詞節"]'::jsonb, 3, '関係代名詞 `that` の先行詞は `modules`。`can be reused` は『再利用できる』という助動詞 + 受動態で、`in other Python programs` がその利用先を示している。', 'https://docs.python.org/3/', 'unpublished', false),
  (397, 'セクション109: 英文読解 (Python モジュールと標準ライブラリ)', 'to start learning to program の構造', '次の文の `to start learning to program in Python` における不定詞の構造として正しいものはどれか。

> as examples to start learning to program in Python', 'as examples to start learning to program in Python', '["`to start` のみが不定詞で `learning to program` は動名詞句", "`to program` のみが不定詞で `start learning` は動詞句", "`to start` と `to program` が同じ階層で並列する不定詞", "`to start learning ...` と `to program ...` が連鎖する二重の不定詞構造"]'::jsonb, 3, '`to start learning to program` は、不定詞 `to start` に動名詞 `learning` が続き、その `learning` の内容としてさらに `to program` が続く連鎖構造。『Pythonでプログラミングすることを学び始めるための』という意味になる。', 'https://docs.python.org/3/', 'unpublished', false),
  (398, 'セクション109: 英文読解 (Python モジュールと標準ライブラリ)', 'and even interfaces の even の役割', '次の文の `and even interfaces` の `even` の役割として正しいものはどれか。

> things like file I/O, system calls, sockets, and even interfaces to graphical user interface toolkits like Tk', 'things like file I/O, system calls, sockets, and even interfaces to graphical user interface toolkits like Tk', '["副詞（『均等に』の意味）", "形容詞（『平らな』の意味）", "接続詞（『〜でさえあれば』の意味）", "副詞（`interfaces` を強調し『〜さえも』の意味）"]'::jsonb, 3, '`even` は副詞として直後の `interfaces` を強調し、『インターフェースさえも』というニュアンスを加えている。並列された要素の最後に置かれ、意外性のある項目を際立たせる用法。', 'https://docs.python.org/3/', 'unpublished', false),
  (399, 'セクション109: 英文読解 (Python モジュールと標準ライブラリ)', 'comes with の和訳', '次の文の `comes with` の訳として最も適切なものはどれか。

> It comes with a large collection of standard modules', 'It comes with a large collection of standard modules', '["〜と一緒に来る", "〜から生まれる", "〜に取り組む", "〜を備えている・〜が付属している"]'::jsonb, 3, '`come with ...` は『〜を備えている』『〜が付属している』という慣用表現。ここでは Python が標準モジュール群を最初から持っていることを述べている。直訳の『一緒に来る』では文脈に合わない。', 'https://docs.python.org/3/', 'unpublished', false),
  (400, 'セクション109: 英文読解 (Python モジュールと標準ライブラリ)', 'モジュール紹介文全体の和訳', '次の文全体の日本語訳として最も適切なものはどれか。

> Python allows you to split your program into modules that can be reused in other Python programs. It comes with a large collection of standard modules that you can use as the basis of your programs — or as examples to start learning to program in Python. Some of these modules provide things like file I/O, system calls, sockets, and even interfaces to graphical user interface toolkits like Tk.', 'Python allows you to split your program into modules that can be reused in other Python programs. It comes with a large collection of standard modules that you can use as the basis of your programs — or as examples to start learning to program in Python. Some of these modules provide things like file I/O, system calls, sockets, and even interfaces to graphical user interface toolkits like Tk.', '["Pythonは他のプログラムからモジュールをインポートすることを可能にする。Pythonには少数の標準モジュールが付属しており、それらはプログラムの最終的な成果物として使える。これらのモジュールはすべて、ファイル操作やTkのようなGUIツールキットへのインターフェースを提供する。", "Pythonはプログラムを複数のファイルに分割することを可能にするが、それらは他のPythonプログラムでは再利用できない。Pythonには標準モジュールのコレクションが付属しており、プログラムの基盤としてのみ使える。これらのモジュールの一部はファイルI/Oやソケットを提供するが、GUIへのインターフェースは提供しない。", "Pythonは他のプログラムで再利用できるモジュールにプログラムを分割することを可能にする。Pythonには大規模な標準モジュールのコレクションが付属しており、プログラムの基盤としてのみ使える。これらのモジュールはすべてファイルI/O、システムコール、ソケットを提供するが、GUIへのインターフェースは提供しない。", "Pythonは他のPythonプログラムで再利用できるモジュールにプログラムを分割することを可能にする。Pythonには大規模な標準モジュールのコレクションが付属しており、プログラムの基盤として、あるいはPythonでのプログラミングを学び始めるための例として使える。これらのモジュールの一部はファイルI/O、システムコール、ソケット、さらにはTkのようなGUIツールキットへのインターフェースのようなものを提供する。"]'::jsonb, 3, '`that can be reused`、`as the basis ... or as examples ...`、`to start learning to program`、`Some of these modules`、`and even interfaces` をすべて正確に反映しているのが正解。他の選択肢は `split into modules` の意味、`can be reused`、`Some of`、GUIインターフェースの有無などを誤っている。', 'https://docs.python.org/3/', 'unpublished', false),
  (401, 'セクション110: Python コマンドと実行環境', 'Ubuntu 22.04 の `python` コマンド既定動作', 'Ubuntu 22.04で `python` コマンドを実行したとき、デフォルトの挙動として正しいものはどれか。', 'python', '["Python 2.x が実行される", "Python 3.x が実行される", "Python 2.x と Python 3.x のどちらかを選択するメニューが表示される", "コマンド自体が存在せずエラーになる"]'::jsonb, 3, 'Ubuntu 22.04 ではデフォルトで `python` コマンドは存在しない。これは Python 2.x と Python 3.x の共存時代の経緯から、意図的に `python` という名前でインストールしない仕様によるもの。`python-is-python2` または `python-is-python3` パッケージを入れると初めて `python` コマンドが定義される。', 'https://docs.python.org/3/using/cmdline.html', 'unpublished', false),
  (402, 'セクション110: Python コマンドと実行環境', '`python -m http.server` の動作', '`python -m http.server 8080` を実行したときの動作として正しいものはどれか。', 'python -m http.server 8080', '["ポート8080でFTPサーバーを起動する", "ポート8080でSSHサーバーを起動する", "ポート8080でメールサーバーを起動する", "カレントディレクトリをポート8080でHTTPサーバーとして公開する"]'::jsonb, 3, '`python -m module` はモジュールをスクリプトとして実行する構文。`http.server` モジュールはカレントディレクトリを簡易 Web サーバーとして公開する機能を持つ。`-m` は内部的にそのモジュールのソースを実行する形に近い。', 'https://docs.python.org/3/using/cmdline.html', 'unpublished', false),
  (403, 'セクション110: Python コマンドと実行環境', '`apt_pkg` エラーの根本原因', '次のトラブルの根本原因として最も適切なものはどれか。

> Ubuntu 22.04で `python3 -V` を実行すると `Python 3.11.0rc1` と表示されるが、OS標準ツールが `ModuleNotFoundError` を起こした。', 'python3 -V
# -> Python 3.11.0rc1
# OS tool -> ModuleNotFoundError: No module named ''apt_pkg''', '["Python 3.11.0rc1 はリリース候補版であるためモジュールが不完全だった", "`python3-apt` パッケージが破損していた", "`/usr/bin/python3` が `update-alternatives` 経由で `python3.11` に切り替わっており、OS標準の `python3.10` と不整合になっていた", "Ubuntu 22.04 は Python 3.11 に対応していない"]'::jsonb, 2, 'Ubuntu 22.04 の標準 Python は `python3.10` であり、`python3-apt` 由来の `apt_pkg` は `python3.10` 向けにビルドされている。`update-alternatives` などで `python3.11` に切り替えると、OS ツールが `python3.11` で `python3.10` 向けの `apt_pkg` を読もうとして不整合が起きる。', 'https://docs.python.org/3/using/cmdline.html', 'unpublished', false),
  (404, 'セクション110: Python コマンドと実行環境', '`ln -sf` による alternatives 復旧', '次のコマンドの意味として正しいものはどれか。

> sudo ln -sf /usr/bin/python3.10 /etc/alternatives/python3', 'sudo ln -sf /usr/bin/python3.10 /etc/alternatives/python3', '["`python3.10` を削除して `python3.11` にリンクする", "`python3.10` のシンボリックリンクを `/usr/bin` に新規作成する", "`python3.10` を `/etc/alternatives/` にコピーする", "`/etc/alternatives/python3` のシンボリックリンクを `python3.10` に強制的に上書きして戻す"]'::jsonb, 3, '`ln -sf` の `-s` はシンボリックリンク作成、`-f` は既存リンクの強制上書き。このコマンドにより `/etc/alternatives/python3 -> /usr/bin/python3.10` というリンクへ戻され、`/usr/bin/python3 -> /etc/alternatives/python3 -> /usr/bin/python3.10` という参照チェーンが復元される。', 'https://docs.python.org/3/using/cmdline.html', 'unpublished', false),
  (405, 'セクション110: Python コマンドと実行環境', 'Ubuntu 22.04 で Python 3.11 を安全に使う方法', 'Ubuntu 22.04において、開発用に Python 3.11 を使う場合の最も安全な方法はどれか。', 'python3.11
python3.11 -m venv .venv', '["`sudo ln -sf /usr/bin/python3.11 /usr/bin/python3` でシステムPythonを書き換える", "`update-alternatives` でシステムの `python3` を `python3.11` に切り替える", "`python3` コマンドを削除して `python3.11` を代わりに配置する", "`python3.11` を直接使うか `python3.11 -m venv .venv` で仮想環境を作成して分離する"]'::jsonb, 3, 'OS 標準の `python3` は Ubuntu 自体を動かすための Python であり、切り替えると OS ツールとの不整合が起きやすい。開発用 Python はシステムから分離し、`python3.11` を直接使うか、`venv` で仮想環境を作って使うのが安全。', 'https://docs.python.org/3/using/cmdline.html', 'unpublished', false),
  (406, 'セクション110: Python コマンドと実行環境', '`python3 -m zipfile -c` の動作', '次のコマンドの説明として正しいものはどれか。

> python3 -m zipfile -c archive.zip file1.txt file2.txt', 'python3 -m zipfile -c archive.zip file1.txt file2.txt', '["`archive.zip` を展開して `file1.txt` と `file2.txt` を取り出す", "`archive.zip` の内容を一覧表示する", "`archive.zip` が壊れていないか検証する", "`file1.txt` と `file2.txt` を `archive.zip` という名前の zip ファイルに圧縮する"]'::jsonb, 3, '`python -m zipfile` は `zipfile` モジュールをスクリプトとして実行する。`-c` (`create`) は新しい zip アーカイブを作るオプションで、指定ファイルを `archive.zip` にまとめる。展開は通常 `-e` を使う。', 'https://docs.python.org/3/using/cmdline.html', 'unpublished', false),
  (407, 'セクション110: Python コマンドと実行環境', 'Ubuntu 22.04 で `/usr/bin/python` がない理由', 'Ubuntu 22.04で `/usr/bin/python` が存在しない理由として最も適切なものはどれか。', 'ls -l /usr/bin/python', '["Python自体がインストールされていないため", "Ubuntu 22.04はPythonを公式サポートしていないため", "Python 2 と Python 3 の混在時代の経緯から、`python` コマンドをデフォルトでインストールしない方針が取られているため", "セキュリティ上の理由でシンボリックリンクが禁止されているため"]'::jsonb, 2, 'Ubuntu や Debian 系では、Python 2 と Python 3 が混在していた時代の経緯から、`python` という名前をデフォルトで提供しない方針が取られてきた。そのため通常は `python3` を明示して使う。必要なら `python-is-python3` などで `python` コマンドを追加できる。', 'https://docs.python.org/3/using/cmdline.html', 'unpublished', false),
  (408, 'セクション110: Python コマンドと実行環境', '`python` を `python3` に向ける公式寄りの方法', '`/usr/bin/python` を `python3` に向けたい場合、Ubuntu が公式に推奨する方法として正しいものはどれか。', 'sudo apt install python-is-python3', '["`sudo ln -sf /usr/bin/python3 /usr/bin/python` で直接シンボリックリンクを作成する", "`update-alternatives` で `/usr/bin/python3` を `python3.11` に切り替える", "`sudo apt install python-is-python3` をインストールする", "`.bashrc` に `alias python=python3` を追記する"]'::jsonb, 2, 'Ubuntu では `python-is-python3` パッケージの導入が案内されており、これにより `python` から `python3` への適切なリンクがパッケージ管理下で提供される。手動の `ln -sf` は動くことはあるが、パッケージ管理の外での変更なので推奨されにくい。', 'https://docs.python.org/3/using/cmdline.html', 'unpublished', false),
  (409, 'セクション110: Python コマンドと実行環境', 'Ubuntu 22.04 の `python3` の参照チェーン', 'Ubuntu 22.04において `python3` コマンドが指すものとして正しいものはどれか。', 'ls -l /usr/bin/python3
ls -l /etc/alternatives/python3', '["`/usr/bin/python3.11` に直接リンクされている", "`/etc/alternatives/python3` を経由せず直接 `python3.10` を指す", "`update-alternatives` の設定に関わらず常に最新版を指す", "`/etc/alternatives/python3` を経由して `/usr/bin/python3.10` を指すシンボリックリンクチェーンになっている"]'::jsonb, 3, '今回の環境では `python3` が `/usr/bin/python3 -> /etc/alternatives/python3 -> /usr/bin/python3.10` というチェーンで管理されていた。この中間リンクが `python3.11` を向くと、Ubuntu 22.04 標準ツールとの不整合が起き得る。', 'https://docs.python.org/3/using/cmdline.html', 'unpublished', false),
  (410, 'セクション110: Python コマンドと実行環境', '`apt_pkg` の `ModuleNotFoundError` の原因', 'Ubuntu 22.04で `python3` が `python3.11` を指していたとき、`apt_pkg` で `ModuleNotFoundError` が発生した根本原因として正しいものはどれか。', 'python3 -c "import apt_pkg"', '["`python3.11` にはモジュールのインポート機能がないため", "`apt_pkg` パッケージ自体が破損していたため", "`python3.11` は Ubuntu 22.04 の公式リポジトリに存在しないため", "`apt_pkg` は Ubuntu 22.04 標準の `python3.10` 向けにビルドされており、`python3.11` からは読み込めないため"]'::jsonb, 3, '`apt_pkg` は `python3-apt` 由来の拡張モジュールで、Ubuntu 22.04 では標準の `python3.10` 向けに用意されている。`python3` を `python3.11` へ切り替えると ABI やインストール先の不整合により import に失敗し、`ModuleNotFoundError` が起こる。', 'https://docs.python.org/3/using/cmdline.html', 'unpublished', false),
  (411, 'セクション110: Python コマンドと実行環境', 'Ubuntu 22.04 で Python 3.11 を安全に使う原則', 'Ubuntu 22.04で開発用に Python 3.11 を安全に使う方法として最も適切なものはどれか。', 'python3.11
python3.11 -m venv .venv', '["`sudo update-alternatives --config python3` でシステムの `python3` を `python3.11` に切り替える", "`sudo ln -sf /usr/bin/python3.11 /usr/bin/python3` でシステムPythonを書き換える", "`python3.11` を削除して `python3.10` に統一する", "`python3.11` を直接使うか `python3.11 -m venv .venv` で仮想環境を作成してシステムPythonと分離する"]'::jsonb, 3, 'OS 標準の `python3` は Ubuntu 自体を支える Python であり、切り替えると `apt` 系や `command-not-found` などのツールと不整合を起こしやすい。開発用の 3.11 はシステムから分離し、直接 `python3.11` を使うか `venv` で閉じ込めるのが安全。', 'https://docs.python.org/3/using/cmdline.html', 'unpublished', false),
  (412, 'セクション111: 英文読解 (Python REPL の終了方法)', '動名詞句が主語になる文', '次の文の主語として正しいものはどれか。

> Typing an end-of-file character (Control-D on Unix, Control-Z on Windows) at the primary prompt causes the interpreter to exit with a zero exit status.', 'Typing an end-of-file character (Control-D on Unix, Control-Z on Windows) at the primary prompt causes the interpreter to exit with a zero exit status.', '["`an end-of-file character`", "`the primary prompt`", "`the interpreter`", "`Typing an end-of-file character (Control-D on Unix, Control-Z on Windows) at the primary prompt`"]'::jsonb, 3, 'この文では `Typing ... at the primary prompt` という動名詞句全体が主語になっている。括弧内の `Control-D ...` は挿入された補足説明で、主語の中心は『EOF文字を入力すること』という行為全体。動名詞句は単数扱いなので動詞は `causes` となる。', 'https://docs.python.org/3/tutorial/interpreter.html', 'unpublished', false),
  (413, 'セクション111: 英文読解 (Python REPL の終了方法)', 'cause + O + to do の構造', '次の文の `causes the interpreter to exit` の文法構造として正しいものはどれか。

> Typing〜causes the interpreter to exit with a zero exit status.', 'Typing ... causes the interpreter to exit with a zero exit status.', '["S=`Typing〜`, V=`causes to exit`, O=`the interpreter`", "S=`Typing〜`, V=`causes`, O=`a zero exit status`, C=`to exit`", "S=`Typing〜`, V=`causes`, O=`the interpreter`, C=`to exit with a zero exit status`（SVOC構文）", "S=`the interpreter`, V=`causes`, O=`Typing〜`, C=`to exit`"]'::jsonb, 2, '`cause + O + to不定詞` は『Oを〜させる』を表す SVOC 構文。ここでは `the interpreter` が目的語、`to exit with a zero exit status` が目的語補語となる。`make` と違って `cause` の後ろでは通常 `to不定詞` が必要。', 'https://docs.python.org/3/tutorial/interpreter.html', 'unpublished', false),
  (414, 'セクション111: 英文読解 (Python REPL の終了方法)', 'with a zero exit status の with の用法', '次の文の `with a zero exit status` の `with` の用法として正しいものはどれか。

> causes the interpreter to exit with a zero exit status', 'causes the interpreter to exit with a zero exit status', '["対立『〜に反して』", "原因『〜のせいで』", "手段『〜を使って』", "付帯状況『〜の状態で・〜とともに』"]'::jsonb, 3, 'ここでの `with` は付帯状況を表し、『ゼロの終了ステータスという状態で』の意味になる。手段ではなく、終了時の状態や結果を添えている点がポイント。', 'https://docs.python.org/3/tutorial/interpreter.html', 'unpublished', false),
  (415, 'セクション111: 英文読解 (Python REPL の終了方法)', 'by + 動名詞 の用法', '次の文の `by typing the following command` の文法的な役割として正しいものはどれか。

> you can exit the interpreter by typing the following command: quit()', 'you can exit the interpreter by typing the following command: quit()', '["目的を表す不定詞句", "条件を表す副詞節", "結果を表す分詞構文", "手段を表す前置詞句（`by + 動名詞`）"]'::jsonb, 3, '`by + 動名詞` は『〜することによって』という手段・方法を表す。ここでは `quit()` を入力することでインタープリターを終了できる、という意味。目的を表す `to不定詞` とは異なる。', 'https://docs.python.org/3/tutorial/interpreter.html', 'unpublished', false),
  (416, 'セクション111: 英文読解 (Python REPL の終了方法)', 'If that doesn''t work の that が指すもの', '次の文の `If that doesn''t work` の `that` が指すものとして最も適切なものはどれか。

> Typing an end-of-file character (Control-D on Unix, Control-Z on Windows) at the primary prompt causes the interpreter to exit with a zero exit status. If that doesn''t work, you can exit the interpreter by typing the following command: quit().', 'Typing an end-of-file character ... causes the interpreter to exit ... If that doesn''t work, you can exit the interpreter by typing the following command: quit().', '["`quit()` コマンドの入力", "`zero exit status` での終了", "Windowsでの `Control-Z` の入力のみ", "プライマリプロンプトで EOF 文字（Control-D または Control-Z）を入力する操作全体"]'::jsonb, 3, '`that` は直前の文全体、つまり『プライマリプロンプトで EOF 文字を入力してインタープリターを終了させる操作』を受けている。特定のキー1つや `quit()` のことではなく、前文の方法全体を指す。', 'https://docs.python.org/3/tutorial/interpreter.html', 'unpublished', false),
  (417, 'セクション111: 英文読解 (Python REPL の終了方法)', 'REPL 終了方法の説明文全体の和訳', '次の文全体の日本語訳として最も適切なものはどれか。

> Typing an end-of-file character (Control-D on Unix, Control-Z on Windows) at the primary prompt causes the interpreter to exit with a zero exit status. If that doesn''t work, you can exit the interpreter by typing the following command: quit().', 'Typing an end-of-file character (Control-D on Unix, Control-Z on Windows) at the primary prompt causes the interpreter to exit with a zero exit status. If that doesn''t work, you can exit the interpreter by typing the following command: quit().', '["プライマリプロンプトでファイル終端文字を入力すると、インタープリターがエラーステータスで強制終了する。その場合は `quit()` コマンドを入力することでエラーを回避できる。", "プライマリプロンプトで Control-D または Control-Z を入力すると、インタープリターが一時停止する。再開するには `quit()` を入力する必要がある。", "UnixではControl-D、WindowsではControl-Zを入力することでインタープリターを起動できる。起動しない場合は `quit()` コマンドを使用する。", "プライマリプロンプトでファイル終端文字（UnixではControl-D、WindowsではControl-Z）を入力すると、インタープリターがゼロの終了ステータスで終了する。それが機能しない場合は、次のコマンドを入力することでインタープリターを終了できる：`quit()`。"]'::jsonb, 3, '`causes the interpreter to exit`、`with a zero exit status`、`If that doesn''t work`、`by typing the following command` をすべて正しく訳しているのが正解。誤答は `zero exit status` をエラー扱いにしたり、『一時停止』『起動』のように動作そのものを取り違えている。', 'https://docs.python.org/3/tutorial/interpreter.html', 'unpublished', false),
  (418, 'セクション112: 英文読解 (Python 対話例の読み方)', 'are distinguished の用法', '次の文の `are distinguished` の文法的な用法として正しいものはどれか。

> input and output are distinguished by the presence or absence of prompts', 'input and output are distinguished by the presence or absence of prompts', '["be動詞 + 形容詞 の第2文型", "be動詞 + 現在分詞 の進行形", "be動詞 + 過去分詞 の受動態", "be動詞 + 不定詞 の予定・義務"]'::jsonb, 2, '`distinguish A from B` / `distinguish A by ...` の受動態で、『入力と出力はプロンプトの有無によって区別される』という意味。`by ...` が区別の手段・基準を示しており、受動態であることがわかる。', 'https://docs.python.org/3/', 'unpublished', false),
  (419, 'セクション112: 英文読解 (Python 対話例の読み方)', 'presence or absence の訳', '次の文の `presence or absence` の訳として最も適切なものはどれか。

> distinguished by the presence or absence of prompts', 'distinguished by the presence or absence of prompts', '["存在と不在の両方", "存在するか存在しないかの選択", "存在することの重要性", "有無"]'::jsonb, 3, '`presence` は『存在・あること』、`absence` は『不在・ないこと』なので、`presence or absence of prompts` は日本語では簡潔に『プロンプトの有無』と訳すのが自然。', 'https://docs.python.org/3/', 'unpublished', false),
  (420, 'セクション112: 英文読解 (Python 対話例の読み方)', 'to repeat the example の役割', '次の文の `to repeat the example` の文法的な役割として正しいものはどれか。

> to repeat the example, you must type everything after the prompt', 'to repeat the example, you must type everything after the prompt', '["主語となる名詞的用法", "名詞を修飾する形容詞的用法", "結果を表す副詞的用法", "目的を表す副詞的用法"]'::jsonb, 3, '文頭の `to repeat the example` は『例を再現するには』『再現するために』という意味で、主節全体を修飾する副詞的用法。文脈上は目的・条件に近いニュアンスを持つ。', 'https://docs.python.org/3/', 'unpublished', false),
  (421, 'セクション112: 英文読解 (Python 対話例の読み方)', 'on a line by itself の意味', '次の文の `on a line by itself` の意味として正しいものはどれか。

> a secondary prompt on a line by itself in an example means you must type a blank line', 'a secondary prompt on a line by itself in an example means you must type a blank line', '["他の行と並んで表示される", "自動的に生成される行に", "複数行にわたって表示される", "それ単体で1行を占めている"]'::jsonb, 3, '`by itself` は『それ単独で』『それだけで』という意味。`on a line by itself` で『単独で1行にある』『それだけで1行を占めている』という慣用的表現になる。', 'https://docs.python.org/3/', 'unpublished', false),
  (422, 'セクション112: 英文読解 (Python 対話例の読み方)', 'be used to + 不定詞 の用法', '次の文の `this is used to end a multi-line command` の `be used to` の用法として正しいものはどれか。

> this is used to end a multi-line command', 'this is used to end a multi-line command', '["過去の習慣『以前は〜するのに慣れていた』", "現在の習慣『〜することに慣れている』", "目的『〜するために使われる』", "仮定『〜するために使われるだろう』"]'::jsonb, 2, '`be used to + 動詞の原形不定詞` は『〜するために使われる』という目的の受動態。`be used to + 動名詞`（〜することに慣れている）と混同しやすいが、ここでは後ろが `to end` なので不定詞であり、目的を表している。', 'https://docs.python.org/3/', 'unpublished', false),
  (423, 'セクション112: 英文読解 (Python 対話例の読み方)', '対話例の読み方の説明文全体の和訳', '次の文全体の日本語訳として最も適切なものはどれか。

> In the following examples, input and output are distinguished by the presence or absence of prompts (>>> and …): to repeat the example, you must type everything after the prompt, when the prompt appears; lines that do not begin with a prompt are output from the interpreter. Note that a secondary prompt on a line by itself in an example means you must type a blank line; this is used to end a multi-line command.', 'In the following examples, input and output are distinguished by the presence or absence of prompts (>>> and ...): to repeat the example, you must type everything after the prompt, when the prompt appears; lines that do not begin with a prompt are output from the interpreter. Note that a secondary prompt on a line by itself in an example means you must type a blank line; this is used to end a multi-line command.', '["以下の例では、`>>>` と `...` はそれぞれ入力と出力を表している。プロンプトの後に何かを入力する必要はなく、プロンプトがない行がユーザーの入力である。`...` が単独で表示された場合はコマンドが完了したことを意味する。", "以下の例では、プロンプトの種類によって入力と出力が区別される。例を再現するにはプロンプトの前にあるすべてを入力しなければならない。`...` が単独で表示された場合は次のコマンドに進むことを意味する。", "以下の例では、`>>>` と `...` はインタープリターの出力を表している。プロンプトがある行はすべてインタープリターからの出力であり、プロンプトがない行がユーザーの入力となる。", "以下の例では、入力と出力はプロンプト（`>>>` と `...`）の有無によって区別される。例を再現するにはプロンプトが表示されたときにプロンプトの後にあるすべてを入力しなければならず、プロンプトで始まらない行はインタープリターの出力である。`...` が単独で1行を占めている場合は空白行を入力する必要があり、これは複数行コマンドを終了させるために使われる。"]'::jsonb, 3, '`by the presence or absence of prompts`、`everything after the prompt`、`lines that do not begin with a prompt are output`、`on a line by itself`、`is used to end a multi-line command` をすべて正確に反映しているのが正解。他の選択肢は入力と出力の関係、`after` の意味、`...` の役割を取り違えている。', 'https://docs.python.org/3/', 'unpublished', false),
  (424, 'セクション113: 英文読解 (Python ドキュメントUI)', 'by clicking on >>> の役割', '次の文の `by clicking on >>>` の文法的な役割として正しいものはどれか。

> You can toggle the display of prompts and output by clicking on >>> in the upper-right corner of an example box.', 'You can toggle the display of prompts and output by clicking on >>> in the upper-right corner of an example box.', '["目的を表す不定詞句", "条件を表す副詞節", "結果を表す分詞構文", "手段を表す前置詞句（`by + 動名詞`）"]'::jsonb, 3, '`by + 動名詞` は『〜することによって』という手段・方法を表す。ここでは `>>>` をクリックすることによって表示を切り替えられる、という意味で、目的の `to不定詞` ではない。', 'https://docs.python.org/3/', 'unpublished', false),
  (425, 'セクション113: 英文読解 (Python ドキュメントUI)', 'toggle の意味', '次の文の `toggle` の意味として最も適切なものはどれか。

> You can toggle the display of prompts and output', 'You can toggle the display of prompts and output', '["削除する", "追加する", "固定する", "オン・オフを切り替える"]'::jsonb, 3, '`toggle` は2つの状態を交互に切り替えることを表す動詞で、UI 文脈では『表示・非表示を切り替える』『オン・オフを切り替える』の意味になる。', 'https://docs.python.org/3/', 'unpublished', false),
  (426, 'セクション113: 英文読解 (Python ドキュメントUI)', 'If〜, then〜 の条件と帰結', '次の文の `If〜, then〜` の構造として正しいものはどれか。

> If you hide the prompts and output for an example, then you can easily copy and paste the input lines into your interpreter.', 'If you hide the prompts and output for an example, then you can easily copy and paste the input lines into your interpreter.', '["`If` 節が結果を表し `then` 節が条件を表す", "`If` 節と `then` 節が対等な並列関係にある", "`then` は時間の順序を表す副詞で条件とは無関係", "`If` 節が条件を表し `then` 節がその帰結を表す"]'::jsonb, 3, '`If ... , then ...` は典型的な条件と帰結の構文で、『もし〜なら、そうすれば〜』という意味を作る。ここでは `If you hide ...` が条件、`then you can ...` がその結果としての帰結。', 'https://docs.python.org/3/', 'unpublished', false),
  (427, 'セクション113: 英文読解 (Python ドキュメントUI)', 'copy and paste の並列構造', '次の文の `copy and paste` の文法的な構造として正しいものはどれか。

> you can easily copy and paste the input lines into your interpreter', 'you can easily copy and paste the input lines into your interpreter', '["`copy` が動詞、`and paste the input lines` が副詞句", "`copy and paste` が複合名詞として目的語になっている", "`copy` が形容詞、`paste` が動詞として機能している", "`copy` と `paste` が `and` で並列する動詞で、共通の目的語 `the input lines` を持つ"]'::jsonb, 3, '`copy` と `paste` は2つの動詞が `and` で並列された形で、どちらも `the input lines` を共通の目的語としている。`easily` は両方にかかる副詞、`into your interpreter` は方向を示す前置詞句。', 'https://docs.python.org/3/', 'unpublished', false),
  (428, 'セクション113: 英文読解 (Python ドキュメントUI)', 'the display of prompts and output の和訳', '次の文の `the display of prompts and output` の訳として最も適切なものはどれか。

> You can toggle the display of prompts and output', 'You can toggle the display of prompts and output', '["プロンプトと出力を表示するボタン", "プロンプトと出力の切り替え機能", "プロンプトと出力の入力欄", "プロンプトと出力の表示"]'::jsonb, 3, '`display` はここでは名詞で『表示』、`of prompts and output` がその内容を示している。全体で『プロンプトと出力の表示』となり、`toggle` と組み合わせて『表示を切り替える』という意味になる。', 'https://docs.python.org/3/', 'unpublished', false),
  (429, 'セクション113: 英文読解 (Python ドキュメントUI)', 'ドキュメントUI説明文全体の和訳', '次の文全体の日本語訳として最も適切なものはどれか。

> You can toggle the display of prompts and output by clicking on >>> in the upper-right corner of an example box. If you hide the prompts and output for an example, then you can easily copy and paste the input lines into your interpreter.', 'You can toggle the display of prompts and output by clicking on >>> in the upper-right corner of an example box. If you hide the prompts and output for an example, then you can easily copy and paste the input lines into your interpreter.', '["サンプルボックスの左上にある `>>>` をクリックすると、プロンプトと出力が永久に削除される。プロンプトと出力を削除すれば、インタープリターから入力行を取り出すことができる。", "サンプルボックスの右上にある `>>>` をクリックすると、入力行のみが表示される。プロンプトと出力を表示した状態では、入力行を自分のインタープリターにコピーできない。", "サンプルボックスの右上にある `>>>` をクリックすると、プロンプトと出力の両方が常に表示される。プロンプトと出力を表示すれば、入力行を簡単にコピーして貼り付けることができる。", "サンプルボックスの右上隅にある `>>>` をクリックすることで、プロンプトと出力の表示を切り替えることができる。例のプロンプトと出力を非表示にすれば、入力行を自分のインタープリターに簡単にコピーして貼り付けることができる。"]'::jsonb, 3, '`toggle`、`in the upper-right corner`、`by clicking on`、`If you hide ...`、`copy and paste`、`into your interpreter` をすべて自然に訳しているのが正解。他の選択肢は `upper-right`、`toggle`、`hide` の意味や条件と帰結の関係を取り違えている。', 'https://docs.python.org/3/', 'unpublished', false),
  (430, 'セクション114: 英文読解 (Python REPL 導入)', 'Let''s try の用法', '次の文の `Let''s try` の文法的な用法として正しいものはどれか。

> Let''s try some simple Python commands.', 'Let''s try some simple Python commands.', '["仮定法『〜したとしたら』", "受動態『〜させられる』", "過去形『〜しようとした』", "勧誘の命令形『〜しましょう』"]'::jsonb, 3, '`Let''s ...` は `Let us ...` の短縮形で、『〜しましょう』と相手を誘う勧誘の命令表現。通常の命令形が相手だけへの指示なのに対し、`Let''s` は話し手も含めた行動の提案になる。', 'https://docs.python.org/3/tutorial/interpreter.html', 'unpublished', false),
  (431, 'セクション114: 英文読解 (Python REPL 導入)', 'Start ... and wait ... の並列命令', '次の文の `Start the interpreter and wait for the primary prompt` の構造として正しいものはどれか。

> Start the interpreter and wait for the primary prompt, >>>.', 'Start the interpreter and wait for the primary prompt, >>>.', '["`Start` が動詞、`the interpreter and wait` が目的語、`for the primary prompt` が副詞句", "`Start the interpreter` が条件節、`wait for the primary prompt` が主節", "`Start` と `wait` が異なる主語を持つ2つの独立した文", "`Start` と `wait` が `and` で並列する命令形で、どちらも読者への指示を表す"]'::jsonb, 3, '`Start the interpreter` と `wait for the primary prompt` はどちらも命令文で、共通の主語 `you` が省略されている。`and` で並列され、読者に順に行動を促している。', 'https://docs.python.org/3/tutorial/interpreter.html', 'unpublished', false),
  (432, 'セクション114: 英文読解 (Python REPL 導入)', 'It shouldn''t take long の It の用法', '次の文の `It` の用法として正しいものはどれか。

> (It shouldn''t take long.)', '(It shouldn''t take long.)', '["前文の `the interpreter` を指す代名詞", "前文の `the primary prompt` を指す代名詞", "天候・時間を表す非人称の `it`", "形式主語（真主語はインタープリターの起動にかかる時間）"]'::jsonb, 3, 'ここでの `It takes ...` は、何かに時間がかかることを述べる形式的な `it` の用法。文脈上は『インタープリターを起動してプロンプトが出るまでの時間』をぼんやり受けており、単なる物や天候を指す `it` ではない。', 'https://docs.python.org/3/tutorial/interpreter.html', 'unpublished', false),
  (433, 'セクション114: 英文読解 (Python REPL 導入)', 'shouldn''t の推量的用法', '次の文の `shouldn''t` の意味として最も適切なものはどれか。

> It shouldn''t take long.', 'It shouldn''t take long.', '["〜してはいけない（禁止）", "〜すべきではない（義務の否定）", "〜しないだろう（単純な否定の推量）", "〜のはずがない（否定の推量）"]'::jsonb, 3, 'ここでの `shouldn''t` は禁止ではなく、『時間はかからないはずだ』という穏やかな否定の推量を表している。`mustn''t` のような禁止とは異なり、話し手の見込みを述べる用法。', 'https://docs.python.org/3/tutorial/interpreter.html', 'unpublished', false),
  (434, 'セクション114: 英文読解 (Python REPL 導入)', 'wait for the primary prompt の和訳', '次の文の `wait for the primary prompt` の訳として最も適切なものはどれか。

> Start the interpreter and wait for the primary prompt, >>>.', 'Start the interpreter and wait for the primary prompt, >>>.', '["プライマリプロンプトを入力してください", "プライマリプロンプトを確認してください", "プライマリプロンプトを削除してください", "プライマリプロンプトを待ってください"]'::jsonb, 3, '`wait for ...` は『〜を待つ』という慣用表現。ここでは `>>>` が表示されるまで待つ、という意味であり、『確認する』『入力する』『削除する』ではない。', 'https://docs.python.org/3/tutorial/interpreter.html', 'unpublished', false),
  (435, 'セクション114: 英文読解 (Python REPL 導入)', 'REPL導入文全体の和訳', '次の文全体の日本語訳として最も適切なものはどれか。

> Let''s try some simple Python commands. Start the interpreter and wait for the primary prompt, >>>. (It shouldn''t take long.)', 'Let''s try some simple Python commands. Start the interpreter and wait for the primary prompt, >>>. (It shouldn''t take long.)', '["いくつかの複雑なPythonコマンドを試してみましょう。インタープリターを終了してセカンダリプロンプト `...` を待ってください。（時間がかかるはずです。）", "簡単なPythonコマンドをすべて試してみましょう。インタープリターを起動してプライマリプロンプトが表示されたら入力してください。（時間はかかりません。）", "いくつかの簡単なPythonコマンドを確認しましょう。インタープリターを再起動してプライマリプロンプト `>>>` が消えるまで待ってください。（時間はかからないはずです。）", "いくつかの簡単なPythonコマンドを試してみましょう。インタープリターを起動してプライマリプロンプト `>>>` を待ってください。（時間はかからないはずです。）"]'::jsonb, 3, '`Let''s try`、`Start the interpreter`、`wait for the primary prompt`、`It shouldn''t take long` をすべて自然に訳しているのが正解。誤答は `simple` を逆にしたり、`Start` を『終了』『再起動』にしたり、`shouldn''t` を逆方向に解釈したりしている。', 'https://docs.python.org/3/tutorial/interpreter.html', 'unpublished', false),
  (436, 'セクション115: 英文法 (仮定法)', '仮定法過去の be動詞', '次の文の空欄に入る最も適切なものはどれか。

> If it ___ a little warmer, we would go out for a walk.', 'If it ___ a little warmer, we would go out for a walk.', '["`is`", "`was`", "`were`", "`will be`"]'::jsonb, 2, '主節に `would + 動詞原形` があるため、この文は現在の事実に反する仮定を表す仮定法過去と判断できる。仮定法過去では、`be` 動詞は主語の人称・数にかかわらず原則として `were` を用いる。口語では `was` も見られるが、文法的に最も標準的なのは `were`。', 'https://dictionary.cambridge.org/grammar/british-grammar/', 'unpublished', false),
  (437, 'セクション116: Python 文字列リテラル', 'SyntaxError になる文字列定義', '次のうち、Pythonで `SyntaxError` になる文字列の定義を**すべて含む組み合わせ**として正しいものはどれですか？', 'A. r"C:\Temp\"
B. "C:\Temp\"
C. r"C:\Temp" + "\"
D. r"C:\Temp"', '["`A` のみ", "`A` と `B` のみ", "`A`・`B`・`C`", "`B`・`C`・`D`"]'::jsonb, 2, 'この問題では **`A`・`B`・`C` が `SyntaxError`、`D` は正常**。`A: r"C:\Temp\"` は raw 文字列だが、**raw 文字列は末尾を奇数個のバックスラッシュで終われない**ため `unterminated string literal` になる。`B: "C:\Temp\"` は通常文字列で、末尾の `\` が閉じクォートをエスケープしてしまい、やはり文字列が終わらない。`C: r"C:\Temp" + "\"` は前半の raw 文字列 `r"C:\Temp"` 自体は正しいが、後半の通常文字列 `"\"` が壊れているため `SyntaxError`。`D: r"C:\Temp"` は末尾がバックスラッシュではないので正しい raw 文字列であり、エラーにはならない。つまり、**raw 文字列特有の問題が当てはまるのは `A` だけ**で、`B` と `C` は通常文字列側のクォート終端ミスによる `SyntaxError`。', 'https://docs.python.org/3/reference/lexical_analysis.html#string-and-bytes-literals', 'unpublished', false),
  (438, 'セクション117: Python `decimal` モジュール', '正確な `0.1` を作る `Decimal` の初期化', '`from decimal import Decimal` を実行した後、正確な `0.1` を表現するために最も適切なインスタンス化の方法はどれですか？', 'from decimal import Decimal', '["`Decimal(\"0.1\")`", "`Decimal(1/10)`", "`float(Decimal(\"0.1\"))`", "`Decimal(0.1)`"]'::jsonb, 0, '正解は `Decimal("0.1")`。`Decimal` で十進数を正確に扱いたいときは、**文字列から生成する**のが基本。`Decimal(0.1)` はすでに2進浮動小数で近似された `0.1` を取り込むため不正確になりうる。`Decimal(1/10)` も `1/10` が先に `float` として評価されるので同じ問題を含む。`float(Decimal("0.1"))` は逆に `Decimal` を `float` に戻してしまい、正確性を失う。', 'https://docs.python.org/3/library/decimal.html', 'unpublished', false),
  (439, 'セクション118: Python 関数引数と落とし穴', '可変デフォルト引数の共有', '以下の関数を定義した直後に、`append_to_list(1)` と `append_to_list(2)` を連続して実行しました。2回目の戻り値はどうなりますか？', 'def append_to_list(val, my_list=[]):
    my_list.append(val)
    return my_list', '["`[2]`", "`TypeError` が発生する", "`[1, 2]`", "`[[1], 2]`"]'::jsonb, 2, '正解は `C` の `[1, 2]`。デフォルト引数の `[]` は**関数呼び出し時ではなく定義時に1回だけ作られる**ため、2回の呼び出しで同じリストオブジェクトが使い回される。1回目の `append_to_list(1)` でリストは `[1]` になり、続く `append_to_list(2)` ではその同じリストに `2` が追加されて `[1, 2]` が返る。可変オブジェクトをデフォルト引数に置くと起きやすい典型的な落とし穴で、通常は `my_list=None` として関数内で新しいリストを作る書き方が推奨される。', 'https://docs.python.org/3/tutorial/controlflow.html#default-argument-values', 'unpublished', false),
  (440, 'セクション119: Python アンパック代入', 'スター付き代入で集められる値', '`a, *b, c = [1, 2, 3, 4, 5]` を実行した後、変数 `b` の値とデータ型として正しいものはどれですか？', 'a, *b, c = [1, 2, 3, 4, 5]', '["値: `[2, 3, 4]`, 型: `list`", "値: `(2, 3, 4)`, 型: `tuple`", "値: `[1, 2, 3, 4, 5]`, 型: `list`", "値: `2`, 型: `int`"]'::jsonb, 0, '正解は `A`。この代入では先頭の `a` が `1`、末尾の `c` が `5` を受け取り、間に残った `2, 3, 4` が `*b` にまとめて入る。重要なのは、**スター付き代入で集められた部分は常に `list` になる**こと。したがって `b` は `[2, 3, 4]` という `list` になる。', 'https://docs.python.org/3/tutorial/datastructures.html#tuples-and-sequences', 'unpublished', false),
  (441, 'セクション120: Python オブジェクト同一性と整数キャッシュ', '`is` と小さな整数キャッシュ', '標準的な `CPython` の対話モードで次のコードを実行したとき、出力される結果はどうなりますか？', 'a = 256
b = 256
c = 257
d = 257
print(a is b, c is d)', '["`True True`", "`True False`", "`False True`", "`False False`"]'::jsonb, 1, '正解は `B` の `True False`。標準的な `CPython` では、**`-5` から `256` までの小さな整数はキャッシュされて使い回される**ため、`256` までは同一オブジェクトになりやすく、`a is b` は `True` になる。一方 `257` はその範囲外なので、対話モードで別々の代入文として評価すると通常は別オブジェクトとなり、`c is d` は `False` になる。なおこれは `CPython` 実装依存の最適化であり、`is` で数値の等しさを判定すべきではない。値の比較には常に `==` を使うべきで、同一性比較 `is` は `None` などに使うのが原則。', 'https://docs.python.org/3/library/functions.html#id', 'unpublished', false),
  (442, 'セクション121: Python リストと参照共有', '二次元リストと `*` 演算子の落とし穴', '`matrix = [[0] * 2] * 2` を実行して作成した配列に対し、`matrix[0][0] = 1` を実行しました。直後の `print(matrix)` の出力はどうなりますか？', 'matrix = [[0] * 2] * 2
matrix[0][0] = 1
print(matrix)', '["`[[1, 0], [0, 0]]`", "`TypeError` が発生する", "`[[1, 1], [1, 1]]`", "`[[1, 0], [1, 0]]`"]'::jsonb, 3, '正解は `D` の `[[1, 0], [1, 0]]`。`[[0] * 2] * 2` は、内側のリスト `[0, 0]` を2回**複製しているように見えるが、実際には同じリストオブジェクトへの参照を2個並べている**。そのため `matrix[0][0] = 1` で1行目を変更すると、2行目も同じオブジェクトを見ているので連動して変わる。`*` 演算子はネストした可変オブジェクトの深いコピーを作るわけではなく、参照を繰り返すだけ、というのがポイント。安全に独立した二次元リストを作るには `[[0] * 2 for _ in range(2)]` のように書く。', 'https://docs.python.org/3/library/copy.html', 'unpublished', false),
  (443, 'セクション122: Python 例外処理フロー', '`try ... except ... else ... finally` の `else` が走る条件', '`try ... except ... else ... finally` 構文において、`else` ブロックのコードが実行される条件はどれですか？', 'try:
    ...
except Exception:
    ...
else:
    ...
finally:
    ...', '["例外の発生有無に関わらず常に", "`except` ブロックで処理できない例外が発生したとき", "例外が発生したときのみ", "`try` ブロック内で例外が発生せず、正常に完了したとき"]'::jsonb, 3, '正解は `D`。`else` は、**`try` ブロックで例外が発生せず、最後まで正常に実行されたときだけ**実行される。`except` で捕まえた場合には `else` は実行されないし、捕まえられない例外が出た場合は `finally` を経て上位に送出される。`if` の `else` とは少し違い、『例外が起きなかった場合の処理』を分けて書くための場所と考えると分かりやすい。', 'https://docs.python.org/3/', 'unpublished', false),
  (444, 'セクション123: Python 真偽値評価', '`bool(x)` が `True` になる値', '次のうち、`bool(x)` で評価したときに結果が `True` になる `x` の値はどれですか？', 'bool(x)', '["`x = ()`", "`x = \"False\"`", "`x = 0.0`", "`x = []`"]'::jsonb, 1, '正解は `B` の `"False"`。Python では**空でない文字列は中身に関係なく真 (`True`)** として扱われる。したがって文字列が `"False"` であっても、長さが1以上あるので `bool(x)` は `True` になる。一方、空タプル `()`、数値の `0.0`、空リスト `[]` はいずれも偽 (`False`) と評価される。文字列では『書かれている単語の意味』ではなく、『空かどうか』が判定基準になる。', 'https://docs.python.org/3/library/stdtypes.html#truth-value-testing', 'unpublished', false),
  (445, 'セクション124: Python REPL の特殊変数', '対話モードの `_` の役割', 'Pythonの対話型インタプリタ（REPL）において、変数 `_` （アンダースコア単体）が持つ特別な役割は何ですか？', '_', '["未定義の変数を表すプレースホルダーとして機能する", "最後に評価されて画面に出力された式の値を保持している", "直前にインポートされたモジュールの名前空間を参照する", "前回発生した例外のトレースバック情報を格納している"]'::jsonb, 1, '正解は `B`。標準的な Python の対話モードでは、`_` は**最後に評価されて表示された式の結果**を自動的に保持する特別な名前として使われる。たとえば `2 + 3` を評価して `5` が表示された直後なら、`_ * 2` のようにしてその結果を再利用できる。これは REPL 特有の便利機能であり、通常のスクリプト中で同じ意味を持つわけではない。', 'https://docs.python.org/3/tutorial/interpreter.html', 'unpublished', false),
  (446, 'セクション125: Pascal / Free Pascal Compiler 基礎', 'Free Pascal の "Free" の意味', '「Free Pascal Compiler」の「Free」が意味するものとして、最も正確な説明はどれですか？', 'Free Pascal Compiler version 3.2.2+dfsg-32 [2024/01/05] for x86_64', '["無料（価格ゼロ）のみを意味する", "自由（オープンソース・GPL）のみを意味する", "無料と自由（オープンソース）の両方を意味する", "フリーウェアとして配布されているが、ソースコードは非公開である"]'::jsonb, 2, '「Free」は「無料（price-free）」と「自由（freedom）」の両方を意味します。Free Pascal は GPL ライセンスのオープンソースコンパイラであり、誰でも無料で入手・使用・改変・再配布できます。ソースコードも公開されています。', 'https://www.freepascal.org/docs.html', 'unpublished', false),
  (447, 'セクション126: Pascal / Free Pascal Compiler 基礎', 'バージョン文字列の +dfsg-32 の意味', '`Free Pascal Compiler version 3.2.2+dfsg-32` における `+dfsg-32` の意味として正しいのはどれですか？', 'Free Pascal Compiler version 3.2.2+dfsg-32 [2024/01/05] for x86_64', '["コンパイラが使用するメモリ上限が 32MB であることを示す", "Debian が非フリー素材を除去してパッケージングした印で、-32 は Debian 側のパッケージリビジョン番号", "コンパイラのデバッグシンボルフラグ（32 ビットデバッグモード）", "x86_64 の 32 ビット互換モードでビルドされたことを示す"]'::jsonb, 1, '`+dfsg` は「Debian Free Software Guidelines」の略で、Debian/Ubuntu がパッケージングする際に非フリーなファイルを取り除いたことを示す印です。`-32` はその後に Debian 側が加えたパッケージ修正の回数（リビジョン番号）で、メモリやビット数とは無関係です。公式サイトから直接入手したバイナリにはこの表記は付きません。', 'https://www.freepascal.org/docs.html', 'unpublished', false),
  (448, 'セクション127: Pascal / Free Pascal Compiler 基礎', 'Pascal for ループのコンパイルエラー', '以下の Pascal コードがコンパイルエラーになる主な原因はどれですか？', 'begin
  for i := 1 to 10 do
    writeln(i);
end.', '["`writeln` は Pascal では使用できない手続きである", "ループカウンタ `i` が `var` セクションで宣言されていない", "for ループのブロックを `begin`/`end` で囲んでいない", "プログラム末尾のピリオド `.` が不要である"]'::jsonb, 1, 'Pascal では変数を使う前に `var` セクションで型宣言が必要です。`i` を宣言しないまま for ループで使うと `Identifier not found "i"` / `Illegal counter variable` などのエラーが発生します。正しくは `var i: integer;` を `begin` の前に追加します。`writeln` は標準手続きで問題なく使用でき、末尾のピリオドも Pascal プログラムの終端として必須です。', 'https://www.freepascal.org/docs.html', 'unpublished', false),
  (449, 'セクション128: Pascal / Python 比較', 'Pascal の for 文の特性', 'Pascal の for 文について正しいものはどれか。', 'for i := 1 to 10 do
  writeln(i);', '["反復ステップを自由に定義できる", "文字列やリストを直接反復できる", "停止条件を定義できない", "反復ステップが1固定で、結果的に常に等差数列になる"]'::jsonb, 3, 'Pascal の for 文は `for i := 1 to 10 do` のように開始値と終了値は定義できるが、ステップは常に1（または `downto` で-1）固定。そのため結果的に常に等差数列となる。これが Python の公式ドキュメントで「like in Pascal」と例示された理由。', 'https://docs.python.org/3/', 'unpublished', false),
  (450, 'セクション129: Pascal / Python 比較', 'Pascal における ordinal 型', 'Pascal における ordinal 型として正しいものはどれか。', NULL, '["real（浮動小数点）", "複素数", "boolean", "配列"]'::jsonb, 2, 'ordinal 型とは「型として大小関係が定義されており、かつ次の値・前の値が定まる型」のこと。boolean は `false < true` という順序が定義されているため ordinal 型。real は大小関係はあるが「次の値」が定まらないため ordinal 型ではない。複素数は大小関係自体が定義できないため ordinal 型ではない。', 'https://docs.python.org/3/', 'unpublished', false),
  (451, 'セクション130: Pascal / Python 比較', 'Python のシーケンス型', '次のうち Python のシーケンスとして正しいものをすべて含む選択肢はどれか。', NULL, '["整数・浮動小数点・複素数", "整数・文字列・辞書", "リスト・文字列・タプル・range", "リスト・辞書・集合"]'::jsonb, 2, 'Python のシーケンスは「順序を持ち、インデックスでアクセスできるデータ構造」。リスト・文字列・タプル・range が該当する。辞書（dict）は Python 3.7 以降で挿入順を保持するが、厳密にはシーケンス型ではない。集合（set）は順序を持たないためシーケンスではない。', 'https://docs.python.org/3/', 'unpublished', false),
  (452, 'セクション131: Pascal / Python 比較', 'C と Pascal の for 文の共通点', 'C と Pascal の for 文の共通点として正しいものはどれか。', NULL, '["反復ステップが1固定である", "文字列を直接反復できる", "停止条件を定義できない", "扱えるのは基本的に数値のみである"]'::jsonb, 3, 'C も Pascal も for 文で扱えるのは基本的に数値のみ。C はステップを自由に定義できる点で Pascal より柔軟だが、数値しか扱えないという制約は共通している。Python はリストや文字列などあらゆるシーケンスを直接反復できる点で両者と本質的に異なる。', 'https://docs.python.org/3/', 'unpublished', false),
  (453, 'セクション132: Pascal / Python 比較', 'コードの言語識別', '次のコードはどの言語で書かれたものか。', 'for i := 0 to 9 do
  writeln(i);', '["C", "Python", "Fortran", "Pascal"]'::jsonb, 3, '`:=` は Pascal の代入演算子、`to` は終了値の指定、`writeln` は Pascal の標準出力手続き。C は `for (int i = 0; i < 10; i++)` という構文、Python は `for i in range(10):` という構文で書く。', 'https://docs.python.org/3/', 'unpublished', false),
  (454, 'セクション133: Pascal / Python 比較', 'Python の for 文が very-high-level な理由', 'Python の for 文が「very-high-level」と言われる理由として最も適切なものはどれか。', 'for fruit in ["apple", "banana", "cherry"]:
    print(fruit)', '["反復ステップを自由に定義できるから", "数値の等差数列を高速に処理できるから", "C や Pascal と同じ構文で書けるから", "開始値・終了値・反復ステップを一切指定せずにシーケンスをそのまま反復できるから"]'::jsonb, 3, 'Python の for 文は数値のカウンターという概念が不要で、シーケンスの要素をそのまま取り出せる。C や Pascal がカウンター変数の管理をプログラマーに委ねているのに対し、Python はその抽象化を言語レベルで実現している点が very-high-level たる所以。', 'https://docs.python.org/3/', 'unpublished', false),
  (455, 'セクション134: Python 設計思想', 'TIMTOWTDI と Python の設計哲学の対比', 'Perl のモットー TIMTOWTDI（There''s More Than One Way To Do It）と Python の設計思想の対比として最も適切なものはどれか。', '# Python の Zen より
# There should be one-- and preferably only one --obvious way to do it.', '["Perl は一貫性を重視し、Python は柔軟性を重視する", "Perl は初心者向けで、Python は上級者向けである", "Perl はオープンソースではなく、Python はオープンソースである", "Perl は多様性・柔軟性を重視し、Python は一つの明確な方法を推奨する"]'::jsonb, 3, 'Larry Wall は「プログラマーはクリエイティブでありたいと思っており、コードを書く理由は人それぞれ異なる」という考えから Perl に複数の方法を用意した。一方 Python は Guido van Rossum が「一つの明確な方法があるべきだ（There should be one obvious way to do it）」という思想で設計しており、両者の設計哲学は対照的。これは Python の for 文がシーケンスをシンプルに反復する唯一の方法を提供していることにも表れている。', 'https://peps.python.org/pep-0020/', 'unpublished', false),
  (456, 'セクション135: Python GIL', 'GIL の基本的な説明', 'GIL（Global Interpreter Lock）の説明として最も正しいものはどれか。', NULL, '["CPython のすべてのオブジェクトに個別にかけられるロック", "マルチプロセス間でメモリを共有するための仕組み", "Python インタープリター全体にかけられた単一のロックで、同時に実行できるスレッドを1つに制限する", "I/O バウンドな処理を高速化するための非同期処理の仕組み"]'::jsonb, 2, 'GIL はインタープリター全体にかかる単一のロックで、Python バイトコードを実行するには必ずこのロックを取得する必要がある。そのため複数のスレッドが存在しても同時に実行できるのは常に1つのみとなる。オブジェクトごとのロックではなく、インタープリター全体への単一ロックという点がポイント。', 'https://docs.python.org/3/glossary.html#term-global-interpreter-lock', 'unpublished', false),
  (457, 'セクション136: Python GIL', 'GIL が導入された理由', 'GIL が導入された根本的な理由として最も適切なものはどれか。', NULL, '["マルチコア CPU を効率的に活用するため", "非同期処理を簡単に実装するため", "シングルスレッドのパフォーマンスを下げるため", "参照カウントによるメモリ管理をスレッドセーフにするため"]'::jsonb, 3, 'CPython はメモリ管理に参照カウントを使用している。複数のスレッドが同時に参照カウントを変更するとメモリの破壊やクラッシュが発生する。オブジェクトごとにロックをかける方法もあるが大幅な性能低下を招くため、インタープリター全体への単一ロック（GIL）という解決策が採用された。', 'https://docs.python.org/3/glossary.html#term-global-interpreter-lock', 'unpublished', false),
  (458, 'セクション137: Python GIL', 'GIL の影響を最も受けるワークロード', 'GIL の影響を最も強く受けるワークロードはどれか。', NULL, '["ファイルの読み書きを行う I/O バウンドな処理", "ネットワークリクエストを大量に行う処理", "asyncio を使った非同期処理", "複数スレッドで重い計算を行う CPU バウンドな処理"]'::jsonb, 3, 'GIL は I/O 待ち中に解放されるため、I/O バウンドな処理や asyncio への影響は小さい。一方 CPU バウンドな処理では GIL が解放されないため、マルチスレッドにしても並列実行ができず性能向上が見込めない。これが GIL の最大の問題点とされている。', 'https://docs.python.org/3/glossary.html#term-global-interpreter-lock', 'unpublished', false),
  (459, 'セクション138: Python GIL', 'CPU バウンド処理の真の並列実行', 'CPU バウンドな処理を Python で真の並列実行する最も適切な方法はどれか。', NULL, '["threading モジュールでスレッド数を増やす", "asyncio で非同期処理を使う", "multiprocessing モジュールでプロセスを分割する", "time.sleep() でスレッドを一時停止する"]'::jsonb, 2, 'multiprocessing はプロセスごとに独自の Python インタープリターと GIL を持つため、マルチコア CPU を活かした真の並列実行が可能。threading は GIL の制約を受けるため CPU バウンドな処理では効果がない。asyncio はシングルスレッドで動作するため並列計算には向かない。', 'https://docs.python.org/3/glossary.html#term-global-interpreter-lock', 'unpublished', false),
  (460, 'セクション139: Python GIL', 'NumPy が GIL を回避できる理由', 'NumPy や Pandas が GIL の影響を回避できる理由として正しいものはどれか。', NULL, '["Python ではなく Java で実装されているため", "GIL を完全に削除した独自のインタープリターを使うため", "asyncio と組み合わせて使うことで自動的に GIL が解放されるため", "C や Cython で実装されており、計算中に GIL を手動で解放できるため"]'::jsonb, 3, 'NumPy や Pandas などの科学計算ライブラリは C や Cython で実装されており、重い計算処理中に GIL を手動で解放できる。これにより他の Python スレッドと並列に処理を実行することが可能となる。これが Python の科学計算エコシステムが GIL の制約を実用上回避できている理由。', 'https://docs.python.org/3/glossary.html#term-global-interpreter-lock', 'unpublished', false),
  (461, 'セクション140: Python GIL', 'Python 3.13 以降の GIL の扱い', 'Python 3.13 以降の GIL に関する説明として正しいものはどれか。', NULL, '["GIL が完全に削除されデフォルトでフリースレッドになった", "GIL は Python 3.13 で廃止が決定し 3.14 で完全削除される", "GIL の影響を受けるのは CPU バウンドな処理のみに限定された", "PEP 703 により GIL がオプション化され、フリースレッドビルドが導入されたが標準ビルドは引き続き GIL を使用する"]'::jsonb, 3, 'Python 3.13 では PEP 703 により GIL をオプションとするフリースレッドビルドが導入された。しかし標準ビルドは引き続き GIL を使用しており、エコシステム（NumPy・Pandas・TensorFlow など多数の C 拡張）がフリースレッドに対応するまでこの状態が続く。Python 3.14 ではフリースレッドビルドが実験的段階を超えて進化する予定。', 'https://docs.python.org/3/glossary.html#term-global-interpreter-lock', 'unpublished', false),
  (462, 'セクション141: CuPy', 'CuPy の最大の特徴', 'CuPy の最大の特徴として最も適切なものはどれか。', NULL, '["Python コードを C++ に変換して CPU 上で高速実行する", "NumPy のコードを JIT コンパイルして高速化する", "GPU プログラミングのための全く新しい API を提供する", "NumPy/SciPy と同じ API を GPU 上で動かせるようにする"]'::jsonb, 3, 'CuPy の最大の特徴は `numpy` を `cupy` に置き換えるだけで GPU 上で実行できる点。GPU プログラミングに必要な専門知識（CUDA など）がなくても NumPy と同じ API で使えるため、学習コストが非常に低い。', 'https://docs.cupy.dev/en/stable/', 'unpublished', false),
  (463, 'セクション142: CuPy', 'import cupy as np の動作', '次のコードについて正しい説明はどれか。', 'import cupy as np
result = np.array([1, 2, 3]) * 2', '["このコードは CPU 上で実行される", "このコードはエラーになる", "NumPy と CuPy は全く異なる API のため動作しない", "`import cupy as np` とすることで NumPy と同じ書き方のまま GPU 上で実行できる"]'::jsonb, 3, 'CuPy は NumPy と同じ API を提供しているため `import cupy as np` とエイリアスを設定するだけで既存の NumPy コードをほぼそのまま GPU 上で実行できる。これが CuPy の設計思想の核心。', 'https://docs.cupy.dev/en/stable/', 'unpublished', false),
  (464, 'セクション143: CuPy', 'CuPy が GIL の制約を受けにくい理由', 'CuPy が GIL の制約を受けにくい理由として最も適切なものはどれか。', NULL, '["CuPy は GIL を独自に削除した特別な Python インタープリターを使うから", "CuPy はマルチプロセスで動作するから", "CuPy は asyncio を使って非同期処理をするから", "計算処理を CPU ではなく GPU 側に逃がすため、GIL の制約を受けずに並列計算できるから"]'::jsonb, 3, 'GIL は CPython のスレッドによる CPU 並列処理を制限するものだが、CuPy はそもそも計算処理を GPU 上で行うため GIL の制約を実質的に回避できる。これは NumPy などの C 拡張ライブラリが GIL を解放して並列実行できることと同様の考え方。', 'https://docs.cupy.dev/en/stable/', 'unpublished', false),
  (465, 'セクション144: CuPy', 'CuPy の開発背景', 'CuPy の開発背景として正しいものはどれか。', NULL, '["Microsoft が Windows ユーザー向けに開発したライブラリ", "Nvidia が CUDA の普及のために開発したライブラリ", "Python コミュニティが公式に開発したライブラリ", "日本の AI スタートアップ Preferred Networks が 2015 年にオープンソース化したライブラリ"]'::jsonb, 3, 'CuPy は日本の AI スタートアップ企業 Preferred Networks によって開発され、2015 年にオープンソース化された。現在は Nvidia や AMD のエンジニアを含む世界 300 人以上のコントリビューターによるコミュニティで開発されており、ベンダーニュートラルな運営を心がけている。', 'https://docs.cupy.dev/en/stable/', 'unpublished', false),
  (466, 'セクション145: CuPy', 'Guido が示した CuPy の将来への提案', 'Guido が CuPy のプレゼンを聞いて述べた将来への提案として最も適切なものはどれか。', NULL, '["CuPy を Python の標準ライブラリに組み込むべきだ", "CuPy の API を NumPy から切り離して独自に発展させるべきだ", "GPU サポートは Python コア側で実装すべきでライブラリには任せるべきでない", "将来的に CuPy の実装を活用して GPU サポートが NumPy 自体に統合される可能性がある"]'::jsonb, 3, 'Guido は Python コアとライブラリの分離を評価しつつも「将来的に CuPy や似たプロジェクトを利用して GPU サポートが NumPy 自体に入る可能性もある」と述べた。これは CuPy の実装を NumPy 本体に取り込むことでより多くのユーザーが GPU の恩恵を受けられるというビジョンを示している。', 'https://docs.cupy.dev/en/stable/', 'unpublished', false),
  (467, 'セクション146: CuPy', 'CuPy のサポート内容（誤っているものを選ぶ）', 'CuPy がサポートしている内容として誤っているものはどれか。', NULL, '["線形代数・FFT・画像処理などの幅広いアルゴリズム", "最新の GPU だけでなく 10 年前の GPU にも対応", "scikit-learn・spaCy・Dask など業界標準フレームワークとの連携", "NumPy/SciPy API のカバレッジは同種ライブラリの中で最も低い"]'::jsonb, 3, '正しくは「同種のライブラリの中で NumPy と SciPy API のカバレッジが最も高い」。CuPy は幅広い API カバレッジを持つことが強みの一つであり、研究から本番環境まで信頼できる選択肢となっている点が強調されていた。', 'https://docs.cupy.dev/en/stable/', 'unpublished', false),
  (468, 'セクション147: Python エコシステム', 'Guido が urllib3 に当初違和感を持った理由', 'Guido が urllib3 に当初違和感を持った理由として最も適切なものはどれか。', NULL, '["urllib3 が Python 2 にしか対応していなかったから", "urllib3 がオープンソースではなかったから", "urllib3 が GIL の問題を解決できなかったから", "標準ライブラリにすでに urllib と urllib2 が存在しているのに、サードパーティが urllib3 と名乗ったから"]'::jsonb, 3, 'urllib・urllib2 は Python 標準ライブラリとして存在していた。そこにサードパーティライブラリが「urllib3」と名乗ったことに Guido は違和感を覚えた。しかし後に Web の進化は標準ライブラリより速く、サードパーティが柔軟に対応できることの価値を認め「私が間違っていた」と率直に認めた。', 'https://docs.python.org/3/', 'unpublished', false),
  (469, 'セクション148: Python 実用例', '電子辞書のリバースエンジニアリングで Python が活躍した場面', '電子辞書のリバースエンジニアリングで Python が最も活躍した場面はどれか。', NULL, '["Linux カーネルのコンパイル", "ブートローダーの設計", "UART によるシリアル通信", "SoC のレジスタ値のビット操作・分解・結合・送信の自動化"]'::jsonb, 3, 'SoC のレジスタは 32bit の固定幅整数に複数の設定値が詰め込まれており、フィールドごとに分解・変更・再結合・送信という繰り返しの作業が必要だった。これを手動で行うのは非常に困難なため Python で自動化するツールを作成した。これが発表の核心部分。', 'https://docs.python.org/3/', 'unpublished', false),
  (470, 'セクション149: Python 型システム', 'comtypes への静的型付け導入のメリット（誤りを選ぶ）', 'comtypes への静的型付け導入の主なメリットとして誤っているものはどれか。', NULL, '["エディタでの自動補完が効くようになる", "型の不一致を実行前に検出できる", "mypy などの静的解析ツールが使えるようになる", "実行速度が C 言語と同等になる"]'::jsonb, 3, '静的型付けの導入によるメリットはエディタ補完・バグの早期発見・コードの可読性向上・静的解析ツールの利用などであり、実行速度の向上は主な目的ではない。Python の型注釈はあくまでヒントであり、実行時の速度には直接影響しない。', 'https://docs.python.org/3/library/typing.html', 'unpublished', false),
  (471, 'セクション150: Python 設計思想', 'Guido が LLM について 18 歳の学生に伝えたメッセージ', 'Guido が LLM（大規模言語モデル）について 18 歳の学生に伝えたメッセージとして最も適切なものはどれか。', NULL, '["LLM は確実に世界を変えるので積極的に学ぶべきだ", "LLM は一時的な流行なので別の分野を学ぶべきだ", "LLM は Python の標準ライブラリに組み込まれるべきだ", "LLM が未来かどうか分からないが、その不確実性自体が面白い時代であり好奇心を持って進むべきだ"]'::jsonb, 3, 'Guido は LLM が「未来なのか一時的な流行なのか」「勢いが失われるのか世界を変えるのか」について率直に「分からない」と述べた。その上で「follow your heart, be curious」という姿勢についてのメッセージで締めくくった。Python の生みの親が不確実性を正直に認める知的誠実さが印象的な発言。', 'https://peps.python.org/pep-0020/', 'unpublished', false),
  (472, 'セクション151: Python 設計思想', 'Guido が一貫して主張している Python の設計思想', 'Guido が一貫して主張している Python の設計思想として最も適切なものはどれか。', NULL, '["すべての機能を Python コアに統合すべきだ", "サードパーティライブラリは標準ライブラリに統合すべきだ", "Python コアは GIL を永続的に維持すべきだ", "Python コアは小さく保ち、機能はライブラリで提供するほうが良い"]'::jsonb, 3, 'Guido は urllib3 への評価、CuPy セッションでの「Python コアと NumPy のようなライブラリの間に境界があるのは良いことだ」という発言、そして GIL なしビルドをオプションとして提供する PEP 703 への支持など、一貫して「コアは小さく・機能はライブラリで」という設計思想を示している。', 'https://peps.python.org/pep-0020/', 'unpublished', false),
  (473, 'セクション152: Web 標準・HTML 歴史', 'DOCTYPE 宣言の PUBLIC の意味', '次の DOCTYPE 宣言の PUBLIC の意味として正しいものはどれか。', '<!DOCTYPE HTML PUBLIC "-//connolly hal.com//DTD WWW HTML Date 1994/04/19 17:24:06 //EN">', '["この HTML ファイルが公開 Web サーバーで使われることを示す", "この DTD がパブリックドメインであることを示す", "この HTML が一般公開されていることを示す", "DTD が特定のシステム固有ではなく一般に公開された識別子を持つことを示す"]'::jsonb, 3, 'SGML の FPI（Formal Public Identifier）フォーマットにおける PUBLIC は、DTD が特定のシステム固有のものではなく公開された識別子を持つことを示す。対義語は SYSTEM で、システム固有のパスを指定する場合に使われる。', 'https://developer.mozilla.org/en-US/docs/Web/HTML', 'unpublished', false),
  (474, 'セクション153: Web 標準・HTML 歴史', 'FPI の先頭の "-" の意味', '次の DOCTYPE 宣言の "-" が意味することとして正しいものはどれか。', '<!DOCTYPE HTML PUBLIC "-//connolly hal.com//DTD...">', '["この DTD が非推奨であることを示す", "この DTD が非公開であることを示す", "この DTD が削除予定であることを示す", "DTD の作成者が ISO などに公式登録されていない組織・個人であることを示す"]'::jsonb, 3, 'FPI フォーマットでは最初の `-` または `+` が登録状態を示す。`-` は非登録（ISO などの公式機関に登録されていない）、`+` は登録済みを意味する。W3C が正式に標準化した後の DOCTYPE では `+//W3C//` という形式になった。', 'https://developer.mozilla.org/en-US/docs/Web/HTML', 'unpublished', false),
  (475, 'セクション154: Web 標準・HTML 歴史', '1994 年に存在した廃止済み HTML タグ', '1994 年の HTML にあって現在の HTML には存在しないタグとして正しいものはどれか。', NULL, '["<strong>", "<pre>", "<dl>", "<next>"]'::jsonb, 3, '`<next>` は次のページを示すために使われた現在は廃止されたタグ。`<strong>`・`<pre>`・`<dl>` は 1994 年当時から存在し現在の HTML でも使われている。現在は次ページへのリンクは `<a rel="next" href="...">` や `<link rel="next">` で表現する。', 'https://developer.mozilla.org/en-US/docs/Web/HTML', 'unpublished', false),
  (476, 'セクション155: Web 標準・HTML 歴史', '1994 年の DOCTYPE のタイムスタンプが秒単位な理由', '1994/04/19 17:24:06 というタイムスタンプが秒単位で記録されている理由として最も適切なものはどれか。', '<!DOCTYPE HTML PUBLIC "-//connolly hal.com//DTD WWW HTML Date 1994/04/19 17:24:06 //EN">', '["HTML の仕様上、秒単位の記録が義務付けられていたから", "Dan Connolly が手動で秒単位まで記録したから", "SGML の仕様でタイムスタンプの形式が決まっていたから", "当時のバージョン管理システム（CVS）が自動的に付与したタイムスタンプだから"]'::jsonb, 3, '当時は CVS（Concurrent Versions System）というバージョン管理システムが使われており、ファイルの変更時刻を秒単位で自動記録していた。これは現在の Git のコミットハッシュに相当するもので、ファイルのバージョンを一意に識別するために使われていた。', 'https://developer.mozilla.org/en-US/docs/Web/HTML', 'unpublished', false),
  (477, 'セクション156: Web 標準・HTML 歴史', 'HTML DOCTYPE 宣言の歴史的な変化の順序', 'HTML の DOCTYPE 宣言の歴史的な変化として正しい順序はどれか。', NULL, '["<!DOCTYPE html> → HTML 4.01 → 1994 年の DTD", "HTML 4.01 → <!DOCTYPE html> → 1994 年の DTD", "<!DOCTYPE html> → 1994 年の DTD → HTML 4.01", "1994 年の DTD → HTML 4.01 → <!DOCTYPE html>"]'::jsonb, 3, '1994 年の Dan Connolly の DTD は HTML 2.0 への橋渡しとなり、その後 HTML 4.01（1999 年）、そして現在の HTML5 の `<!DOCTYPE html>`（2014 年）へと進化した。30 年間で DOCTYPE 宣言は劇的にシンプルになっており、この変化は Web 標準化の歴史を象徴している。', 'https://developer.mozilla.org/en-US/docs/Web/HTML', 'unpublished', false),
  (478, 'セクション157: Web 標準・HTML 歴史', '1994 年と現在の HTML の違い（誤りを選ぶ）', '1994 年当時の HTML と現在の HTML の違いとして誤っているものはどれか。', NULL, '["1994 年当時はタグが大文字で書かれることが多かった", "1994 年当時はページ内リンクに NAME 属性が使われていた", "1994 年当時は <p> タグに閉じタグが不要だった", "1994 年当時は <a href=\"...\"> という形式は存在しなかった"]'::jsonb, 3, '`<a href="...">` という形式は 1994 年当時からすでに存在しており、現在も全く同じ形で使われている。これは Web の黎明期に設計されたリンクの基本構造が 30 年後も変わらず生き続けていることを示す。変わった点はタグの大文字小文字・NAME 属性から id 属性への移行・`<p>` の閉じタグの追加などである。', 'https://developer.mozilla.org/en-US/docs/Web/HTML', 'unpublished', false),
  (479, 'セクション158: Web 標準・Quirks Mode', '不完全な DOCTYPE でもブラウザが表示できる理由', '不完全な DOCTYPE 宣言を書いたとき、ブラウザが画面を表示できる理由として最も適切なものはどれか。', NULL, '["不完全な DOCTYPE 宣言は自動的に修正されるから", "DOCTYPE 宣言はブラウザの表示に全く影響しないから", "不完全な DOCTYPE 宣言は標準モードで動作するから", "ブラウザがエラーを推測して補完し、なんとか表示しようとするから"]'::jsonb, 3, 'ブラウザは HTML に文法エラーがあってもエラー画面にせず、推測して表示しようとする。ただしその際に Quirks Mode（互換モード）が発動し、意図しない挙動が起きる可能性がある。表示できることと「正しく動いている」ことは別物。', 'https://developer.mozilla.org/en-US/docs/Web/HTML/Guides/Quirks_mode_and_standards_mode', 'unpublished', false),
  (480, 'セクション159: Web 標準・Quirks Mode', 'Quirks Mode が発動する条件', 'Quirks Mode（互換モード）が発動する条件として最も適切なものはどれか。', NULL, '["CSS ファイルが読み込めなかったとき", "JavaScript にエラーがあるとき", "サーバーのレスポンスが遅いとき", "不完全・不明な DOCTYPE 宣言が書かれているとき"]'::jsonb, 3, 'Quirks Mode はブラウザがページを「古いルールで作られたもの」と判断したときに発動する。主なトリガーは DOCTYPE 宣言の省略・不完全な記述・ブラウザが認識できない DTD の指定など。CSS エラーや JavaScript エラーは Quirks Mode とは無関係。', 'https://developer.mozilla.org/en-US/docs/Web/HTML/Guides/Quirks_mode_and_standards_mode', 'unpublished', false),
  (481, 'セクション160: Web 標準・Quirks Mode', 'Quirks Mode 発動時の問題（誤りを選ぶ）', 'Quirks Mode が発動したときに起こりうる問題として誤っているものはどれか。', NULL, '["CSS のボックスモデルの計算が意図通りにならない", "ブラウザごとに表示が異なる", "一部の機能が正常に動作しなくなる", "ページの読み込み速度が著しく低下する"]'::jsonb, 3, 'Quirks Mode はレンダリング（描画）のルールが古いものになる状態であり、読み込み速度への直接的な影響はない。主な問題は CSS のボックスモデルの計算の違い・クロスブラウザ対応の悪化・一部機能の誤動作など、あくまで表示・動作の不具合である。', 'https://developer.mozilla.org/en-US/docs/Web/HTML/Guides/Quirks_mode_and_standards_mode', 'unpublished', false),
  (482, 'セクション161: Web 標準・Quirks Mode', 'ブラウザの 3 つのレンダリングモード', 'ブラウザの 3 つのレンダリングモードとして正しい組み合わせはどれか。', NULL, '["Quirks Mode・Legacy Mode・Modern Mode", "Safe Mode・Normal Mode・Strict Mode", "Classic Mode・Standard Mode・Enhanced Mode", "Quirks Mode・Almost Standards Mode・Standards Mode"]'::jsonb, 3, 'ブラウザには 3 つのレンダリングモードが存在する。Standards Mode は正しい DOCTYPE 宣言で動作する現代の標準モード、Almost Standards Mode は一部の古い DOCTYPE で動作するほぼ標準のモード、Quirks Mode は不完全・不明な DOCTYPE で発動する古い挙動のモード。', 'https://developer.mozilla.org/en-US/docs/Web/HTML/Guides/Quirks_mode_and_standards_mode', 'unpublished', false),
  (483, 'セクション162: Web 標準・Quirks Mode', 'Standards Mode を確実に有効にする DOCTYPE 宣言', '現代の HTML で標準モード（Standards Mode）を確実に有効にする正しい DOCTYPE 宣言はどれか。', NULL, '["<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01//EN\">", "<!DOCTYPE HTML PUBLIC \"-//connolly hal.com//DTD WWW HTML Date 1994/04/19 17:24:06 //EN\">", "<!DOCTYPE HTML STRICT>", "<!DOCTYPE html>"]'::jsonb, 3, 'HTML5 で導入された `<!DOCTYPE html>` が現在の正解。大文字小文字を問わず認識されるが慣習的に小文字で書くことが多い。1994 年の DTD や古い HTML 4.01 の DOCTYPE は現代のブラウザに認識されないため Quirks Mode になる場合がある。', 'https://developer.mozilla.org/en-US/docs/Web/HTML/Guides/Quirks_mode_and_standards_mode', 'unpublished', false),
  (484, 'セクション163: Web 標準・Quirks Mode', '<!DOCTYPE html> がシンプルになった歴史的な理由', '`<!DOCTYPE html>` というシンプルな形式が採用された歴史的な理由として最も適切なものはどれか。', '<!DOCTYPE html>', '["HTML5 で SGML との互換性が完全に廃止されたから", "W3C が著作権上の理由で DTD の記載を禁止したから", "ブラウザが DTD を読み込まなくなったから", "複雑な DOCTYPE 宣言の書き間違いによる表示崩れや Quirks Mode の発動が世界中で多発したから"]'::jsonb, 3, '1990 年代から 2000 年代にかけて複雑な DOCTYPE 宣言の誤記による Quirks Mode 発動・表示崩れが世界中で多発した。この教訓から「誰でも間違えないシンプルな形式」として `<!DOCTYPE html>` が採用された。技術的には HTML5 は SGML ベースではなくなったため長い FPI 形式の DTD 指定が不要になったという背景もある。', 'https://developer.mozilla.org/en-US/docs/Web/HTML/Guides/Quirks_mode_and_standards_mode', 'unpublished', false),
  (485, 'セクション164: HTML アンカー仕様', 'アンカーの定義', 'アンカーとは何を示すテキストか。最も正確な説明はどれか。', NULL, '["リンクのテキストと色を定義するもの", "ハイパーテキストリンクの始点のみを示すもの", "ハイパーテキストリンクの終点のみを示すもの", "ハイパーテキストリンクの始点および/または終点を示すもの"]'::jsonb, 3, 'アンカーはハイパーテキストリンクの始点および/または終点を示すテキスト。HREF 属性を持つ場合は始点（リンクの出発点）、NAME 属性を持つ場合は終点（リンクの到達点）として機能し、両方を同時に持つことも可能。', 'https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/a', 'unpublished', false),
  (486, 'セクション165: HTML アンカー仕様', 'HREF 属性の役割', 'HREF 属性について正しい説明はどれか。', '<a href="https://example.com">リンク</a>', '["HREF が指定されている場合、そのアンカーはリンクの終点となる", "HREF が指定されていなくても、アンカーは常にリンクの始点として機能する", "HREF の値には文書内の識別子のみ指定できる", "HREF が指定されている場合、そのアンカーはリンクの始点となり、値にはネットワークアドレス（URL）が指定される"]'::jsonb, 3, 'HREF 属性が指定されている場合、そのアンカーはリンクの始点（出発点）となる。値にはネットワークアドレス（URL）が指定され、ページ内リンクの場合は `#識別子` の形式も使用できる。HREF がない場合は始点としては機能しない。', 'https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/a', 'unpublished', false),
  (487, 'セクション166: HTML アンカー仕様', 'ページ内リンクの動作', '次のコードの動作として正しいものはどれか。', '<a href="#section1">第1章へ</a>
<a name="section1">第1章</a>', '["「第1章へ」をクリックすると別のページの「第1章」へ遷移する", "「第1章へ」をクリックするとページのトップへ戻る", "name 属性は廃止されているためこのコードは動作しない", "「第1章へ」をクリックすると同じページ内の name=\"section1\" の位置へジャンプする"]'::jsonb, 3, '`href="#section1"` は同一ページ内の `name="section1"` または `id="section1"` を持つ要素へジャンプするページ内リンク。`#` はフラグメント識別子と呼ばれる。現在は `name` 属性より `id` 属性が推奨されるが、動作自体は同じ。', 'https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/a', 'unpublished', false),
  (488, 'セクション167: HTML アンカー仕様', 'NAME 属性の説明（誤りを選ぶ）', 'NAME 属性に関する説明として誤っているものはどれか。', '<a name="section1">第1章</a>', '["識別子は HTML 文書内で一意でなければならない", "識別子には任意の文字列が使用できる", "NAME 属性はオプションであり必須ではない", "別の文書から参照するにはアドレスの後にスラッシュで区切って識別子を付加する"]'::jsonb, 3, '誤りは「スラッシュで区切る」という部分。正しくは `https://example.com/page.html#section1` のように **ハッシュ記号（#）** で区切って識別子を付加する。スラッシュはパス区切り文字であり、フラグメント識別子の区切りとしては使用しない。', 'https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/a', 'unpublished', false),
  (489, 'セクション168: HTML アンカー仕様', '相対パスと絶対パスの識別', '次の 2 つの href の値について正しい説明はどれか。', '<a href="chapter/section1.html">section1</a>
<a href="https://example.com/section1.html">section1</a>', '["両方とも絶対パスである", "両方とも相対パスである", "1 つ目は絶対パス、2 つ目は相対パスである", "1 つ目は相対パス、2 つ目は絶対パスである"]'::jsonb, 3, '相対パスはスキーム（`https://`）やホスト名を持たず、現在の文書の位置を基準として解釈される。絶対パスはスキームとホスト名を含む完全な URL。`chapter/section1.html` は相対パス、`https://example.com/section1.html` は絶対パス。', 'https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/a', 'unpublished', false),
  (490, 'セクション169: HTML アンカー仕様', 'REL 属性の仕様', 'REL 属性について正しい説明はどれか。', '<a href="next.html" rel="next">次のページ</a>', '["REL 属性はリンク先のコンテンツタイプを表す", "HREF 属性がない場合でも REL 属性は自由に指定できる", "REL 属性の値はスペース区切りのリストで指定する", "REL 属性はリンクの関係性を表し、値はカンマ区切りのリストで指定する。HREF 属性がない場合は指定すべきではない"]'::jsonb, 3, 'REL 属性はリンクの関係性（relationship）を表し、値はカンマ区切りのリストで指定する。HREF 属性が存在しない場合、リンクが存在しないためREL を指定すべきではないとされている。代表的な値として `next`・`prev`・`nofollow`・`stylesheet` などがある。', 'https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/a', 'unpublished', false),
  (491, 'セクション170: HTML アンカー仕様', 'REV 属性の説明（誤りを選ぶ）', 'REV 属性に関する説明として誤っているものはどれか。', NULL, '["REV は HTML5 で廃止された", "アンカーは REL と REV の両方を持つことができる", "REL=\"X\" を持つ A から B へのリンクは REV=\"X\" を持つ B から A へのリンクと同じ関係性を表す", "REV は REL と同じ方向の関係性を表す"]'::jsonb, 3, '誤りは「REV は REL と同じ方向」という部分。REV（reverse）は REL と **逆方向** の関係性を表す。`REL="made"` が「このページを作った人へのリンク」なら、`REV="made"` は「このページを作ったことを示すリンク」を意味する。REV は HTML5 で廃止された。', 'https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/a', 'unpublished', false),
  (492, 'セクション171: HTML アンカー仕様', 'URN・TITLE・METHODS 属性の目的（誤りを選ぶ）', '次のアンカー属性と説明の組み合わせとして誤っているものはどれか。', NULL, '["URN：文書の統一資源番号（Uniform Resource Name）を指定する", "TITLE：リンク先文書のタイトルを情報として指定する", "METHODS：オブジェクトがサポートする HTTP メソッドを指定する", "METHODS：リンクの関係性をカンマ区切りのリストで指定する"]'::jsonb, 3, '誤りは D。METHODS はリンク先がサポートする HTTP メソッド（GET・POST など）を指定する属性であり、リンクの関係性を表すのは REL 属性の役割。URN は URL に依存しない恒久的な文書識別子、TITLE はリンク先のタイトルをツールチップ等で提供するための属性。', 'https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/a', 'unpublished', false),
  (493, 'セクション172: HTML アンカー仕様', 'HREF がない場合の REL 属性', 'HREF 属性が指定されていない場合、REL 属性はどうすべきか？', NULL, '["REL 属性は HREF がなくても自由に指定できる", "REL 属性は HREF が存在しない場合、指定すべきではない", "REL 属性は HREF がない場合、自動的に無効になる", "REL 属性のデフォルト値は next になる"]'::jsonb, 1, '仕様書には「REL should not be present unless HREF is present」と明記されている。HREF が存在しない場合はリンク自体が存在しないため、リンクの関係性を示す REL を指定することは意味をなさない。', 'https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/a', 'unpublished', false),
  (494, 'セクション173: HTML アンカー仕様', 'アンカーが終点として機能するための属性', 'アンカーが「終点」として機能するために必要な属性はどれか？', NULL, '["HREF 属性", "REL 属性", "NAME 属性", "URN 属性"]'::jsonb, 2, 'NAME 属性が指定されている場合、そのアンカーはリンクの終点（飛び先）となる。HREF 属性は始点（出発点）として機能させるために必要。アンカーは HREF・NAME のどちらか一方、または両方を持つことができる。', 'https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/a', 'unpublished', false),
  (495, 'セクション174: HTML アンカー仕様', 'relative name の正しい解釈', '「relative name, relative to the document''s address」の正しい解釈はどれか？', NULL, '["属性値は必ず絶対パスで記述しなければならない", "属性値はその文書のアドレスを基準とした相対名である", "属性値は別の文書の場合のみ相対パスになる", "属性値はベースアドレスが指定された場合のみ有効になる"]'::jsonb, 1, 'relative name は「相対名」、relative to は「〜に対して相対的な」という意味で、文書のアドレスを基準とした相対名であることを示している。`<base href="...">` でベースを変更することも可能だが、省略時は現在の文書のアドレスが基準となる。', 'https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/a', 'unpublished', false),
  (496, 'セクション175: HTML アンカー仕様', 'REV 属性の正しい説明', 'REV 属性について正しい説明はどれか？', NULL, '["REV=\"X\" を持つ A から B へのリンクは、REL=\"X\" を持つ B から A へのリンクと同じ関係性を表す", "REV は REL と全く同じ動作をする", "REV は HTML4 で廃止され、現在は rel 属性の反対語で表現する", "REV は HREF が存在しない場合のみ使用できる"]'::jsonb, 0, 'REV はリンクの方向が逆になる。`REV="X"` を持つ A から B へのリンクは、`REL="X"` を持つ B から A へのリンクと同じ関係性を表す。廃止されたのは HTML5 であり HTML4 ではない。', 'https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/a', 'unpublished', false),
  (497, 'セクション176: HTML アンカー仕様', 'NAME 属性の識別子のルール', 'NAME 属性の識別子について正しい説明はどれか？', NULL, '["識別子は数字で始めることができ、HTML 文書内で重複してもよい", "識別子は任意の文字列だが、HTML 文書内で一意でなければならない", "識別子は SGML 名に限定されなければならない", "識別子はハッシュ記号を含まなければならない"]'::jsonb, 1, '識別子は任意の文字列（arbitrary strings）だが、同一 HTML 文書内で一意（unique）でなければならない。重複すると `#識別子` でジャンプした際にどの要素を参照するか不定になる。ハッシュ記号は URL 側につけるものであり、NAME 属性値自体には含めない。', 'https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/a', 'unpublished', false),
  (498, 'セクション177: HTML アンカー仕様', 'URN と URL の違い', 'URN と URL の違いとして正しいものはどれか？', NULL, '["URN はリソースの場所を示し、URL はリソースの名前を示す", "URN はリソースの名前を示し、場所が変わっても変わらない", "URN と URL は全く同じ概念で現在は区別されていない", "URN は HTML でのみ使用でき、URL は汎用的に使用できる"]'::jsonb, 1, 'URN（Uniform Resource Name）はリソースの名前を示す永続的な識別子で、リソースの場所が変わっても変わらない。URL（Uniform Resource Locator）はリソースの場所を示す。サーバーが移転しても URN は変わらないが URL は変わる。', 'https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/a', 'unpublished', false),
  (499, 'セクション178: HTML アンカー仕様', '別の文書の特定アンカーへのリンク', '別の文書の特定のアンカーへリンクする正しい書き方はどれか？', NULL, '["href=\"chapter.html/section1\"", "href=\"chapter.html&section1\"", "href=\"chapter.html#section1\"", "href=\"chapter.html@section1\""]'::jsonb, 2, 'アドレスの後にハッシュ記号（`#`）で区切って識別子を付加するのが仕様で定められた書き方。`/` はパス区切り、`&` はクエリパラメータの区切り、`@` はユーザー情報の区切りであり、いずれもフラグメント識別子の区切りとしては使用しない。', 'https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/a', 'unpublished', false),
  (500, 'セクション179: HTML アンカー仕様', 'TITLE 属性の正しい説明', 'TITLE 属性について正しい説明はどれか？', NULL, '["TITLE 属性の値は HREF で指定された文書の TITLE と同じ値でなければならない", "TITLE 属性はアンカーの表示テキストを変更する", "TITLE 属性は SEO 対策のために必須の属性である", "TITLE 属性は REL 属性と組み合わせた場合のみ有効になる"]'::jsonb, 0, 'TITLE 属性は情報提供のみを目的とし、その値は HREF 属性で指定された文書の TITLE の値と同じでなければならないとされている。表示テキストを変更するのは要素のコンテンツ（テキストノード）であり、TITLE 属性ではない。', 'https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/a', 'unpublished', false),
  (501, 'セクション180: HTML アンカー仕様', '@@NOTE の正しい解釈', '仕様書中の @@NOTE の正しい解釈はどれか？', NULL, '["仕様が完全に確定した内容を示すマーク", "著者が仕様の不備や曖昧さを自ら認めたメモ書き", "HTML の登録機関による公式な注記", "URI の仕様書から引用した内容を示すマーク"]'::jsonb, 1, '@@NOTE は草稿段階の仕様書において、著者が仕様の不備や曖昧さを自ら認めたメモ書き。`@@` はまだ整理されていない課題や TODO を示す非公式なマーカーであり、確定した仕様や公式な注記ではない。', 'https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/a', 'unpublished', false),
  (502, 'セクション181: HTML アンカー仕様', 'REL 属性のデフォルト値', 'REL 属性のデフォルト値は何か？', NULL, '["next", "none", "void", "null"]'::jsonb, 2, '仕様書には「The default relationship if none other is given is void」と明記されている。`void` はリンクの関係性が未定義であることを示すデフォルト値。`none`・`null` は HTML のリンク仕様では使われない値。', 'https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/a', 'unpublished', false),
  (503, 'セクション182: Python REPL・pathlib', 'REPL で __file__ が定義されていない理由', 'Python の REPL で `__file__` が定義されていない理由として正しいものはどれか？', '>>> __file__
NameError: name ''__file__'' is not defined', '["REPL はファイルシステムにアクセスできないから", "`__file__` は Python 3 で廃止されたから", "REPL はスクリプトファイルから実行されていないため、ファイルパスという概念が存在しないから", "`__file__` は import されたモジュールにしか存在しないから"]'::jsonb, 2, '`__file__` はスクリプトとして実行されたときに Python インタープリターが自動でセットする変数で、そのスクリプトのパスを保持する。REPL は特定のファイルから実行されているわけではないため `__file__` が存在しない。手動で文字列として代入することで再現できる。', 'https://docs.python.org/3/library/pathlib.html', 'unpublished', false),
  (504, 'セクション183: Python REPL・pathlib', 'クォートなしパスが SyntaxError になる理由', 'REPL で次のコードが SyntaxError になる理由として正しいものはどれか？', '>>> file = /home/user/script.py
  File "<stdin>", line 1
SyntaxError: invalid syntax', '["`file` は Python の予約語だから", "パスが長すぎるから", "`=` の後にスペースが必要だから", "`/` が除算演算子として解釈され、数式として評価しようとするから"]'::jsonb, 3, 'Python はクォートで囲まれていない `/home/user/script.py` を文字列ではなく式として解釈しようとする。`/` は除算演算子のため `home ÷ user ÷ script.py` という数式とみなされ、`SyntaxError` が発生する。パスは必ずクォートで囲んで文字列リテラルとして渡す必要がある。', 'https://docs.python.org/3/library/pathlib.html', 'unpublished', false),
  (505, 'セクション184: Python REPL・pathlib', 'REPL で ROOT_DIR を求める正しいコード', 'REPL でスクリプトの `ROOT_DIR = Path(__file__).resolve().parent.parent` を再現する正しい方法はどれか？', '# スクリプト内での書き方
ROOT_DIR = Path(__file__).resolve().parent.parent', '["`__file__ = /home/user/quiz/scripts/create.py` と入力する", "`__file__ = Path(\"/home/user/quiz/scripts/create.py\")` と入力する", "`file = \"/home/user/quiz/scripts/create.py\"` と代入し `Path(file).resolve().parent.parent` で求める", "`ROOT_DIR = Path().resolve().parent.parent` と入力する"]'::jsonb, 2, 'REPL では `__file__` が存在しないため、任意の変数名（`file` など）にパスを文字列として代入し、それを `Path()` に渡すことで再現できる。`Path()` は引数なしだとカレントディレクトリを返すため D は意図した結果にならない。`__file__` という変数名自体は特別ではなく、任意の文字列変数で代替できる。', 'https://docs.python.org/3/library/pathlib.html', 'unpublished', false),
  (506, 'セクション185: Python パス解決', '__file__ が os.getcwd() より適する理由', '設定ファイルの基準パスを求めるとき、`__file__` が `os.getcwd()` より適している理由として最も正しいものはどれか？', 'cd /tmp && python /project/src/config.py', '["`__file__` は常にカレントディレクトリを返し、`os.getcwd()` はスクリプトの場所を返すから", "`__file__` はスクリプト自身のパスを基準にできるが、`os.getcwd()` は実行時の作業ディレクトリに依存してずれることがあるから", "`os.getcwd()` は相対パスしか返せないが、`__file__` は必ず URL を返すから", "`__file__` は import 時にしか使えず、スクリプト実行時には `os.getcwd()` に置き換わるから"]'::jsonb, 1, '`__file__` はそのスクリプト自身のパスを表すため、設定ファイルや同梱リソースの位置をスクリプト基準で安定して求めやすい。一方 `os.getcwd()` はコマンドを実行した作業ディレクトリを返すため、`cd /tmp && python /project/src/config.py` のように別の場所から起動すると `/tmp` になり、期待した基準パスとずれることがある。', 'https://docs.python.org/3/library/pathlib.html#pathlib.Path.resolve', 'unpublished', false),
  (507, 'セクション186: Python ファイル操作', 'open の ''a'' モードの性質', 'Python の `open("app.log", "a")` の説明として最も正しいものはどれか？', 'with open("app.log", "a", encoding="utf-8") as f:
    f.write("started\n")', '["既存ファイルの先頭に追記し、存在しない場合はエラーになる", "既存ファイルを空にしてから書き込み、存在しない場合は新規作成する", "既存ファイルがあれば末尾に追記し、存在しなければ新規作成するのでログ追記に向いている", "読み取り専用で開くが、`write()` を呼んだときだけ自動で追記モードに切り替わる"]'::jsonb, 2, '`''a''` は append モードで、既存ファイルがあれば内容を消さず末尾に追記し、存在しなければ新しく作成する。`''w''` のように既存内容を上書きしないため、過去の記録を残したいログファイルの書き込みに適している。', 'https://docs.python.org/3/tutorial/inputoutput.html#reading-and-writing-files', 'unpublished', false),
  (508, 'セクション187: Python オブジェクト設計', 'docstring が説明するクラスの性質', '次の docstring の説明として最も適切なものはどれか？', '"""Simple object for storing attributes.

Implements equality by attribute names and values, and provides a simple
string representation.
"""', '["属性を保存するだけの単純なオブジェクトで、属性名と値が同じなら等しいと判定され、簡潔な文字列表現も持つ", "属性の型を自動推論して、値が違っていても属性名が同じなら等しいと判定する", "属性を暗号化して保存し、比較時にはメモリアドレスだけで等価性を判定する", "文字列表現だけを提供し、等価比較は常に `is` と同じ参照比較になる"]'::jsonb, 0, 'この docstring は、そのオブジェクトが属性を格納するための単純な入れ物であり、比較はオブジェクトの参照ではなく属性名とその値に基づいて行うこと、さらに内容を分かりやすく表示するための簡単な文字列表現も備えていることを説明している。', 'https://docs.python.org/3/reference/datamodel.html', 'unpublished', false),
  (509, 'セクション188: Python 上級クイズ', '可変デフォルト引数の再利用', '次のコードを実行した結果として正しいものはどれか？', 'def func(lst=[]):
    lst.append(1)
    return lst

print(func())
print(func())', '["1回目も2回目も `[1]` が表示される", "1回目は `[1]`、2回目は `[1, 1]` が表示される", "1回目は `[1]`、2回目は `[]` が表示される", "実行時エラーになる"]'::jsonb, 1, 'デフォルト引数の `[]` は関数定義時に1回だけ生成され、その後の呼び出しで同じリストが再利用される。1回目で `[1]` になった同じリストに、2回目でさらに `1` が追加されるため `[1, 1]` になる。', 'https://docs.python.org/3/reference/datamodel.html', 'unpublished', false),
  (510, 'セクション189: Python 上級クイズ', 'getrefcount が 1 多く見える理由', '`sys.getrefcount(x)` が実際の参照カウントより 1 多く返る理由として最も正しいものはどれか？', 'import sys
lst = []
print(sys.getrefcount(lst))', '["`sys` モジュールが内部でオブジェクトを複製するから", "`getrefcount` に引数として渡す時点で一時的な参照が 1 つ増えるから", "CPython の既知のバグだから", "`x` がグローバル変数として保持されるから"]'::jsonb, 1, '`getrefcount(x)` を呼ぶとき、`x` は関数引数として一時的に参照される。そのため表示される値には、その呼び出し自身による参照が 1 つ上乗せされる。', 'https://docs.python.org/3/reference/datamodel.html', 'unpublished', false),
  (511, 'セクション190: Python 上級クイズ', 'argparse.SUPPRESS の挙動', '`argparse.SUPPRESS` をデフォルト値として使ったときの挙動として最も正しいものはどれか？', 'import argparse
parser = argparse.ArgumentParser(argument_default=argparse.SUPPRESS)
parser.add_argument(''--foo'')
args = parser.parse_args([])', '["未指定の引数には必ず `None` が入り、`args.foo` は `None` になる", "未指定の引数は `Namespace` に属性自体が作られない", "未指定の引数には空文字列が入り、`args.foo == ''''` になる", "未指定の引数は自動的に必須引数へ変わる"]'::jsonb, 1, '`SUPPRESS` は「未指定ならその属性を作らない」という特別な挙動を指示する。したがって `args.foo` は `None` ではなく、属性自体が存在しないため直接アクセスすると `AttributeError` になる。', 'https://docs.python.org/3/reference/datamodel.html', 'unpublished', false),
  (512, 'セクション191: Python 上級クイズ', 'ROOT_DIR が指す場所', '次のコードで `ROOT_DIR` が指すディレクトリとして正しいものはどれか？', '# ファイルパス: /project/scripts/migrate.py
ROOT_DIR = Path(__file__).resolve().parent.parent', '["`/project/scripts/`", "`/project/`", "`/project/scripts/migrate.py`", "実行時のカレントディレクトリ"]'::jsonb, 1, '`__file__` は現在のスクリプトファイルを指し、`.parent` で `scripts` ディレクトリ、さらに `.parent` でその親の `/project/` に移動する。したがって `ROOT_DIR` はリポジトリルート相当の `/project/` を指す。', 'https://docs.python.org/3/reference/datamodel.html', 'unpublished', false),
  (513, 'セクション192: Python 上級クイズ', 'os.getcwd() がずれる理由', '`os.getcwd()` が設定ファイルの基準パス取得に不向きになることがある理由として最も正しいものはどれか？', '# /tmp で実行
python /project/src/config.py', '["`__file__` が相対パスしか返さないから", "`getcwd()` はスクリプトの場所ではなく、実行時の作業ディレクトリを返すから", "`pathlib` と互換性がないから", "Python 3 では非推奨だから"]'::jsonb, 1, '`os.getcwd()` はそのプロセスのカレントディレクトリを返す。上の例ではスクリプト本体が `/project/src/config.py` にあっても、`/tmp` から起動すれば `/tmp` が返るため、スクリプト位置を基準にしたい用途ではずれが起きる。', 'https://docs.python.org/3/reference/datamodel.html', 'unpublished', false),
  (514, 'セクション193: Python 上級クイズ', '参照カウント 0 の基本挙動', 'CPython で参照カウントが 0 になったオブジェクトに対する基本挙動として最も正しいものはどれか？', NULL, '["フラグだけを立て、必ず後で非同期に削除する", "関連する後始末を行い、そのメモリを Python ランタイムが再利用できる状態にする", "必ず OS に即時返却される", "弱参照だけを残して本体は見えなくする"]'::jsonb, 1, 'CPython では参照カウントが 0 になると、通常はその場で解放処理が進む。ただし『常に OS にメモリが返る』とは限らず、実際には Python のメモリアロケータ管理下で再利用可能になることも多い。なお循環参照は別の GC の対象になる。', 'https://docs.python.org/3/reference/datamodel.html', 'unpublished', false),
  (515, 'セクション194: Python 上級クイズ', 'missing_ok=True が防ぐ例外', '次のコードで `missing_ok=True` が防いでいる例外はどれか？', 'link.unlink(missing_ok=True)', '["`FileExistsError`", "`PermissionError`", "`FileNotFoundError`", "`OSError` 全般"]'::jsonb, 2, '`missing_ok=True` は、削除対象が存在しない場合に `FileNotFoundError` を送出しないための指定。権限不足やその他の OS エラーまで無視するわけではない。', 'https://docs.python.org/3/reference/datamodel.html', 'unpublished', false),
  (516, 'セクション195: Python 上級クイズ', '__defaults__ に値が入るタイミング', '次の関数において、`func.__defaults__` にデフォルト引数の値が格納されるタイミングとして正しいものはどれか？', 'def func(lst=[]):
    pass', '["`func()` が初めて呼ばれたとき", "`def` 文が実行されて関数オブジェクトが作られたとき", "モジュールが import されるたびに毎回新しく", "Python インタープリタ起動時"]'::jsonb, 1, 'デフォルト引数は関数呼び出し時ではなく、`def` 文が実行された時点で評価される。その結果が関数オブジェクトの `__defaults__` に保存され、以後の呼び出しで再利用される。', 'https://docs.python.org/3/reference/datamodel.html', 'unpublished', false),
  (517, 'セクション196: Python id()・メモリ', 'Python 仕様における id() の定義', 'Python 仕様における `id()` の説明として正しいものはどれか？', NULL, '["オブジェクトのメモリアドレスを返す", "オブジェクトを一意に識別する整数を返す", "オブジェクトのハッシュ値を返す", "オブジェクトのポインタそのものを返す"]'::jsonb, 1, 'Python 言語仕様が保証しているのは、`id()` がそのオブジェクトを一意に識別する整数を返すことだけであり、メモリアドレスである必要はない。CPython では実装上たまたまアドレス相当の値を使うことが多い。', 'https://docs.python.org/3/library/functions.html#id', 'unpublished', false),
  (518, 'セクション197: Python id()・メモリ', 'CPython で id() がアドレス相当になりやすい理由', 'CPython で `id()` がメモリアドレス相当の値を返す主な理由として最も適切なものはどれか？', NULL, '["Python 仕様でメモリアドレスを返すよう厳密に定められているから", "オブジェクトの一意性を実装上シンプルに保証しやすいから", "他のすべての Python 実装も同じ方式だから", "GC がオブジェクトのアドレスを永久に固定するから"]'::jsonb, 1, 'CPython では `id()` の一意性を実装しやすくするため、オブジェクトのアドレス相当の値を利用する設計が採られている。これは言語仕様ではなく、CPython 側の実装上の選択である。', 'https://docs.python.org/3/library/functions.html#id', 'unpublished', false),
  (519, 'セクション198: Python id()・メモリ', 'CPython の getrefcount の値', 'CPython で次のコードを実行したとき、`sys.getrefcount(lst)` の戻り値として最も適切なものはどれか。ここで `lst` への参照は他に存在しないものとする。', 'lst = []
import sys
print(sys.getrefcount(lst))', '["0", "1", "2", "3"]'::jsonb, 2, '`lst` を束縛している変数参照が 1 つあり、さらに `getrefcount(lst)` を呼ぶ時点で関数引数として一時参照が 1 つ追加される。そのため表示は 2 になる。`getrefcount()` は実際の参照数より常に 1 多く見える点に注意が必要。', 'https://docs.python.org/3/library/functions.html#id', 'unpublished', false),
  (520, 'セクション199: Python id()・メモリ', '生存期間が重ならないオブジェクトの id()', '生存期間が重ならない 2 つのオブジェクトの `id()` について正しい説明はどれか？', NULL, '["必ず異なる値になる", "同じ値になることがある", "常に連番になる", "比較自体ができない"]'::jsonb, 1, 'あるオブジェクトが解放された後、そのメモリ領域や識別子が別のオブジェクトに再利用されることがある。そのため、生存期間が重ならないなら同じ `id()` の値が再び現れる可能性がある。', 'https://docs.python.org/3/library/functions.html#id', 'unpublished', false),
  (521, 'セクション200: Python id()・メモリ', 'PyPy で id() の実装が異なる理由', 'PyPy で `id()` の扱いが CPython と異なりうる主な理由として正しいものはどれか？', NULL, '["PyPy は Python 仕様に準拠していないから", "移動 GC によりオブジェクトのアドレスが変わりうるから", "PyPy にはメモリアドレスという概念が存在しないから", "`id()` が JVM のオブジェクト ID を返すから"]'::jsonb, 1, 'PyPy では移動 GC によってオブジェクトがメモリ上を移動する可能性がある。そのため、アドレスそのものを `id()` に使う設計は取りにくく、CPython とは異なる内部実装が必要になる。', 'https://docs.python.org/3/library/functions.html#id', 'unpublished', false),
  (522, 'セクション201: Python 関数属性', '__annotations__ に入る内容', '通常の実行条件で、次の関数定義に対する `func.__annotations__` の内容として正しいものはどれか？', 'def func(x: int, y: str) -> bool:
    pass', '["{''x'': <class ''int''>, ''y'': <class ''str''>, ''return'': <class ''bool''>}", "{''x'': <class ''int''>, ''y'': <class ''str''>}", "{''x'': ''int'', ''y'': ''str'', ''return'': ''bool''}", "{''x'': int, ''y'': str}"]'::jsonb, 0, '`__annotations__` には引数と戻り値の型注釈が辞書として格納される。戻り値は `''return''` キーで保存されるため、`x`、`y`、`return` の3項目が入る。', 'https://docs.python.org/3/reference/datamodel.html#index-34', 'unpublished', false),
  (523, 'セクション202: Python 関数属性', '型注釈とデフォルト値の保存先', '次の関数定義で、型注釈とデフォルト値はどこに格納されるか？', 'def func(lst: list = []):
    pass', '["両方とも `__annotations__` に格納される", "両方とも `__defaults__` に格納される", "型注釈は `__annotations__`、デフォルト値は `__defaults__` に別々に格納される", "型注釈は `__defaults__`、デフォルト値は `__annotations__` に格納される"]'::jsonb, 2, '型注釈とデフォルト値は別の仕組みで管理される。`lst: list` の注釈は `__annotations__` に、`=[]` のデフォルト値は `__defaults__` に保存される。', 'https://docs.python.org/3/reference/datamodel.html#index-34', 'unpublished', false),
  (524, 'セクション203: Python 関数属性', '<class ''list''> が表すもの', 'Python で `<class ''list''>` が表しているものとして正しいのはどれか？', NULL, '["`list` 型のインスタンス", "`list` 型オブジェクトそのもの", "`list` の文字列表現だけを保存した値", "`list` のメタクラス"]'::jsonb, 1, 'Python では型そのものもオブジェクトである。`<class ''list''>` は `list` 型オブジェクトの `repr` 表現であり、リストのインスタンスではない。', 'https://docs.python.org/3/reference/datamodel.html#index-34', 'unpublished', false),
  (525, 'セクション204: Python 関数属性', '__closure__ が値を持つ条件', '関数の `__closure__` が `None` ではなく値を持つのはどのような場合か？', NULL, '["デフォルト引数がある場合", "型注釈がある場合", "外側のスコープの変数を参照するクロージャになっている場合", "グローバル変数を参照する場合"]'::jsonb, 2, '`__closure__` は、関数が外側のローカルスコープの変数を自由変数としてキャプチャしたときに、そのセルオブジェクト群を保持する。通常の関数では `None` である。', 'https://docs.python.org/3/reference/datamodel.html#index-34', 'unpublished', false),
  (526, 'セクション205: Python 関数属性', '動的に追加した関数属性の保存先', '次のコードで `my_attr` はどこに格納されるか？', 'def func():
    pass

func.my_attr = ''hello''', '["`__annotations__`", "`__dict__`", "`__code__`", "`__globals__`"]'::jsonb, 1, '関数オブジェクトに後から追加した任意属性は、その関数の `__dict__` に保存される。これは通常の Python オブジェクトへ属性を追加する仕組みと同じである。', 'https://docs.python.org/3/reference/datamodel.html#index-34', 'unpublished', false),
  (527, 'セクション206: Python 関数属性', '関数オブジェクトが参照のコンテナと言える理由', '関数オブジェクトが「参照のコンテナ」と言える理由として最も適切なものはどれか？', NULL, '["`__code__` にすべての情報が集約されているから", "`__defaults__` がすべての属性を一元管理しているから", "`__code__` や `__defaults__` などが別オブジェクトとして存在し、関数オブジェクトがそれらへの参照を保持するから", "関数呼び出しのたびに全属性がコピーされるから"]'::jsonb, 2, '関数オブジェクトは、コードオブジェクト、デフォルト引数、グローバル名前空間など複数の別オブジェクトへの参照をまとめて保持している。その意味で、値そのものではなく参照を束ねるコンテナとみなせる。', 'https://docs.python.org/3/reference/datamodel.html#index-34', 'unpublished', false),
  (528, 'セクション207: Python builtins', '__builtins__ の役割', '`__builtins__` や `builtins` モジュールが関係する役割として最も適切なものはどれか？', NULL, '["組み込み関数を毎回 `import` するための予約領域", "Python が名前解決の最後の段階で参照できる、組み込み関数・例外・定数の集合", "ユーザー定義関数だけを登録する専用辞書", "各モジュールのグローバル変数を保存する標準 API"]'::jsonb, 1, 'Python では名前がローカルやグローバルで見つからないと、最終的に組み込み名前空間が参照される。`print` や `len` を明示的な import なしで使えるのは、その組み込み名前空間に存在するからである。', 'https://docs.python.org/3/library/builtins.html', 'unpublished', false),
  (529, 'セクション208: Python builtins', '__builtins__ の値としてありうるもの', '公式説明に照らして、多くのモジュールでグローバルに見える `__builtins__` の値として通常ありうるものはどれか？', NULL, '["常に `builtins` モジュールだけ", "常に `builtins.__dict__` だけ", "`builtins` モジュールそのもの、またはその `__dict__`", "常に `None`"]'::jsonb, 2, '公式ドキュメントでは、`__builtins__` の値は通常 `builtins` モジュールそのものか、その `__dict__` 属性の値のどちらかだと説明されている。つまり型は一貫しておらず、文脈依存である。', 'https://docs.python.org/3/library/builtins.html', 'unpublished', false),
  (530, 'セクション209: Python builtins', '__builtins__[''print''] が失敗する条件', '`__builtins__[''print''](''hello'')` が `TypeError: ''module'' object is not subscriptable` で失敗する理由として正しいものはどれか？', '__builtins__[''print''](''hello'')', '["`print` という組み込み関数が存在しないから", "`__builtins__` が module であり、module は `[]` で添字アクセスできないから", "`[]` は Python の組み込み関数には使えないから", "`print` は文字列で指定してはいけないから"]'::jsonb, 1, '`__builtins__` が辞書なら `[''print'']` で取り出せるが、module の場合は添字アクセスできない。そのため、`__builtins__` の型に依存したコードは文脈次第で壊れる。', 'https://docs.python.org/3/library/builtins.html', 'unpublished', false),
  (531, 'セクション210: Python builtins', '__builtins__ の型前提が危険な理由', '`__builtins__` の型に依存したコードを書くべきでない理由として最も適切なものはどれか？', NULL, '["`__builtins__` は Python 3 で廃止予定だから", "モジュールか辞書かが文脈や実装で変わりうる実装詳細だから", "`__builtins__` はセキュリティ上アクセス禁止だから", "`__builtins__` は常に空の辞書だから"]'::jsonb, 1, '公式ドキュメントは `__builtins__` を実装詳細だと明記している。多くのモジュールで利用可能ではあるが、値が module か dict かは一定ではなく、代替実装では同じ前提が成り立たないこともある。', 'https://docs.python.org/3/library/builtins.html', 'unpublished', false),
  (532, 'セクション211: Python builtins', 'builtins.__dict__[''print''] が返すもの', '次のコードで `builtins.__dict__[''print'']` が返すものとして正しいのはどれか？', 'import builtins
print(builtins.__dict__[''print''])', '["文字列 `''print''`", "`<built-in function print>`", "`None`", "必ず `KeyError` になる"]'::jsonb, 1, '`builtins.__dict__` は組み込み名前の辞書であり、`''print''` キーには組み込み関数 `print` そのものが入っている。表示するとその `repr` である `<built-in function print>` が見える。', 'https://docs.python.org/3/library/builtins.html', 'unpublished', false),
  (533, 'セクション212: Python builtins', '安全な組み込み関数アクセス', '`__builtins__` の型に左右されず安全に組み込みの `print` へアクセスする方法として最も適切なものはどれか？', NULL, '["`__builtins__[''print''](''hello'')`", "`__builtins__.print(''hello'')`", "`import builtins; builtins.print(''hello'')`", "`globals()[''print''](''hello'')`"]'::jsonb, 2, '`import builtins` を使えば、`__builtins__` が module か dict かに依存せず、一貫した方法で組み込み関数へアクセスできる。公式ドキュメントも、組み込みを明示的に扱う場面では `builtins` モジュールを直接使う例を示している。', 'https://docs.python.org/3/library/builtins.html', 'unpublished', false),
  (534, 'セクション213: Python __call__', '__call__ を定義するとできること', 'クラスで `__call__` を定義すると、インスタンスに対して何ができるようになるか？', NULL, '["クラスのメソッドを自動で静的メソッドに変えられる", "インスタンス自体を `()` で呼び出せるようになる", "クラスを自動で継承可能にする", "インスタンスを辞書のように添字アクセスできるようになる"]'::jsonb, 1, '`__call__` を定義すると、`obj()` のような呼び出し構文が使えるようになる。実際にはその呼び出しが `obj.__call__(...)` に委譲されるため、インスタンスを関数のように振る舞わせられる。', 'https://docs.python.org/3/reference/datamodel.html#object.__call__', 'unpublished', false),
  (535, 'セクション214: Python __call__', 'クラスデコレータ適用後の add の型', '次の `@Logger` デコレータを使った後、`add` の型として正しいものはどれか？', 'class Logger:
    def __init__(self, func):
        self.func = func
    def __call__(self, *args):
        print(f''calling {self.func.__name__}'')
        return self.func(*args)

@Logger
def add(a, b):
    return a + b', '["関数オブジェクト", "`Logger` のインスタンス", "`Logger` クラスそのもの", "`None`"]'::jsonb, 1, '`@Logger` は `add = Logger(add)` と同じ意味なので、元の関数 `add` は `Logger` インスタンスで包まれる。その後の `add(1, 2)` は、そのインスタンスの `__call__` を実行する。', 'https://docs.python.org/3/reference/datamodel.html#object.__call__', 'unpublished', false),
  (536, 'セクション215: Python __call__', '__call__ がないインスタンスを呼ぶとどうなるか', '`@Logger` のように関数をラップしたインスタンスに `__call__` が定義されていない場合、そのインスタンスを `add(1, 2)` のように呼ぶとどうなるか？', NULL, '["正常に元の関数が実行される", "`TypeError` になる", "ログだけ出力されて `None` が返る", "自動的に `func` 属性が呼ばれる"]'::jsonb, 1, 'インスタンスを `()` で呼ぶには、そのオブジェクトが呼び出し可能である必要がある。`__call__` がなければ呼び出し可能ではないため、`TypeError: ''...'' object is not callable` になる。', 'https://docs.python.org/3/reference/datamodel.html#object.__call__', 'unpublished', false),
  (537, 'セクション216: Python __call__', '__call__ と通常メソッドの違い', '`__call__` を持つインスタンスと通常メソッドの違いとして最も適切なものはどれか？', NULL, '["`__call__` の方が常に高速である", "`__call__` があると、インスタンス自体を関数を期待する API に渡せる", "通常メソッドは戻り値を返せない", "`__call__` はクラスにしか定義できず、インスタンスでは使えない"]'::jsonb, 1, '`__call__` を持つインスタンスは、それ自体が callable になる。したがって関数を受け取る API にインスタンスそのものを渡せるが、通常メソッドを使う場合は `obj.method` のように明示的にメソッドを渡す必要がある。', 'https://docs.python.org/3/reference/datamodel.html#object.__call__', 'unpublished', false),
  (538, 'セクション217: Python 名前束縛', '変数名 x が表すもの', '次のコードにおける変数名 `x` の役割として最も適切なものはどれか？', 'x = []', '["`x` 自体がリストオブジェクト本体である", "`x` はリストオブジェクトへの名前束縛（参照）である", "`x` はスタック上に確保されたリストデータそのものである", "`x` は `[]` のコピーを毎回保持する"]'::jsonb, 1, 'Python の代入は、名前をオブジェクトへ束縛する操作である。`x = []` では新しいリストオブジェクトが作られ、`x` という名前がそのオブジェクトを参照する。`x` 自体がリスト本体になるわけではない。', 'https://docs.python.org/3/reference/executionmodel.html#naming-and-binding', 'unpublished', false),
  (539, 'セクション218: Python クラス属性', 'Logger と Logger.__dict__ の id が違う理由', '次のコードで `id(Logger)` と `id(Logger.__dict__)` が異なる最も本質的な理由はどれか？', 'class Logger:
    pass

print(hex(id(Logger)))
print(hex(id(Logger.__dict__)))', '["`Logger` と `Logger.__dict__` は別プロセスで管理されているから", "クラスオブジェクトと、その属性辞書を見せる `mappingproxy` は別オブジェクトだから", "`Logger` は 64bit 領域、`__dict__` は 32bit 領域に置かれるから", "`Logger.__dict__` だけがスタックに確保されるから"]'::jsonb, 1, '`Logger` はクラスオブジェクトそのものだが、`Logger.__dict__` はその属性を読み取り専用で見せる `mappingproxy` オブジェクトである。別オブジェクトなので `id()` が異なるのは自然であり、アドレスの大小関係に特別な意味はない。', 'https://docs.python.org/3/tutorial/classes.html#class-and-instance-variables', 'unpublished', false),
  (540, 'セクション219: Python クロージャ', '__closure__ が返すもの', '関数オブジェクトの `__closure__` が返すものとして正しいのはどれか？', NULL, '["外側のスコープの変数の値をそのまま返す", "`None` または cell オブジェクトのタプルを返す", "クロージャ関数の名前文字列を返す", "外側の関数オブジェクト自体を返す"]'::jsonb, 1, '`__closure__` はクロージャでない場合は `None`、クロージャである場合は自由変数を保持する cell オブジェクトのタプルを返す。実際の値そのものではなく、その値を包む cell が見える。', 'https://docs.python.org/3/reference/executionmodel.html#naming-and-binding', 'unpublished', false),
  (541, 'セクション220: Python クロージャ', 'cell_contents の意味', 'cell オブジェクトの `cell_contents` が表すものとして正しいのはどれか？', NULL, '["cell オブジェクト自身のメモリアドレス", "cell が保持している実際の値", "cell オブジェクトの型情報", "cell オブジェクトの参照カウント"]'::jsonb, 1, 'cell オブジェクトは自由変数への参照を保持しており、`cell_contents` を使うとその中に入っている実際の値を取り出せる。クロージャ経由で値が共有されていることを確認するのに使える。', 'https://docs.python.org/3/reference/executionmodel.html#naming-and-binding', 'unpublished', false),
  (542, 'セクション221: Python クロージャ', 'inner が x を覚えていられる理由', '次のコードで `outer()` の実行が終わった後も `inner()` が `x` を参照できる理由として最も適切なものはどれか？', 'def outer():
    x = 10
    def inner():
        return x
    return inner', '["`x` が自動的にグローバル変数へ昇格するから", "`x` がクロージャの cell に保持され、`inner` がその参照を持ち続けるから", "`outer` 関数オブジェクトがずっと実行中のまま残るから", "`x` は整数なので Python が特別に関数外へコピーするから"]'::jsonb, 1, 'クロージャでは、外側のローカル変数が cell オブジェクトに包まれ、その cell への参照を内側の関数が保持する。したがって `outer()` のローカルスコープが終了しても、`inner` はその cell 経由で `x` を読み続けられる。', 'https://docs.python.org/3/reference/executionmodel.html#naming-and-binding', 'unpublished', false),
  (543, 'セクション222: Python クロージャ', 'closure という名前の由来', '“closure”（クロージャ）という名前の由来として最も適切なものはどれか？', NULL, '["関数を終了させて閉じる操作を表すから", "外側のスコープの変数を関数の振る舞いの中に閉じ込める概念だから", "変数を完全に非公開にする仕組みだから", "スコープをロックして変更不能にする仕組みだから"]'::jsonb, 1, 'クロージャは、外側のスコープにあった変数を内側の関数が抱え込んで持ち続ける仕組みを指す。その『閉じ込めて保持する』イメージが closure という名前の由来である。', 'https://docs.python.org/3/reference/executionmodel.html#naming-and-binding', 'unpublished', false),
  (544, 'セクション223: Python __class__', 'obj.__class__ と type(obj) の通常の関係', '通常の型参照として見たとき、`obj.__class__` と `type(obj)` の関係として最も適切なものはどれか？', NULL, '["`__class__` はインスタンスに使えず、`type()` だけが型を返す", "`obj.__class__` は常に書き換え可能なので、`type(obj)` とは本質的に別物である", "通常はどちらも同じクラスオブジェクトを参照する", "`type()` はクラスにしか使えず、インスタンスに使うとエラーになる"]'::jsonb, 2, '通常、`obj.__class__` と `type(obj)` は同じクラスオブジェクトを指す。`__class__` 代入は一部の制約付きで可能な場合があるが、それは通常の型参照としての基本関係とは別の話である。', 'https://docs.python.org/3/reference/datamodel.html#instance-methods', 'unpublished', false),
  (545, 'セクション224: Python デコレータ', '@Logger 適用後に元の関数が残る場所', '次の `@Logger` デコレータ適用後、元の関数 `add` はどこに保持されるか？', 'class Logger:
    def __init__(self, func):
        self.func = func
    def __call__(self, *args):
        print(f''calling {self.func.__name__}'')
        return self.func(*args)

@Logger
def add(a, b):
    return a + b', '["`add.__name__` に文字列として保存される", "`Logger.func` というクラス変数に保存される", "`add.func` として、`Logger` インスタンスの属性に保存される", "デコレータ適用時に破棄されるため残らない"]'::jsonb, 2, '`@Logger` は `add = Logger(add)` と等価であり、`Logger.__init__` の `self.func = func` によって元の関数オブジェクトがインスタンス属性へ保存される。したがってデコレータ適用後の `add` は `Logger` インスタンスであり、元の関数は `add.func` から参照できる。', 'https://docs.python.org/3/glossary.html#term-decorator', 'unpublished', false),
  (546, 'セクション225: Python オブジェクトモデル', 'オブジェクトが必ず持つ3要素', 'Python 公式の説明によると、すべてのオブジェクトが必ず持つものは何か？', NULL, '["名前・型・値", "同一性（identity）・型（type）・値（value）", "アドレス・サイズ・型", "参照カウント・型・値"]'::jsonb, 1, 'Python のデータモデルは「Every object has an identity, a type and a value」と説明する。`identity` はそのオブジェクトがそのオブジェクトであること、`type` は所属する型、`value` は保持している内容を指す。', 'https://docs.python.org/3/reference/datamodel.html', 'unpublished', false),
  (547, 'セクション226: Python オブジェクトモデル', 'is 演算子が比較するもの', '`is` 演算子が比較しているものとして正しいのはどれか？', NULL, '["オブジェクトの値", "オブジェクトの型", "オブジェクトの同一性（identity）", "オブジェクトのサイズ"]'::jsonb, 2, '`is` は 2 つの参照先が同じオブジェクトかどうか、つまり同一性を比較する。`==` は値の比較であり、値が等しくても別オブジェクトなら `is` は `False` になりうる。', 'https://docs.python.org/3/reference/datamodel.html', 'unpublished', false),
  (548, 'セクション227: Python オブジェクトモデル', '== と is の違い', '次のコードの出力として正しいものはどれか？', 'a = [1, 2, 3]
c = [1, 2, 3]
print(a == c)
print(a is c)', '["`True` の後に `True`", "`False` の後に `False`", "`True` の後に `False`", "`False` の後に `True`"]'::jsonb, 2, '2 つのリストは内容が同じなので `==` は `True` になる。一方で別々に生成された別オブジェクトなので、同一性を比べる `is` は `False` になる。', 'https://docs.python.org/3/reference/datamodel.html', 'unpublished', false),
  (549, 'セクション228: Python オブジェクトモデル', 'type() が返すもの', '`type()` が返すものとして最も適切なものはどれか？', NULL, '["型名の文字列", "型オブジェクトそのもの", "型のメモリアドレス", "型の参照カウント"]'::jsonb, 1, '`type()` は文字列ではなく型オブジェクトそのものを返す。型自体もオブジェクトなので、`type(type(42))` のように『型の型』をさらに調べることもできる。', 'https://docs.python.org/3/reference/datamodel.html', 'unpublished', false),
  (550, 'セクション229: Python オブジェクトモデル', '__class__ 代入の制約', '`obj.__class__ = NewClass` という代入について、最も正しい説明はどれか？', NULL, '["どんなオブジェクトでも常に自由に型を変更できる", "一切不可能で、必ず `TypeError` になる", "一部の互換性条件を満たす場合にだけ許され、常に安全とは限らない", "ミュータブルなオブジェクトなら必ず成功する"]'::jsonb, 2, '`__class__` 代入は完全に自由ではなく、内部レイアウトなどの互換性条件を満たす一部ケースでしか許されない。したがって『オブジェクトの型はいつでも書き換えられる』と一般化するのは危険である。', 'https://docs.python.org/3/reference/datamodel.html', 'unpublished', false),
  (551, 'セクション230: Python オブジェクトモデル', '可変デフォルト引数が危険な理由', '関数のデフォルト引数に `[]` を使うのが危険な根本理由として正しいのはどれか？', NULL, '["`[]` はイミュータブルだから", "`list` はミュータブルで、同じオブジェクトが呼び出し間で共有されうるから", "`[]` は参照カウントが 0 になりやすいから", "`[]` はヒープに置かれないから"]'::jsonb, 1, 'デフォルト引数の `[]` は関数定義時に一度だけ生成される。`list` はミュータブルなので、その同じオブジェクトが後続の呼び出しでも再利用され、変更が蓄積してしまう。', 'https://docs.python.org/3/reference/datamodel.html', 'unpublished', false),
  (552, 'セクション231: Python オブジェクトモデル', 'イミュータブルなオブジェクト', '次のうち、イミュータブルなオブジェクトとして正しいのはどれか？', NULL, '["`list`", "`dict`", "`set`", "`tuple`"]'::jsonb, 3, '`tuple` は作成後に要素の差し替えができないためイミュータブルである。一方 `list`、`dict`、`set` は内容を変更できるミュータブルなオブジェクトである。', 'https://docs.python.org/3/reference/datamodel.html', 'unpublished', false),
  (553, 'セクション232: Python GC とミュータビリティ', 'tuple 内の list を append できる理由', '次のコードで `t[0].append(99)` が成功する理由として正しいのはどれか？', 't = ([1, 2, 3], "hello")
t[0].append(99)', '["`tuple` 自体がミュータブルだから", "`tuple` が保持する参照は固定だが、参照先の `list` はミュータブルだから", "`append()` は `tuple` に一切影響しない特別な命令だから", "Python のバグで本来は失敗すべきだから"]'::jsonb, 1, 'イミュータブルな `tuple` が保証するのは『要素として保持している参照そのものを差し替えられないこと』であり、参照先オブジェクトの中身まで不変にするわけではない。`t[0]` が指している `list` はミュータブルなので `append()` による変更は可能である。', 'https://docs.python.org/3/library/gc.html', 'unpublished', false),
  (554, 'セクション233: Python GC とミュータビリティ', 'x = 11 で起きること', '次の代入で内部的に起きることとして正しいのはどれか？', 'x = 10
x = 11', '["`10` のオブジェクトの値がその場で `11` に書き換えられる", "新しい `11` のオブジェクトが使われ、`x` がそちらを参照し直す", "変数 `x` 自体が削除されて新しい `x` が作り直される", "代入した瞬間に古い `10` のオブジェクトは必ず即時回収される"]'::jsonb, 1, '`int` はイミュータブルなので、既存の `10` オブジェクトの値を書き換えることはしない。代入は名前束縛の変更であり、`x` という名前が今度は `11` を参照するようになるだけである。', 'https://docs.python.org/3/library/gc.html', 'unpublished', false),
  (555, 'セクション234: Python GC とミュータビリティ', 'del a で即回収されない理由', '`del a` を実行してもオブジェクトがすぐ回収されない場合がある理由として正しいのはどれか？', NULL, '["`del` はオブジェクトそのものではなく、名前からその参照を外すだけだから", "`del` は CPython でしか動かない特殊構文だから", "`del` は非同期で遅延実行される命令だから", "`del` は GC に通知しないから"]'::jsonb, 0, '`del a` は名前 `a` の束縛を削除する操作であって、オブジェクトを強制破壊する命令ではない。他の変数やコンテナからまだ参照されていれば、そのオブジェクトは生き続ける。', 'https://docs.python.org/3/library/gc.html', 'unpublished', false),
  (556, 'セクション235: Python GC とミュータビリティ', '循環参照で参照カウントが 0 にならない理由', '2 つのオブジェクトが互いを参照しているとき、外部の変数名を削除しても参照カウントが 0 にならない理由はどれか？', NULL, '["`del` が正しく動作しないから", "オブジェクト同士の相互参照が残っているため、互いの参照カウントが下がり切らないから", "GC が自動で無効化されるから", "参照カウント方式には既知のバグがあるから"]'::jsonb, 1, '外側の変数名を消しても、オブジェクト A が B を参照し、B が A を参照していれば、その内部参照が残る。参照カウント方式だけでは『外部から到達不能だが互いに参照し合っている』状態を解決できない。', 'https://docs.python.org/3/library/gc.html', 'unpublished', false),
  (557, 'セクション236: Python GC とミュータビリティ', '一方的な参照の回収', '次のコードで `del a, b` の後に起きることとして正しいものはどれか？', 'a = []
b = []
a.append(b)  # a → b の一方的な参照
del a, b', '["両方とも永久に回収されない", "`a` だけ回収され、`b` は残り続ける", "`a` が消えることで `b` への最後の参照も失われ、結果として両方回収可能になる", "`b` が先に回収されるので `a` は壊れる"]'::jsonb, 2, '`a` だけが `b` を参照している一方向の構造では、外部の名前を消した後、`a` が回収されればその内部からの `b` 参照も消える。すると `b` も到達不能になり、芋づる式に回収可能になる。', 'https://docs.python.org/3/library/gc.html', 'unpublished', false),
  (558, 'セクション237: Python GC とミュータビリティ', '循環参照 GC の役割', 'CPython の循環参照 GC の役割として最も適切なものはどれか？', NULL, '["`del` 文を自動実行して不要な変数名を消すこと", "参照カウントだけでは回収できない、到達不能な循環参照グループを検出して回収可能にすること", "参照カウントが 1 のオブジェクトをすべて強制削除すること", "すべてのオブジェクトを一定時間ごとに OS へ返却すること"]'::jsonb, 1, 'CPython の基本は参照カウントだが、それだけでは循環参照を回収できない。補助的な GC が、外部から到達不能な循環参照グループを見つけて回収可能にすることで、この弱点を補っている。', 'https://docs.python.org/3/library/gc.html', 'unpublished', false),
  (559, 'セクション238: Python GC とミュータビリティ', '参照カウント方式だけの限界', '参照カウント方式だけでは回収できない典型例として最も適切なものはどれか？', NULL, '["整数オブジェクトが再代入された場合", "外部から参照されていないが、オブジェクト同士が互いを参照し合う循環参照", "関数のローカル変数がスコープを抜けた場合", "文字列オブジェクトがイミュータブルである場合"]'::jsonb, 1, '参照カウントは『参照数が 0 になったら回収する』方式なので、互いを参照し合ってカウントが残る循環参照は苦手である。このため CPython には補助的な循環参照 GC がある。', 'https://docs.python.org/3/library/gc.html', 'unpublished', false),
  (560, 'セクション239: Python GC とミュータビリティ', 'Guido の見解としての GC と with 文', 'Guido van Rossum の説明や Python の流儀に照らして、GC と `with` 文の役割分担として最も適切なものはどれか？', NULL, '["開発者は常に手動でメモリ管理すべきで、GC は信用してはいけない", "オブジェクトの寿命は通常 GC に任せてよいが、ファイルなどのリソース解放は `with` 文で明示的に管理するのが望ましい", "GC は将来廃止されるので、すべて `del` に置き換えるべきだ", "`with` 文はメモリ回収専用であり、ファイルやロックには関係ない"]'::jsonb, 1, 'Guido は、循環参照のための補助 GC があることを前提に、通常のオブジェクト寿命を過度に心配する必要はないという立場を取っている。一方でファイルやロックのような外部リソースは、GC 任せではなく `with` 文などで解放タイミングを明示するのが Python 的な実践である。', 'https://docs.python.org/3/library/gc.html', 'unpublished', false),
  (561, 'セクション240: Python GC 発展', '循環参照オブジェクトの回収保証', 'CPython のガベージコレクションにおいて、循環参照を含むオブジェクトはどのように扱われるか？', NULL, '["参照カウントが 0 になった時点で必ず即座に回収される", "必ず回収されることが常に保証されている", "回収時期は保証されず、`gc` による後続の検出と回収に依存する", "循環参照は自動的に解消されるため問題にならない"]'::jsonb, 2, '循環参照は参照カウントだけでは消えないため、補助的な `gc` が後から到達不能な循環を検出して回収する。したがって、単純な参照カウントのような『その場で即座に回収』は保証されない。', 'https://docs.python.org/3/library/gc.html', 'unpublished', false),
  (562, 'セクション241: Python GC 発展', 'except 節で寿命が延びる理由', '`try ... except` で例外を捕捉したとき、オブジェクトが予想より長く生き残ることがある理由として最も適切なものはどれか？', NULL, '["`except` 節がスタックフレームをロックするから", "例外オブジェクトが `__traceback__` を通じて、ローカル変数を含むフレームを参照し続けることがあるから", "CPython が `except` 節内では参照カウント更新を止めるから", "`gc` モジュールが `except` 節内の回収を禁止しているから"]'::jsonb, 1, '例外オブジェクトは traceback を保持し、その traceback はフレームを参照する。フレームはローカル変数への参照を持つため、例外情報が残っている間は本来短命だったオブジェクトも連鎖的に生存しやすくなる。', 'https://docs.python.org/3/library/gc.html', 'unpublished', false),
  (563, 'セクション242: Python GC 発展', '不変コンテナ内の可変要素の変更', '不変コンテナであるタプルが可変オブジェクトへの参照を含む場合、その参照先を変更すると何が起きるか？', 't = ([1, 2, 3], ''hello'')
t[0].append(99)', '["タプルも不変なので変更は反映されず、必ず例外になる", "タプルが表す値は変化しうるが、タプル自体の identity は変わらない", "タプルの identity が変わり、新しいタプルが自動生成される", "循環参照が発生し、`gc` モジュールが介入する"]'::jsonb, 1, '不変コンテナは『保持する参照の差し替えができない』ことを意味するが、参照先が可変ならその中身は変わりうる。したがってタプル自体は同一オブジェクトのままでも、意味上の内容は変化しうる。', 'https://docs.python.org/3/library/gc.html', 'unpublished', false),
  (564, 'セクション243: Python GC 発展', 'close() を GC 任せにしてはいけない理由', 'ファイルオブジェクトを明示的に `close()` せず使うことが問題になる最も根本的な理由はどれか？', NULL, '["CPython では参照カウントが即座にゼロになることが保証されないから", "ガベージコレクションの実行時期が保証されないため、リソース解放時期も保証されないから", "`with` 文を使わないと OS のファイルディスクリプタが即座に壊れるから", "PyPy と CPython で `close()` の実装が異なるから"]'::jsonb, 1, '本質は『ガベージコレクション任せでは、いつ後始末が走るか分からない』点にある。ファイルやソケットのような外部リソースは解放タイミングが重要なので、`close()` や `with` 文で明示的に管理すべきである。', 'https://docs.python.org/3/library/gc.html', 'unpublished', false),
  (565, 'セクション244: Python GC 発展', 'デバッガやトレースで寿命が延びる理由', 'デバッグ機能やトレース機能を使うと、本来は回収されるはずのオブジェクトが生き続けることがある理由として最も適切なものはどれか？', NULL, '["デバッガが `gc` モジュールを完全に無効化するから", "トレースやデバッガが内部でオブジェクトやフレームへの参照を保持し、参照カウントが下がり切らないことがあるから", "デバッグモードでは循環参照の検出が停止されるから", "CPython がデバッグ時だけ参照カウント更新を遅延させるから"]'::jsonb, 1, 'デバッガやトレース機構は、表示や検査のためにフレーム・例外・ローカル変数などへの参照を保持しがちである。その追加参照のせいで、通常なら寿命が尽きるオブジェクトが想定より長く残ることがある。', 'https://docs.python.org/3/library/gc.html', 'unpublished', false),
  (566, 'セクション245: Python オブジェクト基礎', '参照カウント方式で回収されるタイミング', 'CPython の参照カウント方式において、オブジェクトが回収されるタイミングとして正しいのはどれか？', NULL, '["GC が定期実行されたとき", "参照カウントが 0 になった瞬間", "プログラム終了時", "`gc` モジュールが明示的に呼ばれたときだけ"]'::jsonb, 1, 'CPython の基本は参照カウントであり、通常は参照カウントが 0 になった時点で解放処理が進む。循環参照だけはこの仕組みでは回収できず、補助 GC の対象になる。', 'https://docs.python.org/3/reference/datamodel.html', 'unpublished', false),
  (567, 'セクション246: Python オブジェクト基礎', 'None の真偽値', '`None` の真偽値として正しいのはどれか？', NULL, '["`True`", "`None` は真偽値を持たない", "`False`", "実装依存"]'::jsonb, 2, '`None` の truth value は false である。したがって `if None:` は偽として扱われる。', 'https://docs.python.org/3/reference/datamodel.html', 'unpublished', false),
  (568, 'セクション247: Python オブジェクト基礎', '1 is 1 の結果は仕様上どうか', '次のコードにおける `a is b` の結果について、仕様上もっとも安全な説明はどれか？', 'a = 1
b = 1', '["必ず `True`", "必ず `False`", "実装依存であり、どちらの可能性もある", "`SyntaxError` が発生する"]'::jsonb, 2, '小さな整数の共有は CPython でよく見られる最適化だが、`is` の結果として仕様上保証されるものではない。値の等しさを判定したいなら `==` を使うべきである。', 'https://docs.python.org/3/reference/datamodel.html', 'unpublished', false),
  (569, 'セクション248: Python オブジェクト基礎', '空リストを2回作ったときの is', '次のコードにおける `c is d` の結果はどうなるか？', 'c = []
d = []', '["実装依存", "必ず `True`", "必ず `False`", "`TypeError` が発生する"]'::jsonb, 2, '`[]` を2回評価すると、内容が同じでも別々のリストオブジェクトが新しく作られる。そのため `is` による同一性比較は `False` になる。', 'https://docs.python.org/3/reference/datamodel.html', 'unpublished', false),
  (570, 'セクション249: Python オブジェクト基礎', '未対応オペランドで返すべき値', '数値メソッドが対応していない型のオペランドを受け取った場合、返すべきものは何か？', NULL, '["`None`", "`False`", "`NotImplemented`", "ただちに `TypeError` を送出する"]'::jsonb, 2, '数値メソッドや rich comparison メソッドは、与えられたオペランドに対してその演算を実装していない場合 `NotImplemented` を返すべきである。するとインタープリタが反転演算や別のフォールバックを試せる。', 'https://docs.python.org/3/reference/datamodel.html', 'unpublished', false),
  (571, 'セクション250: Python オブジェクト基礎', 'Python 3.14 の NotImplemented の真偽値評価', 'Python 3.14 以降で `NotImplemented` を真偽値コンテキストで評価するとどうなるか？', NULL, '["`True` と評価される", "`False` と評価される", "`DeprecationWarning` が発生する", "`TypeError` が発生する"]'::jsonb, 3, '`NotImplemented` は真偽値コンテキストで評価すべきではない。Python 3.9 では非推奨化され、Python 3.14 以降は実際に `TypeError` を送出するよう変更された。', 'https://docs.python.org/3/reference/datamodel.html', 'unpublished', false),
  (572, 'セクション251: Python オブジェクト基礎', '連鎖代入したリストの同一性', '次のコードの後、`e is f` の結果として正しいのはどれか？', 'e = f = []', '["`False`（別々のリストが生成される）", "`True`（同じオブジェクトが両方の名前に束縛される）", "実装依存", "`TypeError` が発生する"]'::jsonb, 1, '連鎖代入では 1 つの右辺オブジェクトが作られ、それが複数の名前へ束縛される。したがって `e` と `f` は同じリストオブジェクトを参照し、`e is f` は `True` になる。', 'https://docs.python.org/3/reference/datamodel.html', 'unpublished', false),
  (573, 'セクション252: Python オブジェクトと数値', 'None の真偽値', '`None` の真偽値として正しいのはどれか？', NULL, '["`True`", "`False`", "実装依存", "真偽値を持たない"]'::jsonb, 1, '`None` の truth value は false である。したがって `if None:` は偽として扱われる。', 'https://docs.python.org/3/reference/datamodel.html', 'unpublished', false),
  (574, 'セクション253: Python オブジェクトと数値', 'Ellipsis の真偽値', '`Ellipsis`（`...`）の真偽値として正しいのはどれか？', NULL, '["`True`", "`False`", "実装依存", "真偽値を持たない"]'::jsonb, 0, '`Ellipsis` は組み込み定数の 1 つであり、truth value testing では真として扱われる。`None` や `False` のような特別な偽値ではない。', 'https://docs.python.org/3/reference/datamodel.html', 'unpublished', false),
  (575, 'セクション254: Python オブジェクトと数値', '数値オブジェクトの不変性', 'Python の数値オブジェクトの不変性について正しい説明はどれか？', NULL, '["一度生成された数値オブジェクトの値は変更できない", "変数への再代入によって元の数値オブジェクトの値を書き換えられる", "算術演算によって元のオブジェクトの値が更新される", "整数だけが不変で、浮動小数点数は可変である"]'::jsonb, 0, '数値型オブジェクトはイミュータブルであり、一度生成されたオブジェクトの値は変更できない。再代入や算術演算で起きるのは、名前束縛の変更や新しい値オブジェクトの利用である。', 'https://docs.python.org/3/reference/datamodel.html', 'unpublished', false),
  (576, 'セクション255: Python オブジェクトと数値', 'numbers.Number ではないもの', '次のうち、`numbers.Number` 系のオブジェクトが生成される場面として誤っているものはどれか？', NULL, '["`42` と書いた（数値リテラル）", "`3 + 4` を評価した（算術演算）", "`abs(-5)` を呼んだ（組み込み関数）", "`[1, 2, 3]` と書いた（リストリテラル）"]'::jsonb, 3, '数値リテラル、数値演算、数値向け組み込み関数は数値オブジェクトを扱う。一方 `[1, 2, 3]` は `list` オブジェクトを生成するので、`numbers.Number` 系ではない。', 'https://docs.python.org/3/reference/datamodel.html', 'unpublished', false),
  (577, 'セクション256: Python オブジェクトと数値', '数値の __repr__ の目的', '数値オブジェクトの `__repr__()` が目指す性質として最も適切なものはどれか？', NULL, '["先頭のゼロが付くことを優先する", "正の数にも必ず `+` を表示する", "可能なら同じ値を再現できる文字列表現を返す", "常に 2 進数文字列で返す"]'::jsonb, 2, '`repr(x)` は、可能であればその表現を評価したときに同じ値を再現できるような、曖昧さの少ない文字列表現を目指す。『同じオブジェクト』ではなく『同じ値』を再現するのがポイントである。', 'https://docs.python.org/3/reference/datamodel.html', 'unpublished', false),
  (578, 'セクション257: Python オブジェクトと数値', '__add__ が NotImplemented を返した後', '`a.__add__(b)` が `NotImplemented` を返した場合、次に何が試みられるか？', NULL, '["即座に `TypeError` が発生する", "`a.__radd__(b)` が試みられる", "`b.__radd__(a)` が試みられる", "`b.__add__(a)` が試みられる"]'::jsonb, 2, '通常の二項演算で左オペランド側の実装が `NotImplemented` を返すと、インタープリタは右オペランド側の反射演算メソッド、ここでは `b.__radd__(a)` を試す。', 'https://docs.python.org/3/reference/datamodel.html', 'unpublished', false),
  (579, 'セクション258: Python オブジェクトと数値', '空リスト同士の is 比較', '次のコードの `c is d` の結果はどうなるか？', 'c = []
d = []
c is d', '["`True`", "`False`", "実装依存", "`TypeError` が発生する"]'::jsonb, 1, '`[]` を 2 回評価すると、それぞれ別個のリストオブジェクトが生成される。そのため内容が同じでも同一オブジェクトではなく、`is` の結果は `False` になる。', 'https://docs.python.org/3/reference/datamodel.html', 'unpublished', false),
  (580, 'セクション259: ターミナル制御と termios', 'stty -a の有効フラグ表記', '`stty -a` の出力でフラグが有効であることを示す表記はどれか？', NULL, '["フラグ名の前に `+` が付く", "フラグ名の前に `-` が付く", "フラグ名だけが表示される（`-` なし）", "フラグ名の後に `=1` が付く"]'::jsonb, 2, '`stty -a` では、通常フラグが有効なら `echo` のようにそのまま表示され、無効なら `-echo` のように先頭に `-` が付く。', 'https://man7.org/linux/man-pages/man3/termios.3.html', 'unpublished', false),
  (581, 'セクション260: ターミナル制御と termios', 'stty -a の端末サイズ', '`stty -a` でターミナルの幅と高さを確認するフィールドはどれか？', NULL, '["`speed` と `baud`", "`rows` と `columns`", "`min` と `time`", "`intr` と `susp`"]'::jsonb, 1, '`stty -a` では端末サイズは `rows` と `columns` で表示される。`speed` は回線速度、`min` と `time` は非 canonical モードでの入力条件、`intr` と `susp` は制御文字設定である。', 'https://man7.org/linux/man-pages/man3/termios.3.html', 'unpublished', false),
  (582, 'セクション261: ターミナル制御と termios', 'ICANON と ECHO のクリア', '以下のコードは何をしているか？', 'newt.c_lflag &= ~(ICANON | ECHO);', '["`ICANON` と `ECHO` のビットを 1 にする", "`ICANON` と `ECHO` のビットを 0 にする", "`c_lflag` の全ビットを 0 にする", "`c_lflag` を `ICANON | ECHO` の値に置き換える"]'::jsonb, 1, '`ICANON | ECHO` で対象ビット群を作り、`~` でそれ以外を 1 にしたマスクを `&=` で適用している。結果として `c_lflag` のうち `ICANON` と `ECHO` に対応するビットだけがクリアされる。', 'https://man7.org/linux/man-pages/man3/termios.3.html', 'unpublished', false),
  (583, 'セクション262: C++ enum class', 'unsigned char 基底型の enum class の要素数上限', '`enum class` で基底型を `unsigned char` にした場合、定義できる要素数の上限はいくつか？', NULL, '["128", "255", "256", "512"]'::jsonb, 2, '`unsigned char` が表せる値は通常 0 から 255 までの 256 通りである。列挙子に重複しない値を割り当てる前提なら、取りうる値の個数の上限は 256 である。', 'https://en.cppreference.com/w/cpp/language/enum', 'unpublished', false),
  (584, 'セクション263: C++ enum class', 'scoped enum の暗黙変換', '以下のコードでエラーになるのはどれか？', 'enum class MonsterType : int { SLIME, GOBLIN, MONSTER_MAX };', '["`int x = static_cast<int>(MonsterType::MONSTER_MAX);`", "`int x = MonsterType::MONSTER_MAX;`", "`size_t x = static_cast<size_t>(MonsterType::MONSTER_MAX);`", "`unsigned char x = static_cast<unsigned char>(MonsterType::MONSTER_MAX);`"]'::jsonb, 1, '`enum class` は scoped enumeration であり、基底整数型への暗黙変換を行わない。そのため `MonsterType::MONSTER_MAX` を `int` に代入するには `static_cast` が必要である。', 'https://en.cppreference.com/w/cpp/language/enum', 'unpublished', false),
  (585, 'セクション264: C++ enum class', 'MONSTER_MAX を末尾に置く理由', '`MONSTER_MAX` を `enum class` の最後に定義する主な目的はどれか？', NULL, '["コンパイルエラーを防ぐため", "モンスターの種類数を自動的に管理するため", "配列のインデックスとして直接使用するため", "`static_cast` を不要にするため"]'::jsonb, 1, '末尾に番兵的な列挙子を置くと、有効な要素数を定数として一緒に管理しやすい。新しいモンスターを途中に追加しても、最後の `MONSTER_MAX` が総数の目安として追従する。', 'https://en.cppreference.com/w/cpp/language/enum', 'unpublished', false),
  (586, 'セクション265: ターミナル制御と termios', 'echoctl 有効時の Ctrl+C 表示', '`echoctl` フラグが有効な場合、`Ctrl+C` を入力するとターミナルにどう表示されるか？', NULL, '["何も表示されない", "`^C` と表示される", "`\\\\003` と表示される", "`SIGINT` と表示される"]'::jsonb, 1, '`echoctl` は制御文字をハット記法で表示する挙動を有効にするフラグである。そのため `Ctrl+C` は `^C` のように可視化される。', 'https://man7.org/linux/man-pages/man3/termios.3.html', 'unpublished', false),
  (587, 'セクション266: 型安全性と技術選定', '型安全性のメリットではないもの', '型安全性の主なメリットとして当てはまらないものはどれ？', NULL, '["コンパイル時にバグを発見できる", "コードの可読性が上がる", "実行速度が必ず2倍になる", "IDEの補完機能が強化される"]'::jsonb, 2, '型安全性はコンパイル時の検証、意図の明確化、IDE 補助の改善などに寄与する。一方、実行速度の向上は言語処理系や最適化、ワークロード次第であり、「必ず2倍になる」とは言えない。', 'https://developer.mozilla.org/en-US/docs/Web', 'unpublished', false),
  (588, 'セクション267: 型安全性と技術選定', '小規模開発で型安全性の恩恵が薄れる理由', '小規模開発で型安全性の恩恵が薄れる主な理由は？', NULL, '["型安全性の技術が未熟だから", "コードベース全体を把握できるので混乱しにくいから", "小規模ではバグが発生しないから", "コンパイラが対応していないから"]'::jsonb, 1, '小規模なコードベースでは、開発者が全体像や依存関係を頭に入れやすく、変更影響も手作業で追跡しやすい。このため、大規模開発ほど型安全性の恩恵が前面に出にくい。', 'https://developer.mozilla.org/en-US/docs/Web', 'unpublished', false),
  (589, 'セクション268: 型安全性と技術選定', '変更の影響範囲を自動検出するとは', '「変更の影響範囲を自動検出」とはどういう意味？', NULL, '["実行ログから影響を後から分析する", "型チェッカーがコンパイル時に型の不一致箇所を全て列挙してくれる", "バグ発生後にテストが失敗することで検出する", "IDEがコードをリアルタイムで実行して確認する"]'::jsonb, 1, '型を変更したとき、静的型チェッカーはその型に依存している箇所を実行前に洗い出せる。これは実行後の観測やテスト失敗に頼るのではなく、コンパイル時に網羅的な不整合を報告するという意味での『自動検出』である。', 'https://developer.mozilla.org/en-US/docs/Web', 'unpublished', false),
  (590, 'セクション269: ストレージ技術選定', 'SharedPreferences・DataStore・Hive の選定分類', 'SharedPreferences・DataStore・Hive の技術選定は何の選定に分類される？', NULL, '["型の技術選定", "フレームワークの技術選定", "ストレージ技術の選定", "通信プロトコルの選定"]'::jsonb, 2, 'これらはアプリ内でデータを保存・読み出しするための技術であり、永続化層やローカルストレージの選定に属する。型システムや通信プロトコルの話ではない。', 'https://developer.mozilla.org/en-US/docs/Web', 'unpublished', false),
  (591, 'セクション270: ストレージ技術選定', 'SharedPreferences・DataStore・Hive の共通点', 'SharedPreferences・DataStore・Hive の共通点として最も適切なのはどれ？', NULL, '["データの永続化に使う技術である", "すべてOS標準APIである", "すべてフレームワークである", "すべて通信プロトコルである"]'::jsonb, 0, 'SharedPreferences は Android 標準 API 寄り、DataStore は Jetpack ライブラリ、Hive は Dart のライブラリであり分類は同一ではない。ただし、いずれもアプリ内データの永続化に使う技術という点が共通している。', 'https://developer.mozilla.org/en-US/docs/Web', 'unpublished', false),
  (592, 'セクション271: フレームワークとライブラリ', 'フレームワークとライブラリの違い', 'フレームワークとライブラリの違いとして正しいのはどれ？', NULL, '["フレームワークは小さく、ライブラリは大きい", "フレームワークがアプリ全体の骨格を提供し、開発者がその上に乗る", "ライブラリはOSSで、フレームワークは有料", "違いはほぼない"]'::jsonb, 1, 'フレームワークは制御フローやアプリの骨格を提供し、開発者はその枠組みに沿ってコードを書く。ライブラリは必要なときに開発者側から呼び出す部品であり、ここに制御の逆転という違いがある。', 'https://developer.mozilla.org/en-US/docs/Web', 'unpublished', false),
  (593, 'セクション272: C++ enum class と剰余演算', 'ラップアラウンド計算の目的', '以下のコードの主な目的は何ですか？', '(static_cast<int>(cmd) + N) % N', '["`cmd` を `N` 以下にクランプする", "`cmd` の値をランダムに変換する", "`cmd` を `0` 〜 `N-1` の範囲で循環（ラップアラウンド）させる", "`cmd` を常に `0` に戻す"]'::jsonb, 2, 'この式は値を `0` から `N-1` の範囲で循環させるための典型的な形である。インデックスや列挙値を『最後の次は最初に戻す』ような挙動にしたいときに使う。', 'https://en.cppreference.com/w/cpp/language/operator_arithmetic', 'unpublished', false),
  (594, 'セクション273: C++ enum class と剰余演算', '(x + N) % N が不十分な条件', '`(x + N) % N` が正しく動作しない条件はどれですか？', NULL, '["`x` が正の値のとき", "`x` が `0` のとき", "`x < -N` のとき", "`N` が奇数のとき"]'::jsonb, 2, 'C++ の剰余演算では余りの符号は左オペランド側に従う。したがって `x` が `-N` よりさらに小さいと、`x + N` もまだ負であり、1回だけ `+N` しても `0` から `N-1` の範囲に入らないことがある。', 'https://en.cppreference.com/w/cpp/language/operator_arithmetic', 'unpublished', false),
  (595, 'セクション274: C++ enum class と剰余演算', 'enum class で static_cast が必要な理由', '`enum class` を導入したことで `static_cast` が必要になった理由は？', NULL, '["`enum class` はメモリ使用量を増やすから", "`enum class` は `int` への暗黙の型変換を禁止しているから", "`enum class` はコンパイル速度を落とすから", "`enum class` はグローバルスコープを汚染するから"]'::jsonb, 1, '`enum class` は scoped enumeration であり、従来の `enum` と違って整数型への暗黙変換を行わない。整数演算に使うには明示的な `static_cast` が必要になる。', 'https://en.cppreference.com/w/cpp/language/operator_arithmetic', 'unpublished', false),
  (596, 'セクション275: C++ enum class と剰余演算', 'Core Guidelines Enum.7 の推奨', 'C++ Core Guidelines の `Enum.7` が推奨していることは？', NULL, '["常に underlying type を明示的に指定する", "必要な場合のみ underlying type を指定する", "`enum class` より plain `enum` を優先する", "underlying type は必ず `size_t` にする"]'::jsonb, 1, 'C++ Core Guidelines の `Enum.7` は、underlying type は本当に必要な場合だけ指定すべきだという立場である。可読性や保守性の観点から、不要な明示指定は避けるのが基本になる。', 'https://en.cppreference.com/w/cpp/language/operator_arithmetic', 'unpublished', false),
  (597, 'セクション276: C++ enum class と剰余演算', 'std::to_underlying の導入時期', '`std::to_underlying` が導入された C++ バージョンはどれですか？', NULL, '["C++17", "C++20", "C++23", "C++26"]'::jsonb, 2, '`std::to_underlying` は scoped enum を基底整数型へ安全に変換するためのユーティリティで、標準ライブラリに C++23 で追加された。', 'https://en.cppreference.com/w/cpp/language/operator_arithmetic', 'unpublished', false),
  (598, 'セクション277: C++ enum class と剰余演算', 'GCC 12 で std::to_underlying が使えない理由', 'GCC 12 で `std::to_underlying` が使えない理由は？', NULL, '["GCC 12 は C++ に対応していないから", "GCC 12 の C++23 サポートは部分的・実験的で `std::to_underlying` は未実装だから", "`-std=c++23` オプションが存在しないから", "`std::to_underlying` は Linux では使えないから"]'::jsonb, 1, 'コンパイラが `-std=c++23` を受け付けても、標準ライブラリ機能がすべて実装済みとは限らない。GCC 12 系では C++23 サポートが部分的で、`std::to_underlying` が未提供の構成がありうる。', 'https://en.cppreference.com/w/cpp/language/operator_arithmetic', 'unpublished', false),
  (599, 'セクション278: シェルとビルド実行', '&& の意味', '`g++-12 -std=c++23 -o RPG RPG.cpp && ./RPG` の `&&` の意味は？', NULL, '["常に両方のコマンドを実行する", "左のコマンドが失敗した場合のみ右を実行する", "左のコマンドが成功した場合のみ右を実行する", "バックグラウンドで並列実行する"]'::jsonb, 2, 'シェルの `&&` は論理 AND の短絡評価に似た挙動をし、左側の終了ステータスが成功のときだけ右側を実行する。コンパイル成功時のみ実行したい場合の定番の書き方である。', 'https://www.gnu.org/software/bash/manual/bash.html', 'unpublished', false),
  (600, 'セクション279: GCC と Ubuntu', 'Ubuntu 22.04 の GCC 12 の既定規格', 'Ubuntu 22.04 の GCC 12 のデフォルト C++ 規格はどれですか？', NULL, '["C++14", "C++17", "C++20", "C++23"]'::jsonb, 1, 'GCC 12 系の `g++` は、明示的な `-std=` 指定がない場合、通常は `gnu++17` を既定として扱う。設問の選択肢では GNU 拡張込みの `gnu++17` を便宜上 `C++17` としている。', 'https://docs.python.org/3/library/gc.html', 'unpublished', false),
  (601, 'セクション280: Ubuntu パッケージ管理', 'PPA とは何か', 'PPA とは何ですか？', NULL, '["Ubuntu の公式パッケージリポジトリ", "GCC のビルドシステム", "Ubuntu 向けの非公式パッケージリポジトリ", "C++ の標準化団体"]'::jsonb, 2, 'PPA は Personal Package Archive の略で、主に Launchpad を通じて配布される Ubuntu 向けの追加パッケージリポジトリを指す。公式リポジトリではない追加配布元として使われる。', 'https://manpages.ubuntu.com/manpages/jammy/man8/apt.8.html', 'unpublished', false),
  (602, 'セクション281: C++ enum class と剰余演算', 'underlying type に size_t が不向きな理由', '今回のコードで underlying type に `size_t` が適さない理由は？', NULL, '["`size_t` は `enum class` で使えないから", "`size_t` は符号なし整数のため `-1` を格納できず、負値補正ロジックが破綻するから", "`size_t` は C++23 以降でしか使えないから", "`size_t` は Windows でしか使えないから"]'::jsonb, 1, '`size_t` は符号なし整数型なので、負の方向へ一時的にずらすようなロジックと相性が悪い。今回のように `-1` 相当の値や負値補正を扱う場面では、符号付き整数ベースのほうが意味を保ちやすい。', 'https://en.cppreference.com/w/cpp/language/operator_arithmetic', 'unpublished', false),
  (603, 'セクション282: enum class と配列インデックス設計', 'enum class を配列インデックスに使う目的', '`enum class` を配列インデックスに使う主な目的はどれ？', NULL, '["処理速度の向上", "マジックナンバーの防止", "メモリ使用量の削減", "コンパイル時間の短縮"]'::jsonb, 1, '配列の添字を生の数値ではなく意味を持つ列挙子で表現すると、`0` や `1` が何を指すのかをコメントなしで読めるようになる。主目的は性能ではなく、意図の明確化と保守性の向上である。', 'https://en.cppreference.com/w/cpp/language/operator_arithmetic', 'unpublished', false),
  (604, 'セクション283: enum class と配列インデックス設計', 'マジックナンバーはどれか', '以下のうちマジックナンバーはどれ？', NULL, '["`character[static_cast<int>(CharacterType::PLAYER)].hp`", "`monsters[static_cast<int>(MonsterType::MONSTER_SLIME)]`", "`character[0].hp`", "`CharacterType::PLAYER`"]'::jsonb, 2, '`character[0].hp` の `0` は、それだけでは何を意味する添字か読み手に伝わらない。意味を持つ名前に置き換えられていない裸の定数値は、典型的なマジックナンバーである。', 'https://en.cppreference.com/w/cpp/language/operator_arithmetic', 'unpublished', false),
  (605, 'セクション284: enum class と配列インデックス設計', '_MAX を末尾に置く目的', '`_MAX` を `enum` の末尾に定義する目的はどれ？', NULL, '["最大値を表す定数として演算に使う", "配列サイズとして使い、配列と `enum` を1対1で対応させる", "`enum` の範囲チェックに使う", "デバッグ時の表示用"]'::jsonb, 1, '末尾の `_MAX` は『有効要素数』を表す番兵として使うと便利で、配列サイズやループ終端と自然に対応づけられる。これにより、列挙子の追加と配列側の管理を同期しやすくなる。', 'https://en.cppreference.com/w/cpp/language/operator_arithmetic', 'unpublished', false),
  (606, 'セクション285: enum class と配列インデックス設計', '配列インデックス enum class と size_t', '配列インデックス用の `enum class` に `size_t` を underlying type にすることについて、適切な説明はどれ？', NULL, '["必ずそうすべきで、`int` は誤り", "意味的には自然だが、設計判断の問題であり `int` でも問題ない", "`size_t` は `enum class` で使えないため不可", "Core Guidelines が `size_t` を明示的に推奨している"]'::jsonb, 1, '添字という意味だけを見れば `size_t` は自然だが、列挙値をどの演算に使うかまで含めると設計判断になる。今回のように周回計算や負値補正との関係があるなら `int` ベースでも十分合理的である。', 'https://en.cppreference.com/w/cpp/language/operator_arithmetic', 'unpublished', false),
  (607, 'セクション286: enum class と配列インデックス設計', 'enum class 導入のトレードオフ', '今回の設計で `enum class` を導入したトレードオフはどれ？', NULL, '["型安全性が失われる", "配列との対応が曖昧になる", "`static_cast` が毎回必要になる冗長さ", "コンパイラが `enum` を認識できなくなる"]'::jsonb, 2, '`enum class` によって名前空間汚染や暗黙変換を防げる一方、整数として使いたい場面では明示的な `static_cast` が必要になる。これは安全性と記述量のトレードオフである。', 'https://en.cppreference.com/w/cpp/language/operator_arithmetic', 'unpublished', false),
  (608, 'セクション287: enum class と配列インデックス設計', 'command の underlying type に size_t が向かない理由', '`command` の `enum` の underlying type を `size_t` にできない理由はどれ？', NULL, '["`size_t` は C++23 以降でしか使えないから", "`size_t` は符号なしのため負値補正ロジックが破綻するから", "`size_t` は `enum class` で使えないから", "Core Guidelines が禁止しているから"]'::jsonb, 1, '`size_t` は符号なし整数なので、`-1` のような一時的な負方向の値を前提とするロジックと噛み合わない。今回のように前後移動や剰余での補正を行う設計では、符号付き型のほうが自然である。', 'https://en.cppreference.com/w/cpp/language/operator_arithmetic', 'unpublished', false),
  (609, 'セクション288: enum class と配列インデックス設計', 'scoped enum class の既定 underlying type', '`enum class` で underlying type を明示しない場合の既定はどれ？', NULL, '["`size_t`", "`unsigned int`", "`int`", "`long long`"]'::jsonb, 2, 'scoped enumeration である `enum class` は、基底型を省略した場合は既定で `int` を underlying type とする。これは『常に `int` を明示指定すべき』という意味ではなく、言語仕様上の既定値である。', 'https://en.cppreference.com/w/cpp/language/operator_arithmetic', 'unpublished', false),
  (610, 'セクション289: enum class と配列インデックス設計', 'character[0].hp の問題点', '`character[0].hp` の問題点はどれ？', NULL, '["配列の範囲外アクセスが起きる", "`0` が何を指すか不明でコードの意図が読み取りにくい", "コンパイルエラーになる", "`hp` の値が正しく取得できない"]'::jsonb, 1, '`0` という添字自体は合法でも、それがプレイヤーなのか先頭モンスターなのか、読み手には文脈なしで分からない。名前付きの列挙子を使うと、コードの意図を値ではなく意味で表現できる。', 'https://en.cppreference.com/w/cpp/language/operator_arithmetic', 'unpublished', false),
  (611, 'セクション290: C++ 乱数生成', 'std::random_device{} の {} の役割', '`std::random_device{}()` の `{}` の役割は？', NULL, '["乱数の範囲を指定する", "`std::random_device` のインスタンスを生成する", "シードの初期値を `0` に設定する", "ハードウェア乱数を無効化する"]'::jsonb, 1, '`std::random_device{}` は一時オブジェクトを直接初期化して生成している。つまり `{}` の部分は乱数を取る前段として `std::random_device` のインスタンスをその場で作る役割を持つ。', 'https://en.cppreference.com/w/cpp/numeric/random', 'unpublished', false),
  (612, 'セクション291: C++ 乱数生成', 'std::random_device{}() の末尾の ()', '`std::random_device{}()` の末尾の `()` の役割は？', NULL, '["デストラクタを呼び出す", "インスタンスを初期化する", "乱数値を1つ取得する", "シードをリセットする"]'::jsonb, 2, '`std::random_device` は関数呼び出し演算子 `operator()` を持つ乱数生成器である。末尾の `()` はその一時オブジェクトから乱数値を 1 回取得している。', 'https://en.cppreference.com/w/cpp/numeric/random', 'unpublished', false),
  (613, 'セクション292: C++ 乱数生成', 'rng.seed() の目的', '`rng.seed()` の目的は？', NULL, '["乱数生成器を破棄する", "乱数生成器の初期状態を設定する", "乱数の最大値を設定する", "乱数生成器の速度を最適化する"]'::jsonb, 1, '`seed()` は擬似乱数生成器の内部状態を初期化または再初期化するための関数である。ここで与えた値によって、その後に出力される乱数列が決まる。', 'https://en.cppreference.com/w/cpp/numeric/random', 'unpublished', false),
  (614, 'セクション293: C++ 乱数生成', 'シード固定時の挙動', 'シードを固定した場合の挙動は？', NULL, '["毎回異なる乱数列が生成される", "乱数が生成されなくなる", "毎回同じ乱数列が生成される", "実行環境によって変わる"]'::jsonb, 2, '同じ擬似乱数生成器に同じシードを与えると、通常は同じ内部状態から開始するため、毎回同じ乱数列が再現される。これはテストやデバッグで有用である。', 'https://en.cppreference.com/w/cpp/numeric/random', 'unpublished', false),
  (615, 'セクション294: C++ 乱数生成', 'std::random_device の乱数源', '`std::random_device` の乱数源は？', NULL, '["現在時刻", "プロセス ID", "ハードウェアの乱数源（OS の乱数生成機能など）", "固定値"]'::jsonb, 2, '`std::random_device` は非決定的乱数源を提供するためのインターフェースで、実装は OS の乱数 API やハードウェア由来のエントロピー源を利用しうる。単なる時刻や固定値を前提とするものではない。', 'https://en.cppreference.com/w/cpp/numeric/random', 'unpublished', false),
  (616, 'セクション295: C++ 乱数生成', 'std::random_device の注意点', '`std::random_device` の注意点は？', NULL, '["C++23 以降でしか使えない", "環境によっては擬似乱数にフォールバックする実装がある", "Windows でしか動作しない", "シードに使うことができない"]'::jsonb, 1, '標準は `std::random_device` を非決定的乱数源のインターフェースとして定義しているが、実装によっては真の非決定的ソースを持たず、擬似乱数生成器で代替する場合がある。そのため『常に高品質なハードウェア乱数』とは限らない。', 'https://en.cppreference.com/w/cpp/numeric/random', 'unpublished', false),
  (617, 'セクション296: C++ 乱数生成', 'std::mt19937 とは何か', '`std::mt19937` とは何ですか？', NULL, '["ハードウェア乱数生成器", "擬似乱数生成器", "暗号学的乱数生成器", "固定値生成器"]'::jsonb, 1, '`std::mt19937` は Mersenne Twister アルゴリズムに基づく擬似乱数生成器である。再現性が高く高速だが、暗号用途を前提とした乱数源ではない。', 'https://en.cppreference.com/w/cpp/numeric/random', 'unpublished', false),
  (618, 'セクション297: C++ 乱数生成', 'std::random_device で seed する目的', '`rng.seed(std::random_device{}())` を使う目的は？', NULL, '["実行するたびに異なる乱数列を生成するため", "乱数の範囲を制限するため", "乱数生成を高速化するため", "乱数の再現性を保証するため"]'::jsonb, 0, '`std::random_device` から得た値で擬似乱数生成器を seed すると、実行ごとに異なる初期状態になりやすい。その結果、毎回同じ列ではなく変化する乱数列を得やすくなる。', 'https://en.cppreference.com/w/cpp/numeric/random', 'unpublished', false),
  (619, 'セクション298: C/C++ 標準入出力とターミナル制御', '#include <iostream> の標準エラー出力', '`#include <iostream>` に含まれる標準エラー出力はどれですか？', NULL, '["`std::err`", "`std::cerr`", "`std::error`", "`std::stderr`"]'::jsonb, 1, 'C++ の標準エラー出力ストリームは `std::cerr` である。`std::cout` が標準出力、`std::cin` が標準入力、`std::clog` はログ向けのエラーストリームとして使われる。', 'https://en.cppreference.com/w/cpp/io', 'unpublished', false),
  (620, 'セクション299: C/C++ 標準入出力とターミナル制御', 'std::endl と \n の違い', '`std::endl` と `"\n"` の違いは？', NULL, '["`std::endl` は改行のみ、`\"\\n\"` は改行＋フラッシュ", "`std::endl` は改行＋バッファフラッシュ、`\"\\n\"` は改行のみ", "機能は全く同じ", "`\"\\n\"` は C++ では使えない"]'::jsonb, 1, '`std::endl` は改行文字を出力したうえでストリームを flush するマニピュレータである。一方 `"\n"` は単に改行文字を出力するだけで、通常は明示的な flush を伴わない。', 'https://en.cppreference.com/w/cpp/io', 'unpublished', false),
  (621, 'セクション300: C/C++ 標準入出力とターミナル制御', '<stdlib.h> の C++ での推奨代替', '`<stdlib.h>` の C++ での推奨代替ヘッダは？', NULL, '["`<cstdio>`", "`<cstring>`", "`<cstdlib>`", "`<utility>`"]'::jsonb, 2, 'C++ では C 由来の標準ライブラリヘッダに対応して `<cstdlib>`、`<cstdio>` などの名前が用意されている。`<stdlib.h>` に対応するのは `<cstdlib>` である。', 'https://en.cppreference.com/w/cpp/io', 'unpublished', false),
  (622, 'セクション301: C/C++ 標準入出力とターミナル制御', 'rand() % 3 の偏り', '`rand() % 3` で偏りが生じる理由は？', NULL, '["`rand()` が負の値を返すから", "`RAND_MAX` が `3` の倍数とは限らないから", "`%` 演算子が C++ で非推奨だから", "`rand()` は常に同じ値を返すから"]'::jsonb, 1, '`rand()` が返す値の個数は `RAND_MAX + 1` 通りだが、それが `3` で割り切れるとは限らない。このとき `% 3` を取ると、一部の余りが他より1回多く出現し、分布に偏りが生じうる。', 'https://en.cppreference.com/w/cpp/io', 'unpublished', false),
  (623, 'セクション302: C/C++ 標準入出力とターミナル制御', 'std::mt19937 の正体', '`std::mt19937` とは何ですか？', NULL, '["ハードウェア乱数生成器", "正規分布クラス", "メルセンヌツイスタ法による擬似乱数生成器", "乱数のシード値"]'::jsonb, 2, '`std::mt19937` は Mersenne Twister アルゴリズムを実装した擬似乱数生成器である。分布クラスではなく、乱数列を作るエンジン本体にあたる。', 'https://en.cppreference.com/w/cpp/io', 'unpublished', false),
  (624, 'セクション303: C/C++ 標準入出力とターミナル制御', 'std::to_underlying の導入時期', '`<utility>` の `std::to_underlying` が導入された C++ バージョンは？', NULL, '["C++11", "C++17", "C++20", "C++23"]'::jsonb, 3, '`std::to_underlying` は列挙型を underlying type に安全に変換するためのユーティリティで、標準ライブラリに C++23 で追加された。', 'https://en.cppreference.com/w/cpp/io', 'unpublished', false),
  (625, 'セクション304: C/C++ 標準入出力とターミナル制御', '一般的な家庭回線でグローバル IP を変更できない理由', '一般的な家庭回線でグローバル IP アドレスをコマンドで変更できない理由は？', NULL, '["Linux がグローバル IP の変更をサポートしていないから", "グローバル IP は ISP が管理しており、ユーザーが直接指定できないから", "`sudo` 権限があれば変更できる", "ルーターを再起動すれば必ず変更できる"]'::jsonb, 1, '一般的な家庭向けインターネット接続では、公開側の IP アドレスは ISP が割り当てる。ローカル PC やルーター上でコマンドを打っても、ISP 管理下の公開アドレスを好きな値に直接変更できるわけではない。', 'https://en.cppreference.com/w/cpp/io', 'unpublished', false),
  (626, 'セクション305: C/C++ 標準入出力とターミナル制御', 'getchar() の戻り値が int の理由', '`getchar()` の戻り値が `int` である理由は？', NULL, '["`char` より処理が速いから", "`EOF(-1)` を表現するために `char` の範囲を超える値が必要だから", "C++ では `char` の使用が非推奨だから", "矢印キーを検出するため"]'::jsonb, 1, '`getchar()` は通常の文字値に加えて `EOF` も返す必要がある。すべての `unsigned char` 値と特別値 `EOF` を区別できるよう、戻り値型は `int` になっている。', 'https://en.cppreference.com/w/cpp/io', 'unpublished', false),
  (627, 'セクション306: C/C++ 標準入出力とターミナル制御', 'KEY_UP = 1000 を選ぶ理由', '`KEY_UP = 1000` に `1000` が選ばれた理由として正しいものはどれですか？', NULL, '["ASCII の規格で `1000` が矢印キーに予約されているから", "`256` 以上であれば文字コードと衝突せず、キリが良く拡張しやすいから", "`int` 型の最小値が `1000` だから", "Linux のターミナル仕様で決まっているから"]'::jsonb, 1, '通常の文字入力は 0 から 255 付近の値に収まるため、それより十分大きい値を独自キーコードに割り当てると衝突を避けやすい。`1000` は仕様で決まっている値ではなく、実装上わかりやすい番地として選ばれている。', 'https://en.cppreference.com/w/cpp/io', 'unpublished', false),
  (628, 'セクション307: C/C++ 標準入出力とターミナル制御', 'getch_portable() で整数値に統一する利点', '`getch_portable()` で矢印キーを整数値に置き換える利点は？', NULL, '["処理速度が上がるから", "通常文字・矢印キー・EOF をすべて `int` の整数値として統一的に判別できるから", "`char` 型では矢印キーを格納できないから", "`switch` 文が `char` に対応していないから"]'::jsonb, 1, '通常文字・特殊キー・`EOF` をすべて `int` で統一すると、分岐処理を 1 つの型で扱えるようになる。文字コードと衝突しない範囲に独自キー値を置けば、キー種別の判定も整理しやすい。', 'https://en.cppreference.com/w/cpp/io', 'unpublished', false),
  (629, 'セクション: C++ 基礎', 'グローバル変数とローカル変数の初期化', '以下のコードで、不定値（ゴミ値）が入る可能性があるのはどれですか？', 'int globalArr[4];        // (A)

void func() {
    int localArr[4];     // (B)
    int zeroArr[4] = {}; // (C)
}', '["(A) のみ", "(B) のみ", "(A) と (B) の両方", "すべてゼロ初期化される"]'::jsonb, 1, 'C++ ではグローバル変数はプログラム起動時に自動的にゼロ初期化されます。(A) はグローバルなのですべて 0 です。(B) はローカル変数で初期化子がないため不定値（ゴミ値）が入ります。(C) は `= {}` によりゼロ初期化されます。', 'https://en.cppreference.com/w/cpp/language', 'unpublished', false),
  (630, 'セクション: C++ 基礎', '#define と constexpr の違い', '以下の2つの定数定義の違いとして、正しい説明はどれですか？', '#define BOARD_SIZE 8
constexpr int BOARD_SIZE = 8;', '["#define はコンパイル時に型チェックされる", "constexpr は実行時に値が決まる", "#define はプリプロセッサによる文字置換でスコープも型もない", "どちらも全く同じで使い分ける意味はない"]'::jsonb, 2, '`#define` はコンパイル前にプリプロセッサが単純な文字置換を行うため、スコープも型も持ちません。一方 `constexpr int` はコンパイル時定数として型安全に扱われ、スコープルールも適用されます。C++ では `constexpr` の使用が推奨されます。', 'https://en.cppreference.com/w/cpp/language', 'unpublished', false),
  (631, 'セクション: C++ 基礎', 'リスト初期化と narrowing conversion', '以下のコードで、コンパイルエラーになるのはどれですか？', 'double d = 3.14;
int a = d;  // (A)
int b{d};   // (B)', '["(A) のみエラー", "(B) のみエラー", "(A) と (B) の両方エラー", "どちらもエラーにならない"]'::jsonb, 1, '`= d` によるコピー初期化は暗黙の narrowing conversion（精度落ち変換）を許容し、3 になります。`{d}` によるリスト初期化は narrowing conversion をコンパイルエラーとして検出します。これはリスト初期化の利点の一つで、意図しない精度落ちをコンパイル時に防げます。', 'https://en.cppreference.com/w/cpp/language', 'unpublished', false),
  (632, 'セクション: C++ 基礎', '= delete によるコピー禁止', '以下のコードをコンパイルしたとき、何が起きますか？', 'class Socket {
public:
    Socket() = default;
    Socket(const Socket&) = delete;
};

Socket s1;
Socket s2(s1);', '["正常にコンパイルされ s1 のコピーが s2 に作られる", "コンパイルエラーになる", "実行時エラーになる", "s2 はデフォルトコンストラクタで初期化される"]'::jsonb, 1, '`= delete` はその関数の呼び出しをコンパイルエラーにします。`Socket(const Socket&) = delete` によりコピーコンストラクタが禁止されているため、`Socket s2(s1)` はコンパイルエラーになります。ソケットや排他リソースのように「コピーしたら困るもの」に対してよく使われます。', 'https://en.cppreference.com/w/cpp/language', 'unpublished', false),
  (633, 'セクション: C++ 基礎', 'コピーコンストラクタの引数 const T&', 'コピーコンストラクタの引数が `const Robot&` である理由として、最も正しい説明はどれですか？', 'class Robot {
public:
    Robot(const Robot& other) {
        // other を元に新しい Robot を作る
    }
};', '["`&` はポインタを意味し、`const` はアドレスを固定する", "`&` でコピー元を参照（コピーなし）で受け取り、`const` でコピー元を変更しないことを保証する", "`const` がないとコンパイルエラーになるため慣例で付ける", "`&` はコピー元を削除するための記号である"]'::jsonb, 1, '`&`（参照）を使うことでコピー元オブジェクトをコピーせず直接参照します。もし `&` がなければコピーのためにコピーコンストラクタを呼ぶ無限再帰が発生します。`const` はコピー元を誤って変更しないことをコンパイラが保証するためのものです。', 'https://en.cppreference.com/w/cpp/language', 'unpublished', false),
  (634, 'セクション: C++ 基礎', '#define による定数定義の問題点', '`#define KEY_UP 1000` の問題点として正しいものはどれですか？', '#define KEY_UP 1000', '["コンパイル時に値が確定しないため、定数畳み込みが行われない", "型がなく・スコープもないため、意図しない置換やデバッグの困難が生じる", "整数値しか定義できないため、文字列定数には使えない", "C++では #define 自体がコンパイルエラーになる"]'::jsonb, 1, '`#define` はプリプロセッサによる単純なテキスト置換であり、型情報もスコープも持ちません。そのためデバッガで名前が見えず、意図しない場所で置換が起きるリスクがあります。C++ では `constexpr` または `enum class` を使うのが推奨です。', 'https://en.cppreference.com/w/cpp/language', 'unpublished', false),
  (635, 'セクション: C++ 基礎', 'const int と constexpr int の違い', '`const int` と `constexpr int` の違いとして最も正しい説明はどれですか？', 'const int A = 10;
constexpr int B = 10;', '["`const int` はコンパイル時定数であることを保証するが、`constexpr int` は実行時定数である", "`const int` と `constexpr int` は完全に等価で違いはない", "`const int` はコンパイル時定数であることを保証しない（コンパイラ依存）が、`constexpr int` はコンパイル時定数であることを明示的に保証する", "`constexpr int` は関数内では使用できない"]'::jsonb, 2, '`const int` は値の変更を禁止しますが、コンパイル時に確定するかどうかはコンパイラ依存です。`constexpr int` はコンパイル時定数であることをコンパイラに保証させるため、定数畳み込みが確実に行われます。定数を定義する際は `constexpr` を使うのが推奨です。', 'https://en.cppreference.com/w/cpp/language', 'unpublished', false),
  (636, 'セクション: C++ 基礎', 'enum class による関連定数のグループ化', '複数の関連定数をまとめる際に `constexpr` より `enum class` が好ましい理由として最も正しいのはどれですか？', 'enum class Key {
    UP   = 1000,
    DOWN = 1001,
};', '["enum class はコンパイル時定数になるが、constexpr はならないため", "型安全かつスコープが隔離されるため、無関係な値を誤って渡すことをコンパイル時に防げる", "enum class は int への暗黙変換が可能で扱いやすいため", "enum class を使うと定数畳み込みが行われないため実行時コストがゼロになる"]'::jsonb, 1, '`enum class` はスコープが隔離されており `Key::UP` のようにアクセスします。また `int` への暗黙変換が禁止されているため、型違いの値を誤って渡すとコンパイルエラーになります。複数の関連する定数を型安全にグループ化したい場合に適しています。', 'https://en.cppreference.com/w/cpp/language', 'unpublished', false),
  (637, 'セクション: C++ 基礎', 'enum class の値を int として取り出す方法', '`enum class Key { UP = 1000 };` の値を `int` として取り出す正しい方法はどれですか？', 'enum class Key {
    UP = 1000,
};', '["`int x = Key::UP;`（暗黙変換）", "`int x = static_cast<int>(Key::UP);`", "`int x = Key::UP.value();`", "`int x = (int)Key::UP;`（Cスタイルキャスト）が唯一の方法"]'::jsonb, 1, '`enum class` は `int` への暗黙変換が禁止されています。`static_cast<int>` を使うか、C++23 以降では `std::to_underlying(Key::UP)` が使えます。Cスタイルキャストでも動作しますが、C++ では `static_cast` が推奨されます。', 'https://en.cppreference.com/w/cpp/language', 'unpublished', false),
  (638, 'セクション: C++ 基礎', 'enum class のデフォルト基底型', '`enum class` のデフォルト基底型はどれですか？', 'enum class Color {
    RED,
    GREEN,
    BLUE,
};', '["`unsigned int`", "`short`", "`int`", "`long long`"]'::jsonb, 2, '`enum class` のデフォルト基底型は `int` です。C++ Core Guidelines（Enum.6）では、特別な理由がない限りデフォルトの `int` を使うことを推奨しています。基底型を変える場合は `enum class Color : uint8_t` のように明示します。', 'https://en.cppreference.com/w/cpp/language', 'unpublished', false),
  (639, 'セクション: C++ 基礎', '定数畳み込み（constant folding）', '以下のコードで `C` の値が `30` になるのはいつですか？', 'constexpr int A = 10;
constexpr int B = 20;
constexpr int C = A + B;', '["プログラム起動時（main 関数の実行前）", "変数 C が最初にアクセスされた時", "コンパイル時。実行時には加算命令は生成されず 30 が埋め込まれる", "最適化オプションを有効にしたビルド時のみ"]'::jsonb, 2, '`constexpr` で定義された定数同士の演算はコンパイル時に完結します。これを定数畳み込み（constant folding）といい、実行時コストがゼロになります。条件は「定義と同時に初期化」かつ「初期化子がコンパイル時に確定していること」です。', 'https://en.cppreference.com/w/cpp/language', 'unpublished', false),
  (640, 'セクション: C++ 基礎', 'スコープとリンケージの違い', 'スコープとリンケージの説明として最も正しいのはどれですか？', '// fileA.cpp
int x = 42;         // 外部リンケージ
static int y = 42;  // 内部リンケージ', '["スコープはファイル間の可視性、リンケージはブロック内の可視性を制御する", "スコープとリンケージは同じ概念で、どちらも変数の生存期間を表す", "スコープはブロック内の可視性、リンケージはファイル間の可視性を制御する", "リンケージはコンパイル時のみ意味を持ち、実行時には関係しない"]'::jsonb, 2, 'スコープはブロック（`{}`）内での可視性を制御します。リンケージは翻訳単位（.cpp ファイル）をまたいだ可視性を制御します。外部リンケージは他ファイルから `extern` で参照可能、内部リンケージは同一ファイル内のみアクセス可能です。', 'https://en.cppreference.com/w/cpp/language', 'unpublished', false),
  (641, 'セクション: C++ 基礎', '内部リンケージの実現方法', 'グローバル変数を他のファイルから参照不可（内部リンケージ）にする方法として正しいものをすべて含む選択肢はどれですか？', '// fileA.cpp
constexpr int X = 42;', '["`extern` キーワードを付ける", "`static` を付ける、または無名名前空間に入れる", "`const` を付けるだけで内部リンケージになる", "`inline` キーワードを付ける"]'::jsonb, 1, '内部リンケージにする方法は `static` を付けるか、無名名前空間（`namespace { ... }`）に入れるかのどちらかです。モダン C++ では `static` より無名名前空間が推奨されます。無名名前空間は変数だけでなく関数や型にも適用できます。', 'https://en.cppreference.com/w/cpp/language', 'unpublished', false),
  (642, 'セクション: C++ 基礎', 'C++ Core Guidelines Enum.3', 'C++ Core Guidelines の Enum.3 が推奨する内容として正しいのはどれですか？', '// どちらが推奨されるか？
enum Color { RED, GREEN, BLUE };
enum class Color { RED, GREEN, BLUE };', '["単純な `enum` を使う。`enum class` は冗長なため", "`enum class` を使う。スコープ隔離と型安全のため", "`enum` も `enum class` も等価なのでどちらでもよい", "`enum` の代わりに `constexpr int` を使う"]'::jsonb, 1, 'Enum.3 は「単純な `enum` より `enum class` を使う」ことを推奨しています。`enum class` はスコープが隔離されるため名前衝突を防ぎ、`int` への暗黙変換が禁止されるため型安全です。', 'https://en.cppreference.com/w/cpp/language', 'unpublished', false),
  (643, 'セクション: C++ 基礎', 'enum class の基底型を変更するタイミング', 'C++ Core Guidelines（Enum.6）に従うと、`enum class` の基底型を変更するのが適切なのはどれですか？', 'enum class Flag : uint8_t {
    A = 0x01,
    B = 0x02,
};
enum class Status {
    OK,
    ERROR,
};', '["常に `uint8_t` にしてメモリを節約すべき", "デフォルトの `int` では範囲が足りない場合や、外部仕様（プロトコル・ハードウェア）に合わせる必要がある場合など、明確な理由がある場合のみ", "パフォーマンス向上のために常に最小の型を指定すべき", "基底型の変更は C++ 標準では認められていない"]'::jsonb, 1, 'Enum.6 では「基底型はデフォルト（`int`）を使い、変える理由がある場合のみ変更する」としています。理由の例としては、ハードウェアレジスタやネットワークプロトコルの仕様に合わせる場合、`int` の範囲を超える値が必要な場合などがあります。', 'https://en.cppreference.com/w/cpp/language', 'unpublished', false),
  (644, 'セクション: C++ 基礎', 'enum class の名前付きインデックスとしての使い方', '以下のコードで `CharacterTemplateType` が果たしている役割として最も正しいのはどれですか？', 'constexpr auto characterTemplates = std::to_array<Character>({
    Character{ /* PLAYER */ },
    Character{ /* SLIME  */ },
    Character{ /* BOSS   */ },
});

characterTemplates[std::to_underlying(CharacterTemplateType::BOSS)];', '["コマンド選択肢を型安全に列挙するための enum", "配列のインデックスに意味のある名前を与える名前付きインデックス", "キャラクターの状態遷移を管理するための状態機械", "配列のサイズをコンパイル時に計算するためのセンチネル"]'::jsonb, 1, '`CharacterTemplateType` は `characterTemplates` 配列の各要素に `PLAYER` / `SLIME` / `BOSS` という名前を与え、`[0]` / `[1]` / `[2]` の代わりに意図の伝わるアクセスを可能にする名前付きインデックスです。`COUNT` を持たない点でサイズ計算用の `BattleSlot` とは役割が異なります。', 'https://en.cppreference.com/w/cpp/language', 'unpublished', false),
  (645, 'セクション: C++ 基礎', 'データテーブルとしての constexpr 配列', '以下の `characterTemplates` のような `constexpr` 配列はゲーム開発で何と呼ばれますか？', 'constexpr auto characterTemplates = std::to_array<Character>({
    Character{ 1060, 1060, 60, 60, "ゆうしゃ", "", 20, ... },
    Character{    3,    3,  0,  0, "スライム", "...", 2, ... },
    Character{  255,  255,  0,  0, "まおう",   "...",50, ... },
});', '["ルックアップテーブル（またはマスターデータ）", "シングルトン", "ファクトリ関数", "コマンドパターン"]'::jsonb, 0, 'キャラクターのステータスや設定値を一箇所にまとめた定数配列はデータテーブル・ルックアップテーブルと呼ばれ、ゲーム開発ではマスターデータとも呼びます。`constexpr` でソースコードに直書きしたものは簡易版で、本格的なマスターデータ管理では JSON や CSV に外出しして読み込みます。', 'https://en.cppreference.com/w/cpp/language', 'unpublished', false),
  (646, 'セクション: C++ 基礎', 'BattleSlot の COUNT センチネル', '`BattleSlot::COUNT` の用途として正しいのはどれですか？', 'enum class BattleSlot
{
    PLAYER,
    MONSTER,
    COUNT,
};

std::array<Character, std::to_underlying(BattleSlot::COUNT)> characters;', '["ループの終了条件には使えないが、配列サイズにのみ使える", "配列サイズやループ上限として使えるセンチネル値で、要素数と配列定義を常に同期させられる", "COUNT は enum の慣例的な最後の要素で、実際には値を持たない", "switch 文で全列挙子を処理したかを確認するためだけに使う"]'::jsonb, 1, '`COUNT` は enum class の最後に置くセンチネル値で、`std::array` のサイズ指定やループの上限として使います。列挙子を追加すると `COUNT` の値も自動的に増えるため、配列サイズと要素数が常に同期するのが利点です。', 'https://en.cppreference.com/w/cpp/language', 'unpublished', false),
  (647, 'セクション: C++ 基礎', 'CommandType と CharacterTemplateType の使い分け', '`CommandType` と `CharacterTemplateType` の本質的な違いはどれですか？', 'enum class CommandType  { FIGHT, SPELL, FULL_HEAL, RUN };
enum class CharacterTemplateType { PLAYER, SLIME, BOSS };', '["要素数の違いだけで、使い方は同じ", "`CommandType` は switch 文で有限の選択肢を型安全に扱うために使い、`CharacterTemplateType` は配列の名前付きインデックスとして使う", "`CharacterTemplateType` は switch 文と組み合わせ、`CommandType` は配列インデックスとして使う", "両方とも配列インデックスとしてのみ使われる"]'::jsonb, 1, '`CommandType` は switch 文と組み合わせて「有限の状態・選択肢を型安全に表す」enum class 本来の使い方をしています。`CharacterTemplateType` は配列インデックスに名前を付けるという C 言語由来のイディオムです。同じ `enum class` でも目的が異なります。', 'https://en.cppreference.com/w/cpp/language', 'unpublished', false),
  (648, 'セクション: C++ 基礎', '配列＋名前付きインデックス vs 構造体フィールド', 'バトルの参加者を管理する際、配列＋`BattleSlot` より構造体フィールドが適している条件はどれですか？', '// 案A: 配列 + 名前付きインデックス
std::array<Character, to_underlying(BattleSlot::COUNT)> characters;
characters[to_underlying(BattleSlot::PLAYER)].hp;

// 案B: 構造体フィールド
struct BattleState { Character player; Character monster; };
battleState.player.hp;', '["全員にダメージを与えるなど for ループで一括処理したい場合", "個々の参加者が異なる意味を持ち、for ループで一括処理する必要がない場合", "参加者数が実行時に変わる可能性がある場合", "配列インデックスで直接アクセスしたい場合"]'::jsonb, 1, '構造体フィールドは `to_underlying` が不要で `battleState.player.hp` と直接アクセスでき可読性が高いです。一方、全員に同じ処理を for ループで適用したい場合は配列の方が自然です。RPG.cpp では「全員のターン処理をループで回す」要件があるため配列を選んでいます。', 'https://en.cppreference.com/w/cpp/language', 'unpublished', false),
  (649, 'セクション: C++ 基礎', '無名名前空間とは何か', '無名名前空間（`namespace { ... }`）の説明として正しいのはどれですか？', '// fileA.cpp
namespace {
    constexpr int X = 42;
    void helper() { /* ... */ }
}

// fileB.cpp
// X も helper も見えない', '["どのファイルからもアクセスできるグローバル名前空間の別名", "同じ翻訳単位（.cpp ファイル）内からしかアクセスできない名前空間で、変数・関数・型すべてに内部リンケージを与えられる", "クラス内部でのみ使用できる名前空間", "`static` キーワードと完全に等価で、変数にのみ適用できる"]'::jsonb, 1, '無名名前空間は同じ翻訳単位（.cpp ファイル）内からしかアクセスできません。`static` と同じく内部リンケージを実現しますが、変数だけでなく関数・struct・enum class にも適用できる点が優れています。モダン C++ では `static` より無名名前空間が推奨されます。', 'https://en.cppreference.com/w/cpp/language', 'unpublished', false),
  (650, 'セクション: C++ 基礎', 'C++ Core Guidelines SF.22', 'C++ Core Guidelines SF.22 の内容として正しいのはどれですか？', '// 実装ファイル（.cpp）での推奨構造
namespace {
    // 外部に公開しない定数・型・関数
    constexpr int X = 42;
    enum class State { ... };
    void helper() { ... }
}

// 外部に公開するエンティティ
void PublicFunction() { ... }', '["ヘッダファイルでは無名名前空間を使わない", "実装ソースファイルで外部に公開しないすべての定義は無名名前空間に入れる", "無名名前空間はパフォーマンス最適化のために使う", "public メンバ関数は無名名前空間に入れてはならない"]'::jsonb, 1, 'SF.22 は「実装ソースファイルで外部エンティティでない定義にはすべて無名名前空間を使う」というルールです。これにより意図しない外部リンケージを防ぎ、ODR（One Definition Rule）違反のリスクを下げます。定数だけでなく関数・enum class・struct も対象です。', 'https://en.cppreference.com/w/cpp/language', 'unpublished', false),
  (651, 'セクション: C++ 基礎', 'char配列 vs std::string_view', '`char name[13]` の問題点として最も正しいのはどれですか？', 'struct Character {
    char name[13]; // 12バイト + 終端文字
};', '["文字列をコピーできないため、代入が一切できない", "バッファサイズを手動で管理する必要があり、超えた場合にコンパイルエラーにならず隣のメモリを壊すバグになる", "char配列は constexpr コンテキストで使用できない", "UTF-8 文字列を格納できない"]'::jsonb, 1, '`char[]` は固定サイズの箱で、サイズを超えた書き込みはコンパイルエラーにならず未定義動作（隣のメモリ破壊）になります。`std::string_view` はサイズ管理が不要で安全に文字列を参照できます。', 'https://en.cppreference.com/w/cpp/language', 'unpublished', false),
  (652, 'セクション: C++ 基礎', 'std::string_view の所有と寿命', '`std::string_view` の説明として最も正しいのはどれですか？', 'struct Character {
    std::string_view name;
};

constexpr auto characterTemplates = std::to_array<Character>({
    Character{ .name = "ゆうしゃ" },
});', '["文字列データを所有するため、元の文字列が消えても安全", "文字列を指差しているだけで所有しない。元の文字列が消えると無効になるが、文字列リテラルはプログラム終了まで存在するので安全", "std::string と完全に等価で、メモリ管理も自動", "constexpr コンテキストでは使用できない"]'::jsonb, 1, '`std::string_view` は文字列を所有せず参照するだけです。参照先が消えると無効になりますが、文字列リテラル（`"ゆうしゃ"` 等）はプログラムが動いている間ずっと存在するため、リテラルを指す `string_view` は安全です。', 'https://en.cppreference.com/w/cpp/language', 'unpublished', false),
  (653, 'セクション: C++ 基礎', '集成体初期化の順序依存問題', '以下の初期化の問題点として最も正しいのはどれですか？', 'struct Character {
    int hp;
    int maxhp;
    int attack;
};

Character c{ 100, 100, 20 };', '["値をカンマ区切りで渡せないためコンパイルエラーになる", "フィールドを追加・並び替えすると初期化値が無言でずれ、コンパイルエラーにならないままバグになる", "constexpr には使用できない", "整数値のみ使用可能で、enum class は渡せない"]'::jsonb, 1, '位置ベースの集成体初期化はフィールドの順序に依存します。構造体のフィールドを追加・削除・並び替えすると、すべての初期化値が無言でずれてもコンパイルエラーにならず、発見困難なバグになります。C++20 の指示付き初期化で解決できます。', 'https://en.cppreference.com/w/cpp/language', 'unpublished', false),
  (654, 'セクション: C++ 基礎', 'C++20 指示付き初期化（designated initializers）', 'C++20 の指示付き初期化の利点として最も正しいのはどれですか？', 'Character c{
    .hp     = 100,
    .maxhp  = 100,
    .attack = 20,
};', '["初期化の実行速度が向上する", "フィールド名を明示するため、フィールドの追加・並び替えをしても初期化値がずれず、可読性も上がる", "すべてのフィールドを省略できるようになる", "constexpr 構造体にのみ使用できる"]'::jsonb, 1, '指示付き初期化（`.field = value`）はフィールド名を明示するため、構造体が変更されても初期化値が意図せずずれることを防ぎます。また何の値を設定しているか一目でわかり可読性も向上します。', 'https://en.cppreference.com/w/cpp/language', 'unpublished', false),
  (655, 'セクション: C++ 基礎', 'CommandEntry 構造体の役割', '以下の `CommandEntry` 構造体の役割として最も正しいのはどれですか？', 'struct CommandEntry {
    CommandType type;
    const char *name;
};

constexpr auto commands = std::to_array<CommandEntry>({
    CommandEntry{CommandType::FIGHT, "たたかう"},
    CommandEntry{CommandType::RUN,   "にげる"},
});', '["コマンドの実行処理を関数ポインタとして保持する", "コマンド種別（内部識別子）と画面表示用の名前をペアで持つ", "コマンドの入力キーと処理を対応付ける", "コマンドの実行順序を管理するキュー"]'::jsonb, 1, '`CommandType` は内部識別子（`FIGHT` 等）であり画面表示には使えません。`CommandEntry` が `type` と表示名（`"たたかう"` 等）をペアで持つことで、コマンド選択UIの描画とロジックの両方に対応できます。', 'https://en.cppreference.com/w/cpp/language', 'unpublished', false),
  (656, 'セクション: C++ 基礎', '雛形テーブルと実インスタンスの分離', '`characterTemplates` と `GameState::characters` の役割の違いとして最も正しいのはどれですか？', 'constexpr auto characterTemplates = std::to_array<Character>({ /* 初期値 */ });

struct GameState {
    std::array<Character, std::to_underlying(BattleSlot::COUNT)> characters;
};', '["両者は同じデータを指しており、どちらを使っても同じ", "`characterTemplates` はコンパイル時定数の雛形、`GameState::characters` はバトル中に状態が変化する実インスタンス", "`characterTemplates` は実行時に変更可能で、`GameState::characters` は変更不可", "`GameState::characters` はテンプレートで、バトルごとに `characterTemplates` へコピーされる"]'::jsonb, 1, '`characterTemplates` は `constexpr` のコンパイル時定数で、キャラクターの初期値の雛形です。`GameState::characters` はそこからコピーして作られる実インスタンスで、バトル中の HP 減少などの状態変化を保持します。雛形と実体を分けることで初期値が保護されます。', 'https://en.cppreference.com/w/cpp/language', 'unpublished', false),
  (657, 'セクション: C++ 基礎', 'FIELD_WIDTH の役割と Core Guidelines', '次の定義について、C++ Core Guidelines の考え方に最も近い説明はどれですか？', 'constexpr int FIELD_WIDTH = 520;', '["`520` のような数値は意味が明白なので、名前を付けずに直接書く方が望ましい", "意味のある定数名でマジックナンバーを避けている点はよい。C++ では `#define` より `constexpr` を使うのが自然", "`FIELD_WIDTH` はマクロ風の大文字なので、必ず `#define` で書かなければならない", "`constexpr int` は配列サイズには使えないので不適切"]'::jsonb, 1, '`520` を直接各所に書くより、`FIELD_WIDTH` のような名前付き定数にした方が意図が伝わります。C++ Core Guidelines ではマジックナンバーを避け、定数や擬似関数に `#define` ではなく `constexpr` や `const` を使う方針です。', 'https://en.cppreference.com/w/cpp/language', 'unpublished', false),
  (658, 'セクション: C++ 基礎', '中央寄せ開始座標の計算', '次の式 `FIELD_WIDTH / 2 - patternWidth / 2` が求めているものとして最も正しいのはどれですか？', 'PatternTransfer(
    FIELD_WIDTH / 2 - patternWidth / 2,
    FIELD_HEIGHT / 2 - patternHeight / 2,
    patternWidth,
    patternHeight,
    (bool*)pattern);', '["`field` の左端そのものの位置", "`pattern` を `field` の中央付近に置くための左上開始座標", "`field` と `pattern` の面積差", "`pattern` の中心座標そのもの"]'::jsonb, 1, '`field` の中心位置から `pattern` の中心位置を引いて、`pattern` の左上をどこに置けば中央寄せになるかを求めています。`FIELD_WIDTH = 520`、`patternWidth = 513` なら開始位置は `4` になり、左に 4 セル、右に 3 セルの余白ができます。', 'https://en.cppreference.com/w/cpp/language', 'unpublished', false),
  (659, 'セクション: C++ 基礎', 'field と pattern の役割の違い', '`field` と `pattern` の違いとして最も正しいのはどれですか？', 'bool field[FIELD_HEIGHT][FIELD_WIDTH];
constexpr int patternWidth = 513;
constexpr int patternHeight = 513;
bool pattern[patternHeight][patternWidth] = {};', '["`field` は初期配置用の部品、`pattern` はシミュレーション本体の盤面", "`field` は実際に更新・描画される盤面、`pattern` は最初に `field` へコピーする初期配置データ", "`field` も `pattern` も完全に同じ役割で、名前だけが違う", "`pattern` は描画専用、`field` は入力専用"]'::jsonb, 1, '`field` はライフゲームの現在状態を保持し、描画や次世代計算の対象になります。`pattern` は最初の形を作るためのテンプレートで、`PatternTransfer()` によって `field` の中央に貼り付けられます。', 'https://en.cppreference.com/w/cpp/language', 'unpublished', false),
  (660, 'セクション: C++ 基礎', 'bool 配列を足し算できる理由', '次のコードで `count += field[roopedY][roopedX];` が成立する理由として最も正しいのはどれですか？', 'int count = 0;
count += field[roopedY][roopedX];', '["`bool` は足し算できないが、配列要素だけ特別に許可されている", "`bool` は加算時に自動的に `int` へ変換され、`true` は `1`、`false` は `0` になる", "`field` の型は実際には `int` 配列なので `bool` ではない", "`+=` が内部で文字列連結に変換される"]'::jsonb, 1, 'C++ では `bool` を算術演算に使うと整数型へ暗黙変換されます。そのため `true` は `1`、`false` は `0` として扱われ、生きているセルだけを数える処理として成立します。', 'https://en.cppreference.com/w/cpp/language', 'unpublished', false),
  (661, 'セクション: C++ 基礎', 'memcpy の引数順と効果', '次の `memcpy` 呼び出しの意味として最も正しいのはどれですか？', 'memcpy(field, nextField, sizeof field);', '["`field` から `nextField` へ `sizeof nextField` バイトコピーする", "`nextField` の内容を `field` に `field` 全体のサイズ分コピーする", "`field` と `nextField` の差分だけを自動で検出して更新する", "`field` 配列を初期化して全要素を `false` にする"]'::jsonb, 1, '`memcpy` の引数順は `コピー先, コピー元, バイト数` です。ここでは `nextField` に作った次世代盤面を `field` へ丸ごと上書きしています。`sizeof field` は 2 次元配列全体のバイト数を表します。', 'https://en.cppreference.com/w/cpp/language', 'unpublished', false),
  (662, 'セクション: C++ 基礎', 'std::clock の値とフレーム時間の違い', '次のコードで `clocks` に記録される値として最も正しいのはどれですか？', 'clock_t lastClock = std::clock();
...
lastClock = newClock;
clocks.push_back(lastClock);', '["毎フレームの経過秒数そのもの", "前回フレームから今回フレームまでの差分 tick 数", "`std::clock()` の現在値、つまり開始からの累積クロック値", "常に `CLOCKS_PER_SEC` と同じ定数値"]'::jsonb, 2, '`lastClock = newClock;` の直後に `push_back(lastClock)` しているため、保存しているのは差分ではなくその時点の `std::clock()` の値です。1 フレーム当たりの時間を記録したいなら `newClock - lastClock` を秒に変換して保存する必要があります。', 'https://en.cppreference.com/w/cpp/language', 'unpublished', false),
  (663, 'セクション: C++ 基礎', 'PatternTransfer の引数名の意味', '次の `PatternTransfer` の引数名の説明として最も正しいのはどれですか？', 'void PatternTransfer(
    int _destX, int _destY,
    int _srcWidth, int _srcHeight,
    bool *_pPattern)', '["`dest` はコピー元、`src` はコピー先、`p` は public の略", "`_destX` と `_destY` は貼り付け先座標、`_srcWidth` と `_srcHeight` はコピー元の大きさ、`_pPattern` はパターン先頭へのポインタ", "`_destX` と `_destY` はパターンの中心座標、`_srcWidth` と `_srcHeight` はフィールド全体の大きさ、`_pPattern` は配列の要素数", "すべての引数はデバッグ用で、実際のコピー処理には使われない"]'::jsonb, 1, '`dest` は destination でコピー先、`src` は source でコピー元、`p` は pointer の略です。したがって `_destX` / `_destY` は `field` のどこに貼り付けるか、`_srcWidth` / `_srcHeight` はコピー元パターンの幅と高さ、`_pPattern` はコピー元データの先頭アドレスを表します。', 'https://en.cppreference.com/w/cpp/language', 'unpublished', false),
  (664, 'セクション: セキュリティツール比較', 'CI/CD に載せやすい理由', 'OWASP ZAP が 3 ツールの中で CI/CD に組み込みやすい理由として最も適切なのはどれですか？', NULL, '["公式 Docker イメージと GitHub Actions が用意されているから", "Community 版でも Burp Scanner が使えるから", "w3af のプラグインをそのまま流用できるから", "ブラウザを起動しなくても Firestore を直接読めるから"]'::jsonb, 0, 'OWASP ZAP は公式 Docker イメージ、`zap-baseline.py` などのスキャンスクリプト、GitHub Actions を備えているため、パイプラインに組み込みやすいです。', 'https://owasp.org/www-project-web-security-testing-guide/', 'unpublished', false),
  (665, 'セクション: セキュリティツール比較', 'Burp Community の制約', 'Burp Suite Community 版の制約として正しいものはどれですか？', NULL, '["REST API が一切使えない", "自動脆弱性スキャン機能が使えない", "プロキシ機能が存在しない", "Repeater が完全に無効化されている"]'::jsonb, 1, 'Burp Suite Community 版では Proxy や Repeater などの手動テスト機能は使えますが、Professional 版のような自動 Scanner は使えません。', 'https://owasp.org/www-project-web-security-testing-guide/', 'unpublished', false),
  (666, 'セクション: セキュリティツール比較', 'w3af の最大の注意点', '今回の比較で、w3af の最大の注意点として繰り返し挙げられていたものはどれですか？', NULL, '["GUI が新しすぎて不安定なこと", "メンテナンスが低調で更新が少ないこと", "Go API を一切スキャンできないこと", "Linux では絶対に動かないこと"]'::jsonb, 1, 'w3af はオープンソースですが更新頻度が低く、依存関係の古さや最新脆弱性への追従の遅れが注意点として挙げられました。', 'https://owasp.org/www-project-web-security-testing-guide/', 'unpublished', false),
  (667, 'セクション: セキュリティツール比較', 'Blind SSRF に強い機能', 'Blind SSRF の検出に最も有利な Burp Suite の機能はどれですか？', NULL, '["Sequencer", "Comparer", "Burp Collaborator", "Decoder"]'::jsonb, 2, 'Burp Collaborator は DNS/HTTP コールバックを受け取れるため、レスポンスに何も返らない Blind SSRF でも検出しやすくなります。', 'https://owasp.org/www-project-web-security-testing-guide/', 'unpublished', false),
  (668, 'セクション: セキュリティツール比較', 'ZAP が苦手な領域', 'OWASP ZAP が特に苦手な領域として最も適切なのはどれですか？', NULL, '["HTTP ヘッダの確認", "ビジネスロジックの欠陥の自動判定", "OpenAPI ベースの API スキャン", "XSS の検出"]'::jsonb, 1, 'ZAP は通信をもとに脆弱性を探すツールなので、仕様理解が必要なビジネスロジック欠陥や安全でない設計の自動判定は苦手です。', 'https://owasp.org/www-project-web-security-testing-guide/', 'unpublished', false),
  (669, 'セクション: セキュリティツール比較', 'SPA に弱い理由', 'w3af が React のような SPA に弱い理由として最も正しいものはどれですか？', NULL, '["JavaScript を実行した動的クロールが弱いから", "HTTP を送れないから", "CSS を解析できないから", "PostgreSQL を使うアプリだけを対象にしているから"]'::jsonb, 0, 'w3af は静的なリンクをたどる前提が強く、React Router などで生成される SPA の画面遷移を十分に追えないことがあります。', 'https://owasp.org/www-project-web-security-testing-guide/', 'unpublished', false),
  (670, 'セクション: Docker セキュリティ', 'イメージ CVE を見るべきツール', 'Docker イメージ自体の CVE を調べる用途に最も適したツールはどれですか？', NULL, '["Burp Repeater", "Trivy", "Ajax Spider", "Burp Sequencer"]'::jsonb, 1, 'Trivy は Docker イメージの脆弱性、秘密情報、設定不備を見る専用ツールであり、Web 脆弱性診断ツールとは役割が異なります。', 'https://docs.docker.com/engine/security/', 'unpublished', false),
  (671, 'セクション: Docker セキュリティ', 'Hadolint の役割', 'Hadolint の主な役割として正しいものはどれですか？', NULL, '["Dockerfile のベストプラクティス違反を検出する", "実行中コンテナのメモリリークを検出する", "Flutter の証明書ピンニングを解除する", "Firestore のルートコレクションを列挙する"]'::jsonb, 0, 'Hadolint は Dockerfile の静的チェックに使われ、危険な書き方やベストプラクティス違反を早期に見つけるのに向いています。', 'https://docs.docker.com/engine/security/', 'unpublished', false),
  (672, 'セクション: Docker セキュリティ', 'Dockle の用途', 'Dockle の説明として最も正しいものはどれですか？', NULL, '["CIS Benchmark に基づいてコンテナ設定を点検する", "SQL インジェクションだけに特化したツール", "React Router のルートを列挙するツール", "JWT のランダム性を測るツール"]'::jsonb, 0, 'Dockle はコンテナ設定やイメージの構成を CIS Benchmark などの観点から点検するためのツールです。', 'https://docs.docker.com/engine/security/', 'unpublished', false),
  (673, 'セクション: OWASP ZAP', 'Baseline と Full Scan の違い', '`zap-baseline.py` と `zap-full-scan.py` の違いとして最も正しいものはどれですか？', 'docker run --rm ghcr.io/zaproxy/zaproxy:stable zap-baseline.py -t https://example.com
docker run --rm ghcr.io/zaproxy/zaproxy:stable zap-full-scan.py -t https://example.com', '["どちらも完全に同じで名前だけが違う", "Baseline は主に安全な確認、Full Scan はアクティブスキャンを含む", "Baseline は Burp 専用、Full Scan は ZAP 専用", "Full Scan は HTML を返せず JSON のみ返す"]'::jsonb, 1, 'Baseline は主に受動的・安全寄りの確認、Full Scan はアクティブスキャンを含むため、対象への影響も大きくなります。', 'https://www.zaproxy.org/docs/', 'unpublished', false),
  (674, 'セクション: OWASP ZAP', 'OpenAPI 向けスクリプト', 'OpenAPI 定義から API をスキャンしたいときに使う ZAP のスクリプトはどれですか？', NULL, '["zap-api-scan.py", "zap-repeater.py", "zap-sequencer.py", "zap-scope.py"]'::jsonb, 0, 'OpenAPI や GraphQL 定義を入力にして API を確認したい場合は `zap-api-scan.py` を使います。', 'https://www.zaproxy.org/docs/', 'unpublished', false),
  (675, 'セクション: Burp Suite', 'IDOR の補助に使う拡張', 'IDOR や認可不備の検証を半自動化するために Burp Suite でよく使う拡張はどれですか？', NULL, '["Logger++", "Autorize", "Retire.js", "Turbo Intruder"]'::jsonb, 1, 'Autorize は複数ユーザのトークンで同じリクエストを再送し、認可の崩れを見つける補助に使われます。', 'https://portswigger.net/burp/documentation', 'unpublished', false),
  (676, 'セクション: Burp Suite', 'JWT Editor の用途', 'Burp Suite の `JWT Editor` 拡張の主な用途として最も適切なのはどれですか？', NULL, '["JWT の解析や改変、脆弱性検証を補助する", "TLS ハンドシェイクだけを高速化する", "Docker イメージをスキャンする", "ZAP のアラートを Burp に移す"]'::jsonb, 0, 'JWT Editor はトークンの中身確認、改変、署名関連の検証など JWT 周りのテストを補助する拡張です。', 'https://portswigger.net/burp/documentation', 'unpublished', false),
  (677, 'セクション: Burp Suite', 'Sequencer の役割', 'Burp Suite の Sequencer が得意なことはどれですか？', NULL, '["セッショントークンのランダム性を統計的に分析する", "Dockerfile を lint する", "OpenAPI 定義を生成する", "Flutter の proxy 設定を自動変更する"]'::jsonb, 0, 'Sequencer はセッション ID やトークンのランダム性を分析し、予測しやすい値になっていないかを見るための機能です。', 'https://portswigger.net/burp/documentation', 'unpublished', false),
  (678, 'セクション: OWASP ZAP', 'React SPA で必要な機能', 'React のような SPA を ZAP でたどるとき、特に重要な機能はどれですか？', NULL, '["Ajax Spider", "Comparer", "Decoder", "Burp Collaborator"]'::jsonb, 0, 'SPA は JavaScript 実行後に画面が構成されるため、通常の Spider だけでなく Ajax Spider の利用が重要になります。', 'https://www.zaproxy.org/docs/', 'unpublished', false),
  (679, 'セクション: スタック別診断', 'w3af の現実的な使いどころ', 'Go + React + Flutter + Docker の構成で、w3af の現実的な使いどころとして最も適切なのはどれですか？', NULL, '["React SPA の動的画面遷移だけに使う", "Flutter の証明書ピンニング解除だけに使う", "Go バックエンド API を直接スキャンする用途に絞る", "Docker イメージの CVE を調べる用途に使う"]'::jsonb, 2, 'w3af は SPA やモバイルプロキシ連携が弱いため、この構成では Go API の直接スキャンに絞るのが現実的と整理されました。', 'https://owasp.org/www-project-web-security-testing-guide/', 'unpublished', false),
  (680, 'セクション: モバイル診断', 'Flutter 通信を傍受する前提', 'Flutter アプリの通信を ZAP や Burp で傍受するときにまず必要なことはどれですか？', NULL, '["プロキシ設定と CA 証明書のインストール", "Dockerfile の EXPOSE を削除すること", "PostgreSQL を SQLite に変えること", "Go のポインタを unsafe にすること"]'::jsonb, 0, 'モバイルアプリの HTTPS 通信を傍受するには、端末やエミュレータがプロキシを通るよう設定し、プロキシ CA 証明書を信頼させる必要があります。', 'https://owasp.org/www-project-mobile-app-security/', 'unpublished', false),
  (681, 'セクション: モバイル診断', 'Android 7+ の証明書制約', 'Android 7 以降でユーザー証明書をアプリが信頼しない問題への対策として適切なのはどれですか？', '<network-security-config>
  <debug-overrides>
    <trust-anchors>
      <certificates src="user" />
    </trust-anchors>
  </debug-overrides>
</network-security-config>', '["`network_security_config` で debug 用の信頼設定を追加する", "必ず本番証明書を埋め込む", "Burp のポートを 80 に変える", "React Router を HashRouter に変える"]'::jsonb, 0, 'Android 7+ ではユーザー証明書が自動で信頼されないため、デバッグ用に `network_security_config` を設定する対応がよく使われます。', 'https://owasp.org/www-project-mobile-app-security/', 'unpublished', false),
  (682, 'セクション: モバイル診断', '証明書ピンニングの影響', 'Flutter アプリが証明書ピンニングを実装している場合、プロキシ診断で起こりやすいことはどれですか？', NULL, '["プロキシ経由でも常に平文 HTTP に変換される", "プロキシ CA を信頼せず通信が失敗する", "JWT が自動更新される", "DOM XSS の検出率が上がる"]'::jsonb, 1, '証明書ピンニングが有効だと、端末に追加した CA 証明書ではなくアプリ側の固定証明書検証が優先され、MITM 型のプロキシ傍受が失敗しやすくなります。', 'https://owasp.org/www-project-mobile-app-security/', 'unpublished', false),
  (683, 'セクション: モバイル診断', 'Flutter 連携で最も現実的なツール', 'Flutter アプリの通信傍受と手順の充実度という観点で最も現実的なツールはどれですか？', NULL, '["w3af", "Burp Suite", "Hadolint", "grep_search"]'::jsonb, 1, 'Flutter のプロキシ設定、証明書導入、ピンニング確認、gRPC 拡張などまで含めると、Burp Suite が最も現実的な選択肢として整理されました。', 'https://owasp.org/www-project-mobile-app-security/', 'unpublished', false),
  (684, 'セクション: Go API 診断', 'バックエンド言語と HTTP 診断', 'Go 製バックエンドに対して ZAP や Burp が診断できる理由として正しいものはどれですか？', NULL, '["Go の AST を内部で直接読むから", "HTTP レベルの通信を解析するため言語に依存しないから", "Go 専用プラグインが必須だから", "Go でしか JWT を発行できないから"]'::jsonb, 1, 'これらのツールは HTTP/HTTPS の通信内容を解析するので、Go・Node・Java などバックエンド言語そのものには依存しません。', 'https://pkg.go.dev/net/http', 'unpublished', false),
  (685, 'セクション: Go API 診断', 'ZAP と JSON ボディ', 'ZAP で JSON リクエストのパラメータを積極的に検査したいときに確認すべきことはどれですか？', NULL, '["Active Scan Input Vectors で JSON を有効にする", "必ず gRPC 拡張を入れる", "Docker の volume を外す", "Node.js を 14 系に固定する"]'::jsonb, 0, 'Go API では JSON ボディが多いため、ZAP の Input Vectors で JSON を有効にしておかないと検査の見落としが起きやすくなります。', 'https://pkg.go.dev/net/http', 'unpublished', false),
  (686, 'セクション: Go API 診断', 'JWT 期限切れの影響', 'スキャン中に JWT が期限切れになると起きやすい問題はどれですか？', NULL, '["すべての API が自動で公開される", "後続リクエストが 401 になりスキャンが不完全になる", "Firestore の projectId が変わる", "HTML の `<br>` が自動削除される"]'::jsonb, 1, '認証付き API をスキャン中にトークンが切れると、その後のリクエストが未認証扱いになり、正しい画面や API を十分に調べられなくなります。', 'https://pkg.go.dev/net/http', 'unpublished', false),
  (687, 'セクション: Go API 診断', '危険な CORS の組み合わせ', 'CORS の設定として特に危険な組み合わせはどれですか？', NULL, '["`Access-Control-Allow-Origin: *` と認証情報の併用", "`Content-Type: application/json` を返すこと", "`Strict-Transport-Security` を返すこと", "`X-Content-Type-Options: nosniff` を返すこと"]'::jsonb, 0, 'ワイルドカード許可と認証情報の扱いが不適切に組み合わさると、意図しないオリジンからの認証付きアクセスを許すリスクがあります。', 'https://pkg.go.dev/net/http', 'unpublished', false),
  (688, 'セクション: w3af', 'Bearer トークンを固定で送る方法', 'w3af で長寿命の Bearer トークンを毎回送る実装として適切なのはどれですか？', 'w3af>>> http-settings
w3af/config:http-settings>>> set headers_file /tmp/headers.txt', '["`headers_file` に Authorization ヘッダを書いて読み込む", "`bool` を `int` に暗黙変換する", "`runQuery` で Firestore を直接読む", "`zap-api-scan.py` を同時に実行する"]'::jsonb, 0, 'w3af は JWT 自動更新が弱いため、固定トークンを `headers_file` で読み込んで API に送る回避策が現実的です。', 'https://docs.w3af.org/en/latest/', 'unpublished', false),
  (689, 'セクション: Burp Suite', 'JWT 再取得の自動化', 'Burp Suite で JWT の期限切れ対策を自動化する機能として最も適切なのはどれですか？', NULL, '["Session Handling Rules", "Decoder", "Comparer", "Comment Pins"]'::jsonb, 0, 'Burp の Session Handling Rules とログインマクロを使うと、スキャン中に必要な認証トークン再取得を自動化できます。', 'https://portswigger.net/burp/documentation', 'unpublished', false),
  (690, 'セクション: Go API 診断', 'OpenAPI 定義の価値', 'Go API の診断で OpenAPI 定義が特に有効な理由はどれですか？', NULL, '["画面の CSS を最適化できるから", "クローラが見つけにくい API エンドポイントも網羅しやすいから", "Flutter の証明書を自動で信頼するから", "Docker イメージの CVE を消せるから"]'::jsonb, 1, 'API は HTML のリンクのようにたどれないことが多いため、OpenAPI 定義があるとスキャナが対象エンドポイントを網羅しやすくなります。', 'https://pkg.go.dev/net/http', 'unpublished', false),
  (691, 'セクション: Docker セキュリティ', 'スキャナコンテナの疎通', 'Docker 内で動くアプリをスキャナコンテナから叩くときに重要なのはどれですか？', 'docker run --rm --network your-app-network ghcr.io/zaproxy/zaproxy:stable ...', '["同じネットワークに参加させて疎通を確保する", "全コンテナを `--privileged` にする", "必ず `localhost` しか使わない", "`EXPOSE` を削除する"]'::jsonb, 0, 'スキャン対象コンテナへ名前解決・通信できることが前提なので、同じ Docker ネットワークへ参加させる設計が重要です。', 'https://docs.docker.com/engine/security/', 'unpublished', false),
  (692, 'セクション: Docker セキュリティ', 'Burp の Docker 利用事情', 'Burp Suite を Docker ネットワーク内でヘッドレス運用したい場合の説明として最も適切なのはどれですか？', NULL, '["Community 版に公式 Docker イメージがある", "Enterprise 版の方が現実的で、通常の Burp は手動運用が中心になる", "w3af の Docker イメージをそのまま使える", "Docker では Burp の Proxy は動かない"]'::jsonb, 1, 'Burp は通常 GUI 前提の利用が多く、ヘッドレスな自動運用は Enterprise 版の方が現実的です。', 'https://docs.docker.com/engine/security/', 'unpublished', false),
  (693, 'セクション: Docker セキュリティ', '3 ツールで見えないもの', 'OWASP ZAP・w3af・Burp Suite の 3 ツールで共通して見えにくいものはどれですか？', NULL, '["実行中 Web アプリのレスポンスヘッダ", "Docker イメージ内 OS パッケージの CVE", "XSS の反射結果", "CORS ヘッダ"]'::jsonb, 1, 'これらは Web 脆弱性診断ツールなので、HTTP 通信の外側にある Docker イメージ内部のパッケージ脆弱性は専用ツールが必要です。', 'https://docs.docker.com/engine/security/', 'unpublished', false),
  (694, 'セクション: Docker セキュリティ', 'Trivy の secret スキャン', 'Trivy で秘密情報の混入を重点的に見たいときのオプションとして適切なのはどれですか？', 'trivy image --scanners secret myapp:latest', '["`--scanners secret`", "`--proxy burp`", "`--ajax-spider`", "`--cluster-bomb`"]'::jsonb, 0, 'Trivy は `--scanners secret` で秘密情報スキャンを有効にでき、イメージ内の鍵やトークン混入を探せます。', 'https://docs.docker.com/engine/security/', 'unpublished', false),
  (695, 'セクション: Docker セキュリティ', 'IaC の設定チェック', 'Dockerfile や docker-compose の IaC セキュリティチェックに向くツールはどれですか？', NULL, '["Checkov", "Sequencer", "Ajax Spider", "JWT Editor"]'::jsonb, 0, 'Checkov は IaC 向けの静的検査ツールで、Dockerfile や compose の危険な設定を点検する用途に向いています。', 'https://docs.docker.com/engine/security/', 'unpublished', false),
  (696, 'セクション: Firebase / Firestore', '失敗したログイン経路', '今回の調査で失敗した Firebase CLI ログイン経路はどれですか？', 'firebase login --no-localhost', '["`invalid_request / Unable to verify client` で失敗した", "ローカルに `firebase` コマンドが無いので失敗したままだった", "SQL の構文エラーで失敗した", "PostgreSQL に接続できず失敗した"]'::jsonb, 0, '通常の `firebase login --no-localhost` は `Unable to verify client` で失敗し、この環境では別経路が必要でした。', 'https://firebase.google.com/docs/firestore', 'unpublished', false),
  (697, 'セクション: Firebase / Firestore', '成功した代替認証', '通常の Firebase CLI ログインが失敗した後、代替として成功したコマンドはどれですか？', NULL, '["`firebase login:ci`", "`firebase login:graphql`", "`firebase login:firestore`", "`firebase login:zap`"]'::jsonb, 0, '`firebase login:ci` は成功し、CLI で利用できるトークンを取得できました。', 'https://firebase.google.com/docs/firestore', 'unpublished', false),
  (698, 'セクション: Firebase / Firestore', 'プレビュー token エンドポイントのメソッド', 'Studio preview の token エンドポイント `https://api.studiodesignapp.com/api/v2/previews/rROnBByYOA/token` について正しいものはどれですか？', NULL, '["GET 専用エンドポイントである", "POST で token を取得した", "DELETE で token を更新する", "WebSocket でしかアクセスできない"]'::jsonb, 1, 'この token エンドポイントは POST で叩く必要があり、そこから preview 用の custom token を取得しました。', 'https://firebase.google.com/docs/firestore', 'unpublished', false),
  (699, 'セクション: Firebase / Firestore', 'custom token の交換先', 'preview token から Firebase の `idToken` を得るために使ったエンドポイントはどれですか？', NULL, '["`/JSON/ascan/action/scan/`", "`identitytoolkit.googleapis.com/v1/accounts:signInWithCustomToken`", "`firestore.googleapis.com/v1/projects:listCollectionIds`", "`api.studiodesignapp.com/api/v2/previews/runQuery`"]'::jsonb, 1, 'preview から得た custom token は Identity Toolkit の `signInWithCustomToken` に渡し、`idToken` を取得しました。', 'https://firebase.google.com/docs/firestore', 'unpublished', false),
  (700, 'セクション: Firebase / Firestore', '空表示の原因の切り分け', '`information/AiduBduv` が空に見える問題について、調査の結論として最も正しいものはどれですか？', NULL, '["Firestore の該当ドキュメントは空だった", "該当レコードは埋まっており、表示側の問題と判断した", "Docker ネットワークが原因で全文が削除された", "quiz データの seed が上書きした"]'::jsonb, 1, 'Firestore 上の該当ドキュメントにはタイトル・本文が入っており、データ欠損ではなくクライアント側の取得・描画問題と切り分けられました。', 'https://firebase.google.com/docs/firestore', 'unpublished', false),
  (701, 'セクション: Firebase / Firestore', '`net::ERR_ABORTED` が示すもの', 'ページ再読み込み時の Firestore listen チャンネルで `net::ERR_ABORTED` が見えたことから、最も自然な推測はどれですか？', NULL, '["Go のコンパイラが壊れている", "クライアント側の購読や実行時処理に問題がある", "Burp Suite が自動で本文を削除した", "`quiz.md` が読み込まれた"]'::jsonb, 1, 'データは存在したため、listen チャンネルの abort はデータ欠損よりもクライアントの購読・実行時処理の問題を示唆します。', 'https://firebase.google.com/docs/firestore', 'unpublished', false),
  (702, 'セクション: Studio DOM', '`information` ページの ID', '`information/AiduBduv` の DOM 調査結果として正しいものはどれですか？', NULL, '["`#cms-body` が存在した", "本文相当コンテナはあったが `#cms-body` は無かった", "`body` 要素しか存在しなかった", "`#__nuxt` が存在しなかった"]'::jsonb, 1, '`information/AiduBduv` では `#cms-body` 自体はありませんでしたが、`div.richText.sd.appear` という本文相当コンテナは存在していました。', 'https://developer.mozilla.org/en-US/docs/Web/API/Document_Object_Model', 'unpublished', false),
  (703, 'セクション: Studio DOM', '`case` ページの本文コンテナ', '`case/casestudy/detail/-HMbXDXq` の DOM 調査結果として正しいものはどれですか？', NULL, '["`div#cms-body.richText.sd.appear` が存在した", "本文コンテナは `canvas` のみだった", "`#__nuxt` が無かった", "`script#__NUXT_DATA__` が本文だった"]'::jsonb, 0, '`case` の詳細ページでは、実際に `div#cms-body.richText.sd.appear` が確認でき、提示されたカスタムコードの前提が成立していました。', 'https://developer.mozilla.org/en-US/docs/Web/API/Document_Object_Model', 'unpublished', false),
  (704, 'セクション: Studio DOM', 'ID なし本文コンテナの役割', '`div.richText.sd.appear` が `#cms-body` 相当と判断された理由として最も適切なのはどれですか？', NULL, '["常に Firestore の projectId を持っているから", "本文の `p`, `a`, `strong`, `br` などがまとまって入っていたから", "`canvas` より後ろにあるから", "Burp Collaborator が使えたから"]'::jsonb, 1, 'ID は無くても、本文に相当するリッチテキスト要素群がそこにまとまっていたため、役割として `#cms-body` に相当すると判断されました。', 'https://developer.mozilla.org/en-US/docs/Web/API/Document_Object_Model', 'unpublished', false),
  (705, 'セクション: Studio DOM', '`#cms-body` 依存コードの挙動', '`document.querySelector(''#cms-body'')` を前提にした後処理コードが、`information/AiduBduv` で何もしない理由はどれですか？', 'const root = document.querySelector(''#cms-body'');
if (!root) return;', '["`MutationObserver` が古いから", "対象 ID が存在せず早期 return するから", "`TreeWalker` が `div` を読めないから", "`inline style` が自動で消されるから"]'::jsonb, 1, 'コードは `#cms-body` を見つけられなければそのまま終了するため、本文相当コンテナが別の selector でしか存在しないページでは何も起きません。', 'https://developer.mozilla.org/en-US/docs/Web/API/Document_Object_Model', 'unpublished', false),
  (706, 'セクション: Studio DOM', '今回の学びの本質', 'Studio ページ差分の調査から得られた学びとして最も適切なのはどれですか？', NULL, '["本文の有無より、安定した識別子が付いているかが重要だった", "Firebase CLI は DOM を自動修正する", "Burp Suite が `id` 属性を生成する", "`#__nuxt` があれば必ず `#cms-body` がある"]'::jsonb, 0, '今回の差分は本文が存在するかではなく、JavaScript が狙うための安定した `id` が CMS 領域に付いているかどうかでした。', 'https://developer.mozilla.org/en-US/docs/Web/API/Document_Object_Model', 'unpublished', false),
  (707, 'セクション: Studio DOM', '`body` 末尾の要素', '`case/casestudy/detail/-HMbXDXq` のページで `body` 直下の末尾側に来ていたものとして正しいのはどれですか？', NULL, '["`div#cms-body` が `body` の末尾に直接置かれていた", "末尾は `script` と `script#__NUXT_DATA__` だった", "末尾は `canvas.comment-canvas` だった", "末尾は `head` だった"]'::jsonb, 1, '`#cms-body` は深い子孫であり、`body` 直下の末尾ではありませんでした。`body` の末尾側には script 群がありました。', 'https://developer.mozilla.org/en-US/docs/Web/API/Document_Object_Model', 'unpublished', false),
  (708, 'セクション: Studio DOM', '親要素内での `#cms-body` の位置', '`case` ページにおける `#cms-body` の位置づけとして正しいものはどれですか？', NULL, '["`body` 直下の 1 個目だった", "親コンテナ内では最後の子要素だった", "`head` 配下にあった", "SVG の中にあった"]'::jsonb, 1, '`#cms-body` は `body` 直下ではありませんが、その親コンテナの子要素としては末尾に位置していました。', 'https://developer.mozilla.org/en-US/docs/Web/API/Document_Object_Model', 'unpublished', false),
  (709, 'セクション: Studio DOM', 'ページ全体の抽象構造', '`case` ページを抽象的に見たときの構造として最も適切なのはどれですか？', NULL, '["アプリ殻 → 導入レイアウト → `#cms-body` 本文 → 下部導線", "`#cms-body` だけでページ全体が構成される", "すべてが `<canvas>` で描画される", "`head` に本文、`body` に画像だけがある"]'::jsonb, 0, 'ページ全体は Studio のレイアウトシステムの中に、本文ブロックとして `#cms-body` が差し込まれている構成と整理されました。', 'https://developer.mozilla.org/en-US/docs/Web/API/Document_Object_Model', 'unpublished', false),
  (710, 'セクション: カスタムコード', '監視している変化', '提示された擬似タグ変換コードの `MutationObserver` が主に監視しているものはどれですか？', 'mo.observe(root, { childList: true, subtree: true });', '["`childList` の変化", "`attributes` の変化のみ", "`characterData` の変化のみ", "CSS の computed style 変化"]'::jsonb, 0, 'コードでは `childList: true, subtree: true` を指定しており、要素の追加・削除のような変化を監視しています。', 'https://developer.mozilla.org/en-US/docs/Web/API/MutationObserver', 'unpublished', false),
  (711, 'セクション: カスタムコード', 'inline style 前提のリスク', 'この擬似タグ変換コードが崩れやすい条件として正しいものはどれですか？', 's.setAttribute(''style'', TAG_STYLE[tag] || '''');', '["CSP で inline style が禁止されている場合", "Go で書かれた API を使っている場合", "`#__nuxt` がある場合", "`<p>` が 10 個以上ある場合"]'::jsonb, 0, 'スタイルを `style` 属性へ直接埋め込む実装なので、CSP などで inline style が禁止されると表示が崩れる可能性があります。', 'https://developer.mozilla.org/en-US/docs/Web/API/MutationObserver', 'unpublished', false),
  (712, 'セクション: カスタムコード', '擬似タグが解釈できないケース', 'この実装で擬似タグが解釈できなくなるケースとして最も正しいものはどれですか？', NULL, '["`[title1]` が別テキストノードに分断される場合", "本文が `<p>` に入っている場合", "`MutationObserver` が存在する場合", "`document.readyState` が `loading` の場合"]'::jsonb, 0, '実装はテキストノード内の文字列として擬似タグを解釈するため、タグ文字列自体が複数テキストノードに分断されると認識できません。', 'https://developer.mozilla.org/en-US/docs/Web/API/MutationObserver', 'unpublished', false),
  (713, 'セクション: カスタムコード', 'ブロックまたぎで閉じないタグ', '提示コードの説明として正しいものはどれですか？', 'const CLOSE_ON_BLOCK = new Set([''title1'',''title2'',''rightCaption'',''photoCaption'']);', '["`color` はブロックをまたいでも明示的に閉じるまで継続する", "すべてのタグはブロックをまたいだ瞬間に閉じる", "`note` だけは DOM 全体で永続する", "`annotation` は span ではなく table に変換される"]'::jsonb, 0, '`CLOSE_ON_BLOCK` に含まれないタグは自動クローズされないため、`color` などは明示的な閉じタグまで継続する前提です。', 'https://developer.mozilla.org/en-US/docs/Web/API/MutationObserver', 'unpublished', false),
  (714, 'セクション: カスタムコード', '`<br>` 整理の副作用', '`collapseConsecutiveBRs` や `trimBRsAtBlockEdges` の副作用として考えるべきことはどれですか？', NULL, '["元の改行意図が変わる可能性がある", "Go API の JWT が失効する", "Firestore の rules が緩くなる", "`#__NUXT_DATA__` が削除される"]'::jsonb, 0, '連続 `<br>` やブロック端の `<br>` を削除するため、著者が意図した改行表現が変わる可能性があります。', 'https://developer.mozilla.org/en-US/docs/Web/API/MutationObserver', 'unpublished', false),
  (715, 'セクション: カスタムコード', '見落としうる更新', 'このコードが自動再変換を見落としやすい更新として正しいものはどれですか？', 'mo.observe(root, { childList: true, subtree: true });', '["`characterData` だけの差し替え", "子要素の追加", "子要素の削除", "DOM 全体の再描画"]'::jsonb, 0, '監視対象は `childList` であり、テキストノードの中身だけが書き換わる `characterData` の変化は自動再変換の対象外です。', 'https://developer.mozilla.org/en-US/docs/Web/API/MutationObserver', 'unpublished', false),
  (716, 'セクション: C++ Othello', 'flip の開始位置のバグ', 'Othello の `flip(Cursor position)` で修正すべきだった主なバグはどれですか？', NULL, '["盤面外チェックを完全に削除していた", "隣接マスではなく不適切な位置から反転を始めていた", "白石しか置けなかった", "`enum class cell` が存在しなかった"]'::jsonb, 1, '反転は置いた位置の隣接セルから始めるべきですが、元の処理では開始位置がずれており、正しく石がひっくり返らない原因になっていました。', 'https://en.cppreference.com/w/cpp/language', 'unpublished', false),
  (717, 'セクション: C++ Othello', 'canFlipInDirection の余計な前進', '`canFlipInDirection()` のバグとして修正された内容はどれですか？', NULL, '["方向の配列を 8 方向から 4 方向へ減らした", "余計に 1 マス進めてしまう処理を取り除いた", "盤面サイズを 8x8 から 10x10 へ変えた", "黒番と白番を逆にした"]'::jsonb, 1, '余計な前進があると `O -> O -> X` のような並びを正しく判定できず、合法手が見落とされる原因になっていました。', 'https://en.cppreference.com/w/cpp/language', 'unpublished', false),
  (718, 'セクション: C++ Othello', 'turn 切り替えの正しい位置', 'Othello の `turn = 1 - turn` を置く位置として正しいのはどれですか？', NULL, '["入力を受け取る前に毎回切り替える", "石を正しく置いて反転が成功した後に切り替える", "盤面表示の直前で切り替える", "ゲーム開始時に 1 回だけ切り替える"]'::jsonb, 1, '合法手が成立した後にだけ手番を切り替えないと、無効な操作でもターンが進んでしまいます。', 'https://en.cppreference.com/w/cpp/language', 'unpublished', false),
  (719, 'セクション: C++ Othello', '未実装の pass 判定', 'Othello の pass 処理を実装するために必要とされた補助関数の方向性として最も適切なのはどれですか？', NULL, '["`canPlaceAnywhere(int color)` のように盤面全体の合法手有無を調べる", "`memcpy` を 3 回呼ぶ", "`std::clock` を無効化する", "`__file__` を使う"]'::jsonb, 0, 'pass の判定には、現在の色で盤面のどこかに合法手があるかを広く確認する関数が必要という話になっていました。', 'https://en.cppreference.com/w/cpp/language', 'unpublished', false),
  (720, 'セクション: C++ 基礎', '`bool` を足せる理由の確認', '`count += field[y][x];` が成立する理由として正しいものはどれですか？', 'int count = 0;
count += field[y][x];', '["`bool` が演算時に 0/1 の整数へ暗黙変換されるから", "配列要素だけ特別に文字列化されるから", "`field` は本当は `double` 配列だから", "C++ では `+=` が比較演算だから"]'::jsonb, 0, 'C++ では `bool` を算術演算に使うと `true` は 1、`false` は 0 として扱われるため、生存セル数の加算に使えます。', 'https://en.cppreference.com/w/cpp/language', 'unpublished', false),
  (721, 'セクション: C++ 基礎', '`memcpy` の引数順の再確認', '`memcpy(field, nextField, sizeof field);` の意味として正しいものはどれですか？', 'memcpy(field, nextField, sizeof field);', '["`nextField` を `field` に配列全体サイズ分コピーする", "`field` を `nextField` にコピーする", "差分だけ自動更新する", "両方を `false` に初期化する"]'::jsonb, 0, '`memcpy` は `コピー先, コピー元, サイズ` の順なので、次世代盤面 `nextField` を現在盤面 `field` に上書きしています。', 'https://en.cppreference.com/w/cpp/language', 'unpublished', false),
  (722, 'セクション: Python REPL', 'REPL に `__file__` がない理由', 'Python の REPL で `__file__` が無い理由として正しいものはどれですか？', '>>> __file__
NameError: name ''__file__'' is not defined', '["REPL は特定のスクリプトファイルとして実行されていないから", "Python 3 で `__file__` が削除されたから", "REPL は文字列を使えないから", "`Path` を import していないから"]'::jsonb, 0, '`__file__` はスクリプト実行時にセットされる変数であり、REPL は特定ファイルに紐づかないため未定義です。', 'https://docs.python.org/3/tutorial/interpreter.html', 'unpublished', false),
  (723, 'セクション: Python REPL', 'クォート無しパスの解釈', 'REPL で `/home/user/script.py` をクォート無しで代入すると構文エラーになりやすい理由はどれですか？', '>>> file = /home/user/script.py', '["`/` が除算演算子として解釈されるから", "パス長が 255 文字を超えるから", "`file` が予約語だから", "REPL では代入が禁止だから"]'::jsonb, 0, 'クォートが無いと Python はそれを文字列ではなく式として読もうとし、`/` を除算演算子として扱います。', 'https://docs.python.org/3/tutorial/interpreter.html', 'unpublished', false),
  (724, 'セクション: Python ファイル操作', 'append モードの意味', '`open(''app.log'', ''a'')` の説明として正しいものはどれですか？', 'with open(''app.log'', ''a'', encoding=''utf-8'') as f:
    f.write(''started\n'')', '["先頭に追記するだけで新規作成はしない", "末尾に追記し、無ければ新規作成する", "必ず内容を空にしてから書く", "読み取り専用で開く"]'::jsonb, 1, '`a` は append モードで、既存ファイルの内容を残したまま末尾へ追記し、ファイルが無ければ作成します。', 'https://docs.python.org/3/tutorial/inputoutput.html#reading-and-writing-files', 'unpublished', false),
  (725, 'セクション: Python 上級', '`getrefcount` が 1 多い理由', '`sys.getrefcount(x)` が実際の参照数より 1 多く見える理由はどれですか？', 'import sys
lst = []
print(sys.getrefcount(lst))', '["関数に渡す時点で一時参照が 1 つ増えるから", "GC が必ず 1 を足すから", "グローバル変数は常に 2 倍表示されるから", "Windows だけの仕様だから"]'::jsonb, 0, '`getrefcount` に渡す引数そのものが一時的に参照されるため、表示値にはその分が 1 つ上乗せされます。', 'https://docs.python.org/3/reference/datamodel.html', 'unpublished', false),
  (726, 'セクション: Python 上級', '`argparse.SUPPRESS` の挙動', '`argparse.SUPPRESS` を既定値にした未指定引数はどうなりますか？', 'parser = argparse.ArgumentParser(argument_default=argparse.SUPPRESS)', '["必ず空文字列になる", "属性自体が Namespace に作られない", "必ず `None` になる", "自動で必須引数になる"]'::jsonb, 1, '`SUPPRESS` を指定すると、未指定の引数は `Namespace` 上に属性そのものが作られません。', 'https://docs.python.org/3/reference/datamodel.html', 'unpublished', false),
  (727, 'セクション: クイズ運用', '候補プールの役割', '`admin-web/src/data/quizzes.json` の役割として正しいものはどれですか？', NULL, '["本番 DB の唯一の正データ", "レビュー前の問題ストックを含む候補プール", "Docker イメージの脆弱性レポート", "Flutter の mock API"]'::jsonb, 1, '`admin-web/src/data/quizzes.json` は候補プールであり、下書きやレビュー中の問題を含むストックとして扱われます。', 'https://vite.dev/guide/assets#the-public-directory', 'unpublished', false),
  (728, 'セクション: クイズ運用', '新規問題の最初の追加先', '新しい問題を思いついたとき、最初に追加すべき場所として文書化されているのはどれですか？', NULL, '["`backend/seeds/quizzes.production.json`", "`admin-web/src/data/quizzes.json`", "PostgreSQL の `quizzes` テーブルへ直接 INSERT", "`web/src/data/quizzes.ts`"]'::jsonb, 1, 'ワークフローでは、新しい問題はまず候補プールである `admin-web/src/data/quizzes.json` に追加すると明記されています。', 'https://vite.dev/guide/assets#the-public-directory', 'unpublished', false),
  (729, 'セクション: クイズ運用', 'replace-mode sync の注意', '本番 seed の同期が replace-mode に近い運用であることの注意点はどれですか？', NULL, '["seed に無い問題が DB から消える可能性がある", "常に 9000 番台の ID に変換される", "画像ファイルしか同期できない", "Burp Scanner が自動起動する"]'::jsonb, 0, '本番用 JSON を元に差し替え同期する運用では、seed から外した問題が DB から消える可能性があり、取り扱いに注意が必要です。', 'https://vite.dev/guide/assets#the-public-directory', 'unpublished', false),
  (730, 'セクション: クイズ運用', 'production seed の意味', '`backend/seeds/quizzes.production.json` の位置づけとして正しいものはどれですか？', NULL, '["候補プールと同義で全問題を入れる", "本番採用が決まった問題だけを持つテンプレート", "フロントの CSS 変数ファイル", "Studio preview の route 一覧"]'::jsonb, 1, '`quizzes.production.json` は本番採用済みの問題だけを保持し、DB シード生成の入力として使われます。', 'https://vite.dev/guide/assets#the-public-directory', 'unpublished', false),
  (731, 'セクション: クイズ運用', '最終的な正データ', 'ユーザー配信に関する最終的な Single Source of Truth として説明されているものはどれですか？', NULL, '["`admin-web/src/data/quizzes.json`", "PostgreSQL の `quizzes` テーブル", "`quiz.md`", "`README.md`"]'::jsonb, 1, '文書では、最終的な正データは PostgreSQL の `quizzes` テーブルであり、管理画面からの CRUD もそこに対して行うと整理されています。', 'https://vite.dev/guide/assets#the-public-directory', 'unpublished', false),
  (732, 'セクション: クイズ運用', 'CI で lint される対象', 'リポジトリ検索から確認できた、CI で lint 対象になっている JSON として正しい組み合わせはどれですか？', NULL, '["候補プールと production seed の両方", "候補プールだけ", "production seed だけ", "どちらも lint されない"]'::jsonb, 0, '`.github/workflows/quiz-data.yml` では `admin-web/src/data/quizzes.json` と `backend/seeds/quizzes.production.json` の両方が lint 対象でした。', 'https://vite.dev/guide/assets#the-public-directory', 'unpublished', false),
  (733, 'セクション: クイズ運用', '9000 番台 ID の意図', '`web/src/data/quizzes.ts` 側で 9000 番台 ID が使われていた意図として最も自然なものはどれですか？', NULL, '["admin 側候補プールとの衝突回避", "Firebase の projectId を表すため", "Burp の拡張番号を表すため", "HTML 仕様で 9000 番台が推奨されるため"]'::jsonb, 0, '別管理のクイズセットと ID が衝突しないよう、高いレンジを使っていると読むのが自然です。', 'https://vite.dev/guide/assets#the-public-directory', 'unpublished', false),
  (734, 'セクション: セキュリティドキュメント', 'Burp Docker ガイドの方針', '`burp-suite-docker.md` の調整方針として正しいものはどれですか？', NULL, '["Docker 利用を最優先に強く推奨した", "ホストへの通常インストールを推奨し、VNC/X11 例は隠した", "Burp を w3af に置き換えた", "すべての説明を削除した"]'::jsonb, 1, 'Burp は GUI 前提の利用が多いため、Docker 内 GUI 実行よりもホストへの通常インストールを優先し、VNC/X11 例はコメントアウトする方針にしました。', 'https://owasp.org/www-project-web-security-testing-guide/', 'unpublished', false),
  (735, 'セクション: セキュリティドキュメント', 'w3af の記述で強調すべきこと', 'w3af のセットアップや脆弱性資料で繰り返し強調すべき注意として適切なのはどれですか？', NULL, '["メンテナンス低調で依存関係問題が起きやすいこと", "Windows 専用ツールであること", "必ず Firestore を読むこと", "React SPA に最適であること"]'::jsonb, 0, 'w3af はメンテナンス低調で依存関係の古さが課題なので、その注意点は資料でも明示しておく必要があります。', 'https://owasp.org/www-project-web-security-testing-guide/', 'unpublished', false),
  (736, 'セクション: セキュリティドキュメント', '多層防御の考え方', 'Docker を使うアプリのセキュリティを考えるとき、文書で推奨された多層防御の組み合わせとして最も適切なのはどれですか？', NULL, '["Hadolint / Trivy / Dockle と、ZAP / Burp を役割分担して使う", "Burp Suite だけで Dockerfile から本番 API まで全部見る", "w3af だけでイメージ CVE と SPA を同時に見る", "`grep_search` だけで脆弱性を断定する"]'::jsonb, 0, 'イメージ層・設定層は Trivy や Dockle、Web アプリ層は ZAP や Burp というように、階層ごとに専用ツールを分担させるのが推奨でした。', 'https://owasp.org/www-project-web-security-testing-guide/', 'unpublished', false),
  (737, 'セクション: セキュリティドキュメント', 'デプロイ後の自動スキャン担当', '多層防御の説明で、デプロイ後の Web アプリ自動スキャン担当として位置づけられていたツールはどれですか？', NULL, '["OWASP ZAP", "Hadolint", "Dockle", "Checkov"]'::jsonb, 0, 'ZAP はデプロイ後の Web アプリ層を自動スキャンする役割として位置づけられ、Burp は手動ペネトレーションテスト側に置かれました。', 'https://owasp.org/www-project-web-security-testing-guide/', 'unpublished', false),
  (738, 'セクション: セキュリティドキュメント', 'Blind 脆弱性に最も強い選択', '3 ツール比較で Blind 脆弱性の検出に最も強いと整理されたものはどれですか？', NULL, '["w3af", "OWASP ZAP", "Burp Suite Professional", "Hadolint"]'::jsonb, 2, 'Burp Suite Professional は Collaborator により Blind SQLi・Blind SSRF・Blind XXE など OOB 系の検出が最も強いと整理されました。', 'https://owasp.org/www-project-web-security-testing-guide/', 'unpublished', false),
  (739, 'セクション: Burp Suite', 'Community 版 Intruder の注意', 'Burp Suite Community 版の Intruder に関する注意として正しいものはどれですか？', NULL, '["速度制限がある", "完全に削除されている", "SQL しか送れない", "TLS を扱えない"]'::jsonb, 0, 'Community 版でも Intruder はありますが、速度制限があるため大規模ファジングには向きません。', 'https://portswigger.net/burp/documentation', 'unpublished', false),
  (740, 'セクション: Burp Suite', 'Collaborator が必要な理由', 'Burp Collaborator が Professional 版で重要になる理由として最も適切なのはどれですか？', NULL, '["CSS を minify するため", "OOB コールバックで Blind 系脆弱性を確認できるため", "Dockerfile を lint するため", "Node.js の型エラーを直すため"]'::jsonb, 1, 'Collaborator は外部コールバックを受けられるため、レスポンス差分が出ない Blind 系の脆弱性でも検出の証拠を取りやすくなります。', 'https://portswigger.net/burp/documentation', 'unpublished', false),
  (741, 'セクション: OWASP ZAP', 'パッシブとアクティブの違い', 'ZAP のパッシブスキャンとアクティブスキャンの違いとして正しいものはどれですか？', NULL, '["パッシブは通信観察中心、アクティブは攻撃リクエストを送る", "パッシブは Burp でしか使えない", "アクティブは HTML を読めない", "違いは出力形式だけ"]'::jsonb, 0, 'パッシブは既存通信を観察して危険設定などを見つけ、アクティブは実際に payload を送り込んで脆弱性を確かめます。', 'https://www.zaproxy.org/docs/', 'unpublished', false),
  (742, 'セクション: w3af', 'プラグインカテゴリ', 'w3af のプラグインカテゴリの組み合わせとして正しいものはどれですか？', NULL, '["crawl / audit / grep / infrastructure", "repeater / intruder / decoder / comparer", "lint / build / deploy / seed", "nuxt / pinia / vue / router"]'::jsonb, 0, 'w3af は `crawl`, `audit`, `grep`, `infrastructure`, `auth`, `output` などのカテゴリでプラグインを構成します。', 'https://docs.w3af.org/en/latest/', 'unpublished', false),
  (743, 'セクション: Burp Suite', 'Repeater の役割', 'Burp Repeater の説明として最も適切なのはどれですか？', NULL, '["単一リクエストを編集しながら繰り返し送る手動検証用ツール", "Docker イメージをスキャンするツール", "JWT を自動更新する cron", "React の router を生成する機能"]'::jsonb, 0, 'Repeater は 1 件のリクエストを細かく編集し、レスポンス差分を見ながら手動で脆弱性を検証するための機能です。', 'https://portswigger.net/burp/documentation', 'unpublished', false),
  (744, 'セクション: Burp Suite', 'Cluster bomb の意味', 'Intruder の `Cluster bomb` アタックタイプの説明として正しいものはどれですか？', NULL, '["1 パラメータだけに順番に payload を送る", "複数パラメータの payload 組み合わせを網羅する", "同じ payload を全パラメータへ同時適用する", "常に空 payload を送る"]'::jsonb, 1, 'Cluster bomb は複数パラメータに対する payload の組み合わせを広く試すアタックタイプです。', 'https://portswigger.net/burp/documentation', 'unpublished', false),
  (745, 'セクション: OWASP ZAP', 'Spider の進捗確認 API', 'ZAP REST API で Spider の進捗を確認するエンドポイントとして適切なのはどれですか？', NULL, '["`/JSON/spider/view/status/`", "`/JSON/repeater/view/status/`", "`/JSON/docker/view/status/`", "`/JSON/flutter/view/status/`"]'::jsonb, 0, 'Spider の進捗確認は `/JSON/spider/view/status/` で行い、scanId に対する 0〜100 の進捗を取得できます。', 'https://www.zaproxy.org/docs/', 'unpublished', false),
  (746, 'セクション: Firebase / Firestore', 'root collection 列挙が失敗した理由', 'Firestore の root collection 列挙がうまくいかなかった直接の理由として最も近いものはどれですか？', NULL, '["rules により root listing がブロックされたため", "Go コンパイラが古いため", "`#cms-body` が無いため", "Burp Collaborator が停止していたため"]'::jsonb, 0, '認証後でも root collection の列挙は rules によってブロックされ、そこから直接スキーマを一覧化することはできませんでした。', 'https://firebase.google.com/docs/firestore', 'unpublished', false),
  (747, 'セクション: Firebase / Firestore', 'preview project doc の経路', 'Studio preview `rROnBByYOA` の調査で到達した preview project document のパスとして正しいものはどれですか？', NULL, '["`projects/vHoFQ8fsGUnc3wY7aIef`", "`schemas/H360oksrGI5kZArZjdeb` だけ", "`contents/JQLBbWHMlfj2458RCq9e` だけ", "`web/src/data/quizzes.ts`"]'::jsonb, 0, '調査では preview に対応する project document が `projects/vHoFQ8fsGUnc3wY7aIef` と特定されました。', 'https://firebase.google.com/docs/firestore', 'unpublished', false),
  (748, 'セクション: Firebase / Firestore', 'route から content doc への対応', '`information/AiduBduv` の route が最終的に対応付けられた Firestore content document として正しいものはどれですか？', NULL, '["`projects/vHoFQ8fsGUnc3wY7aIef/schemas/H360oksrGI5kZArZjdeb/contents/JQLBbWHMlfj2458RCq9e`", "`projects/vHoFQ8fsGUnc3wY7aIef/schemas/000/contents/000`", "`projects/studio-7e371/contents/AiduBduv`", "`backend/seeds/quizzes.production.json`"]'::jsonb, 0, '最終的に route は特定の content document にマップされ、そのパスまで確認できました。', 'https://firebase.google.com/docs/firestore', 'unpublished', false),
  (749, 'セクション: Studio DOM', '`case` ページの本文コンテナの完全な形', '`case` ページで見つかった本文コンテナの selector として最も正しいものはどれですか？', NULL, '["`div#cms-body.richText.sd.appear`", "`main#cms-body.root`", "`article#cms-body.markdown`", "`p#cms-body.text`"]'::jsonb, 0, '実際に確認できた本文コンテナは `div#cms-body.richText.sd.appear` でした。', 'https://developer.mozilla.org/en-US/docs/Web/API/Document_Object_Model', 'unpublished', false),
  (750, 'セクション: Studio DOM', '`information` ページの本文相当コンテナ', '`information` ページで `#cms-body` の代わりに本文相当コンテナとして見つかったものはどれですか？', NULL, '["`div.richText.sd.appear`", "`canvas.comment-canvas`", "`script#__NUXT_DATA__`", "`meta[property=og:title]`"]'::jsonb, 0, 'ID は無くても、本文領域として機能していたのは `div.richText.sd.appear` でした。', 'https://developer.mozilla.org/en-US/docs/Web/API/Document_Object_Model', 'unpublished', false),
  (751, 'セクション: Studio DOM', '確認できたものとできないもの', '今回のブラウザ調査で確認できたものとして正しいのはどれですか？', NULL, '["表示中ページの DOM 構造や script/state の内容", "Studio 側の元 HTML ソースファイルそのもの", "ローカルファイルシステム上の Studio プロジェクト一式", "Burp Suite の未保存セッション"]'::jsonb, 0, 'ブラウザ上で確認できたのは、表示中ページの DOM や埋め込みスクリプト、state の内容であり、Studio 側の元ソースファイルそのものではありません。', 'https://developer.mozilla.org/en-US/docs/Web/API/Document_Object_Model', 'unpublished', false),
  (752, 'セクション: Studio DOM', '`#cms-body` 前後の役割差', '`case` ページにおける `#cms-body` 前後の役割差として最も適切なのはどれですか？', NULL, '["前は導入レイアウト、後は本文や下部導線への切り替え点になっている", "前後とも完全に同一の `<p>` 群だけで構成される", "前は Firestore、後は PostgreSQL を表す", "前後とも script タグだけで構成される"]'::jsonb, 0, '`#cms-body` の前はヘッダーや導入ブロックなどレイアウト中心、`#cms-body` 以降は本文、さらにその後は共通導線へ戻るという役割差が見えました。', 'https://developer.mozilla.org/en-US/docs/Web/API/Document_Object_Model', 'unpublished', false),
  (753, 'セクション: Studio DOM', '本文だけを狙う selector の意味', '擬似タグ変換コードで `#cms-body` のような selector に対象を限定する主な利点はどれですか？', NULL, '["ヘッダーやフッターなど本文以外を触らずに済む", "自動で Firestore rules を変更できる", "必ず Docker image CVE を取れる", "Burp Intruder の速度制限が消える"]'::jsonb, 0, '本文専用コンテナを起点にすれば、共通ナビや下部導線ではなく CMS 本文だけへ後処理を限定できます。', 'https://developer.mozilla.org/en-US/docs/Web/API/Document_Object_Model', 'unpublished', false),
  (754, 'セクション: Docker セキュリティ', '3 ツールで直接できないこと', 'OWASP ZAP・w3af・Burp Suite に共通して、直接は担当外と整理されたものはどれですか？', NULL, '["コンテナ上の Web アプリの HTTP 診断", "Docker イメージ自体の CVE スキャン", "セキュリティヘッダの確認", "React SPA の画面確認"]'::jsonb, 1, '3 ツールは Web アプリ層の診断には使えますが、Docker イメージ自体の CVE スキャンは Trivy など別ツールの役割です。', 'https://docs.docker.com/engine/security/', 'unpublished', false),
  (755, 'セクション: セキュリティツール比較', 'Blind 脆弱性に強い理由', 'Burp Suite Pro が Blind 脆弱性に強い理由として最も適切なのはどれですか？', NULL, '["すべての HTML を Markdown に変換するから", "Collaborator による OOB コールバック確認ができるから", "常に React Router を理解するから", "`__file__` を自動定義するから"]'::jsonb, 1, 'Blind 系はレスポンス差分が乏しいため、OOB コールバックを拾える Collaborator の存在が大きな差になります。', 'https://owasp.org/www-project-web-security-testing-guide/', 'unpublished', false),
  (756, 'セクション: セキュリティツール比較', 'CI/CD 自動化の向き不向き', 'Community 版 Burp と比べたとき、ZAP が CI/CD に向く主因はどれですか？', NULL, '["公式の自動化スクリプト群と Action が整っているから", "JWT Editor が標準搭載だから", "必ず gRPC を解読できるから", "SQLMap を内蔵しているから"]'::jsonb, 0, 'ZAP はコマンドライン・Docker・GitHub Actions の流れが整っており、Community 版 Burp より自動化に乗せやすいです。', 'https://owasp.org/www-project-web-security-testing-guide/', 'unpublished', false),
  (757, 'セクション: セキュリティツール比較', 'この構成での w3af の位置づけ', 'Go + React + Flutter + Docker の構成での w3af の位置づけとして最も適切なのはどれですか？', NULL, '["主役として全レイヤーを任せるべき", "Go API の直接スキャンに限定するのが現実的", "Flutter の CA 証明書導入専用に使う", "Docker イメージの SBOM 生成専用に使う"]'::jsonb, 1, 'w3af はこの構成すべてをカバーする主役ではなく、Go API の直接スキャンに用途を限定するのが現実的と整理されました。', 'https://owasp.org/www-project-web-security-testing-guide/', 'unpublished', false),
  (758, 'セクション: モバイル診断', 'ピンニング回避の代表例', 'Flutter アプリの証明書ピンニングをテスト環境で一時的に回避する代表例として挙がっていたものはどれですか？', 'frida -U -f com.example.myapp -l ssl_pinning_bypass.js --no-pause', '["Frida を使ったバイパス", "Hadolint の実行", "`memcpy` の書き換え", "`argparse.SUPPRESS` の指定"]'::jsonb, 0, 'モバイル診断では Frida を使ってテスト環境で一時的にピンニングを回避する方法が代表例として挙がっていました。', 'https://owasp.org/www-project-mobile-app-security/', 'unpublished', false),
  (759, 'セクション: モバイル診断', 'gRPC を扱うときの Burp 拡張', 'Flutter が gRPC を使う場合、Burp で protobuf を扱いやすくするために検討すべきものはどれですか？', NULL, '["gRPC 拡張", "Sequencer", "Comparer", "Retire.js"]'::jsonb, 0, 'Burp は標準でもある程度扱えますが、gRPC の protobuf を見やすくするには gRPC 拡張の導入が有効です。', 'https://owasp.org/www-project-mobile-app-security/', 'unpublished', false),
  (760, 'セクション: Go API 診断', 'CORS を手動検証する方法', 'Burp Repeater で Go API の CORS 設定を手動検証するときの基本操作として正しいものはどれですか？', 'Origin: https://evil.example.com', '["`Origin` ヘッダを変えてレスポンスの許可内容を確認する", "`Content-Length` を常に 0 にする", "`Host` を削除する", "`Transfer-Encoding: chunked` を必ず追加する"]'::jsonb, 0, 'CORS の過剰許可は、想定外 Origin を付けてレスポンスの `Access-Control-Allow-Origin` などを見ることで確認しやすくなります。', 'https://pkg.go.dev/net/http', 'unpublished', false),
  (761, 'セクション: Firebase / Firestore', 'データ欠損ではない根拠', '`information/AiduBduv` の空表示がデータ欠損でないと判断できた根拠として最も直接的なのはどれですか？', NULL, '["該当 Firestore ドキュメントの title/body が取得できた", "Docker Compose が起動した", "Burp Repeater が使えた", "`grep ''id''` で 663 まで見えた"]'::jsonb, 0, '最終的に対象 content document を特定し、その中に title/body が入っていることを確認できたため、データ欠損説は否定されました。', 'https://firebase.google.com/docs/firestore', 'unpublished', false),
  (762, 'セクション: Studio DOM', 'custom code 痕跡の評価', 'カスタムコードの痕跡についての回答として最も正確だったものはどれですか？', NULL, '["提示コードそのものを完全一致で発見した", "custom-code 統合の痕跡は見えたが、提示コード断片をそのまま特定したわけではない", "カスタムコードは一切入っていなかった", "Burp 拡張としてのみ存在した"]'::jsonb, 1, '公開ページには custom-code が組み込まれている痕跡がありましたが、提示された IIFE をそのままソース上で完全一致確認したわけではありません。', 'https://developer.mozilla.org/en-US/docs/Web/API/Document_Object_Model', 'unpublished', false),
  (763, 'セクション: Studio DOM', '今回の最終的な設計理解', '今回の調査から推測された、Studio 上のカスタム JavaScript 運用として最も自然なものはどれですか？', NULL, '["CMS 本文ブロックに id を付け、その要素を起点に後処理 JavaScript を当てる運用", "すべてのページで `body` 全体を毎回書き換える運用", "Firestore の rules をページごとに変える運用", "quiz データを Studio 本文に直接埋め込む運用"]'::jsonb, 0, '今回の差分を見ると、Studio 側で CMS 本文ブロックに安定した id を付け、その selector を起点に JavaScript の後処理を行う運用だったと考えるのが自然です。', 'https://developer.mozilla.org/en-US/docs/Web/API/Document_Object_Model', 'unpublished', false),
  (764, 'セクション: ANSIエスケープシーケンス', 'ANSIエスケープシーケンスとは', 'ANSIエスケープシーケンスの説明として最も正しいものはどれですか？', NULL, '["Windowsのみで動作するターミナル制御コードの規格である", "端末エミュレータに対してカーソル移動・色変更などの制御命令を埋め込む文字列で、`ESC`（0x1B）から始まる", "バイナリデータをテキスト形式にエンコードするための規格である", "C言語の標準ライブラリに定義された文字列操作関数の総称である"]'::jsonb, 1, 'ANSIエスケープシーケンスは、ANSI X3.64規格に基づく端末制御コードです。`\033`（ESCコード、0x1B）から始まり、カーソル移動・画面消去・文字色・背景色などを制御できます。Linux/macOSのターミナルでは広くサポートされており、`system("clear")` のように外部コマンドを呼ぶ必要がなく、移植性・安全性の面でも優れています。', 'https://man7.org/linux/man-pages/man4/console_codes.4.html', 'unpublished', false),
  (765, 'セクション: ANSIエスケープシーケンス', '画面クリアのエスケープシーケンス', 'ターミナルの画面全体を消去し、カーソルを左上（0,0）へ移動させる正しいエスケープシーケンスはどれですか？', 'std::cout << "???";', '["\\033[0m", "\\033[2J\\033[H", "\\033[1A\\033[2K", "\\033[31m"]'::jsonb, 1, '`\033[2J` が画面全体の消去（Erase in Display）、`\033[H` がカーソルを先頭行・先頭列へ移動（Cursor Position）するシーケンスです。組み合わせることで `system("clear")` と同等の動作をシェルを介さずに実現できます。`\033[0m` は属性リセット、`\033[1A` は1行上移動、`\033[31m` は赤色テキストです。', 'https://man7.org/linux/man-pages/man4/console_codes.4.html', 'unpublished', false),
  (766, 'セクション: ANSIエスケープシーケンス', 'system("clear") との違い', '`system("clear")` の代わりにANSIエスケープシーケンスを使う利点として誤っているものはどれですか？', '// Before
system("clear");

// After
std::cout << "\033[2J\033[H";', '["シェルプロセスを起動しないためオーバーヘッドが小さい", "POSIX環境であればシェルや外部コマンドに依存せず動作する", "Windowsのコマンドプロンプト（cmd.exe）でも追加設定なしに完全に動作する", "インジェクション攻撃の余地をなくせる"]'::jsonb, 2, 'ANSIエスケープシーケンスはLinux/macOSの端末エミュレータで広くサポートされています。しかしWindowsの古いコマンドプロンプトではデフォルトで無効であり、Windows 10以降のコンソールホストでは `SetConsoleMode` でVT処理を有効化するか、Windows Terminal等を使う必要があります。一方 `system("clear")` はシェルを介して `clear` コマンドを呼ぶためオーバーヘッドや、環境によっては外部コマンドの上書きによるインジェクションリスクがあります。', 'https://man7.org/linux/man-pages/man4/console_codes.4.html', 'unpublished', false),
  (767, 'セクション: ANSIエスケープシーケンス', 'CSIシーケンスの構造', '以下のシーケンス `\033[31;1m` を正しく解釈しているものはどれですか？', 'std::cout << "\033[31;1m" << "Error!" << "\033[0m";', '["カーソルを31行1列に移動する", "前景色を赤（31）かつ太字（1）に設定する", "31文字分右にカーソルを移動し、1行下げる", "31番のカラーパレットで背景色を塗りつぶす"]'::jsonb, 1, '`\033[` はCSI（Control Sequence Introducer）と呼ばれる接頭辞で、続くパラメータをセミコロンで区切ります。SGR（Select Graphic Rendition）コード `m` の場合、`31` は前景色を赤に、`1` は太字を意味します。`\033[0m` ですべての属性をリセットします。カーソル移動には `H`（Cursor Position）や `A/B/C/D` などの終端文字を使います。', 'https://man7.org/linux/man-pages/man4/console_codes.4.html', 'unpublished', false),
  (768, 'セクション: ANSIエスケープシーケンス', 'カーソル操作シーケンス', '現在のカーソル位置から1行上に移動し、その行全体を消去するシーケンスの正しい組み合わせはどれですか？', NULL, '["\\033[1B\\033[2K", "\\033[1A\\033[2K", "\\033[2J\\033[H", "\\033[1A\\033[0m"]'::jsonb, 1, '`\033[1A` はカーソルを1行上（Cursor Up）へ移動、`\033[2K` はカーソルのある行全体を消去（Erase in Line）します。`\033[1B` は1行下移動、`\033[2J` は画面全体の消去、`\033[0m` は属性リセットであり、行消去ではありません。プログレスバーやスピナーの上書き表示でよく使われるテクニックです。', 'https://man7.org/linux/man-pages/man4/console_codes.4.html', 'unpublished', false),
  (769, 'セクション: コマンドライン & grep', 'grep/ripgrep の単語境界検索', 'コマンド `rg -n "\ball\b" file.cpp` の実行結果として正しいものはどれですか？', '// file.cpp の内容:
// 70: int ball = 10;
// 71: void callback() {}
// 72: const char* all =
// 73: int small = 5;', '["70, 71, 72, 73 行目すべてがマッチする", "72 行目のみがマッチする", "70, 72, 73 行目がマッチする", "71, 72 行目がマッチする"]'::jsonb, 1, '`\b` は単語境界（word boundary）を意味する正規表現のメタ文字です。`\ball\b` は「all」という単語全体にのみマッチし、「ball」「callback」「small」のように他の文字と結合している場合はマッチしません。したがって 72 行目の `const char* all =` のみが該当します。ripgrep（rg）は grep の高速代替ツールで、`-n` オプションで行番号を表示します。', 'https://man7.org/linux/man-pages/man1/grep.1.html', 'unpublished', false),
  (770, 'セクション: Java XML DOM', 'setXmlStandalone(true) の意味', '`document.setXmlStandalone(true);` の説明として最も正しいものはどれですか？', 'Document document = builder.newDocument();
document.setXmlVersion("1.0");
document.setXmlStandalone(true);', '["XML文書が外部の定義ファイルに頼らず、単体で使えることを示す設定", "XML文書を自動的にファイルへ保存する設定", "XML文書の文字コードを UTF-8 に固定する設定", "XML文書のルート要素を自動的に作成する設定"]'::jsonb, 0, '`setXmlStandalone(true)` は、XML宣言の standalone を true として扱う設定です。ざっくり言うと、このXML文書は外部DTDなどの外部定義に頼らず、単体で意味を持つことを示します。ファイル保存、文字コード指定、ルート要素作成を行う設定ではありません。', 'https://docs.oracle.com/en/java/javase/21/docs/api/java.xml/org/w3c/dom/package-summary.html', 'unpublished', false),
  (771, 'セクション: Java XML DOM', 'DOMのルート要素 rootNode', '`Element rootNode = doc.createElement("data");` に相当する処理の説明として最も正しいものはどれですか？', 'Element rootNode = doc.createElement("data");
doc.appendChild(rootNode);', '["`data` という名前の要素を作り、XML文書の一番上の要素として追加する", "`data` という名前のXMLファイルを読み込む", "`rootNode` という名前のタグを自動的に出力する", "XML文書を `data` というファイル名で保存する"]'::jsonb, 0, '`createElement("data")` は `<data>` 要素を作る処理です。その要素を `doc.appendChild(rootNode)` で `Document` に追加すると、XML文書のルート要素になります。変数名の `rootNode` はタグ名ではなく、Java側でその要素を指すための名前です。', 'https://docs.oracle.com/en/java/javase/21/docs/api/java.xml/org/w3c/dom/package-summary.html', 'unpublished', false),
  (772, 'セクション: Java XML DOM', 'String.valueOf と XML の表示', '`String.valueOf(div.getId())` で文字列に変換しているのに、出力結果が `<id>1</id>` となり `"1"` のように表示されない理由として正しいものはどれですか？', 'Element idNode = createElement(document, "id", String.valueOf(div.getId()));

// 出力例
<id>1</id>', '["XMLの要素内容では文字列でも引用符を付けて表示しないため", "`String.valueOf` が失敗して、数値のまま出力されているため", "`setTextContent` は数値だけを受け取るメソッドのため", "`<id>` タグの中では Java の String 型を使えないため"]'::jsonb, 0, '`String.valueOf(div.getId())` によって Java 側では `1` が文字列の `"1"` になります。ただし XMLに出力されるとき、要素の本文は `<id>1</id>` のように表示され、Java の文字列リテラルを表す引用符は出ません。引用符が見えるのは Java コード上で文字列を書くときの表記であり、XMLのテキスト内容そのものではありません。', 'https://docs.oracle.com/en/java/javase/21/docs/api/java.xml/org/w3c/dom/package-summary.html', 'unpublished', false),
  (773, 'セクション: Python ファイル操作', 'os.makedirs(path, exist_ok=True) の意味', '`os.makedirs(path, exist_ok=True)` の説明として最も適切なのはどれですか？', 'import os
path = ''data/submit/''
os.makedirs(path, exist_ok=True)', '["指定パスのディレクトリを作成し、途中のディレクトリも必要に応じて作る。既に存在していてもエラーにしない", "指定パス内の既存ファイルをすべて削除してから新規作成する", "ディレクトリではなく空ファイルを作成する", "Windows でしか動作しない専用APIである"]'::jsonb, 0, '`os.makedirs()` はネストしたディレクトリをまとめて作成できます。`exist_ok=True` を付けると、対象ディレクトリが既に存在していても `FileExistsError` を出さずに処理を続行できます。', 'https://docs.python.org/3/tutorial/inputoutput.html#reading-and-writing-files', 'unpublished', false),
  (774, 'セクション: Jupyter とシェルコマンド', '! dir "data/submit/" の意味', 'Jupyter Notebook で `! dir "data/submit/"` を実行したときの説明として正しいものはどれですか？', '! dir "data/submit/"', '["Notebook からシェルコマンドを実行し、`data/submit/` 配下のファイル・フォルダ一覧を表示する", "Python の `dir()` 関数を呼び出して、変数 `data` の属性を表示する", "ディレクトリ `data/submit/` を新規作成する", "`data/submit/` 内の全ファイルを削除する"]'::jsonb, 0, 'Jupyter では行頭の `!` でシェルコマンドを実行できます。`dir` は Windows系でディレクトリ一覧を表示するコマンドのため、この記述は `data/submit/` の中身確認に使います。', 'https://docs.jupyter.org/en/latest/', 'unpublished', false),
  (775, 'セクション: Python ループ制御', 'continue の意味', 'for文の中で、現在の1回分の処理だけを飛ばして次の反復へ進みたい場合に使う文はどれですか？', 'for string in "Hello World!!":
    if string == "o":
        ____
    print(string)', '["`continue`", "`break`", "`return`", "`pass`"]'::jsonb, 0, '`continue` は現在の反復の残り処理をスキップし、最も内側のループの次の周期へ進みます。`break` はループ全体を終了するため、この場面では不適切です。', 'https://docs.python.org/3/tutorial/controlflow.html#for-statements', 'unpublished', false),
  (776, 'セクション: Python ループ制御', 'break の動作', '次のコードで `i == 2` になったときの `break` の動作として正しいものはどれですか？', 'for i in range(5):
    if i == 2:
        break
    print(i)', '["for文全体をその時点で終了する", "現在の1回分だけを飛ばして `i == 3` の処理へ進む", "`print(i)` だけを一時停止して後で再開する", "`i` を自動的に0へ戻す"]'::jsonb, 0, '`break` は最も内側のループを終了させます。この例では `i == 2` になった時点でfor文を抜けるため、`3` や `4` の反復には進みません。', 'https://docs.python.org/3/tutorial/controlflow.html#for-statements', 'unpublished', false),
  (777, 'セクション: Python イテレーション', 'for文とイテレーター', 'Pythonのfor文とイテレーターの関係として最も正しいものはどれですか？', 'for x in [10, 20, 30]:
    print(x)', '["for文は反復可能オブジェクトからイテレーターを取得し、次の値を順に取り出して処理する", "for文そのものが常に整数カウンターであり、必ず1ずつ加算される", "for文はリスト専用で、文字列や辞書には使えない", "for文では `next()` 相当の処理は行われない"]'::jsonb, 0, 'Pythonのfor文は、反復可能オブジェクトに対して内部的にイテレーターを使い、次の値を順に取り出して処理します。数値カウンターだけに限定されません。', 'https://docs.python.org/3/tutorial/controlflow.html#for-statements', 'unpublished', false),
  (778, 'セクション: Python 文字列フォーマット', '{:0>5} の意味', '`''{:0>5}''.format(''521'')` の結果として正しいものはどれですか？', 'code = ''{:0>5}''.format(''521'')
print(code)', '["`00521`", "`52100`", "`00000521`", "`521`"]'::jsonb, 0, '`{:0>5}` は、幅5になるように左側を `0` で埋めて右寄せする指定です。`''521''` は5桁に足りないため、左に0が2つ付いて `00521` になります。', 'https://docs.python.org/3/tutorial/inputoutput.html#formatted-string-literals', 'unpublished', false),
  (779, 'セクション: Python 文字列フォーマット', '.format() と変数の上書き', '次のコードの説明として正しいものはどれですか？', 'shinaCd = [''521'', ''522'', ''523'']
shinaCd = [''{:0>5}''.format(c) for c in shinaCd]', '["`.format()` が新しい文字列を返し、その結果のリストを同じ変数 `shinaCd` に再代入している", "`.format()` が元の文字列オブジェクトを直接変更している", "`shinaCd` は一度作ると再代入できない", "`format()` は数値にしか使えないため、このコードは必ず失敗する"]'::jsonb, 0, '文字列はイミュータブルなので `.format()` が元の文字列を直接変更するわけではありません。新しい文字列を返し、その結果で作ったリストを `shinaCd` に再代入しています。', 'https://docs.python.org/3/tutorial/inputoutput.html#formatted-string-literals', 'unpublished', false),
  (780, 'セクション: Python ネストしたループ', '全組み合わせを作る二重ループ', '`daily_list` 3件と `shinaCd` 3件の全組み合わせを作る処理として正しいものはどれですか？', 'daily_list = [''20191111'', ''20191112'', ''20191113'']
shinaCd = [''521'', ''522'', ''523'']
path = ''/daily/{daily}/{shinaCd}''', '["`for daily in daily_list:` の中で `for cd in shinaCd:` を回し、9件作成する", "`enumerate(daily_list)` で同じインデックスの `shinaCd` だけを使い、3件作成する", "`daily_list[0]` と `shinaCd[0]` だけを使い、1件作成する", "`zip(daily_list, shinaCd)` で3件だけ作れば必ず全組み合わせになる"]'::jsonb, 0, '全組み合わせが必要な場合は二重ループを使います。3日分と3コード分なら `3 * 3 = 9` 件になります。`enumerate` や `zip` で1対1に対応させると3件しか作れません。', 'https://docs.python.org/3/tutorial/controlflow.html#for-statements', 'unpublished', false),
  (781, 'セクション: Python ファイル操作', 'os.rename のリネーム先', '`test_b.txt` を `text_B.txt` にリネームする処理として正しいものはどれですか？', 'import os', '["`os.rename(''data/submit/test_b.txt'', ''data/submit/text_B.txt'')`", "`os.rename(''data/submit/test_b.txt'', ''data/submit/test_B.txt'')`", "`os.remove(''data/submit/test_b.txt'', ''data/submit/text_B.txt'')`", "`os.makedirs(''data/submit/text_B.txt'')`"]'::jsonb, 0, '問題文のリネーム先は `text_B.txt` です。`test_B.txt` ではファイル名が異なります。`os.rename(src, dst)` は第1引数に変更前、第2引数に変更後のパスを指定します。', 'https://docs.python.org/3/tutorial/inputoutput.html#reading-and-writing-files', 'unpublished', false),
  (782, 'セクション: Python while文', 'while True と break', '`input()` を繰り返し、`Finish` が入力されたら終了する処理として正しいものはどれですか？', NULL, '["`while True:` の中で `input()` を実行し、`name == ''Finish''` のとき `break` する", "`if name == ''Finish'': break` だけを単独で書く", "`While` とだけ書く", "`continue` を使えば必ず入力処理が終了する"]'::jsonb, 0, '繰り返し入力には `while True:` で無限ループを作り、終了条件に一致したとき `break` でループを終了する構造が必要です。`break` はループの外に単独では書けません。', 'https://docs.python.org/3/reference/compound_stmts.html#the-while-statement', 'unpublished', false),
  (783, 'セクション: Python 関数と真偽値', '素数判定の戻り値', '素数判定関数の戻り値として最も適切なのはどれですか？', 'def prime_number(num):
    # 素数なら ? を返す', '["真偽値の `True` / `False`", "文字列の `''true''` / `''false''`", "必ず整数の `1` / `0`", "戻り値は不要"]'::jsonb, 0, '問題文が「素数であればtrue、そうでなければfalseを戻り値として返す」としている場合、Pythonでは真偽値の `True` / `False` を返すのが自然です。文字列の `''true''` / `''false''` は真偽値ではありません。', 'https://docs.python.org/3/library/stdtypes.html#truth-value-testing', 'unpublished', false),
  (784, 'セクション: Python 素数判定', '平方根まで調べる理由', '素数判定で `while i * i <= num:` としている理由として正しいものはどれですか？', 'i = 2
while i * i <= num:
    if num % i == 0:
        return False
    i += 1', '["約数があるなら、その片方は必ず `num` の平方根以下にあるため", "`i * i <= num` と書かないとPythonではwhile文が使えないため", "すべての数を `num` まで調べるより常に結果が変わるため", "`i` を2ずつ増やすため"]'::jsonb, 0, '合成数は `a * b = num` と表せます。両方が平方根より大きいと積が `num` を超えるため、約数がある場合は少なくとも片方が平方根以下にあります。そのため平方根まで調べれば十分です。', 'https://docs.python.org/3/tutorial/controlflow.html#defining-functions', 'unpublished', false),
  (785, 'セクション: Python エラー理解', 'UnboundLocalError の原因', '次のエラー文の意味として最も正しいものはどれですか？

UnboundLocalError: cannot access local variable ''result'' where it is not associated with a value', 'def calc(x):
    if x > 0:
        result = x * 2
    return result

print(calc(0))', '["ローカル変数 `result` が値を持つ前に参照されたためエラーになっている", "`result` はグローバル変数でなければ使えないためエラーになっている", "`return` は if 文の外で使えないためエラーになっている", "`x` が整数なので `result` が自動的に未定義になるためエラーになっている"]'::jsonb, 0, 'このエラーは『ローカル変数 result に値が代入される前に参照した』ことを示します。例では `x <= 0` の場合に `result` が代入されないまま `return result` に到達するため発生します。', 'https://docs.python.org/3/tutorial/errors.html', 'unpublished', false),
  (786, 'セクション: Java 共通処理とユーティリティクラス', 'java.lang.Math と lang の意味', '`java.lang.Math` の説明として最も適切なのはどれですか？', 'double x = Math.sqrt(16);
int y = Math.max(3, 7);', '["`lang` は language の略で、`java.lang` はJavaの基本クラスを集めたパッケージである。`Math` は状態を持たない計算用のstaticメソッドを提供する", "`lang` は long の略で、`Math` はlong型専用の計算クラスである", "`Math` を使うには必ず `new Math()` でインスタンスを作る必要がある", "`java.lang` は通常のJavaコードでは必ず明示的にimportしなければ使えない"]'::jsonb, 0, '`java.lang` の `lang` は language の略です。`java.lang` には `String`、`Object`、`System`、`Math` などJavaの基本的なクラスが含まれ、通常は明示的にimportしなくても使えます。`Math.sqrt` や `Math.max` のような処理はオブジェクトの状態に依存しないため、staticメソッドとして提供されています。', 'https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/Math.html', 'unpublished', false),
  (787, 'セクション: Java 共通処理とユーティリティクラス', 'ユーティリティクラスをインスタンス化させない工夫', '次の `ValidationUtils` の設計意図として最も適切なのはどれですか？', 'public final class ValidationUtils {
    private ValidationUtils() {
    }

    public static boolean isEmpty(String value) {
        return value == null || value.length() == 0;
    }
}', '["`static` メソッドで使う共通処理クラスなので、`private` コンストラクタでインスタンス化を防ぎ、`final` で継承も防いでいる", "`private` コンストラクタを書くと `isEmpty` が自動的に高速化される", "`final` を付けると `isEmpty` の戻り値が常に同じ値に固定される", "`static` メソッドを使うには必ずクラスを `final` にしなければコンパイルできない"]'::jsonb, 0, 'ユーティリティクラスは `ValidationUtils.isEmpty(value)` のようにクラス名経由で `static` メソッドを呼び出して使うため、通常はインスタンスを作る必要がありません。そのため `private` コンストラクタで `new ValidationUtils()` を防ぎ、必要に応じて `final` を付けて継承も防ぐ設計がよく使われます。', 'https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/Math.html', 'unpublished', false),
  (788, 'セクション: Java 共通処理とユーティリティクラス', 'privateコンストラクタで例外を投げる理由', 'ユーティリティクラスの private コンストラクタで `throw new IllegalStateException("Utility class");` と書く目的として最も適切なのはどれですか？', 'public final class ValidationUtils {
    private ValidationUtils() {
        throw new IllegalStateException("Utility class");
    }

    public static boolean isEmpty(String value) {
        return value == null || value.length() == 0;
    }
}', '["クラス内部やリフレクションなどで万一コンストラクタが呼ばれた場合にも、インスタンス化を明確に失敗させるため", "`static` メソッドの戻り値を例外に変換するため", "`IllegalStateException` を書かないと `private` コンストラクタはコンパイルできないため", "`new ValidationUtils()` を外部から自由に呼べるようにするため"]'::jsonb, 0, '`private` コンストラクタだけでも通常の外部コードからの `new ValidationUtils()` は防げます。ただしクラス内部からコンストラクタを呼ぶコードを書いた場合や、リフレクションで呼び出された場合には到達し得ます。そこで `throw new IllegalStateException("Utility class")` を入れておくと、このクラスはインスタンス化するものではないという意図を明確にし、呼ばれた場合にも失敗させられます。', 'https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/Math.html', 'unpublished', false),
  (789, 'セクション: Java 共通処理とユーティリティクラス', 'ユーティリティクラス設計の基本セット', 'ユーティリティクラスを作るときの基本的な設計として、最も適切なのはどれですか？', 'public final class ValidationUtils {
    private ValidationUtils() {
        throw new IllegalStateException("Utility class");
    }

    public static boolean isEmpty(String value) {
        return value == null || value.length() == 0;
    }
}', '["`final class` で継承を防ぎ、`private` コンストラクタでインスタンス化を防ぎ、`public static` メソッドでクラス名から直接使えるようにする", "`abstract class` にして、すべての利用側クラスに必ず継承させる", "すべてのメソッドをインスタンスメソッドにして、毎回 `new` してから使う", "コンストラクタを `public` にして、どこからでも自由にインスタンス化できるようにする"]'::jsonb, 0, 'ユーティリティクラスはオブジェクトを作って状態を持たせるためのクラスではなく、関連する共通処理をまとめる置き場所として使います。そのため、`final class` で継承を防ぎ、`private` コンストラクタで `new` を防ぎ、`public static` メソッドで `ValidationUtils.isEmpty(value)` のように直接呼び出せる形にするのが基本です。', 'https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/lang/Math.html', 'unpublished', false),
  (790, 'セクション: Java import static', 'static import の使いどころ', 'Java の `import static` の説明として最も適切なのはどれですか？', 'import static java.lang.Math.sqrt;
import static org.junit.jupiter.api.Assertions.assertEquals;

double x = sqrt(4);
assertEquals(2, actual);', '["別クラスのstaticメソッドやstatic定数をクラス名なしで呼び出せる。JUnitのassert系やMathのような定番用途では便利だが、多用すると出所が分かりにくくなる", "通常のインスタンスメソッドをすべてstaticメソッドに変換するための機能である", "`import static` を使うと、対象クラスを継承したことになる", "`import static` は `java.lang.Math` 専用で、JUnitのメソッドには使えない"]'::jsonb, 0, '`import static` を使うと、`Math.sqrt(4)` を `sqrt(4)` のようにクラス名を省略して呼び出せます。JUnitの `assertEquals` など、1ファイル内で何度も使う定番メソッドではコードが読みやすくなることがあります。一方で業務ロジック系のstaticメソッドを多用すると、どのクラスのメソッドか分かりにくくなるため、使いどころを絞るのが一般的です。', 'https://docs.oracle.com/javase/tutorial/java/package/usepkgs.html', 'unpublished', false),
  (791, 'セクション: DBアクセスとパフォーマンス', 'N+1問題の意味', 'N+1問題の説明として最も適切なのはどれですか？', 'List<User> users = userRepository.findAll(); // 1回

for (User user : users) {
    List<Order> orders = orderRepository.findByUserId(user.getId()); // N回
}', '["一覧を1回取得したあと、一覧の件数N回ぶん追加問い合わせが発生し、合計N+1回のDBアクセスになってしまう問題", "ループが1回しか実行されないため、N件中1件だけ処理される問題", "必ずメモリ使用量がN+1バイトになる問題", "SQLを1回にまとめると必ず遅くなる問題"]'::jsonb, 0, 'N+1問題では、最初に一覧取得で1回、その後に各要素ごとの関連データ取得でN回の問い合わせが発生します。例えばユーザー100人に対して注文を1人ずつ取得すると、1 + 100 = 101回のDBアクセスになります。改善するには、ID一覧を使って関連データをまとめて取得するなど、問い合わせ回数を減らす設計にします。', 'https://www.postgresql.org/docs/current/performance-tips.html', 'unpublished', false),
  (792, 'セクション: DSL 基礎', 'DSLと汎用プログラミング言語の違い', 'DSLの説明として最も適切なのはどれですか？', 'SELECT name FROM users WHERE age >= 20;', '["特定のドメインに表現を寄せた言語やAPIで、扱える範囲を狭める代わりにその領域を簡潔に書ける", "JavaやC++のように、あらゆる処理を目的とする汎用プログラミング言語だけを指す", "コンパイルできない設定ファイルの総称である", "必ず独自の構文解析器を自作しなければDSLとは呼べない"]'::jsonb, 0, 'DSLはDomain-Specific Languageの略で、特定領域の問題を、その領域の語彙や構造で表現しやすくした言語やAPIです。SQLはデータ問い合わせという領域に特化しているため、代表的なDSLと見なせます。', 'https://martinfowler.com/books/dsl.html', 'unpublished', false),
  (793, 'セクション: DSL 基礎', '内部DSLの意味', '内部DSLの説明として最も適切なのはどれですか？', 'describe("User", () => {
  it("has a name", () => {
    expect(user.name).toBe("Taro");
  });
});', '["ホスト言語の文法の中で、特定ドメインを読みやすく書けるように設計されたAPIや記法", "ホスト言語とは完全に別の構文を持ち、必ず別ファイルで書く言語", "コンパイラ内部だけで使われ、利用者が直接書けない言語", "HTMLだけを生成するための専用言語"]'::jsonb, 0, '内部DSLは、JavaScriptやRubyなどのホスト言語の構文を使いながら、API名や構造を特定ドメイン向けに設計したものです。例の `describe`、`it`、`expect` はJavaScriptとして実行されますが、テスト仕様を自然に書ける内部DSLとして機能しています。', 'https://martinfowler.com/books/dsl.html', 'unpublished', false),
  (794, 'セクション: DSL 基礎', '外部DSLの意味', '外部DSLの説明として最も適切なのはどれですか？', '<component class="helper.printer" />', '["ホスト言語とは別の構文や別ファイルで書かれ、処理系に読み取られて特定ドメインの意味を持つもの", "Javaのメソッドチェーンだけで作るDSL", "プログラムの外部ネットワークに接続するためのDSL", "必ず実行時に機械語へ直接変換されるDSL"]'::jsonb, 0, '外部DSLは、ホスト言語の文法から独立した構文で書かれるDSLです。XML設定ファイルはXMLという汎用構文を使いつつ、タグ名や属性にアプリケーション固有の意味を与えることで外部DSLとして利用されます。', 'https://martinfowler.com/books/dsl.html', 'unpublished', false),
  (795, 'セクション: JSP と DSL', 'JSPは何を生成する技術か', 'JSPの説明として最も適切なのはどれですか？', '<h1>Hello, <%= name %></h1>', '["サーバー側で実行され、最終的にHTMLレスポンスを生成するサーバーサイドビュー技術", "ブラウザ上でJavaバイトコードを直接実行する技術", "Javaのクラスファイルを手書きするための構文", "SQLをHTMLへ変換するためだけのデータベース言語"]'::jsonb, 0, 'JSPはJavaサーバー側で処理され、HTMLなどのレスポンスを生成するビュー技術です。HTMLの中にJSP式やタグを埋め込み、実行時には値が展開されたHTMLがブラウザに返されます。', 'https://jakarta.ee/specifications/pages/', 'unpublished', false),
  (796, 'セクション: JSP と DSL', 'JSPとServletの関係', 'JSPとServletの関係として最も適切なのはどれですか？', 'JSP -> Servlet -> HTML response', '["JSPはサーバー上でServletのJavaコードへ変換・コンパイルされ、実行結果としてHTMLなどを返す", "ServletはJSPをブラウザで表示するためのCSSファイルである", "JSPはServletとは無関係で、常にブラウザだけで実行される", "JSPはJavaScriptへ変換され、Node.js上でのみ実行される"]'::jsonb, 0, 'JSPはそのまま単独で実行されるのではなく、JSPコンテナによってServletのJavaコードに変換され、コンパイル・実行されます。その結果としてHTMLなどのレスポンスが生成されます。', 'https://jakarta.ee/specifications/pages/', 'unpublished', false),
  (797, 'セクション: JSP と DSL', 'JSPを外部DSLとみなせる理由', 'JSPを外部DSLとみなせる理由として最も適切なのはどれですか？', '<p><%= user.getName() %></p>', '["Javaそのものの文法ではないJSP独自の構文でHTML生成を記述し、処理系がServletへ変換するため", "JSPはJavaのメソッドチェーンだけで実装されているため", "JSPはHTMLを一切扱わず、数値計算だけを行うため", "JSPはJavaとは無関係なOSコマンドだけで動くため"]'::jsonb, 0, '`<%= ... %>` のようなJSP構文は通常の `.java` ファイルとしては成立しません。Javaとは別のテンプレート構文でHTML生成を記述し、処理系がServletへ変換するため、JSPは外部DSL的なテンプレート言語と見なせます。', 'https://jakarta.ee/specifications/pages/', 'unpublished', false),
  (798, 'セクション: DSL 基礎', 'ホスト言語と内部DSL', '内部DSLにおけるホスト言語の説明として最も適切なのはどれですか？', 'app.get("/users", listUsers);
app.post("/users", createUser);', '["内部DSLが乗っている汎用言語のことで、例ではJavaScriptの文法内でルーティング定義を書いている", "外部DSLをHTMLへ変換するためだけの言語である", "DSLの利用者が絶対に触れられない非公開の言語である", "データベースサーバーだけで使われる言語である"]'::jsonb, 0, '内部DSLはホスト言語の構文の中に作られます。例の `app.get` や `app.post` はJavaScriptとして実行されるAPIですが、Webルーティングというドメインを読みやすく記述する内部DSL的な形になっています。', 'https://martinfowler.com/books/dsl.html', 'unpublished', false),
  (799, 'セクション: DSL 基礎', '内部DSLはその言語そのものではないのか', '内部DSLについての説明として最も適切なのはどれですか？', 'query.select("name").from("users").where("age > 20");', '["文法としてはホスト言語そのものだが、APIの語彙や構造が特定ドメイン向けに設計されているためDSLと呼べる", "ホスト言語の構文を使っている時点で、絶対にDSLとは呼べない", "内部DSLは必ずホスト言語より低水準の機械語で書く", "内部DSLはコメントとして書かれるため実行されない"]'::jsonb, 0, '内部DSLは構文上はホスト言語の通常コードです。ただし、メソッド名やチェーン構造を特定ドメインの語彙に寄せることで、利用者には小さな専用言語のように見えるインターフェースになります。', 'https://martinfowler.com/books/dsl.html', 'unpublished', false),
  (800, 'セクション: XML と外部DSL', 'XML設定ファイルがDSLになる条件', 'XML設定ファイルを外部DSLと見なせる理由として最も適切なのはどれですか？', '<bean id="printer" class="helper.Printer" />', '["XML構文を使いながら、`bean` や `class` などのタグ・属性にフレームワーク固有の意味を持たせているため", "XMLはJavaの予約語だけで構成されているため", "XMLファイルは必ずHTMLとしてブラウザに表示されるため", "XMLは数値計算専用の内部DSLであるため"]'::jsonb, 0, 'XML自体は汎用のマークアップ構文ですが、特定フレームワークが `bean`、`component`、`class` などのタグや属性に意味を与えると、その設定ファイルは外部DSLとして機能します。', 'https://www.w3.org/TR/xml/', 'unpublished', false),
  (801, 'セクション: DSL 基礎', '外部DSLと内部DSLの見分け方', '内部DSLと外部DSLの見分け方として最も適切なのはどれですか？', '// 内部DSL風
router.get("/users", handler);

// 外部DSL風
<route method="GET" path="/users" handler="handler" />', '["ホスト言語の文法内で書くなら内部DSL、独立した構文や別ファイルとして処理系に読ませるなら外部DSLと考えられる", "短いコードは内部DSL、長いコードは外部DSLである", "Webで使うものはすべて外部DSL、CLIで使うものはすべて内部DSLである", "コンパイルエラーが出るものだけが内部DSLである"]'::jsonb, 0, '内部DSLはホスト言語の文法を使って特定ドメインのAPIとして設計されます。一方、外部DSLはホスト言語の構文とは別の形式で書かれ、専用の処理系やパーサーに読み取られて意味を持ちます。', 'https://martinfowler.com/books/dsl.html', 'unpublished', false),
  (802, 'セクション: Rails ルーティング', 'match ''/todo/:id'' の意味', 'Railsのルーティング `match ''/todo/:id'', :to => ''todo#show''` の説明として最も適切なのはどれですか？', 'match ''/todo/:id'', :to => ''todo#show''', '["`/todo/123` のようなURLを `TodoController` の `show` アクションへ対応付ける", "`/todo/:id` という文字列だけに完全一致したとき、HTMLファイルを直接返す", "`todo#show` という名前のデータベーステーブルを作成する", "`id` というControllerクラスを `todo` アクションへ対応付ける"]'::jsonb, 0, '`/todo/:id` の `:id` は可変部分です。例えば `/todo/123` にアクセスすると `params[:id]` に `"123"` が入り、`todo#show`、つまり `TodoController` の `show` アクションへ処理が渡されます。', 'https://guides.rubyonrails.org/routing.html', 'unpublished', false),
  (803, 'セクション: Rails ルーティング', 'todo#show と Controller 名', 'Railsの `to: ''todo#show''` の `todo#show` が表すものとして最も適切なのはどれですか？', 'get ''/todo/:id'', to: ''todo#show''', '["`TodoController` クラスの `show` アクション", "`Todo` モデルの `show` カラム", "`show` コントローラの `todo` アクション", "`todo#show` というURLパスそのもの"]'::jsonb, 0, 'Railsのルーティングでは `#` の前がコントローラ名、後ろがアクション名です。`todo#show` は規約により `TodoController#show` を指します。Railsではコントローラ指定時に末尾の `Controller` は書きません。', 'https://guides.rubyonrails.org/routing.html', 'unpublished', false),
  (804, 'セクション: Rails ルーティング', ':id と params の関係', 'Railsのルーティング `/todo/:id` に対して `/todo/123` へアクセスした場合、`123` を取得する方法として最も適切なのはどれですか？', 'get ''/todo/:id'', to: ''todo#show''

class TodoController < ApplicationController
  def show
    # ここでURLのidを使う
  end
end', '["`params[:id]` で取得する", "`request[:todo]` で取得する", "`TodoController.id` で取得する", "`show.params` で取得する"]'::jsonb, 0, 'ルーティングの `:id` はパスパラメータです。`/todo/123` の `123` は `params[:id]` としてコントローラのアクション内から参照できます。値は通常文字列として渡されます。', 'https://guides.rubyonrails.org/routing.html', 'unpublished', false),
  (805, 'セクション: 表計算', '会員販売通番による最終販売日の検索', '会員管理シートのD4に最終販売日を求める式を入力します。列Hの会員販売通番は、上位4桁が会員番号、下位3桁が会員ごとの販売通番です。最も適切な式はどれですか？', 'IF(論理和(A4＝null,C4＝0),null, ここに入る式)

会員管理シート:
A列: 会員番号
C列: 販売回数
D列: 最終販売日

販売データシート:
A列: レシート番号
B列: 販売日
C列: 会員番号
H列: 会員販売通番', '["照合検索(A4,販売データ!C$2:C$9999,販売データ!A$2:A$9999)", "照合検索(A4,販売データ!C$2:C$9999,販売データ!B$2:B$9999)", "照合検索(A4*1000+1,販売データ!H$2:H$9999,販売データ!A$2:A$9999)", "照合検索(A4*1000+1,販売データ!H$2:H$9999,販売データ!B$2:B$9999)", "照合検索(A4*1000+C4,販売データ!H$2:H$9999,販売データ!A$2:A$9999)", "照合検索(A4*1000+C4,販売データ!H$2:H$9999,販売データ!B$2:B$9999)"]'::jsonb, 5, 'A4は式を入力している会員管理シートの会員番号、C4はその会員の販売回数です。`A4*1000+C4` によって、会員番号を上位4桁、販売回数を下位3桁にした会員販売通番を作ります。その値を販売データシートのH列から探し、一致した行のB列、つまり販売日を返すので、最終販売日を求められます。`販売データ!A$2:A$9999` を返す選択肢はレシート番号を返してしまうため不適切です。', 'https://developer.mozilla.org/en-US/docs/Web', 'unpublished', false),
  (806, 'セクション: 表計算', '表引きと照合一致による会員クラス判定', '会員管理シートのD4に会員クラスを求める式を入力します。次の式の b に入る組合せとして最も適切なものはどれですか？', 'IF(A4＝null,null,表引き(分類表!D$4:F$6, b))

会員管理シート:
A列: 会員番号
B列: 販売額合計
C列: 販売回数
D列: 会員クラス

分類表:
C4:C6: 販売回数の下限 0, 6, 12
D3:F3: 販売額合計の下限 0, 40000, 80000
D4:F6: 会員クラス表', '["照合一致(B4,分類表!C$4:C$6,1), 照合一致(C4,分類表!D$3:F$3,1)", "照合一致(B4,分類表!D$3:F$3,1), 照合一致(C4,分類表!C$4:C$6,1)", "照合一致(C4,分類表!C$4:C$6,1), 照合一致(B4,分類表!D$3:F$3,1)", "照合一致(C4,分類表!D$3:F$3,1), 照合一致(B4,分類表!C$4:C$6,1)"]'::jsonb, 2, '`表引き(範囲, 行番号, 列番号)` では、先に行番号、次に列番号を指定します。`D$4:F$6` は会員クラスを取り出す表本体です。行方向は販売回数で決まるため、会員管理シートのC4を分類表の`C$4:C$6`に照合します。列方向は販売額合計で決まるため、会員管理シートのB4を分類表の`D$3:F$3`に照合します。第三引数`1`は近似一致で、検索値以下の最大値の位置を返すため、販売回数や販売額を下限値の表でランク分けできます。', 'https://developer.mozilla.org/en-US/docs/Web', 'unpublished', false),
  (807, 'セクション: システム開発', 'システム開発の最初の工程', 'システム開発の最初の工程で行う作業として適切なものは何ですか？', NULL, '["各プログラムの内部構造を設計する", "現状の業務を分析し、システム要件を整理する", "サブシステムをプログラム単位に分割し、各プログラムの詳細を設計する", "ユーザーインターフェイスを設計する"]'::jsonb, 1, 'システム開発の最初の工程では、現状業務や利用者の要求を分析し、システムに必要な要件を整理します。プログラム内部構造の設計、プログラム単位への分割、ユーザーインターフェイス設計は、要件を明確にした後の設計工程で行います。', 'システム開発工程 / 要件定義', 'unpublished', false),
  (808, 'セクション: システム開発', '非機能要件の定義', '非機能要件の定義に該当するものはどれですか？', NULL, '["業務を構成する機能間の情報の流れを明確にする", "システム開発で利用する言語に合わせた開発基準、標準を作成する", "システム機能として実現する範囲を定義する", "他システムとの情報授受などのインターフェイスを明確にする"]'::jsonb, 1, '非機能要件は、システムが提供する個別機能そのものではなく、性能、信頼性、保守性、運用性、セキュリティ、開発標準などに関する要件です。開発で利用する言語に合わせた開発基準や標準の作成は、保守性や品質を支える非機能面の定義に該当します。情報の流れ、実現する機能範囲、他システムとのインターフェイスは、主に機能要件の定義に関係します。', 'システム開発工程 / 非機能要件定義', 'unpublished', false),
  (809, 'セクション: システム開発', '外部設計で顧客承認を受けるもの', 'システムの外部設計を完了させるとき、顧客から承認を受けるものはどれですか？', NULL, '["画面レイアウト", "システム開発計画", "物理データベース仕様", "プログラム流れ図"]'::jsonb, 0, '外部設計では、利用者から見える画面、帳票、入出力項目、外部インターフェイスなどを設計します。そのため、顧客が確認して承認する対象として適切なのは画面レイアウトです。システム開発計画は計画工程、物理データベース仕様やプログラム流れ図は内部設計や詳細設計に近い内容です。', 'システム開発工程 / 外部設計', 'unpublished', false),
  (810, 'セクション: システム開発', '外部設計と内部設計の説明', '内部設計および外部設計の説明のうち、正しいものはどれですか？', NULL, '["外部設計では、システムをいくつかのプログラムに分割し、内部設計ではプログラムごとのDFDを作成する", "外部設計ではデータ項目を洗い出して論理データ構造を決定し、内部設計では物理データ構造、データの処理方式やチェック方式などを決定する", "外部設計と内部設計の遂行順序は、基本計画における利用者の要求に基づいて決定される", "外部設計はコンピュータ側から見たシステム設計であり、内部設計は利用者側から見たシステム設計である"]'::jsonb, 1, '外部設計は、画面、帳票、フォームの入力項目、論理データ構造など、利用者から見える仕様を決める工程です。内部設計は、物理データ構造、バリデーションなどのチェック方式、データの処理方式、モジュール分割など、システム内部でどう実現するかを決める工程です。したがって、外部設計で論理的なデータ項目を整理し、内部設計で物理データ構造や処理方式、チェック方式を決める説明が正しいです。', 'システム開発工程 / 外部設計・内部設計', 'unpublished', false),
  (811, 'セクション: システム開発', 'ソフトウェア詳細設計書の役割', 'ソフトウェア詳細設計書に関する記述として、適切なものはどれですか？', NULL, '["システム結合テストのテスト仕様が含まれる", "設計書に基づいてプログラミングが実施される", "システム要件定義の終了を契機として作成が開始される", "将来のメンテナンス用として、単体テストが完了した後で完成させる"]'::jsonb, 1, 'ソフトウェア詳細設計書は、各プログラムやモジュールの処理内容、入出力、データ構造、ロジックなどを具体的に記述し、プログラミングのもとになる設計書です。システム結合テストの仕様はテスト仕様書の内容であり、詳細設計は通常、要件定義直後ではなく外部設計や内部設計の後に行います。また、単体テスト後ではなくプログラミング前に作成します。', 'システム開発工程 / ソフトウェア詳細設計', 'unpublished', false),
  (812, 'セクション: アジャイル開発', 'デイリースクラムの目的', 'アジャイル開発手法の一つであるスクラムで定義され、スプリントで実施するイベントのうち、毎日決まった時間に決まった場所で行い、開発チームの全員が前回からの進捗状況や今後の作業計画を共有するものはどれですか？', NULL, '["スプリントプランニング", "スプリントレトロスペクティブ", "スプリントレビュー", "デイリースクラム"]'::jsonb, 3, 'デイリースクラムは、スプリント中に毎日行う短いイベントで、開発者が進捗、今後の作業、課題などを共有し、スプリントゴールに向けた作業計画を調整します。決まった時間・場所で行うのが基本ですが、場所は物理的な会議室に限らず、リモート環境ではオンラインでも実施できます。スプリントプランニングは開始時の計画、スプリントレビューは成果物の確認、スプリントレトロスペクティブは進め方の振り返りです。', 'Scrum Guide / デイリースクラム', 'unpublished', false),
  (813, 'セクション: アジャイル開発', 'プロダクトオーナーの役割', 'スクラムチームにおけるプロダクトオーナーの役割として、最も適切なものはどれですか？', NULL, '["生み出されるプロダクトの価値を最大化するために、プロダクトバックログのアイテムを作成し、並び替える", "完成の定義を忠実に守ることにより品質を作りこみ、利用可能なインクリメントを完成させる", "スプリント計画を作成する", "チームのリーダーとして、自己管理型で機能横断型のチームのメンバーをコーチする"]'::jsonb, 0, 'プロダクトオーナーは、生み出されるプロダクトの価値を最大化する責任を持ち、プロダクトバックログの内容や優先順位を管理します。プロダクトバックログアイテムは、これから作る機能、改善、不具合修正、調査などの作業候補です。完成の定義を守って利用可能なインクリメントを完成させるのは主に開発者の役割です。スプリント計画はスクラムチーム全体で行い、実作業の計画は開発者が具体化します。自己管理型で機能横断型のチームを支援しコーチするのはスクラムマスターの役割です。', 'Scrum Guide / プロダクトオーナー', 'unpublished', false),
  (814, 'セクション: システム開発', 'DFDの表記方法', 'DFDの表記方法として、適切なものはどれですか？', NULL, '["2本の平行線は同期を意味し、名前は付けない", "円にはデータを蓄積するファイルの名前を付ける", "四角には、入力画面や帳票を表す名前を付ける", "矢印にはデータを表す名前を付ける"]'::jsonb, 3, 'DFD（Data Flow Diagram）は、データの流れを表す図です。矢印はデータフローを表すため、注文情報、顧客情報、請求データのようにデータを表す名前を付けます。円は処理、2本の平行線はデータストア、四角は外部実体を表します。したがって、矢印にデータを表す名前を付ける説明が適切です。', 'システム開発工程 / DFD', 'unpublished', false),
  (815, 'セクション: システム開発', 'E-R図の説明', 'E-R図に関する記述として、適切なものはどれですか？', NULL, '["関係データベースの表として実装することを前提に表現する", "管理の対象をエンティティおよびエンティティ間のリレーションシップとして表現する", "データの生成から消滅に至るデータ操作を表現する", "リレーションシップは業務上の手順を表現する"]'::jsonb, 1, 'E-R図（Entity-Relationship Diagram）は、データとして管理したい対象をエンティティ（実体）として表し、エンティティ同士の関係をリレーションシップとして表す図です。たとえば、顧客、商品、注文などがエンティティで、顧客が注文する、注文に商品が含まれる、といった関係がリレーションシップです。データ操作の流れや業務手順を表す図ではありません。', 'システム開発工程 / E-R図', 'unpublished', false),
  (816, 'セクション: システム開発', '状態遷移図が適したシステム', '設計するときに、状態遷移図を用いることが最も適切なシステムはどれですか？', NULL, '["月末及び決算時の棚卸資産を集計処理する在庫棚卸システム", "システム資源の日次の稼働状況を、レポートとして出力するシステム稼働状況報告システム", "水道の検針データを入力として、料金計算する水道料金計算システム", "設置したセンサの情報から、室内環境を最適に保つ温湿度制御システム"]'::jsonb, 3, '状態遷移図は、イベントや条件によって状態が変化するシステムの設計に適しています。温湿度制御システムでは、センサ情報に応じて通常運転、冷房中、暖房中、加湿中、除湿中、停止中、異常検知中などの状態が切り替わります。一方、棚卸集計、稼働状況レポート出力、料金計算は、主に集計処理や計算処理が中心であり、状態遷移図よりも処理フローやDFDなどの方が適しています。', 'システム開発工程 / 状態遷移図', 'unpublished', false),
  (817, 'セクション: システム開発', 'UMLアクティビティ図の説明', 'UMLにおける振る舞い図の説明のうち、アクティビティ図のものはどれですか？', NULL, '["ある振る舞いから次の振る舞いへの制御の流れを表現する", "オブジェクト間の相互作用を時系列で表現する", "システムが外部に提供する機能と、それを利用する者や外部システムとの関係を表現する", "一つのオブジェクトの状態がイベントの発生や時間の経過とともにどのように変化するかを表現する"]'::jsonb, 0, 'アクティビティ図は、処理や作業の流れ、つまりある振る舞いから次の振る舞いへの制御の流れを表すUMLの振る舞い図です。オブジェクト間の相互作用を時系列で表すのはシーケンス図、システムが提供する機能と利用者や外部システムとの関係を表すのはユースケース図、オブジェクトの状態変化を表すのは状態遷移図またはステートマシン図です。', 'システム開発工程 / UML アクティビティ図', 'unpublished', false),
  (818, 'セクション: システム開発', 'UML図の使い分け', 'UMLの図の使い分けとして、最も適切なものはどれですか？', NULL, '["処理や作業の流れに注目する場合はアクティビティ図を用いる", "処理や作業の流れに注目する場合はオブジェクト図を用いる", "ある時点のオブジェクトと関係に注目する場合はシーケンス図を用いる", "オブジェクト間のやり取りの時間順に注目する場合はクラス図を用いる"]'::jsonb, 0, 'アクティビティ図は、注文受付、在庫確認、支払い確認、出荷指示のような処理や作業の流れを表す図です。シーケンス図は、会員、ログイン画面、認証サービス、会員DBのようなオブジェクト間のやり取りを時間順に表します。オブジェクト図は、ある時点で存在するオブジェクトとその関係を表すスナップショットです。クラス図は、オブジェクトの設計図となる型や関係を表します。', 'システム開発工程 / UML 図の使い分け', 'unpublished', false),
  (819, 'セクション: システム開発', '業務フローを表すUML図', 'UML図のうち、業務要件定義において業務フローを記述する際に使用し、処理の分岐や並行処理、処理の動機などを表現できる図はどれですか？', NULL, '["アクティビティ図", "クラス図", "オブジェクト図", "シーケンス図"]'::jsonb, 0, 'アクティビティ図は、業務や処理の流れを表すUML図です。条件による分岐、複数処理の並行実行、開始や終了などを表現できるため、業務要件定義で業務フローを整理する用途に適しています。クラス図は構造、オブジェクト図はある時点の実体、シーケンス図はオブジェクト間のやり取りの時間順を表します。', 'システム開発工程 / UML アクティビティ図', 'unpublished', false),
  (820, 'セクション: システム開発', 'クラス図の長方形に記述する要素', 'UMLのクラス図において、クラスを表す長方形の中に記述するものとして、最も適切なものはどれですか？', NULL, '["クラス名、属性、操作", "アクター名、ユースケース名、関連", "開始状態、終了状態、遷移条件", "オブジェクト名、メッセージ、実行仕様"]'::jsonb, 0, 'クラス図では、クラスを長方形で表し、通常は上からクラス名、属性、操作を区画に分けて記述します。アクターやユースケースはユースケース図、状態や遷移は状態遷移図、メッセージの時間順はシーケンス図で扱います。', 'システム開発工程 / UML クラス図', 'unpublished', false),
  (821, 'セクション: システム開発', 'クラスとオブジェクトの関係', 'オブジェクト指向分析を用いてモデリングしたとき、クラスとオブジェクトの関係になる組はどれですか？', NULL, '["公園、ブランコ", "公園、代々木公園", "鉄棒、ぶらんこ", "中之島公園、代々木公園"]'::jsonb, 1, 'クラスは同じ性質を持つものを抽象化した型や概念であり、オブジェクトはその具体的な実体です。公園は概念としてのクラス、代々木公園は具体的な公園なのでオブジェクトに当たります。公園とブランコは全体と部品の関係、鉄棒とぶらんこは遊具の同列関係、中之島公園と代々木公園はどちらも具体的な公園です。', 'オブジェクト指向分析 / クラスとオブジェクト', 'unpublished', false),
  (822, 'セクション: システム開発', 'クラスとインスタンスの関係', 'オブジェクト指向におけるクラスとインスタンスとの関係のうち、適切なものはどれですか？', NULL, '["インスタンスはクラスの仕様を定義したものである", "クラスの定義に基づいてインスタンスが生成される", "一つのインスタンスに対して、複数のクラスが対応する", "一つのクラスに対してインスタンスはただ一つ存在する"]'::jsonb, 1, 'クラスは属性や操作などの仕様を定義する設計図のようなもので、インスタンスはそのクラスの定義に基づいて生成される具体的な実体です。インスタンスがクラスの仕様を定義するわけではありません。また、通常は一つのクラスから複数のインスタンスを生成できます。', 'オブジェクト指向分析 / クラスとインスタンス', 'unpublished', false),
  (823, 'セクション: ソフトウェアテスト', '同値分割と境界値分析のテストデータ数', '正数1〜1000を有効とする入力値について、1〜100の場合は処理Aを、101〜1000の場合は処理Bを実行する入力処理モジュールを、同値分割と境界値分析によってテストします。次の条件でテストするとき、テストデータの最小個数はいくつですか？

条件1: 有効同値クラスの1クラスにつき、1つの値をテストデータとする。ただし、テストする値は境界値ではないものとする。
条件2: 有効同値クラス、無効同値クラスのすべての境界値をテストデータとする。', NULL, '["6", "7", "8", "10"]'::jsonb, 2, '同値クラスは、無効な0以下、有効な1〜100、有効な101〜1000、無効な1001以上に分けられます。境界値は0、1、100、101、1000、1001の6個です。さらに、有効同値クラスごとに境界値ではない代表値を1つずつ選ぶため、1〜100から1個、101〜1000から1個を追加します。したがって、6個 + 2個 = 8個です。', 'ソフトウェアテスト / 同値分割・境界値分析', 'unpublished', false),
  (824, 'セクション: ソフトウェアテスト', '命令網羅と判定条件網羅の関係', '単一の入口を持ち、入力項目を用いた複数の判断を含むプログラムのテストケースを設計します。命令網羅と判定条件網羅の関係のうち、適切なものはどれですか？', NULL, '["判定条件網羅を満足しても命令網羅を満足しない場合がある", "判定条件網羅を満足するならば、命令網羅も満足する", "命令網羅を満足しなくても、判定条件網羅を満足する場合がある", "命令網羅を満足するならば、判定条件網羅も満足する"]'::jsonb, 1, '命令網羅は、プログラム中の各命令を少なくとも1回実行するようにテストする考え方です。判定条件網羅は、各判定の結果が真と偽の両方になるようにテストするため、分岐先の命令も実行され、結果として命令網羅も満たします。一方、命令網羅を満たしても、各判定の真と偽の両方を確認したとは限らないため、判定条件網羅を満たすとは限りません。', 'ソフトウェアテスト / ホワイトボックステスト', 'unpublished', false),
  (825, 'セクション: ソフトウェアテスト', 'ボトムアップテストの特徴', 'ボトムアップテストの特徴として、適切なものはどれですか？', NULL, '["開発の初期段階では移行作業が困難である", "スタブが必要である", "テスト済みの上位モジュールが必要である", "ドライバが必要である"]'::jsonb, 3, 'ボトムアップテストは、下位モジュールから順に結合してテストする方法です。下位モジュールを呼び出す上位モジュールがまだ完成していない場合があるため、呼び出し役となるドライバが必要です。スタブは、上位モジュールから先にテストするトップダウンテストで、未完成の下位モジュールの代わりに使います。', 'ソフトウェアテスト / 結合テスト', 'unpublished', false),
  (826, 'セクション: プロジェクトマネジメント', 'プロジェクト統合マネジメントの活動', 'プロジェクトマネジメントの活動には、プロジェクト統合マネジメント、プロジェクトスコープマネジメント、プロジェクトスケジュールマネジメント、プロジェクトコストマネジメントなどがあります。プロジェクト統合マネジメントの活動には、資源配分を決め、議論する目標や代替案のトレードオフを調整することが含まれます。システム開発プロジェクトにおいて、当初の計画にはない機能の追加を行う場合のプロジェクト統合マネジメントの活動として、適切なものはどれですか？', NULL, '["機能追加にかかる費用を見積り、必要な予算を確保する", "機能追加に対応するために、納期変更するか要員を追加するかを検討する", "機能追加のために必要な作業内容を明確にし、WBSを更新する", "機能追加のための所要期間を見積り、スケジュールを変更する"]'::jsonb, 1, 'プロジェクト統合マネジメントは、スコープ、スケジュール、コスト、資源などの複数の管理領域をまたいで調整し、全体として整合を取る活動です。機能追加に対応するために、納期を変更するか、要員を追加するかを検討することは、スケジュールと資源配分のトレードオフを調整する活動なので、プロジェクト統合マネジメントに該当します。費用見積りや予算確保はコストマネジメント、WBSの更新はスコープマネジメント、所要期間の見積りやスケジュール変更はスケジュールマネジメントの活動です。', 'プロジェクトマネジメント / プロジェクト統合マネジメント', 'unpublished', false),
  (827, 'セクション: プロジェクトマネジメント', '工数見積りと進捗遅れの超過工数', 'あるシステムを開発するための工数を見積もったところ150人月でした。現在までの投入工数は60人月で、出来高は全体の3割であり、進捗に遅れが生じています。今後も同じ生産性が続くと想定したときに、このシステムの開発を完了させるためには何人月の工数が超過しますか？', NULL, '["50", "90", "105", "140"]'::jsonb, 0, '全体の3割を完成させるために60人月を投入しているので、同じ生産性が続く場合の全体工数は 60人月 ÷ 0.3 = 200人月 です。当初見積りは150人月なので、超過工数は 200人月 - 150人月 = 50人月 になります。', 'プロジェクトマネジメント / 工数見積り・進捗管理', 'unpublished', false),
  (828, 'セクション: プロジェクトマネジメント', '実績生産性を用いた追加要員数', '10人が0.5kステップ/人日の生産性で作業するとき、30日間を要するプログラミング作業があります。10日目が終了した時点で作業が終了したステップ数は、10人の合計で30kステップでした。予定の30日間でプログラミングを完了するためには、少なくとも何名の要員を追加すればよいですか。ここで、追加する要員の生産性は現在の要員と同じとします。', NULL, '["2", "5", "10", "20"]'::jsonb, 2, '予定全体の作業量は 10人 × 30日 × 0.5kステップ/人日 = 150kステップ です。10日目終了時点の実績生産性は、30kステップ ÷ (10人 × 10日) = 0.3kステップ/人日 です。残作業は 150k - 30k = 120kステップ、残り期間は20日なので、実績生産性0.3kステップ/人日で完了するために必要な人数は 120k ÷ (20日 × 0.3k) = 20人 です。現在10人いるため、追加が必要な要員は 20人 - 10人 = 10人 になります。', 'プロジェクトマネジメント / 工数見積り・進捗管理', 'unpublished', false),
  (829, 'セクション: プロジェクトマネジメント', '設計・テスト工数を含む必要要員数', 'システムを構成するプログラムの本数とプログラム1本当たりのコーディング所要工数が表のとおりであるとき、システムを95日間で開発するには少なくとも何人の要員が必要ですか。ここで、システム開発にはコーディングのほかに、設計及びテストの作業が必要であり、それらの作業にはコーディング所要工数の8倍の工数がかかるものとします。', 'プログラム本数 | 1本当たりのコーディング所要工数
20本 | 1人日
10本 | 3人日
5本 | 9人日', '["4", "8", "9", "10"]'::jsonb, 2, 'コーディング工数は、20本 × 1人日 + 10本 × 3人日 + 5本 × 9人日 = 20人日 + 30人日 + 45人日 = 95人日 です。設計及びテストの工数はコーディング工数の8倍なので 95人日 × 8 = 760人日 です。総開発工数は 95人日 + 760人日 = 855人日 となり、95日間で開発するために必要な人数は 855人日 ÷ 95日 = 9人 です。', 'プロジェクトマネジメント / 工数見積り・要員計画', 'unpublished', false),
  (830, 'セクション: クラウドストレージ', 'OneDrive フォルダーの場所', 'Windows PC で OneDrive の同期フォルダーとして一般的に使われる場所はどれですか？', NULL, '["C:\\Windows\\OneDrive", "C:\\Users\\ユーザー名\\OneDrive", "C:\\Program Files\\OneDrive", "C:\\Users\\Public\\OneDrive"]'::jsonb, 1, 'Windows では、OneDrive の同期フォルダーは通常、各ユーザーのプロファイル配下に作成されます。一般的な場所は `C:\Users\ユーザー名\OneDrive` です。WSL から参照する場合は `/mnt/c/Users/ユーザー名/OneDrive` のようなパスになります。', 'Windows / OneDrive', 'unpublished', false),
  (831, 'セクション: フロントエンド開発環境', 'pnpm ストアキャッシュの扱い', 'Git 管理しているプロジェクトで、`services/admin-web/C:\Users\name\AppData\Local\pnpm\store\v3` のようなディレクトリが未追跡で大量生成されました。最も適切な対応はどれですか？', NULL, '["再現性のためにそのままコミットする", "package.json に追記して参照させる", "ローカルキャッシュなので削除し、必要なら ignore 設定を見直す", "node_modules と同様に毎回手動でリネームする"]'::jsonb, 2, 'pnpm のストアキャッシュは開発者ごとのローカル再利用データで、通常 Git で共有する対象ではありません。誤ってプロジェクト配下に生成された場合は削除し、`.npmrc` や環境変数の store-dir 設定を確認して再発防止します。', 'pnpm / store cache 運用', 'unpublished', false),
  (832, 'セクション: 日本語文法', '格助詞『が』の用法', '次のうち、格助詞『が』の説明として不適切なものはどれですか？', '例: 山がある。
例: 水がきれいだ。
例: 音楽が好きだ。', '["動作・存在・状態の主体（主語）を表す用法がある", "希望・好悪・能力などの対象を表す用法がある", "格助詞としては、文中で常に逆接（〜けれども）だけを表す", "同じ『が』でも、格助詞・接続助詞・終助詞などで機能が異なる"]'::jsonb, 2, '不適切なのは3です。逆接を表す『が』は主に接続助詞の用法であり、格助詞『が』には主体や対象を示す用法があります。例として『学習用アプリが改修。』は文として不自然で、通常は『学習用アプリを改修した。』または『学習用アプリが改修された。』のように表現します。', 'デジタル大辞泉（コトバンク）https://kotobank.jp/word/%E3%81%8C-2021137 / 精選版 日本国語大辞典（コトバンク）https://kotobank.jp/word/%E3%81%8C-456340', 'unpublished', false),
  (833, 'セクション: Python ループ制御', 'range の終端は含まれるか', '1 から n までの奇数をリストに入れたい。n 自身が奇数なら n も含める仕様のとき、次のコードの修正として最も適切なものはどれですか？', 'def odd_numbers(n):
    result = []
    for x in range(1, n):
        if x % 2 == 1:
            result.append(x)
    return result

print(odd_numbers(101))', '["`range(1, n)` のままでよい。101 も自動的に含まれる", "`range(1, n + 1)` にする。`range` の終端は含まれないため", "`range(0, n)` にする。0 から始めれば 101 も含まれる", "`range(1, n, 2)` にするだけで、どんな n でも必ず n 自身まで含まれる"]'::jsonb, 1, 'Python の `range(start, stop)` は `stop` を含みません。そのため `range(1, n)` では `n` は走査されず、`n = 101` のとき 101 は結果に入りません。『n 自身が奇数ならそれも含める』仕様なら、上限を 1 つ広げて `range(1, n + 1)` にする必要があります。なお `range(1, n, 2)` も終端は含まれないため、`n = 101` では 99 までしか出ません。', 'https://docs.python.org/3/tutorial/controlflow.html#the-range-function', 'unpublished', false),
  (834, 'セクション: npm workspaces', 'workspaces が指すもの', 'npm の workspaces が指す機能として最も適切なものはどれですか？', NULL, '["複数のローカルパッケージを、ルートの1つの package.json から管理する仕組み", "pnpm 専用のストアを共有する仕組み", "各パッケージに package-lock.json を必ず置く仕組み", "Docker コンテナ内だけで npm を使う仕組み"]'::jsonb, 0, 'npm の workspaces は、ルート（トップレベル）の1パッケージから、ローカルファイルシステム上の複数パッケージを管理する CLI 機能群です。`npm install` 時に入れ子のパッケージを自動でリンクし、手作業の `npm link` を不要にします。pnpm のストアや Docker とは別の話です。', 'https://docs.npmjs.com/cli/v11/using-npm/workspaces', 'unpublished', false),
  (835, 'セクション: npm workspaces', 'workspaces 欄の書き方', 'ルートの package.json で workspaces を有効にする書き方として正しいものはどれですか？', '{
  "name": "my-workspaces-powered-project",
  "workspaces": ["packages/a"]
}', '["`\"workspaces\": [\"packages/a\"]` のように、入れ子パッケージのパスを配列で書く", "`\"workspace\": true` を書けば配下の全ディレクトリが対象になる", "`\"private\": [\"packages/*\"]` が workspaces の宣言である", "`\"bundledDependencies\": [\"packages/a\"]` が workspaces の宣言である"]'::jsonb, 0, 'workspaces はルート `package.json` の `workspaces` プロパティで定義します。値は入れ子パッケージ（その中に `package.json` があるディレクトリ）へのパス配列です。`workspace: true` や `private` 配列、`bundledDependencies` では有効になりません。', 'https://docs.npmjs.com/cli/v11/using-npm/workspaces', 'unpublished', false),
  (836, 'セクション: npm workspaces', 'ルートの npm install の結果', 'ルートで workspaces を定義したあと、そのディレクトリで `npm install` したときの結果として正しいものはどれですか？', '.
+-- package.json
`-- packages
   `-- a
       `-- package.json', '["workspace がルートの node_modules にシンボリックリンクされ、package-lock.json はルートに1本できる", "各 workspace 配下に独立した package-lock.json が必須になる", "ルートの npm install では workspace は無視され、各ディレクトリで npm link が必要", "package.json の無いディレクトリ（Go や Flutter など）も自動で workspace になる"]'::jsonb, 0, '公式ドキュメントの例では、ルートで `npm install` すると `packages/a` が `node_modules/a` へシンボリックリンクされ、`package-lock.json` はルートに置かれます。入れ子 lockfile は不要です。workspace になるのは、パスが `workspaces` にあり、かつそのディレクトリに `package.json` があるパッケージだけです。', 'https://docs.npmjs.com/cli/v11/using-npm/workspaces', 'unpublished', false),
  (837, 'セクション: npm workspaces', 'workspace 文脈での npm run', 'ルートから、workspace `a` の `test` スクリプトを実行する公式の方法はどれですか？', 'npm run test --workspace=a', '["`npm run test --workspace=a`", "`npm test --prefix-all a`", "`pnpm i -w a`", "`npm workspaces run a test`"]'::jsonb, 0, 'ルートから特定 workspace のスクリプトを走らせるには `--workspace`（短縮 `-w`）を使います。例は `npm run test --workspace=a` です。`cd packages/a && npm run test` でも同じスクリプトが走ります。`pnpm i -w a` は依存追加の文脈で、この設問の実行方法ではありません。', 'https://docs.npmjs.com/cli/v11/using-npm/workspaces', 'unpublished', false),
  (838, 'セクション: TypeScript・VS Code', 'ワークスペース版 TypeScript の選択', '`tsconfig.json` で `allowImportingTsExtensions: true` を有効にしても、VS Code 上だけ TS5097 が表示されました。`.vscode/settings.json` には次の設定があり、コマンドラインの型検査は成功します。最も適切な対応はどれですか？', '{
  "js/ts.tsdk.path": "node_modules/typescript/lib"
}', '["`TypeScript: Select TypeScript Version` を実行し、`Use Workspace Version` を選択する", "`typescript.useWorkspaceTsdk: true` を `tsconfig.json` の `compilerOptions` に追加する", "`allowImportingTsExtensions` を `.vscode/settings.json` に移動する", "`noEmit: true` を削除して、VS Code に JavaScript を出力させる"]'::jsonb, 0, '`js/ts.tsdk.path` はワークスペース版 TypeScript の場所を VS Code に知らせますが、それだけでは使用版は切り替わりません。TypeScript ファイルを開いて `TypeScript: Select TypeScript Version` から `Use Workspace Version` を選択します。選択状態は TypeScript 拡張の内部 workspace state（`typescript.useWorkspaceTsdk`）に保存されるため、このキーを通常の `settings.json` や `tsconfig.json` に直接書く設定ではありません。', 'https://code.visualstudio.com/docs/typescript/typescript-transpiling#_using-the-workspace-version-of-typescript', 'unpublished', false),
  (839, 'セクション: SSH・ネットワーク', '外部ユーザー想定のSSH疎通確認', '次のコマンドを実行したところ、`external-test@52.196.241.106: Permission denied (publickey).` と表示されました。この結果の解釈として最も適切なものはどれですか？', 'ssh \
  -F /dev/null \
  -o UserKnownHostsFile=/tmp/quiz-external-known-hosts \
  -o StrictHostKeyChecking=accept-new \
  -o BatchMode=yes \
  -o PubkeyAuthentication=no \
  -o PasswordAuthentication=no \
  -o KbdInteractiveAuthentication=no \
  -o ConnectTimeout=10 \
  external-test@52.196.241.106 true', '["TCP 22への接続にも失敗しており、SSHサーバーとは通信できていない", "TCP 22とSSHサーバーへの到達には成功したが、有効な公開鍵を提示していないため認証で拒否された", "パスワード認証に成功したが、`true`コマンドの実行だけが失敗した", "SSH接続に成功し、`external-test`ユーザーとしてログイン済みである"]'::jsonb, 1, '`Permission denied (publickey)` は、対象のTCP 22へ接続してSSHプロトコルのやり取りを行った後、公開鍵認証を完了できずに拒否されたことを示します。このコマンドは `-F /dev/null` でユーザーのSSH設定を使わず、公開鍵・パスワード・キーボード対話認証も送らないため、外部の未認証ユーザーを想定した到達確認になります。ポートへ到達できない場合は、一般にタイムアウトまたは接続拒否になります。', 'https://man.openbsd.org/ssh', 'unpublished', false)
ON CONFLICT (id) DO UPDATE SET
  section = EXCLUDED.section,
  title = EXCLUDED.title,
  question = EXCLUDED.question,
  code = EXCLUDED.code,
  options = EXCLUDED.options,
  correct_answer_index = EXCLUDED.correct_answer_index,
  explanation = EXCLUDED.explanation,
  source = EXCLUDED.source,
  updated_at = NOW();

DELETE FROM quizzes WHERE NOT (id = ANY(ARRAY[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175, 176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207, 208, 209, 210, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220, 221, 222, 223, 224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236, 237, 238, 239, 240, 241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 252, 253, 254, 255, 256, 257, 258, 259, 260, 261, 262, 263, 264, 265, 266, 267, 268, 269, 270, 271, 272, 273, 274, 275, 276, 277, 278, 279, 280, 281, 282, 283, 284, 285, 286, 287, 288, 289, 290, 291, 292, 293, 294, 295, 296, 297, 298, 299, 300, 301, 302, 303, 304, 305, 306, 307, 308, 309, 310, 311, 312, 313, 314, 315, 316, 317, 318, 319, 320, 321, 322, 323, 324, 325, 326, 327, 328, 329, 330, 331, 332, 333, 334, 335, 336, 337, 338, 339, 340, 341, 342, 343, 344, 345, 346, 347, 348, 349, 350, 351, 352, 353, 354, 355, 356, 357, 358, 359, 360, 361, 362, 363, 364, 365, 366, 367, 368, 369, 370, 371, 372, 373, 374, 375, 376, 377, 378, 379, 380, 381, 382, 383, 384, 385, 386, 387, 388, 389, 390, 391, 392, 393, 394, 395, 396, 397, 398, 399, 400, 401, 402, 403, 404, 405, 406, 407, 408, 409, 410, 411, 412, 413, 414, 415, 416, 417, 418, 419, 420, 421, 422, 423, 424, 425, 426, 427, 428, 429, 430, 431, 432, 433, 434, 435, 436, 437, 438, 439, 440, 441, 442, 443, 444, 445, 446, 447, 448, 449, 450, 451, 452, 453, 454, 455, 456, 457, 458, 459, 460, 461, 462, 463, 464, 465, 466, 467, 468, 469, 470, 471, 472, 473, 474, 475, 476, 477, 478, 479, 480, 481, 482, 483, 484, 485, 486, 487, 488, 489, 490, 491, 492, 493, 494, 495, 496, 497, 498, 499, 500, 501, 502, 503, 504, 505, 506, 507, 508, 509, 510, 511, 512, 513, 514, 515, 516, 517, 518, 519, 520, 521, 522, 523, 524, 525, 526, 527, 528, 529, 530, 531, 532, 533, 534, 535, 536, 537, 538, 539, 540, 541, 542, 543, 544, 545, 546, 547, 548, 549, 550, 551, 552, 553, 554, 555, 556, 557, 558, 559, 560, 561, 562, 563, 564, 565, 566, 567, 568, 569, 570, 571, 572, 573, 574, 575, 576, 577, 578, 579, 580, 581, 582, 583, 584, 585, 586, 587, 588, 589, 590, 591, 592, 593, 594, 595, 596, 597, 598, 599, 600, 601, 602, 603, 604, 605, 606, 607, 608, 609, 610, 611, 612, 613, 614, 615, 616, 617, 618, 619, 620, 621, 622, 623, 624, 625, 626, 627, 628, 629, 630, 631, 632, 633, 634, 635, 636, 637, 638, 639, 640, 641, 642, 643, 644, 645, 646, 647, 648, 649, 650, 651, 652, 653, 654, 655, 656, 657, 658, 659, 660, 661, 662, 663, 664, 665, 666, 667, 668, 669, 670, 671, 672, 673, 674, 675, 676, 677, 678, 679, 680, 681, 682, 683, 684, 685, 686, 687, 688, 689, 690, 691, 692, 693, 694, 695, 696, 697, 698, 699, 700, 701, 702, 703, 704, 705, 706, 707, 708, 709, 710, 711, 712, 713, 714, 715, 716, 717, 718, 719, 720, 721, 722, 723, 724, 725, 726, 727, 728, 729, 730, 731, 732, 733, 734, 735, 736, 737, 738, 739, 740, 741, 742, 743, 744, 745, 746, 747, 748, 749, 750, 751, 752, 753, 754, 755, 756, 757, 758, 759, 760, 761, 762, 763, 764, 765, 766, 767, 768, 769, 770, 771, 772, 773, 774, 775, 776, 777, 778, 779, 780, 781, 782, 783, 784, 785, 786, 787, 788, 789, 790, 791, 792, 793, 794, 795, 796, 797, 798, 799, 800, 801, 802, 803, 804, 805, 806, 807, 808, 809, 810, 811, 812, 813, 814, 815, 816, 817, 818, 819, 820, 821, 822, 823, 824, 825, 826, 827, 828, 829, 830, 831, 832, 833, 834, 835, 836, 837, 838, 839]::bigint[]));

SELECT setval('quizzes_id_seq', COALESCE((SELECT MAX(id) FROM quizzes), 1), (SELECT COUNT(*) > 0 FROM quizzes));
