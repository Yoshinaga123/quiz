# Burp Suite — 認証付きスキャン

ログインが必要なページをスキャンするための設定手順。
Burp Suite は手動テスト向けに設計されており、認証付きスキャンの柔軟性が最も高い。

---

## 対象スタック

```
Go バックエンド (Gin) — JWT Bearer トークン認証
React SPA (React Router) — ブラウザ上でトークンを保持
エンドポイント例:
  POST /api/login   → レスポンスに {"token": "eyJ..."} が返る
  GET  /api/users   → Authorization: Bearer eyJ... が必要
```

---

## 方法 1: Repeater に JWT を手動設定する（最もシンプル）

手動テストの基本。ログインしてトークンを取得し、Repeater に貼り付けて各エンドポイントを検査する。

### 手順

```
① Proxy タブ → ブラウザで POST /api/login を実行
   Burp が以下のレスポンスをキャプチャ:
   {"token":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."}

② トークンをコピー

③ Repeater タブ → GET /api/users のリクエストを貼り付け
   ヘッダに追加:
   Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

④ "Send" → 200 OK が返ればログイン成功、スキャン開始
```

### HTTP History から Repeater へ送る方法

```
Proxy → HTTP history →
  /api/users を右クリック → "Send to Repeater"
  Repeater タブで Authorization ヘッダを書き換えて再送
```

---

## 方法 2: Proxy の Match and Replace で全リクエストに JWT を付ける

全リクエストに自動的に Bearer トークンを付与する設定。
繰り返しテストするときに便利。

### 設定手順

```
Proxy → Options → Match and Replace → "Add" をクリック

設定内容:
  Type:    Request header
  Match:   ^Authorization:.*$    (正規表現)
  Replace: Authorization: Bearer eyJhbGciOi...
  Comment: JWT auth

→ "Enabled" にチェックして OK

以降、Proxy を通る全リクエストに Authorization ヘッダが付く
```

> トークンを更新するときは Replace の値を書き換えるだけ。

---

## 方法 3: Session Handling Rules（セッション管理ルール）でトークン自動更新

JWT の有効期限が切れたときに自動でログインし直す仕組み。
Professional 版で特に有効（Active Scanner との連携ができる）。

### 設定手順

```
① Macro Recorder でログインフローを記録する

   Project options → Sessions → Macros → "Add" をクリック
   → "Run macro recorder" をクリック
   → ブラウザで POST /api/login を実行してトークンを取得
   → Macro recorder を停止

② 記録した Macro を確認:
   POST /api/login
     Body: {"username":"testuser","password":"testpass"}
   Response: {"token":"eyJ..."}

③ Custom parameter location を設定:
   レスポンス内の token の値を "jwt_token" という変数に保存する設定

   Macro → Configure item → Custom parameter locations in response:
     Name:       jwt_token
     Location:   Body — JSON path: $.token

④ Session Handling Rules を追加:

   Project options → Sessions → Session Handling Rules → "Add"

   Rule description: JWT auto-login
   Rule actions:
     "Run a macro" → 作成した Macro を選択

   Rule scope:
     Tools: Scanner, Repeater, Intruder にチェック
     URL scope: http://localhost:8080/*

⑤ Authorization ヘッダの更新設定:
   Actions → "Set a specific header" → Authorization: Bearer {jwt_token}
```

---

## 方法 4: Burp Collaborator を使った認証後の OOB テスト（Professional のみ）

認証後のエンドポイントに対して、帯域外 (OOB — 外部サーバへのDNS/HTTP通信を使った検出) テストを行う。
Blind SSRF や OOB SQLi の検出に使う。

```
① Burp Collaborator client を開く
   Burp menu → Burp Collaborator client → "Copy to clipboard"
   → コールバック URL 例: abcde1234.burpcollaborator.net

② 認証済みの Repeater リクエストで Collaborator URL をペイロードに使う:
   GET /api/users?id=1 AND (SELECT 1 FROM (SELECT(SLEEP(5)))a)--

   または SSRF テスト:
   POST /api/fetch
   Authorization: Bearer eyJ...
   {"url": "http://abcde1234.burpcollaborator.net"}

③ Collaborator client で DNS/HTTP コールバックを確認
   → コールバックが届けば SSRF 確定
```

---

## React SPA のスキャン（認証後のページ）

React Router を使った SPA は URL のハッシュ (`#`) やクライアントサイドルーティングを使うため、
通常の Spider では認証後のページに到達できない場合がある。

### 手動でリクエストを収集する方法

```
① Burp のプロキシをブラウザに設定
② ブラウザで手動ログイン → アプリの全ページを操作
   (ユーザ一覧、クイズ一覧、プロフィール編集など)
③ Proxy → HTTP history に全リクエストが記録される
④ 記録されたリクエストを右クリック → "Send to Scanner" (Pro のみ)
   または "Send to Intruder" で手動テスト
```

### Target Scope の設定（スキャン対象を絞る）

```
Target → Site map → 対象ドメインを右クリック
→ "Add to scope"

Scope の設定:
  Include: http://localhost:8080/api/.*
  Exclude: http://localhost:8080/api/logout   ← ログアウトだけ除外
```

---

## JWT の改ざんテスト（JWT Editor BApp）

JWT 認証の実装ミスを検出する。無料の BApp で使用可能。

### 主なテストパターン

```
① alg: none 攻撃
   JWT Editor → アルゴリズムを "none" に変更 → 署名なしで送信
   → サーバが受け入れれば JWT 検証バグ

② 署名キーの誤設定 (RS256 → HS256)
   公開鍵を秘密鍵として悪用する攻撃パターン

③ ペイロードの改ざん
   {"role":"user"} → {"role":"admin"} に変更して送信
   → 権限昇格できれば認可不備
```

### 手順

```
Proxy → HTTP history → JWT を含むリクエストを右クリック
→ "Send to Repeater"
→ Repeater → Request タブ → "JSON Web Token" タブが表示される
→ Payload を直接編集 → "Sign" または "Attack" を選択
```

---

## テストユーザの準備

```
推奨するテストユーザ構成:

| ユーザ | 役割 | 目的 |
|--------|------|------|
| testuser_admin | 管理者権限 | 全エンドポイントへのアクセス確認 |
| testuser_normal | 一般ユーザ権限 | 権限昇格テスト (IDOR など) |

注意: 本番環境のユーザは絶対に使わない
本番環境では絶対にスキャンしない (管理者の明示的な許可がある場合を除く)
```

---

## Community 版 vs Professional 版 の認証テスト比較

| 機能 | Community | Professional |
|------|-----------|-------------|
| 手動 Repeater テスト | ◎ | ◎ |
| JWT Editor (BApp) | ◎ | ◎ |
| Match and Replace | ◎ | ◎ |
| Session Handling Rules | ◎ | ◎ |
| Macro Recorder | ◎ | ◎ |
| Active Scanner (自動スキャン) | × | ◎ |
| Scanner + Session Rule 連携 | × | ◎ |
| Burp Collaborator (OOB) | × | ◎ |

> Community 版でも手動テストは十分にできる。自動スキャンとの連携のみ Professional が必要。

---

## よくある失敗と対処

| 失敗 | 原因 | 対処 |
|------|------|------|
| Repeater が 401 を返す | Authorization ヘッダが付いていない | Match and Replace の設定を確認 |
| スキャン途中で 401 が増える | JWT 有効期限切れ | Session Handling Rules + Macro を設定 |
| React ページのリクエストが少ない | SPA のルーティングが記録されていない | ブラウザで手動操作して全ページを回る |
| JWT Editor タブが表示されない | BApp がインストールされていない | BApp Store → "JWT Editor" をインストール |
