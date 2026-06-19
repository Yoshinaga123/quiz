# OWASP ZAP — 認証付きスキャン

ログインが必要なページをスキャンするための設定手順。
認証なしでスキャンすると、ログイン後のエンドポイント（API のほとんど）が検査対象から外れてしまう。

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

## 方法 1: リクエストヘッダに JWT を直接設定する（最もシンプル）

ログイン API を手動で叩いてトークンを取得し、ZAP に渡す方法。
設定が簡単で、スクリプトが不要。

### 手順

```bash
# ① ログインしてトークンを取得
TOKEN=$(curl -s -X POST http://localhost:8080/api/login \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","password":"testpass"}' \
  | jq -r '.token')

echo "TOKEN: $TOKEN"

# ② ZAP のデフォルトリクエストヘッダに JWT を設定
curl "http://localhost:8080/JSON/replacer/action/addRule/" \
  --data-urlencode "description=JWT Auth" \
  --data-urlencode "enabled=true" \
  --data-urlencode "matchType=REQ_HEADER" \
  --data-urlencode "matchString=Authorization" \
  --data-urlencode "replacement=Bearer $TOKEN" \
  --data-urlencode "apikey=zapkey123"

# ③ スパイダースキャン
curl "http://localhost:8080/JSON/spider/action/scan/?url=http://target:8080&apikey=zapkey123"

# ④ アクティブスキャン（実際に攻撃データを送って検査する）
curl "http://localhost:8080/JSON/ascan/action/scan/?url=http://target:8080&apikey=zapkey123"
```

> **注意**: JWT には有効期限がある。長時間スキャンの場合は方法 2（スクリプト）を使うこと。

---

## 方法 2: ZAP 認証スクリプト（トークン自動更新）

スキャン中に JWT が切れても自動再ログインする方法。

### GUI での設定手順

```
1. ZAP → "Sites" タブで対象サイトを右クリック
   → "Flag as Context" → "Default Context"

2. Context の設定画面を開く
   左メニュー: Default Context → Authentication → "Script-based Authentication" を選択

3. 認証スクリプトを作成（JavaScript）:
   Scripts タブ → Authentication → New Script

4. スクリプトの内容は下記参照

5. Logged In / Logged Out の判定パターンを設定:
   - Logged In Indicator:  "username"  (レスポンスに含まれる文字列)
   - Logged Out Indicator: "Unauthorized" または "401"

6. "Users" タブでテストユーザを登録:
   Username: testuser
   Password: testpass

7. Spider / Active Scan 実行時に "Context" と "User" を選択して実行
```

### 認証スクリプト (JavaScript — ZAP スクリプトエンジン用)

```javascript
// Authentication Script: JWT ログイン
function authenticate(helper, paramsValues, credentials) {
    var loginUrl = "http://localhost:8080/api/login";
    var body = JSON.stringify({
        username: credentials.getParam("Username"),
        password: credentials.getParam("Password")
    });

    var msg = helper.prepareMessage();
    msg.setRequestHeader(
        msg.getRequestHeader().toString().replace(
            "GET " + loginUrl,
            "POST " + loginUrl
        )
    );
    var requestBody = new org.apache.commons.httpclient.methods.StringRequestEntity(
        body, "application/json", "UTF-8"
    );

    // POST リクエストを送信
    var response = helper.sendAndReceive(msg, false);

    // レスポンスから JWT を取り出す
    var responseBody = msg.getResponseBody().toString();
    var tokenMatch = responseBody.match(/"token"\s*:\s*"([^"]+)"/);
    if (tokenMatch) {
        var token = tokenMatch[1];
        // 以降のリクエスト全てにヘッダを付ける
        helper.getHttpSender().addCustomHeader("Authorization", "Bearer " + token);
    }

    return msg;
}

function getRequiredParamsNames() { return []; }
function getOptionalParamsNames() { return []; }
function getCredentialsParamsNames() { return ["Username", "Password"]; }
```

---

## 方法 3: API スキャン + セキュリティスキーム (OpenAPI 定義を使う方法)

Go の Gin サーバが OpenAPI (Swagger) 定義を公開している場合、最も精度が高い。

### OpenAPI 定義に認証スキーム情報を含める

```yaml
# openapi.yaml の一部
components:
  securitySchemes:
    BearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT

security:
  - BearerAuth: []

paths:
  /api/users:
    get:
      security:
        - BearerAuth: []
```

### ZAP API スキャンに JWT を渡す

```bash
# トークンを取得
TOKEN=$(curl -s -X POST http://localhost:8080/api/login \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","password":"testpass"}' \
  | jq -r '.token')

# OpenAPI スキャン時にヘッダを指定
docker run --rm \
  -v $(pwd)/reports:/zap/wrk \
  ghcr.io/zaproxy/zaproxy:stable \
  zap-api-scan.py \
  -t http://host.docker.internal:8080/openapi.json \
  -f openapi \
  -r /zap/wrk/report.html \
  -z "-config replacer.full_list(0).description=JWT \
      -config replacer.full_list(0).enabled=true \
      -config replacer.full_list(0).matchtype=REQ_HEADER \
      -config replacer.full_list(0).matchstr=Authorization \
      -config replacer.full_list(0).replacement=Bearer\ $TOKEN"
```

---

## JWT 有効期限の対処

JWT の有効期限が短い場合（例: 15 分）、長時間スキャンの途中でトークンが無効になる。

### 対処方法

```bash
# ① テスト用に有効期限を長く設定する（スキャン時のみ）

# Go コード例: テスト環境では期限を 24 時間に設定
if os.Getenv("ENV") == "test" {
    expiry = 24 * time.Hour
} else {
    expiry = 15 * time.Minute
}

# ② スキャン前にトークンを取得して環境変数に保存
export ZAP_TOKEN=$(curl -s -X POST http://localhost:8080/api/login \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","password":"testpass"}' \
  | jq -r '.token')
```

---

## React SPA のスキャン（認証後のページ）

React Router を使った SPA はページ遷移が JavaScript で行われるため、通常の Spider では認証後のページに到達できない。

### Ajax Spider を使う

```bash
# ① ブラウザで手動ログインした後、ZAP の Ajax Spider を使う
# GUI: Spider → Ajax Spider → Launch Browser を選択
# ブラウザが自動で開く → ログインして対象ページに移動 → Spider が自動でクロール開始

# API での Ajax Spider 起動
curl "http://localhost:8080/JSON/ajaxSpider/action/scan/?url=http://target:8080&apikey=zapkey123"

# スキャン完了確認
curl "http://localhost:8080/JSON/ajaxSpider/view/status/?apikey=zapkey123"
# → "stopped" になるまで待つ
```

---

## テストユーザの準備

スキャンには**実際に操作できるテスト用アカウント**が必要。

```
推奨するテストユーザ構成:

| ユーザ | 役割 | 目的 |
|--------|------|------|
| testuser_admin | 管理者権限 | 全エンドポイントへのアクセス確認 |
| testuser_normal | 一般ユーザ権限 | 権限昇格テスト（IDOR など） |

注意: 本番環境のユーザは絶対に使わない
本番環境では絶対にスキャンしない (管理者の明示的な許可がある場合を除く)
```

---

## 認証付きスキャンの確認方法

スキャンが正しく認証できているか確認する。

```
ZAP GUI での確認:
1. "Sites" ツリーに /api/users, /api/quiz などのパスが表示されているか確認
   → 表示されていればログイン後のページにアクセスできている

2. "Alerts" タブで "Authentication Failure" が大量に出ていないか確認
   → 大量に出ている場合は認証設定が正しくない

3. HTTP History で Authorization ヘッダが付いているか確認
   → Filter: "Authorization" で絞り込む
```

---

## よくある失敗と対処

| 失敗 | 原因 | 対処 |
|------|------|------|
| `/api/users` が Sites ツリーに現れない | 認証できていない / Spider が届いていない | JWT 設定を確認、Ajax Spider を使う |
| 全リクエストが 401 | Bearer トークンの形式が間違い | `Authorization: Bearer <token>` の形式を確認 |
| スキャン途中で 401 が増える | JWT の有効期限切れ | テスト環境で期限を延ばすか認証スクリプトを使う |
| React のページが検出されない | SPA のルーティングが Spider に届かない | Ajax Spider に切り替える |
