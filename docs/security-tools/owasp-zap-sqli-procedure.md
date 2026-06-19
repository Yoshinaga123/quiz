# OWASP ZAP — SQL インジェクション 検出手順

## 対象脆弱性

**SQL インジェクション (SQLi)** — OWASP Top 10: A03 Injection

ユーザ入力がサニタイズされずに SQL クエリへ直接埋め込まれることで、攻撃者がデータベースを不正に操作できる脆弱性。

---

## 検証対象の想定環境

```
Go バックエンド (Gin フレームワーク)
エンドポイント: POST /api/login
                GET  /api/users?id=1

脆弱なコード例 (Go):
query := "SELECT * FROM users WHERE id = " + userInput   // ← 危険
db.QueryRow(query)
```

---

## 事前準備

### 1. ZAP の起動

```bash
# Docker でバックグラウンド常駐モード (デーモンモード) 起動
docker run -u zap -d \
  -p 8080:8080 \
  --name zap \
  ghcr.io/zaproxy/zaproxy:stable \
  zap.sh -daemon \
  -host 0.0.0.0 \
  -port 8080 \
  -config api.addrs.addr.name=.* \
  -config api.addrs.addr.regex=true \
  -config api.key=zapkey123
```

### 2. ブラウザのプロキシ設定

```
HTTP プロキシ: 127.0.0.1
ポート: 8080
```

### 3. CA 証明書のインポート

```
ブラウザで http://zap にアクセス → CA Certificate をダウンロード
Firefox: 設定 → 証明書を表示 → インポート
```

---

## 手順 1: 対象サイトのクロール

### GUI の場合

```
1. ZAP を起動
2. 「自動スキャン」ボタンをクリック
3. ターゲット URL: http://localhost:8080 を入力
4. 「Spider」を実行してエンドポイントを探索
```

### CLI (API) の場合

```bash
# Spider スキャン開始
curl "http://localhost:8080/JSON/spider/action/scan/?url=http://target:8080&apikey=zapkey123"

# スキャン完了まで待機 (status が 100 になるまで)
watch -n 2 'curl -s "http://localhost:8080/JSON/spider/view/status/?scanId=0&apikey=zapkey123"'
```

---

## 手順 2: SQL インジェクションの自動スキャン

### GUI の場合

```
1. Sites ツリーで対象 URL を右クリック
2. 「Attack」→「Active Scan」を選択
3. 「Policy」タブ → カテゴリ「Injection」のみ有効化
4. 「Start Scan」をクリック
```

### CLI (API) の場合

```bash
# アクティブスキャン開始
curl "http://localhost:8080/JSON/ascan/action/scan/?url=http://target:8080&apikey=zapkey123"

# スキャン進捗確認
curl "http://localhost:8080/JSON/ascan/view/status/?scanId=0&apikey=zapkey123"

# スキャン完了後: アラート確認
curl "http://localhost:8080/JSON/alert/view/alerts/?riskId=3&apikey=zapkey123" | python3 -m json.tool
```

---

## 手順 3: 検出結果の確認

### GUI での確認

```
下部パネル「Alerts」タブ → リスクレベル「High」をフィルタ
→ 「SQL Injection」アラートをクリック

表示される情報:
  - 脆弱なURL
  - 注入されたパラメータ名
  - 使用されたペイロード
  - サーバのレスポンス
  - 証拠 (Evidence)
```

### 検出時のアラート例

```json
{
  "alert": "SQL Injection",
  "risk": "High",
  "url": "http://target:8080/api/users?id=1",
  "param": "id",
  "attack": "1 AND 1=1 --",
  "evidence": "SELECT * FROM users",
  "solution": "Use parameterized queries..."
}
```

---

## 手順 4: 手動検証 (ZAP の手動リクエスト送信)

自動スキャンで検出されたら、手動で確認して確証を得る。

### 正常リクエスト

```
ZAP → Requester タブ (または右クリック → Open/Resend with Request Editor)

GET /api/users?id=1 HTTP/1.1
Host: target:8080
```

レスポンス:
```json
{"id": 1, "name": "Alice", "email": "alice@example.com"}
```

### 真偽テスト 1: 常に真の条件

```
GET /api/users?id=1 AND 1=1-- HTTP/1.1
Host: target:8080
```

期待: 正常なレスポンスが返る (脆弱性あり)

### 真偽テスト 2: 常に偽の条件

```
GET /api/users?id=1 AND 1=2-- HTTP/1.1
Host: target:8080
```

期待: 空のレスポンスまたは 404 が返る (脆弱性あり)

### エラーベース確認

```
GET /api/users?id=1' HTTP/1.1
Host: target:8080
```

期待: SQL エラーメッセージが含まれるレスポンス

```
# Go + PostgreSQL の場合のエラー例
pq: unterminated quoted string at or near "'"
```

---

## 手順 5: ブラインド SQL インジェクションの確認

エラーが表示されない場合でも、時間ベースで確認できる。

### 時間ベース (Time-Based Blind SQLi)

```
# PostgreSQL の場合
GET /api/users?id=1;SELECT pg_sleep(5)-- HTTP/1.1

# MySQL の場合
GET /api/users?id=1 AND SLEEP(5)-- HTTP/1.1
```

レスポンスが 5 秒以上遅延すれば SQLi が存在する。

ZAP の自動スキャンは時間ベースの SQLi も検出ポリシーに含まれている:
```
Active Scan Policy → Injection → SQL Injection - Time Based
→ Threshold: Medium / Strength: High に設定
```

---

## 手順 6: レポート出力

### GUI

```
レポート → レポートの生成
→ テンプレート: "Traditional HTML Report"
→ 出力パス指定 → 生成
```

### CLI

```bash
# HTML レポート
curl "http://localhost:8080/OTHER/core/other/htmlreport/?apikey=zapkey123" \
  -o sqli_report.html

# JSON レポート (CI/CD 向け)
curl "http://localhost:8080/OTHER/core/other/jsonreport/?apikey=zapkey123" \
  -o sqli_report.json
```

---

## 手順 7: CI/CD パイプラインでの自動検出 (GitHub Actions)

```yaml
name: SQLi Scan

on: [push]

jobs:
  sqli-scan:
    runs-on: ubuntu-latest
    services:
      go-api:
        image: your-go-api:latest
        ports:
          - 8080:8080

    steps:
      - name: ZAP API Scan
        uses: zaproxy/action-api-scan@v0.7.0
        with:
          target: 'http://localhost:8080/openapi.json'
          format: openapi
          cmd_options: '-z "-config scanner.strength=HIGH"'

      - name: Upload Report
        uses: actions/upload-artifact@v4
        with:
          name: zap-report
          path: report_html.html
```

---

## 修正方法 (Go コード)

### 脆弱なコード

```go
// NG: 文字列結合によるクエリ構築
query := "SELECT * FROM users WHERE id = " + userInput
row := db.QueryRow(query)
```

### 修正後のコード

```go
// OK: プレースホルダを使ったパラメータ化クエリ (変数を安全に渡す仕組み)
row := db.QueryRow("SELECT * FROM users WHERE id = $1", userID)

// ORM を使う場合 (GORM)
db.Where("id = ?", userID).First(&user)
```

---

## ZAP による SQLi 検出の限界

| 限界 | 内容 |
|------|------|
| 帯域外 (OOB) SQLi | DNS コールバック不要の OOB SQLi は検出が難しい |
| 複雑な認証フロー | JWT が期限切れになると以降の検査が不完全になる |
| ストアドプロシージャ内の SQLi | 実行結果に差異が出ない場合は検出困難 |
| 二次 SQLi | 入力が一度 DB に保存されてから実行される SQLi は Spider だけでは追いにくい |
