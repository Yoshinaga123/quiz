# w3af — DoS / DDoS 関連脆弱性 検出手順

## 対象脆弱性

DoS (Denial of Service) / DDoS (Distributed DoS) に直結するアプリケーション層の脆弱性。

| 脆弱性 | OWASP 分類 | w3af プラグイン |
|--------|-----------|----------------|
| レートリミット欠如 | A04 Insecure Design | `audit/dos` (限定的) |
| ReDoS | A04 Insecure Design | `audit/redos` |
| Slow HTTP | A05 Security Misconfiguration | 手動確認 |
| 巨大ペイロード | A04 Insecure Design | `audit/file_upload` + 手動 |
| バッファオーバーフロー系 | A04 Insecure Design | `audit/buffer_overflow` |

> **重要**: 自分が所有または許可を得た環境でのみ実施すること。  
> 本番環境での DoS テストは絶対に禁止。

> **w3af の注意**: w3af はメンテナンスが低調。ReDoS プラグインなど一部は動作が不安定な場合がある。ZAP または Burp Suite との併用を強く推奨する。

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

### 1. w3af の起動

```bash
docker run -it \
  --network host \
  andresriancho/w3af \
  ./w3af_console
```

---

## 検証 1: ReDoS の検出

### プラグインの設定

```
w3af>>> plugins

# ReDoS 検出プラグイン
w3af/plugins>>> audit redos

# エンドポイントを Spider で探索
w3af/plugins>>> crawl web_spider

# エラーページの検出 (ReDoS でサーバがエラーを返す場合)
w3af/plugins>>> grep error_pages

w3af/plugins>>> output console html_file
w3af/plugins>>> output config html_file
w3af/plugins/output/config:html_file>>> set output_file /tmp/dos_report.html
w3af/plugins/output/config:html_file>>> back
w3af/plugins>>> back
```

### ターゲットの設定と実行

```
w3af>>> target
w3af/config:target>>> set target http://localhost:8080/api/search?q=test
w3af/config:target>>> back
w3af>>> start
```

### 検出時の出力例

```
[17:03:12] redos plugin is testing: http://localhost:8080/api/search?q=test
[17:03:14] [High] ReDoS vulnerability found at:
           URL: http://localhost:8080/api/search?q=test
           Variable: "q"
           Payload: "aaaaaaaaaaaaaaaaaaaaaaaaaab"
           Response time with normal input:   12 ms
           Response time with ReDoS payload: 8423 ms
           Ratio: 702x → ReDoS confirmed
```

### 手動確認

```bash
# 通常の入力でのレスポンス時間
time curl -s "http://localhost:8080/api/search?q=hello"

# ReDoS ペイロードでのレスポンス時間
time curl -s "http://localhost:8080/api/search?q=aaaaaaaaaaaaaaaaaaaaaaaaaab"
time curl -s "http://localhost:8080/api/search?q=aaaaaaaaaaaaaaaaaaaaaaaaaaaaaab"

# 5秒以上かかれば ReDoS 脆弱性あり
```

---

## 検証 2: レートリミット欠如の検出

w3af には専用のレートリミット検出プラグインはないが、`brute` プラグインと手動スクリプトで確認できる。

### brute プラグインで確認

```
w3af>>> plugins
w3af/plugins>>> bruteforce form_auth_brute_force
w3af/plugins>>> back

w3af>>> target
w3af/config:target>>> set target http://localhost:8080/api/login
w3af/config:target>>> back
w3af>>> start
```

### 結果の確認

```
w3af>>> kb
w3af/kb>>> list brute_force

  # | URL                              | Findings
  --|----------------------------------|--------
  0 | http://localhost:8080/api/login  | No lockout detected after 50 attempts
```

「No lockout detected」が表示されれば、アカウントロックアウトもレートリミットも存在しない。

### 手動スクリプトでの確認

```bash
# 50 回連続でログイン試行
for i in $(seq 1 50); do
  CODE=$(curl -s -o /dev/null -w "%{http_code}" \
    -X POST http://localhost:8080/api/login \
    -H "Content-Type: application/json" \
    -d "{\"username\":\"test\",\"password\":\"wrong$i\"}")
  echo "Request $i: HTTP $CODE"
  if [ "$CODE" = "429" ]; then
    echo "→ Rate limit triggered at request $i"
    break
  fi
done | tee /tmp/rate_limit_test.txt

# 結果サマリ
echo "=== Summary ==="
grep -c "HTTP 401" /tmp/rate_limit_test.txt || true
grep -c "HTTP 429" /tmp/rate_limit_test.txt || true
```

---

## 検証 3: バッファオーバーフロー / 大きな入力

### buffer_overflow プラグインの設定

```
w3af>>> plugins
w3af/plugins>>> audit buffer_overflow

# バッファオーバーフローは GET パラメータに長い文字列を送るプラグイン
# DoS につながるメモリ消費を検出する副次効果あり

w3af/plugins>>> back
w3af>>> target
w3af/config:target>>> set target http://localhost:8080/api/search?q=test
w3af/config:target>>> back
w3af>>> start
```

### 出力例

```
[17:10:02] buffer_overflow plugin is testing: http://localhost:8080/api/search?q=test
[17:10:05] [Medium] Possible buffer overflow / resource exhaustion at:
           URL: http://localhost:8080/api/search?q=test
           Variable: "q"
           Payload length: 32760 bytes
           Response: HTTP 500 (server error triggered by large input)
```

### 手動での大きな入力テスト

```bash
# 各サイズの入力でテスト
for SIZE in 100 1000 10000 100000 1000000; do
  INPUT=$(python3 -c "print('A' * $SIZE)")
  TIME=$(curl -s -o /dev/null -w "%{time_total}" \
    "http://localhost:8080/api/search?q=$INPUT")
  CODE=$(curl -s -o /dev/null -w "%{http_code}" \
    "http://localhost:8080/api/search?q=$INPUT")
  echo "Size: $SIZE chars → HTTP $CODE (${TIME}s)"
done
```

期待する結果:
```
Size: 100 chars    → HTTP 200 (0.012s)
Size: 1000 chars   → HTTP 200 (0.013s)
Size: 10000 chars  → HTTP 400 (0.011s)  ← 入力長チェックあり
Size: 100000 chars → HTTP 413 (0.010s)  ← リクエストサイズ制限あり
Size: 1000000 chars → HTTP 413 (0.010s)
```

---

## 検証 4: Slow HTTP の設定確認

w3af は Slowloris 攻撃を直接実行しないが、サーバ設定の漏れを grep プラグインで確認できる。

### grep プラグインでヘッダを確認

```
w3af>>> plugins
w3af/plugins>>> grep http_in_body http_auth_detect
w3af/plugins>>> back

w3af>>> target
w3af/config:target>>> set target http://localhost:8080
w3af/config:target>>> back
w3af>>> start
```

### 手動でのタイムアウト確認

```bash
# 不完全なリクエストを送信してタイムアウトを計測
time (echo -e "GET /api/users HTTP/1.1\r\nHost: localhost:8080\r\n" | \
  nc -q 60 localhost 8080)
# → 応答するまでの時間を計測
# 60 秒以上待ち続ける = Connection タイムアウト設定なし = Slowloris 脆弱
```

```bash
# ReadTimeout が設定されているか確認 (設定が正しければ 5秒程度でタイムアウト)
time (echo -ne "GET /api/users HTTP/1.1\r\nHost: localhost:8080\r\n" | \
  nc localhost 8080)
# 5秒以内に接続が切られれば ReadTimeout が機能している
```

---

## 検証 5: JSON Bomb (深くネストした JSON) のテスト

```bash
# 20段ネストした JSON Bomb を生成
python3 -c "
depth = 20
bomb = '\"end\"'
for _ in range(depth):
    bomb = '{\"a\":' + bomb + '}'
with open('/tmp/json_bomb.json', 'w') as f:
    f.write(bomb)
print('JSON bomb size:', len(bomb), 'bytes')
" 

# 送信
time curl -s -o /tmp/bomb_response.txt -w "%{http_code}" \
  -X POST http://localhost:8080/api/data \
  -H "Content-Type: application/json" \
  -d @/tmp/json_bomb.json

cat /tmp/bomb_response.txt
```

期待: 即座に `400 Bad Request` (深さ制限あり)
危険: 処理に時間がかかって `200 OK` またはサーバがハング

---

## 自動化スクリプト (.w3af ファイル)

```bash
# dos_scan.w3af
plugins
audit redos buffer_overflow
crawl web_spider
grep error_pages
output console html_file
output config html_file
set output_file /tmp/dos_report.html
back
back
target
set target http://localhost:8080
back
start
exit
```

```bash
docker run -it \
  --network host \
  -v $(pwd)/dos_scan.w3af:/home/w3af/scan.w3af \
  -v $(pwd)/reports:/tmp \
  andresriancho/w3af \
  ./w3af_console -s /home/w3af/scan.w3af
```

---

## 補完ツール: slowhttptest による Slowloris テスト

w3af では Slowloris を直接テストできないため、専用ツールを使う。

```bash
# slowhttptest をインストール
sudo apt install slowhttptest

# Slowloris テスト (20秒間、200コネクション、2秒間隔でヘッダを送信)
slowhttptest \
  -c 200 \
  -H \
  -g \
  -o /tmp/slowloris_test \
  -i 10 \
  -r 200 \
  -t GET \
  -u http://localhost:8080/api/users \
  -x 24 \
  -p 3

# オプション説明:
#   -c 200    : 200 コネクション
#   -H        : Slowloris モード (不完全ヘッダ)
#   -i 10     : 10 秒間隔でヘッダ送信
#   -r 200    : 1秒あたり 200 コネクション
#   -p 3      : 3 秒以内に応答なければサービス停止とみなす
```

---

## レポートの確認

```bash
# HTML レポートをブラウザで開く
xdg-open /tmp/dos_report.html

# w3af スキャン結果 (ナレッジベース) で確認
w3af>>> kb
w3af/kb>>> list

  Vulnerability           | Count
  ------------------------|------
  ReDoS                   | 1
  Possible Buffer Overflow | 2
```

---

## 修正方法 (Go コード)

### レートリミット実装

```go
import "github.com/ulule/limiter/v3"

rate := limiter.Rate{
    Period: 1 * time.Minute,
    Limit:  10,
}
```

### ReDoS 対策

```go
// NG
pattern := regexp.MustCompile(`^(a+)+$`)

// OK: シンプルな正規表現 + 入力長制限
if len(input) > 100 {
    return errors.New("input too long")
}
pattern := regexp.MustCompile(`^[a-z0-9]+$`)
```

### JSON 深さ制限 (Go)

```go
import "encoding/json"

decoder := json.NewDecoder(r.Body)
decoder.DisallowUnknownFields()
// MaxDepth は標準ライブラリにないため、jsoniter を使う
import jsoniter "github.com/json-iterator/go"

var jsoni = jsoniter.Config{
    MaxDepth: 10,
}.Froze()
jsoni.Unmarshal(data, &result)
```

### サーバタイムアウト設定

```go
srv := &http.Server{
    ReadTimeout:  5 * time.Second,
    WriteTimeout: 10 * time.Second,
    IdleTimeout:  30 * time.Second,
}
```

---

## w3af による DoS 関連検出の限界

| 限界 | 内容 |
|------|------|
| DDoS の再現 | 分散攻撃は w3af 単体では不可。k6 / Locust との組み合わせが必要 |
| Slowloris | 専用プラグインなし。slowhttptest などの外部ツールを使用 |
| JSON Bomb | 自動検出なし。手動 curl テストが必要 |
| プラグインの信頼性 | w3af はメンテナンス低調。redos プラグインが最新バージョンで動作しない場合あり |
| ネットワーク層 DoS | L3/L4 攻撃 (SYN Flood など) は対象外 |
