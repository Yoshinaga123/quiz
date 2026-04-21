-- Migration: seed quizzes from quizzes.production.json
-- Generated: 2026-04-11

INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source, status, push_enabled)
VALUES
  (1, 'セクション1: React & TypeScript ', 'useEffect 依存配列と関数参照', '以下のコードについて、最も正しい説明はどれですか？', 'const fetchUser = useCallback(async () => {
  const res = await fetch(`/api/users/${userId}`);
  const data = await res.json();
  setUser(data);
}, [userId]);

useEffect(() => {
  fetchUser();
}, [fetchUser]);', '["`fetchUser` を依存配列に入れると常に無限ループになる", "`useCallback` で `fetchUser` を安定化し、`[fetchUser]` を依存配列に入れると `userId` 変更時に再実行されるため `exhaustive-deps` の意図に沿う", "`useEffect(..., [])` にしても同じ挙動で、常に最新の `userId` を参照できる", "cleanup 関数は初回マウント前に必ず1回実行される"]'::jsonb, 1, '`fetchUser` は `useCallback(..., [userId])` により `userId` が変わると新しい参照になります。Effect 側を `[fetchUser]` にすると、結果として `userId` 変化に追従しつつ、依存関係を正しく宣言できます。`[]` にすると古い `userId` を閉じ込める（stale closure）リスクがあります。', 'React useCallback / useEffect / exhaustive-deps', 'unpublished', false),
  (2, 'セクション1: React & TypeScript ', '関数型コンポーネントの State 更新', '以下の useState の使用について、誤っているのはどれですか？', 'const [state, setState] = useState({ count: 0, name: "test" });
setState(prev => ({ ...prev, count: 1 }));', '["前のstate とマージしないと、name プロパティが失われる", "setState(() => prev) という書き方では前の値を参照できない", "setState は非同期で実行されるため、即座に state は更新されない", "setState 後、即座に console.log(state) を実行すると古い値が出力される"]'::jsonb, 1, 'setState(() => prev) は、setState に関数を渡す形式で、前の値を参照できる正しい書き方です。', 'React Official Documentation', 'unpublished', false),
  (3, 'セクション1: React & TypeScript ', 'TypeScript の Generic について', 'React コンポーネントで Generic を使う際、以下の記述で型推論が正しく機能するのはどれですか？', 'interface Props<T> {
  items: T[];
  onSelect: (item: T) => void;
}', '["T の型は自動推論される", "T extends { id: number } により、id プロパティを持つ型のみが使用可能", "props の型が正確に定義される", "すべてが正しい"]'::jsonb, 3, 'Generic を使うことで、型安全かつ柔軟なコンポーネント設計が可能になります。', 'TypeScript Handbook', 'unpublished', false),
  (4, 'セクション2: ビルドツール & Asset 管理', 'Vite での Asset 読み込み', '以下のファイル配置について、fetch(''/data.json'') でHTTPアクセス可能なのはどれですか？', '// 例1: public/data.json は HTTP で直接取得できる
const res = await fetch(''/data.json'');

// 例2: src/data/data.json は import で利用する（fetch での直アクセス前提ではない）
import localData from ''./data/data.json'';', '["src/data/data.json", "public/data.json", "dist/data.json", "いずれでも可能"]'::jsonb, 1, 'ソースコードから参照されないアセット、まったく同じファイル名を保つ必要があるアセット、または URL を得るためだけに最初に import したくないアセットは、プロジェクトルート配下の特別な `public` ディレクトリに置くことができます。このディレクトリ内のアセットは、開発時にはルートパス `/` で配信され、`dist` ディレクトリのルートへそのままコピーされます。`public` アセットは常にルート絶対パスで参照する必要があるため、`public/data.json` は `/data.json` として取得します。', 'https://vite.dev/guide/assets.html#the-public-directory', 'unpublished', false),
  (5, 'セクション2: ビルドツール & Asset 管理', 'src vs public 方式の使い分け', '動的にコンテンツを読み込みたい場合、最適な配置方式はどちらですか？', '// 複数の quiz.json from サーバー', '["src/data/ にすべてバンドル", "public/ フォルダに複数ファイル保存", "バックエンド API から取得", "TypeScript enum で定義"]'::jsonb, 2, 'Vite の `public` ディレクトリは、「ソースコードから参照されないアセット」「まったく同じファイル名を保つ必要があるアセット」「URL を得るためだけに import したくないアセット」を置くためのものです。一方で Fetch API は、「ネットワーク越しを含むリソースを取得するためのインターフェース」を提供します。したがって、内容が固定ファイルではなく動的に変わるコンテンツを読み込みたい場合は、`public` に複数 JSON を置くより、バックエンド API から取得する方が問題文の意図に合っています。', 'Vite Public Directory / MDN Fetch API', 'unpublished', false),
  (6, 'セクション2: ビルドツール & Asset 管理', 'モジュールと非モジュール読み込み', 'JSON を import vs fetch で読み込む場合の違いはどれですか？', 'import quizzes from ''./quizzes.json'';
const res = await fetch(''/api/quizzes.json'');', '["取得タイミングが異なる", "バンドルサイズが変わる", "ビルド時最適化が異なる", "すべて正しい"]'::jsonb, 3, 'import はビルド時に解析され、fetch は実行時に取得します。バンドルサイズと最適化方法が異なります。', 'Vite Guide', 'unpublished', false),
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
}', 'React Design Patterns', 'unpublished', false),
  (8, 'セクション3: コンポーネント設計', 'Controlled vs Uncontrolled Component', 'フォーム入力を React で管理する際、state で値を制御する方式の名称はどれですか？', '<input value={name} onChange={(e) => setName(e.target.value)} />', '["Uncontrolled Component", "Controlled Component", "Ref Component", "Form Component"]'::jsonb, 1, 'state で値を管理し、onChange で更新する方式が Controlled Component です。', 'React Forms', 'unpublished', false),
  (9, 'セクション3: コンポーネント設計', 'React.memo の使用シーン', 'React.memo でコンポーネントをラップする場合の効果はどれですか？', 'const MemoizedList = React.memo(ListComponent);', '["props が同じなら再レンダリングをスキップ", "必ずレンダリングスキップされる", "メモリ使用量が削減される", "TypeScript の型チェックが厳しくなる"]'::jsonb, 0, 'React.memo は props の浅い比較で再レンダリングをスキップします。', 'React Optimization', 'unpublished', false),
  (10, 'セクション4: 非同期処理パターン', 'Promise.all vs Promise.allSettled', '複数の API 呼び出しについて、全件の成功を待ち、1つでも失敗したら全体を reject したい場合に使うメソッドはどれですか？', 'Promise.all([fetch(url1), fetch(url2), fetch(url3)])', '["Promise.race", "Promise.all", "Promise.any", "Promise.allSettled"]'::jsonb, 1, 'Promise.all は、すべての入力 Promise が fulfill されたときにのみ fulfill され、1つでも reject されると即座に reject されます。一方 Promise.allSettled は、成功・失敗にかかわらずすべての Promise が settle するまで待ち、各結果を配列で返します。', 'Promise MDN', 'unpublished', false),
  (11, 'セクション4: 非同期処理パターン', 'async/await のエラーハンドリング', '複数の async 処理をシーケンシャルに実行し、エラーが発生した時点で停止する場合の書き方は？', 'try {
  const data = await fetchUser();
  const posts = await fetchPosts(data.id);
} catch (err) { ... }', '["Promise チェーン", "async/await + try/catch", "async/await + catch メソッド", "コールバック地獄"]'::jsonb, 1, 'async/await + try/catch は読みやすく、エラーハンドリングが容易です。', 'JavaScript Async', 'unpublished', false),
  (12, 'セクション5: TypeScript 型システム', 'Union Type vs Intersection Type', '以下の型定義について、値が持つべきプロパティはどれですか？', 'type A = { name: string; age: number };
type B = { email: string };
type Result = A & B;', '["name か email のいずれか", "name, age, email のすべて", "age のみ", "name のみ"]'::jsonb, 1, 'Intersection Type (A & B) は両方の型を『すべて』持つ必要があります。', 'TypeScript Advanced', 'unpublished', false),
  (13, 'セクション5: TypeScript 型システム', 'Partial と Required ユーティリティ型', 'すべてのプロパティをオプショナルにするユーティリティ型はどれですか？', 'type User = { name: string; age: number };
type OptionalUser = Partial<User>;', '["Required", "Partial", "Pick", "Record"]'::jsonb, 1, 'Partial<T> はすべてのプロパティをオプショナル（? がつく）に変換します。', 'TypeScript Utility Types', 'unpublished', false),
  (14, 'セクション5: TypeScript 型システム', 'keyof と Mapped Type', '`User` 型の各キーをそのまま使い、値の型だけをすべて `boolean` にした新しい型を作るには？', 'type User = { name: string; age: number };
type Flags = { [K in keyof User]: boolean };', '["Pick", "Omit", "Mapped Type", "Union"]'::jsonb, 2, '`keyof User` で `name | age` のようなキーのユニオン型を取り出し、`[K in keyof User]` で各キーを順にたどれます。そこで各プロパティの値の型を `boolean` に置き換えると、`{ name: boolean; age: boolean }` のような新しい型を作れます。これは Mapped Type の基本パターンです。

ユーザー目線で実現できる機能の例:
- プロフィール編集画面で、各項目が「編集中かどうか」を `name: true`, `age: false` のように管理できる
- バリデーション結果を、各入力欄ごとに「エラーあり / なし」で持てる
- 管理画面で、各列や各設定項目の ON/OFF 状態を元のデータ構造に合わせて安全に管理できる
- フォーム送信時に、どの項目を変更したか、どの項目を無効化するかを同じキー構造で扱える

つまり Mapped Type を使うと、元データと同じ項目構成を保ったまま、UI 用の状態や設定フラグを自動的に作れるため、画面機能を増やしても型のズレを減らせます。', 'TypeScript Handbook', 'unpublished', false),
  (15, 'セクション6: エラーハンドリング戦略', 'try/catch で複数エラー型を処理', 'fetch エラーと JSON parse エラーを区別する方法はどれですか？', 'try { ... } catch (err) { if (err instanceof SyntaxError) ... }', '["Error.message で文字列判定", "instanceof で型チェック", "err.code を参照", "手動で throw-catch"]'::jsonb, 1, 'instanceof はエラーの実際の型をチェックできます。', 'Error Handling Best Practices', 'unpublished', false),
  (16, 'セクション6: エラーハンドリング戦略', 'カスタムエラークラス', 'ビジネスロジック固有のエラーを表現するための推奨パターンは？', 'class ValidationError extends Error { constructor(msg) { super(msg); } }', '["Error を拡張してカスタムクラスを作成", "単なる Error を throw する", "文字列を throw する", "undefined を throw する"]'::jsonb, 0, 'Error を継承してカスタムクラスを作ることで、エラーの種類を明確にできます。', 'JavaScript Patterns', 'unpublished', false),
  (17, 'セクション7: パフォーマンス最適化', 'useMemo vs useCallback', '関数の参照を保持して再作成を避けたい場合に使用するフックはどれですか？', 'const memoizedCallback = useCallback(() => { doSomething() }, [dep]);', '["useMemo", "useCallback", "useRef", "useReducer"]'::jsonb, 1, 'useCallback は関数の参照を保持し、不必要な再作成を避けます。', 'React Hooks', 'unpublished', false),
  (18, 'セクション7: パフォーマンス最適化', 'バンドルサイズの最適化', '不要な npm パッケージを削除した際、最初に確認すべき項目はどれですか？', 'npm install @large/library  // 削除', '["ビルドファイルサイズ", "package.json の記録", "node_modules の削除", "すべて"]'::jsonb, 3, 'パッケージ管理、依存関係、ビルド出力のサイズ確認が重要です。', 'Build Optimization', 'unpublished', false),
  (19, 'セクション8: テスト戦略', 'ユニットテストの対象', 'React コンポーネントのテストで最優先すべき項目はどれですか？', '// テスト対象の優先順位', '["UI の見た目", "ユーザーの入力と出力", "内部実装の詳細", "CSS の正確性"]'::jsonb, 1, 'ユーザー視点での入出力と振る舞いをテストすることが重要です。', 'React Testing Library', 'unpublished', false),
  (20, 'セクション8: テスト戦略', 'マッチャーの選択', '要素が DOM に存在することをテストする場合の推奨マッチャーは？', 'expect(screen.getByText(''Hello'')).toBeInTheDocument();', '["toBeTruthy", "toBeInTheDocument", "toBeVisible", "toHaveLength"]'::jsonb, 1, 'toBeInTheDocument は DOM の存在を確認する明示的な方法です。', 'Jest Matchers', 'unpublished', false),
  (21, 'セクション9: API 統合パターン', 'CORS の仕組み', 'ブラウザから別オリジンの API にリクエストを送る際、サーバーが返すべきヘッダーはどれですか？', '// ブラウザ制限を回避するには', '["Access-Control-Allow-Origin", "Authorization", "X-API-Key", "Content-Type"]'::jsonb, 0, 'サーバーが Access-Control-Allow-Origin ヘッダーを返して CORS を許可します。', 'MDN CORS', 'unpublished', false),
  (22, 'セクション9: API 統合パターン', '認証トークンの管理', 'JWT トークンを localStorage に保存する方法の安全性は？', 'localStorage.setItem(''token'', jwtToken);', '["最も安全な方法", "XSS 攻撃のリスクあり", "完全に安全", "サーバー側のみで管理すべき"]'::jsonb, 1, 'localStorage は XSS 攻撃で奪われるリスクがあります。より安全な方法はタブ内のメモリや HttpOnly Cookie です。', 'OWASP HTML5 Security Cheat Sheet / JWT Cheat Sheet', 'unpublished', false),
  (23, 'セクション10: デバッグとロギング', 'console.log vs console.table', 'オブジェクト配列 `users` を DevTools 上で列形式で見やすく確認したい。`console.log(users)` の代わりとして最も適切なのはどれですか？', 'const users = [{id: 1, name: ''A''}, {id: 2, name: ''B''}];
console.log(users);', '["console.log", "console.table", "JSON.stringify", "alert"]'::jsonb, 1, 'console.table は配列のオブジェクトをテーブル形式で表示して可視化しやすくします。', 'Browser DevTools', 'unpublished', false),
  (24, 'セクション11: モジュールシステム', 'CommonJS vs ES Modules', '最新の JavaScript プロジェクトで推奨されるモジュールシステムはどれですか？', 'import { Component } from ''./component.js'';
const { Component } = require(''./component.js'');', '["CommonJS", "ES Modules", "どちらでも同じ", "環境に依存"]'::jsonb, 1, 'ES Modules は標準化され、ツールの最適化も充実しているため npm @latest では推奨されます。', 'ECMAScript 2015+', 'unpublished', false),
  (25, 'セクション11: モジュールシステム', 'デフォルトエクスポート vs 名前付きエクスポート', '複数の関数をエクスポートする場合、推奨するパターンはどれですか？', 'export const func1 = () => {};
export const func2 = () => {};', '["デフォルトエクスポート", "名前付きエクスポート", "どちらでも同じ", "別ファイルに分割"]'::jsonb, 1, '複数のエクスポートは名前付きエクスポートを使うことで、import する側が柔軟に選択できます。', 'ES6 Modules', 'unpublished', false),
  (26, 'セクション12: React StrictMode', 'StrictMode の役割', 'React.StrictMode は開発環境で何を行いますか？', '<React.StrictMode>
  <App />
</React.StrictMode>', '["エラーをキャッチして本番環境を保護", "不純な関数を検出して2回レンダリング", "パフォーマンスを向上させる", "バンドルサイズを削減"]'::jsonb, 1, 'StrictMode は意図しない副作用を検出するため、開発環境でコンポーネントを2回マウント・レンダリングします。', 'React.StrictMode', 'unpublished', false),
  (27, 'セクション12: React StrictMode', 'StrictMode による useEffect の重複実行', 'StrictMode で useEffect が異なる結果を返すコードはどれですか？', 'useEffect(() => {
  array.push(1);  // 破壊的変更
}, []);', '["純粋なデータ変換", "破壊的な変更（配列 push など）", "fetch による外部データ取得", "console.log による出力"]'::jsonb, 1, '配列の push などの破壊的な変更は、2回実行されると異なる結果になり、StrictMode で検出されます。', 'React StrictMode', 'unpublished', false),
  (28, 'セクション12: React StrictMode', 'StrictMode でハイライトされるバグ', 'useEffect の重複実行で検出される『不純な関数』の特徴はどれですか？', 'useEffect(() => {
  globalCounter++;  // グローバル変数変更
}, []);', '["入出力が確定している", "同じ入力なら同じ出力を返す", "外部状態を変更する", "すべてが A と B"]'::jsonb, 2, '不純な関数は外部状態を変更し、「同じ入力 → 異なる出力」となってバグの原因になります。', 'React.StrictMode', 'unpublished', false),
  (29, 'セクション12: React StrictMode', 'StrictMode による double-render の合図', 'DOMに値が2倍になって表示される場合、疑うべき関数の特徴は？', 'const Counter = () => {
  const [count, setCount] = useState(0);
  // レンダー結果を変更する処理が含まれている', '["fetch エラー", "破壊的な props", "不純なレンダー（pure でない関数）によるバグ"]'::jsonb, 2, '公式ドキュメントより：「Strict Mode calls some of your functions (only the ones that should be pure) twice in development.」不純な関数を早期に検出します。', 'React StrictMode', 'unpublished', false),
  (30, 'セクション12: React StrictMode', 'StrictMode での console エラー重複', 'StrictMode で console.error や console.warn が2回出力されるのはなぜですか？', 'useEffect(() => {
  console.warn(''Warning'');
}, []);', '["バグの報告がある", "不純な関数の検出のため2回実行", "メモリリークのサイン", "ネットワークエラーの再実行"]'::jsonb, 1, 'StrictMode はコンポーネントの2重実行で不純な関数を検出するため、console 出力も2回経験します。', 'React Strict Mode', 'unpublished', false),
  (31, 'セクション13: useEffect と副作用・データ取得パターン', 'useEffect の依存配列 [] の意味', '以下のコードで、空の依存配列 [] を指定した useEffect はどのタイミングで実行されますか？（本番挙動ベースで回答）', 'useEffect(() => {
  fetch(API_URL).then(res => res.json()).then(data => setCount(data.count));
}, []);', '["毎回のレンダリングのたびに実行される", "マウント時とアンマウント時だけに実行される", "マウント時だけ1回実行される", "state が更新されるたびに実行される"]'::jsonb, 2, '空の依存配列 [] は、Effect を初回マウント時に実行する意図を表します。本番ビルドでは通常1回です。なお開発環境で React StrictMode が有効な場合は副作用検出のために追加実行され、結果として2回観測されることがあります。', 'view-counter/frontend/src/components/ViewCounter.tsx', 'unpublished', false),
  (32, 'セクション13: useEffect と副作用・データ取得パターン', '外部データ取得を『副作用』と呼ぶ理由', '以下の説明の中で、『副作用（side effect）』の定義として最も正確なものはどれですか？', 'useEffect(() => {
  fetch(API_URL)
  .then(data => setCount(data.count));
}, []);', '["コンポーネントのレンダリング結果に直接反映されない処理", "レンダー関数内で実行されると問題が生じる処理（データ取得、イベントリスナー登録など）", "props や state に基づかない処理", "エラーを発生させる可能性のある処理"]'::jsonb, 1, '『副作用』とは、『コンポーネントの pure なレンダリングプロセスの外で実行される処理』を指します。これらをレンダー関数内で直接実行するとバグの原因になります。', 'React Official Documentation', 'unpublished', false),
  (33, 'セクション13: useEffect と副作用・データ取得パターン', 'useEffect に直接 async を書けない理由と cleanup', '以下のコードが推奨されていない理由は何ですか？', 'useEffect(async () => {
  const res = await fetch(API_URL);
  const data = await res.json();
  setCount(data.count);
}, []);', '["非同期処理のため、cleanup 関数が実行できなくなる", "async 関数は自動的に Promise を返すが、useEffect は関数かクリーンアップ関数の返却を期待しており、Promise の返却は型に矛盾するから", "useState の呼び出しが許可されないから", "fetch API は useEffect 内では使用禁止だから"]'::jsonb, 1, 'useEffect の第1引数は『関数 → (クリーンアップ関数 | undefined)』の型を期待しています。async 関数は必ず Promise を返すため、型が合致しません。正しいパターンは『内部に async 関数を定義して呼び出す』方式です。', 'view-counter/frontend/src/components/ViewCounter.tsx', 'unpublished', false),
  (34, 'セクション13: useEffect と副作用・データ取得パターン', 'fetch API と res.ok チェックの重要性', '以下のコードで res.ok を確認する理由は何ですか？', 'const res = await fetch(API_URL);
if (!res.ok) throw new Error(`HTTP error: ${res.status}`);
const data = await res.json();', '["fetch が失敗しても Promise は reject されず、HTTP エラーステータス（404, 500など）は成功値として返されるから", "res.json() 呼び出し時に必ず IOException が発生するから", "JSON パースエラーを事前に防ぐため", "TypeScript の型チェックで必須だから"]'::jsonb, 0, 'fetch API の重要な特性：『ネットワークエラーのみで Promise を reject する』。HTTP エラーステータスでも fetch は成功値を返すため、res.ok チェックが必須です。', 'view-counter/frontend/src/components/ViewCounter.tsx', 'unpublished', false),
  (35, 'セクション13: useEffect と副作用・データ取得パターン', 'TypeScript 型アサーション (as) の役割', '以下のコードで as ViewData を使用する理由は何ですか？', 'const data = (await res.json()) as ViewData;

type ViewData = {
  count: number;
};', '["res.json() は any 型を返し、TypeScript は data.count がどの型なのか推測できないため、開発者が『これは ViewData 型です』と明示する", "型アサーションで実行時のデータ検証が自動的に行われる", "as を使うことで fetch エラーが自動的にハンドルされる", "JSON のパース速度が向上する"]'::jsonb, 0, 'res.json() は Promise<any> を返します。型アサーション (as ViewData) は『このデータは ViewData 型である』と TypeScript コンパイラに通知し、型チェックを可能にします。ただし実行時のデータ検証は行われません。', 'view-counter/frontend/src/components/ViewCounter.tsx', 'unpublished', false),
  (36, 'セクション13: useEffect と副作用・データ取得パターン', 'try/catch でのエラーハンドリングと型ガード', '以下のコードで err instanceof Error を確認する理由は何ですか？', 'try {
  const data = (await res.json()) as ViewData;
  setCount(data.count);
} catch (err) {
  setError(err instanceof Error ? err.message : "Unknown error");
}', '["catch ブロックの err 変数は unknown 型であり、Error 型とは限らず、throw \"string\" や throw 123 などの任意の値も catch される可能性があるから", "await 式でのみ例外が発生し、それ以外では発生しないから", "catch で捕捉されたすべてのエラーは自動的に Error 型", "「型ガード」は TypeScript だけの機能で、JavaScript では無関係"]'::jsonb, 0, 'JavaScript では `throw new Error(...)` の他に、`throw "string"` や `throw 123` など任意の値を throw できます。そのため catch 時に `err instanceof Error` で検証し、堅牢な実装をします。', 'view-counter/frontend/src/components/ViewCounter.tsx', 'unpublished', false),
  (37, 'セクション14: CORS とセキュリティ', 'CORS エラーの原因特定', '以下のエラーが発生した原因として正しいものはどれですか？

Access to fetch at ''http://localhost:8080/api/views'' from origin ''http://localhost:5174'' has been blocked by CORS policy: The ''Access-Control-Allow-Origin'' header has a value ''http://localhost:5173'' that is not equal to the supplied origin.', '// Go バックエンド
w.Header().Set("Access-Control-Allow-Origin", "http://localhost:5173")

// フロントエンドは http://localhost:5174 で起動中', '["フロントエンドのコードに誤りがある", "バックエンドの CORS 許可オリジンが 5173 固定のため、5174 で起動した Vite からのリクエストが拒否された", "fetch の URL が間違っている", "ブラウザのキャッシュが原因"]'::jsonb, 1, 'CORS は『ブラウザが』リクエスト元のオリジン（プロトコル + ホスト + ポート）とサーバーが返す Access-Control-Allow-Origin を比較し、一致しない場合にブロックします。Vite は 5173 が使用中のとき自動的に 5174 に切り替えるため、固定値のままでは起動のたびに壊れます。', 'view-counter/backend/main.go', 'unpublished', false),
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

今回のケースは localhost 開発環境専用かつ Credentials なしのため実害はありませんが、本番コードに流用しないよう注意が必要です。', 'view-counter/backend/main.go', 'unpublished', false),
  (39, 'セクション15: フロントエンドアーキテクチャ選定', 'SPA / RSC / Astro の使い分け', '「徹底的なパフォーマンス最適化」を目指す場合、アーキテクチャ選定の基準として最も正確な説明はどれですか？', '// A: Vite + React SPA
// B: Next.js App Router (RSC)
// C: Astro (Islands Architecture)', '["RSC は常に最速なので、すべてのプロジェクトで採用すべき", "プロダクトの性質（コンテンツ駆動 vs インタラクション駆動）によって最適解は変わるため、銀の弾丸はない", "Astro は静的サイト専用で、動的コンテンツには使えない", "SPA はパフォーマンスが劣るため、現代では使うべきではない"]'::jsonb, 1, 'アーキテクチャ選定はユースケース依存です。

・SPA（Vite + React）: インタラクションが密なアプリ（クイズ、管理画面など）に適切
・RSC（Next.js）: データ取得が多くインタラクションが少ないコンテンツ駆動サイトで効果的。ライブラリがバンドルに含まれず転送量が削減される
・Astro（Islands）: ほぼ静的で一部だけインタラクティブなサイトに最適

「銀の弾丸はない」がアーキテクチャ設計の大原則です。', 'アーキテクチャ設計原則', 'unpublished', false),
  (40, 'セクション15: フロントエンドアーキテクチャ選定', 'React Server Components (RSC) の特徴', 'React Server Components (RSC) がクライアントバンドルサイズを削減できる理由はどれですか？', '// Server Component（サーバー側のみで実行）
async function ProductList() {
  const data = await db.query(...)  // DBに直接アクセス可
  return <ul>{data.map(...)}</ul>
}
// このコンポーネントで使ったライブラリはブラウザに送られない', '["コードを自動的に圧縮するから", "Server Components はサーバー側のみで実行され、そこで使ったライブラリはクライアントの JavaScript バンドルに含まれないから", "画像を自動的に最適化するから", "不要な CSS を削除するから"]'::jsonb, 1, 'Server Components はサーバー側でのみ実行されます。使ったライブラリ（例: 巨大な日付フォーマットライブラリ）はブラウザに一切送信されず、ネットワーク転送量を削減できます。

ただし Hydration がゼロになるわけではなく「選択的 Hydration」が正確な表現です。''use client'' がついた Client Components は従来通り Hydration されます。', 'React Server Components', 'unpublished', false),
  (41, 'セクション15: フロントエンドアーキテクチャ選定', 'クイズアプリに最適なアーキテクチャ', '今回開発しているクイズアプリ（ユーザーが問題を選択・回答し、リアルタイムでフィードバックを受ける）に最も適したアーキテクチャはどれですか？', '// クイズアプリの特性
// - 問題選択・回答 → state 管理が必要
// - 正解/不正解フィードバック → リアルタイムな UI 更新
// - 問題データは静的 JSON', '["Next.js (RSC): サーバー側レンダリングで SEO を最適化すべき", "Astro (Islands): 静的コンテンツが多いので Islands が最適", "Vite + React SPA: インタラクションが密でほぼ全域が動的なため SPA が素直に合う", "どれでも同じなので、チームの慣れで決めればよい"]'::jsonb, 2, 'クイズアプリはインタラクション駆動型の典型例です。

・問題の選択・回答・フィードバックはすべて state で管理
・ほぼ全域が動的なため Astro の Islands の旨味がない
・問題データが静的 JSON なので RSC の「DB直接アクセス」の恩恵も薄い

Vite + React SPA が最もシンプルで適切です。パフォーマンス改善が必要な場合は RSC より先に React.memo / useMemo / React.lazy（コード分割）を検討するのが現実的です。', 'フロントエンドアーキテクチャ選定', 'unpublished', false),
  (42, 'セクション16: パフォーマンス最適化の判断基準', '主張評価: 計測前提での最適化判断', '次の評価のうち、最も妥当なものはどれですか？

A. State Colocation 推奨
B. Zustand/Jotai 強推奨
C. Code Splitting 推奨', '// 前提: クイズアプリ (Vite + React SPA)
// 目的: パフォーマンス最適化方針の妥当性を評価する', '["A, B, C すべて無条件で正しい", "A は良い習慣だが前提条件が必要、B は計測なき最適化になりやすく注意、C は方向性は正しいが効果はアプリ規模に依存", "B だけが唯一正しく、まずグローバル状態管理ライブラリを導入すべき", "C は不要で、コード分割は現代のビルドツールなら自動で最適化される"]'::jsonb, 1, '実務では『計測なき最適化』を避けることが重要です。

・State Colocation: 不要な再レンダリング伝播が原因と確認できた場合に有効
・Zustand/Jotai: 共有状態の複雑化が実際にボトルネックになってから検討
・Code Splitting: 初期バンドルや LCP/INP の実測悪化がある場合に効果が出る

結論として、最適化施策は常に計測結果とアプリ規模を前提に採用判断する。', 'パフォーマンス最適化原則', 'unpublished', false),
  (43, 'セクション17: Go の並行処理と排他制御', 'sync.Mutex の英文読解', '次の Go 公式ドキュメントの英文から読み取れる `Mutex` の説明として、最も適切なものはどれですか？', 'A Mutex is a mutual exclusion lock.
The zero value for a Mutex is an unlocked mutex.
A Mutex must not be copied after first use.
Lock locks m. If the lock is already in use, the calling goroutine blocks until the mutex is available.', '["Mutex は最初から lock 済みで、コピーして使い回すことが推奨される", "Mutex は相互排他ロックで、初期状態は unlocked。すでに使用中なら利用可能になるまで goroutine は待機する", "Mutex は goroutine ごとの専用ロックで、Lock した goroutine 以外は Unlock できない", "Mutex は読み取り専用ロックなので、共有データの書き込み保護には向かない"]'::jsonb, 1, '`A Mutex is a mutual exclusion lock.` は「Mutex は相互排他ロックである」という意味です。つまり、同じ共有データに複数の goroutine が同時に入らないように制御します。`The zero value for a Mutex is an unlocked mutex.` は「初期値の Mutex は未ロック状態」という意味で、宣言直後から使えます。`A Mutex must not be copied after first use.` は「使い始めた後はコピーしてはいけない」という注意です。さらに `If the lock is already in use, the calling goroutine blocks until the mutex is available.` から、すでに誰かが Lock している間は、次の goroutine は利用可能になるまで待機すると読み取れます。', 'https://pkg.go.dev/sync#Mutex', 'unpublished', false),
  (44, 'セクション18: Docker Compose とビルド設定', 'failed to read dockerfile の原因と対処', '次のエラーが発生した。最も適切な原因と解決策の組み合わせはどれですか？

failed to solve: failed to read dockerfile: open Dockerfile: no such file or directory', '# 前提
# - docker-compose.yml の api に build: ./backend を指定
# - backend/ に Dockerfile は存在しない
# - 実行場所: vite-quiz-app/backend', '["原因: ポート 8080 が競合している。解決: ports を 8081:8080 に変更する", "原因: build コンテキスト内に Dockerfile がない。解決: Dockerfile を配置し、compose の build.context / dockerfile を正しいパスに合わせる", "原因: depends_on の順序が逆。解決: db を削除して api 単体起動にする", "原因: Vite が起動している。解決: npm run dev を停止すれば Dockerfile なしでもビルドできる"]'::jsonb, 1, 'このエラーは Docker がビルド時に Dockerfile を見つけられないときに発生します。`build: ./backend` は compose ファイルの配置位置を基準に解決されるため、意図と異なるディレクトリを参照することがあります。対策は (1) Dockerfile をビルドコンテキストに置く、(2) `build.context` と `build.dockerfile` を実ディレクトリ構成に合わせて明示する、の2点です。', 'Docker Compose Build Specification', 'unpublished', false),
  (45, 'セクション19: DB マイグレーション運用', '本番マイグレーションでの IF EXISTS/IF NOT EXISTS', 'CI/CD 前提の本番マイグレーションで、再実行可能性（冪等性）を高める方針として最も適切なのはどれですか？', '-- 例
DROP TABLE IF EXISTS temp_table;
CREATE TABLE IF NOT EXISTS users (...);', '["本番では失敗を早く検知するため、IF EXISTS は使わないのが常に正解", "本番では IF EXISTS / IF NOT EXISTS を適切に使い、アトミックかつリバーシブルなマイグレーションにする", "IF EXISTS は開発環境でのみ有効で、本番SQLでは無効", "IF EXISTS を使うとロールバック不能になるため禁止すべき"]'::jsonb, 1, 'モダンな CI/CD では、デプロイやロールバックの再試行可能性が重要です。`IF EXISTS` / `IF NOT EXISTS` は環境差分や途中失敗後の再実行でスクリプト全体のクラッシュを防ぎやすくし、冪等性の実装に寄与します。', 'MDN/各種Migrationベストプラクティス要約', 'unpublished', false),
  (46, 'セクション20: Flutter 実行環境トラブルシュート', 'No supported devices found の原因', '以下の実行で `No supported devices found with name or id matching ...` が出た。最も適切な対処はどれですか？', 'flutter run -d 8D8A5796-D4C7-4BB9-B135-
DBF87FC258BA --dart-define-from-file=dart-defines.json', '["UUID を途中改行で分断しない。Simulator を boot してから `flutter devices` で認識を確認する", "`--dart-define-from-file` を削除すれば必ずデバイス認識される", "`flutter run` の代わりに `npm run dev` を使う", "UUID は不要で、常に `-d ios` 固定が正解"]'::jsonb, 0, 'ログでは UUID が改行で分断され、`zsh: command not found` も発生しています。まず UUID を1行で渡し、必要なら `xcrun simctl boot <UUID>` と `open -a Simulator` 後に `flutter devices` で対象が見えることを確認します。', 'Flutter CLI / simctl 実行ログ', 'unpublished', false),
  (47, 'セクション21: Node.js 環境トラブルシュート', 'npm EACCES と root-owned cache', '`npm ERR! code EACCES` と `Your cache folder contains root-owned files` が出た場合の実務的な対処として最も適切なのはどれですか？', 'npm ERR! Your cache folder contains root-owned files ...
npm ERR! To permanently fix this problem, run: sudo chown -R ... ~/.npm', '["毎回 `sudo npm install` で実行し続ける", "案内された通り `.npm` キャッシュ所有者を現在ユーザーへ戻し、以後は通常ユーザーで npm を実行する", "node_modules を削除するだけで必ず解決する", "OS を再起動すれば再発しない"]'::jsonb, 1, '原因はキャッシュ配下の所有権不整合です。まず所有者を修正し、以後 `sudo npm` を常用しない運用へ戻すのが再発防止に有効です。', 'npm エラーメッセージ', 'unpublished', false),
  (48, 'セクション22: Docker Compose とビルド反映', 'docker compose up だけでは反映されない理由', 'Go アプリを Dockerfile で `go build -o server .` している構成で、`main.go` に `fmt.Printf(...)` を追加したのに `docker compose logs api` に出ない。最も適切な説明と対処はどれですか？', 'FROM golang:1.26-alpine AS build-env
COPY . /app
WORKDIR /app
RUN go mod download
RUN go build -o server .

FROM alpine:3.19
COPY --from=build-env /app/server /app/server
CMD ["./server"]', '["`fmt.Printf` は Docker では常に捨てられるので、`log.Printf` に変えない限り `docker compose logs` には出ない", "既存コンテナは以前ビルドした `server` バイナリを実行している。ソース変更を反映するには `docker compose up --build` でイメージを再ビルドする", "`docker compose up` は毎回自動で再ビルドするが、Go の `runtime.NumCPU()` だけはログ出力されない", "PostgreSQL の checkpoint ログが大量に出ると API ログは非表示になるため、db コンテナを停止してから起動する"]'::jsonb, 1, 'この構成ではコンテナ内で実行されるのはソースコードではなく、ビルド済みの `server` バイナリです。`main.go` を編集しても既存イメージや既存コンテナには自動反映されません。`docker compose up --build` あるいは `docker compose build` 後に再起動して、最新ソースからバイナリを作り直す必要があります。`fmt.Printf` 自体は標準出力に出るため、再ビルド後であれば `docker compose logs api` で確認できます。', 'Docker Compose / Dockerfile build behavior', 'unpublished', false),
  (49, 'セクション23: air による Go 開発環境', 'air で自動再起動させるための条件', 'Go API を Docker 上で `air` により自動再起動させたい。最も適切な構成はどれですか？', 'services:
  api:
    build:
      context: .
      target: dev
    volumes:
      - .:/app
    command: ["air", "-c", ".air.toml"]', '["本番用のビルド済みバイナリを実行するだけでよく、ソースコードの volume mount も `air` 設定も不要", "`air` をコンテナ内に入れ、ソースコードを volume mount し、`air` を PID 1 として起動する", "PostgreSQL コンテナに `air` を入れれば、`api` コンテナも自動で再起動する", "`docker compose logs -f api` を開いておけば、ファイル変更時に自動再起動される"]'::jsonb, 1, '`air` はファイル監視ツールなので、監視対象のソースコードがコンテナ内から見えている必要があります。そのため、開発用コンテナには `air` のインストール、ソースコードの bind mount、`air` を起動コマンドにする設定が必要です。単にビルド済みバイナリを実行するだけの構成では自動再起動されません。', 'air / Docker Compose development setup', 'unpublished', false),
  (50, 'セクション23: air による Go 開発環境', 'air.toml の root と tmp_dir の意味', '次の `air` 設定について、`root` と `tmp_dir` の説明として最も適切なのはどれですか？', 'root = "."
tmp_dir = "tmp"

[build]
cmd = "go build -o ./tmp/server ."
entrypoint = "./tmp/server"
include_ext = ["go"]
exclude_dir = ["tmp"]', '["`root` は Go module 名、`tmp_dir` は Docker volume 名である", "`root` は `air` が監視とビルドの基準にする作業ディレクトリ、`tmp_dir` は再ビルド時の一時成果物を置くディレクトリである", "`root` は実行バイナリ名、`tmp_dir` は PostgreSQL のデータ保存先である", "`root` は常に `/` 固定で、`tmp_dir` は指定しても無視される"]'::jsonb, 1, '`root` は `air` がプロジェクトの基準ディレクトリとして扱う場所です。この例では `.` なので、`air` を起動した現在ディレクトリを基準に監視・ビルドします。`tmp_dir` は再ビルドした実行ファイルなどの一時ファイル置き場で、この設定では `./tmp` 配下が使われます。', 'air configuration semantics', 'unpublished', false),
  (51, 'セクション23: air による Go 開発環境', 'air の build 設定と typo の見分け方', '次の設定断片を見たときの判断として最も適切なのはどれですか？', '[build]
cmd = "go build -o ./tmp/server ."
bin = "./tmp/server ."
include_ext = ["go"]
exclude_dir = ["tmp"]', '["`bin` の値に余分な ` .` が入っており不自然で、実行パス指定として typo を疑うべきである", "`bin = \"./tmp/server .\"` は Go の標準的な書き方で、末尾の `.` は必須である", "`cmd` の `go build` は不要で、`air` はソースコードを直接実行するため常に `bin` だけあればよい", "`exclude_dir = [\"tmp\"]` を入れると `cmd` は実行されなくなる"]'::jsonb, 0, '`cmd` の末尾の `.` は `go build` のビルド対象として自然ですが、`bin` や実行パスに `./tmp/server .` のような値が入るのは不自然です。実行ファイルの指定なら通常は `./tmp/server` で、末尾の空白と `.` は typo を疑うのが妥当です。現行設定では deprecated な `bin` ではなく `entrypoint = "./tmp/server"` を使う形にしています。', 'air build configuration troubleshooting', 'unpublished', false),
  (52, 'セクション23: air による Go 開発環境', 'include_ext と exclude_dir を両方入れる理由', '次の `air` 設定で `include_ext` と `exclude_dir` を両方指定する主な理由として最も適切なのはどれですか？', '[build]
cmd = "go build -o ./tmp/server ."
entrypoint = "./tmp/server"
include_ext = ["go"]
exclude_dir = ["tmp"]', '["`.go` の変更だけを監視しつつ、ビルド成果物のある `tmp` を監視対象から外して不要な再検知ループを防ぐため", "Go は `include_ext` と `exclude_dir` を必ず同時に書かないとコンパイルできないため", "`exclude_dir = [\"tmp\"]` を入れると `tmp` 配下にだけ変更を限定して高速化できるため", "`include_ext = [\"go\"]` はログの色を変える設定で、監視とは無関係であるため"]'::jsonb, 0, '`include_ext = ["go"]` により、Go ソースの変更に絞って監視できます。一方 `exclude_dir = ["tmp"]` を入れておかないと、`cmd` が生成した `./tmp/server` などの成果物まで再度検知して、無駄な再ビルドや再起動ループの原因になります。', 'air watch configuration', 'unpublished', false),
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
CMD ["./server"]', '["開発用はソースを mount して `air` で変更を監視するが、本番用はビルド済みバイナリを固定イメージとして実行する", "開発用と本番用の違いはポート番号だけで、再ビルド反映の考え方は同じである", "本番用のほうが `air` による自動再起動が強く有効になる", "開発用は必ず `docker compose up --build` が必要で、本番用は不要である"]'::jsonb, 0, '開発用構成は bind mount したソースコードを `air` が監視し、その場で再ビルド・再起動します。一方、本番用は Docker build 時に作ったバイナリを含むイメージを実行する構成で、起動後にソース変更を自動反映する仕組みは持ちません。目的が異なるため、同じ運用を期待しないことが重要です。', 'Docker development vs production architecture', 'unpublished', false),
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
- そのため `docker compose up --build` が必要になりやすいのは B です。', 'Docker Compose build reflection behavior', 'unpublished', false),
  (55, 'セクション23: air による Go 開発環境', 'root = "." を別ディレクトリに変えたときの影響', '`air` 設定で `root = "."` を `root = "./handlers"` に変更した。下の設定断片を前提に、最も起きやすい影響はどれですか？', 'root = "./handlers"
tmp_dir = "tmp"

[build]
cmd = "go build -o ./tmp/server ."
entrypoint = "./tmp/server"', '["`air` の基準ディレクトリが `./handlers` になり、監視範囲や `cmd` の相対パス解決が変わってビルド対象がズレる可能性がある", "`root` はログ表示用の文字列なので、実際の動作には影響しない", "`root` を変えると PostgreSQL の接続先も自動で切り替わる", "`root` をサブディレクトリにすると `air` は必ずすべての親ディレクトリも自動監視するので問題は起きない"]'::jsonb, 0, '`root` は `air` の作業基準ディレクトリです。ここをサブディレクトリへ変えると、監視対象の範囲だけでなく、`cmd` や `entrypoint` の相対パス解決基準も変わります。その結果、本来プロジェクトルートで実行したい `go build` が別ディレクトリ基準になり、ビルド失敗や意図しない監視範囲になることがあります。', 'air root directory behavior', 'unpublished', false),
  (56, 'セクション23: air による Go 開発環境', 'exclude_dir = ["tmp"] を消したときの不具合', '次の設定のように `exclude_dir = ["tmp"]` を削除したとき、最も起きやすい不具合はどれですか？', 'tmp_dir = "tmp"

[build]
cmd = "go build -o ./tmp/server ."
entrypoint = "./tmp/server"
include_ext = ["go"]', '["`./tmp/server` などの生成物まで監視対象に入り、再ビルドのたびに再検知して無駄な再起動やループの原因になりやすい", "`air` が `.go` ファイルを監視しなくなり、変更しても何も起きなくなる", "`tmp` ディレクトリが自動で PostgreSQL 用 volume に変換される", "`exclude_dir` を省略すると `entrypoint` が無視されて `cmd` だけが 1 回実行される"]'::jsonb, 0, 'この構成では `cmd` が `./tmp/server` を更新します。`tmp` を除外しないと、その生成物への変更まで `air` が検知してしまい、再ビルド後の成果物をまた変更と見なして、不要な再起動やループを引き起こしやすくなります。', 'air exclude_dir troubleshooting', 'unpublished', false),
  (57, 'セクション23: air による Go 開発環境', 'entrypoint と cmd の役割分担', '次の `build` 設定における `cmd` と `entrypoint` の役割分担として、最も適切なのはどれですか？', '[build]
cmd = "go build -o ./tmp/server ."
entrypoint = "./tmp/server"', '["`cmd` は再ビルド時に実行するコマンド、`entrypoint` はビルド後に起動する実行ファイルやコマンドを指す", "`cmd` と `entrypoint` は完全に同義で、どちらを書いても内部的に同じ処理になる", "`cmd` は Docker Compose 用、`entrypoint` は PostgreSQL 接続用の設定である", "`entrypoint` は監視拡張子の一覧を表し、`cmd` はログの出力形式を表す"]'::jsonb, 0, '`cmd` はソース変更時に何でビルドするかを定義する項目です。この例では `go build -o ./tmp/server .` がそれに当たります。一方 `entrypoint` は、そのビルド成果物として何を実行するかを表し、ここでは `./tmp/server` を起動します。つまり、`cmd` は作る処理、`entrypoint` は動かす対象です。', 'air cmd vs entrypoint semantics', 'unpublished', false),
  (58, 'セクション24: Codex 設定トラブルシュート', 'unknown variant xhigh の直接原因', '次のエラーの直接原因として最も適切なのはどれですか？', 'Error loading configuration: unknown variant ''xhigh'' ... expected one of minimal, low, medium, high', '["Codex 本体のバイナリ破損", "`model_reasoning_effort` に許可されていない値 `xhigh` が設定されていた", "ネットワークがオフラインだった", "API トークンの期限切れ"]'::jsonb, 1, 'このエラーは設定値の列挙型チェックで発生しています。`model_reasoning_effort` が受け付ける値は `minimal | low | medium | high` だけで、`xhigh` はスキーマ外です。', 'Codex config validation behavior', 'unpublished', false),
  (59, 'セクション24: Codex 設定トラブルシュート', 'なぜ xhigh が入りやすいか', '`xhigh` のような無効値が設定に残る経路として、最も現実的なのはどれですか？', 'model_reasoning_effort = "xhigh"', '["過去の会話ログや内部表現（例: reasoning_effort）をそのまま `config.toml` に転記した", "TOML では high が自動的に xhigh に変換される", "Go のバージョンが古いと high が xhigh に展開される", "Docker Compose が起動時に設定文字列を改変する"]'::jsonb, 0, '設定エラーの多くは『別コンテキストで使われていた値やサンプルをそのまま貼る』ことで起きます。TOML や Docker が自動変換した可能性は低く、手動転記ミスのほうが説明力があります。', 'Configuration drift troubleshooting', 'unpublished', false),
  (60, 'セクション24: Codex 設定トラブルシュート', 'なぜ high への変更で直るのか', '`model_reasoning_effort = "high"` に修正すると起動できる主な理由はどれですか？', 'model_reasoning_effort = "high"', '["`high` が許可済みの列挙値で、設定パーサーのバリデーションを通過するため", "`high` だと認証をスキップできるため", "`high` だと自動でネットワーク設定が修正されるため", "`high` だと API エンドポイントが localhost に変わるため"]'::jsonb, 0, '今回の失敗点は設定読み込み段階の enum 不一致でした。許可された値に戻すことで、起動前バリデーションが通り CLI が通常起動します。', 'Codex startup configuration parsing', 'unpublished', false),
  (61, 'セクション24: Codex 設定トラブルシュート', '再発防止の確認コマンド', '設定修正後に再発防止の観点で最初に実行する確認として適切なのはどれですか？', 'codex --help', '["ヘルプ表示などの軽量コマンドで設定読み込みに失敗しないことを先に確認する", "いきなり長時間の本番バッチを実行する", "設定ファイルを削除して毎回再生成する", "エラーが出なくても毎回 Docker を再ビルドする"]'::jsonb, 0, '`codex --help` は副作用が少なく、設定パースの成否をすぐ確認できます。まず軽量コマンドで健全性を確認してから本処理へ進むのが安全です。', 'Operational verification pattern', 'unpublished', false),
  (62, 'セクション24: Codex 設定トラブルシュート', '切り分け時の探索対象', 'ワークスペース内に該当設定が見つからない場合、次に優先して調べるべき場所はどれですか？', '# workspace で見つからない場合', '["ユーザーホーム配下の `~/.codex/config.toml`", "`node_modules` の任意ライブラリ", "Docker コンテナ内の `/var/lib/postgresql/data`", "ブラウザの localStorage"]'::jsonb, 0, 'Codex CLI の恒久設定はユーザースコープに置かれることが多く、ワークスペース外の `~/.codex/config.toml` が原因点になるケースがあります。今回もここが実際の修正箇所でした。', 'User-scope CLI configuration', 'unpublished', false),
  (63, 'セクション25: Go 標準ライブラリ読解', 'LookupEnv の戻り値の意味', '次のコードについて、最も正しい説明はどれですか？', 'func LookupEnv(key string) (string, bool) {
	testlog.Getenv(key)
	return syscall.Getenv(key)
}', '["環境変数が未設定でも常に `(\"\", true)` を返す", "第2戻り値は『キーが存在したか』を表し、値が空文字でも存在していれば true になる", "`testlog.Getenv` が環境変数の実体を読み取り、第1戻り値として返している", "`LookupEnv` は値だけを返し、bool は常に false になる"]'::jsonb, 1, '`LookupEnv` は `(value, found)` を返す API です。ここでは最終的に `syscall.Getenv(key)` の結果をそのまま返しています。`found` は『環境変数が存在するか』を表すため、値が空文字でもキーが設定済みなら true です。未設定の場合のみ false になります。`testlog.Getenv(key)` はテスト用ログフックで、戻り値の意味そのものは `syscall.Getenv` に依存します。', 'Go os.LookupEnv implementation', 'unpublished', false),
  (64, 'セクション26: Go runtime 診断出力', 'runtime.NumCPU の意味', '次のコード断片における `runtime.NumCPU()` の説明として最も適切なのはどれですか？', 'fmt.Printf("Number of CPUs: %d\n", runtime.NumCPU())', '["現在の goroutine 数を返す", "実行可能な論理CPU数を返し、Goプロセスが使う並列数そのものとは限らない", "常に物理CPUソケット数を返す", "Goのバージョン文字列を返す"]'::jsonb, 1, '`runtime.NumCPU()` はマシンの論理CPU数を返します。ただし実際の並列実行上限は `GOMAXPROCS` によって制御されるため、`NumCPU` と実効並列度は常に一致するとは限りません。', 'Go runtime package', 'unpublished', false),
  (65, 'セクション26: Go runtime 診断出力', 'runtime.GOMAXPROCS(0) の読み取り', '`runtime.GOMAXPROCS(0)` をログ表示に使う主な意図はどれですか？', 'fmt.Printf("GOMAXPROCS: %d\n", runtime.GOMAXPROCS(0))', '["GOMAXPROCS を 0 に設定して無効化するため", "現在値を変更せずに、並列実行に使う OS スレッド数の上限を取得するため", "goroutine をすべて停止するため", "CPU 使用率をパーセントで取得するため"]'::jsonb, 1, '`GOMAXPROCS(n)` は通常『設定して旧値を返す』APIですが、`n=0` のときは設定変更せず現在値を返します。診断ログでは副作用なく現設定を確認できるため有用です。', 'Go runtime.GOMAXPROCS', 'unpublished', false),
  (66, 'セクション26: Go runtime 診断出力', 'runtime.NumGoroutine の解釈', '`runtime.NumGoroutine()` の値を監視する際の注意点として最も適切なのはどれですか？', 'fmt.Printf("Number of Goroutines: %d\n", runtime.NumGoroutine())', '["この値は常に 1 で固定される", "この値は現在生存している goroutine 数のスナップショットで、負荷やタイミングで変動する", "この値は OS スレッド数と必ず同じ", "この値はメモリ使用量(MB)を示す"]'::jsonb, 1, '`NumGoroutine` は瞬間値です。リクエスト処理中やバックグラウンドタスクの有無で増減します。単発値だけでなく時系列で見るとリーク検知に役立ちます。', 'Go runtime.NumGoroutine', 'unpublished', false),
  (67, 'セクション26: Go runtime 診断出力', 'runtime.Version の用途', '起動時に `runtime.Version()` を出力する主なメリットはどれですか？', 'fmt.Printf("Go Version: %s\n", runtime.Version())', '["アプリのビジネスロジックを高速化するため", "実行バイナリがどの Go ランタイムで動作しているかを運用時に追跡するため", "JWT の署名方式を選択するため", "DB 接続数を自動調整するため"]'::jsonb, 1, '運用環境での不具合調査では『どの Go バージョンで動いているか』の可観測性が重要です。`runtime.Version()` のログは再現性確認やデプロイ差分の切り分けに有効です。', 'Go runtime.Version', 'unpublished', false),
  (68, 'セクション26: Go runtime 診断出力', 'runtime.GOOS / GOARCH の意味', '`runtime.GOOS` と `runtime.GOARCH` を同時にログ出力する目的として最も適切なのはどれですか？', 'fmt.Printf("OS/Arch: %s/%s\n", runtime.GOOS, runtime.GOARCH)', '["HTTP レスポンスの Content-Type を決めるため", "実行バイナリの対象プラットフォーム（OS/アーキテクチャ）を明示し、環境差異を診断しやすくするため", "データベース方言を切り替えるため", "CORS 設定を自動生成するため"]'::jsonb, 1, '`GOOS/GOARCH` は実行環境の識別子です。コンテナやクロスビルド環境では想定外の組み合わせで動くことがあるため、起動時に可視化しておくと障害対応が速くなります。', 'Go runtime constants', 'unpublished', false),
  (69, 'セクション27: runtime 診断ログの実践読解', 'NumCPU と GOMAXPROCS が同じ値の意味', '次の起動ログから読み取れる状態として最も適切なのはどれですか？', 'Number of CPUs: 12
GOMAXPROCS: 12', '["CPU制限が設定されていて、Goプロセスはすべての論理CPUを使用可能", "Go プロセス用に意図的に 6 つの CPU が割り当てられている", "マシンに物理 CPU ソケットが 6 個ある", "このプロセスは単一スレッドで動く"]'::jsonb, 0, 'NumCPU と GOMAXPROCS が同じ値なら、デフォルト設定で全論理CPU を並列実行に使えます。Docker 環境なら cpus 制限がない状態、物理マシンならマシン全体で並列実行できます。', 'Container / Runtime CPU diagnostics', 'unpublished', false),
  (70, 'セクション27: runtime 診断ログの実践読解', '起動直後の Goroutines: 1 の状態', '起動直後に Goroutines: 1 と表示される状態から、リクエスト受信中にこの数が増える主な原因はどれですか？', 'Number of Goroutines: 1  // 起動直後
// リクエスト受信後は増加する', '["メモリリークがある", "HTTP リクエストハンドラーが新しい goroutine を起動しているか、バックグラウンドタスクが実行されている", "CPU 使用率が上がった", "Go のバージョンが古い"]'::jsonb, 1, '起動直後は main goroutine だけで 1 ですが、http.ListenAndServe でリクエスト受信時に handler goroutine が生成され、数が増えます。多数の同時リクエストやバック側タスク実行で、さらに増加します。', 'Goroutine lifecycle in HTTP server', 'unpublished', false),
  (71, 'セクション27: runtime 診断ログの実践読解', 'NumCPU=12, GOMAXPROCS=12, Goroutines=1 の組み合わせから判断できること', '次のログを見たときの状態判断として最も適切なのはどれですか？', 'Number of CPUs: 12
GOMAXPROCS: 12
Number of Goroutines: 1', '["CPU リソースは十分で、並列度は高いが、起動直後でまだリクエストを受け取っていない状態", "CPU が過負荷で、Goroutine が 1 つだけしか作成できない", "Go プロセスはシングルスレッド", "ネットワークが遮断されている"]'::jsonb, 0, '全 CPU が利用可能で並列実行可能な環境「なのに」 Goroutines が 1 つとは、まさに起動直後やアイドル状態を意味します。反対に数百～千の Goroutine がいれば、高負荷状態です。', 'Runtime diagnostics interpretation', 'unpublished', false),
  (72, 'セクション27: runtime 診断ログの実践読解', 'OS/Arch: linux/amd64 の環境判断', 'OS/Arch: linux/amd64 というログから推測できる運用環境として、最も可能性が高いのはどれですか？', 'OS/Arch: linux/amd64', '["Windows Server 環境で WSL を使用している", "Apple Silicon Mac（ARM64）上での実行", "Docker コンテナ内での実行、Linux サーバー、または Linux VM", "Raspberry Pi や組み込みデバイス"]'::jsonb, 2, 'linux/amd64 は x86-64 CPU をもつ標準的な Linux 実行環境です。Docker、クラウド環境、Linux サーバーの大多数がこの組み合わせで、ARM や Windows では異なります。', 'Platform identification', 'unpublished', false),
  (73, 'セクション27: runtime 診断ログの実践読解', '起動ログから推測できる Docker コンテナ構成', '次のログが Docker コンテナ起動時に見える状況を診断するうえで、最も重要な観点はどれですか？', 'api-1  | Number of CPUs: 12
api-1  | GOMAXPROCS: 12
api-1  | Go Version: go1.26.1
api-1  | OS/Arch: linux/amd64', '["コンテナに CPU 制限（--cpus 等）が設定されておらず、ホストのすべての CPU にアクセス可能な状態", "コンテナは ARM ビルド", "Go のバージョンが最新ではない", "アプリケーションに必ずバグがある"]'::jsonb, 0, '12 CPU すべてが見える＝CPU 制限なし。実運用では resource limits を設定して過剰リソース消費を防ぐため、この状況が見えたら限度設定の見直し対象です。', 'Container resource isolation', 'unpublished', false),
  (74, 'セクション28: PostgreSQL ログ読解', 'checkpoint complete の意味', '次のログの `checkpoint complete` が示す状態として最も適切なのはどれですか？', 'db-1 | LOG: checkpoint complete: wrote 13 buffers (0.1%); ...', '["WAL が破損したため DB が強制終了した", "チェックポイント処理が正常に完了し、dirty page の一部がディスクへ書き出された", "すべてのテーブルが VACUUM された", "クライアント接続がすべて切断された"]'::jsonb, 1, '`checkpoint complete` は障害ではなく、PostgreSQL の定期的な永続化処理の完了ログです。メモリ上の変更（dirty buffers）をディスクへ反映し、リカバリ起点を進めます。', 'PostgreSQL checkpoint logs', 'unpublished', false),
  (75, 'セクション28: PostgreSQL ログ読解', 'wrote 13 buffers (0.1%) の読み方', '`wrote 13 buffers (0.1%)` という値の解釈として最も適切なのはどれですか？', '... checkpoint complete: wrote 13 buffers (0.1%); ...', '["13 個の接続を切断した", "チェックポイント対象のうち実際に書き込んだバッファが少量で、負荷は比較的軽い", "13 個の WAL ファイルを新規作成した", "13 秒間ロックを保持した"]'::jsonb, 1, '`buffers` は共有バッファ中の書き出し対象ページ数を示します。0.1% と小さいため、このチェックポイントでの書き込み負荷は低めと読めます。', 'PostgreSQL shared buffers metrics', 'unpublished', false),
  (76, 'セクション28: PostgreSQL ログ読解', 'WAL file(s) added/removed/recycled が 0 の意味', '次のログ断片の解釈として最も適切なのはどれですか？', '... 0 WAL file(s) added, 0 removed, 0 recycled; ...', '["WAL 機能が無効化されている", "そのチェックポイント区間では WAL ファイルの増減・再利用イベントが発生しなかった", "レプリケーションが停止している", "トランザクションが 0 件だった"]'::jsonb, 1, 'この値は WAL 管理イベントの件数です。すべて 0 でも異常とは限らず、単にその期間にファイル追加・削除・再利用が不要だったことを示します。', 'PostgreSQL WAL checkpoint counters', 'unpublished', false),
  (77, 'セクション28: PostgreSQL ログ読解', 'write / sync / total の関係', '`write=1.221 s, sync=0.019 s, total=1.274 s` の関係として正しい説明はどれですか？', '... write=1.221 s, sync=0.019 s, total=1.274 s; ...', '["total は常に write + sync と完全一致する", "total はチェックポイント全体時間で、write/sync 以外の処理時間も含みうる", "sync はネットワーク同期時間を示す", "write が 1 秒を超えると必ず障害である"]'::jsonb, 1, '`total` はチェックポイント処理全体で、`write` と `sync` のほか管理オーバーヘッドを含むことがあります。したがって厳密一致しない場合があります。', 'PostgreSQL checkpoint timing fields', 'unpublished', false),
  (78, 'セクション28: PostgreSQL ログ読解', 'lsn と redo lsn の読み方', '`lsn=0/19B0628, redo lsn=0/19B05F0` から読み取れる内容として最も適切なのはどれですか？', '... lsn=0/19B0628, redo lsn=0/19B05F0', '["redo lsn は現在 lsn より常に大きい", "redo lsn はクラッシュリカバリ開始位置を示し、通常は最新 lsn 以下になる", "lsn は CPU 使用率、redo lsn はメモリ使用率を示す", "この値が表示されると必ず WAL 破損を意味する"]'::jsonb, 1, '`LSN` は WAL 上の位置を示す識別子です。`redo lsn` はリカバリ再生の起点で、一般には最新 `lsn` より前方にあります。差分はリカバリ時に再生対象となる範囲の目安になります。', 'PostgreSQL WAL/LSN fundamentals', 'unpublished', false),
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
  (80, 'セクション30: Tailwind CSS クラス読解', 'section の className から見た目を読む', '次の Tailwind CSS の `className` が適用された `<section>` の見た目として、最も適切なのはどれですか？', '<section className="mt-7 rounded-[24px] border border-[#14213d]/12 bg-white/72 p-[clamp(20px,4vw,32px)] shadow-[0_22px_48px_rgba(20,33,61,0.12)]">', '["上に余白があり、24px の角丸、薄いボーダー、少し透けた白背景、20px から 32px の可変 padding、柔らかい影が付いたカード状の見た目", "上余白はなく、角丸もなく、濃い紺色の背景に太い実線ボーダーが付き、padding は 0 で影もない", "背景は完全に透明で、hover 時だけ影と padding が付与される。通常時はボーダーも角丸もない", "50% の丸い角丸と固定 4px の padding が付き、背景色は黒、ボーダーは二重線になる"]'::jsonb, 0, '`mt-7` は上側にマージンを付けます。`rounded-[24px]` は任意値による 24px の角丸です。`border` はボーダーを表示し、`border-[#14213d]/12` はカスタム色 `#14213d` を 12% の不透明度で適用します。`bg-white/72` は白背景に 72% の不透明度を指定しています。`p-[clamp(20px,4vw,32px)]` は画面幅に応じて 20px から 32px の間で変化する padding を与えます。`shadow-[0_22px_48px_rgba(20,33,61,0.12)]` は任意値による柔らかいドロップシャドウです。全体として、少し浮いたカード状のセクションに見えます。', 'Tailwind utility classes / arbitrary values', 'unpublished', false),
  (81, 'セクション30: Tailwind CSS クラス読解', 'header のレスポンシブ配置を読む', '以下のコードを見て、この `header` の見た目として正しいものはどれですか？', '<header className="mb-[22px] flex flex-col gap-[18px] xl:flex-row xl:items-start xl:justify-between">', '["画面サイズに関わらず、要素は常に横並びに表示される", "小さい画面では縦並び、xl（1280px以上）になると横並びに切り替わり、両端に要素が配置される", "小さい画面では横並び、xl になると縦並びに切り替わる", "画面サイズに関わらず、要素は常に縦並びで中央揃えになる"]'::jsonb, 1, '`flex` で flex コンテナになり、通常は `flex-col` により縦並びです。`gap-[18px]` は子要素間の間隔を 18px にします。`mb-[22px]` は下側マージン 22px です。`xl:flex-row` は xl ブレークポイント以上で横並びへ切り替える指定です。さらに `xl:items-start` で交差軸方向の開始位置に揃え、`xl:justify-between` で主軸方向に要素を両端配置します。したがって、小さい画面では縦並び、xl 以上では横並びで左右に分かれたレイアウトになります。', 'Tailwind utility classes / arbitrary values', 'unpublished', false),
  (82, 'セクション31: Tailwind CSS ビルド最適化', '未使用クラスの自動削除', 'Tailwind CSS のビルド時パージ（未使用クラスの自動削除）について、最も適切な説明はどれですか？', 'Tailwind はビルド時に使っていないクラスを自動で削除する。
開発時: 数MB（全クラス入り）
本番ビルド後: 数KB〜数十KB（使ったクラスだけ）
Tailwind v3 以降ではデフォルトで自動なので、基本的に追加意識は不要。', '["本番ビルドでも全クラスをそのまま含むため、CSS サイズはほとんど変わらない", "Tailwind はソースファイル内のクラスを検出して必要なスタイルだけを生成するため、本番 CSS を小さくできる", "未使用クラスの削除はブラウザ実行時に JavaScript が動的に行う", "Tailwind v3 以降では未使用クラス削除機能は廃止され、手動で purge ツールを入れる必要がある"]'::jsonb, 1, 'Tailwind のドキュメントでは、Tailwind はプロジェクト内のソースファイルをスキャンしてクラス名を探し、対応するスタイルを生成すると説明されています。つまり、実際に使ったクラスだけが最終 CSS に含まれるため、本番ビルドの CSS サイズを小さくできます。Tailwind CSS v3 の説明でも、同じ CSS を共有しつつ、ほとんどの Tailwind プロジェクトは非常に小さな CSS を配信できるとされています。要するに、未使用クラスの除去は本番ビルド時に自動で効く最適化です。', 'Tailwind production optimization', 'unpublished', false),
  (83, 'セクション31: Tailwind CSS ビルド最適化', '手動で CSS の膨張を抑える方法', 'Tailwind CSS で、手動で CSS の膨張や保守コストを抑える方法として最も適切なのはどれですか？', '// ❌ これが多いとCSSが膨らむ
p-[17px] p-[23px] p-[31px]

// ✅ デザイントークンに統一する
p-4 p-6 p-8

// ❌ 同じクラスが色んな場所に散らばる
<div className="rounded-2xl bg-white shadow-md p-6">
<div className="rounded-2xl bg-white shadow-md p-6">

// ✅ コンポーネントにまとめる
<Card> // 内部でクラスを管理', '["任意値をできるだけ増やし、同じクラス列も各画面に直接書いたほうが最適化しやすい", "任意値を減らしてデザイントークンへ寄せ、重複するクラスの組み合わせはコンポーネントへまとめる", "CSS の膨張を避けるには Tailwind をやめて、すべて inline style に置き換えるのが最善", "同じクラス文字列を何度も書くほど Tailwind が自動でより強く圧縮してくれる"]'::jsonb, 1, 'Tailwind では未使用クラスの自動削除が効きますが、任意値を細かく増やし続けると生成されるユーティリティの種類が増えやすくなります。そのため、`p-[17px]` のような個別値を乱立させるより、`p-4` `p-6` `p-8` のようにデザイントークンへ寄せた方が設計を揃えやすく、出力も管理しやすくなります。また、`rounded-2xl bg-white shadow-md p-6` のような同じクラスの組み合わせが各所に散らばると、見た目の変更やレビューがしづらくなります。`<Card>` のようなコンポーネントへまとめると、内部でクラスを一元管理でき、保守性と再利用性を上げられます。', 'Tailwind utility classes / arbitrary values', 'unpublished', false),
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
import PrimaryButton from ''./Button'';', '["1つのモジュールで `export default` は複数定義できる", "`export default` で公開した値は、import 側で任意の名前で受け取れる", "`export default` は必ず中括弧付きで import しなければならない", "`export default` は関数には使えず、クラスでしか使えない"]'::jsonb, 1, 'ES Modules では 1 モジュールにつき default export は 1 つだけ定義できます。default export は import 側で `import AnyName from ''...''` のように任意の識別子名で受け取れます。一方、`{ ... }` を使うのは named export を import する場合です。', 'https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/export', 'unpublished', false),
  (86, 'セクション34: Go Runtime Monitoring 戦略', '本番監視の導入順と閾値設計', 'Go アプリケーションの本番監視方針として、次の結論の要点を最も正しくまとめたものはどれですか？', 'Monitoring Go runtime metrics is essential for maintaining healthy, performant applications in production.

Start with the default Go collector metrics, then add custom metrics as you learn your application''s specific patterns and requirements.

Remember that thresholds should be adjusted based on your application''s characteristics.
Establish baselines during normal operation and set alerts based on meaningful deviations from those baselines.', '["最初から細かい custom metrics と固定しきい値を大量投入し、どのサービスでも同じ alert 条件を使うのが最善", "まず標準の Go runtime 指標を監視し、必要に応じて Prometheus や OpenTelemetry の custom metrics を足し、しきい値はアプリ固有の通常時ベースラインから調整する", "runtime.NumGoroutine() と runtime.ReadMemStats() は開発時だけに使い、本番ではアプリ独自ログだけ見れば十分", "高スループットなバッチ処理と軽量 API では同じ goroutine 数・GC pause しきい値を共有すべき"]'::jsonb, 1, '結論の中心は、「Go runtime の監視は本番で重要であり、まずは標準の runtime 指標から始める」という点です。そのうえで、Prometheus や OpenTelemetry を使って可視化を広げ、必要になったところだけ custom metrics を追加していくのが推奨されています。また、goroutine 数、メモリ使用量、GC pause などの警告しきい値は全サービス共通の固定値ではなく、アプリの特性によって調整すべきだと述べています。つまり、通常運転時のベースラインを先に観測し、そこから意味のある逸脱に対して alert を張る、という運用方針が正解です。', 'Go runtime / Prometheus / OpenTelemetry monitoring', 'unpublished', false),
  (87, 'セクション35: 英単語 × CSS カラー', '「navy」の英単語の意味', 'CSS で `--color-navy: #14213d;` のように使われる「navy」という英単語の本来の意味として正しいものはどれですか？', '/* index.css */
@theme {
  --color-navy: #14213d; /* 深い紺色 */
}', '["空軍（航空戦力）", "海軍（海上の軍隊）", "陸軍（地上部隊）", "海兵隊（水陸両用部隊）"]'::jsonb, 1, '"navy" の本来の意味は「海軍」です。語源はラテン語の "navis"（船）に由来します。色名としての「ネイビーブルー（navy blue）」はイギリス海軍の制服の色（深い紺色）に由来しており、そこから転じて深い紺色全般を指す色名にもなりました。CSS では `#14213d` のような暗い紺色を `navy` と命名するケースが多いのはこの背景からです。', 'https://www.etymonline.com/word/navy', 'unpublished', false),
  (88, 'セクション36: React モジュールスコープ', 'コンポーネント外の定数宣言', '次のコードで `allQuizzes` をコンポーネント関数の外（モジュールスコープ）で宣言している主な理由として最も適切なものはどれですか？', '// モジュールスコープ（コンポーネント外）
const allQuizzes = getAllQuizzes()
const sectionCount = groupQuizzesBySection().size
const quizCountPerSession = allQuizzes.length

function JsonQuizPreviewSection() {
  // ...
}', '["React の規約でデータ取得は必ずコンポーネント外で行わなければならない", "コンポーネントの再レンダリングのたびに再計算されないよう、初回モジュール読み込み時に1度だけ評価するため", "`const` はコンポーネント内では使えないため", "ESLint の react-hooks/exhaustive-deps ルールに違反しないようにするため"]'::jsonb, 1, 'モジュールスコープに宣言すると、そのファイルがはじめて import された時点で1度だけ評価されます。コンポーネント内に書いてしまうと、state 変化などで再レンダリングが起きるたびに `getAllQuizzes()` が呼ばれてしまいます。クイズデータのように「変化しない重い初期化」はモジュールスコープに置くことでコストを抑えられます。なお、値が変化しうる場合は `useState` や `useMemo` を使う方が適切です。', 'https://react.dev/learn/keeping-components-pure', 'unpublished', false),
  (89, 'セクション37: 技術英語読解', '`recommended` の意味', '技術ドキュメントで `It is strongly recommended to restart the server after changing this setting.` と書かれているとき、`recommended` の意味として最も適切なのはどれですか？', 'It is strongly recommended to restart the server after changing this setting.', '["再起動は禁止されている", "再起動が推奨されている", "再起動は必須で、省略すると設定は保存されない", "サーバーは自動的に再起動される"]'::jsonb, 1, '`recommended` は「推奨されている」という意味です。Cambridge Dictionary では、`recommended` は「ある目的や仕事にとって良い・適切だと提案されている、または実行すべき行動として提案されている」と説明されています。したがってこの文は、「この設定を変更したあと、サーバーを再起動するのが強く勧められる」という意味です。`must` のような絶対必須までは言っていませんが、従うべき実務上の推奨として読むのが自然です。', 'https://dictionary.cambridge.org/us/dictionary/english/recommended', 'unpublished', false),
  (90, 'セクション38: React / TypeScript 英文読解', '`createRoot(container!)` コメントの読解', '次の React 18 の GitHub Issue コメントの意味として、最も適切なものはどれですか？', 'The issue here is that `container` is potentially null. `createRoot(null)` would throw at runtime and therefore rightfully does not compile. If you''re sure it''s not nullable then you can use the `!` operator: `createRoot(container!)`.', '["`container` は常に null ではないので、TypeScript のエラーは誤検知である", "`container` は null の可能性があるため、そのままではコンパイルできないのは正しい。null ではないと確信できるなら `!` で非 null として扱える", "`createRoot(null)` は実行時に安全に無視されるので、`!` は不要である", "`!` 演算子を使うと DOM 要素が自動生成されるので、`getElementById(''root'')` の結果確認は不要になる"]'::jsonb, 1, 'このコメントは、「問題は `container` が null かもしれないことだ」と述べています。`createRoot(null)` は実行時に例外になるため、TypeScript がそのコードを拒否するのは正しい、という意味です。そのうえで、呼び出し側が `container` は null ではないと本当に保証できるなら、non-null assertion の `!` を使って `createRoot(container!)` と書ける、という説明です。つまり、型エラーを黙らせるために無条件で `!` を付けるのではなく、null にならない根拠がある場合だけ使うべき、という文脈です。', 'https://github.com/facebook/react/issues/24208#issuecomment-1082708370', 'unpublished', false),
  (91, 'セクション39: ESLint / TypeScript ルール読解', '`@typescript-eslint/no-non-null-assertion: ''error''` の意味', '次の ESLint 設定の意味として最も適切なのはどれですか？', '"@typescript-eslint/no-non-null-assertion": "error"', '["postfix `!` を使う non-null assertion を禁止し、違反は ESLint の error として扱われる", "`x!` は `null` と `undefined` を型から除外し、出力される JavaScript では `!` が削除される", "`warn` は違反を報告するが exit code には影響しない", "このルールはオプションで細かく挙動を調整できる"]'::jsonb, 0, '`@typescript-eslint/no-non-null-assertion` は、`!` postfix を使った non-null assertion を禁止するルールです。typesript-eslint の公式 docs でも `Disallow non-null assertions using the ! postfix operator.` と説明されています。さらに ESLint では、ルールを `"error"` にすると違反は error として扱われ、トリガー時は exit code が 1 になります。一方、TypeScript の docs にある「`x!` は `null` / `undefined` を型から除外し、JavaScript 出力では消える」という説明は演算子自体の性質であり、この ESLint 設定の意味そのものではありません。また、この rule は typescript-eslint docs 上で `This rule is not configurable.` とされています。', 'https://typescript-eslint.io/rules/no-non-null-assertion, https://eslint.org/docs/latest/use/configure/rules, https://www.typescriptlang.org/docs/handbook/release-notes/typescript-2-0.html', 'unpublished', false),
  (92, 'セクション40: TypeScript / Vite エラー対応', 'vite/client 型定義エラーの原因', '次の TypeScript エラーの原因として最も適切なのはどれですか？

Cannot find type definition file for ''vite/client''.
The file is in the program because:
Entry point of type library ''vite/client'' specified in compilerOptions', '// tsconfig.app.json
{
  "compilerOptions": {
    "types": ["vite/client"]
  }
}', '["`types` で `vite/client` を指定しているが、Vite 依存関係の解決に失敗して型定義を見つけられていない", "`vite/client` は TypeScript で使えない予約語である", "`types` 配列に 1 つしか指定できないため発生する", "JSON ファイルの読み込み設定が不足しているため発生する"]'::jsonb, 0, 'このエラーは、`compilerOptions.types` に `vite/client` を指定しているのに、TypeScript が該当型定義を解決できないときに発生します。多くの場合は依存関係の未インストールや壊れた `node_modules` が原因です。', 'TypeScript / Vite configuration error', 'unpublished', false),
  (93, 'セクション41: TypeScript エラー切り分け', '最初の確認対象', '`Cannot find type definition file for ''vite/client''` が出たとき、最初に確認すべき対象として最も適切なのはどれですか？', '// tsconfig.app.json
{
  "compilerOptions": {
    "types": ["vite/client"]
  }
}', '["tsconfig の `types` 設定が何を要求しているかを確認する", "まず CSS の import を削除する", "React のバージョンを下げる", "eslint.config.js を削除する"]'::jsonb, 0, '切り分けの第一歩は、設定が何を解決しようとしているかを把握することです。`types` に `vite/client` があるなら、TypeScript はその型定義の解決を試みます。', 'TypeScript troubleshooting workflow', 'unpublished', false),
  (94, 'セクション41: TypeScript エラー切り分け', 'package.json と実体の差分', '`package.json` に `vite` が定義されているのに `npm ls vite --depth=0` が `(empty)` になる状況の説明として正しいのはどれですか？', '// package.json には vite がある
"devDependencies": {
  "vite": "^7.3.1"
}

// ただし npm ls では empty', '["依存定義はあるが、インストールされていない（node_modules が未構築）", "vite は npm ls で表示されない仕様", "TypeScript 5.9 では vite が無効化される", "ESM プロジェクトでは devDependencies が無視される"]'::jsonb, 0, '`package.json` は要求仕様、`node_modules` は実体です。要求があっても install されていなければ解決できません。', 'npm dependency resolution basics', 'unpublished', false),
  (95, 'セクション41: TypeScript エラー切り分け', 'npm install の役割', '今回のケースで `npm install` を実行する主目的として最も適切なのはどれですか？', 'npm install', '["未導入の依存関係を node_modules に展開し、`vite/client` 型定義を解決可能にする", "tsconfig のエラーを自動で書き換える", "ESLint ルールを自動修正する", "build 出力を dist から削除する"]'::jsonb, 0, '今回の欠損は設定ではなく依存実体です。`npm install` により Vite 本体と型定義ファイルが利用可能になります。', 'npm install behavior', 'unpublished', false),
  (96, 'セクション41: TypeScript エラー切り分け', '存在確認コマンドの意味', '`test -f node_modules/vite/client.d.ts` を実行する意義として最も適切なのはどれですか？', 'test -f node_modules/vite/client.d.ts && echo ''vite-client-types-ok''', '["TypeScript が参照する型定義ファイルの実在を直接検証する", "tsconfig の JSON 構文を検証する", "Vite の開発サーバーを起動する", "ESLint の警告を無効化する"]'::jsonb, 0, 'ファイルの存在確認は、推測ではなく事実で切り分けるための最短手段です。', 'shell troubleshooting practice', 'unpublished', false),
  (97, 'セクション41: TypeScript エラー切り分け', '修正完了の判定', 'この問題に対する最終的な完了判定として最も妥当なのはどれですか？', 'npm run build', '["`npm run build` が成功し、TypeScript で同エラーが再現しない", "`package.json` を開いて確認しただけで完了", "`node_modules` が存在すれば無条件で完了", "エディタの表示を閉じれば完了"]'::jsonb, 0, '最終判定は実行結果です。設定確認と依存導入の後、ビルド成功で再現性のある完了確認になります。', 'build verification workflow', 'unpublished', false),
  (98, 'セクション42: Docker トラブルシュート', 'Cannot connect to the Docker daemon の意味', '次のエラーメッセージの意味として最も適切なのはどれですか？

Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?', 'docker ps', '["Docker CLI は動いているが、接続先の Docker デーモン（バックグラウンドサービス）に接続できていない", "コンテナ数が多すぎて `docker ps` がタイムアウトした", "Dockerfile が見つからないため `docker ps` が失敗した", "イメージの pull が未完了なため必ず出る正常メッセージ"]'::jsonb, 0, 'このエラーは、`docker` コマンド自体ではなく、裏で動く Docker デーモンに接続できない状態を示します。代表例は Docker Desktop が未起動、デーモン停止、またはソケット権限の問題です。', 'Docker daemon connection error', 'unpublished', false),
  (99, 'セクション42: Docker トラブルシュート', 'コンテナが Exited (255) になる理由', 'リポジトリのコンテナが `Exited (255)` になっている。原因切り分けとして最も適切な最初の行動はどれですか？', 'docker ps -a
docker logs <container_name>', '["終了コードだけでは原因を断定できないため、まず `docker logs` で起動時エラー（環境変数不足、接続失敗、実行ファイルエラーなど）を確認する", "Exited (255) は常にポート競合なので、ポート番号だけ変更すればよい", "Exited (255) は正常終了の意味なので、対応は不要", "コンテナを再作成せずに、OS を再起動すれば必ず解決する"]'::jsonb, 0, '`255` は一般的に異常終了を示しますが、理由はアプリごとに異なります。まずは `docker logs` と `docker inspect` で実際のエラーメッセージを確認し、設定不足・接続先未起動・コマンド実行失敗などを切り分けるのが正攻法です。', 'Docker troubleshooting practice', 'unpublished', false),
  (100, 'セクション43: DBマイグレーション運用', 'dirty 状態の意味', 'DBマイグレーション文脈で `dirty` 状態と表示されたときの意味として最も適切なのはどれですか？', 'error: Dirty database version 12. Fix and force version.', '["あるマイグレーションが途中で失敗し、スキーマ整合性が不確定なため後続マイグレーションが停止される状態", "DBに不要データが多いので VACUUM が必要な状態", "マイグレーションが完全成功したことを示す正常状態", "SQLファイル名に誤字があるだけで、実行には影響しない警告状態"]'::jsonb, 0, '`dirty` は途中失敗の保護状態です。まず失敗理由と実DB状態を確認し、必要に応じて手動修正してから履歴バージョンと dirty フラグを整合させて再開します。', 'Migration tools common behavior', 'unpublished', false),
  (101, 'セクション43: DBマイグレーション運用', '000016失敗後に force 16 する意図', '次の対応の説明として最も適切なのはどれですか？

000016 は `information.image_url` が既に存在していたため失敗。
000016 はカラム追加1文のみだったので実体反映済みと判断し、`force 16` で履歴を整えた後に 000017 を適用した。', '-- 000016: ALTER TABLE information ADD COLUMN image_url ...
-- 実DBには既に image_url が存在
-- migration tool: force 16
-- then apply 000017', '["実DBスキーマは16相当まで進んでいると確認できたため、履歴テーブルだけを16に合わせて dirty/不整合を解消し、後続の000017を再開した", "000016 のSQLを自動的にロールバックして、DBを15に完全復元した", "000016 と000017 を同時にスキップし、次回デプロイでまとめて実行する設定にした", "`force 16` はDB実体を自動変更する機能なので、検証なしで使って問題ない"]'::jsonb, 0, 'この対応は『実体と履歴の再同期』です。000016 は「既存カラムのため失敗」だったが、内容がその1文のみで実体が既に満たされていると確認できたため、履歴だけ16に進めて不整合を解消し、次の000017を適用しています。ポイントは force が履歴操作であり、実体変更の代替ではないことです。', 'DB migration incident recovery', 'unpublished', false),
  (102, 'セクション44: SQL データ操作', 'DELETE + サブクエリの対象理解', '次の SQL クエリの目的として最も適切なものはどれですか？', 'DELETE FROM user_favorite_stores
WHERE user_id IN (SELECT id FROM users WHERE email IN (''user1@example.com'', ''user2@example.com'', ''user3@example.com''));', '["指定メールアドレスのユーザー本体を users テーブルから削除する", "指定メールアドレスのユーザーに紐づく user_favorite_stores の行を削除する", "user_favorite_stores に新しい行を追加する", "users テーブルのメールアドレスを一括更新する"]'::jsonb, 1, '内側のサブクエリで、指定メールアドレスに一致する `users.id` を取得し、外側の DELETE でその `id` を `user_id` に持つ `user_favorite_stores` の行を削除します。削除対象は users 本体ではなく関連テーブルです。', 'SQL DELETE with subquery', 'unpublished', false),
  (103, 'セクション45: Linux コマンド基礎', 'wc コマンドの意味', '`wc -l src/data/quizzes.json` で使われている `wc` の意味として最も適切なのはどれですか？', 'wc -l src/data/quizzes.json', '["テキストの行数・単語数・バイト数などを数えるコマンド", "ファイルの所有者を変更するコマンド", "ディレクトリ構造をツリー表示するコマンド", "ファイルを圧縮するコマンド"]'::jsonb, 0, '`wc` は word count の略で、入力テキストの統計情報（行数・単語数・バイト数など）を表示するコマンドです。', 'Unix wc command', 'unpublished', false),
  (104, 'セクション45: Linux コマンド基礎', '`-l` オプションの意味', '`wc -l src/data/quizzes.json` の `-l` オプションが表すものはどれですか？', 'wc -l src/data/quizzes.json', '["ファイルの行数（line count）を表示する", "ファイルの最終更新日時を表示する", "ファイルサイズを人間向け表示にする", "隠しファイルも含めて一覧表示する"]'::jsonb, 0, '`-l` は line の意味で、改行区切りの行数を表示します。今回の出力 `1440 src/data/quizzes.json` はそのファイルが 1440 行であることを示します。', 'wc -l option', 'unpublished', false),
  (105, 'セクション46: Docker Compose エラー読解', '設定ファイルが見つからないエラーの意味', '次のエラーメッセージの意味として最も適切なものはどれですか？

can''t find a suitable configuration file in this directory or any parent: not found', 'docker compose up', '["現在のディレクトリか親ディレクトリに、利用可能な Compose 設定ファイル（例: docker-compose.yml）が見つからない", "Compose ファイルは見つかったが、ポート競合で起動に失敗している", "Docker デーモンが停止しているため、ソケット接続に失敗している", "イメージのビルドは成功したが、コンテナのヘルスチェックだけ失敗している"]'::jsonb, 0, 'このエラーは、実行場所のパスに Compose 設定ファイルが無いことを示します。`docker compose up` は通常、カレントディレクトリまたは親ディレクトリから `compose.yaml` / `docker-compose.yml` などを探します。', 'Docker Compose configuration lookup', 'unpublished', false),
  (106, 'セクション47: Node.js / JSON 検証', 'JSON.parse で構文検証するコマンドの意味', '次のコマンドの目的として最も適切なものはどれですか？

node -e "JSON.parse(require(''fs'').readFileSync(''src/data/quizzes.json'',''utf8'')); console.log(''quizzes.json valid'')"', 'node -e "JSON.parse(require(''fs'').readFileSync(''src/data/quizzes.json'',''utf8'')); console.log(''quizzes.json valid'')"', '["quizzes.json を読み込んで JSON 構文が正しいか確認し、成功時にメッセージを表示する", "quizzes.json の内容を自動整形して上書き保存する", "quizzes.json を gzip 圧縮して容量を確認する", "quizzes.json の行数を数えて表示する"]'::jsonb, 0, '`readFileSync` で文字列として読み込んだ JSON を `JSON.parse` しており、構文エラーがあれば例外で失敗します。例外が出なければ `console.log(''quizzes.json valid'')` が表示されるため、簡易的なJSON妥当性チェックとして使えます。', 'Node.js JSON validation pattern', 'unpublished', false),
  (107, 'セクション48: React exhaustive-deps 実践', '欠けた依存配列が生む不具合', '`useEffect` / `useMemo` / `useCallback` で依存配列に必要な値を入れ忘れたとき、最も起きやすい問題はどれですか？', 'useEffect(() => {
  console.log(count);
}, []); // count を参照しているのに依存配列にない', '["stale closure により古い値を参照し続け、想定した再同期が起きない", "React が自動で依存を補完するので問題は起きない", "依存を省略すると常に最適化されて再レンダリングが減る", "依存配列は本番ビルドでだけ評価される"]'::jsonb, 0, '依存配列は『Effect が参照する値』を宣言するためのものです。参照値を漏らすと、値が変わっても Effect が再実行されず、古いクロージャを掴んだままになります。', 'React exhaustive-deps lint guidance', 'unpublished', false),
  (108, 'セクション48: React exhaustive-deps 実践', '関数依存で無限ループになる理由', '次のパターンで `useEffect` がループしやすい主な理由はどれですか？', 'const logItems = () => console.log(items);
useEffect(() => {
  logItems();
}, [logItems]);', '["毎レンダーで `logItems` の参照が新しくなり、依存変化として Effect が再実行されるため", "`console.log` は非同期なので必ず再レンダーが起きるため", "依存配列に関数を入れると React が例外を投げるため", "`useEffect` はデフォルトで 2 回しか実行されないため"]'::jsonb, 0, '関数をインライン定義すると参照が毎回変わります。Effect がその関数参照に依存していると、依存が毎回変化したと判断され再実行ループにつながります。必要なら `useCallback` で参照を安定化します。', 'React exhaustive-deps lint guidance', 'unpublished', false),
  (109, 'セクション48: React exhaustive-deps 実践', '"一度だけ実行"したいときの設計', '`userId` を使う analytics 送信を『実質1回』にしたい。lint を回避せずに実装する方針として最も適切なのはどれですか？', 'useEffect(() => {
  sendAnalytics(userId);
}, []); // lint で userId 不足を指摘', '["`[userId]` を依存に含め、必要なら `useRef` ガードで重複送信を制御する", "eslint-disable コメントで exhaustive-deps を無効化する", "依存配列を削除して毎レンダー送信する", "`userId` を state から外しグローバル変数にする"]'::jsonb, 0, '基本は依存を正しく宣言することです。"一度だけ"の要件がある場合は、依存を隠すのではなく `useRef` などで実行制御を行うのが安全です。', 'React exhaustive-deps lint guidance', 'unpublished', false),
  (110, 'セクション48: React exhaustive-deps 実践', 'カスタム Effect Hook の lint 対象化', '`useMyEffect` のようなカスタム Hook も exhaustive-deps のチェック対象に含めたい。設定として最も適切なのはどれですか？', '// ESLint settings または rule-level option で正規表現を指定する', '["`settings.react-hooks.additionalEffectHooks` か rule-level の `additionalHooks` に regex を設定する", "TypeScript の `types` 配列に Hook 名を追加する", "Vite config の plugins に Hook 名を列挙する", "React コンポーネント名を PascalCase にすれば自動で検出される"]'::jsonb, 0, 'eslint-plugin-react-hooks では、カスタム Effect Hook を正規表現で指定して依存配列チェック対象に含められます。共有 settings と rule-level option の両方が用意されています。', 'React exhaustive-deps lint guidance', 'unpublished', false),
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
}', '["exhaustive-deps の警告を eslint-disable コメントで無効化する", "fetchProduct を useCallback でラップし、依存配列に [productId] を指定した上で useEffect の依存配列に [fetchProduct] を追加する", "fetchProduct をそのまま useEffect の依存配列に追加する（[fetchProduct]）", "fetchProduct の定義を useEffect の内部に移動し、依存配列を [productId] にする"]'::jsonb, 3, 'React公式（Hooks FAQ）は「関数をEffect内に移動する」を第一の推奨としています。こうすることでfetchProductが依存配列の問題を引き起こさず、productIdが変わるたびに正しく再実行されます。useCallbackを使う方法（選択肢2）も正しく動作しますが、公式はメモ化より先に「関数をEffect内に移動する」シンプルな解決策を優先しています。選択肢1はuseCallbackなしで関数参照が毎レンダーで変わるため無限ループになります。選択肢0はバグを隠蔽するだけで根本的な解決になりません。', 'https://legacy.reactjs.org/docs/hooks-faq.html#is-it-safe-to-omit-functions-from-the-list-of-dependencies', 'unpublished', false),
  (112, 'セクション49: TypeScript JSX 読解', 'Intrinsic elements の基本訳', '`Intrinsic elements are looked up on the special interface JSX.IntrinsicElements.` の日本語訳として最も適切なのはどれですか？', 'Intrinsic elements are looked up on the special interface JSX.IntrinsicElements.', '["intrinsic elements は、特別なインターフェース JSX.IntrinsicElements 上で参照される。", "intrinsic elements は、JSX.IntrinsicElements を自動生成する。", "intrinsic elements は、特別なインターフェースを常に無視する。", "intrinsic elements は、JSX.IntrinsicElements に変換される。"]'::jsonb, 0, 'looked up はこの文脈では『参照される』『検索される』の意味で、intrinsic elements が JSX.IntrinsicElements を基準に扱われることを述べています。', 'TypeScript JSX Intrinsic Elements', 'unpublished', false),
  (113, 'セクション49: TypeScript JSX 読解', 'By default の意味', '本文中の `By default` の意味として最も適切なのはどれですか？', 'By default, if this interface is not specified, then anything goes and intrinsic elements will not be type checked.', '["例外的に", "初期状態では", "明示的に", "結果として"]'::jsonb, 1, '`By default` は『特別な設定がなければ通常は』『初期状態では』という意味で使われています。', 'TypeScript JSX Intrinsic Elements', 'unpublished', false),
  (114, 'セクション49: TypeScript JSX 読解', 'if this interface is not specified の訳', '`if this interface is not specified` の日本語訳として最も適切なのはどれですか？', 'By default, if this interface is not specified, then anything goes and intrinsic elements will not be type checked.', '["このインターフェースが自動生成される場合", "このインターフェースが指定されていない場合", "このインターフェースを削除した場合", "このインターフェースを継承した場合"]'::jsonb, 1, '`is not specified` は『指定されていない』を意味します。ここでは JSX.IntrinsicElements が定義されていないケースを指しています。', 'TypeScript JSX Intrinsic Elements', 'unpublished', false),
  (115, 'セクション49: TypeScript JSX 読解', '指定されていない場合の挙動', '本文では、`JSX.IntrinsicElements` が指定されていない場合、intrinsic elements はどう扱われると述べられていますか？', 'By default, if this interface is not specified, then anything goes and intrinsic elements will not be type checked.', '["常に厳密に型チェックされる", "自動的に DOM API に変換される", "何でも許され、型チェックされない", "JSX 構文エラーとして扱われる"]'::jsonb, 2, '本文の `anything goes and intrinsic elements will not be type checked` がそのまま根拠で、制約なしに受け入れられ型チェックも行われません。', 'TypeScript JSX Intrinsic Elements', 'unpublished', false),
  (116, 'セクション49: TypeScript JSX 読解', 'However の役割', '本文中の `However` はどのような役割をしていますか？', 'However, if JSX.IntrinsicElements is present, then the name of the intrinsic element is looked up as a property on the JSX.IntrinsicElements interface.', '["具体例の追加", "理由の説明", "対比の導入", "結論の強調"]'::jsonb, 2, '前文では『指定されない場合』を説明し、この文では『存在する場合』を説明しているため、However は対比を導入しています。', 'TypeScript JSX Intrinsic Elements', 'unpublished', false),
  (117, 'セクション49: TypeScript JSX 読解', 'property on the interface の訳', '`the name of the intrinsic element is looked up as a property on the JSX.IntrinsicElements interface` の日本語訳として最も適切なのはどれですか？', 'However, if JSX.IntrinsicElements is present, then the name of the intrinsic element is looked up as a property on the JSX.IntrinsicElements interface.', '["intrinsic element の名前は、JSX.IntrinsicElements を置き換えるプロパティになる。", "intrinsic element の名前は、JSX.IntrinsicElements インターフェース上のプロパティとして参照される。", "intrinsic element の名前は、プロパティではなく型引数として扱われる。", "intrinsic element の名前は、JSX.IntrinsicElements とは無関係に評価される。"]'::jsonb, 1, '`as a property on ... interface` は『そのインターフェース上のプロパティとして』という意味です。', 'TypeScript JSX Intrinsic Elements', 'unpublished', false),
  (118, 'セクション49: TypeScript JSX 読解', '本文内容との一致', '本文の内容に合うものを次から1つ選びなさい。', 'By default, if this interface is not specified, then anything goes and intrinsic elements will not be type checked. However, if JSX.IntrinsicElements is present, then the name of the intrinsic element is looked up as a property on the JSX.IntrinsicElements interface.', '["JSX.IntrinsicElements がなくても常に厳密な型チェックが行われる。", "JSX.IntrinsicElements が存在すると、要素名はそのインターフェースのプロパティとして調べられる。", "Intrinsic elements は JSX.IntrinsicElements とは無関係である。", "JSX.IntrinsicElements があると型チェックは無効になる。"]'::jsonb, 1, '本文後半がそのまま根拠です。JSX.IntrinsicElements がある場合は、要素名をそのプロパティとして照合します。', 'TypeScript JSX Intrinsic Elements', 'unpublished', false),
  (119, 'セクション49: TypeScript JSX 読解', '英文全体の要約', 'この英文全体の内容を1文で要約したものとして最も適切なのはどれですか？', 'By default, if this interface is not specified, then anything goes and intrinsic elements will not be type checked. However, if JSX.IntrinsicElements is present, then the name of the intrinsic element is looked up as a property on the JSX.IntrinsicElements interface.', '["JSX の intrinsic elements は常にランタイムでのみ処理され、型とは関係ない。", "JSX.IntrinsicElements の有無によって、intrinsic elements の型チェック方法が変わる。", "JSX.IntrinsicElements は React 専用であり、TypeScript では使用されない。", "intrinsic elements は必ずクラスコンポーネントとして解釈される。"]'::jsonb, 1, '前半は『未指定なら型チェックしない』、後半は『存在すればそのプロパティとして照合する』であり、要約すると型チェック方法が変わるという内容です。', 'TypeScript JSX Intrinsic Elements', 'unpublished', false),
  (120, 'セクション49: TypeScript JSX 読解', 'TOEIC風: By default most nearly mean', 'What does the phrase `By default` most nearly mean in this passage?', 'By default, if this interface is not specified, then anything goes and intrinsic elements will not be type checked.', '["In advance", "Normally", "By mistake", "In detail"]'::jsonb, 1, '`By default` means `normally` or `in the standard case` in this passage.', 'TypeScript JSX Intrinsic Elements', 'unpublished', false),
  (121, 'セクション49: TypeScript JSX 読解', 'TOEIC風: interface is not specified', 'What happens if the interface is not specified?', 'By default, if this interface is not specified, then anything goes and intrinsic elements will not be type checked.', '["Intrinsic elements are deleted automatically.", "Intrinsic elements are converted into properties.", "Intrinsic elements are not type checked.", "Intrinsic elements become invalid syntax."]'::jsonb, 2, 'The passage explicitly says `intrinsic elements will not be type checked.`', 'TypeScript JSX Intrinsic Elements', 'unpublished', false),
  (122, 'セクション49: TypeScript JSX 読解', 'TOEIC風: However の役割', 'What is the role of `However` in the passage?', 'However, if JSX.IntrinsicElements is present, then the name of the intrinsic element is looked up as a property on the JSX.IntrinsicElements interface.', '["It introduces a similar example.", "It adds technical detail.", "It shows a contrast.", "It repeats the previous idea."]'::jsonb, 2, '`However` marks a contrast between the case where the interface is absent and the case where it is present.', 'TypeScript JSX Intrinsic Elements', 'unpublished', false),
  (123, 'セクション49: TypeScript JSX 読解', 'TOEIC風: interface が存在する場合', 'According to the passage, what happens when `JSX.IntrinsicElements` is present?', 'However, if JSX.IntrinsicElements is present, then the name of the intrinsic element is looked up as a property on the JSX.IntrinsicElements interface.', '["The intrinsic element name is checked as a property of the interface.", "All intrinsic elements are ignored by the compiler.", "The interface is removed from the program.", "JSX syntax is disabled."]'::jsonb, 0, 'The passage states that the intrinsic element name is looked up as a property on the interface.', 'TypeScript JSX Intrinsic Elements', 'unpublished', false),
  (124, 'セクション49: TypeScript JSX 読解', 'TOEIC風: 最も正確な要約', 'Which of the following is most accurate according to the passage?', 'By default, if this interface is not specified, then anything goes and intrinsic elements will not be type checked. However, if JSX.IntrinsicElements is present, then the name of the intrinsic element is looked up as a property on the JSX.IntrinsicElements interface.', '["Type checking always happens, whether the interface exists or not.", "The interface is only used for runtime execution.", "The presence of the interface affects how intrinsic elements are checked.", "Intrinsic elements cannot be used with interfaces."]'::jsonb, 2, 'This is the best summary of the passage: whether the interface exists changes how TypeScript checks intrinsic elements.', 'TypeScript JSX Intrinsic Elements', 'unpublished', false),
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
const newBadgeTextColor = Color(0xFF1A1A1A);', '["_currentPage が 1 以外でも、displayDate が now より後なら true", "_currentPage が 1 で、displayDate が newCutoff から now の範囲内なら true", "displayDate が newCutoff より前でも _readIds に含まれなければ true", "_readIds に含まれていても newBadgeColor が黄色なら true"]'::jsonb, 1, '`isNew` は `_currentPage == 1` かつ `isDateInNewRange` のAND条件です。`isDateInNewRange` は `displayDate` が `newCutoff` 以上 `now` 以下のとき true になります。', 'User provided Flutter snippet', 'unpublished', false),
  (126, 'セクション51: TypeScript Property Key', 'Quoted Property Key と keyof', '次の型定義において `type K = keyof Settings;` の結果として最も正しいものはどれですか？', 'type Settings = {
  "api-key": string;
  retryCount: number;
};

type K = keyof Settings;', '["`string`", "`\"api-key\" | \"retryCount\"`", "`\"api-key\" & \"retryCount\"`", "`number`"]'::jsonb, 1, 'quoted property key で定義した `"api-key"` も通常のプロパティキーとして扱われるため、`keyof Settings` は `"api-key" | "retryCount"` になります。なお値としてアクセスする際は `settings["api-key"]` のようにブラケット記法を使うのが基本です。', 'TypeScript keyof / quoted property names', 'unpublished', false),
  (127, 'セクション52: Claude Code アップデート案内', 'Claude Code のバージョン更新', '次のメッセージが表示されたとき、最も適切な対応はどれですか？', 'It looks like your version of Claude Code (1.0.37) needs an update.
A newer version (1.0.88 or higher) is required to continue.

To update, please run:
    claude update', '["`claude update` を実行して必要なバージョンへ更新する", "`git pull` を実行すれば Claude Code も更新される", "そのまま `claude code` を再実行すれば自動で続行できる", "`npm install` を実行すれば必ず解決する"]'::jsonb, 0, 'このメッセージは、現在の Claude Code が `1.0.37` で、継続には `1.0.88` 以上が必要だと明示しています。したがって案内どおり `claude update` を実行して CLI 自体を更新するのが正しい対応です。', 'User provided Claude Code update message', 'unpublished', false),
  (128, 'セクション53: JavaScript 英語表現', '組み込みオブジェクトの英訳', '`組み込みオブジェクト` を英語で表すものとして最も適切なのはどれですか？', '// JavaScript で Array, Date, Math などを指す文脈', '["built-in object", "embedded property", "internal variable", "default instance"]'::jsonb, 0, '`組み込みオブジェクト` は英語で一般に `built-in object` と表現します。JavaScript では `Array` や `Date` など、言語や実行環境にあらかじめ備わっているオブジェクトを指す文脈で使われます。', 'General JavaScript terminology', 'unpublished', false),
  (129, 'セクション54: Go ランタイム メモリ統計', 'runtime.MemStats の Alloc フィールド', '以下のコードで `stats.Alloc` が表す値はどれですか？', 'var stats runtime.MemStats
runtime.ReadMemStats(&stats)
fmt.Printf("Alloc: %s\n", formatBytes(stats.Alloc))', '["OSからGoランタイムに割り当てられた総メモリ量", "現在ヒープに使用中のメモリ量（GCされていないオブジェクト）", "プログラム開始からの累計アロケーション量", "スタック領域の使用量"]'::jsonb, 1, '`Alloc` は現在ヒープ上で生きているオブジェクトが使用中のバイト数です。GCが走るたびに減少します。累計アロケーション量は `TotalAlloc`、OSから取得した総量は `Sys` です。', 'backend/main.go - logMemoryStats() / https://pkg.go.dev/runtime#MemStats', 'unpublished', false),
  (130, 'セクション54: Go ランタイム メモリ統計', 'TotalAlloc と Alloc の違い', '`stats.TotalAlloc` と `stats.Alloc` の違いとして正しいものはどれですか？', 'fmt.Printf("Alloc（ヒープ使用中）: %s\n", formatBytes(stats.Alloc))
fmt.Printf("TotalAlloc（累計）: %s\n", formatBytes(stats.TotalAlloc))', '["`TotalAlloc` はGC後に減少し、`Alloc` は単調増加する", "`Alloc` はGC後に減少するが、`TotalAlloc` はプログラム開始からの累計で減少しない", "両者は常に同じ値を返す", "`TotalAlloc` はスタックとヒープの合計、`Alloc` はヒープのみ"]'::jsonb, 1, '`Alloc` はGCが走るとオブジェクトが回収されるため減少します。`TotalAlloc` はプログラム開始から確保されたバイト数の累計で、単調増加のみです。メモリ圧力を測るには `Alloc` を、アロケーション頻度を測るには `TotalAlloc` の変化量を見ます。', 'backend/main.go - logMemoryStats() / https://pkg.go.dev/runtime#MemStats', 'unpublished', false),
  (131, 'セクション54: Go ランタイム メモリ統計', 'HeapIdle と HeapInuse', '`HeapIdle` が大きい場合、何を意味しますか？', 'fmt.Printf("HeapIdle: %s\n", formatBytes(stats.HeapIdle))
fmt.Printf("HeapInuse: %s\n", formatBytes(stats.HeapInuse))', '["ヒープのメモリ不足が近い", "Goランタイムが確保しているがオブジェクトに使われていないスパンが多い", "GCが全く動いていない", "スタックが大きく成長している"]'::jsonb, 1, '`HeapIdle` はOSから確保済みだがオブジェクトが入っていないスパンの合計です。大きい場合はメモリをOSに返せる余地があります。`debug.FreeOSMemory()` を呼ぶか、`GOGC` を下げると解放されます。`HeapInuse` は実際にオブジェクトが入っているスパンです。', 'backend/main.go - logMemoryStats() / https://pkg.go.dev/runtime#MemStats', 'unpublished', false),
  (132, 'セクション54: Go ランタイム メモリ統計', 'NumGC の意味', '`stats.NumGC` が表す値はどれですか？', 'fmt.Printf("NumGC（GCサイクル数）: %d\n", stats.NumGC)', '["現在実行中のGCゴルーチン数", "プログラム開始からの完了したGCサイクル数", "次のGCが発動するまでの残りサイクル数", "強制GC（runtime.GC()）の呼び出し回数のみ"]'::jsonb, 1, '`NumGC` はプログラム開始から完了したGCサイクルの総数です。自動GC・強制GCどちらもカウントされます。強制GCのみのカウントは `NumForcedGC` が別途あります。', 'backend/main.go - logMemoryStats() / https://pkg.go.dev/runtime#MemStats', 'unpublished', false),
  (133, 'セクション54: Go ランタイム メモリ統計', 'StackInuse とゴルーチン数の関係', '以下のコードで平均スタックサイズを計算しているとき、`numGoroutines` が増えると `avgStack` はどうなりますか？', 'numGoroutines := runtime.NumGoroutine()
if numGoroutines > 0 {
    avgStack := stats.StackInuse / uint64(numGoroutines)
    fmt.Printf("Average Stack per Goroutine: %s\n", formatBytes(avgStack))
}', '["numGoroutines が増えると avgStack は増加する", "numGoroutines が増えると avgStack は減少する（分母が増えるため）", "numGoroutines と avgStack は無関係", "StackInuse は変化しないため avgStack は常に一定"]'::jsonb, 1, '`avgStack = StackInuse / numGoroutines` なので、分母の `numGoroutines` が増えると `avgStack` は小さくなります。ただし実際はゴルーチンが増えると `StackInuse` も増加するため、実運用での `avgStack` の変化は必ずしも単調ではありません。', 'backend/main.go - analyzeNonHeapMemory()', 'unpublished', false),
  (134, 'セクション54: Go ランタイム メモリ統計', 'MSpanInuse とは', '`stats.MSpanInuse` が表すものはどれですか？', 'fmt.Printf("MSpanInuse: %s\n", formatBytes(stats.MSpanInuse))
fmt.Printf("MSpanSys: %s\n", formatBytes(stats.MSpanSys))', '["ヒープオブジェクトのメモリ量", "mspan 構造体（ヒープスパン管理メタデータ）が使用しているメモリ量", "ミューテックスのスピン待機に使われているメモリ量", "OSのメモリマップに使われているメモリ量"]'::jsonb, 1, '`MSpanInuse` はGoランタイムがヒープスパンを管理するための `mspan` 構造体が実際に使用しているメモリ量です。`MSpanSys` はOSから確保した総量で、`MSpanSys - MSpanInuse` がアイドル分になります。', 'backend/main.go - analyzeNonHeapMemory() / https://pkg.go.dev/runtime#MemStats', 'unpublished', false),
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
}', '["\"1500 B\"", "\"1.46 KB\"", "\"1.50 KB\"", "\"0.00 MB\""]'::jsonb, 1, '1500 >= 1024 なのでKB換算になります。`1500 / 1024 = 1.46484...` なので `"1.46 KB"` です。ループは `n = 1500/1024 = 1` で `1 < 1024` のため即終了し `exp=0`（K）になります。', 'backend/main.go - formatBytes()', 'unpublished', false),
  (136, 'セクション54: Go ランタイム メモリ統計', 'BuckHashSys の用途', '`stats.BuckHashSys` が表すものはどれですか？', 'fmt.Printf("BuckHashSys: %s\n", formatBytes(stats.BuckHashSys))', '["バケットソートに使われるメモリ量", "プロファイリング用バケットハッシュテーブルが使用しているメモリ量", "ハッシュマップの全エントリのメモリ量", "GCのマークビットマップに使われているメモリ量"]'::jsonb, 1, '`BuckHashSys` はGoランタイムがpprof等のプロファイリングデータを管理するバケットハッシュテーブルに使用するメモリ量です。通常は数百KB以下で、アプリのメモリ問題の主因にはなりません。', 'backend/main.go - analyzeNonHeapMemory() / https://pkg.go.dev/runtime#MemStats', 'unpublished', false),
  (137, 'セクション55: Go GC 統計', 'LastGC の型と変換', '以下のコードで `stats.LastGC` を時刻に変換しているとき、`stats.LastGC` の型はどれですか？', 'if stats.LastGC > 0 {
    lastGCTime := time.Unix(0, int64(stats.LastGC))
    fmt.Printf("Last GC: %s\n", lastGCTime.Format(time.RFC3339))
}', '["time.Time", "int64（Unix秒）", "uint64（Unixナノ秒）", "float64（Unix秒の小数）"]'::jsonb, 2, '`MemStats.LastGC` は `uint64` 型で、最後のGCが完了したUnixナノ秒を表します。`time.Unix(0, int64(stats.LastGC))` で `time.Time` に変換します。`time.Unix(sec, nsec)` の第1引数をゼロにし、第2引数にナノ秒を渡すのがポイントです。', 'backend/main.go - analyzeGC() / https://pkg.go.dev/runtime#MemStats', 'unpublished', false),
  (138, 'セクション55: Go GC 統計', 'PauseTotalNs と平均ポーズ時間', '以下のコードで平均GCポーズ時間を計算するとき、`stats.NumGC` がゼロの場合に除算しない理由はどれですか？', 'if stats.NumGC > 0 {
    avgPause := time.Duration(stats.PauseTotalNs / uint64(stats.NumGC))
    fmt.Printf("Average GC Pause: %s\n", avgPause)
}', '["NumGC がゼロだとPauseTotalNsも必ずゼロになるから", "ゼロ除算でパニックが発生するのを防ぐため", "uint64 の除算ではゼロ除算が無視されるから", "NumGC はゼロになり得ないから"]'::jsonb, 1, 'Goでは整数のゼロ除算は実行時パニック（`runtime error: integer divide by zero`）になります。`stats.NumGC > 0` のガードで安全に除算しています。なお `PauseTotalNs` が0でも除算は問題なく0を返すため、ガードは `NumGC` のみで十分です。', 'backend/main.go - analyzeGC()', 'unpublished', false),
  (139, 'セクション55: Go GC 統計', 'GCCPUFraction の意味', '`stats.GCCPUFraction` が `0.05` のとき、何を意味しますか？', 'fmt.Printf("GC CPU Fraction: %.4f%%\n", stats.GCCPUFraction*100)

// gcTuningReport() より
if stats.GCCPUFraction > 0.05 {
    fmt.Println("WARNING: GC overhead is high (>5%)")
}', '["GCが5%の確率で実行される", "プログラム実行時間の5%をGCが消費している", "ヒープの5%がGC対象になっている", "GCが毎秒5回実行されている"]'::jsonb, 1, '`GCCPUFraction` は直近のGCサイクルでGCがCPU時間の何割を使ったかを表す `float64`（0〜1）です。`0.05` なら5%のCPU時間をGCが使用しています。5%超は高負荷の目安とされ、`GOGC` を上げる（GC頻度を下げる）か、アロケーション量を減らすことが推奨されます。', 'backend/main.go - gcTuningReport() / https://pkg.go.dev/runtime#MemStats', 'unpublished', false),
  (140, 'セクション55: Go GC 統計', 'PauseNs 配列とインデックス計算', '以下のコードで最新のGCポーズ時間を取得するインデックス計算の意味はどれですか？', 'idx := int((stats.NumGC - uint32(i) - 1 + 256) % 256)', '["256サイクル分の循環バッファから最新順にインデックスを計算している", "ランダムなサンプリング位置を計算している", "256で割った余りを使って配列の境界外アクセスを防いでいるだけ", "NumGCを256進数に変換している"]'::jsonb, 0, '`PauseNs` は256要素の循環バッファで、インデックスは `NumGC % 256` の位置に最新値が入ります。`(NumGC - i - 1 + 256) % 256` で i=0が最新、i=1が一つ前…と逆順にアクセスできます。`+256` はアンダーフロー防止です。', 'backend/main.go - analyzeGCPauses() / https://pkg.go.dev/runtime#MemStats', 'unpublished', false),
  (141, 'セクション55: Go GC 統計', 'パーセンタイル計算（P50/P90/P99）', '以下のP99計算コードで `len(pauses)*99/100` を使う理由はどれですか？', 'sort.Slice(pauses, func(i, j int) bool {
    return pauses[i] < pauses[j]
})

p50 := pauses[len(pauses)*50/100]
p90 := pauses[len(pauses)*90/100]
p99 := pauses[len(pauses)*99/100]', '["浮動小数点演算を避けて整数インデックスを求めるため", "配列を256要素に正規化するため", "sort.Sliceが1-basedインデックスを使うため", "99番目の要素だけを取り出すため"]'::jsonb, 0, 'スライスのインデックスは整数なので `int(float64(len)*0.99)` より整数演算 `len*99/100` の方がシンプルです。ソート済み配列の `len*99/100` 番目が99パーセンタイル（下から99%の位置）に相当します。厳密な実装ではなく近似値ですが、GCポーズの傾向把握には十分です。', 'backend/main.go - analyzeGCPauses()', 'unpublished', false),
  (142, 'セクション55: Go GC 統計', 'debug.SetGCPercent の使い方', '以下のコードで `debug.SetGCPercent(-1)` を呼んだ後に再度 `debug.SetGCPercent(gcPercent)` を呼ぶ理由はどれですか？', 'gcPercent := debug.SetGCPercent(-1)
debug.SetGCPercent(gcPercent)
if gcPercent < 0 {
    fmt.Println("GOGC: off (GC disabled)")
} else {
    fmt.Printf("GOGC: %d%%\n", gcPercent)
}', '["GCを一時的に無効化して値を読み取るため", "`SetGCPercent` は現在値を返すので `-1` で読み取り専用アクセスし、元の値に戻している", "GCを2回トリガーするため", "負の値を渡すとGCが強制実行されるため"]'::jsonb, 1, '`debug.SetGCPercent(n)` は新しい値を設定し**直前の値**を返します。`-1` を渡すとGCが無効化されてしまうため、返ってきた元の値を即座に再設定して副作用を打ち消しています。現在値だけを読み取る専用関数がないため、このパターンが慣用的です。', 'backend/main.go - gcTuningReport() / https://pkg.go.dev/runtime/debug#SetGCPercent', 'unpublished', false),
  (143, 'セクション55: Go GC 統計', 'GOMEMLIMIT の未設定検出', '以下のコードで `unlimitedMemLimit` を `1<<63 - 1` と定義している理由はどれですか？', 'memLimit := debug.SetMemoryLimit(-1)
const unlimitedMemLimit int64 = 1<<63 - 1
if memLimit == unlimitedMemLimit {
    fmt.Println("GOMEMLIMIT: not set")
}', '["int64の最大値がGOMEMLIMIT未設定時のデフォルト値だから", "負の値を表現するため", "メモリ上限を1PBに制限するため", "オーバーフローのチェック用マジックナンバーだから"]'::jsonb, 0, '`debug.SetMemoryLimit` はGOMEMLIMITが設定されていない場合に `math.MaxInt64`（= `1<<63 - 1`）を返します。これはGoの仕様で「上限なし」を意味するセンチネル値です。この値と比較することでGOMEMLIMITが明示設定されているかを判定できます。', 'backend/main.go - gcTuningReport() / https://pkg.go.dev/runtime/debug#SetMemoryLimit', 'unpublished', false),
  (144, 'セクション55: Go GC 統計', 'NextGC とヒープ成長比率', '`stats.NextGC / stats.HeapAlloc` が `2.0` のとき、何を意味しますか？', 'if stats.HeapAlloc > 0 && stats.NextGC > 0 {
    growthRatio := float64(stats.NextGC) / float64(stats.HeapAlloc)
    fmt.Printf("Heap Growth Ratio (NextGC/HeapAlloc): %.2fx\n", growthRatio)
}', '["次のGCまでにヒープが2倍になると予測されている", "現在のヒープの2倍に達したときに次のGCが発動する", "GCが2サイクル後に実行される", "ヒープ効率が50%である"]'::jsonb, 1, '`NextGC` は次のGCが発動するヒープサイズの目標値です。デフォルトの `GOGC=100` では前回GC後のヒープサイズの2倍が `NextGC` になります。`NextGC/HeapAlloc = 2.0` は「現在の2倍になったらGC」という状態を表し、デフォルト動作です。', 'backend/main.go - gcTuningReport() / https://pkg.go.dev/runtime#MemStats', 'unpublished', false),
  (145, 'セクション55: Go GC 統計', 'NumForcedGC の意味', '`stats.NumForcedGC` が `stats.NumGC` より小さい場合、何を意味しますか？', 'fmt.Printf("Completed GC Cycles: %d\n", stats.NumGC)
fmt.Printf("Forced GC Cycles: %d\n", stats.NumForcedGC)', '["強制GCの一部が失敗した", "自動GC（ランタイムによるトリガー）が発生している", "GCが無効化されている", "NumForcedGCのカウントにバグがある"]'::jsonb, 1, '`NumGC` は全GCサイクル数、`NumForcedGC` は `runtime.GC()` 等で明示的に呼んだGCの回数です。`NumForcedGC < NumGC` はランタイムが自動でGCを実行したサイクルが存在することを意味します。通常の運用では `NumForcedGC` はほぼゼロで、`NumGC` の大半は自動GCです。', 'backend/main.go - analyzeGC() / https://pkg.go.dev/runtime#MemStats', 'unpublished', false),
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
}', '["ゴルーチンの実行速度を計測するため", "ゴルーチンリークを検出するため", "チャネルのバッファサイズを確認するため", "OSスレッド数の上限を確認するため"]'::jsonb, 1, 'ゴルーチンが適切に終了していれば、全ワーカー完了後のゴルーチン数は起動前の値に戻るはずです。`final > initial` の場合、いずれかのゴルーチンが終了していない（リーク）可能性を示します。テストでは `goleak` パッケージが同様の検出を行います。', 'backend/main.go - main()', 'unpublished', false),
  (147, 'セクション56: Go ゴルーチン管理', 'ゴルーチンのクロージャと引数渡し', '以下のコードで `go func(id int) { ... }(i)` のように引数で `i` を渡している理由はどれですか？', 'for i := 0; i < 10; i++ {
    go func(id int) {
        time.Sleep(2 * time.Second)
        done <- true
    }(i)
}', '["goroutineにIDを渡してデバッグログを出力するため", "クロージャがループ変数 i を共有するstale closure問題を避けるため", "time.Sleepに引数として使うため", "done チャネルへの送信順序を制御するため"]'::jsonb, 1, 'クロージャが `i` を直接参照すると、全ゴルーチンが同じ変数を共有しループ終了後の値（10）を見てしまいます（stale closure）。引数 `id int` として値コピーを渡すことで各ゴルーチンが独立した値を持ちます。Go 1.22以降はループ変数のスコープが変わりこの問題が緩和されましたが、明示的な引数渡しは可読性のために推奨されます。', 'backend/main.go - main()', 'unpublished', false),
  (148, 'セクション56: Go ゴルーチン管理', 'time.Sleep(100 * time.Millisecond) の役割', '全ワーカーの完了を `<-done` で待った後に `time.Sleep(100 * time.Millisecond)` を挟んでいる理由はどれですか？', 'for i := 0; i < 10; i++ {
    <-done
}

time.Sleep(100 * time.Millisecond)
final := runtime.NumGoroutine()', '["次のGCサイクルを発生させるため", "ランタイムがゴルーチンのクリーンアップを完了する時間を与えるため", "チャネルのバッファをフラッシュするため", "OSスレッドのスケジューリングを安定させるため"]'::jsonb, 1, '`done <- true` を送信しても、送信側ゴルーチンがスケジューラによって完全に終了・回収されるまでわずかな時間がかかります。即座に `NumGoroutine()` を呼ぶとまだ終了処理中のゴルーチンがカウントされ誤検知になることがあります。短いスリープでランタイムのクリーンアップを待ちます。', 'backend/main.go - main()', 'unpublished', false),
  (149, 'セクション56: Go ゴルーチン管理', 'runtime.GOMAXPROCS の意味', '`runtime.GOMAXPROCS(0)` を呼び出したとき何が返りますか？', 'fmt.Printf("GOMAXPROCS: %d\n", runtime.GOMAXPROCS(0))', '["GOMAXPROCSを0に設定して以前の値を返す", "現在のGOMAXPROCS値を変更せず返す", "利用可能なCPUコア数を返す", "実行中のOSスレッド数を返す"]'::jsonb, 1, '`GOMAXPROCS(n)` はn>0なら値を設定して以前の値を返し、n=0なら設定を変更せず現在値を返します。読み取り専用アクセスに `0` を使うのは慣用パターンです。初期値は `runtime.NumCPU()` と同じです。', 'backend/main.go - main() / https://pkg.go.dev/runtime#GOMAXPROCS', 'unpublished', false),
  (150, 'セクション56: Go ゴルーチン管理', 'unbuffered channel でのワーカー同期', '以下のコードで `done` チャネルをバッファなし（`make(chan bool)`）にしている場合、ワーカーが `done <- true` を送信するタイミングはどれですか？', 'done := make(chan bool)
for i := 0; i < 10; i++ {
    go func(id int) {
        time.Sleep(2 * time.Second)
        done <- true
    }(i)
}
for i := 0; i < 10; i++ {
    <-done
}', '["受信側が <-done を呼ぶ準備ができるまでワーカーはブロックされる", "ワーカーは done <- true を非同期で送信してすぐ終了する", "バッファなしチャネルへの送信は常にパニックになる", "メインゴルーチンが <-done を呼ぶ前にバッファに積まれる"]'::jsonb, 0, 'バッファなしチャネルは送受信が必ずランデブー（同期）します。送信側（ワーカー）は受信側（メインゴルーチン）が `<-done` を呼ぶまでブロックされます。これにより「10回 `<-done` を受け取る = 10ワーカーが全員完了」という同期が実現します。', 'backend/main.go - main()', 'unpublished', false),
  (151, 'セクション56: Go ゴルーチン管理', 'ワーカー生成後のゴルーチン数', '以下のコードで `afterSpawn` の値として期待される値はどれですか（初期ゴルーチン数が1の場合）？', 'initial := runtime.NumGoroutine()  // 1

for i := 0; i < 10; i++ {
    go func(id int) {
        time.Sleep(2 * time.Second)
        done <- true
    }(i)
}

afterSpawn := runtime.NumGoroutine()
fmt.Printf("ワーカー生成後: %d\n", afterSpawn)', '["1（ゴルーチンはまだ起動していない）", "10（ワーカーのみ）", "11（メイン + 10ワーカー）", "不定（スケジューラ次第）"]'::jsonb, 2, '`go func()` でゴルーチンを起動すると即座にスケジューラに登録されます。メインゴルーチン(1) + 10ワーカー = 11 が期待値です。ただし `NumGoroutine()` はランタイムの内部ゴルーチン（GC補助など）も含む場合があり、環境によって±数個の誤差がありえます。', 'backend/main.go - main()', 'unpublished', false),
  (152, 'セクション57: Go JWT 認証', 'jwt.RegisteredClaims の ExpiresAt', '以下のコードで発行されるJWTの有効期限はどれですか？', 'claims := jwt.RegisteredClaims{
    Subject:   s.adminUser,
    IssuedAt:  jwt.NewNumericDate(time.Now()),
    ExpiresAt: jwt.NewNumericDate(time.Now().Add(24 * time.Hour)),
}
token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
return token.SignedString(s.jwtSecret)', '["発行から1時間", "発行から24時間", "発行から7日間", "無期限"]'::jsonb, 1, '`time.Now().Add(24 * time.Hour)` で現在時刻から24時間後を `ExpiresAt` に設定しています。`jwt.NewNumericDate` はGoの `time.Time` をJWT仕様の NumericDate（Unixタイムスタンプ）に変換します。', 'backend/main.go - issueJWT()', 'unpublished', false),
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
})', '["JWTの署名を事前検証するため", "Authorizationヘッダーが存在しない・形式が違う場合を早期リターンするため", "Base64デコードを行うため", "トークンの有効期限を確認するため"]'::jsonb, 1, '`Bearer ` プレフィックスがない場合はJWT自体が存在しないか形式が不正です。`jwt.ParseWithClaims` を呼ぶ前に早期リターンすることで不要なパース処理を省き、エラーメッセージも明確になります。', 'backend/main.go - requireAuth()', 'unpublished', false),
  (154, 'セクション57: Go JWT 認証', '署名アルゴリズムの検証', '以下のキー関数で署名アルゴリズムを確認している理由はどれですか？', 'func(token *jwt.Token) (any, error) {
    if token.Method != jwt.SigningMethodHS256 {
        return nil, fmt.Errorf("unexpected signing method: %s", token.Method.Alg())
    }
    return s.jwtSecret, nil
}', '["パフォーマンス最適化のため", "alg:none 攻撃など意図しないアルゴリズムによる検証バイパスを防ぐため", "HS256以外ではシークレットキーが不要なため", "jwt.ParseWithClaims がアルゴリズムを自動検出できないため"]'::jsonb, 1, '攻撃者がヘッダーの `alg` を `none` に書き換えると、ライブラリによっては署名検証をスキップします。キー関数内で期待するアルゴリズムを明示的に確認することで、このアルゴリズム混同攻撃を防止します。これはJWT利用時のセキュリティベストプラクティスです。', 'backend/main.go - requireAuth()', 'unpublished', false),
  (155, 'セクション57: Go JWT 認証', 'http.Handle と requireAuth の合成', '以下のルーティングで `s.requireAuth(http.HandlerFunc(s.handleListQuizzes))` のように2つの型変換を行っている理由はどれですか？', 'mux.Handle(
    "GET /api/admin/quizzes",
    s.requireAuth(http.HandlerFunc(s.handleListQuizzes)),
)', '["s.handleListQuizzes はメソッドなので直接 http.Handler として渡せないため、http.HandlerFunc でラップする", "requireAuth がメソッドを受け取れないため", "mux.Handle が関数ポインタを受け取らないため", "http.HandlerFunc はパフォーマンス最適化のためのラッパー"]'::jsonb, 0, '`s.handleListQuizzes` は `func(http.ResponseWriter, *http.Request)` 型のメソッド値です。`mux.Handle` は `http.Handler` インターフェース（`ServeHTTP` メソッドを持つ型）を要求します。`http.HandlerFunc` は関数を `http.Handler` に変換する型エイリアスで、`ServeHTTP` が定義されています。', 'backend/main.go - routes()', 'unpublished', false),
  (156, 'セクション57: Go JWT 認証', 'handleLogin での認証情報比較', '以下の認証処理で `payload.Username != s.adminUser || payload.Password != s.adminPassword` の条件が真の場合、HTTPステータスコードはどれですか？', 'if payload.Username != s.adminUser || payload.Password != s.adminPassword {
    writeError(w, http.StatusUnauthorized, "invalid credentials")
    return
}', '["400 Bad Request", "401 Unauthorized", "403 Forbidden", "404 Not Found"]'::jsonb, 1, '認証情報が不正（ユーザー名・パスワードの不一致）は `401 Unauthorized` です。`403 Forbidden` は認証済みだがアクセス権限がない場合、`400 Bad Request` はリクエスト形式が不正な場合に使います。RFC 7235に基づき、認証失敗は401が正しい選択です。', 'backend/main.go - handleLogin()', 'unpublished', false),
  (157, 'セクション58: Go HTTP & CORS', 'withCORS の Origin 動的設定', '以下の CORS ミドルウェアで `Access-Control-Allow-Origin` を固定値 `*` ではなくリクエストの `Origin` ヘッダーで動的に設定している理由はどれですか？', 'origin := r.Header.Get("Origin")
if origin != "" {
    w.Header().Set("Access-Control-Allow-Origin", origin)
    w.Header().Set("Vary", "Origin")
}', '["* ではCookieや認証ヘッダーを含むリクエストが許可されないため", "* はChromiumブラウザで動作しないため", "動的設定の方がパフォーマンスが高いため", "* はHTTPSでのみ使用できないため"]'::jsonb, 0, '`Access-Control-Allow-Credentials: true` と組み合わせる場合、`Access-Control-Allow-Origin: *` はブラウザに拒否されます。Cookieや `Authorization` ヘッダーを含む認証リクエストでは、オリジンを明示する必要があります。`Vary: Origin` はキャッシュがオリジンごとに別々のレスポンスを保持するよう指示します。', 'backend/main.go - withCORS()', 'unpublished', false),
  (158, 'セクション58: Go HTTP & CORS', 'OPTIONS プリフライトリクエストの処理', '以下のコードで `OPTIONS` メソッドを特別に処理している理由はどれですか？', 'if r.Method == http.MethodOptions {
    w.WriteHeader(http.StatusNoContent)
    return
}
next.ServeHTTP(w, r)', '["OPTIONS は危険なメソッドなので即座に遮断するため", "ブラウザがCORSプリフライトとして OPTIONS を送るため、本処理前に204を返す必要があるため", "OPTIONSレスポンスはボディを含めてはいけないため", "mux が OPTIONS を認識しないため"]'::jsonb, 1, 'ブラウザはクロスオリジンリクエストの前に `OPTIONS` メソッドでプリフライトリクエストを送り、サーバーが許可しているかを確認します。CORSヘッダーを付けた `204 No Content` を返すことでブラウザに「許可済み」を伝え、本リクエストの送信に進ませます。', 'backend/main.go - withCORS()', 'unpublished', false),
  (159, 'セクション58: Go HTTP & CORS', 'writeJSON でのエンコード', '以下の `writeJSON` で `json.NewEncoder(w).Encode(payload)` を使う利点はどれですか？', 'func writeJSON(w http.ResponseWriter, status int, payload any) {
    w.Header().Set("Content-Type", "application/json")
    w.WriteHeader(status)
    if payload == nil {
        return
    }
    if err := json.NewEncoder(w).Encode(payload); err != nil {
        log.Printf("encode response: %v", err)
    }
}', '["`json.Marshal` より高速なため", "メモリに全データをバッファせず `http.ResponseWriter` に直接ストリーム書き込みできるため", "文字コードを自動変換するため", "`any` 型を受け取れるのは `Encoder` だけのため"]'::jsonb, 1, '`json.Marshal` は全データをメモリ上の `[]byte` に一度展開してから書き込みます。`json.NewEncoder(w).Encode` は `io.Writer`（ここでは `http.ResponseWriter`）に直接ストリーム出力するためメモリ効率が良いです。大きなレスポンスで特に有効です。', 'backend/main.go - writeJSON()', 'unpublished', false),
  (160, 'セクション58: Go HTTP & CORS', 'io.LimitReader によるリクエストボディ制限', '以下のコードで `io.LimitReader(r.Body, 1<<20)` を使う理由はどれですか？', 'decoder := json.NewDecoder(io.LimitReader(r.Body, 1<<20))
decoder.DisallowUnknownFields()', '["JSONのパース速度を向上させるため", "1MB超のリクエストボディによるメモリ枯渇・DoS攻撃を防ぐため", "r.Body をコピーして再利用できるようにするため", "Content-Length ヘッダーの検証をするため"]'::jsonb, 1, '`1<<20` は 1MB（1,048,576バイト）です。制限なしで `r.Body` を読むと、巨大なボディを送りつけるDoS攻撃でサーバーメモリを枯渇させられます。`LimitReader` で上限を設けることで安全にボディを処理できます。', 'backend/main.go - decodeJSON()', 'unpublished', false),
  (161, 'セクション58: Go HTTP & CORS', 'DisallowUnknownFields の効果', '`decoder.DisallowUnknownFields()` を設定した場合、JSONに未知フィールドが含まれていたときどうなりますか？', 'decoder := json.NewDecoder(io.LimitReader(r.Body, 1<<20))
decoder.DisallowUnknownFields()
if err := decoder.Decode(dst); err != nil {
    return err
}', '["未知フィールドは無視されてデコード成功", "デコードエラーが返される", "未知フィールドのみ別の変数に格納される", "パニックが発生する"]'::jsonb, 1, 'デフォルトでは `json.Decoder` は未知フィールドを無視します。`DisallowUnknownFields()` を呼ぶと、構造体に対応するフィールドが存在しないJSONキーがあった場合にエラーを返します。タイポや意図しないフィールドを早期検出するためのバリデーション手段です。', 'backend/main.go - decodeJSON()', 'unpublished', false),
  (162, 'セクション58: Go HTTP & CORS', '2回目の Decode で io.EOF を確認', '以下のコードで2回目の `decoder.Decode(&extra)` を行う目的はどれですか？', 'if err := decoder.Decode(dst); err != nil {
    return err
}
var extra json.RawMessage
if err := decoder.Decode(&extra); err != io.EOF {
    return errors.New("request body must contain a single JSON object")
}', '["追加フィールドをキャプチャするため", "リクエストボディに複数のJSONオブジェクトが含まれていないか確認するため", "デコードのキャッシュをクリアするため", "r.Body を閉じるため"]'::jsonb, 1, '1回目の `Decode` 後に `io.EOF` 以外が返る場合、ボディにまだデータが残っています。`{...}{...}` のように複数のJSONオブジェクトを連結して送る攻撃や誤りを検出できます。正常なリクエストなら2回目の `Decode` は `io.EOF` を返します。', 'backend/main.go - decodeJSON()', 'unpublished', false),
  (163, 'セクション58: Go HTTP & CORS', 'r.PathValue によるパスパラメータ取得', '以下のコードで `r.PathValue("id")` を使っています。これはGoのどのバージョンから使えますか？', 'func (s *server) handleGetQuiz(w http.ResponseWriter, r *http.Request) {
    quizID, err := parseID(r.PathValue("id"))
    if err != nil {
        writeError(w, http.StatusBadRequest, err.Error())
        return
    }
}', '["Go 1.18（Generics導入時）", "Go 1.20", "Go 1.22", "Go 1.19"]'::jsonb, 2, '`http.Request.PathValue` と `ServeMux` のパターンマッチング（`{id}` 記法）はGo 1.22で標準ライブラリに追加されました。それ以前はパスパラメータの取得に `gorilla/mux` や `chi` などサードパーティのルーターが必要でした。', 'backend/main.go - handleGetQuiz() / Go 1.22 release notes', 'unpublished', false),
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
}', '["NullStringはStringより高速にスキャンできるため", "DBのNULL値をGoの nil として安全に扱うため", "Stringではマルチバイト文字を扱えないため", "sql.Scanがstring型を直接受け取れないため"]'::jsonb, 1, 'DBのカラムが NULL の場合、`string` に直接スキャンするとエラーになります。`sql.NullString` は `{String string; Valid bool}` を持ち、`Valid=false` のとき NULL を表します。スキャン後に `code.Valid` を確認して `*string`（nil or 値）に変換しています。', 'backend/main.go - scanQuiz()', 'unpublished', false),
  (165, 'セクション59: Go SQL & JSONB', 'JSONB カラムのスキャン', '以下のコードで `options` を `[]byte` でスキャンしてから `json.Unmarshal` している理由はどれですか？', 'var optionsJSON []byte
err := scanner.Scan(
    // ...
    &optionsJSON,
    // ...
)
json.Unmarshal(optionsJSON, &item.Options)', '["[]stringには直接スキャンできないため、[]byteで受けてからGoの型に変換する", "PostgreSQLのJSONBはバイナリ形式で返されるため", "json.Unmarshalの方がsql.Scanより速いため", "[]stringはsql.Scanでnilになるため"]'::jsonb, 0, '`database/sql` は `[]string` 型への直接スキャンをサポートしていません。PostgreSQLのJSONBカラムをスキャンするには一旦 `[]byte` または `string` で受け取り、`json.Unmarshal` でGoの型に変換するのが標準的なパターンです。', 'backend/main.go - scanQuiz()', 'unpublished', false),
  (166, 'セクション59: Go SQL & JSONB', 'ON CONFLICT DO NOTHING の使い所', '以下のSQLで `ON CONFLICT (id) DO NOTHING` を指定した場合の動作はどれですか？', 'INSERT INTO quizzes (id, section, title, ...)
VALUES ($1, $2, $3, ...)
ON CONFLICT (id) DO NOTHING;', '["同じidが存在するとエラーが発生する", "同じidが存在する場合は既存行を上書きする", "同じidが存在する場合はINSERTをスキップして正常終了する", "同じidが存在する場合はNULLを挿入する"]'::jsonb, 2, '`ON CONFLICT (id) DO NOTHING` は競合（主キー重複など）が発生した場合にエラーを発生させずスキップします。冪等なシード処理に適しています。上書きしたい場合は `ON CONFLICT DO UPDATE SET ...`（UPSERT）を使います。', 'backend/migrations/002_seed_quizzes.up.sql', 'unpublished', false),
  (167, 'セクション59: Go SQL & JSONB', 'RETURNING 句の活用', '以下のINSERT文で `RETURNING` 句を使っている理由はどれですか？', 'item, err := scanQuiz(s.db.QueryRow(`
    INSERT INTO quizzes (...)
    VALUES ($1, $2, ...)
    RETURNING
        id,
        section,
        created_at,
        updated_at
`, ...))', '["INSERTの実行確認のため", "INSERT後にSELECTを別途発行せずに挿入された行のデータを1回のクエリで取得するため", "トランザクションを自動コミットするため", "created_at のデフォルト値を上書きするため"]'::jsonb, 1, '`RETURNING` はINSERT/UPDATE/DELETEで変更された行のカラム値を返すPostgreSQL拡張です。`INSERT ... RETURNING id, created_at` とすることで、DB側で生成された `BIGSERIAL` のIDやデフォルト値 `NOW()` の `created_at` を別途SELECTなしで取得できます。', 'backend/main.go - handleCreateQuiz()', 'unpublished', false),
  (168, 'セクション59: Go SQL & JSONB', 'rows.Err() の確認', '以下のコードで `rows.Close()` の後に `rows.Err()` を確認している理由はどれですか？', 'rows, err := s.db.Query(`SELECT ...`)
if err != nil { ... }
defer rows.Close()

for rows.Next() {
    // ...
}

if err := rows.Err(); err != nil {
    writeError(w, http.StatusInternalServerError, err.Error())
    return
}', '["rows.Closeのエラーを確認するため", "ループ中に発生したDBエラー（ネットワーク断など）を検出するため", "結果セットが空かどうかを確認するため", "rows.Nextの戻り値を再確認するため"]'::jsonb, 1, '`rows.Next()` がfalseを返した理由は「全行読み終わった」または「エラー発生」の2つです。`rows.Err()` でイテレーション中のエラーを確認しないと、DBサーバーとの通信断などで途中で切れた結果を正常として返してしまうバグが起きます。', 'backend/main.go - handleListQuizzes()', 'unpublished', false),
  (169, 'セクション59: Go SQL & JSONB', 'sql.ErrNoRows の判定', '以下のコードで `errors.Is(err, sql.ErrNoRows)` を使っている理由はどれですか？', 'item, err := scanQuiz(s.db.QueryRow(`SELECT ... WHERE id = $1`, quizID))
if err != nil {
    if errors.Is(err, sql.ErrNoRows) {
        writeError(w, http.StatusNotFound, "quiz not found")
        return
    }
    writeError(w, http.StatusInternalServerError, err.Error())
    return
}', '["QueryRowは必ずエラーを返すため", "レコードが見つからない場合と内部エラーを区別して適切なHTTPステータスを返すため", "sql.ErrNoRowsはpanicを防ぐためのセンチネル値のため", "errors.Isを使わないと型アサーションが失敗するため"]'::jsonb, 1, '`db.QueryRow` はレコードが0件のとき `sql.ErrNoRows` を返します。これを区別しないと「存在しないID」へのリクエストに `500 Internal Server Error` を返してしまいます。`errors.Is` でエラーの種類を判定し、`404 Not Found` と `500` を正しく使い分けます。', 'backend/main.go - handleGetQuiz()', 'unpublished', false),
  (170, 'セクション59: Go SQL & JSONB', 'setval でシーケンスをリセット', 'マイグレーションのシードSQL末尾にある以下のSQL文の目的はどれですか？', 'SELECT setval(''quizzes_id_seq'', (SELECT MAX(id) FROM quizzes));', '["シーケンスを1にリセットして最初からIDを採番し直すため", "INSERT後にシーケンスの現在値を最大IDに合わせ、次の自動採番が重複しないようにするため", "quizzes_id_seqテーブルを初期化するため", "MAX(id)の値をログに出力するため"]'::jsonb, 1, '`BIGSERIAL` のシーケンスは通常INSERTのたびにインクリメントされますが、`id` を明示指定したINSERT（シードデータ）ではシーケンスが進みません。このため次の通常INSERTが既存IDと重複する可能性があります。`setval` でシーケンスを `MAX(id)` に合わせることで重複を防ぎます。', 'backend/migrations/002_seed_quizzes.up.sql', 'unpublished', false),
  (171, 'セクション60: Go embed & golang-migrate', '//go:embed ディレクティブ', '以下のコードで `//go:embed migrations/*.sql` を使う目的はどれですか？', '//go:embed migrations/*.sql
var migrationsFS embed.FS', '["実行時にファイルシステムからSQLを読み込むため", "ビルド時にSQLファイルをバイナリに埋め込み、デプロイ時に別途ファイルを配置不要にするため", "SQLファイルを暗号化するため", "マイグレーションを自動実行するため"]'::jsonb, 1, '`//go:embed` はビルド時に指定したファイルをGoバイナリに埋め込みます。`migrations/*.sql` をバイナリに含めることで、デプロイ先サーバーにSQLファイルを別途配置する必要がなくなります。`embed.FS` は組み込みファイルへの読み取り専用アクセスを提供します。', 'backend/main.go / https://pkg.go.dev/embed', 'unpublished', false),
  (172, 'セクション60: Go embed & golang-migrate', 'migrate.ErrNoChange の処理', '以下のコードで `errors.Is(err, migrate.ErrNoChange)` を無視している理由はどれですか？', 'if err := m.Up(); err != nil && !errors.Is(err, migrate.ErrNoChange) {
    return err
}
return nil', '["ErrNoChange はフォーマットエラーのため無視できる", "全マイグレーション適用済みの場合 ErrNoChange が返り、これはエラーではなく正常状態のため", "ErrNoChange はGoの標準エラーではないため比較できないから", "m.Up() は常にエラーを返すため"]'::jsonb, 1, '`m.Up()` は全マイグレーションが既に適用されている場合（追加変更なし）に `migrate.ErrNoChange` を返します。これはエラーではなく「何もすることがない」という正常な状態です。サーバー再起動のたびに `Up()` を呼ぶ構成ではこの処理が必須です。', 'backend/main.go - runMigrations()', 'unpublished', false),
  (173, 'セクション60: Go embed & golang-migrate', 'schema_migrations テーブルの役割', 'golang-migrate が自動作成する `schema_migrations` テーブルの役割はどれですか？', '-- golang-migrate が内部で管理するテーブル
SELECT version, dirty FROM schema_migrations;
--  version | dirty
-- ---------+-------
--        2 | f', '["マイグレーションSQLの内容を保存するため", "どのバージョンのマイグレーションまで適用済みかを追跡するため", "ロールバック用にデータのスナップショットを保存するため", "マイグレーションの実行時間を記録するため"]'::jsonb, 1, '`schema_migrations` は適用済みマイグレーションのバージョン番号と `dirty`（失敗フラグ）を管理します。`version=2` なら `002_` までが適用済みを意味します。`dirty=true` はマイグレーション途中で失敗した状態を示し、手動修正が必要になります。', 'backend/main.go - runMigrations() / golang-migrate docs', 'unpublished', false),
  (174, 'セクション60: Go embed & golang-migrate', 'iofs.New の第2引数', '以下のコードで `iofs.New(migrationsFS, "migrations")` の第2引数 `"migrations"` は何を意味しますか？', 'srcDriver, err := iofs.New(migrationsFS, "migrations")', '["マイグレーション名のプレフィックス", "embed.FS 内でSQLファイルを探すディレクトリパス", "データベース名", "マイグレーションのバージョン番号"]'::jsonb, 1, '`iofs.New` の第2引数は `embed.FS` 内のどのディレクトリをルートとしてマイグレーションファイルを探すかを指定します。`//go:embed migrations/*.sql` で埋め込んだファイルは `migrations/` ディレクトリ構造で `embed.FS` に入るため、`"migrations"` を指定することで `001_create_tables.up.sql` 等が正しく検出されます。', 'backend/main.go - runMigrations()', 'unpublished', false),
  (175, 'セクション60: Go embed & golang-migrate', 'up.sql と down.sql の命名規則', 'golang-migrate のファイル命名規則として正しいものはどれですか？', 'migrations/
  001_create_tables.up.sql
  001_create_tables.down.sql
  002_seed_quizzes.up.sql
  002_seed_quizzes.down.sql', '["{version}_{description}.{direction}.sql（バージョンは連番、direction は up または down）", "{description}_{version}.sql（方向はファイル内のコメントで指定）", "{version}.sql と {version}_rollback.sql のペア", "任意のファイル名でよく、ファイル内のコメントで方向を指定"]'::jsonb, 0, 'golang-migrate の標準命名規則は `{version}_{description}.{direction}.sql` です。`version` は数値の連番（`001`, `002`...）、`direction` は `up`（適用）または `down`（ロールバック）です。バージョン番号の順序でマイグレーションが実行されます。', 'backend/migrations/ / golang-migrate docs', 'unpublished', false),
  (176, 'セクション61: Go 環境変数 & サーバー構造体', 'getEnv のフォールバックパターン', '以下の `getEnv` 関数で環境変数が空文字列 `""` の場合、`fallback` が返されますか？', 'func getEnv(key, fallback string) string {
    if value := os.Getenv(key); value != "" {
        return value
    }
    return fallback
}', '["はい、空文字列は falsy として扱われ fallback が返る", "いいえ、空文字列は設定済みとして扱われ空文字列が返る", "os.Getenv は空文字列を返さない", "パニックが発生する"]'::jsonb, 0, '`value != ""` の条件なので、環境変数が設定されていても値が空文字列の場合は `fallback` が返ります。`os.Getenv` は未設定・空設定どちらも空文字列を返すため、この実装では「未設定」と「空文字列に設定」を区別しません。区別が必要なら `os.LookupEnv` を使います。', 'backend/main.go - getEnv()', 'unpublished', false),
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
}', '["グローバル変数より読み書きが速いため", "テスト時にモックDBや異なる設定を注入しやすく、グローバル状態を避けられるため", "Goではメソッドに引数を渡せないため", "フィールドは自動的にgoroutine-safeになるため"]'::jsonb, 1, '依存関係を構造体フィールドに持たせる「依存性注入（DI）」パターンです。グローバル変数と違い、テスト時に `server{db: mockDB}` のように差し替えやすく、並行テストでの競合も避けられます。ハンドラがすべてメソッドとして `*server` に紐づくためコンテキストも明確です。', 'backend/main.go - server struct / main()', 'unpublished', false),
  (178, 'セクション61: Go 環境変数 & サーバー構造体', 'jwtSecret を []byte で保持する理由', '`jwtSecret` を `string` ではなく `[]byte` で保持している理由はどれですか？', 'jwtSecret: []byte(getEnv("JWT_SECRET", "dev-only-secret")),

// 使用箇所
return token.SignedString(s.jwtSecret)', '["[]byteの方がメモリ効率が良いため", "jwt.SignedStringが[]byteを要求し、文字列より安全にゼロクリアできるため", "環境変数はバイト列で返されるため", "Goではstring型の比較ができないため"]'::jsonb, 1, '`jwt.Token.SignedString` はHMAC系アルゴリズムで `[]byte` を要求します。また `[]byte` はメモリ上でゼロクリア（`for i := range secret { secret[i] = 0 }`）が可能ですが、Goの `string` はイミュータブルなためクリアできません。シークレット情報を `[]byte` で扱うのはセキュリティ上の慣行です。', 'backend/main.go - server struct / issueJWT()', 'unpublished', false),
  (179, 'セクション61: Go 環境変数 & サーバー構造体', 'defer db.Close() のタイミング', '以下のコードで `defer db.Close()` を呼んでいるとき、`db.Close()` が実行されるタイミングはどれですか？', 'db, err := initDB()
if err != nil {
    log.Fatal(err)
}
defer db.Close()

// ... サーバー起動
if err := http.ListenAndServe(":8080", s.routes()); err != nil {
    log.Fatal(err)
}', '["initDB() の直後", "main() 関数が返るとき（サーバーが停止したとき）", "各HTTPリクエスト処理後", "GCが実行されたとき"]'::jsonb, 1, '`defer` は宣言した関数（ここでは `main`）が返るときに実行されます。`http.ListenAndServe` はサーバーが停止するまでブロックするため、通常は `db.Close()` は呼ばれません。サーバーがシャットダウンしたとき（エラーまたはシグナル）に `main` が返り、`defer db.Close()` が実行されます。', 'backend/main.go - main()', 'unpublished', false),
  (180, 'セクション61: Go 環境変数 & サーバー構造体', 'log.Fatal の動作', '`log.Fatal(err)` と `log.Print(err); os.Exit(1)` の動作の違いはどれですか？', 'db, err := initDB()
if err != nil {
    log.Fatal(err)
}', '["log.Fatal はパニックを起こすが log.Print はログのみ", "実質同じ動作（ログ出力 + os.Exit(1)）。ただし log.Fatal は defer を実行しない", "log.Fatal は終了コード 0 で終了する", "log.Fatal はゴルーチンをすべて待ってから終了する"]'::jsonb, 1, '`log.Fatal` は内部で `log.Print + os.Exit(1)` を呼びます。`os.Exit` は `defer` を実行せずに即終了します。そのため `defer db.Close()` が登録済みでも `log.Fatal` で終了すると実行されません。グレースフルシャットダウンが必要な場合は `os.Exit` を避け、エラーを上位に返す設計が推奨されます。', 'backend/main.go - main() / https://pkg.go.dev/log#Fatal', 'unpublished', false),
  (181, 'セクション62: Go バリデーション & 文字列処理', 'strings.TrimSpace の活用', '以下の `normalizeQuizPayload` で各フィールドに `strings.TrimSpace` を適用している理由はどれですか？', 'func normalizeQuizPayload(payload *quizPayload) error {
    payload.Section = strings.TrimSpace(payload.Section)
    payload.Title = strings.TrimSpace(payload.Title)
    payload.Question = strings.TrimSpace(payload.Question)
    // ...
    if payload.Section == "" {
        return errors.New("section is required")
    }
}', '["SQLインジェクションを防ぐため", "前後の空白のみのデータが「空」として正しく検出されるようにするため", "全角スペースを除去するため", "文字列を小文字に変換するため"]'::jsonb, 1, '`TrimSpace` なしで `"  "`（空白のみ）を `== ""` で比較すると空と判定されません。バリデーション前に `TrimSpace` を適用することで「空白のみ入力」を「空」として検出します。また `payload` はポインタ渡しなので `TrimSpace` 後の値が呼び出し元にも反映されます。', 'backend/main.go - normalizeQuizPayload()', 'unpublished', false),
  (182, 'セクション62: Go バリデーション & 文字列処理', 'CorrectAnswerIndex の範囲チェック', '以下の範囲チェックで `payload.CorrectAnswerIndex >= len(payload.Options)` を含める理由はどれですか？', 'if payload.CorrectAnswerIndex < 0 || payload.CorrectAnswerIndex >= len(payload.Options) {
    return errors.New("correctAnswerIndex is out of range")
}', '["Goの配列は1始まりのため", "インデックスは0始まりなのでlen(options)はインデックスとして無効な値のため", "len()が負の値を返すことがあるため", "Options が空の場合のみチェックするため"]'::jsonb, 1, 'Goのスライスインデックスは0始まりなので、有効な範囲は `0` 〜 `len-1` です。`CorrectAnswerIndex == len(options)` は1つ外（out of bounds）になります。`< 0` と `>= len` の両方をチェックすることで配列外アクセスによるパニックを防ぎます。', 'backend/main.go - normalizeQuizPayload()', 'unpublished', false),
  (183, 'セクション62: Go バリデーション & 文字列処理', 'parseID での strconv.ParseInt', '以下の `parseID` で `strconv.ParseInt(raw, 10, 64)` を使っている理由はどれですか？', 'func parseID(raw string) (int64, error) {
    id, err := strconv.ParseInt(raw, 10, 64)
    if err != nil || id <= 0 {
        return 0, errors.New("invalid quiz id")
    }
    return id, nil
}', '["URLパスパラメータは常に16進数のため", "パスパラメータは文字列なので10進整数として安全にパースし、quiz.ID（int64）型に合わせるため", "int32では値が溢れる可能性があるため、パフォーマンスのためにint64を使う", "strconvの方がfmtパッケージより速いため"]'::jsonb, 1, '`r.PathValue` は常に文字列を返すため数値変換が必要です。`ParseInt(raw, 10, 64)` の第2引数 `10` は10進数、第3引数 `64` はビットサイズ（`int64`）を指定します。`quiz.ID` が `int64` 型なので合わせています。また `id <= 0` チェックで負数や0の無効なIDを弾きます。', 'backend/main.go - parseID()', 'unpublished', false),
  (184, 'セクション62: Go バリデーション & 文字列処理', 'options の空スライス初期化', '以下の `handleListQuizzes` で `make([]quiz, 0)` を使う理由はどれですか？', 'items := make([]quiz, 0)
for rows.Next() {
    item, err := scanQuiz(rows)
    // ...
    items = append(items, item)
}
writeJSON(w, http.StatusOK, items)', '["var items []quiz と全く同じため、どちらでもよい", "var で宣言するとnil スライスになりJSONで null になるが、make([]quiz, 0)は空配列 [] になるため", "make の方がappendのパフォーマンスが良いため", "nil スライスへの append はパニックになるため"]'::jsonb, 1, '`var items []quiz` は `nil` スライスを作るため `json.Marshal` すると `null` になります。`make([]quiz, 0)` は空（長さ0）の非nilスライスを作るため `[]` になります。クイズが0件のとき `null` ではなく `[]` を返す方がAPIクライアントにとって扱いやすいため、`make` を使っています。', 'backend/main.go - handleListQuizzes()', 'unpublished', false),
  (185, 'セクション62: Go バリデーション & 文字列処理', 'code フィールドの nil 判定', '以下のコードで `payload.Code == ""` のとき `codeValue = nil` にしている理由はどれですか？', 'var codeValue any
if payload.Code == "" {
    codeValue = nil
} else {
    codeValue = payload.Code
}

item, err := scanQuiz(s.db.QueryRow(`
    INSERT INTO quizzes (..., code, ...) VALUES (..., $4, ...)
`, ..., codeValue, ...))', '["空文字列のSQLパラメータはエラーになるため", "DBスキーマでcodeはNULL許容（TEXT, not NOT NULL）なので、コードなしのクイズはNULLを格納するため", "PostgreSQLでは空文字列とNULLは同じ扱いのため", "nil を渡すとPostgreSQLが自動でDEFAULT値を使うため"]'::jsonb, 1, 'DBスキーマで `code TEXT`（`NOT NULL` なし）のため NULL が許容されます。コードブロックがないクイズで空文字列 `""` を格納するよりも `NULL` を格納する方が「値なし」の意味が明確です。Go の `nil` を `any` 型で渡すと `database/sql` が SQL の `NULL` に変換します。', 'backend/main.go - handleCreateQuiz() / handleUpdateQuiz()', 'unpublished', false),
  (186, 'セクション62: Go バリデーション & 文字列処理', 'RowsAffected による削除確認', '以下の削除処理で `rowsAffected == 0` のとき 404 を返している理由はどれですか？', 'result, err := s.db.Exec(`DELETE FROM quizzes WHERE id = $1`, quizID)
rowsAffected, err := result.RowsAffected()
if rowsAffected == 0 {
    writeError(w, http.StatusNotFound, "quiz not found")
    return
}
writeJSON(w, http.StatusNoContent, nil)', '["DELETEは常に少なくとも1行削除するため0は異常", "存在しないIDへのDELETEはエラーを返さず0行削除するため、404で存在しないことを伝える", "rowsAffectedが0の場合DBエラーが発生するため", "PostgreSQLはrowsAffectedを返さないため"]'::jsonb, 1, '`DELETE WHERE id = $1` は条件に一致する行がなくてもエラーにならず、`RowsAffected()` が `0` を返します。クライアントに「そのIDは存在しなかった」と伝えるため `404 Not Found` を返します。削除成功時は `204 No Content`（ボディなし）がRESTの慣行です。', 'backend/main.go - handleDeleteQuiz()', 'unpublished', false),
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
}', '["SSRはビルド時、SSGはリクエスト時にHTMLを生成する", "SSRはリクエスト時にサーバーでHTMLを生成し、SSGはビルド時にHTMLを生成する", "SSRとSSGは同じもので、フレームワークによって名称が異なる", "SSGはJavaScriptを使わない静的サイトのことで、Reactは使えない"]'::jsonb, 1, 'SSRはリクエストのたびにサーバーがHTMLを生成して返すため、常に最新データを返せますがサーバー負荷がかかります。SSGはビルド時に全ページのHTMLを生成するため高速・低コストですが、データ更新にはリビルドが必要です。クイズ一覧のような更新頻度の低いコンテンツはSSGが適しています。', 'https://nextjs.org/docs/pages/building-your-application/rendering', 'unpublished', false),
  (189, 'セクション63: SPA と SEO', 'Core Web Vitals とSEO', 'Google検索のランキング要因になっている Core Web Vitals の3指標として正しい組み合わせはどれですか？', '// Lighthouseで計測できる主要指標
// LCP: ページ内の最大コンテンツが表示されるまでの時間
// CLS: レイアウトのズレ（累積レイアウトシフト）
// INP: ユーザー操作に対する応答性（旧FID）', '["FCP・TTI・TBT", "LCP・CLS・INP", "TTFB・FCP・TTI", "SEO・Performance・Accessibility"]'::jsonb, 1, 'Core Web Vitals は LCP（Largest Contentful Paint）・CLS（Cumulative Layout Shift）・INP（Interaction to Next Paint、2024年3月にFIDから移行）の3指標です。Googleは2021年よりこれらを検索ランキングの要因に組み込んでいます。SPAはJSバンドルが大きくなりがちなためLCPが悪化しやすい点に注意が必要です。', 'https://web.dev/articles/vitals', 'unpublished', false),
  (190, 'セクション63: SPA と SEO', 'React SPA から Next.js への移行の主なメリット', 'Vite + React SPA を Next.js に移行する最大のSEO上のメリットはどれですか？', '// Before: SPAの初期HTML
<div id="root"></div> // コンテンツなし

// After: Next.js SSGの初期HTML
<h1>Reactの基礎</h1>
<p>以下の問題に答えてください...</p>
// コンテンツがHTMLに含まれる', '["TypeScriptが使えるようになる", "初期HTMLにコンテンツが含まれるためGoogleボットがJSレンダリングを待たずにインデックスできる", "CSSのバンドルサイズが小さくなる", "APIルートが使えるためバックエンドが不要になる"]'::jsonb, 1, 'Next.js のSSR/SSGでは初期レスポンスのHTMLにすでにコンテンツが含まれます。Googleボットはこれを即座にパースしてインデックスできるため、SPAの「遅延レンダリング問題」が解消されます。クイズタイトル・問題文・解説がHTMLに含まれることで、検索結果にコンテンツが反映されやすくなります。', 'https://nextjs.org/docs/pages/building-your-application/rendering/server-side-rendering', 'unpublished', false),
  (191, 'セクション63: SPA と SEO', '動的メタタグと og:title', 'クイズ詳細ページ（`/quizzes/123`）でSNSシェア時に正しいタイトルを表示するために必要な対応はどれですか？', '// SPAでは全ページ共通のmetaになってしまう
<meta property="og:title" content="Quiz App" />

// Next.jsではページごとに動的に設定できる
export const metadata = {
  title: quiz.title,
  openGraph: { title: quiz.title }
}', '["JavaScriptでdocument.titleを書き換えれば十分", "SNSクローラーはJSを実行しないため、SSR/SSGでHTMLにog:titleを埋め込む必要がある", "og:titleはGoogleのみが参照するためSEOには影響しない", "React HelmetでSPAでも同じ効果が得られる"]'::jsonb, 1, 'Twitter・Facebook等のSNSクローラーはJavaScriptを実行せず、HTMLのみを解析します。SPAでJSから `og:title` を動的に設定しても、クローラーには初期HTMLの値しか見えません。Next.jsのSSR/SSGでは各ページのHTMLに正しい `og:title` が埋め込まれるため、シェア時に適切なプレビューが表示されます。', 'https://developers.google.com/search/docs/appearance/structured-data/intro-structured-data', 'unpublished', false),
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
)', '["StrictMode を使っているため", "document.getElementById と createRoot によりブラウザのDOMにReactツリーをマウントしており、サーバーではなくブラウザ上でレンダリングが行われるため", "StrictModeはサーバーでは動作しないため", "App コンポーネントをラップしているため"]'::jsonb, 1, '`document.getElementById` は `document` オブジェクトを参照しており、これはブラウザ環境のみに存在します。`createRoot` でブラウザのDOM要素にReactをマウントすることがCSRの本質です。SSRでは `hydrateRoot` を使い、サーバーで生成済みのHTMLにイベントを付与します。', 'admin-web/src/main.tsx', 'unpublished', false),
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
}', '["BrowserRouter は React Router v6 以降でしか使えないため", "BrowserRouter は window.history API を使ってブラウザ上でルーティングを管理するため、サーバーではなくブラウザがページ遷移を制御するCSRの仕組み", "Routes コンポーネントはサーバーで動作しないため", "BrowserRouter を使うと自動的にSSRが無効になるため"]'::jsonb, 1, '`BrowserRouter` は `window.history.pushState` を使ってURLを書き換え、ブラウザ側でルーティングを管理します。Next.jsではサーバーが各URLに対応するHTMLを返しますが、SPAではどのURLへのアクセスも同じ `index.html` を返し、その後JavaScriptがURLに応じたコンポーネントを表示します。', 'admin-web/src/App.tsx', 'unpublished', false),
  (196, 'セクション64: CSR を示すコード読解', 'useEffect + fetch はCSRのデータ取得', '以下の `ViewCounter.tsx` のデータ取得パターンがCSRであることを示す根拠はどれですか？', '// ViewCounter.tsx
useEffect(() => {
  const fetchViews = async () => {
    const res = await fetch(API_URL)
    const data = await res.json()
    setCount(data.count)
  }
  fetchViews()
}, [])', '["useEffect はサーバーで実行されないため、データ取得がブラウザ上でマウント後に行われる", "fetch はブラウザAPIのため", "async/await はサーバーで使えないため", "setCount はブラウザのみで動作するため"]'::jsonb, 0, '`useEffect` はコンポーネントのマウント後（ブラウザ上）にのみ実行されます。サーバーサイドでは実行されません。このため初期HTMLには `count` の値が含まれず、ブラウザでJSが実行されて初めてデータが表示されます。SSGなら `getStaticProps`、SSRなら `getServerSideProps` でビルド時・リクエスト時にデータを取得してHTMLに埋め込みます。', 'admin-web/src/components/ViewCounter.tsx', 'unpublished', false),
  (197, 'セクション64: CSR を示すコード読解', 'window.localStorage はブラウザ専用API', '以下の `session.ts` のコードがCSR環境前提である証拠はどれですか？', '// auth/session.ts
const TOKEN_STORAGE_KEY = ''quiz-admin-token''

export function getAuthToken(): string | null {
  return window.localStorage.getItem(TOKEN_STORAGE_KEY)
}

export function setAuthToken(token: string): void {
  window.localStorage.setItem(TOKEN_STORAGE_KEY, token)
}', '["localStorage は文字列のみ保存できるため", "window.localStorage はブラウザ専用APIであり、Node.js（SSR）環境では window が存在しないためエラーになる", "TOKEN_STORAGE_KEY を定数にしているため", "getAuthToken が null を返す可能性があるため"]'::jsonb, 1, '`window.localStorage` はブラウザ専用のWeb APIです。Next.jsのSSR環境（Node.js）では `window` は未定義のため、このコードをサーバーサイドで実行すると `ReferenceError: window is not defined` が発生します。Next.jsに移行する場合、`typeof window !== ''undefined''` のガードや `useEffect` 内への移動が必要です。', 'admin-web/src/auth/session.ts', 'unpublished', false),
  (198, 'セクション64: CSR を示すコード読解', 'isLoading state はCSRのUXパターン', '以下の `QuizListPage.tsx` で `isLoading` state が必要になる根本的な理由はどれですか？', '// QuizListPage.tsx
const [quizzes, setQuizzes] = useState<Quiz[]>([])
const [isLoading, setIsLoading] = useState(true)

// ...
{isLoading ? (
  <div>読み込み中...</div>
) : (
  <table>...</table>
)}', '["useState の初期値に空配列を使っているため", "CSRではページ表示後にブラウザからAPIを叩くため、データ取得中の空白期間が生まれUXのためローディング表示が必要になる", "React の仕様でテーブルは非同期でレンダリングされるため", "APIが遅いため"]'::jsonb, 1, 'CSRではブラウザがJSを実行してからAPIリクエストを送るため、必ずデータ取得前の「空の状態」が存在します。SSGであればビルド時にデータ取得済みのHTMLが返るため、初期表示時にローディング状態が不要になります。`isLoading` の存在自体がCSRのデータ取得パターンの証拠です。', 'admin-web/src/pages/QuizListPage.tsx', 'unpublished', false),
  (199, 'セクション64: CSR を示すコード読解', 'ProtectedRoute はクライアント側認証', '以下の `ProtectedRoute` コンポーネントがCSR前提である理由はどれですか？', '// components/ProtectedRoute.tsx
import { Navigate } from ''react-router-dom''
import { getAuthToken } from ''../auth/session''

export default function ProtectedRoute({ children }) {
  if (!getAuthToken()) {
    return <Navigate to="/login" replace />
  }
  return children
}', '["Navigate コンポーネントを使っているため", "getAuthToken() が window.localStorage を参照しており、認証チェックがブラウザ上のJS実行時に行われるため、サーバーでは保護できない", "children props を受け取っているため", "replace オプションを使っているため"]'::jsonb, 1, '`getAuthToken()` は `window.localStorage` を参照するCSRの実装です。SSRでは初期HTMLレスポンス時点でサーバー側が認証状態を確認してリダイレクトできますが、この実装ではブラウザでJSが実行されるまで保護ページのHTMLが一瞬表示される可能性（フラッシュ）があります。Next.jsではMiddlewareやサーバーコンポーネントでサーバー側認証が可能です。', 'admin-web/src/components/ProtectedRoute.tsx', 'unpublished', false),
  (200, 'セクション64: CSR を示すコード読解', 'Next.js移行時の window 対応', 'CSRの `session.ts` を Next.js に移行する際、`window.localStorage` が原因でSSRエラーになる場合の正しい対処法はどれですか？', '// 現在のコード（SSR環境でエラー）
export function getAuthToken(): string | null {
  return window.localStorage.getItem(''quiz-admin-token'')
}

// Next.js 移行後の対応例
export function getAuthToken(): string | null {
  if (typeof window === ''undefined'') return null
  return window.localStorage.getItem(''quiz-admin-token'')
}', '["window を global に置き換える", "typeof window === ''undefined'' でサーバー実行時を判定してnullを返す", "localStorage を sessionStorage に置き換える", "useEffect 内でのみ localStorage を使い、それ以外では Cookie を使う"]'::jsonb, 1, '`typeof window === ''undefined''` はサーバーサイド（Node.js）では `true` になります。このガードを追加することでSSRビルドエラーを回避できます。より本格的な対応としては、Cookie-based認証に切り替えてサーバーサイドでもトークンを読めるようにする方法が推奨されます（Next.js の `cookies()` API等）。', 'admin-web/src/auth/session.ts / Next.js migration', 'unpublished', false),
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
})', '["@vitejs/plugin-react を残したまま reactRouter() を追加する", "@vitejs/plugin-react を削除し reactRouter() に置き換える", "vite.config.ts は変更不要で package.json のみ変更する", "reactRouter() は vite.config.ts ではなく react-router.config.ts に書く"]'::jsonb, 1, '`reactRouter()` は `@react-router/dev/vite` が提供するViteプラグインで、`@vitejs/plugin-react` の機能を内包しています。両方を同時に使うと競合するため、`@vitejs/plugin-react` を削除して置き換えます。合わせて `npm install -D @react-router/dev` と `npm install @react-router/node` が必要です。', 'https://reactrouter.com/upgrading/component-routes', 'unpublished', false),
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
)', '["createRoot のまま App を HydratedRouter に変えるだけでよい", "createRoot を hydrateRoot に変え、App を HydratedRouter に置き換え、マウント対象を document 全体にする", "main.tsx は削除してよく、entry.client.tsx は自動生成される", "hydrateRoot は SSR が有効なときのみ必要で、SPA モードなら createRoot のまま"]'::jsonb, 1, '`hydrateRoot` はサーバーで生成済みのHTMLにReactのイベントを付与（ハイドレーション）します。`createRoot` は空のDOMにゼロからレンダリングするCSRの方式です。マウント対象が `document.getElementById(''root'')` から `document` 全体になる点も重要な変更です。`<HydratedRouter>` がルーティングを管理するため `<App>` は不要になります。', 'https://reactrouter.com/upgrading/component-routes', 'unpublished', false),
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
] satisfies RouteConfig', '["routes.ts では element プロパティで JSX を直接渡す", "routes.ts ではファイルパスの文字列でルートモジュールを指定し、コンポーネントは各ファイルの default export になる", "routes.ts は JSON 形式で記述する", "BrowserRouter を残したまま routes.ts を追加できる"]'::jsonb, 1, 'React Router v7 の `routes.ts` ではJSXではなくファイルパスの文字列でルートを定義します。各ページファイルが「ルートモジュール」となり、`default export` がコンポーネント、`loader` がデータ取得、`action` がフォーム送信処理を担います。自動コード分割もこの構造によって実現されます。', 'https://reactrouter.com/upgrading/component-routes', 'unpublished', false),
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
}', '["loader は並列実行されるためパフォーマンスが上がる", "初期HTMLにクイズデータが含まれるためGoogleボットがJSを待たずにインデックスでき、isLoading状態も不要になる", "loader はキャッシュが自動で効くためAPIリクエストが減る", "loader はTypeScriptの型推論が強化されるためバグが減る"]'::jsonb, 1, '`loader` はサーバーサイドで実行されるため、レスポンスのHTMLにクイズデータが含まれます。Googleボットはこれを即座にインデックスできます。また `useEffect` でのデータ取得がなくなるため `isLoading` state も不要になり、コードがシンプルになります。', 'https://reactrouter.com/upgrading/component-routes', 'unpublished', false),
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
} satisfies Config', '["ssr: false はビルドが速くなるだけで動作は同じ", "ssr: false はCSRのまま（既存SPAと同等）で移行の足がかりになり、ssr: true にするとSSR/SSGが有効になる", "ssr: true にするとReact Server Componentsが使えるようになる", "ssr: false は開発環境のみ有効でプロダクションでは自動でtrueになる"]'::jsonb, 1, '`ssr: false` はSPAモードで、フレームワーク機能（routes.ts、loader等）は使えますがサーバーレンダリングはしません。既存SPAからの段階的移行の足がかりとして使えます。`ssr: true` にするとサーバーレンダリングが有効になります。`prerender` で特定URLを静的HTML生成（SSG相当）することもできます。', 'https://reactrouter.com/upgrading/component-routes', 'unpublished', false),
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
}', '["外部CDNのスクリプトを読み込む", "Viteがバンドルしたクライアント側JavaScriptをHTMLに挿入し、ハイドレーションを可能にする", "Google Analyticsを自動挿入する", "サーバーサイドのスクリプトを実行する"]'::jsonb, 1, '`<Scripts />` はViteがビルドしたJSバンドルを `<script>` タグとして自動挿入するコンポーネントです。これがないとブラウザにJSが読み込まれずインタラクティブなUIが動きません。`<Meta />` はルートの `meta` エクスポート、`<Links />` はCSSリンク、`<ScrollRestoration />` はナビゲーション時のスクロール位置復元を担います。', 'https://reactrouter.com/upgrading/component-routes', 'unpublished', false),
  (207, 'セクション65: React Router v7 移行', 'catchall.tsx による段階的移行', '移行初期に `routes.ts` で `route(''*?'', ''catchall.tsx'')` を定義し、`catchall.tsx` で既存の `<App>` を返す理由はどれですか？', '// routes.ts（移行初期）
export default [
  route(''*?'', ''catchall.tsx''),
] satisfies RouteConfig

// catchall.tsx
import App from ''./App''
export default function Component() {
  return <App />
}', '["App.tsx を削除するための準備として使う", "既存の Routes/BrowserRouter をそのまま動かしながらフレームワークモードに移行し、その後ルートを1つずつ routes.ts に移行できる", "catchall は 404 ページ専用の規約のため", "全 URL を App にフォールバックすることでSSRが自動有効になる"]'::jsonb, 1, 'catchall（`*?`）で全URLを既存の `<App>` に委譲することで、フレームワークモードへの移行初日から既存機能を壊さず動かせます。その後 `routes.ts` にルートを1つずつ追加し、`App.tsx` の対応する `<Route>` を削除していく段階的移行が可能です。ドキュメントでも「最初の数ルートが最も大変」と記載されています。', 'https://reactrouter.com/upgrading/component-routes', 'unpublished', false),
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
}', '["fetch に渡す URL", "SWR がデータをキャッシュ・重複排除するためのキーで、同じキーを使うコンポーネントはキャッシュを共有する", "ローカルストレージの保存キー", "API のエンドポイントを自動検出するための型情報"]'::jsonb, 1, 'SWR の第1引数はキャッシュキーです。同じキーを持つ `useSWR` は複数のコンポーネントから呼ばれてもリクエストが1回に重複排除（dedup）されます。第2引数の fetcher 関数が実際のデータ取得を行うため、キーはURLである必要はありませんが、慣習的にAPIパスを使います。', 'admin-web/src/hooks/useQuizzes.ts / https://swr.vercel.app/docs/getting-started', 'unpublished', false),
  (209, 'セクション66: SWR & コード分割', 'revalidateOnFocus: false の効果', '`revalidateOnFocus: false` を指定する理由として最も適切なものはどれですか？', 'useSWR<Quiz[]>(
  ''/api/admin/quizzes'',
  () => listQuizzes(),
  {
    revalidateOnFocus: false,
    revalidateOnReconnect: true,
  },
)', '["フォーカスイベントが発生するたびにフェッチすると入力中のフォームがリセットされるため", "タブ切り替えのたびに不要なAPIリクエストが発生し、管理画面では頻繁な再取得が不要なため", "revalidateOnFocus はモバイルブラウザで動作しないため", "false にしないと SWR のキャッシュが無効になるため"]'::jsonb, 1, 'SWR はデフォルトでブラウザタブにフォーカスが戻るたびにデータを再取得します。管理画面のクイズ一覧ではタブ切り替えのたびにAPIを叩く必要はありません。`revalidateOnReconnect: true` はネットワーク復帰時の再取得で、オフライン→オンラインの遷移では再取得が有用です。', 'admin-web/src/hooks/useQuizzes.ts / https://swr.vercel.app/docs/revalidation', 'unpublished', false),
  (210, 'セクション66: SWR & コード分割', 'mutate による楽観的更新', '以下の削除処理で `mutate(filteredData, false)` の第2引数 `false` の意味はどれですか？', 'await deleteQuiz(quizToDelete.id)
await mutate(
  quizzes.filter((quiz) => quiz.id !== quizToDelete.id),
  false
)', '["エラーハンドリングを無効にする", "キャッシュを更新した後にサーバーへの再検証（再フェッチ）をスキップする", "mutate の戻り値を Promise ではなく boolean にする", "削除操作をキャンセルする"]'::jsonb, 1, '`mutate(data, false)` の第2引数は `revalidate` オプションです。`false` にするとローカルキャッシュを更新するだけでサーバーへの再フェッチを行いません。すでに `deleteQuiz` でサーバーの削除は完了しているため、改めてリスト全体を取得し直す必要がなく、UIが即座に反映されます。', 'admin-web/src/pages/QuizListPage.tsx / https://swr.vercel.app/docs/mutation', 'unpublished', false),
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
}, [loadQuizzes])', '["useState の deleteErrorMessage のみ", "quizzes・isLoading・errorMessage の3つの useState と、loadQuizzes の useCallback と、useEffect のすべて", "useEffect のみ", "useState のみ"]'::jsonb, 1, 'SWR は `data`（quizzes）・`isLoading`・`error` を内部で管理し、マウント時の自動フェッチも行います。そのため `useState` x3 + `useCallback` + `useEffect` の計5つのフックが `useQuizzes()` の1行に置き換わりました。削除関連の `deleteErrorMessage`・`quizToDelete`・`isDeleting` は SWR とは無関係なため残ります。', 'admin-web/src/pages/QuizListPage.tsx / admin-web/src/hooks/useQuizzes.ts', 'unpublished', false),
  (212, 'セクション66: SWR & コード分割', 'React.lazy によるコード分割', '以下のコードで `lazy(() => import(''./pages/QuizListPage''))` を使ったとき、ビルド出力にどのような変化が起きますか？', '// 変更前: 静的インポート
import QuizListPage from ''./pages/QuizListPage''
import QuizFormPage from ''./pages/QuizFormPage''

// 変更後: 動的インポート
const QuizListPage = lazy(() => import(''./pages/QuizListPage''))
const QuizFormPage = lazy(() => import(''./pages/QuizFormPage''))', '["ビルド出力に変化はない", "QuizListPage と QuizFormPage が別チャンクに分離され、該当ページへの遷移時に初めてダウンロードされる", "全ページが1つのチャンクにまとめられてバンドルサイズが増える", "lazy を使うと開発時のHMRが無効になる"]'::jsonb, 1, '`React.lazy` + 動的 `import()` により Vite がページ単位の別チャンクを生成します。実際のビルド出力では `QuizListPage-xxx.js`（261KB）と `QuizFormPage-xxx.js`（8KB）が分離され、初期バンドル `index-xxx.js`（304KB）には含まれません。ログインページを開いたときにクイズ関連のJSをダウンロードしなくて済み、初期表示が高速化します。', 'admin-web/src/App.tsx', 'unpublished', false),
  (213, 'セクション66: SWR & コード分割', 'Suspense の fallback', '以下の `Suspense` の `fallback` が表示されるのはどのタイミングですか？', '<Suspense fallback={<div>読み込み中...</div>}>
  <Routes>
    <Route path="/quizzes" element={<QuizListPage />} />
  </Routes>
</Suspense>', '["QuizListPage が API からデータを取得している間", "React.lazy で分割されたチャンク（QuizListPage の JS ファイル）がダウンロード完了するまで", "React の初回レンダリング中に常に表示される", "エラーが発生したときのフォールバック表示"]'::jsonb, 1, '`Suspense` は `React.lazy` で分割されたコンポーネントのJSチャンクがネットワークからダウンロードされるまでの間に `fallback` を表示します。一度ダウンロードされればキャッシュされるため、2回目以降は fallback は表示されません。APIのデータ取得待ちは SWR の `isLoading` で別途ハンドリングします。', 'admin-web/src/App.tsx / https://react.dev/reference/react/Suspense', 'unpublished', false),
  (214, 'セクション66: SWR & コード分割', 'data ?? [] の nullish coalescing', '以下のコードで `data ?? []` を使っている理由はどれですか？', 'const { data, error, isLoading, mutate } = useSWR<Quiz[]>(
  ''/api/admin/quizzes'',
  () => listQuizzes(),
)

return {
  quizzes: data ?? [],
}', '["data が空配列 [] のとき [] に変換するため", "data が undefined（初回フェッチ前）のとき空配列を返すことで、呼び出し側で undefined チェックを不要にするため", "data が null のとき SWR がエラーを投げるのを防ぐため", "TypeScript の型エラーを回避するためのキャスト"]'::jsonb, 1, 'SWR の `data` は初回フェッチが完了するまで `undefined` です。`??`（nullish coalescing）は左辺が `null` または `undefined` のとき右辺を返します。これにより `useQuizzes()` の戻り値 `quizzes` は常に `Quiz[]` 型が保証され、呼び出し側で `quizzes?.map(...)` のようなオプショナルチェーンが不要になります。', 'admin-web/src/hooks/useQuizzes.ts', 'unpublished', false),
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
// └──────────────────────┘ ← 画面の下端 = div の下端', '["header を画面上部に固定するため", "コンテンツが少なくても div がビューポート全体の高さを確保し、背景色やレイアウトが画面下端まで適用されるようにするため", "スクロールバーを常に表示するため", "main の幅を画面幅に合わせるため"]'::jsonb, 1, '`min-h-screen` は `min-height: 100vh` に相当し、「この要素の高さは最低でもビューポート（画面）と同じにする」という意味です。クイズが0件など中身が短い場合でも、外側の `<div>` が画面下端まで伸びるため背景色やレイアウトが途切れません。中身が画面より長い場合は自然にスクロールされます。', 'admin-web/src/layouts/AdminLayout.tsx / https://tailwindcss.com/docs/min-height', 'unpublished', false),
  (216, 'セクション67: Tailwind CSS レイアウト', 'sticky top-0 の動作', '以下の `header` に付いている `sticky top-0` の動作はどれですか？', '<header className="sticky top-0 z-10 border-b border-[#14213d]/8 bg-[#fffaf0]/78 backdrop-blur-[18px]">
  <!-- ナビゲーション -->
</header>', '["header が常に画面最上部に固定され、コンテンツの上に重なる（position: fixed と同じ）", "スクロールして header が画面上端に達したとき、そこに貼り付いてスクロールに追従する", "header がページの一番上に配置されるだけで固定はされない", "top-0 は header の上部余白を 0 にするだけ"]'::jsonb, 1, '`sticky` は `position: sticky` に相当し、通常のフロー内に配置されますが、スクロールで `top: 0` の位置に達すると画面上端に貼り付きます。`fixed` と違い、最初はコンテンツの流れに沿って配置されるため他の要素を押し出しません。`backdrop-blur-[18px]` で半透明の背景ぼかし効果を加え、下のコンテンツがうっすら透けて見えるデザインになっています。', 'admin-web/src/layouts/AdminLayout.tsx / https://tailwindcss.com/docs/position', 'unpublished', false),
  (217, 'セクション67: Tailwind CSS レイアウト', 'mx-auto max-w-[1200px] の組み合わせ', '以下のクラスの組み合わせが実現するレイアウトはどれですか？', '<div className="mx-auto w-full max-w-[1200px] px-4 sm:px-6 lg:px-8">
  <!-- コンテンツ -->
</div>', '["幅 1200px で左寄せされる", "幅が最大 1200px で中央寄せされ、画面幅が狭い場合はレスポンシブに縮む", "常に画面幅いっぱいに広がる", "1200px 未満の画面ではコンテンツが非表示になる"]'::jsonb, 1, '`w-full` で親の幅いっぱいに広がりつつ、`max-w-[1200px]` で上限を制限します。`mx-auto` は左右マージンを auto にして中央寄せします。`px-4 sm:px-6 lg:px-8` はブレークポイントごとにパディングを変えるレスポンシブ対応です。この3点セットは中央寄せコンテナの定型パターンです。', 'admin-web/src/layouts/AdminLayout.tsx / https://tailwindcss.com/docs/max-width', 'unpublished', false),
  (218, 'セクション67: Tailwind CSS レイアウト', 'backdrop-blur の効果', '`backdrop-blur-[18px]` と `bg-[#fffaf0]/78` を組み合わせた header の視覚効果はどれですか？', '<header className="sticky top-0 z-10 bg-[#fffaf0]/78 backdrop-blur-[18px]">
  <!-- ナビゲーション -->
</header>', '["header の文字がぼやけて読みにくくなる", "header の背景が半透明（78%不透明度）で、背後のコンテンツが18pxのぼかしで透けて見えるすりガラス効果", "header の影が18pxぼかされる", "header の下のコンテンツが非表示になる"]'::jsonb, 1, '`bg-[#fffaf0]/78` は背景色を78%の不透明度で適用し、`backdrop-blur-[18px]` は要素の背後にある領域を18pxぼかします。スクロール時に下のコンテンツがすりガラス越しにうっすら見える効果が生まれます。`z-10` で他のコンテンツより前面に表示されることが保証されます。', 'admin-web/src/layouts/AdminLayout.tsx / https://tailwindcss.com/docs/backdrop-blur', 'unpublished', false),
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
</NavLink>', '["React Router が className に文字列を受け取れないため", "現在のURLと NavLink の to が一致（アクティブ）しているかどうかで、スタイルを動的に切り替えるため", "アニメーションのために関数が必要なため", "TypeScript の型推論のため"]'::jsonb, 1, 'React Router の `NavLink` は `className` に関数を渡すと `{ isActive, isPending }` を引数で受け取れます。現在の URL が `/quizzes` なら `isActive: true` になり青いグラデーション背景が適用され、そうでなければ白い背景のスタイルが適用されます。`end` プロパティは完全一致のみアクティブにする指定で、`/quizzes/new` のとき「一覧」がアクティブにならないようにします。', 'admin-web/src/layouts/AdminLayout.tsx / https://reactrouter.com/components/nav-link', 'unpublished', false),
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
</Route>', '["AdminLayout 自身を再帰的にレンダリングする", "URL に応じた子ルートのコンポーネント（/quizzes なら QuizListPage、/quizzes/new なら QuizFormPage）を表示する", "常に全子ルートを同時に表示する", "404 ページのフォールバックを表示する"]'::jsonb, 1, '`<Outlet />` は React Router のネストされたルート構造で、現在の URL に一致する子ルートのコンポーネントを描画する「穴」です。`AdminLayout` は header + main の共通レイアウトを提供し、`<Outlet />` の部分だけがページ遷移で入れ替わります。これにより header のナビゲーションは再レンダリングされず、ページコンテンツだけが切り替わります。', 'admin-web/src/layouts/AdminLayout.tsx / admin-web/src/App.tsx', 'unpublished', false),
  (221, 'セクション68: CSS テーブルレイアウト', 'table-fixed と table-auto の違い', '以下のテーブルに `table-fixed` を追加した場合の動作変化はどれですか？', '// 変更前: 列幅がセル内容で自動決定
<table className="min-w-full border-collapse">

// 変更後: 列幅が th の width 指定で固定
<table className="min-w-full border-collapse table-fixed">', '["テーブルの高さが固定される", "列幅の計算方法が「セル内容の長さベース」から「th の width 指定ベース」に変わり、長いテキストは改行される", "テーブルがスクロール不可になる", "border-collapse が無効になる"]'::jsonb, 1, '`table-fixed` は `table-layout: fixed` に相当します。デフォルトの `table-layout: auto` はセル内容の長さに応じて列幅が決まりますが、`fixed` では最初の行（通常 `<th>`）の `width` 指定で列幅が決まります。長いテキスト（例:「セクション52: Claude Code アップデート案内」）は列幅に収まるよう自動改行されます。', 'admin-web/src/pages/QuizListPage.tsx / https://tailwindcss.com/docs/table-layout', 'unpublished', false),
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
</table>', '["各列が 1/6（約16.67%）で均等幅になる", "最初の列だけが 1/6 で残りは自動調整される", "w-1/6 は 6px を意味するため非常に狭くなる", "table-fixed がないと w-1/6 は無視される"]'::jsonb, 0, '`w-1/6` は `width: 16.666667%` に相当します。6列 × 16.67% = 100% で均等に分割されます。`table-fixed` と組み合わせることで、セル内容の長さに関係なく列幅が固定されます。`table-fixed` がなくても `w-1/6` は適用されますが、セル内容が長いと `auto` レイアウトに上書きされることがあります。', 'admin-web/src/pages/QuizListPage.tsx / https://tailwindcss.com/docs/width', 'unpublished', false),
  (223, 'セクション68: CSS テーブルレイアウト', 'table-layout: fixed のパフォーマンス', '`table-layout: fixed` が `table-layout: auto` よりレンダリングが速い理由はどれですか？', '// auto: 全セルの内容を読んでから列幅を計算
<table className="border-collapse"> <!-- table-layout: auto -->

// fixed: 最初の行だけ見て列幅を決定
<table className="border-collapse table-fixed">', '["fixed はブラウザキャッシュを使うため", "fixed は最初の行の幅情報だけで列幅を確定でき、全行のセル内容を先読みする必要がないため", "fixed は CSS を省略できるため", "fixed はテーブルの行数を制限するため"]'::jsonb, 1, '`table-layout: auto` はブラウザが全行の全セルを読み込んでから最適な列幅を計算するため、行数が多いとレンダリングが遅くなります。`table-layout: fixed` は最初の行（`<th>`）の `width` だけで列幅を確定するため、残りの行は逐次描画できます。クイズ一覧のように行数が多いテーブルでは体感速度の差が出ます。', 'https://developer.mozilla.org/docs/Web/CSS/table-layout', 'unpublished', false),
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
}', '["コンポーネントから複数要素を返したいが、`div` で包むと `table > tr > td` のような正しい HTML 構造を壊すため", "React が `div` 要素を将来的に廃止する予定だったため", "JSX では `td` 要素を2つ以上書けない仕様だったため", "Fragments は DOM ノード数を常に 0 にし、イベント処理も完全に無効化するため"]'::jsonb, 0, 'React の旧公式 Fragments ドキュメントでは、余計なラッパー要素を入れると表のような文脈で不正な HTML になることが導入の動機として説明されています。Fragments は複数要素をグループ化しつつ、DOM に不要なラッパーノードを追加しないため、この問題を避けられます。現行の react.dev でも、Fragment は wrapper node なしで要素をまとめる手段として説明されています。', 'https://legacy.reactjs.org/docs/fragments.html / https://react.dev/reference/react/Fragment', 'unpublished', false),
  (225, 'セクション70: Googlebot と JavaScript レンダリング', 'Googlebot の JS レンダリング ファイルサイズ制限の変更', 'Googlebot が JavaScript をレンダリングする際、2026年2月に変更されたファイルサイズ制限は何 MB から何 MB になりましたか？', NULL, '["10MB から 20MB", "15MB から 50MB", "50MB から 100MB", "制限なしから 15MB に新設された"]'::jsonb, 1, '2026年2月、Google は Web Rendering Service (WRS) のリソースサイズ上限を従来の 15MB から 50MB に引き上げました。これにより、大規模な SPA バンドルでもレンダリング対象に入りやすくなりましたが、レンダリングキューの遅延（数時間〜数日）は依然として存在するため、SEO が重要なページでは SSR/SSG が推奨されます。', 'https://developers.google.com/search/docs/crawling-indexing/javascript/javascript-seo-basics', 'unpublished', false),
  (226, 'セクション70: Googlebot と JavaScript レンダリング', 'ダイナミックレンダリングの代替手法', 'Google 公式ドキュメントで、ダイナミックレンダリング（User-Agent によるサーバー側切替）の代わりに推奨されている3つの手法の組み合わせとして正しいものはどれですか？', NULL, '["SSR（サーバーサイドレンダリング）、SSG（静的サイト生成）、ハイドレーション", "CSR（クライアントサイドレンダリング）、ISR（インクリメンタル静的再生成）、Edge Functions", "プリレンダリング、AMP、Service Worker キャッシュ", "Headless Chrome、Puppeteer、Lighthouse CI"]'::jsonb, 0, 'Google の JavaScript SEO ドキュメントでは、ダイナミックレンダリングは「回避策 (workaround)」であり長期的な解決策ではないとされています。代わりに SSR（サーバーサイドレンダリング）、SSG（静的サイト生成）、ハイドレーション（SSR で生成した HTML にクライアント側で JS を接続する手法）の3つが推奨されています。', 'https://developers.google.com/search/docs/crawling-indexing/javascript/dynamic-rendering', 'unpublished', false),
  (227, 'セクション71: SWR（stale-while-revalidate）', 'SWR の名前の由来', 'SWR という名前の由来となった HTTP キャッシュ戦略の正式名称はどれですか？', NULL, '["stale-while-revalidate", "service-worker-refresh", "synchronous-web-request", "server-wide-replication"]'::jsonb, 0, 'SWR は HTTP の Cache-Control ヘッダーで使われる `stale-while-revalidate` 戦略に由来します。RFC 5861 で定義されたこの戦略は、キャッシュが stale（期限切れ）でもまず古いデータを返し（stale）、バックグラウンドで最新データを取得（revalidate）するというものです。Vercel の SWR ライブラリはこの考え方をクライアント側データフェッチに応用しています。', 'https://swr.vercel.app/', 'unpublished', false),
  (228, 'セクション71: SWR（stale-while-revalidate）', 'SEO と SWR の相性', 'SEO が重要なコンテンツに SWR（CSR でのデータフェッチ）を使うべきでない理由として最も適切なものはどれですか？', NULL, '["SWR はデータを暗号化するため、検索エンジンがコンテンツを読めなくなる", "SWR は初回レンダリング時に HTML が空であり、Googlebot の JS レンダリングキューに依存するためインデックスが遅延する", "SWR はサーバーサイドでしか動作しないため、ブラウザに HTML が届かない", "SWR のキャッシュ戦略が robots.txt と競合するため"]'::jsonb, 1, 'SWR を CSR で使う場合、初期 HTML は `<div id="root"></div>` のような空の状態でブラウザに届きます。コンテンツは JavaScript 実行後に描画されるため、Googlebot は JS レンダリングキュー（数時間〜数日の遅延）を経由してからでないとコンテンツを認識できません。また、Twitter や Slack 等のクローラーは JS を実行しないため、OGP タグも機能しません。ただし、ログイン必須の管理画面のように SEO が不要な画面では SWR + CSR で問題ありません。', 'https://swr.vercel.app/ / https://developers.google.com/search/docs/crawling-indexing/javascript/javascript-seo-basics', 'unpublished', false),
  (229, 'セクション72: CSS position: sticky と関連プロパティ', 'top: 0 の 0 に単位は必要か', 'Tailwind CSS の `top-0` は `top: 0px` を生成します。CSS の仕様上、`top: 0` と `top: 0px` の違いについて MDN Web Docs の記述に基づく正しい説明はどれですか？', '/* Tailwind が生成する CSS */
.top-0 {
  top: 0px;
}

/* 手書きでも有効な CSS */
.header {
  top: 0;
}', '["`top: 0` は無効な CSS であり、必ず `top: 0px` のように単位を付けなければならない", "`0` は次元を持たない特別な値なので単位を省略でき、`top: 0` と `top: 0px` は同じ意味になる", "`top: 0` は `top: 0%` と解釈されるため、`top: 0px` とは異なる", "`top: 0` は `top: auto` のエイリアスとして扱われる"]'::jsonb, 1, 'MDN Web Docs によると、CSS の `<length>` 値には通常単位が必要ですが、値が `0` の場合は例外です。0 はどの単位でも同じ距離（ゼロ）を表すため、単位を省略できます。したがって `top: 0` と `top: 0px` は完全に等価です。Tailwind CSS は明示的に `0px` を生成しますが、手書き CSS では `top: 0` で問題ありません。', 'https://developer.mozilla.org/en-US/docs/Web/CSS/top', 'unpublished', false),
  (230, 'セクション72: CSS position: sticky と関連プロパティ', 'z-index の値は相対的か絶対的か', '管理画面のヘッダーに `z-10`（`z-index: 10`）が設定されています。これを `z-5`（`z-index: 5`）に変更しても問題ないかを判断するために、MDN Web Docs の z-index の説明に基づく正しい理解はどれですか？', '/* 現在の設定 */
header { z-index: 10; }

/* 変更案 */
header { z-index: 5; }', '["z-index の数値は CSS 仕様で用途ごとに予約されており、ヘッダーには必ず 10 以上を使わなければならない", "z-index は同一スタッキングコンテキスト内での相対的な順序を決めるだけなので、他の要素より大きければ 5 でも 10 でも結果は同じ", "z-index: 5 は z-index: 10 の半分の透明度で描画される", "z-index は 0〜9 の範囲しか有効でないため、10 は実質 0 と同じ扱いになる"]'::jsonb, 1, 'MDN Web Docs によると、z-index はスタッキングコンテキスト内での要素の重なり順を決める整数値であり、数値自体に絶対的な意味はありません。重要なのは同じスタッキングコンテキスト内の他の要素との相対的な大小関係です。ヘッダーより前面に出る要素がなければ z-index: 5 でも z-index: 10 でも視覚的な結果は同じです。ただし、将来モーダル（z-40）やドロップダウンメニュー（z-20）を追加する可能性を考慮して、ヘッダーに z-10 程度の余裕を持たせるのが一般的な慣習です。', 'https://developer.mozilla.org/en-US/docs/Web/CSS/z-index', 'unpublished', false),
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
  (232, 'セクション72: CSS position: sticky と関連プロパティ', 'z-index: auto と z-index: 0 の違い', 'MDN Web Docs によると、`z-index: auto`（デフォルト値）と `z-index: 0` の違いとして正しいものはどれですか？', NULL, '["まったく同じであり、どちらもスタッキングコンテキストを生成する", "auto はスタッキングコンテキストを生成しないが、0 は新しいスタッキングコンテキストを生成する", "auto はスタック順が 0 になるが、0 はスタック順が -1 になる", "auto は positioned 要素にのみ有効で、0 は static 要素にも有効"]'::jsonb, 1, 'MDN Web Docs によると、z-index: auto のスタックレベルは 0 ですが、新しいスタッキングコンテキストは生成しません。一方 z-index: 0（整数値）はスタックレベルが 0 であると同時に、新しいローカルスタッキングコンテキストを生成します。この違いは子要素の重なり順に影響します。auto の場合、子要素の z-index は親の外側の要素と直接比較されますが、0 の場合は新しいスタッキングコンテキスト内に閉じ込められます。', 'https://developer.mozilla.org/en-US/docs/Web/CSS/z-index', 'unpublished', false),
  (233, 'セクション72: CSS position: sticky と関連プロパティ', 'position: static で top が効かない理由', '次の CSS で `.box` が 30px 下にずれない理由として、MDN Web Docs の記述に基づく正しい説明はどれですか？', '.box {
  /* position 未指定 → デフォルトは static */
  top: 30px;
  left: 20px;
}', '["top と left を同時に指定しているため、値が打ち消し合ってゼロになる", "position が static（デフォルト）の場合、top / right / bottom / left プロパティは効果を持たない", "px 単位は position と併用できず、% 単位でなければならない", "top: 30px は構文エラーであり、ブラウザに無視される"]'::jsonb, 1, 'MDN Web Docs の top プロパティのページでは、position の値ごとの効果が明記されています。position: static の場合、top プロパティは「has no effect（効果なし）」です。top / right / bottom / left が機能するのは position が relative, absolute, fixed, sticky のいずれかの場合に限られます。CSS として記述すること自体は有効ですが、static 要素に対しては完全に無視されます。', 'https://developer.mozilla.org/en-US/docs/Web/CSS/top', 'unpublished', false),
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
  (235, 'セクション73: Dart late と null safety', 'late がコンパイル時ではなくランタイムで制約を強制する意味', 'Dart 公式 docs では `late` について “enforce this variable''s constraints at runtime instead of at compile time” と説明されています。次の宣言に対する理解として最も正しいものはどれですか？', 'late SharedPreferences sharedPref;', '["宣言と同時に `SharedPreferences.getInstance()` が自動実行され、`sharedPref` に即座に値が入る", "コンパイル時の definite assignment チェックの代わりに、未初期化のまま読み出したときにランタイムで検査される", "`late` を付けると変数自体が存在しなくなり、初回代入時までメモリは一切使われない", "`late` を付けた変数は暗黙に nullable になり、未代入時は常に `null` を返す"]'::jsonb, 1, '`late` は「あとで必ず初期化する」という前提で、コンパイル時の初期化保証を緩め、その代わりに実行時チェックへ回す仕組みです。このため `late SharedPreferences sharedPref;` という宣言だけでは `SharedPreferences` の取得処理は走りません。実際の値は後で代入する必要があり、代入前に読み出すと `LateInitializationError` になります。', 'https://dart.dev/null-safety/understanding-null-safety / https://dart.dev/language/variables', 'unpublished', false),
  (236, 'セクション73: Dart late と null safety', 'preferences と references の意味の違い', '`late SharedPreferences sharedPref;` を説明する文脈で、`preferences` と `references` の違いとして最も正しいものはどれですか？', 'late SharedPreferences sharedPref;', '["`preferences` は参照、`references` は設定値を意味するので、2語はほぼ同義で入れ替えてよい", "`preferences` は設定や選好、`references` は参照を意味するため、`SharedPreferences` を「設定保存」と説明しつつ、変数にはオブジェクトへの reference が入ると区別するのが正しい", "`preferences` はメモリアドレス、`references` はディスク領域を意味する技術用語である", "`references` は Dart では予約語なので、公式 docs では `preferences` の代わりに使われている"]'::jsonb, 1, '`preferences` は一般英語として「設定・好み・選好」を表します。一方 `references` は「参照」です。したがって `SharedPreferences` という API 名は「共有設定」を指しており、変数 `sharedPref` に入るものを説明する時は「SharedPreferences オブジェクトへの参照が入る」と言うのが正確です。名前に `Preferences` が含まれていることと、実行時に変数が保持する reference は別概念です。', 'Dart variables store references / SharedPreferences naming', 'unpublished', false),
  (237, 'セクション74: Flutter プラットフォームとバインディング', 'Flutter における「プラットフォーム」の意味', 'Flutter の文脈で「プラットフォーム側」とは何を指すか。', NULL, '["Dart で記述された UI コンポーネント群", "Android・iOS など OS 側のネイティブ環境", "Flutter SDK のビルドツールチェーン", "pub.dev で配布されるパッケージ群"]'::jsonb, 1, 'Flutter では Dart で UI を記述するが、SharedPreferences・カメラ・通知・位置情報など端末固有の機能を使う際は OS 側（Android、iOS、Web、macOS 等）とやり取りする。この OS 側のネイティブ環境を「プラットフォーム」と呼ぶ。', 'https://docs.flutter.dev/platform-integration/platform-channels', 'unpublished', false),
  (238, 'セクション74: Flutter プラットフォームとバインディング', 'WidgetsFlutterBinding.ensureInitialized() の役割', 'main() 関数内で runApp() より前に WidgetsFlutterBinding.ensureInitialized() を呼ぶ必要があるのはどのような場合か。', NULL, '["StatefulWidget を使用する場合", "runApp() の前にプラットフォーム側の機能（SharedPreferences 等）を利用する場合", "複数の MaterialApp を定義する場合", "リリースビルドを行う場合"]'::jsonb, 1, 'WidgetsFlutterBinding.ensureInitialized() は Flutter の Dart コードと OS 側のネイティブ機能をつなぐバインディングを初期化する。runApp() は内部でこれを自動的に行うが、runApp() より前に SharedPreferences などプラットフォーム機能を使う場合は、明示的に呼び出して先にバインディングを確立する必要がある。', 'https://api.flutter.dev/flutter/widgets/WidgetsFlutterBinding/ensureInitialized.html', 'unpublished', false),
  (239, 'セクション74: Flutter プラットフォームとバインディング', 'Flutter の共通コードとプラットフォーム固有コードの関係', 'Flutter アプリにおいて、Dart で書かれた共通コードからカメラや通知などの OS 固有機能を利用する仕組みとして正しいものはどれか。', NULL, '["Dart コードから直接 OS の API を呼び出す", "プラットフォームチャネルを介して Dart 側と OS 側が通信する", "OS 固有機能は Flutter では利用できない", "ビルド時に Dart コードがネイティブコードに完全変換される"]'::jsonb, 1, 'Flutter は Platform Channels という仕組みで Dart 側とプラットフォーム側（Android/iOS 等）を接続する。SharedPreferences、SystemChrome、カメラ、通知、位置情報などの OS 固有機能はすべてこの通信機構を通じて利用される。Dart コードが直接 OS の API を呼ぶわけではない。', 'https://docs.flutter.dev/platform-integration/platform-channels', 'unpublished', false),
  (240, 'セクション75: Docker / Migration トラブルシュート', 'ERR_EMPTY_RESPONSE の背後にあった本当の原因', '管理画面で `http://localhost:8082/api/admin/quizzes?sort=updated_newest&page=1` へのアクセス時に `Failed to load resource: net::ERR_EMPTY_RESPONSE` が出ていました。調査すると backend のログには `duplicate key value violates unique constraint "quizzes_pkey"` と `Dirty database version 4. Fix and force version.` が出ていました。この状況の原因と解決策として最も適切なものはどれですか？', '// browser
:8082/api/admin/quizzes?sort=updated_newest&page=1
Failed to load resource: net::ERR_EMPTY_RESPONSE

// backend log
migration failed: duplicate key value violates unique constraint "quizzes_pkey"
Dirty database version 4. Fix and force version.', '["Vite の proxy 設定不足が原因なので、vite.config.ts に proxy を追加するだけで直る", "認証トークン切れが原因なので、再ログインだけで直る", "seed migration が既存の quizzes データと主キー衝突して backend が起動失敗し、HTTP 応答を返せていなかった。重複しない形に migration を直し、dirty な schema_migrations を修復して再起動する必要がある", "ブラウザキャッシュ破損が原因なので、ハードリロードで backend の migration も自動修復される"]'::jsonb, 2, '`ERR_EMPTY_RESPONSE` はフロントの fetch 記述ミスではなく、接続先サーバーが正常な HTTP レスポンスを返す前に落ちている時にも発生します。今回の実原因は seed migration 004 が `quizzes` テーブルの既存データと主キー衝突を起こし、その途中で DB が `version=4, dirty=true` になって backend が起動失敗していたことです。対処としては、migration を再実行可能な形に修正し、`schema_migrations` の dirty 状態を解消した上で backend を再起動します。その後は `ERR_EMPTY_RESPONSE` ではなく、未認証なら `401` のような通常の HTTP 応答が返るようになります。', 'backend/migrations/004_seed_quizzes_128_234.up.sql / backend/main.go / docker logs backend-api-1', 'unpublished', false),
  (241, 'セクション76: Matt Pocock - TypeScript の実践', 'TypeScript 採用による Airbnb のバグ防止率', 'Matt Pocock が紹介した事例によると、Airbnb が TypeScript に移行した際、防止可能だったバグの割合はどのくらいか。', NULL, '["約 15%", "約 25%", "約 38%", "約 50%"]'::jsonb, 2, 'Matt Pocock は Kent C. Dodds との対談で Airbnb の TypeScript 移行事例を引用し、''I can''t remember what the exact figure was, but it was something like 38%'' と述べている。Matt 本人が概算と断っている数値だが、TypeScript の型システムがコンパイル時に多くのバグを検出できることを示す事例として紹介された。', 'https://www.epicweb.dev/bonuses/interviews-with-experts/the-magic-of-typescript-with-matt-pocock', 'unpublished', false),
  (242, 'セクション76: Matt Pocock - TypeScript の実践', '外部データ境界における Zod の推奨理由', 'Matt Pocock と Kent C. Dodds が fetch のレスポンスに対してジェネリクスで型を付ける手法を危険だと警告している理由はどれか。', 'const data = await fetch(''/api/user'').then(r => r.json()) as User;', '["ジェネリクスを使うとバンドルサイズが増大するため", "実行時にはデータの中身を検証しておらず、any を隠しているだけだから", "TypeScript コンパイラがジェネリクスを最適化できないため", "fetch API がジェネリクスをサポートしていないため"]'::jsonb, 1, 'fetch のレスポンスを as User やジェネリクスで型付けしても、実行時のデータが本当にその型に合致するかは検証されない。見た目は型安全だが、内部的には any を隠しているだけである。Matt Pocock はこの問題の代替案として Zod などのランタイム検証ツールでデータ境界を実際にチェックすることを推奨している。', 'https://www.epicweb.dev/bonuses/interviews-with-experts/the-magic-of-typescript-with-matt-pocock', 'unpublished', false),
  (243, 'セクション76: Matt Pocock - TypeScript の実践', 'interface と type のパフォーマンス差', 'Matt Pocock が指摘した、TypeScript における interface が交差型（& 演算子による type）よりパフォーマンス上有利な理由はどれか。', '// interface
interface User extends Base {
  name: string;
}

// type + 交差型
type User = Base & {
  name: string;
};', '["interface は JavaScript にコンパイルされるが type はされないため", "interface extends による名前付け継承で TypeScript のキャッシュ効率が向上するため", "interface は V8 エンジンの隠しクラスに直接マッピングされるため", "type は毎回新しいオブジェクトをヒープに確保するため"]'::jsonb, 1, 'Matt Pocock によると、interface extends は名前付け継承として TypeScript コンパイラがキャッシュしやすい。一方、交差型（&）は毎回型の合成を評価する必要があり、キャッシュ効率が劣る。ただし Matt は「両者は第一級プリミティブであり、一貫性強制は不要」とも述べている。', 'https://www.epicweb.dev/bonuses/interviews-with-experts/the-magic-of-typescript-with-matt-pocock', 'unpublished', false),
  (244, 'セクション76: Matt Pocock - TypeScript の実践', 'interface の宣言マージの落とし穴', 'TypeScript で同名の interface を2回宣言した場合、どのような挙動になるか。', 'interface Config {
  host: string;
}

interface Config {
  port: number;
}', '["コンパイルエラーになる", "後の宣言が前の宣言を上書きする", "自動的にマージされ、host と port の両方を持つ型になる", "どちらの宣言も無視される"]'::jsonb, 2, 'TypeScript の interface には宣言マージ（declaration merging）という機能があり、同名の interface は自動的に統合される。これは意図的に使う場面もあるが、意図せず同名にしてしまった場合、バグの原因になる。Matt Pocock はこれを interface の落とし穴として指摘している。type の場合は同名で重複宣言するとコンパイルエラーになるため、この問題は起きない。', 'https://www.epicweb.dev/bonuses/interviews-with-experts/the-magic-of-typescript-with-matt-pocock', 'unpublished', false),
  (245, 'セクション76: Matt Pocock - TypeScript の実践', 'Matt Pocock の戻り値型アノテーションに対する見解', 'Matt Pocock は関数の戻り値型を常に明示すべきだと考えているか。', NULL, '["常に明示すべき。型推論に頼るのは危険である", "常に省略すべき。TypeScript の型推論は十分に正確である", "常に明示すべきではないが、必要で意味がある場面では明示すべき", "ライブラリ開発でのみ明示し、アプリケーションコードでは常に省略すべき"]'::jsonb, 2, 'Matt Pocock は ''I think you shouldn''t always require explicit return types. I still think you should use return types when you need to and when it makes sense'' と述べている。「常に明示」ルールには反対だが、必要に応じて明示する柔軟な姿勢である。具体的にどの場面で必要かについて厳密な分類は示しておらず、文脈次第としている。', 'https://www.epicweb.dev/bonuses/interviews-with-experts/the-magic-of-typescript-with-matt-pocock', 'unpublished', false),
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
};', '["schema とサンプルを同居させると、フィールドを追加した瞬間にサンプル側が型エラーになり、セットで修正すべきことがすぐ分かるから", "TypeScript は別ファイルから z.infer を実行できないため", "Zod は単一ファイル内でしか import/export できないため", "Vite は JSON や Zod を複数ファイルで扱うとバンドルできないため"]'::jsonb, 0, 'Kent C. Dodds が提唱する Colocation では、一緒に変更されるものは同じ場所に置きます。Zod スキーマと代表サンプルを同じファイルに置くと、フィールドを追加・削除した際にサンプルが即座にコンパイルエラーになり、両者を同時に更新することが明確になります。また shape に関する単一の情報源として読めるため理解が速くなります。', 'https://kentcdodds.com/blog/colocation', 'unpublished', false),
  (247, 'セクション78: GitHub SSH 認証', 'SSH 接続時の認証キー', 'SSH 経由で GitHub に接続する際、認証に使用されるのはどちらのキーか？', NULL, '["公開鍵（public key）", "秘密鍵（private key）", "パスフレーズ", "Personal Access Token"]'::jsonb, 1, 'GitHub 公式ドキュメントには ''When you connect via SSH, you authenticate using a private key file on your local machine.'' と記載されている。SSH 接続時の認証には秘密鍵が使用され、公開鍵は GitHub アカウント側に登録するものである。', 'https://docs.github.com/ja/authentication/connecting-to-github-with-ssh/about-ssh', 'unpublished', false),
  (248, 'セクション78: GitHub SSH 認証', '未使用 SSH キーの自動削除', 'GitHub は、セキュリティ上の理由から1年間使用されなかった SSH キーをどうするか？', NULL, '["無効化して通知する", "自動的に削除する", "読み取り専用に変更する", "パスフレーズのリセットを要求する"]'::jsonb, 1, 'GitHub 公式ドキュメントには ''If you haven''t used your SSH key for a year, then GitHub will automatically delete your inactive SSH key as a security precaution.'' と記載されている。セキュリティ予防措置として、1年間使用されなかった SSH キーは自動的に削除される。', 'https://docs.github.com/ja/authentication/connecting-to-github-with-ssh/about-ssh', 'unpublished', false),
  (249, 'セクション78: GitHub SSH 認証', '推奨 SSH キーアルゴリズム', 'GitHub 公式ドキュメントで新しい SSH キーを生成する際に推奨されているアルゴリズムはどれか？', 'ssh-keygen -t ??? -C "your_email@example.com"', '["rsa", "dsa", "ed25519", "ecdsa"]'::jsonb, 2, '公式ドキュメントのコマンド例は `ssh-keygen -t ed25519 -C "your_email@example.com"` であり、Ed25519 が推奨されている。Ed25519 をサポートしないレガシシステムでのみ RSA（4096ビット）が代替として案内されている。', 'https://docs.github.com/ja/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent', 'unpublished', false),
  (250, 'セクション78: GitHub SSH 認証', 'DSA キーのサポート廃止', 'GitHub が 2022年3月15日以降サポートを廃止した SSH キーの種類はどれか？', NULL, '["RSA キー (`ssh-rsa`)", "Ed25519 キー (`ssh-ed25519`)", "DSA キー (`ssh-dss`)", "ECDSA キー (`ssh-ecdsa`)"]'::jsonb, 2, '公式ドキュメントに『それ以降、DSA キー (`ssh-dss`) はサポートされなくなりました。GitHub の個人用アカウントに新しい DSA キーを追加することはできません。』と記載されている。セキュリティ強化の一環としての措置である。', 'https://docs.github.com/ja/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent', 'unpublished', false),
  (251, 'セクション78: GitHub SSH 認証', 'ssh-agent の役割', 'SSH キーのパスフレーズを毎回入力したくない場合、どのツールにキーを追加すればよいか？', NULL, '["git-credential-manager", "ssh-agent", "gpg-agent", "keychain"]'::jsonb, 1, '公式ドキュメントに『キーにパスフレーズがあり、キーを使用するたびにパスフレーズを入力したくない場合は、SSH エージェントにキーを追加できます。SSH エージェントでは SSH キーを管理し、パスフレーズを記憶します。』と記載されている。', 'https://docs.github.com/ja/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent', 'unpublished', false),
  (252, 'セクション78: GitHub SSH 認証', 'RSA キーの SHA-2 要件', '2021年11月2日以降に生成された RSA キーが満たさなければならない要件はどれか？', NULL, '["鍵長が 8192 ビット以上であること", "SHA-2 署名アルゴリズムを使用すること", "パスフレーズが必須であること", "ハードウェアセキュリティキーと併用すること"]'::jsonb, 1, '公式ドキュメントに『その日以降に生成される RSA キーは、SHA-2 署名アルゴリズムを使用する必要があります。SHA-2 署名を使用するには、一部の古いクライアントをアップグレードする必要があります。』と記載されている。', 'https://docs.github.com/ja/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent', 'unpublished', false),
  (253, 'セクション78: GitHub SSH 認証', 'SSH キーの用途選択', 'GitHub アカウントに SSH 公開鍵を追加する際、キーの用途として選択できるのはどれか？', NULL, '["認証（authentication）または署名（signing）", "暗号化（encryption）または復号（decryption）", "プッシュ（push）またはプル（pull）", "読み取り（read）または書き込み（write）"]'::jsonb, 0, '公式ドキュメントに『キーの種類として、認証または署名のいずれかを選びます。』と記載されている。認証と署名の両方に同じ SSH キーを使用する場合は、2回アップロードする必要がある。', 'https://docs.github.com/ja/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account', 'unpublished', false),
  (254, 'セクション78: GitHub SSH 認証', 'SSH 公式英文の日本語訳', '以下の英文の正しい日本語訳はどれか？

''You must also add the public SSH key to your account on GitHub before you use the key to authenticate or sign commits.''', NULL, '["SSH キーを使用して認証やコミット署名を行う前に、秘密鍵を GitHub アカウントに追加する必要がある", "SSH キーを使用して認証やコミット署名を行った後に、公開鍵を GitHub アカウントに追加する必要がある", "SSH キーを使用して認証やコミット署名を行う前に、公開鍵を GitHub アカウントに追加する必要がある", "SSH キーを使用して認証やコミット署名を行うには、秘密鍵と公開鍵の両方を GitHub に追加する必要がある"]'::jsonb, 2, '''public SSH key'' が公開鍵、''before'' が『〜する前に』を意味する。秘密鍵はローカルに保持し、公開鍵のみ GitHub に登録する。誤訳選択肢は秘密鍵・公開鍵の取り違え、before/after の誤訳をそれぞれ含んでいる。', 'https://docs.github.com/ja/authentication/connecting-to-github-with-ssh/about-ssh', 'unpublished', false),
  (255, 'セクション78: GitHub SSH 認証', 'ハードウェアセキュリティキー用コマンド', 'ハードウェアセキュリティキー用の SSH キーを生成する際、Ed25519 アルゴリズムをサポートしていない場合に使用すべきコマンドはどれか？', NULL, '["`ssh-keygen -t rsa -b 4096 -C \"email@example.com\"`", "`ssh-keygen -t ecdsa-sk -C \"email@example.com\"`", "`ssh-keygen -t dsa -C \"email@example.com\"`", "`ssh-keygen -t ed25519 -C \"email@example.com\"`"]'::jsonb, 1, '公式ドキュメントに『コマンドが失敗し、エラー invalid format または feature not supported を受け取る場合は、Ed25519 アルゴリズムをサポートしていないハードウェアセキュリティキーを使っている可能性があります。代わりに ssh-keygen -t ecdsa-sk -C ... を入力します。』と記載されている。-sk サフィックスはセキュリティキー対応を示す。', 'https://docs.github.com/ja/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent', 'unpublished', false),
  (256, 'セクション78: GitHub SSH 認証', 'SAML SSO 環境での SSH キー承認', 'SAML シングルサインオンを使用する Organization のリポジトリに SSH キーでアクセスするために必要な追加手順は何か？', NULL, '["SSH キーを再生成する", "SSH キーを承認（authorize）する", "SSH キーにパスフレーズを追加する", "SSH キーを管理者に送信する"]'::jsonb, 1, '公式ドキュメントに ''To use your SSH key with a repository owned by an organization that uses SAML single sign-on, you must authorize the key.'' と記載されている。キーの再生成やパスフレーズ追加は不要で、既存のキーを Organization 向けに承認する操作が必要である。', 'https://docs.github.com/ja/authentication/connecting-to-github-with-ssh/about-ssh', 'unpublished', false),
  (257, 'セクション79: クイズ同期 & 管理画面運用', 'production JSON の役割', '`backend/seeds/quizzes.production.json` の役割として最も適切なものはどれですか？', NULL, '["管理画面の見た目だけを調整する Tailwind 設定ファイル", "本番反映対象のクイズを保持し、DB 同期やマイグレーション生成の入力に使う JSON", "ログイン用 JWT の秘密鍵を保存する JSON", "React Router のルーティング定義ファイル"]'::jsonb, 1, '`backend/seeds/quizzes.production.json` は本番反映対象のクイズデータを持つテンプレートであり、管理画面の同期 API や seed SQL 生成の入力として使われる。', 'docs/quiz-data-workflow.md / backend/seeds/quizzes.production.json', 'unpublished', false),
  (258, 'セクション79: クイズ同期 & 管理画面運用', 'generate_migration.py の責務', '`python3 scripts/generate_migration.py < backend/seeds/quizzes.production.json` の説明として正しいものはどれですか？', NULL, '["マイグレーション番号を自動採番して DB へ即時適用する", "JSON を読み取って SQL テキストを stdout に出力する", "quizzes.production.json を React 用 JSX に変換する", "DB の既存クイズを JSON に書き戻す"]'::jsonb, 1, '`generate_migration.py` は seed JSON を読み取り、`INSERT ... ON CONFLICT ...` などの SQL テキストを標準出力へ出す。ファイル作成や採番は別処理で行う。', 'scripts/generate_migration.py', 'unpublished', false),
  (259, 'セクション79: クイズ同期 & 管理画面運用', 'golang-migrate create の役割', '`migrate create -ext sql -dir backend/migrations -seq -digits 3 seed_quizzes` を使う主目的はどれですか？', 'migrate create -ext sql -dir backend/migrations -seq -digits 3 seed_quizzes', '["既存マイグレーションを自動的にロールバックするため", "番号付きの `up.sql` / `down.sql` 雛形を正しい命名規則で作るため", "PostgreSQL のテーブル定義を JSON に変換するため", "React 管理画面の API クライアントを生成するため"]'::jsonb, 1, '`golang-migrate create` は連番付きの `NNN_name.up.sql` / `NNN_name.down.sql` を生成し、採番やファイル名の管理を肩代わりする。', 'scripts/create_seed_migration.py / golang-migrate', 'unpublished', false),
  (260, 'セクション79: クイズ同期 & 管理画面運用', 'Upsert の更新条件', '`ON CONFLICT (id) DO UPDATE` に変更した後の挙動として正しいものはどれですか？', NULL, '["同じ ID が存在しても常に挿入をスキップする", "同じ ID の行があれば、タイトルや選択肢が少しでも違うと更新される", "同じ ID があると必ずエラーになる", "ID が同じ場合は `created_at` だけ更新される"]'::jsonb, 1, '`ON CONFLICT (id) DO UPDATE SET ...` では競合した ID の行を上書き更新する。`section`、`title`、`question`、`options` など指定したカラムが新しい値へ更新される。', 'scripts/generate_migration.py / backend/migrations/006_seed_quizzes.up.sql', 'unpublished', false),
  (261, 'セクション79: クイズ同期 & 管理画面運用', 'down.sql の性質', '今回の seed 用 `down.sql` の性質として最も適切なのはどれですか？', NULL, '["更新前のレコード内容を完全に復元できる", "今回の seed 対象 ID を削除する簡易ロールバックであり、更新前データまでは戻さない", "DB スキーマを 001 の状態まで戻す", "マイグレーションの `dirty` フラグだけを消す"]'::jsonb, 1, 'この `down.sql` は seed 対象 ID の削除が主目的であり、Upsert 前の値をスナップショットから復元する仕組みは持たない。', 'docs/quiz-data-workflow.md / scripts/generate_migration.py', 'unpublished', false),
  (262, 'セクション79: クイズ同期 & 管理画面運用', '管理画面ボタンの呼び先', '管理画面の `production.json を DB 反映` ボタンを押したとき、最初にフロントが呼ぶ API はどれですか？', NULL, '["`POST /api/admin/quizzes/sync-production`", "`GET /api/admin/quizzes`", "`PATCH /api/admin/quizzes/{id}/status`", "`POST /api/admin/login/verification`"]'::jsonb, 0, '一覧画面の同期ボタンは `syncProductionQuizzes()` を呼び、認証付きで `POST /api/admin/quizzes/sync-production` を送る。', 'admin-web/src/pages/QuizListPage.tsx / admin-web/src/api/admin.ts / backend/main.go', 'unpublished', false),
  (263, 'セクション79: クイズ同期 & 管理画面運用', '同期 API が読むファイル', '管理画面の同期 API が既定で読み込むファイルパスはどれですか？', NULL, '["`admin-web/src/data/quizzes.json`", "`backend/seeds/quizzes.production.json`", "`backend/migrations/006_seed_quizzes.up.sql`", "`docs/quiz-data-workflow.md`"]'::jsonb, 1, 'バックエンドは既定で `seeds/quizzes.production.json` を読み込む。リポジトリ上では `backend/seeds/quizzes.production.json` に相当する。', 'backend/main.go', 'unpublished', false),
  (264, 'セクション79: クイズ同期 & 管理画面運用', 'replace モードの意味', '管理画面ボタンの同期仕様が replace モードに変更された後、正しい説明はどれですか？', NULL, '["JSON にある ID だけ追加し、JSON にない ID はそのまま残す", "JSON にある ID は Upsert し、JSON にない ID は DB から削除する", "JSON の内容は無視して常に DB 全件を保持する", "JSON にない ID だけを別テーブルへ移動する"]'::jsonb, 1, 'replace モードでは `quizzes.production.json` を正とみなし、存在しない ID を削除することで DB と JSON の内容を一致させる。', 'backend/main.go / docs/quiz-data-workflow.md', 'unpublished', false),
  (265, 'セクション79: クイズ同期 & 管理画面運用', '空配列での replace 同期', '`quizzes.production.json` の中身が次のように正しい JSON で、`quizzes` 配列が空だった場合の挙動はどれですか？

`{"quizzes": []}`', NULL, '["422 で拒否され、DB は変更されない", "`quizzes` テーブルが全件削除される", "最新 1 件だけが残る", "`schema_migrations` テーブルだけが削除される"]'::jsonb, 1, 'replace モードでは JSON を正として扱うため、`quizzes` 配列が空なら DB 側の `quizzes` テーブルも空に同期される。', 'backend/main.go / docs/quiz-data-workflow.md', 'unpublished', false),
  (266, 'セクション79: クイズ同期 & 管理画面運用', '同期時の status / push の扱い', '管理画面ボタンの同期 API が `status` と `push_enabled` を扱う方法として正しいものはどれですか？', NULL, '["既存行でも毎回 `published` / `true` に上書きする", "既存行では保持し、新規行だけ `unpublished` / `false` で挿入する", "常に JSON から `status` と `push_enabled` を読む", "同期時には `status` と `push_enabled` を NULL にする"]'::jsonb, 1, 'production seed JSON には `status` と `push_enabled` を持たせていないため、既存行では現在値を保持し、新規行のみ既定値 `unpublished` / `false` で作成する。', 'backend/main.go', 'unpublished', false),
  (267, 'セクション79: クイズ同期 & 管理画面運用', '422 エラーの意味', '管理画面の同期 API が 422 を返すケースとして最も適切なものはどれですか？', NULL, '["JWT が期限切れで再ログインが必要なとき", "`quizzes.production.json` の JSON 構文が壊れている、またはクイズデータが不正なとき", "API サーバーが起動していないとき", "削除モーダルのスクロールが足りないとき"]'::jsonb, 1, '422 は入力データが妥当でないことを表す。今回の実装では、壊れた JSON、重複 ID、必須項目不足、`correctAnswerIndex` の範囲外などが該当する。', 'backend/main.go / admin-web/src/pages/QuizListPage.tsx', 'unpublished', false),
  (268, 'セクション79: クイズ同期 & 管理画面運用', '削除モーダルのスクロール修正', '削除モーダルで長い内容を安全に表示するために行った修正として正しいものはどれですか？', NULL, '["モーダルを `position: static` に変更した", "オーバーレイに `overflow-y-auto`、ダイアログ本文に `max-height` と内部スクロールを追加した", "コードブロックをすべて削除した", "モーダルを別ページ遷移に置き換えた"]'::jsonb, 1, 'モーダル本体を viewport 高さ内に収め、本文領域だけをスクロール可能にすることで、長い問題文やコードを含んでも操作ボタンが見失われにくくなった。', 'admin-web/src/components/DeleteQuizDialog.tsx', 'unpublished', false)
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

DELETE FROM quizzes WHERE NOT (id = ANY(ARRAY[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175, 176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207, 208, 209, 210, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220, 221, 222, 223, 224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236, 237, 238, 239, 240, 241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 252, 253, 254, 255, 256, 257, 258, 259, 260, 261, 262, 263, 264, 265, 266, 267, 268]::bigint[]));

SELECT setval('quizzes_id_seq', COALESCE((SELECT MAX(id) FROM quizzes), 1), (SELECT COUNT(*) > 0 FROM quizzes));
