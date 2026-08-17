import type { Quiz } from '../types/quiz'

/**
 * Starter pack: バックエンドの公開 API が用意されるまでのフォールバックデータ。
 *
 * - すべて MDN Web Docs / React 公式 / TC39 / RFC など信頼できる一次情報からの引用に基づく
 * - `quiz.md` の方針に従い、IT 範囲で「コードの意味」「公式英文の和訳」を含む高難易度問題のみを採用する
 * - id は `packages/admin-web/src/data/quizzes.json`（437 問の候補プール）と衝突しない 9000 番台で割り当てる
 */
export const STARTER_QUIZZES: readonly Quiz[] = [
  {
    id: 9001,
    section: 'React Hooks',
    title: 'useState の更新関数の安定性',
    question: '`useState` から返される set 関数（dispatcher）について、React 公式が保証している性質はどれですか？',
    options: [
      '依存配列に入れていなくても、レンダリングごとに新しい関数参照になる',
      'コンポーネントの生存期間中、参照が安定（identity が変わらない）であり、依存配列に含める必要はない',
      'ステートが変わるたびに新しい参照に置き換わる',
      'StrictMode 下でのみ参照が安定する',
    ],
    correctAnswerIndex: 1,
    explanation:
      'React Reference では「React guarantees that setState function identity is stable and will not change on re-renders」と明記されており、`set` 関数を `useEffect` などの依存配列に含める必要はないとされている。',
    source: 'React Reference: useState (react.dev)',
    code: 'const [count, setCount] = useState(0)',
  },
  {
    id: 9002,
    section: 'React Hooks',
    title: 'リスト描画の key',
    question: 'React のリストレンダリングで `key` に配列インデックスを使うことの主な問題はどれですか？',
    options: [
      'インデックスは数値のため key として禁止されており、必ず実行時エラーになる',
      '要素の挿入・削除・並び替えで、内部 state や DOM が誤った要素に再関連付けされ、表示や入力値が崩れる',
      '配列インデックス key は SEO 上で禁止されており、Lighthouse のスコアが下がる',
      'インデックス key を使うと自動的に React.memo が無効化される',
    ],
    correctAnswerIndex: 1,
    explanation:
      'React 公式は「key を index に頼ると、項目の並びが変わったときに React がどの要素がどれか追跡できず、state や非制御入力が別の要素に紐づいてしまう」と説明している。安定で一意な ID を使う。',
    source: 'React: Rendering Lists (react.dev/learn/rendering-lists)',
  },
  {
    id: 9003,
    section: 'React Hooks',
    title: 'useEffect クリーンアップの実行タイミング',
    question: '`useEffect(setup, [deps])` のクリーンアップ関数が呼ばれるタイミングとして正しい組み合わせはどれですか？',
    options: [
      'コンポーネントのマウント直前と、props が変わる直前の 2 回だけ',
      '依存配列が変化して setup を再実行する直前と、コンポーネントのアンマウント時',
      'すべての再レンダリング後に必ず呼ばれる',
      'StrictMode の開発ビルドでのみ呼ばれ、本番ビルドでは呼ばれない',
    ],
    correctAnswerIndex: 1,
    explanation:
      'React 公式は「React will call your cleanup function each time before the Effect runs again, and one final time when the component unmounts」と定義している。',
    source: 'React Reference: useEffect (react.dev)',
  },
  {
    id: 9004,
    section: 'TypeScript',
    title: 'never 型の意味',
    question: 'TypeScript の `never` 型に当てはまる説明はどれですか？',
    options: [
      'すべての型のスーパータイプであり、任意の値を代入できる',
      '値を持たない型で、決して終了しない関数や常に throw する関数の戻り値型として使う',
      '`undefined` のエイリアスである',
      '`unknown` と等価で、型ガードを通せば任意の型として扱える',
    ],
    correctAnswerIndex: 1,
    explanation:
      'TypeScript Handbook では `never` を「the type of values that never occur」と定義している。`throw` のみ行う関数や無限ループする関数の戻り値、絞り込み（narrowing）で「ここには到達しない」ことを表す型として使う。',
    source: 'TypeScript Handbook: Functions / Narrowing',
  },
  {
    id: 9005,
    section: 'TypeScript',
    title: '型ガード関数の戻り値',
    question: '次のコードで `value is User` の戻り値型 注釈が果たす役割はどれですか？',
    code: 'function isUser(value: unknown): value is User {\n  return typeof value === "object" && value !== null && "id" in value\n}',
    options: [
      'ランタイムで `value` の型を強制的に `User` に変換する',
      'コンパイラに対して、戻り値が `true` のとき呼び出し元のスコープ内で `value` を `User` に絞り込んでよいと教える型述語である',
      '実行時に `instanceof User` と等価のチェックを自動生成する',
      '型としては効果がなく、JSDoc コメントと同じ扱いになる',
    ],
    correctAnswerIndex: 1,
    explanation:
      'TypeScript の "type predicates" は、関数が `true` を返した場合に引数の型を絞り込むためのコンパイラへのヒント。実行時の挙動は変えず、`if (isUser(x))` の中だけで `x` が `User` として扱える。',
    source: 'TypeScript Handbook: Narrowing / User-Defined Type Guards',
  },
  {
    id: 9006,
    section: 'JavaScript',
    title: 'コードの意味: Optional Chaining',
    question: '次の式の評価結果として正しいものはどれですか？',
    code: 'const user = { profile: null }\nconst city = user?.profile?.address?.city ?? "unknown"',
    options: [
      '`TypeError: Cannot read properties of null` が発生する',
      '`city` は `null` になる',
      '`city` は `"unknown"` になる',
      '`city` は `undefined` になる',
    ],
    correctAnswerIndex: 2,
    explanation:
      '`?.` は左辺が `null` または `undefined` のとき短絡して `undefined` を返す。`undefined` は `??` の左辺で nullish と判定されるため、右辺の `"unknown"` が採用される。',
    source: 'MDN: Optional chaining (?.) / Nullish coalescing operator (??)',
  },
  {
    id: 9007,
    section: 'JavaScript',
    title: 'コードの意味: Promise.allSettled',
    question: '次のコードを実行したとき `results` の値として正しいものはどれですか？',
    code: 'const results = await Promise.allSettled([\n  Promise.resolve(1),\n  Promise.reject(new Error("x")),\n  Promise.resolve(3),\n])',
    options: [
      '`[1, 3]`（reject されたものは除外される）',
      '例外が throw されて catch される',
      '`[{status:"fulfilled",value:1}, {status:"rejected",reason:Error}, {status:"fulfilled",value:3}]`',
      '`Promise.all` と同じく、最初の reject で全体が reject される',
    ],
    correctAnswerIndex: 2,
    explanation:
      '`Promise.allSettled` はすべての Promise が settle するまで待ち、各要素を `{status,value|reason}` の形にした配列を返す。reject されても全体は reject されない。',
    source: 'MDN: Promise.allSettled()',
  },
  {
    id: 9008,
    section: 'Web Standards (英文読解)',
    title: '公式英文の和訳: HTTP 401 vs 403',
    question:
      '次の HTTP 仕様の記述（RFC 9110, §15.5.2）の和訳として最も正確なものはどれですか？\n\n"The 401 (Unauthorized) status code indicates that the request has not been applied because it lacks valid authentication credentials for the target resource."',
    options: [
      '401 は、認証情報の有効期限が切れたためにリクエストが破棄されたことを示す。',
      '401 は、対象リソースに対する有効な認証情報を欠いているため、リクエストが適用されなかったことを示す。',
      '401 は、認証情報は正しいがリソースへのアクセス権がないことを示す。',
      '401 は、サーバー側の一時的な障害でリクエストを処理できないことを示す。',
    ],
    correctAnswerIndex: 1,
    explanation:
      '"lacks valid authentication credentials" = 「有効な認証情報を欠いている」。401 は認証失敗（未認証）を表し、権限不足は 403 Forbidden で表す（同 §15.5.4）。',
    source: 'RFC 9110: HTTP Semantics §15.5.2 (401 Unauthorized)',
  },
  {
    id: 9009,
    section: 'Web Standards (英文読解)',
    title: '公式英文の和訳: useEffect の strict-mode の挙動',
    question:
      'React 公式の次の記述の和訳として最も正確なものはどれですか？\n\n"In development with Strict Mode, React will call setup and cleanup one extra time before the actual setup. This is a stress-test that verifies your Effect\'s logic is implemented correctly."',
    options: [
      '本番ビルドでは setup と cleanup が 2 回ずつ実行され、開発時のみ 1 回になる。',
      '開発モードの Strict Mode では、本来の setup の前に setup と cleanup を 1 回多く呼ぶ。これは Effect のロジックが正しく実装されているかを検証するストレステストである。',
      'Strict Mode を有効にすると本番でも setup と cleanup が二重に実行されるため、副作用は冪等にする必要がある。',
      'Strict Mode は cleanup のみを 2 回呼び、setup は 1 回しか呼ばれない。',
    ],
    correctAnswerIndex: 1,
    explanation:
      '"in development with Strict Mode" = 「開発モードかつ Strict Mode のとき」。"one extra time before the actual setup" = 「実際の setup の前に 1 回多く」。Effect が再マウントに耐える実装になっているかを開発時に検出させる目的で挿入されている。',
    source: 'React Reference: useEffect — "How to handle the Effect firing twice in development?" (react.dev)',
  },
  {
    id: 9010,
    section: 'Browser Internals',
    title: 'ブラウザのレンダリングパイプライン',
    question:
      'CSS の `transform: translate3d(...)` を使ったアニメーションが、`top` / `left` のアニメーションよりも一般的に高速なのはなぜですか？',
    options: [
      '`top` / `left` は GPU でのみ計算され、CPU を使わないため',
      '`transform` は Layout と Paint をスキップでき、Composite フェーズだけで処理できる場合があるため',
      '`transform` は内部的に `requestAnimationFrame` を強制し、フレームレートを 120fps に固定するため',
      '`top` / `left` は CSS Transitions で禁止されている',
    ],
    correctAnswerIndex: 1,
    explanation:
      '`top`/`left` の変更は要素のジオメトリを変えるため Layout（リフロー）と Paint が発生しやすい。一方 `transform` はレイヤーを Composite するだけで済む構造になっており、Layout と Paint をスキップできるケースが多いため安価。',
    source: 'web.dev: Stick to compositor-only properties and manage layer count',
  },
] as const
