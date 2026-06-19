# OWASP ZAP — DoS / DDoS 関連脆弱性 検出手順

## 対象脆弱性

DoS (Denial of Service) / DDoS (Distributed DoS) に直結する以下のアプリケーション層の脆弱性を対象とする。

| 脆弱性 | OWASP 分類 | 概要 |
|--------|-----------|------|
| レートリミット欠如 | A04 Insecure Design | 同一エンドポイントへの無制限リクエストを許容 |
| ReDoS | A04 Insecure Design | 悪意ある正規表現入力でサーバ CPU を枯渇 |
| Slow HTTP (Slowloris) | A05 Security Misconfiguration | 低速リクエストでコネクションを占有 |
| 巨大ペイロード | A04 Insecure Design | 大きな JSON / ファイルでメモリ・CPU を枯渇 |
| JSON/XML Bomb | A04 Insecure Design | 深くネストした構造でパーサを枯渇 |

> **重要**: 本手順は自分が所有または許可を得た環境でのみ実施すること。  
> 本番環境での DoS テストは絶対に禁止。必ずステージング・開発環境を使用する。

---

## 検証対象の想定環境

```
Go バックエンド (Gin フレームワーク)
エンドポイント:
  POST /api/login          (レートリミットなし)
  GET  /api/search?q=xxx   (ReDoS 脆弱な正規表現)
  POST /api/upload         (ファイルサイズ制限なし)
  POST /api/data           (JSON 深さ制限なし)
```

---

## 事前準備

### 1. ZAP の起動

```bash
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

---

## 検証 1: レートリミット欠如の検出

### 手順: ZAP Fuzzer で大量リクエストを送信

```
1. ブラウザで POST /api/login を実行し、HTTP history に記録させる

2. HTTP history → /api/login を右クリック
   → "Attack" → "Fuzz..."

3. Fuzz ダイアログ:
   Body 内の username の値をハイライト → "Add" → "Payload" タブ
   → Type: "Numberzz"  開始: 1 終了: 1000 (1000回送信)

4. "Fuzz" をクリック
```

### 結果の確認ポイント

```
Fuzzer 結果テーブルで確認:
  - 全リクエストがステータス 200 または 401 → レートリミットなし (脆弱)
  - 429 Too Many Requests が返り始める → レートリミットあり (安全)

Columns:
  Code | Reason    | Size Resp Header | RTT
  401  | OK        | 145 bytes        | 12 ms
  401  | OK        | 145 bytes        | 11 ms
  ...
  ← 429 が一度も出ない場合は Rate Limit 未設定
```

### CLI (API) での自動確認

```bash
# 100回連続でログインを試みてレスポンスコードを確認
for i in $(seq 1 100); do
  code=$(curl -s -o /dev/null -w "%{http_code}" -X POST http://localhost:8080/api/login \
    -H "Content-Type: application/json" \
    -d '{"username":"test","password":"wrong"}')
  echo "Request $i: $code"
  if [ "$code" = "429" ]; then
    echo "Rate limit triggered at request $i"
    break
  fi
done
```

100回すべて 401 なら Rate Limit なし = DoS リスクあり。

---

## 検証 2: ReDoS (正規表現 DoS) の検出

### 脆弱なGoコード例

```go
// NG: バックトラッキングが爆発する正規表現
import "regexp"

pattern := regexp.MustCompile(`^(a+)+$`)
if pattern.MatchString(userInput) {   // userInput = "aaaaaaaaaaaaaab" で長時間ブロック
    ...
}
```

### ZAP Fuzzer での ReDoS テスト

```
1. GET /api/search?q=test を HTTP history から Fuzzer に送信

2. パラメータ q の値をハイライト → Payload Type: "File"
   → ReDoS 専用ペイロードファイルを指定:

   # /tmp/redos_payloads.txt の内容:
   aaaaaaaaaaaaaaaaaaaaaaaaaab
   (a+)+b
   aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaac
   aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaab
   (a|a)+b
```

```bash
# ペイロードファイルを作成
cat << 'EOF' > /tmp/redos_payloads.txt
aaaaaaaaaaaaaaaaaaaaaaaaaab
aaaaaaaaaaaaaaaaaaaaaaaaaaaab
aaaaaaaaaaaaaaaaaaaaaaaaaaaaab
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaab
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaab
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaab
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaab
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaab
EOF
```

### 結果の確認

```
Fuzzer 結果の RTT (応答時間) 列を確認:
  通常リクエスト: 5–20 ms
  ReDoS ペイロード: 5000–30000 ms (5秒以上)

RTT が急激に増加するペイロードがあれば ReDoS 脆弱性あり
```

---

## 検証 3: Slow HTTP (Slowloris) の検出

ZAP 自体には Slowloris テストは含まれないが、設定漏れを確認できる。

### ZAP のパッシブスキャン (通信を見るだけで攻撃データを送らない検査) で Server ヘッダを確認

```
HTTP history → 任意のレスポンス → Response ヘッダを確認:

  Server: nginx/1.18.0
  → nginx が前段にない場合、Go の net/http は接続タイムアウトのデフォルトが長い

確認ポイント:
  - Keep-Alive タイムアウト設定の有無
  - Connection: close ヘッダの有無
```

### ZAP Script コンソールで Slow HTTP をシミュレート

```
ZAP → Script Console → Type: Standalone

# JavaScript で不完全なヘッダを送り続けるシミュレーション
importClass(java.net.Socket)
importClass(java.io.PrintWriter)
importClass(java.lang.Thread)

var connections = []
for (var i = 0; i < 50; i++) {
    var sock = new Socket("localhost", 8080)
    var writer = new PrintWriter(sock.getOutputStream(), true)
    writer.println("GET /api/users HTTP/1.1")
    writer.println("Host: localhost:8080")
    writer.println("X-Custom-" + i + ": value")
    // ヘッダを故意に完了させない (\\r\\n\\r\\n を送らない)
    connections.push(sock)
}

Thread.sleep(10000)

// この間にサーバが新しいコネクションを受け付けられるか確認
var test = new Socket("localhost", 8080)
// 接続できれば Slowloris 耐性あり
// タイムアウトすれば脆弱
```

---

## 検証 4: 巨大ペイロード (Large Payload) の検出

### ZAP Fuzzer で大きなペイロードを送信

```bash
# 大きなペイロードファイルを生成
python3 -c "
import json
payload = {'data': 'A' * 10_000_000}  # 10MB の文字列
with open('/tmp/large_payload.json', 'w') as f:
    json.dump(payload, f)
"
```

```
1. POST /api/data の Intercept されたリクエストを Fuzzer に送信
2. Body 全体を選択 → Payload Type: "File"
   → /tmp/large_payload.json を指定
3. Fuzz → RTT と レスポンスを確認

期待: 413 Request Entity Too Large が返る (安全)
危険: 200 OK が返り、サーバ負荷が急増する (脆弱)
```

### API での確認

```bash
# 10MB の JSON を送信
python3 -c "print('{\"data\":\"' + 'A'*10000000 + '\"}')" > /tmp/big.json
curl -s -o /dev/null -w "%{http_code} %{size_upload}bytes\n" \
  -X POST http://localhost:8080/api/data \
  -H "Content-Type: application/json" \
  -d @/tmp/big.json
```

---

## 検証 5: JSON Bomb の検出

### テストペイロード (深くネストした JSON)

```bash
cat << 'EOF' > /tmp/json_bomb.json
{"a":{"a":{"a":{"a":{"a":{"a":{"a":{"a":{"a":{"a":{"a":{"a":{"a":{"a":{"a":{"a":{"a":{"a":{"a":{"a":"bomb"}}}}}}}}}}}}}}}}}}}}
EOF
```

```bash
# 送信して応答を確認
time curl -s -o /dev/null -w "%{http_code}\n" \
  -X POST http://localhost:8080/api/data \
  -H "Content-Type: application/json" \
  -d @/tmp/json_bomb.json

# 処理に時間がかかる = JSON Bomb に脆弱
# 即座に 400 Bad Request が返れば深さ制限あり (安全)
```

---

## 検証 6: ZAP スキャン設定でリソース枯渇リスクを確認

### アクティブスキャン (実際に攻撃データを送って検査) で DoS 関連チェック

```bash
# アクティブスキャン開始 (DoS 関連スキャンルールを含む)
curl "http://localhost:8080/JSON/ascan/action/scan/?url=http://target:8080&apikey=zapkey123"

# スキャン完了後: DoS 関連アラートを確認
curl "http://localhost:8080/JSON/alert/view/alerts/?apikey=zapkey123" | \
  python3 -c "
import json, sys
alerts = json.load(sys.stdin)['alerts']
dos_related = [a for a in alerts if 'DoS' in a['alert'] or 'Denial' in a['alert'] or 'Rate' in a['alert']]
for a in dos_related:
    print(a['alert'], '-', a['url'])
"
```

### パッシブスキャン (通信を見るだけの検査) で確認できる DoS 関連ヘッダ

ZAP のパッシブスキャンは以下のヘッダ欠如を自動検出する:

```
[Missing Header] X-Content-Type-Options
[Missing Header] X-Frame-Options
[Missing Header] Strict-Transport-Security

# DoS に直接関係する設定確認
Retry-After ヘッダの有無 → レートリミット応答に含まれるべき
```

---

## CI/CD でのレートリミット確認 (GitHub Actions)

```yaml
name: DoS Resilience Check

on: [push]

jobs:
  rate-limit-check:
    runs-on: ubuntu-latest
    steps:
      - name: Start API
        run: docker compose up -d

      - name: Check rate limiting on login endpoint
        run: |
          TRIGGERED=false
          for i in $(seq 1 50); do
            CODE=$(curl -s -o /dev/null -w "%{http_code}" \
              -X POST http://localhost:8080/api/login \
              -H "Content-Type: application/json" \
              -d '{"username":"test","password":"wrong"}')
            if [ "$CODE" = "429" ]; then
              echo "Rate limit triggered at request $i ✓"
              TRIGGERED=true
              break
            fi
          done
          if [ "$TRIGGERED" = "false" ]; then
            echo "ERROR: Rate limit not triggered after 50 requests"
            exit 1
          fi

      - name: Check large payload rejection
        run: |
          python3 -c "print('{\"data\":\"' + 'A'*1000001 + '\"}')" > /tmp/big.json
          CODE=$(curl -s -o /dev/null -w "%{http_code}" \
            -X POST http://localhost:8080/api/data \
            -H "Content-Type: application/json" \
            -d @/tmp/big.json)
          if [ "$CODE" != "413" ] && [ "$CODE" != "400" ]; then
            echo "ERROR: Large payload not rejected (got $CODE)"
            exit 1
          fi
          echo "Large payload rejected with $CODE ✓"
```

---

## 修正方法 (Go コード)

### レートリミット実装

```go
import "github.com/ulule/limiter/v3"
import "github.com/ulule/limiter/v3/drivers/middleware/gin"
import "github.com/ulule/limiter/v3/drivers/store/memory"

rate := limiter.Rate{
    Period: 1 * time.Minute,
    Limit:  10,
}
store := memory.NewStore()
instance := limiter.New(store, rate)

router.POST("/api/login", gin_limiter.NewMiddleware(instance), loginHandler)
```

### 巨大ペイロード制限

```go
// Gin のデフォルト上限は 32 MB → 明示的に制限する
router.MaxMultipartMemory = 4 << 20  // 4 MB

// JSON ボディサイズ制限
router.Use(func(c *gin.Context) {
    c.Request.Body = http.MaxBytesReader(c.Writer, c.Request.Body, 1<<20) // 1 MB
    c.Next()
})
```

### ReDoS 対策

```go
// NG: バックトラッキングが爆発する正規表現
pattern := regexp.MustCompile(`^(a+)+$`)

// OK: シンプルな文字クラス + 長さ制限
if len(input) > 100 {
    return errors.New("input too long")
}
pattern := regexp.MustCompile(`^[a-z0-9]+$`)
```

### Connection タイムアウト設定

```go
srv := &http.Server{
    Addr:         ":8080",
    Handler:      router,
    ReadTimeout:  5 * time.Second,   // ヘッダ読み取りタイムアウト
    WriteTimeout: 10 * time.Second,
    IdleTimeout:  30 * time.Second,  // Keep-Alive タイムアウト
}
```

---

## ZAP による DoS 関連検出の限界

| 限界 | 内容 |
|------|------|
| 本物の DDoS テスト | 分散攻撃は ZAP 単体では再現不可 (負荷テストツール k6/Locust との組み合わせが必要) |
| ネットワーク層の DoS | SYN Flood、UDP Flood などの L3/L4 攻撃は検出対象外 |
| 自動 ReDoS 検出 | ZAP のデフォルトルールに ReDoS 専用チェックはなく、手動 Fuzzing が必要 |
| Slowloris | ZAP には Slowloris テスト機能なし (slowhttptest などの専用ツールが必要) |
