### クイズアプリ開発要件定義
    実行コマンドは以下の通りです。
    前提条件としてはNode.jsがインストールされている必要があります。
    ```bash
    npm create vite@latest vite-app-quiz
    ```
    プロジェクトのテンプレートはreactを選択してください。
    本プロジェクトは、ユーザー向けのクイズアプリをモバイル版（Flutter）とWeb版（React/Vite）の2つで提供し、別途クイズ管理用のWeb画面（React/Vite）とバックエンドAPI（Go）で構成されます。

### 要件定義
- クイズアプリは高難易度のクイズアプリです。
- コードの意味を問うクイズを作成してください。
- 公式ドキュメントの英文から、正しい日本語訳を選択する問題も作成してください。
- クイズは複数選択式で、正解は1つだけです。
- ITに関する範囲であればなんでも構いません。
- 出題形式も自由です。
- 答えは高品質なドキュメントから引用してください。
- 下記のクイズは簡単すぎますが、単なる一例です。実際のクイズはもっと難易度が高いものを作成してください。
- push通知でログイン状態に応じて、ログインを促す通知を送る機能も追加してください。
- モバイルはandroidとiOS両方に対応してください。
- クイズはモバイルアプリ版とWeb版の両方を提供してください。
- クイズの管理は管理画面で行います。管理画面ではクイズの追加、編集、削除ができるようにしてください。
- 管理画面はWebで実装してください。

### クイズ例
1. 以下のコードは何を意味していますか？
```const [count, setCount] = useState(0);
```

2. 以下の英文の意味は何ですか？
```The useState hook is a function that allows you to add state to functional components in React.```


###　画面設計

- クイズの問題と選択肢を表示する画面
 - IT系の英文読解
 - コードの意味を問うクイズ
- クイズの結果を表示する画面
 - さらに詳細な英文例
 - さらに丁寧なコード解説
- クイズの履歴を表示する画面
 - 過去に解いたクイズの一覧
 - 正解率や傾向を分析する機能

### 開発規約
- コードはESLintのルールに従って書いてください。
- コードはPrettierでフォーマットしてください。
- コンポーネントは機能ごとに分割してください。
- AIによるコード生成は許可しますが、開発者が必ず理解することが前提です。
- クイズの内容は必ず高品質なドキュメントから引用してください。
- クイズの内容は必ず正確であることを確認してください。
- クイズの内容は必ず最新の情報を反映してください。

### 追加要件
- 現時点ではなし。


### 全体構成
- モバイル向けクイズアプリ + Web向けクイズアプリ + 管理web + Go製API + PostgreSQL + Docker
・モバイル向けクイズアプリ: Flutter / Dart
・Web向けクイズアプリ: React / TypeScript / Vite
・管理web: React / TypeScript / Vite


### 詳細な技術スタック
- Web向けクイズアプリ: React 18 + TypeScript 5
- 管理画面: React 18 + TypeScript 5
- モバイルアプリ: Flutter / Dart / shared_preferences / intl / firebase_messaging / flutter_local_notifications / http / barcode_widget / app_links
- 状態管理: ReactのuseStateフック
- スタイリング: Tailwind CSS
- ビルドツール: Vite
- コード品質: ESLint, Prettier
- バージョン管理: Git
- ルーティング: react-router-dom
- バックエンド: Go Echo
- データベース: PostgreSQL
- API通信: EchoのHTTPクライアント
- push通知: Firebase Cloud Messaging (FCM), Apple Push Notification service (APNs)
- 認証: JWT (JSON Web Tokens)
- コンテナ化: Docker
- バリデーション: zod
- 品質・開発補助: ESLint, Prettier, Vitest, Testing Library, jsdom, Storybook, lint-staged, Husky
- schema/Docs OpenAPI, Redocly

### まとめ
このクイズアプリは、ITに関する高難易度のクイズを提供することを目的としています。ユーザーはコードの意味や公式ドキュメントの英文の意味を問うクイズに挑戦することができます。クイズの内容は高品質なドキュメントから引用され、正確で最新の情報を反映しています。開発者はESLintとPrettierを使用してコードの品質を保ち、機能ごとにコンポーネントを分割して開発を進めてください。