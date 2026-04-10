-- Migration: seed quizzes from quizzes.json
-- Generated: 2026-04-07

INSERT INTO quizzes (id, section, title, question, code, options, correct_answer_index, explanation, source)
VALUES
  (1, 'セクション1: React & TypeScript ', 'useEffect 依存配列と関数参照', '以下のコードについて、最も正しい説明はどれですか？', 'const fetchUser = useCallback(async () => {
  const res = await fetch(`/api/users/${userId}`);
  const data = await res.json();
  setUser(data);
}, [userId]);

useEffect(() => {
  fetchUser();
}, [fetchUser]);', '["`fetchUser` を依存配列に入れると常に無限ループになる", "`useCallback` で `fetchUser` を安定化し、`[fetchUser]` を依存配列に入れると `userId` 変更時に再実行されるため `exhaustive-deps` の意図に沿う", "`useEffect(..., [])` にしても同じ挙動で、常に最新の `userId` を参照できる", "cleanup 関数は初回マウント前に必ず1回実行される"]'::jsonb, 1, '`fetchUser` は `useCallback(..., [userId])` により `userId` が変わると新しい参照になります。Effect 側を `[fetchUser]` にすると、結果として `userId` 変化に追従しつつ、依存関係を正しく宣言できます。`[]` にすると古い `userId` を閉じ込める（stale closure）リスクがあります。', 'React useCallback / useEffect / exhaustive-deps'),
  (2, 'セクション1: React & TypeScript ', '関数型コンポーネントの State 更新', '以下の useState の使用について、誤っているのはどれですか？', 'const [state, setState] = useState({ count: 0, name: "test" });
setState(prev => ({ ...prev, count: 1 }));', '["前のstate とマージしないと、name プロパティが失われる", "setState(() => prev) という書き方では前の値を参照できない", "setState は非同期で実行されるため、即座に state は更新されない", "setState 後、即座に console.log(state) を実行すると古い値が出力される"]'::jsonb, 1, 'setState(() => prev) は、setState に関数を渡す形式で、前の値を参照できる正しい書き方です。', 'React Official Documentation'),
  (3, 'セクション1: React & TypeScript ', 'TypeScript の Generic について', 'React コンポーネントで Generic を使う際、以下の記述で型推論が正しく機能するのはどれですか？', 'interface Props<T> {
  items: T[];
  onSelect: (item: T) => void;
}', '["T の型は自動推論される", "T extends { id: number } により、id プロパティを持つ型のみが使用可能", "props の型が正確に定義される", "すべてが正しい"]'::jsonb, 3, 'Generic を使うことで、型安全かつ柔軟なコンポーネント設計が可能になります。', 'TypeScript Handbook'),
  (4, 'セクション2: ビルドツール & Asset 管理', 'Vite での Asset 読み込み', '以下のファイル配置について、fetch(''/data.json'') でHTTPアクセス可能なのはどれですか？', '// 例1: public/data.json は HTTP で直接取得できる
const res = await fetch(''/data.json'');

// 例2: src/data/data.json は import で利用する（fetch での直アクセス前提ではない）
import localData from ''./data/data.json'';', '["src/data/data.json", "public/data.json", "dist/data.json", "いずれでも可能"]'::jsonb, 1, 'ソースコードから参照されないアセット、まったく同じファイル名を保つ必要があるアセット、または URL を得るためだけに最初に import したくないアセットは、プロジェクトルート配下の特別な `public` ディレクトリに置くことができます。このディレクトリ内のアセットは、開発時にはルートパス `/` で配信され、`dist` ディレクトリのルートへそのままコピーされます。`public` アセットは常にルート絶対パスで参照する必要があるため、`public/data.json` は `/data.json` として取得します。', 'https://vite.dev/guide/assets.html#the-public-directory'),
  (5, 'セクション2: ビルドツール & Asset 管理', 'src vs public 方式の使い分け', '動的にコンテンツを読み込みたい場合、最適な配置方式はどちらですか？', '// 複数の quiz.json from サーバー', '["src/data/ にすべてバンドル", "public/ フォルダに複数ファイル保存", "バックエンド API から取得", "TypeScript enum で定義"]'::jsonb, 2, 'Vite の `public` ディレクトリは、「ソースコードから参照されないアセット」「まったく同じファイル名を保つ必要があるアセット」「URL を得るためだけに import したくないアセット」を置くためのものです。一方で Fetch API は、「ネットワーク越しを含むリソースを取得するためのインターフェース」を提供します。したがって、内容が固定ファイルではなく動的に変わるコンテンツを読み込みたい場合は、`public` に複数 JSON を置くより、バックエンド API から取得する方が問題文の意図に合っています。', 'Vite Public Directory / MDN Fetch API'),
  (6, 'セクション2: ビルドツール & Asset 管理', 'モジュールと非モジュール読み込み', 'JSON を import vs fetch で読み込む場合の違いはどれですか？', 'import quizzes from ''./quizzes.json'';
const res = await fetch(''/api/quizzes.json'');', '["取得タイミングが異なる", "バンドルサイズが変わる", "ビルド時最適化が異なる", "すべて正しい"]'::jsonb, 3, 'import はビルド時に解析され、fetch は実行時に取得します。バンドルサイズと最適化方法が異なります。', 'Vite Guide'),
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
}', 'React Design Patterns'),
  (8, 'セクション3: コンポーネント設計', 'Controlled vs Uncontrolled Component', 'フォーム入力を React で管理する際、state で値を制御する方式の名称はどれですか？', '<input value={name} onChange={(e) => setName(e.target.value)} />', '["Uncontrolled Component", "Controlled Component", "Ref Component", "Form Component"]'::jsonb, 1, 'state で値を管理し、onChange で更新する方式が Controlled Component です。', 'React Forms'),
  (9, 'セクション3: コンポーネント設計', 'React.memo の使用シーン', 'React.memo でコンポーネントをラップする場合の効果はどれですか？', 'const MemoizedList = React.memo(ListComponent);', '["props が同じなら再レンダリングをスキップ", "必ずレンダリングスキップされる", "メモリ使用量が削減される", "TypeScript の型チェックが厳しくなる"]'::jsonb, 0, 'React.memo は props の浅い比較で再レンダリングをスキップします。', 'React Optimization'),
  (10, 'セクション4: 非同期処理パターン', 'Promise.all vs Promise.allSettled', '複数の API 呼び出しについて、全件の成功を待ち、1つでも失敗したら全体を reject したい場合に使うメソッドはどれですか？', 'Promise.all([fetch(url1), fetch(url2), fetch(url3)])', '["Promise.race", "Promise.all", "Promise.any", "Promise.allSettled"]'::jsonb, 1, 'Promise.all は、すべての入力 Promise が fulfill されたときにのみ fulfill され、1つでも reject されると即座に reject されます。一方 Promise.allSettled は、成功・失敗にかかわらずすべての Promise が settle するまで待ち、各結果を配列で返します。', 'Promise MDN'),
  (11, 'セクション4: 非同期処理パターン', 'async/await のエラーハンドリング', '複数の async 処理をシーケンシャルに実行し、エラーが発生した時点で停止する場合の書き方は？', 'try {
  const data = await fetchUser();
  const posts = await fetchPosts(data.id);
} catch (err) { ... }', '["Promise チェーン", "async/await + try/catch", "async/await + catch メソッド", "コールバック地獄"]'::jsonb, 1, 'async/await + try/catch は読みやすく、エラーハンドリングが容易です。', 'JavaScript Async'),
  (12, 'セクション5: TypeScript 型システム', 'Union Type vs Intersection Type', '以下の型定義について、値が持つべきプロパティはどれですか？', 'type A = { name: string; age: number };
type B = { email: string };
type Result = A & B;', '["name か email のいずれか", "name, age, email のすべて", "age のみ", "name のみ"]'::jsonb, 1, 'Intersection Type (A & B) は両方の型を『すべて』持つ必要があります。', 'TypeScript Advanced'),
  (13, 'セクション5: TypeScript 型システム', 'Partial と Required ユーティリティ型', 'すべてのプロパティをオプショナルにするユーティリティ型はどれですか？', 'type User = { name: string; age: number };
type OptionalUser = Partial<User>;', '["Required", "Partial", "Pick", "Record"]'::jsonb, 1, 'Partial<T> はすべてのプロパティをオプショナル（? がつく）に変換します。', 'TypeScript Utility Types'),
  (14, 'セクション5: TypeScript 型システム', 'keyof と Mapped Type', '`User` 型の各キーをそのまま使い、値の型だけをすべて `boolean` にした新しい型を作るには？', 'type User = { name: string; age: number };
type Flags = { [K in keyof User]: boolean };', '["Pick", "Omit", "Mapped Type", "Union"]'::jsonb, 2, '`keyof User` で `name | age` のようなキーのユニオン型を取り出し、`[K in keyof User]` で各キーを順にたどれます。そこで各プロパティの値の型を `boolean` に置き換えると、`{ name: boolean; age: boolean }` のような新しい型を作れます。これは Mapped Type の基本パターンです。

ユーザー目線で実現できる機能の例:
- プロフィール編集画面で、各項目が「編集中かどうか」を `name: true`, `age: false` のように管理できる
- バリデーション結果を、各入力欄ごとに「エラーあり / なし」で持てる
- 管理画面で、各列や各設定項目の ON/OFF 状態を元のデータ構造に合わせて安全に管理できる
- フォーム送信時に、どの項目を変更したか、どの項目を無効化するかを同じキー構造で扱える

つまり Mapped Type を使うと、元データと同じ項目構成を保ったまま、UI 用の状態や設定フラグを自動的に作れるため、画面機能を増やしても型のズレを減らせます。', 'TypeScript Handbook'),
  (15, 'セクション6: エラーハンドリング戦略', 'try/catch で複数エラー型を処理', 'fetch エラーと JSON parse エラーを区別する方法はどれですか？', 'try { ... } catch (err) { if (err instanceof SyntaxError) ... }', '["Error.message で文字列判定", "instanceof で型チェック", "err.code を参照", "手動で throw-catch"]'::jsonb, 1, 'instanceof はエラーの実際の型をチェックできます。', 'Error Handling Best Practices'),
  (16, 'セクション6: エラーハンドリング戦略', 'カスタムエラークラス', 'ビジネスロジック固有のエラーを表現するための推奨パターンは？', 'class ValidationError extends Error { constructor(msg) { super(msg); } }', '["Error を拡張してカスタムクラスを作成", "単なる Error を throw する", "文字列を throw する", "undefined を throw する"]'::jsonb, 0, 'Error を継承してカスタムクラスを作ることで、エラーの種類を明確にできます。', 'JavaScript Patterns'),
  (17, 'セクション7: パフォーマンス最適化', 'useMemo vs useCallback', '関数の参照を保持して再作成を避けたい場合に使用するフックはどれですか？', 'const memoizedCallback = useCallback(() => { doSomething() }, [dep]);', '["useMemo", "useCallback", "useRef", "useReducer"]'::jsonb, 1, 'useCallback は関数の参照を保持し、不必要な再作成を避けます。', 'React Hooks'),
  (18, 'セクション7: パフォーマンス最適化', 'バンドルサイズの最適化', '不要な npm パッケージを削除した際、最初に確認すべき項目はどれですか？', 'npm install @large/library  // 削除', '["ビルドファイルサイズ", "package.json の記録", "node_modules の削除", "すべて"]'::jsonb, 3, 'パッケージ管理、依存関係、ビルド出力のサイズ確認が重要です。', 'Build Optimization'),
  (19, 'セクション8: テスト戦略', 'ユニットテストの対象', 'React コンポーネントのテストで最優先すべき項目はどれですか？', '// テスト対象の優先順位', '["UI の見た目", "ユーザーの入力と出力", "内部実装の詳細", "CSS の正確性"]'::jsonb, 1, 'ユーザー視点での入出力と振る舞いをテストすることが重要です。', 'React Testing Library'),
  (20, 'セクション8: テスト戦略', 'マッチャーの選択', '要素が DOM に存在することをテストする場合の推奨マッチャーは？', 'expect(screen.getByText(''Hello'')).toBeInTheDocument();', '["toBeTruthy", "toBeInTheDocument", "toBeVisible", "toHaveLength"]'::jsonb, 1, 'toBeInTheDocument は DOM の存在を確認する明示的な方法です。', 'Jest Matchers'),
  (21, 'セクション9: API 統合パターン', 'CORS の仕組み', 'ブラウザから別オリジンの API にリクエストを送る際、サーバーが返すべきヘッダーはどれですか？', '// ブラウザ制限を回避するには', '["Access-Control-Allow-Origin", "Authorization", "X-API-Key", "Content-Type"]'::jsonb, 0, 'サーバーが Access-Control-Allow-Origin ヘッダーを返して CORS を許可します。', 'MDN CORS'),
  (22, 'セクション9: API 統合パターン', '認証トークンの管理', 'JWT トークンを localStorage に保存する方法の安全性は？', 'localStorage.setItem(''token'', jwtToken);', '["最も安全な方法", "XSS 攻撃のリスクあり", "完全に安全", "サーバー側のみで管理すべき"]'::jsonb, 1, 'localStorage は XSS 攻撃で奪われるリスクがあります。より安全な方法はタブ内のメモリや HttpOnly Cookie です。', 'OWASP HTML5 Security Cheat Sheet / JWT Cheat Sheet'),
  (23, 'セクション10: デバッグとロギング', 'console.log vs console.table', 'オブジェクト配列 `users` を DevTools 上で列形式で見やすく確認したい。`console.log(users)` の代わりとして最も適切なのはどれですか？', 'const users = [{id: 1, name: ''A''}, {id: 2, name: ''B''}];
console.log(users);', '["console.log", "console.table", "JSON.stringify", "alert"]'::jsonb, 1, 'console.table は配列のオブジェクトをテーブル形式で表示して可視化しやすくします。', 'Browser DevTools'),
  (24, 'セクション11: モジュールシステム', 'CommonJS vs ES Modules', '最新の JavaScript プロジェクトで推奨されるモジュールシステムはどれですか？', 'import { Component } from ''./component.js'';
const { Component } = require(''./component.js'');', '["CommonJS", "ES Modules", "どちらでも同じ", "環境に依存"]'::jsonb, 1, 'ES Modules は標準化され、ツールの最適化も充実しているため npm @latest では推奨されます。', 'ECMAScript 2015+'),
  (25, 'セクション11: モジュールシステム', 'デフォルトエクスポート vs 名前付きエクスポート', '複数の関数をエクスポートする場合、推奨するパターンはどれですか？', 'export const func1 = () => {};
export const func2 = () => {};', '["デフォルトエクスポート", "名前付きエクスポート", "どちらでも同じ", "別ファイルに分割"]'::jsonb, 1, '複数のエクスポートは名前付きエクスポートを使うことで、import する側が柔軟に選択できます。', 'ES6 Modules'),
  (26, 'セクション12: React StrictMode', 'StrictMode の役割', 'React.StrictMode は開発環境で何を行いますか？', '<React.StrictMode>
  <App />
</React.StrictMode>', '["エラーをキャッチして本番環境を保護", "不純な関数を検出して2回レンダリング", "パフォーマンスを向上させる", "バンドルサイズを削減"]'::jsonb, 1, 'StrictMode は意図しない副作用を検出するため、開発環境でコンポーネントを2回マウント・レンダリングします。', 'React.StrictMode'),
  (27, 'セクション12: React StrictMode', 'StrictMode による useEffect の重複実行', 'StrictMode で useEffect が異なる結果を返すコードはどれですか？', 'useEffect(() => {
  array.push(1);  // 破壊的変更
}, []);', '["純粋なデータ変換", "破壊的な変更（配列 push など）", "fetch による外部データ取得", "console.log による出力"]'::jsonb, 1, '配列の push などの破壊的な変更は、2回実行されると異なる結果になり、StrictMode で検出されます。', 'React StrictMode'),
  (28, 'セクション12: React StrictMode', 'StrictMode でハイライトされるバグ', 'useEffect の重複実行で検出される『不純な関数』の特徴はどれですか？', 'useEffect(() => {
  globalCounter++;  // グローバル変数変更
}, []);', '["入出力が確定している", "同じ入力なら同じ出力を返す", "外部状態を変更する", "すべてが A と B"]'::jsonb, 2, '不純な関数は外部状態を変更し、「同じ入力 → 異なる出力」となってバグの原因になります。', 'React.StrictMode'),
  (29, 'セクション12: React StrictMode', 'StrictMode による double-render の合図', 'DOMに値が2倍になって表示される場合、疑うべき関数の特徴は？', 'const Counter = () => {
  const [count, setCount] = useState(0);
  // レンダー結果を変更する処理が含まれている', '["fetch エラー", "破壊的な props", "不純なレンダー（pure でない関数）によるバグ"]'::jsonb, 2, '公式ドキュメントより：「Strict Mode calls some of your functions (only the ones that should be pure) twice in development.」不純な関数を早期に検出します。', 'React StrictMode'),
  (30, 'セクション12: React StrictMode', 'StrictMode での console エラー重複', 'StrictMode で console.error や console.warn が2回出力されるのはなぜですか？', 'useEffect(() => {
  console.warn(''Warning'');
}, []);', '["バグの報告がある", "不純な関数の検出のため2回実行", "メモリリークのサイン", "ネットワークエラーの再実行"]'::jsonb, 1, 'StrictMode はコンポーネントの2重実行で不純な関数を検出するため、console 出力も2回経験します。', 'React Strict Mode'),
  (31, 'セクション13: useEffect と副作用・データ取得パターン', 'useEffect の依存配列 [] の意味', '以下のコードで、空の依存配列 [] を指定した useEffect はどのタイミングで実行されますか？（本番挙動ベースで回答）', 'useEffect(() => {
  fetch(API_URL).then(res => res.json()).then(data => setCount(data.count));
}, []);', '["毎回のレンダリングのたびに実行される", "マウント時とアンマウント時だけに実行される", "マウント時だけ1回実行される", "state が更新されるたびに実行される"]'::jsonb, 2, '空の依存配列 [] は、Effect を初回マウント時に実行する意図を表します。本番ビルドでは通常1回です。なお開発環境で React StrictMode が有効な場合は副作用検出のために追加実行され、結果として2回観測されることがあります。', 'view-counter/frontend/src/components/ViewCounter.tsx'),
  (32, 'セクション13: useEffect と副作用・データ取得パターン', '外部データ取得を『副作用』と呼ぶ理由', '以下の説明の中で、『副作用（side effect）』の定義として最も正確なものはどれですか？', 'useEffect(() => {
  fetch(API_URL)
  .then(data => setCount(data.count));
}, []);', '["コンポーネントのレンダリング結果に直接反映されない処理", "レンダー関数内で実行されると問題が生じる処理（データ取得、イベントリスナー登録など）", "props や state に基づかない処理", "エラーを発生させる可能性のある処理"]'::jsonb, 1, '『副作用』とは、『コンポーネントの pure なレンダリングプロセスの外で実行される処理』を指します。これらをレンダー関数内で直接実行するとバグの原因になります。', 'React Official Documentation'),
  (33, 'セクション13: useEffect と副作用・データ取得パターン', 'useEffect に直接 async を書けない理由と cleanup', '以下のコードが推奨されていない理由は何ですか？', 'useEffect(async () => {
  const res = await fetch(API_URL);
  const data = await res.json();
  setCount(data.count);
}, []);', '["非同期処理のため、cleanup 関数が実行できなくなる", "async 関数は自動的に Promise を返すが、useEffect は関数かクリーンアップ関数の返却を期待しており、Promise の返却は型に矛盾するから", "useState の呼び出しが許可されないから", "fetch API は useEffect 内では使用禁止だから"]'::jsonb, 1, 'useEffect の第1引数は『関数 → (クリーンアップ関数 | undefined)』の型を期待しています。async 関数は必ず Promise を返すため、型が合致しません。正しいパターンは『内部に async 関数を定義して呼び出す』方式です。', 'view-counter/frontend/src/components/ViewCounter.tsx'),
  (34, 'セクション13: useEffect と副作用・データ取得パターン', 'fetch API と res.ok チェックの重要性', '以下のコードで res.ok を確認する理由は何ですか？', 'const res = await fetch(API_URL);
if (!res.ok) throw new Error(`HTTP error: ${res.status}`);
const data = await res.json();', '["fetch が失敗しても Promise は reject されず、HTTP エラーステータス（404, 500など）は成功値として返されるから", "res.json() 呼び出し時に必ず IOException が発生するから", "JSON パースエラーを事前に防ぐため", "TypeScript の型チェックで必須だから"]'::jsonb, 0, 'fetch API の重要な特性：『ネットワークエラーのみで Promise を reject する』。HTTP エラーステータスでも fetch は成功値を返すため、res.ok チェックが必須です。', 'view-counter/frontend/src/components/ViewCounter.tsx'),
  (35, 'セクション13: useEffect と副作用・データ取得パターン', 'TypeScript 型アサーション (as) の役割', '以下のコードで as ViewData を使用する理由は何ですか？', 'const data = (await res.json()) as ViewData;

type ViewData = {
  count: number;
};', '["res.json() は any 型を返し、TypeScript は data.count がどの型なのか推測できないため、開発者が『これは ViewData 型です』と明示する", "型アサーションで実行時のデータ検証が自動的に行われる", "as を使うことで fetch エラーが自動的にハンドルされる", "JSON のパース速度が向上する"]'::jsonb, 0, 'res.json() は Promise<any> を返します。型アサーション (as ViewData) は『このデータは ViewData 型である』と TypeScript コンパイラに通知し、型チェックを可能にします。ただし実行時のデータ検証は行われません。', 'view-counter/frontend/src/components/ViewCounter.tsx'),
  (36, 'セクション13: useEffect と副作用・データ取得パターン', 'try/catch でのエラーハンドリングと型ガード', '以下のコードで err instanceof Error を確認する理由は何ですか？', 'try {
  const data = (await res.json()) as ViewData;
  setCount(data.count);
} catch (err) {
  setError(err instanceof Error ? err.message : "Unknown error");
}', '["catch ブロックの err 変数は unknown 型であり、Error 型とは限らず、throw \"string\" や throw 123 などの任意の値も catch される可能性があるから", "await 式でのみ例外が発生し、それ以外では発生しないから", "catch で捕捉されたすべてのエラーは自動的に Error 型", "「型ガード」は TypeScript だけの機能で、JavaScript では無関係"]'::jsonb, 0, 'JavaScript では `throw new Error(...)` の他に、`throw "string"` や `throw 123` など任意の値を throw できます。そのため catch 時に `err instanceof Error` で検証し、堅牢な実装をします。', 'view-counter/frontend/src/components/ViewCounter.tsx'),
  (37, 'セクション14: CORS とセキュリティ', 'CORS エラーの原因特定', '以下のエラーが発生した原因として正しいものはどれですか？

Access to fetch at ''http://localhost:8080/api/views'' from origin ''http://localhost:5174'' has been blocked by CORS policy: The ''Access-Control-Allow-Origin'' header has a value ''http://localhost:5173'' that is not equal to the supplied origin.', '// Go バックエンド
w.Header().Set("Access-Control-Allow-Origin", "http://localhost:5173")

// フロントエンドは http://localhost:5174 で起動中', '["フロントエンドのコードに誤りがある", "バックエンドの CORS 許可オリジンが 5173 固定のため、5174 で起動した Vite からのリクエストが拒否された", "fetch の URL が間違っている", "ブラウザのキャッシュが原因"]'::jsonb, 1, 'CORS は『ブラウザが』リクエスト元のオリジン（プロトコル + ホスト + ポート）とサーバーが返す Access-Control-Allow-Origin を比較し、一致しない場合にブロックします。Vite は 5173 が使用中のとき自動的に 5174 に切り替えるため、固定値のままでは起動のたびに壊れます。', 'view-counter/backend/main.go'),
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

今回のケースは localhost 開発環境専用かつ Credentials なしのため実害はありませんが、本番コードに流用しないよう注意が必要です。', 'view-counter/backend/main.go'),
  (39, 'セクション15: フロントエンドアーキテクチャ選定', 'SPA / RSC / Astro の使い分け', '「徹底的なパフォーマンス最適化」を目指す場合、アーキテクチャ選定の基準として最も正確な説明はどれですか？', '// A: Vite + React SPA
// B: Next.js App Router (RSC)
// C: Astro (Islands Architecture)', '["RSC は常に最速なので、すべてのプロジェクトで採用すべき", "プロダクトの性質（コンテンツ駆動 vs インタラクション駆動）によって最適解は変わるため、銀の弾丸はない", "Astro は静的サイト専用で、動的コンテンツには使えない", "SPA はパフォーマンスが劣るため、現代では使うべきではない"]'::jsonb, 1, 'アーキテクチャ選定はユースケース依存です。

・SPA（Vite + React）: インタラクションが密なアプリ（クイズ、管理画面など）に適切
・RSC（Next.js）: データ取得が多くインタラクションが少ないコンテンツ駆動サイトで効果的。ライブラリがバンドルに含まれず転送量が削減される
・Astro（Islands）: ほぼ静的で一部だけインタラクティブなサイトに最適

「銀の弾丸はない」がアーキテクチャ設計の大原則です。', 'アーキテクチャ設計原則'),
  (40, 'セクション15: フロントエンドアーキテクチャ選定', 'React Server Components (RSC) の特徴', 'React Server Components (RSC) がクライアントバンドルサイズを削減できる理由はどれですか？', '// Server Component（サーバー側のみで実行）
async function ProductList() {
  const data = await db.query(...)  // DBに直接アクセス可
  return <ul>{data.map(...)}</ul>
}
// このコンポーネントで使ったライブラリはブラウザに送られない', '["コードを自動的に圧縮するから", "Server Components はサーバー側のみで実行され、そこで使ったライブラリはクライアントの JavaScript バンドルに含まれないから", "画像を自動的に最適化するから", "不要な CSS を削除するから"]'::jsonb, 1, 'Server Components はサーバー側でのみ実行されます。使ったライブラリ（例: 巨大な日付フォーマットライブラリ）はブラウザに一切送信されず、ネットワーク転送量を削減できます。

ただし Hydration がゼロになるわけではなく「選択的 Hydration」が正確な表現です。''use client'' がついた Client Components は従来通り Hydration されます。', 'React Server Components'),
  (41, 'セクション15: フロントエンドアーキテクチャ選定', 'クイズアプリに最適なアーキテクチャ', '今回開発しているクイズアプリ（ユーザーが問題を選択・回答し、リアルタイムでフィードバックを受ける）に最も適したアーキテクチャはどれですか？', '// クイズアプリの特性
// - 問題選択・回答 → state 管理が必要
// - 正解/不正解フィードバック → リアルタイムな UI 更新
// - 問題データは静的 JSON', '["Next.js (RSC): サーバー側レンダリングで SEO を最適化すべき", "Astro (Islands): 静的コンテンツが多いので Islands が最適", "Vite + React SPA: インタラクションが密でほぼ全域が動的なため SPA が素直に合う", "どれでも同じなので、チームの慣れで決めればよい"]'::jsonb, 2, 'クイズアプリはインタラクション駆動型の典型例です。

・問題の選択・回答・フィードバックはすべて state で管理
・ほぼ全域が動的なため Astro の Islands の旨味がない
・問題データが静的 JSON なので RSC の「DB直接アクセス」の恩恵も薄い

Vite + React SPA が最もシンプルで適切です。パフォーマンス改善が必要な場合は RSC より先に React.memo / useMemo / React.lazy（コード分割）を検討するのが現実的です。', 'フロントエンドアーキテクチャ選定'),
  (42, 'セクション16: パフォーマンス最適化の判断基準', '主張評価: 計測前提での最適化判断', '次の評価のうち、最も妥当なものはどれですか？

A. State Colocation 推奨
B. Zustand/Jotai 強推奨
C. Code Splitting 推奨', '// 前提: クイズアプリ (Vite + React SPA)
// 目的: パフォーマンス最適化方針の妥当性を評価する', '["A, B, C すべて無条件で正しい", "A は良い習慣だが前提条件が必要、B は計測なき最適化になりやすく注意、C は方向性は正しいが効果はアプリ規模に依存", "B だけが唯一正しく、まずグローバル状態管理ライブラリを導入すべき", "C は不要で、コード分割は現代のビルドツールなら自動で最適化される"]'::jsonb, 1, '実務では『計測なき最適化』を避けることが重要です。

・State Colocation: 不要な再レンダリング伝播が原因と確認できた場合に有効
・Zustand/Jotai: 共有状態の複雑化が実際にボトルネックになってから検討
・Code Splitting: 初期バンドルや LCP/INP の実測悪化がある場合に効果が出る

結論として、最適化施策は常に計測結果とアプリ規模を前提に採用判断する。', 'パフォーマンス最適化原則'),
  (43, 'セクション17: Go の並行処理と排他制御', 'sync.Mutex の英文読解', '次の Go 公式ドキュメントの英文から読み取れる `Mutex` の説明として、最も適切なものはどれですか？', 'A Mutex is a mutual exclusion lock.
The zero value for a Mutex is an unlocked mutex.
A Mutex must not be copied after first use.
Lock locks m. If the lock is already in use, the calling goroutine blocks until the mutex is available.', '["Mutex は最初から lock 済みで、コピーして使い回すことが推奨される", "Mutex は相互排他ロックで、初期状態は unlocked。すでに使用中なら利用可能になるまで goroutine は待機する", "Mutex は goroutine ごとの専用ロックで、Lock した goroutine 以外は Unlock できない", "Mutex は読み取り専用ロックなので、共有データの書き込み保護には向かない"]'::jsonb, 1, '`A Mutex is a mutual exclusion lock.` は「Mutex は相互排他ロックである」という意味です。つまり、同じ共有データに複数の goroutine が同時に入らないように制御します。`The zero value for a Mutex is an unlocked mutex.` は「初期値の Mutex は未ロック状態」という意味で、宣言直後から使えます。`A Mutex must not be copied after first use.` は「使い始めた後はコピーしてはいけない」という注意です。さらに `If the lock is already in use, the calling goroutine blocks until the mutex is available.` から、すでに誰かが Lock している間は、次の goroutine は利用可能になるまで待機すると読み取れます。', 'https://pkg.go.dev/sync#Mutex'),
  (44, 'セクション18: Docker Compose とビルド設定', 'failed to read dockerfile の原因と対処', '次のエラーが発生した。最も適切な原因と解決策の組み合わせはどれですか？

failed to solve: failed to read dockerfile: open Dockerfile: no such file or directory', '# 前提
# - docker-compose.yml の api に build: ./backend を指定
# - backend/ に Dockerfile は存在しない
# - 実行場所: vite-quiz-app/backend', '["原因: ポート 8080 が競合している。解決: ports を 8081:8080 に変更する", "原因: build コンテキスト内に Dockerfile がない。解決: Dockerfile を配置し、compose の build.context / dockerfile を正しいパスに合わせる", "原因: depends_on の順序が逆。解決: db を削除して api 単体起動にする", "原因: Vite が起動している。解決: npm run dev を停止すれば Dockerfile なしでもビルドできる"]'::jsonb, 1, 'このエラーは Docker がビルド時に Dockerfile を見つけられないときに発生します。`build: ./backend` は compose ファイルの配置位置を基準に解決されるため、意図と異なるディレクトリを参照することがあります。対策は (1) Dockerfile をビルドコンテキストに置く、(2) `build.context` と `build.dockerfile` を実ディレクトリ構成に合わせて明示する、の2点です。', 'Docker Compose Build Specification'),
  (45, 'セクション19: DB マイグレーション運用', '本番マイグレーションでの IF EXISTS/IF NOT EXISTS', 'CI/CD 前提の本番マイグレーションで、再実行可能性（冪等性）を高める方針として最も適切なのはどれですか？', '-- 例
DROP TABLE IF EXISTS temp_table;
CREATE TABLE IF NOT EXISTS users (...);', '["本番では失敗を早く検知するため、IF EXISTS は使わないのが常に正解", "本番では IF EXISTS / IF NOT EXISTS を適切に使い、アトミックかつリバーシブルなマイグレーションにする", "IF EXISTS は開発環境でのみ有効で、本番SQLでは無効", "IF EXISTS を使うとロールバック不能になるため禁止すべき"]'::jsonb, 1, 'モダンな CI/CD では、デプロイやロールバックの再試行可能性が重要です。`IF EXISTS` / `IF NOT EXISTS` は環境差分や途中失敗後の再実行でスクリプト全体のクラッシュを防ぎやすくし、冪等性の実装に寄与します。', 'MDN/各種Migrationベストプラクティス要約'),
  (46, 'セクション20: Flutter 実行環境トラブルシュート', 'No supported devices found の原因', '以下の実行で `No supported devices found with name or id matching ...` が出た。最も適切な対処はどれですか？', 'flutter run -d 8D8A5796-D4C7-4BB9-B135-
DBF87FC258BA --dart-define-from-file=dart-defines.json', '["UUID を途中改行で分断しない。Simulator を boot してから `flutter devices` で認識を確認する", "`--dart-define-from-file` を削除すれば必ずデバイス認識される", "`flutter run` の代わりに `npm run dev` を使う", "UUID は不要で、常に `-d ios` 固定が正解"]'::jsonb, 0, 'ログでは UUID が改行で分断され、`zsh: command not found` も発生しています。まず UUID を1行で渡し、必要なら `xcrun simctl boot <UUID>` と `open -a Simulator` 後に `flutter devices` で対象が見えることを確認します。', 'Flutter CLI / simctl 実行ログ'),
  (47, 'セクション21: Node.js 環境トラブルシュート', 'npm EACCES と root-owned cache', '`npm ERR! code EACCES` と `Your cache folder contains root-owned files` が出た場合の実務的な対処として最も適切なのはどれですか？', 'npm ERR! Your cache folder contains root-owned files ...
npm ERR! To permanently fix this problem, run: sudo chown -R ... ~/.npm', '["毎回 `sudo npm install` で実行し続ける", "案内された通り `.npm` キャッシュ所有者を現在ユーザーへ戻し、以後は通常ユーザーで npm を実行する", "node_modules を削除するだけで必ず解決する", "OS を再起動すれば再発しない"]'::jsonb, 1, '原因はキャッシュ配下の所有権不整合です。まず所有者を修正し、以後 `sudo npm` を常用しない運用へ戻すのが再発防止に有効です。', 'npm エラーメッセージ'),
  (48, 'セクション22: Docker Compose とビルド反映', 'docker compose up だけでは反映されない理由', 'Go アプリを Dockerfile で `go build -o server .` している構成で、`main.go` に `fmt.Printf(...)` を追加したのに `docker compose logs api` に出ない。最も適切な説明と対処はどれですか？', 'FROM golang:1.26-alpine AS build-env
COPY . /app
WORKDIR /app
RUN go mod download
RUN go build -o server .

FROM alpine:3.19
COPY --from=build-env /app/server /app/server
CMD ["./server"]', '["`fmt.Printf` は Docker では常に捨てられるので、`log.Printf` に変えない限り `docker compose logs` には出ない", "既存コンテナは以前ビルドした `server` バイナリを実行している。ソース変更を反映するには `docker compose up --build` でイメージを再ビルドする", "`docker compose up` は毎回自動で再ビルドするが、Go の `runtime.NumCPU()` だけはログ出力されない", "PostgreSQL の checkpoint ログが大量に出ると API ログは非表示になるため、db コンテナを停止してから起動する"]'::jsonb, 1, 'この構成ではコンテナ内で実行されるのはソースコードではなく、ビルド済みの `server` バイナリです。`main.go` を編集しても既存イメージや既存コンテナには自動反映されません。`docker compose up --build` あるいは `docker compose build` 後に再起動して、最新ソースからバイナリを作り直す必要があります。`fmt.Printf` 自体は標準出力に出るため、再ビルド後であれば `docker compose logs api` で確認できます。', 'Docker Compose / Dockerfile build behavior'),
  (49, 'セクション23: air による Go 開発環境', 'air で自動再起動させるための条件', 'Go API を Docker 上で `air` により自動再起動させたい。最も適切な構成はどれですか？', 'services:
  api:
    build:
      context: .
      target: dev
    volumes:
      - .:/app
    command: ["air", "-c", ".air.toml"]', '["本番用のビルド済みバイナリを実行するだけでよく、ソースコードの volume mount も `air` 設定も不要", "`air` をコンテナ内に入れ、ソースコードを volume mount し、`air` を PID 1 として起動する", "PostgreSQL コンテナに `air` を入れれば、`api` コンテナも自動で再起動する", "`docker compose logs -f api` を開いておけば、ファイル変更時に自動再起動される"]'::jsonb, 1, '`air` はファイル監視ツールなので、監視対象のソースコードがコンテナ内から見えている必要があります。そのため、開発用コンテナには `air` のインストール、ソースコードの bind mount、`air` を起動コマンドにする設定が必要です。単にビルド済みバイナリを実行するだけの構成では自動再起動されません。', 'air / Docker Compose development setup'),
  (50, 'セクション23: air による Go 開発環境', 'air.toml の root と tmp_dir の意味', '次の `air` 設定について、`root` と `tmp_dir` の説明として最も適切なのはどれですか？', 'root = "."
tmp_dir = "tmp"

[build]
cmd = "go build -o ./tmp/server ."
entrypoint = "./tmp/server"
include_ext = ["go"]
exclude_dir = ["tmp"]', '["`root` は Go module 名、`tmp_dir` は Docker volume 名である", "`root` は `air` が監視とビルドの基準にする作業ディレクトリ、`tmp_dir` は再ビルド時の一時成果物を置くディレクトリである", "`root` は実行バイナリ名、`tmp_dir` は PostgreSQL のデータ保存先である", "`root` は常に `/` 固定で、`tmp_dir` は指定しても無視される"]'::jsonb, 1, '`root` は `air` がプロジェクトの基準ディレクトリとして扱う場所です。この例では `.` なので、`air` を起動した現在ディレクトリを基準に監視・ビルドします。`tmp_dir` は再ビルドした実行ファイルなどの一時ファイル置き場で、この設定では `./tmp` 配下が使われます。', 'air configuration semantics'),
  (51, 'セクション23: air による Go 開発環境', 'air の build 設定と typo の見分け方', '次の設定断片を見たときの判断として最も適切なのはどれですか？', '[build]
cmd = "go build -o ./tmp/server ."
bin = "./tmp/server ."
include_ext = ["go"]
exclude_dir = ["tmp"]', '["`bin` の値に余分な ` .` が入っており不自然で、実行パス指定として typo を疑うべきである", "`bin = \"./tmp/server .\"` は Go の標準的な書き方で、末尾の `.` は必須である", "`cmd` の `go build` は不要で、`air` はソースコードを直接実行するため常に `bin` だけあればよい", "`exclude_dir = [\"tmp\"]` を入れると `cmd` は実行されなくなる"]'::jsonb, 0, '`cmd` の末尾の `.` は `go build` のビルド対象として自然ですが、`bin` や実行パスに `./tmp/server .` のような値が入るのは不自然です。実行ファイルの指定なら通常は `./tmp/server` で、末尾の空白と `.` は typo を疑うのが妥当です。現行設定では deprecated な `bin` ではなく `entrypoint = "./tmp/server"` を使う形にしています。', 'air build configuration troubleshooting'),
  (52, 'セクション23: air による Go 開発環境', 'include_ext と exclude_dir を両方入れる理由', '次の `air` 設定で `include_ext` と `exclude_dir` を両方指定する主な理由として最も適切なのはどれですか？', '[build]
cmd = "go build -o ./tmp/server ."
entrypoint = "./tmp/server"
include_ext = ["go"]
exclude_dir = ["tmp"]', '["`.go` の変更だけを監視しつつ、ビルド成果物のある `tmp` を監視対象から外して不要な再検知ループを防ぐため", "Go は `include_ext` と `exclude_dir` を必ず同時に書かないとコンパイルできないため", "`exclude_dir = [\"tmp\"]` を入れると `tmp` 配下にだけ変更を限定して高速化できるため", "`include_ext = [\"go\"]` はログの色を変える設定で、監視とは無関係であるため"]'::jsonb, 0, '`include_ext = ["go"]` により、Go ソースの変更に絞って監視できます。一方 `exclude_dir = ["tmp"]` を入れておかないと、`cmd` が生成した `./tmp/server` などの成果物まで再度検知して、無駄な再ビルドや再起動ループの原因になります。', 'air watch configuration'),
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
CMD ["./server"]', '["開発用はソースを mount して `air` で変更を監視するが、本番用はビルド済みバイナリを固定イメージとして実行する", "開発用と本番用の違いはポート番号だけで、再ビルド反映の考え方は同じである", "本番用のほうが `air` による自動再起動が強く有効になる", "開発用は必ず `docker compose up --build` が必要で、本番用は不要である"]'::jsonb, 0, '開発用構成は bind mount したソースコードを `air` が監視し、その場で再ビルド・再起動します。一方、本番用は Docker build 時に作ったバイナリを含むイメージを実行する構成で、起動後にソース変更を自動反映する仕組みは持ちません。目的が異なるため、同じ運用を期待しないことが重要です。', 'Docker development vs production architecture'),
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
- そのため `docker compose up --build` が必要になりやすいのは B です。', 'Docker Compose build reflection behavior'),
  (55, 'セクション23: air による Go 開発環境', 'root = "." を別ディレクトリに変えたときの影響', '`air` 設定で `root = "."` を `root = "./handlers"` に変更した。下の設定断片を前提に、最も起きやすい影響はどれですか？', 'root = "./handlers"
tmp_dir = "tmp"

[build]
cmd = "go build -o ./tmp/server ."
entrypoint = "./tmp/server"', '["`air` の基準ディレクトリが `./handlers` になり、監視範囲や `cmd` の相対パス解決が変わってビルド対象がズレる可能性がある", "`root` はログ表示用の文字列なので、実際の動作には影響しない", "`root` を変えると PostgreSQL の接続先も自動で切り替わる", "`root` をサブディレクトリにすると `air` は必ずすべての親ディレクトリも自動監視するので問題は起きない"]'::jsonb, 0, '`root` は `air` の作業基準ディレクトリです。ここをサブディレクトリへ変えると、監視対象の範囲だけでなく、`cmd` や `entrypoint` の相対パス解決基準も変わります。その結果、本来プロジェクトルートで実行したい `go build` が別ディレクトリ基準になり、ビルド失敗や意図しない監視範囲になることがあります。', 'air root directory behavior'),
  (56, 'セクション23: air による Go 開発環境', 'exclude_dir = ["tmp"] を消したときの不具合', '次の設定のように `exclude_dir = ["tmp"]` を削除したとき、最も起きやすい不具合はどれですか？', 'tmp_dir = "tmp"

[build]
cmd = "go build -o ./tmp/server ."
entrypoint = "./tmp/server"
include_ext = ["go"]', '["`./tmp/server` などの生成物まで監視対象に入り、再ビルドのたびに再検知して無駄な再起動やループの原因になりやすい", "`air` が `.go` ファイルを監視しなくなり、変更しても何も起きなくなる", "`tmp` ディレクトリが自動で PostgreSQL 用 volume に変換される", "`exclude_dir` を省略すると `entrypoint` が無視されて `cmd` だけが 1 回実行される"]'::jsonb, 0, 'この構成では `cmd` が `./tmp/server` を更新します。`tmp` を除外しないと、その生成物への変更まで `air` が検知してしまい、再ビルド後の成果物をまた変更と見なして、不要な再起動やループを引き起こしやすくなります。', 'air exclude_dir troubleshooting'),
  (57, 'セクション23: air による Go 開発環境', 'entrypoint と cmd の役割分担', '次の `build` 設定における `cmd` と `entrypoint` の役割分担として、最も適切なのはどれですか？', '[build]
cmd = "go build -o ./tmp/server ."
entrypoint = "./tmp/server"', '["`cmd` は再ビルド時に実行するコマンド、`entrypoint` はビルド後に起動する実行ファイルやコマンドを指す", "`cmd` と `entrypoint` は完全に同義で、どちらを書いても内部的に同じ処理になる", "`cmd` は Docker Compose 用、`entrypoint` は PostgreSQL 接続用の設定である", "`entrypoint` は監視拡張子の一覧を表し、`cmd` はログの出力形式を表す"]'::jsonb, 0, '`cmd` はソース変更時に何でビルドするかを定義する項目です。この例では `go build -o ./tmp/server .` がそれに当たります。一方 `entrypoint` は、そのビルド成果物として何を実行するかを表し、ここでは `./tmp/server` を起動します。つまり、`cmd` は作る処理、`entrypoint` は動かす対象です。', 'air cmd vs entrypoint semantics'),
  (58, 'セクション24: Codex 設定トラブルシュート', 'unknown variant xhigh の直接原因', '次のエラーの直接原因として最も適切なのはどれですか？', 'Error loading configuration: unknown variant ''xhigh'' ... expected one of minimal, low, medium, high', '["Codex 本体のバイナリ破損", "`model_reasoning_effort` に許可されていない値 `xhigh` が設定されていた", "ネットワークがオフラインだった", "API トークンの期限切れ"]'::jsonb, 1, 'このエラーは設定値の列挙型チェックで発生しています。`model_reasoning_effort` が受け付ける値は `minimal | low | medium | high` だけで、`xhigh` はスキーマ外です。', 'Codex config validation behavior'),
  (59, 'セクション24: Codex 設定トラブルシュート', 'なぜ xhigh が入りやすいか', '`xhigh` のような無効値が設定に残る経路として、最も現実的なのはどれですか？', 'model_reasoning_effort = "xhigh"', '["過去の会話ログや内部表現（例: reasoning_effort）をそのまま `config.toml` に転記した", "TOML では high が自動的に xhigh に変換される", "Go のバージョンが古いと high が xhigh に展開される", "Docker Compose が起動時に設定文字列を改変する"]'::jsonb, 0, '設定エラーの多くは『別コンテキストで使われていた値やサンプルをそのまま貼る』ことで起きます。TOML や Docker が自動変換した可能性は低く、手動転記ミスのほうが説明力があります。', 'Configuration drift troubleshooting'),
  (60, 'セクション24: Codex 設定トラブルシュート', 'なぜ high への変更で直るのか', '`model_reasoning_effort = "high"` に修正すると起動できる主な理由はどれですか？', 'model_reasoning_effort = "high"', '["`high` が許可済みの列挙値で、設定パーサーのバリデーションを通過するため", "`high` だと認証をスキップできるため", "`high` だと自動でネットワーク設定が修正されるため", "`high` だと API エンドポイントが localhost に変わるため"]'::jsonb, 0, '今回の失敗点は設定読み込み段階の enum 不一致でした。許可された値に戻すことで、起動前バリデーションが通り CLI が通常起動します。', 'Codex startup configuration parsing'),
  (61, 'セクション24: Codex 設定トラブルシュート', '再発防止の確認コマンド', '設定修正後に再発防止の観点で最初に実行する確認として適切なのはどれですか？', 'codex --help', '["ヘルプ表示などの軽量コマンドで設定読み込みに失敗しないことを先に確認する", "いきなり長時間の本番バッチを実行する", "設定ファイルを削除して毎回再生成する", "エラーが出なくても毎回 Docker を再ビルドする"]'::jsonb, 0, '`codex --help` は副作用が少なく、設定パースの成否をすぐ確認できます。まず軽量コマンドで健全性を確認してから本処理へ進むのが安全です。', 'Operational verification pattern'),
  (62, 'セクション24: Codex 設定トラブルシュート', '切り分け時の探索対象', 'ワークスペース内に該当設定が見つからない場合、次に優先して調べるべき場所はどれですか？', '# workspace で見つからない場合', '["ユーザーホーム配下の `~/.codex/config.toml`", "`node_modules` の任意ライブラリ", "Docker コンテナ内の `/var/lib/postgresql/data`", "ブラウザの localStorage"]'::jsonb, 0, 'Codex CLI の恒久設定はユーザースコープに置かれることが多く、ワークスペース外の `~/.codex/config.toml` が原因点になるケースがあります。今回もここが実際の修正箇所でした。', 'User-scope CLI configuration'),
  (63, 'セクション25: Go 標準ライブラリ読解', 'LookupEnv の戻り値の意味', '次のコードについて、最も正しい説明はどれですか？', 'func LookupEnv(key string) (string, bool) {
	testlog.Getenv(key)
	return syscall.Getenv(key)
}', '["環境変数が未設定でも常に `(\"\", true)` を返す", "第2戻り値は『キーが存在したか』を表し、値が空文字でも存在していれば true になる", "`testlog.Getenv` が環境変数の実体を読み取り、第1戻り値として返している", "`LookupEnv` は値だけを返し、bool は常に false になる"]'::jsonb, 1, '`LookupEnv` は `(value, found)` を返す API です。ここでは最終的に `syscall.Getenv(key)` の結果をそのまま返しています。`found` は『環境変数が存在するか』を表すため、値が空文字でもキーが設定済みなら true です。未設定の場合のみ false になります。`testlog.Getenv(key)` はテスト用ログフックで、戻り値の意味そのものは `syscall.Getenv` に依存します。', 'Go os.LookupEnv implementation'),
  (64, 'セクション26: Go runtime 診断出力', 'runtime.NumCPU の意味', '次のコード断片における `runtime.NumCPU()` の説明として最も適切なのはどれですか？', 'fmt.Printf("Number of CPUs: %d\n", runtime.NumCPU())', '["現在の goroutine 数を返す", "実行可能な論理CPU数を返し、Goプロセスが使う並列数そのものとは限らない", "常に物理CPUソケット数を返す", "Goのバージョン文字列を返す"]'::jsonb, 1, '`runtime.NumCPU()` はマシンの論理CPU数を返します。ただし実際の並列実行上限は `GOMAXPROCS` によって制御されるため、`NumCPU` と実効並列度は常に一致するとは限りません。', 'Go runtime package'),
  (65, 'セクション26: Go runtime 診断出力', 'runtime.GOMAXPROCS(0) の読み取り', '`runtime.GOMAXPROCS(0)` をログ表示に使う主な意図はどれですか？', 'fmt.Printf("GOMAXPROCS: %d\n", runtime.GOMAXPROCS(0))', '["GOMAXPROCS を 0 に設定して無効化するため", "現在値を変更せずに、並列実行に使う OS スレッド数の上限を取得するため", "goroutine をすべて停止するため", "CPU 使用率をパーセントで取得するため"]'::jsonb, 1, '`GOMAXPROCS(n)` は通常『設定して旧値を返す』APIですが、`n=0` のときは設定変更せず現在値を返します。診断ログでは副作用なく現設定を確認できるため有用です。', 'Go runtime.GOMAXPROCS'),
  (66, 'セクション26: Go runtime 診断出力', 'runtime.NumGoroutine の解釈', '`runtime.NumGoroutine()` の値を監視する際の注意点として最も適切なのはどれですか？', 'fmt.Printf("Number of Goroutines: %d\n", runtime.NumGoroutine())', '["この値は常に 1 で固定される", "この値は現在生存している goroutine 数のスナップショットで、負荷やタイミングで変動する", "この値は OS スレッド数と必ず同じ", "この値はメモリ使用量(MB)を示す"]'::jsonb, 1, '`NumGoroutine` は瞬間値です。リクエスト処理中やバックグラウンドタスクの有無で増減します。単発値だけでなく時系列で見るとリーク検知に役立ちます。', 'Go runtime.NumGoroutine'),
  (67, 'セクション26: Go runtime 診断出力', 'runtime.Version の用途', '起動時に `runtime.Version()` を出力する主なメリットはどれですか？', 'fmt.Printf("Go Version: %s\n", runtime.Version())', '["アプリのビジネスロジックを高速化するため", "実行バイナリがどの Go ランタイムで動作しているかを運用時に追跡するため", "JWT の署名方式を選択するため", "DB 接続数を自動調整するため"]'::jsonb, 1, '運用環境での不具合調査では『どの Go バージョンで動いているか』の可観測性が重要です。`runtime.Version()` のログは再現性確認やデプロイ差分の切り分けに有効です。', 'Go runtime.Version'),
  (68, 'セクション26: Go runtime 診断出力', 'runtime.GOOS / GOARCH の意味', '`runtime.GOOS` と `runtime.GOARCH` を同時にログ出力する目的として最も適切なのはどれですか？', 'fmt.Printf("OS/Arch: %s/%s\n", runtime.GOOS, runtime.GOARCH)', '["HTTP レスポンスの Content-Type を決めるため", "実行バイナリの対象プラットフォーム（OS/アーキテクチャ）を明示し、環境差異を診断しやすくするため", "データベース方言を切り替えるため", "CORS 設定を自動生成するため"]'::jsonb, 1, '`GOOS/GOARCH` は実行環境の識別子です。コンテナやクロスビルド環境では想定外の組み合わせで動くことがあるため、起動時に可視化しておくと障害対応が速くなります。', 'Go runtime constants'),
  (69, 'セクション27: runtime 診断ログの実践読解', 'NumCPU と GOMAXPROCS が同じ値の意味', '次の起動ログから読み取れる状態として最も適切なのはどれですか？', 'Number of CPUs: 12
GOMAXPROCS: 12', '["CPU制限が設定されていて、Goプロセスはすべての論理CPUを使用可能", "Go プロセス用に意図的に 6 つの CPU が割り当てられている", "マシンに物理 CPU ソケットが 6 個ある", "このプロセスは単一スレッドで動く"]'::jsonb, 0, 'NumCPU と GOMAXPROCS が同じ値なら、デフォルト設定で全論理CPU を並列実行に使えます。Docker 環境なら cpus 制限がない状態、物理マシンならマシン全体で並列実行できます。', 'Container / Runtime CPU diagnostics'),
  (70, 'セクション27: runtime 診断ログの実践読解', '起動直後の Goroutines: 1 の状態', '起動直後に Goroutines: 1 と表示される状態から、リクエスト受信中にこの数が増える主な原因はどれですか？', 'Number of Goroutines: 1  // 起動直後
// リクエスト受信後は増加する', '["メモリリークがある", "HTTP リクエストハンドラーが新しい goroutine を起動しているか、バックグラウンドタスクが実行されている", "CPU 使用率が上がった", "Go のバージョンが古い"]'::jsonb, 1, '起動直後は main goroutine だけで 1 ですが、http.ListenAndServe でリクエスト受信時に handler goroutine が生成され、数が増えます。多数の同時リクエストやバック側タスク実行で、さらに増加します。', 'Goroutine lifecycle in HTTP server'),
  (71, 'セクション27: runtime 診断ログの実践読解', 'NumCPU=12, GOMAXPROCS=12, Goroutines=1 の組み合わせから判断できること', '次のログを見たときの状態判断として最も適切なのはどれですか？', 'Number of CPUs: 12
GOMAXPROCS: 12
Number of Goroutines: 1', '["CPU リソースは十分で、並列度は高いが、起動直後でまだリクエストを受け取っていない状態", "CPU が過負荷で、Goroutine が 1 つだけしか作成できない", "Go プロセスはシングルスレッド", "ネットワークが遮断されている"]'::jsonb, 0, '全 CPU が利用可能で並列実行可能な環境「なのに」 Goroutines が 1 つとは、まさに起動直後やアイドル状態を意味します。反対に数百～千の Goroutine がいれば、高負荷状態です。', 'Runtime diagnostics interpretation'),
  (72, 'セクション27: runtime 診断ログの実践読解', 'OS/Arch: linux/amd64 の環境判断', 'OS/Arch: linux/amd64 というログから推測できる運用環境として、最も可能性が高いのはどれですか？', 'OS/Arch: linux/amd64', '["Windows Server 環境で WSL を使用している", "Apple Silicon Mac（ARM64）上での実行", "Docker コンテナ内での実行、Linux サーバー、または Linux VM", "Raspberry Pi や組み込みデバイス"]'::jsonb, 2, 'linux/amd64 は x86-64 CPU をもつ標準的な Linux 実行環境です。Docker、クラウド環境、Linux サーバーの大多数がこの組み合わせで、ARM や Windows では異なります。', 'Platform identification'),
  (73, 'セクション27: runtime 診断ログの実践読解', '起動ログから推測できる Docker コンテナ構成', '次のログが Docker コンテナ起動時に見える状況を診断するうえで、最も重要な観点はどれですか？', 'api-1  | Number of CPUs: 12
api-1  | GOMAXPROCS: 12
api-1  | Go Version: go1.26.1
api-1  | OS/Arch: linux/amd64', '["コンテナに CPU 制限（--cpus 等）が設定されておらず、ホストのすべての CPU にアクセス可能な状態", "コンテナは ARM ビルド", "Go のバージョンが最新ではない", "アプリケーションに必ずバグがある"]'::jsonb, 0, '12 CPU すべてが見える＝CPU 制限なし。実運用では resource limits を設定して過剰リソース消費を防ぐため、この状況が見えたら限度設定の見直し対象です。', 'Container resource isolation'),
  (74, 'セクション28: PostgreSQL ログ読解', 'checkpoint complete の意味', '次のログの `checkpoint complete` が示す状態として最も適切なのはどれですか？', 'db-1 | LOG: checkpoint complete: wrote 13 buffers (0.1%); ...', '["WAL が破損したため DB が強制終了した", "チェックポイント処理が正常に完了し、dirty page の一部がディスクへ書き出された", "すべてのテーブルが VACUUM された", "クライアント接続がすべて切断された"]'::jsonb, 1, '`checkpoint complete` は障害ではなく、PostgreSQL の定期的な永続化処理の完了ログです。メモリ上の変更（dirty buffers）をディスクへ反映し、リカバリ起点を進めます。', 'PostgreSQL checkpoint logs'),
  (75, 'セクション28: PostgreSQL ログ読解', 'wrote 13 buffers (0.1%) の読み方', '`wrote 13 buffers (0.1%)` という値の解釈として最も適切なのはどれですか？', '... checkpoint complete: wrote 13 buffers (0.1%); ...', '["13 個の接続を切断した", "チェックポイント対象のうち実際に書き込んだバッファが少量で、負荷は比較的軽い", "13 個の WAL ファイルを新規作成した", "13 秒間ロックを保持した"]'::jsonb, 1, '`buffers` は共有バッファ中の書き出し対象ページ数を示します。0.1% と小さいため、このチェックポイントでの書き込み負荷は低めと読めます。', 'PostgreSQL shared buffers metrics'),
  (76, 'セクション28: PostgreSQL ログ読解', 'WAL file(s) added/removed/recycled が 0 の意味', '次のログ断片の解釈として最も適切なのはどれですか？', '... 0 WAL file(s) added, 0 removed, 0 recycled; ...', '["WAL 機能が無効化されている", "そのチェックポイント区間では WAL ファイルの増減・再利用イベントが発生しなかった", "レプリケーションが停止している", "トランザクションが 0 件だった"]'::jsonb, 1, 'この値は WAL 管理イベントの件数です。すべて 0 でも異常とは限らず、単にその期間にファイル追加・削除・再利用が不要だったことを示します。', 'PostgreSQL WAL checkpoint counters'),
  (77, 'セクション28: PostgreSQL ログ読解', 'write / sync / total の関係', '`write=1.221 s, sync=0.019 s, total=1.274 s` の関係として正しい説明はどれですか？', '... write=1.221 s, sync=0.019 s, total=1.274 s; ...', '["total は常に write + sync と完全一致する", "total はチェックポイント全体時間で、write/sync 以外の処理時間も含みうる", "sync はネットワーク同期時間を示す", "write が 1 秒を超えると必ず障害である"]'::jsonb, 1, '`total` はチェックポイント処理全体で、`write` と `sync` のほか管理オーバーヘッドを含むことがあります。したがって厳密一致しない場合があります。', 'PostgreSQL checkpoint timing fields'),
  (78, 'セクション28: PostgreSQL ログ読解', 'lsn と redo lsn の読み方', '`lsn=0/19B0628, redo lsn=0/19B05F0` から読み取れる内容として最も適切なのはどれですか？', '... lsn=0/19B0628, redo lsn=0/19B05F0', '["redo lsn は現在 lsn より常に大きい", "redo lsn はクラッシュリカバリ開始位置を示し、通常は最新 lsn 以下になる", "lsn は CPU 使用率、redo lsn はメモリ使用率を示す", "この値が表示されると必ず WAL 破損を意味する"]'::jsonb, 1, '`LSN` は WAL 上の位置を示す識別子です。`redo lsn` はリカバリ再生の起点で、一般には最新 `lsn` より前方にあります。差分はリカバリ時に再生対象となる範囲の目安になります。', 'PostgreSQL WAL/LSN fundamentals'),
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
}', '["最初に取得しないと `NumGoroutine()` が正しい値を返さなくなるため", "処理前の基準値を保存し、処理完了後に goroutine 数が戻るか比較してリークの目安にするため", "OS スレッド数を取得して `GOMAXPROCS` を自動設定するため", "goroutine を 1 個ずつ停止するための ID を保存するため"]'::jsonb, 1, '`NumGoroutine()` はその瞬間に生存している goroutine 数のスナップショットです。`initial` を処理前の基準値として保存しておくと、処理後の `final` と比較し、終了したはずの goroutine が残っていないかを大まかに確認できます。なお、ランタイム内部 goroutine や計測タイミングの影響があるため、これは厳密なリーク判定ではなく目安として使います。', 'https://pkg.go.dev/runtime#NumGoroutine'),
  (80, 'セクション30: Tailwind CSS クラス読解', 'section の className から見た目を読む', '次の Tailwind CSS の `className` が適用された `<section>` の見た目として、最も適切なのはどれですか？', '<section className="mt-7 rounded-[24px] border border-[#14213d]/12 bg-white/72 p-[clamp(20px,4vw,32px)] shadow-[0_22px_48px_rgba(20,33,61,0.12)]">', '["上に余白があり、24px の角丸、薄いボーダー、少し透けた白背景、20px から 32px の可変 padding、柔らかい影が付いたカード状の見た目", "上余白はなく、角丸もなく、濃い紺色の背景に太い実線ボーダーが付き、padding は 0 で影もない", "背景は完全に透明で、hover 時だけ影と padding が付与される。通常時はボーダーも角丸もない", "50% の丸い角丸と固定 4px の padding が付き、背景色は黒、ボーダーは二重線になる"]'::jsonb, 0, '`mt-7` は上側にマージンを付けます。`rounded-[24px]` は任意値による 24px の角丸です。`border` はボーダーを表示し、`border-[#14213d]/12` はカスタム色 `#14213d` を 12% の不透明度で適用します。`bg-white/72` は白背景に 72% の不透明度を指定しています。`p-[clamp(20px,4vw,32px)]` は画面幅に応じて 20px から 32px の間で変化する padding を与えます。`shadow-[0_22px_48px_rgba(20,33,61,0.12)]` は任意値による柔らかいドロップシャドウです。全体として、少し浮いたカード状のセクションに見えます。', 'Tailwind utility classes / arbitrary values'),
  (81, 'セクション30: Tailwind CSS クラス読解', 'header のレスポンシブ配置を読む', '以下のコードを見て、この `header` の見た目として正しいものはどれですか？', '<header className="mb-[22px] flex flex-col gap-[18px] xl:flex-row xl:items-start xl:justify-between">', '["画面サイズに関わらず、要素は常に横並びに表示される", "小さい画面では縦並び、xl（1280px以上）になると横並びに切り替わり、両端に要素が配置される", "小さい画面では横並び、xl になると縦並びに切り替わる", "画面サイズに関わらず、要素は常に縦並びで中央揃えになる"]'::jsonb, 1, '`flex` で flex コンテナになり、通常は `flex-col` により縦並びです。`gap-[18px]` は子要素間の間隔を 18px にします。`mb-[22px]` は下側マージン 22px です。`xl:flex-row` は xl ブレークポイント以上で横並びへ切り替える指定です。さらに `xl:items-start` で交差軸方向の開始位置に揃え、`xl:justify-between` で主軸方向に要素を両端配置します。したがって、小さい画面では縦並び、xl 以上では横並びで左右に分かれたレイアウトになります。', 'Tailwind utility classes / arbitrary values'),
  (82, 'セクション31: Tailwind CSS ビルド最適化', '未使用クラスの自動削除', 'Tailwind CSS のビルド時パージ（未使用クラスの自動削除）について、最も適切な説明はどれですか？', 'Tailwind はビルド時に使っていないクラスを自動で削除する。
開発時: 数MB（全クラス入り）
本番ビルド後: 数KB〜数十KB（使ったクラスだけ）
Tailwind v3 以降ではデフォルトで自動なので、基本的に追加意識は不要。', '["本番ビルドでも全クラスをそのまま含むため、CSS サイズはほとんど変わらない", "Tailwind はソースファイル内のクラスを検出して必要なスタイルだけを生成するため、本番 CSS を小さくできる", "未使用クラスの削除はブラウザ実行時に JavaScript が動的に行う", "Tailwind v3 以降では未使用クラス削除機能は廃止され、手動で purge ツールを入れる必要がある"]'::jsonb, 1, 'Tailwind のドキュメントでは、Tailwind はプロジェクト内のソースファイルをスキャンしてクラス名を探し、対応するスタイルを生成すると説明されています。つまり、実際に使ったクラスだけが最終 CSS に含まれるため、本番ビルドの CSS サイズを小さくできます。Tailwind CSS v3 の説明でも、同じ CSS を共有しつつ、ほとんどの Tailwind プロジェクトは非常に小さな CSS を配信できるとされています。要するに、未使用クラスの除去は本番ビルド時に自動で効く最適化です。', 'Tailwind production optimization'),
  (83, 'セクション31: Tailwind CSS ビルド最適化', '手動で CSS の膨張を抑える方法', 'Tailwind CSS で、手動で CSS の膨張や保守コストを抑える方法として最も適切なのはどれですか？', '// ❌ これが多いとCSSが膨らむ
p-[17px] p-[23px] p-[31px]

// ✅ デザイントークンに統一する
p-4 p-6 p-8

// ❌ 同じクラスが色んな場所に散らばる
<div className="rounded-2xl bg-white shadow-md p-6">
<div className="rounded-2xl bg-white shadow-md p-6">

// ✅ コンポーネントにまとめる
<Card> // 内部でクラスを管理', '["任意値をできるだけ増やし、同じクラス列も各画面に直接書いたほうが最適化しやすい", "任意値を減らしてデザイントークンへ寄せ、重複するクラスの組み合わせはコンポーネントへまとめる", "CSS の膨張を避けるには Tailwind をやめて、すべて inline style に置き換えるのが最善", "同じクラス文字列を何度も書くほど Tailwind が自動でより強く圧縮してくれる"]'::jsonb, 1, 'Tailwind では未使用クラスの自動削除が効きますが、任意値を細かく増やし続けると生成されるユーティリティの種類が増えやすくなります。そのため、`p-[17px]` のような個別値を乱立させるより、`p-4` `p-6` `p-8` のようにデザイントークンへ寄せた方が設計を揃えやすく、出力も管理しやすくなります。また、`rounded-2xl bg-white shadow-md p-6` のような同じクラスの組み合わせが各所に散らばると、見た目の変更やレビューがしづらくなります。`<Card>` のようなコンポーネントへまとめると、内部でクラスを一元管理でき、保守性と再利用性を上げられます。', 'Tailwind utility classes / arbitrary values'),
  (84, 'セクション32: Tailwind v4 CSS-first 構成', 'v4 での CSS-first 設定の正解', 'Tailwind v4 の CSS-first 構成として、最も適切な説明はどれですか？', '/* app.css */
@import "tailwindcss";

@theme {
  --color-brand-500: oklch(0.72 0.11 221.19);
}

/* HTML */
<div class="bg-brand-500">...</div>', '["`@theme` は通常の `:root` と同じで、Tailwind のユーティリティ生成には影響しない", "`@import \"tailwindcss\";` を CSS で読み込み、`@theme` をトップレベルで定義すると、対応するユーティリティ（例: `bg-brand-500`）が使える", "v4 では CSS に何も書かず、`tailwind.config.js` だけが唯一の設定方法である", "`@theme` は任意のセレクタ内（例: `.card { ... }`）にネストして定義するのが推奨される"]'::jsonb, 1, 'Tailwind v4 では CSS-first の設計が中心で、`@import "tailwindcss";` で Tailwind を読み込みます。`@theme` で定義したテーマ変数は単なる CSS 変数ではなく、Tailwind のユーティリティ生成にも使われます。公式ドキュメントでも `--color-*` などのテーマ変数により `bg-*` 等のクラスが有効になること、`@theme` はトップレベルで定義することが示されています。', 'https://tailwindcss.com/docs/theme'),
  (85, 'セクション33: ES Modules 基礎', 'export default の性質', '次の `export default` の説明として最も適切なのはどれですか？', '// Button.tsx
export default function Button() {
  return <button>OK</button>;
}

// App.tsx
import PrimaryButton from ''./Button'';', '["1つのモジュールで `export default` は複数定義できる", "`export default` で公開した値は、import 側で任意の名前で受け取れる", "`export default` は必ず中括弧付きで import しなければならない", "`export default` は関数には使えず、クラスでしか使えない"]'::jsonb, 1, 'ES Modules では 1 モジュールにつき default export は 1 つだけ定義できます。default export は import 側で `import AnyName from ''...''` のように任意の識別子名で受け取れます。一方、`{ ... }` を使うのは named export を import する場合です。', 'https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/export'),
  (86, 'セクション34: Go Runtime Monitoring 戦略', '本番監視の導入順と閾値設計', 'Go アプリケーションの本番監視方針として、次の結論の要点を最も正しくまとめたものはどれですか？', 'Monitoring Go runtime metrics is essential for maintaining healthy, performant applications in production.

Start with the default Go collector metrics, then add custom metrics as you learn your application''s specific patterns and requirements.

Remember that thresholds should be adjusted based on your application''s characteristics.
Establish baselines during normal operation and set alerts based on meaningful deviations from those baselines.', '["最初から細かい custom metrics と固定しきい値を大量投入し、どのサービスでも同じ alert 条件を使うのが最善", "まず標準の Go runtime 指標を監視し、必要に応じて Prometheus や OpenTelemetry の custom metrics を足し、しきい値はアプリ固有の通常時ベースラインから調整する", "runtime.NumGoroutine() と runtime.ReadMemStats() は開発時だけに使い、本番ではアプリ独自ログだけ見れば十分", "高スループットなバッチ処理と軽量 API では同じ goroutine 数・GC pause しきい値を共有すべき"]'::jsonb, 1, '結論の中心は、「Go runtime の監視は本番で重要であり、まずは標準の runtime 指標から始める」という点です。そのうえで、Prometheus や OpenTelemetry を使って可視化を広げ、必要になったところだけ custom metrics を追加していくのが推奨されています。また、goroutine 数、メモリ使用量、GC pause などの警告しきい値は全サービス共通の固定値ではなく、アプリの特性によって調整すべきだと述べています。つまり、通常運転時のベースラインを先に観測し、そこから意味のある逸脱に対して alert を張る、という運用方針が正解です。', 'Go runtime / Prometheus / OpenTelemetry monitoring'),
  (87, 'セクション35: 英単語 × CSS カラー', '「navy」の英単語の意味', 'CSS で `--color-navy: #14213d;` のように使われる「navy」という英単語の本来の意味として正しいものはどれですか？', '/* index.css */
@theme {
  --color-navy: #14213d; /* 深い紺色 */
}', '["空軍（航空戦力）", "海軍（海上の軍隊）", "陸軍（地上部隊）", "海兵隊（水陸両用部隊）"]'::jsonb, 1, '"navy" の本来の意味は「海軍」です。語源はラテン語の "navis"（船）に由来します。色名としての「ネイビーブルー（navy blue）」はイギリス海軍の制服の色（深い紺色）に由来しており、そこから転じて深い紺色全般を指す色名にもなりました。CSS では `#14213d` のような暗い紺色を `navy` と命名するケースが多いのはこの背景からです。', 'https://www.etymonline.com/word/navy'),
  (88, 'セクション36: React モジュールスコープ', 'コンポーネント外の定数宣言', '次のコードで `allQuizzes` をコンポーネント関数の外（モジュールスコープ）で宣言している主な理由として最も適切なものはどれですか？', '// モジュールスコープ（コンポーネント外）
const allQuizzes = getAllQuizzes()
const sectionCount = groupQuizzesBySection().size
const quizCountPerSession = allQuizzes.length

function JsonQuizPreviewSection() {
  // ...
}', '["React の規約でデータ取得は必ずコンポーネント外で行わなければならない", "コンポーネントの再レンダリングのたびに再計算されないよう、初回モジュール読み込み時に1度だけ評価するため", "`const` はコンポーネント内では使えないため", "ESLint の react-hooks/exhaustive-deps ルールに違反しないようにするため"]'::jsonb, 1, 'モジュールスコープに宣言すると、そのファイルがはじめて import された時点で1度だけ評価されます。コンポーネント内に書いてしまうと、state 変化などで再レンダリングが起きるたびに `getAllQuizzes()` が呼ばれてしまいます。クイズデータのように「変化しない重い初期化」はモジュールスコープに置くことでコストを抑えられます。なお、値が変化しうる場合は `useState` や `useMemo` を使う方が適切です。', 'https://react.dev/learn/keeping-components-pure'),
  (89, 'セクション37: 技術英語読解', '`recommended` の意味', '技術ドキュメントで `It is strongly recommended to restart the server after changing this setting.` と書かれているとき、`recommended` の意味として最も適切なのはどれですか？', 'It is strongly recommended to restart the server after changing this setting.', '["再起動は禁止されている", "再起動が推奨されている", "再起動は必須で、省略すると設定は保存されない", "サーバーは自動的に再起動される"]'::jsonb, 1, '`recommended` は「推奨されている」という意味です。Cambridge Dictionary では、`recommended` は「ある目的や仕事にとって良い・適切だと提案されている、または実行すべき行動として提案されている」と説明されています。したがってこの文は、「この設定を変更したあと、サーバーを再起動するのが強く勧められる」という意味です。`must` のような絶対必須までは言っていませんが、従うべき実務上の推奨として読むのが自然です。', 'https://dictionary.cambridge.org/us/dictionary/english/recommended'),
  (90, 'セクション38: React / TypeScript 英文読解', '`createRoot(container!)` コメントの読解', '次の React 18 の GitHub Issue コメントの意味として、最も適切なものはどれですか？', 'The issue here is that `container` is potentially null. `createRoot(null)` would throw at runtime and therefore rightfully does not compile. If you''re sure it''s not nullable then you can use the `!` operator: `createRoot(container!)`.', '["`container` は常に null ではないので、TypeScript のエラーは誤検知である", "`container` は null の可能性があるため、そのままではコンパイルできないのは正しい。null ではないと確信できるなら `!` で非 null として扱える", "`createRoot(null)` は実行時に安全に無視されるので、`!` は不要である", "`!` 演算子を使うと DOM 要素が自動生成されるので、`getElementById(''root'')` の結果確認は不要になる"]'::jsonb, 1, 'このコメントは、「問題は `container` が null かもしれないことだ」と述べています。`createRoot(null)` は実行時に例外になるため、TypeScript がそのコードを拒否するのは正しい、という意味です。そのうえで、呼び出し側が `container` は null ではないと本当に保証できるなら、non-null assertion の `!` を使って `createRoot(container!)` と書ける、という説明です。つまり、型エラーを黙らせるために無条件で `!` を付けるのではなく、null にならない根拠がある場合だけ使うべき、という文脈です。', 'https://github.com/facebook/react/issues/24208#issuecomment-1082708370'),
  (91, 'セクション39: ESLint / TypeScript ルール読解', '`@typescript-eslint/no-non-null-assertion: ''error''` の意味', '次の ESLint 設定の意味として最も適切なのはどれですか？', '"@typescript-eslint/no-non-null-assertion": "error"', '["postfix `!` を使う non-null assertion を禁止し、違反は ESLint の error として扱われる", "`x!` は `null` と `undefined` を型から除外し、出力される JavaScript では `!` が削除される", "`warn` は違反を報告するが exit code には影響しない", "このルールはオプションで細かく挙動を調整できる"]'::jsonb, 0, '`@typescript-eslint/no-non-null-assertion` は、`!` postfix を使った non-null assertion を禁止するルールです。typesript-eslint の公式 docs でも `Disallow non-null assertions using the ! postfix operator.` と説明されています。さらに ESLint では、ルールを `"error"` にすると違反は error として扱われ、トリガー時は exit code が 1 になります。一方、TypeScript の docs にある「`x!` は `null` / `undefined` を型から除外し、JavaScript 出力では消える」という説明は演算子自体の性質であり、この ESLint 設定の意味そのものではありません。また、この rule は typescript-eslint docs 上で `This rule is not configurable.` とされています。', 'https://typescript-eslint.io/rules/no-non-null-assertion, https://eslint.org/docs/latest/use/configure/rules, https://www.typescriptlang.org/docs/handbook/release-notes/typescript-2-0.html'),
  (92, 'セクション40: TypeScript / Vite エラー対応', 'vite/client 型定義エラーの原因', '次の TypeScript エラーの原因として最も適切なのはどれですか？

Cannot find type definition file for ''vite/client''.
The file is in the program because:
Entry point of type library ''vite/client'' specified in compilerOptions', '// tsconfig.app.json
{
  "compilerOptions": {
    "types": ["vite/client"]
  }
}', '["`types` で `vite/client` を指定しているが、Vite 依存関係の解決に失敗して型定義を見つけられていない", "`vite/client` は TypeScript で使えない予約語である", "`types` 配列に 1 つしか指定できないため発生する", "JSON ファイルの読み込み設定が不足しているため発生する"]'::jsonb, 0, 'このエラーは、`compilerOptions.types` に `vite/client` を指定しているのに、TypeScript が該当型定義を解決できないときに発生します。多くの場合は依存関係の未インストールや壊れた `node_modules` が原因です。', 'TypeScript / Vite configuration error'),
  (93, 'セクション41: TypeScript エラー切り分け', '最初の確認対象', '`Cannot find type definition file for ''vite/client''` が出たとき、最初に確認すべき対象として最も適切なのはどれですか？', '// tsconfig.app.json
{
  "compilerOptions": {
    "types": ["vite/client"]
  }
}', '["tsconfig の `types` 設定が何を要求しているかを確認する", "まず CSS の import を削除する", "React のバージョンを下げる", "eslint.config.js を削除する"]'::jsonb, 0, '切り分けの第一歩は、設定が何を解決しようとしているかを把握することです。`types` に `vite/client` があるなら、TypeScript はその型定義の解決を試みます。', 'TypeScript troubleshooting workflow'),
  (94, 'セクション41: TypeScript エラー切り分け', 'package.json と実体の差分', '`package.json` に `vite` が定義されているのに `npm ls vite --depth=0` が `(empty)` になる状況の説明として正しいのはどれですか？', '// package.json には vite がある
"devDependencies": {
  "vite": "^7.3.1"
}

// ただし npm ls では empty', '["依存定義はあるが、インストールされていない（node_modules が未構築）", "vite は npm ls で表示されない仕様", "TypeScript 5.9 では vite が無効化される", "ESM プロジェクトでは devDependencies が無視される"]'::jsonb, 0, '`package.json` は要求仕様、`node_modules` は実体です。要求があっても install されていなければ解決できません。', 'npm dependency resolution basics'),
  (95, 'セクション41: TypeScript エラー切り分け', 'npm install の役割', '今回のケースで `npm install` を実行する主目的として最も適切なのはどれですか？', 'npm install', '["未導入の依存関係を node_modules に展開し、`vite/client` 型定義を解決可能にする", "tsconfig のエラーを自動で書き換える", "ESLint ルールを自動修正する", "build 出力を dist から削除する"]'::jsonb, 0, '今回の欠損は設定ではなく依存実体です。`npm install` により Vite 本体と型定義ファイルが利用可能になります。', 'npm install behavior'),
  (96, 'セクション41: TypeScript エラー切り分け', '存在確認コマンドの意味', '`test -f node_modules/vite/client.d.ts` を実行する意義として最も適切なのはどれですか？', 'test -f node_modules/vite/client.d.ts && echo ''vite-client-types-ok''', '["TypeScript が参照する型定義ファイルの実在を直接検証する", "tsconfig の JSON 構文を検証する", "Vite の開発サーバーを起動する", "ESLint の警告を無効化する"]'::jsonb, 0, 'ファイルの存在確認は、推測ではなく事実で切り分けるための最短手段です。', 'shell troubleshooting practice'),
  (97, 'セクション41: TypeScript エラー切り分け', '修正完了の判定', 'この問題に対する最終的な完了判定として最も妥当なのはどれですか？', 'npm run build', '["`npm run build` が成功し、TypeScript で同エラーが再現しない", "`package.json` を開いて確認しただけで完了", "`node_modules` が存在すれば無条件で完了", "エディタの表示を閉じれば完了"]'::jsonb, 0, '最終判定は実行結果です。設定確認と依存導入の後、ビルド成功で再現性のある完了確認になります。', 'build verification workflow'),
  (98, 'セクション42: Docker トラブルシュート', 'Cannot connect to the Docker daemon の意味', '次のエラーメッセージの意味として最も適切なのはどれですか？

Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?', 'docker ps', '["Docker CLI は動いているが、接続先の Docker デーモン（バックグラウンドサービス）に接続できていない", "コンテナ数が多すぎて `docker ps` がタイムアウトした", "Dockerfile が見つからないため `docker ps` が失敗した", "イメージの pull が未完了なため必ず出る正常メッセージ"]'::jsonb, 0, 'このエラーは、`docker` コマンド自体ではなく、裏で動く Docker デーモンに接続できない状態を示します。代表例は Docker Desktop が未起動、デーモン停止、またはソケット権限の問題です。', 'Docker daemon connection error'),
  (99, 'セクション42: Docker トラブルシュート', 'コンテナが Exited (255) になる理由', 'リポジトリのコンテナが `Exited (255)` になっている。原因切り分けとして最も適切な最初の行動はどれですか？', 'docker ps -a
docker logs <container_name>', '["終了コードだけでは原因を断定できないため、まず `docker logs` で起動時エラー（環境変数不足、接続失敗、実行ファイルエラーなど）を確認する", "Exited (255) は常にポート競合なので、ポート番号だけ変更すればよい", "Exited (255) は正常終了の意味なので、対応は不要", "コンテナを再作成せずに、OS を再起動すれば必ず解決する"]'::jsonb, 0, '`255` は一般的に異常終了を示しますが、理由はアプリごとに異なります。まずは `docker logs` と `docker inspect` で実際のエラーメッセージを確認し、設定不足・接続先未起動・コマンド実行失敗などを切り分けるのが正攻法です。', 'Docker troubleshooting practice'),
  (100, 'セクション43: DBマイグレーション運用', 'dirty 状態の意味', 'DBマイグレーション文脈で `dirty` 状態と表示されたときの意味として最も適切なのはどれですか？', 'error: Dirty database version 12. Fix and force version.', '["あるマイグレーションが途中で失敗し、スキーマ整合性が不確定なため後続マイグレーションが停止される状態", "DBに不要データが多いので VACUUM が必要な状態", "マイグレーションが完全成功したことを示す正常状態", "SQLファイル名に誤字があるだけで、実行には影響しない警告状態"]'::jsonb, 0, '`dirty` は途中失敗の保護状態です。まず失敗理由と実DB状態を確認し、必要に応じて手動修正してから履歴バージョンと dirty フラグを整合させて再開します。', 'Migration tools common behavior'),
  (101, 'セクション43: DBマイグレーション運用', '000016失敗後に force 16 する意図', '次の対応の説明として最も適切なのはどれですか？

000016 は `information.image_url` が既に存在していたため失敗。
000016 はカラム追加1文のみだったので実体反映済みと判断し、`force 16` で履歴を整えた後に 000017 を適用した。', '-- 000016: ALTER TABLE information ADD COLUMN image_url ...
-- 実DBには既に image_url が存在
-- migration tool: force 16
-- then apply 000017', '["実DBスキーマは16相当まで進んでいると確認できたため、履歴テーブルだけを16に合わせて dirty/不整合を解消し、後続の000017を再開した", "000016 のSQLを自動的にロールバックして、DBを15に完全復元した", "000016 と000017 を同時にスキップし、次回デプロイでまとめて実行する設定にした", "`force 16` はDB実体を自動変更する機能なので、検証なしで使って問題ない"]'::jsonb, 0, 'この対応は『実体と履歴の再同期』です。000016 は「既存カラムのため失敗」だったが、内容がその1文のみで実体が既に満たされていると確認できたため、履歴だけ16に進めて不整合を解消し、次の000017を適用しています。ポイントは force が履歴操作であり、実体変更の代替ではないことです。', 'DB migration incident recovery'),
  (102, 'セクション44: SQL データ操作', 'DELETE + サブクエリの対象理解', '次の SQL クエリの目的として最も適切なものはどれですか？', 'DELETE FROM user_favorite_stores
WHERE user_id IN (SELECT id FROM users WHERE email IN (''user1@example.com'', ''user2@example.com'', ''user3@example.com''));', '["指定メールアドレスのユーザー本体を users テーブルから削除する", "指定メールアドレスのユーザーに紐づく user_favorite_stores の行を削除する", "user_favorite_stores に新しい行を追加する", "users テーブルのメールアドレスを一括更新する"]'::jsonb, 1, '内側のサブクエリで、指定メールアドレスに一致する `users.id` を取得し、外側の DELETE でその `id` を `user_id` に持つ `user_favorite_stores` の行を削除します。削除対象は users 本体ではなく関連テーブルです。', 'SQL DELETE with subquery'),
  (103, 'セクション45: Linux コマンド基礎', 'wc コマンドの意味', '`wc -l src/data/quizzes.json` で使われている `wc` の意味として最も適切なのはどれですか？', 'wc -l src/data/quizzes.json', '["テキストの行数・単語数・バイト数などを数えるコマンド", "ファイルの所有者を変更するコマンド", "ディレクトリ構造をツリー表示するコマンド", "ファイルを圧縮するコマンド"]'::jsonb, 0, '`wc` は word count の略で、入力テキストの統計情報（行数・単語数・バイト数など）を表示するコマンドです。', 'Unix wc command'),
  (104, 'セクション45: Linux コマンド基礎', '`-l` オプションの意味', '`wc -l src/data/quizzes.json` の `-l` オプションが表すものはどれですか？', 'wc -l src/data/quizzes.json', '["ファイルの行数（line count）を表示する", "ファイルの最終更新日時を表示する", "ファイルサイズを人間向け表示にする", "隠しファイルも含めて一覧表示する"]'::jsonb, 0, '`-l` は line の意味で、改行区切りの行数を表示します。今回の出力 `1440 src/data/quizzes.json` はそのファイルが 1440 行であることを示します。', 'wc -l option'),
  (105, 'セクション46: Docker Compose エラー読解', '設定ファイルが見つからないエラーの意味', '次のエラーメッセージの意味として最も適切なものはどれですか？

can''t find a suitable configuration file in this directory or any parent: not found', 'docker compose up', '["現在のディレクトリか親ディレクトリに、利用可能な Compose 設定ファイル（例: docker-compose.yml）が見つからない", "Compose ファイルは見つかったが、ポート競合で起動に失敗している", "Docker デーモンが停止しているため、ソケット接続に失敗している", "イメージのビルドは成功したが、コンテナのヘルスチェックだけ失敗している"]'::jsonb, 0, 'このエラーは、実行場所のパスに Compose 設定ファイルが無いことを示します。`docker compose up` は通常、カレントディレクトリまたは親ディレクトリから `compose.yaml` / `docker-compose.yml` などを探します。', 'Docker Compose configuration lookup'),
  (106, 'セクション47: Node.js / JSON 検証', 'JSON.parse で構文検証するコマンドの意味', '次のコマンドの目的として最も適切なものはどれですか？

node -e "JSON.parse(require(''fs'').readFileSync(''src/data/quizzes.json'',''utf8'')); console.log(''quizzes.json valid'')"', 'node -e "JSON.parse(require(''fs'').readFileSync(''src/data/quizzes.json'',''utf8'')); console.log(''quizzes.json valid'')"', '["quizzes.json を読み込んで JSON 構文が正しいか確認し、成功時にメッセージを表示する", "quizzes.json の内容を自動整形して上書き保存する", "quizzes.json を gzip 圧縮して容量を確認する", "quizzes.json の行数を数えて表示する"]'::jsonb, 0, '`readFileSync` で文字列として読み込んだ JSON を `JSON.parse` しており、構文エラーがあれば例外で失敗します。例外が出なければ `console.log(''quizzes.json valid'')` が表示されるため、簡易的なJSON妥当性チェックとして使えます。', 'Node.js JSON validation pattern'),
  (107, 'セクション48: React exhaustive-deps 実践', '欠けた依存配列が生む不具合', '`useEffect` / `useMemo` / `useCallback` で依存配列に必要な値を入れ忘れたとき、最も起きやすい問題はどれですか？', 'useEffect(() => {
  console.log(count);
}, []); // count を参照しているのに依存配列にない', '["stale closure により古い値を参照し続け、想定した再同期が起きない", "React が自動で依存を補完するので問題は起きない", "依存を省略すると常に最適化されて再レンダリングが減る", "依存配列は本番ビルドでだけ評価される"]'::jsonb, 0, '依存配列は『Effect が参照する値』を宣言するためのものです。参照値を漏らすと、値が変わっても Effect が再実行されず、古いクロージャを掴んだままになります。', 'React exhaustive-deps lint guidance'),
  (108, 'セクション48: React exhaustive-deps 実践', '関数依存で無限ループになる理由', '次のパターンで `useEffect` がループしやすい主な理由はどれですか？', 'const logItems = () => console.log(items);
useEffect(() => {
  logItems();
}, [logItems]);', '["毎レンダーで `logItems` の参照が新しくなり、依存変化として Effect が再実行されるため", "`console.log` は非同期なので必ず再レンダーが起きるため", "依存配列に関数を入れると React が例外を投げるため", "`useEffect` はデフォルトで 2 回しか実行されないため"]'::jsonb, 0, '関数をインライン定義すると参照が毎回変わります。Effect がその関数参照に依存していると、依存が毎回変化したと判断され再実行ループにつながります。必要なら `useCallback` で参照を安定化します。', 'React exhaustive-deps lint guidance'),
  (109, 'セクション48: React exhaustive-deps 実践', '"一度だけ実行"したいときの設計', '`userId` を使う analytics 送信を『実質1回』にしたい。lint を回避せずに実装する方針として最も適切なのはどれですか？', 'useEffect(() => {
  sendAnalytics(userId);
}, []); // lint で userId 不足を指摘', '["`[userId]` を依存に含め、必要なら `useRef` ガードで重複送信を制御する", "eslint-disable コメントで exhaustive-deps を無効化する", "依存配列を削除して毎レンダー送信する", "`userId` を state から外しグローバル変数にする"]'::jsonb, 0, '基本は依存を正しく宣言することです。"一度だけ"の要件がある場合は、依存を隠すのではなく `useRef` などで実行制御を行うのが安全です。', 'React exhaustive-deps lint guidance'),
  (110, 'セクション48: React exhaustive-deps 実践', 'カスタム Effect Hook の lint 対象化', '`useMyEffect` のようなカスタム Hook も exhaustive-deps のチェック対象に含めたい。設定として最も適切なのはどれですか？', '// ESLint settings または rule-level option で正規表現を指定する', '["`settings.react-hooks.additionalEffectHooks` か rule-level の `additionalHooks` に regex を設定する", "TypeScript の `types` 配列に Hook 名を追加する", "Vite config の plugins に Hook 名を列挙する", "React コンポーネント名を PascalCase にすれば自動で検出される"]'::jsonb, 0, 'eslint-plugin-react-hooks では、カスタム Effect Hook を正規表現で指定して依存配列チェック対象に含められます。共有 settings と rule-level option の両方が用意されています。', 'React exhaustive-deps lint guidance'),
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
}', '["exhaustive-deps の警告を eslint-disable コメントで無効化する", "fetchProduct を useCallback でラップし、依存配列に [productId] を指定した上で useEffect の依存配列に [fetchProduct] を追加する", "fetchProduct をそのまま useEffect の依存配列に追加する（[fetchProduct]）", "fetchProduct の定義を useEffect の内部に移動し、依存配列を [productId] にする"]'::jsonb, 3, 'React公式（Hooks FAQ）は「関数をEffect内に移動する」を第一の推奨としています。こうすることでfetchProductが依存配列の問題を引き起こさず、productIdが変わるたびに正しく再実行されます。useCallbackを使う方法（選択肢2）も正しく動作しますが、公式はメモ化より先に「関数をEffect内に移動する」シンプルな解決策を優先しています。選択肢1はuseCallbackなしで関数参照が毎レンダーで変わるため無限ループになります。選択肢0はバグを隠蔽するだけで根本的な解決になりません。', 'https://legacy.reactjs.org/docs/hooks-faq.html#is-it-safe-to-omit-functions-from-the-list-of-dependencies'),
  (112, 'セクション49: TypeScript JSX 読解', 'Intrinsic elements の基本訳', '`Intrinsic elements are looked up on the special interface JSX.IntrinsicElements.` の日本語訳として最も適切なのはどれですか？', 'Intrinsic elements are looked up on the special interface JSX.IntrinsicElements.', '["intrinsic elements は、特別なインターフェース JSX.IntrinsicElements 上で参照される。", "intrinsic elements は、JSX.IntrinsicElements を自動生成する。", "intrinsic elements は、特別なインターフェースを常に無視する。", "intrinsic elements は、JSX.IntrinsicElements に変換される。"]'::jsonb, 0, 'looked up はこの文脈では『参照される』『検索される』の意味で、intrinsic elements が JSX.IntrinsicElements を基準に扱われることを述べています。', 'TypeScript JSX Intrinsic Elements'),
  (113, 'セクション49: TypeScript JSX 読解', 'By default の意味', '本文中の `By default` の意味として最も適切なのはどれですか？', 'By default, if this interface is not specified, then anything goes and intrinsic elements will not be type checked.', '["例外的に", "初期状態では", "明示的に", "結果として"]'::jsonb, 1, '`By default` は『特別な設定がなければ通常は』『初期状態では』という意味で使われています。', 'TypeScript JSX Intrinsic Elements'),
  (114, 'セクション49: TypeScript JSX 読解', 'if this interface is not specified の訳', '`if this interface is not specified` の日本語訳として最も適切なのはどれですか？', 'By default, if this interface is not specified, then anything goes and intrinsic elements will not be type checked.', '["このインターフェースが自動生成される場合", "このインターフェースが指定されていない場合", "このインターフェースを削除した場合", "このインターフェースを継承した場合"]'::jsonb, 1, '`is not specified` は『指定されていない』を意味します。ここでは JSX.IntrinsicElements が定義されていないケースを指しています。', 'TypeScript JSX Intrinsic Elements'),
  (115, 'セクション49: TypeScript JSX 読解', '指定されていない場合の挙動', '本文では、`JSX.IntrinsicElements` が指定されていない場合、intrinsic elements はどう扱われると述べられていますか？', 'By default, if this interface is not specified, then anything goes and intrinsic elements will not be type checked.', '["常に厳密に型チェックされる", "自動的に DOM API に変換される", "何でも許され、型チェックされない", "JSX 構文エラーとして扱われる"]'::jsonb, 2, '本文の `anything goes and intrinsic elements will not be type checked` がそのまま根拠で、制約なしに受け入れられ型チェックも行われません。', 'TypeScript JSX Intrinsic Elements'),
  (116, 'セクション49: TypeScript JSX 読解', 'However の役割', '本文中の `However` はどのような役割をしていますか？', 'However, if JSX.IntrinsicElements is present, then the name of the intrinsic element is looked up as a property on the JSX.IntrinsicElements interface.', '["具体例の追加", "理由の説明", "対比の導入", "結論の強調"]'::jsonb, 2, '前文では『指定されない場合』を説明し、この文では『存在する場合』を説明しているため、However は対比を導入しています。', 'TypeScript JSX Intrinsic Elements'),
  (117, 'セクション49: TypeScript JSX 読解', 'property on the interface の訳', '`the name of the intrinsic element is looked up as a property on the JSX.IntrinsicElements interface` の日本語訳として最も適切なのはどれですか？', 'However, if JSX.IntrinsicElements is present, then the name of the intrinsic element is looked up as a property on the JSX.IntrinsicElements interface.', '["intrinsic element の名前は、JSX.IntrinsicElements を置き換えるプロパティになる。", "intrinsic element の名前は、JSX.IntrinsicElements インターフェース上のプロパティとして参照される。", "intrinsic element の名前は、プロパティではなく型引数として扱われる。", "intrinsic element の名前は、JSX.IntrinsicElements とは無関係に評価される。"]'::jsonb, 1, '`as a property on ... interface` は『そのインターフェース上のプロパティとして』という意味です。', 'TypeScript JSX Intrinsic Elements'),
  (118, 'セクション49: TypeScript JSX 読解', '本文内容との一致', '本文の内容に合うものを次から1つ選びなさい。', 'By default, if this interface is not specified, then anything goes and intrinsic elements will not be type checked. However, if JSX.IntrinsicElements is present, then the name of the intrinsic element is looked up as a property on the JSX.IntrinsicElements interface.', '["JSX.IntrinsicElements がなくても常に厳密な型チェックが行われる。", "JSX.IntrinsicElements が存在すると、要素名はそのインターフェースのプロパティとして調べられる。", "Intrinsic elements は JSX.IntrinsicElements とは無関係である。", "JSX.IntrinsicElements があると型チェックは無効になる。"]'::jsonb, 1, '本文後半がそのまま根拠です。JSX.IntrinsicElements がある場合は、要素名をそのプロパティとして照合します。', 'TypeScript JSX Intrinsic Elements'),
  (119, 'セクション49: TypeScript JSX 読解', '英文全体の要約', 'この英文全体の内容を1文で要約したものとして最も適切なのはどれですか？', 'By default, if this interface is not specified, then anything goes and intrinsic elements will not be type checked. However, if JSX.IntrinsicElements is present, then the name of the intrinsic element is looked up as a property on the JSX.IntrinsicElements interface.', '["JSX の intrinsic elements は常にランタイムでのみ処理され、型とは関係ない。", "JSX.IntrinsicElements の有無によって、intrinsic elements の型チェック方法が変わる。", "JSX.IntrinsicElements は React 専用であり、TypeScript では使用されない。", "intrinsic elements は必ずクラスコンポーネントとして解釈される。"]'::jsonb, 1, '前半は『未指定なら型チェックしない』、後半は『存在すればそのプロパティとして照合する』であり、要約すると型チェック方法が変わるという内容です。', 'TypeScript JSX Intrinsic Elements'),
  (120, 'セクション49: TypeScript JSX 読解', 'TOEIC風: By default most nearly mean', 'What does the phrase `By default` most nearly mean in this passage?', 'By default, if this interface is not specified, then anything goes and intrinsic elements will not be type checked.', '["In advance", "Normally", "By mistake", "In detail"]'::jsonb, 1, '`By default` means `normally` or `in the standard case` in this passage.', 'TypeScript JSX Intrinsic Elements'),
  (121, 'セクション49: TypeScript JSX 読解', 'TOEIC風: interface is not specified', 'What happens if the interface is not specified?', 'By default, if this interface is not specified, then anything goes and intrinsic elements will not be type checked.', '["Intrinsic elements are deleted automatically.", "Intrinsic elements are converted into properties.", "Intrinsic elements are not type checked.", "Intrinsic elements become invalid syntax."]'::jsonb, 2, 'The passage explicitly says `intrinsic elements will not be type checked.`', 'TypeScript JSX Intrinsic Elements'),
  (122, 'セクション49: TypeScript JSX 読解', 'TOEIC風: However の役割', 'What is the role of `However` in the passage?', 'However, if JSX.IntrinsicElements is present, then the name of the intrinsic element is looked up as a property on the JSX.IntrinsicElements interface.', '["It introduces a similar example.", "It adds technical detail.", "It shows a contrast.", "It repeats the previous idea."]'::jsonb, 2, '`However` marks a contrast between the case where the interface is absent and the case where it is present.', 'TypeScript JSX Intrinsic Elements'),
  (123, 'セクション49: TypeScript JSX 読解', 'TOEIC風: interface が存在する場合', 'According to the passage, what happens when `JSX.IntrinsicElements` is present?', 'However, if JSX.IntrinsicElements is present, then the name of the intrinsic element is looked up as a property on the JSX.IntrinsicElements interface.', '["The intrinsic element name is checked as a property of the interface.", "All intrinsic elements are ignored by the compiler.", "The interface is removed from the program.", "JSX syntax is disabled."]'::jsonb, 0, 'The passage states that the intrinsic element name is looked up as a property on the interface.', 'TypeScript JSX Intrinsic Elements'),
  (124, 'セクション49: TypeScript JSX 読解', 'TOEIC風: 最も正確な要約', 'Which of the following is most accurate according to the passage?', 'By default, if this interface is not specified, then anything goes and intrinsic elements will not be type checked. However, if JSX.IntrinsicElements is present, then the name of the intrinsic element is looked up as a property on the JSX.IntrinsicElements interface.', '["Type checking always happens, whether the interface exists or not.", "The interface is only used for runtime execution.", "The presence of the interface affects how intrinsic elements are checked.", "Intrinsic elements cannot be used with interfaces."]'::jsonb, 2, 'This is the best summary of the passage: whether the interface exists changes how TypeScript checks intrinsic elements.', 'TypeScript JSX Intrinsic Elements'),
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
const newBadgeTextColor = Color(0xFF1A1A1A);', '["_currentPage が 1 以外でも、displayDate が now より後なら true", "_currentPage が 1 で、displayDate が newCutoff から now の範囲内なら true", "displayDate が newCutoff より前でも _readIds に含まれなければ true", "_readIds に含まれていても newBadgeColor が黄色なら true"]'::jsonb, 1, '`isNew` は `_currentPage == 1` かつ `isDateInNewRange` のAND条件です。`isDateInNewRange` は `displayDate` が `newCutoff` 以上 `now` 以下のとき true になります。', 'User provided Flutter snippet'),
  (126, 'セクション51: TypeScript Property Key', 'Quoted Property Key と keyof', '次の型定義において `type K = keyof Settings;` の結果として最も正しいものはどれですか？', 'type Settings = {
  "api-key": string;
  retryCount: number;
};

type K = keyof Settings;', '["`string`", "`\"api-key\" | \"retryCount\"`", "`\"api-key\" & \"retryCount\"`", "`number`"]'::jsonb, 1, 'quoted property key で定義した `"api-key"` も通常のプロパティキーとして扱われるため、`keyof Settings` は `"api-key" | "retryCount"` になります。なお値としてアクセスする際は `settings["api-key"]` のようにブラケット記法を使うのが基本です。', 'TypeScript keyof / quoted property names'),
  (127, 'セクション52: Claude Code アップデート案内', 'Claude Code のバージョン更新', '次のメッセージが表示されたとき、最も適切な対応はどれですか？', 'It looks like your version of Claude Code (1.0.37) needs an update.
A newer version (1.0.88 or higher) is required to continue.

To update, please run:
    claude update', '["`claude update` を実行して必要なバージョンへ更新する", "`git pull` を実行すれば Claude Code も更新される", "そのまま `claude code` を再実行すれば自動で続行できる", "`npm install` を実行すれば必ず解決する"]'::jsonb, 0, 'このメッセージは、現在の Claude Code が `1.0.37` で、継続には `1.0.88` 以上が必要だと明示しています。したがって案内どおり `claude update` を実行して CLI 自体を更新するのが正しい対応です。', 'User provided Claude Code update message'),
  (128, 'セクション53: JavaScript 英語表現', '組み込みオブジェクトの英訳', '`組み込みオブジェクト` を英語で表すものとして最も適切なのはどれですか？', '// JavaScript で Array, Date, Math などを指す文脈', '["built-in object", "embedded property", "internal variable", "default instance"]'::jsonb, 0, '`組み込みオブジェクト` は英語で一般に `built-in object` と表現します。JavaScript では `Array` や `Date` など、言語や実行環境にあらかじめ備わっているオブジェクトを指す文脈で使われます。', 'General JavaScript terminology')
ON CONFLICT (id) DO NOTHING;

SELECT setval('quizzes_id_seq', (SELECT MAX(id) FROM quizzes));
