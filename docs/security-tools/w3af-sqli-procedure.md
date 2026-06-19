# w3af — SQL インジェクション 検出手順

## 対象脆弱性

**SQL インジェクション (SQLi)** — OWASP Top 10: A03 Injection

ユーザ入力がサニタイズされずに SQL クエリへ直接埋め込まれることで、攻撃者がデータベースを不正に操作できる脆弱性。

---

## 検証対象の想定環境

```
Go バックエンド (Gin フレームワーク)
エンドポイント: GET  /api/users?id=1
                POST /api/login  (JSON ボディ)

脆弱なコード例 (Go):
query := "SELECT * FROM users WHERE id = " + userInput   // ← 危険
db.QueryRow(query)
```

> **注意**: w3af は JSON ボディへのインジェクション精度が低い。URL パラメータの SQLi 検出に集中する。

---

## 事前準備

### 1. w3af のインストール (Docker 推奨)

```bash
docker pull andresriancho/w3af
```

### 2. コンテナ起動

```bash
docker run -it \
  --network host \
  andresriancho/w3af \
  ./w3af_console
```

---

## 手順 1: 対象 URL とプラグインの設定

### コンソールでの設定

```
# w3af_console 起動後

# ターゲットを設定
w3af>>> target
w3af/config:target>>> set target http://localhost:8080/api/users?id=1
w3af/config:target>>> view

  target  | http://localhost:8080/api/users?id=1

w3af/config:target>>> back
```

### SQLi 関連プラグインのみ有効化

```
w3af>>> plugins

# audit プラグイン: SQLi のみ有効化
w3af/plugins>>> audit sqli blind_sqli

# crawl プラグイン: Spider でエンドポイントを探索
w3af/plugins>>> crawl web_spider

# grep プラグイン: エラーメッセージ・DBエラーを検出
w3af/plugins>>> grep error_pages

# output プラグイン: HTML レポートを出力
w3af/plugins>>> output console html_file
w3af/plugins>>> output config html_file
w3af/plugins/output/config:html_file>>> set output_file /tmp/sqli_report.html
w3af/plugins/output/config:html_file>>> back
w3af/plugins>>> back
```

### 有効化されたプラグインを確認

```
w3af>>> plugins
w3af/plugins>>> list audit

  Plugin      | Status  | Conf
  ------------|---------|------
  sqli        | Enabled | Yes
  blind_sqli  | Enabled | Yes
  (その他は Disabled)
```

---

## 手順 2: スキャンの実行

```
w3af>>> start
```

### スキャン中の出力例

```
[16:42:01] Starting w3af, version 1.7.6
[16:42:02] Web Spider is started.
[16:42:03] Found 3 URLs:
           - http://localhost:8080/api/users?id=1
           - http://localhost:8080/api/users?id=2
           - http://localhost:8080/api/login
[16:42:05] sqli plugin is testing: http://localhost:8080/api/users?id=1
[16:42:07] [High] SQL Injection was found at:
           URL: http://localhost:8080/api/users?id=1
           Variable: "id"
           Payload: "1' AND SLEEP(5)--"
```

---

## 手順 3: 検出結果の確認

### スキャン結果 (ナレッジベース) で確認

```
w3af>>> kb
w3af/kb>>> list

  Vulnerability         | Count
  ----------------------|------
  SQL Injection         | 2
  Blind SQL Injection   | 1
  Error Page            | 3

w3af/kb>>> list sqli

  # | URL                                     | Variable | Method
  --|------------------------------------------|----------|-------
  0 | http://localhost:8080/api/users?id=1     | id       | GET
  1 | http://localhost:8080/api/search?query=a | query    | GET

# 詳細を確認
w3af/kb>>> get sqli 0

  URL      : http://localhost:8080/api/users?id=1
  Variable : id
  Method   : GET
  Payload  : 1' AND '1'='1
  Response : {"id":1,"name":"Alice"}   ← 通常レスポンスと同じ → SQLi の証拠
```

---

## 手順 4: 手動確認 (w3af の REST ペイロードで直接テスト)

w3af でスキャンしながら、別ターミナルから curl で手動確認する。

### 基本テスト: シングルクォートでエラーを誘発

```bash
curl -s "http://localhost:8080/api/users?id=1'"
```

期待するレスポンス (Go + PostgreSQL):
```json
{"error": "pq: unterminated quoted string at or near \"'\""}
```

これが返れば SQL エラーが露出している = SQLi が存在する。

### 真偽テスト: 条件による差異を確認

```bash
# 常に真 → 通常レスポンス
curl -s "http://localhost:8080/api/users?id=1 AND 1=1--"
# → {"id":1,"name":"Alice","email":"alice@example.com"}

# 常に偽 → 空レスポンスまたはエラー
curl -s "http://localhost:8080/api/users?id=1 AND 1=2--"
# → {} または []
```

2つのレスポンスが異なれば SQLi が確定。

### 時間ベースブラインドテスト

```bash
# PostgreSQL: 5秒スリープ
time curl -s "http://localhost:8080/api/users?id=1;SELECT+pg_sleep(5)--"

# MySQL: 5秒スリープ
time curl -s "http://localhost:8080/api/users?id=1+AND+SLEEP(5)--"
```

レスポンスに 5 秒以上かかれば Blind SQLi が存在する。

w3af の `blind_sqli` プラグインはこの時間差を自動で検出する。

---

## 手順 5: スクリプトで自動化

```bash
# sqli_scan.w3af
plugins
audit sqli blind_sqli
crawl web_spider
grep error_pages
output console html_file
output config html_file
set output_file /tmp/sqli_report.html
back
back
target
set target http://localhost:8080/api/users?id=1
back
start
exit
```

```bash
# Docker コンテナでスクリプト実行
docker run -it \
  --network host \
  -v $(pwd)/sqli_scan.w3af:/home/w3af/scan.w3af \
  -v $(pwd)/reports:/tmp \
  andresriancho/w3af \
  ./w3af_console -s /home/w3af/scan.w3af
```

---

## 手順 6: 複数エンドポイントを一括スキャン

Go API の複数エンドポイントを一度にスキャンする。

```
w3af>>> target
w3af/config:target>>> set target http://localhost:8080/api/users?id=1, http://localhost:8080/api/products?category=1, http://localhost:8080/api/search?q=test
w3af/config:target>>> back
w3af>>> start
```

---

## 手順 7: HTTP 設定の調整 (スキャン精度向上)

```
w3af>>> http-settings
w3af/config:http-settings>>> set timeout 30
w3af/config:http-settings>>> set headers_file /tmp/headers.txt
w3af/config:http-settings>>> back
```

`/tmp/headers.txt` の内容 (JWT 認証が必要な場合):
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json
```

---

## 手順 8: レポートの確認

スキャン終了後、出力されたレポートを確認する。

```bash
# レポートをブラウザで開く
open /tmp/sqli_report.html    # macOS
xdg-open /tmp/sqli_report.html  # Linux
```

レポートに記載される内容:
- 発見された脆弱性の一覧
- 脆弱な URL とパラメータ
- 使用したペイロード
- レスポンスの証拠

---

## w3af による SQLi 検出の限界

| 限界 | 内容 |
|------|------|
| JSON ボディの SQLi | JSON リクエストボディへの注入テスト精度が低い。Go API の POST エンドポイントの多くは JSON を使うため見落とし多い |
| OOB (帯域外) SQLi | DNS コールバック機能がないため OOB SQLi は検出不可 |
| 二次 SQLi | 入力が一度 DB に保存されてから実行される SQLi は追跡できない |
| CVE の陳腐化 | メンテナンス低調のため、最新の DB バージョン固有の SQLi パターンが未収録の可能性 |
| False Positive | Go のカスタムエラーレスポンスを SQLi エラーと誤検知する場合がある |

---

## 修正方法 (Go コード)

### 脆弱なコード

```go
// NG: 文字列結合
userID := c.Query("id")
query := "SELECT * FROM users WHERE id = " + userID
row := db.QueryRow(query)
```

### 修正後のコード

```go
// OK: パラメータ化クエリ (変数を安全に渡す仕組み)
userID := c.Query("id")
row := db.QueryRow("SELECT * FROM users WHERE id = $1", userID)

// ORM (GORM) を使う場合
db.Where("id = ?", userID).First(&user)
```
