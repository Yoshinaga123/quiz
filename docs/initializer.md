# 初期化ポリシー

## 目的

本ドキュメントは、このプロジェクトにおける初期化の責務、順序、失敗時の扱いを揃えるための方針を定める。
対象は `admin-web`、`backend`、`mobile` である。

初期化で事故が起きやすいポイントは次の通り。

- 起動順序が暗黙になり、依存関係が崩れる
- `late` やグローバル変数が未初期化のまま参照される
- constructor や widget build に重い処理や I/O を混ぜる
- テスト時だけ別経路の初期化が必要になり、差し替え不能になる

## 基本原則

- 初期化は「いつ・どこで・何を」行うかを明示する
- オブジェクトは生成直後に妥当な状態であるか、未完成であることを API 上明示する
- constructor には重い処理や非同期 I/O を押し込まない
- 非同期初期化は `init()`、factory、loader、provider など明示的な境界で行う
- 初期化失敗は握りつぶさず、起動失敗・再試行・フォールバックのどれかに寄せる
- `late` は「代入前に読まれないことを保証できる場合」に限定する
- グローバル状態や singleton の初期化箇所は 1 か所に固定する
- テストで差し替える依存は、初期化コードの内部で直接 new しすぎない

## 用語

### 初期化

利用可能な状態にするための準備。

例:

- 設定値の読み込み
- 認証状態の復元
- API クライアントの生成
- DB 接続
- provider / context / router の組み立て

### 遅延初期化

宣言時ではなく、必要になった時点または後続処理で値を入れること。

例:

- Dart の `late`
- React のイベント発火後取得
- Go の lazy singleton

## 禁止・非推奨

### 禁止

- constructor 内で外部 API、DB、永続ストレージへの重い I/O を始める
- build/render のたびに初期化処理を走らせる
- 初期化失敗を黙って無視する
- 未初期化アクセスの可能性がある `late` を安易に使う
- 初期化順序が必要なのに、コメントや文書なしで暗黙依存にする

### 非推奨

- singleton を各所で勝手に初期化する
- `null`、空文字、ゼロ値で「未初期化」を曖昧に表現する
- テスト不能な初期化コードを書く
- 起動時に不要なものまで全部 eager に初期化する

## 設計ルール

### 1. 初期化責務を分離する

初期化は少なくとも次の責務に分けて考える。

- 設定読み込み
- 依存解決
- セッション復元
- 初期データ取得
- 画面成立に必要な前提確認

1つの関数で全部やらない。

### 2. 非同期初期化を明示する

同期 constructor だけでは完結しないものは、呼び出し側から見て分かる API にする。

例:

- `Future<void> init()`
- `Future<AppConfig> loadConfig()`
- `Future<SharedPreferences> getInstance()`
- ルート loader
- Riverpod の `FutureProvider`

### 3. 初期化済みと未初期化を区別する

状態を曖昧にしない。

- `late` を使うなら、必ず代入される経路を 1 つ以上確認する
- 必要なら `isInitialized` 相当の状態を持つ
- `required / optional / nullable` を混同しない

### 4. 初期化失敗時の方針を先に決める

失敗時は次のどれかに分類する。

- 起動不能として止める
- UI で再試行させる
- 安全な既定値でフォールバックする

何もしない、は選ばない。

### 5. 初期化順序を固定する

依存関係がある場合は順序を文書化する。

例:

1. 環境変数・設定を読む
2. ロガーやクライアントを組み立てる
3. 認証状態を復元する
4. 画面成立に必要な初期データを取得する
5. UI を公開する

## 技術別ガイド

### `admin-web`

- `main.tsx` / `App.tsx` では、router、provider、auth context の組み立てに集中する
- 画面成立に必須な初期データは route loader か画面遷移前提で取得する
- 補助データは画面描画後に取得してよい
- `useEffect` は「初期化境界」と「再実行条件」を明示して使う
- モジュールトップレベルで重い副作用を起こさない

補足:

- 認証復元、flash provider、router 構築の順序は `App` 周辺で追える状態に保つ
- 一覧画面の検索条件は URL から復元し、URL を初期状態の信頼源とする

### `backend`

- `main` では起動に必須な初期化だけを順に行う
- 例:
  - 環境変数確認
  - DB 接続
  - migration
  - HTTP server 起動
- 起動不能な初期化失敗は即終了し、中途半端にサーバーを立ち上げない
- リクエストごとの処理で一度だけ必要な初期化を毎回繰り返さない
- package init に重要な副作用を持たせない

補足:

- 現在の `backend`（`main.go` + `db.go`）では DB と migration の初期化順が重要なので、依存順を崩さない
- 初期化エラーは利用者向けではなく運用ログ向けに明確に出す

### `mobile`

- `main.dart` では app 起動に必要な最小構成だけを行う
- 永続設定、認証復元、初回データ取得は provider / repository / service の責務に寄せる
- `late` を使う場合、`initState` や provider 初期化で必ず代入されることを確認する
- Widget constructor で非同期 I/O を始めない
- 端末ストレージや `SharedPreferences` 取得は明示的な非同期初期化として扱う

補足:

- `late SharedPreferences sharedPref;` のような宣言は、代入前に参照されない保証がある時だけ使う
- 不安があるなら `FutureProvider`、nullable、wrapper service を優先する
- constructor の initializer list では `this` や instance member を参照しない
- `An instance variable initializer can't access this` は、linter ではなく Dart analyzer の診断として扱われる

## `late` の扱い

`late` は便利だが、初期化順序の問題を隠しやすい。

許容するケース:

- framework lifecycle 上、代入が必ず先に走る
- テストでも同じ順序を保証できる
- nullable にしたくない明確な理由がある

避けるケース:

- どこで代入されるか追いにくい
- 条件分岐次第で未代入経路がある
- 非同期初期化の完了前に UI から読まれる可能性がある

### Dart の initializer に関する注意

- constructor の initializer list では、まだ instance が完成していないため `this` を使えない
- そのため instance member を参照すると `implicit_this_reference_in_initializer` が発生する
- 一方で `late` な instance field の lazy initializer は、最初の読み出し時に評価されるため `this` 参照が許される場合がある
- ただし `late` で許されることと、初期化順序として安全かどうかは別問題として扱う

例:

```dart
class BadExample {
  final int base = 1;

  // NG: constructor initializer list では instance member を参照できない
  BadExample() : doubled = base * 2;

  final int doubled;
}

class LateExample {
  final int base = 1;

  // OK: late field の initializer は lazy に評価される
  late final int doubled = base * 2;
}
```

参照:

- Dart diagnostics: `implicit_this_reference_in_initializer`
- Dart constructors
- Dart null safety: `late`

## テスト方針

- 初期化失敗パターンをテストできる設計にする
- テストでは設定・クライアント・ストレージを差し替え可能にする
- 初期化順序に依存するコードは、順序を壊した時に失敗が見えるようにする

## チェックリスト

新しい初期化コードを追加する時は、次を確認する。

1. それは本当に起動時初期化が必要か
2. constructor ではなく明示的な初期化境界に置けているか
3. 同期 / 非同期が API 上明確か
4. 失敗時の扱いが決まっているか
5. 順序依存があるなら文書化されているか
6. `late` の未初期化アクセス経路がないか
7. テストで差し替え可能か

## 関連ドキュメント

- [実装ポリシー](./implement-policy.md)
- [バリデーションポリシー](./validation-policy.md)
- [ADR 0002: Frontend Architecture Selection (SPA)](./adr/0002-frontend-architecture-spa.md)
