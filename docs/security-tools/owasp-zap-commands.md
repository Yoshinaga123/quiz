# OWASP ZAP コマンド一覧

## CLI 起動オプション

```bash
zap.sh [オプション]
```

| オプション | 説明 |
|-----------|------|
| `-daemon` | GUI なしのバックグラウンド常駐モード (デーモンモード) で起動 |
| `-host <ホスト>` | ZAP がリッスンするホストを指定 (デフォルト: `localhost`) |
| `-port <ポート>` | ZAP がリッスンするポートを指定 (デフォルト: `8080`) |
| `-config <key=value>` | 設定値を起動時に指定 |
| `-configfile <ファイル>` | 設定ファイルを指定 |
| `-dir <ディレクトリ>` | ZAP のホームディレクトリを指定 |
| `-installdir <ディレクトリ>` | ZAP のインストールディレクトリを指定 |
| `-session <ファイル>` | セッションファイルを読み込む |
| `-newsession <ファイル>` | 新規セッションを作成して保存 |
| `-addoninstall <アドオンID>` | アドオンをインストールして起動 |
| `-addonuninstall <アドオンID>` | アドオンをアンインストールして起動 |
| `-addonupdate` | 全アドオンを更新して起動 |
| `-notel` | テレメトリの送信を無効化 |
| `-silent` | ZAP がコールバックを行わないサイレントモードで起動 |
| `-cmd` | GUI を表示せずコマンドを実行後に終了 |

---

## Docker コマンド

### 基本起動

```bash
# バックグラウンド常駐モードで起動 (API キーなし ※テスト環境のみ)
docker run -u zap -p 8080:8080 ghcr.io/zaproxy/zaproxy:stable \
  zap.sh -daemon \
  -host 0.0.0.0 \
  -port 8080 \
  -config api.addrs.addr.name=.* \
  -config api.addrs.addr.regex=true \
  -config api.key=your-api-key
```

### Baseline スキャン

```bash
# HTML レポート出力
docker run --rm ghcr.io/zaproxy/zaproxy:stable \
  zap-baseline.py \
  -t https://example.com \
  -r report.html

# JSON レポート出力
docker run --rm ghcr.io/zaproxy/zaproxy:stable \
  zap-baseline.py \
  -t https://example.com \
  -J report.json

# CI モード (警告をエラーとして扱う)
docker run --rm ghcr.io/zaproxy/zaproxy:stable \
  zap-baseline.py \
  -t https://example.com \
  -r report.html \
  -I

# 設定ファイルを指定
docker run --rm \
  -v $(pwd):/zap/wrk \
  ghcr.io/zaproxy/zaproxy:stable \
  zap-baseline.py \
  -t https://example.com \
  -c zap.conf \
  -r report.html
```

### フルスキャン (アクティブスキャン含む)

```bash
docker run --rm ghcr.io/zaproxy/zaproxy:stable \
  zap-full-scan.py \
  -t https://example.com \
  -r report.html
```

### API スキャン (OpenAPI / Swagger 対応)

```bash
# OpenAPI 定義ファイルを使ったスキャン
docker run --rm ghcr.io/zaproxy/zaproxy:stable \
  zap-api-scan.py \
  -t https://example.com/openapi.json \
  -f openapi \
  -r report.html

# GraphQL スキャン
docker run --rm ghcr.io/zaproxy/zaproxy:stable \
  zap-api-scan.py \
  -t https://example.com/graphql \
  -f graphql \
  -r report.html
```

---

## ZAP スキャンスクリプト オプション一覧

`zap-baseline.py` / `zap-full-scan.py` / `zap-api-scan.py` 共通オプション:

| オプション | 説明 |
|-----------|------|
| `-t <URL>` | スキャン対象の URL |
| `-r <ファイル>` | HTML レポートの出力先 |
| `-J <ファイル>` | JSON レポートの出力先 |
| `-x <ファイル>` | XML レポートの出力先 |
| `-w <ファイル>` | Markdown レポートの出力先 |
| `-c <ファイル>` | 設定ファイルのパス |
| `-g <ファイル>` | 設定ファイルを生成して終了 |
| `-a` | スパイダースキャンを有効化 (Ajax Spider) |
| `-d` | デバッグ出力を有効化 |
| `-P <ポート>` | ZAP がリッスンするポートを指定 |
| `-I` | アラートをエラーとして扱わない (CI での終了コード制御) |
| `-i` | 情報レベルのアラートも失敗扱いにする |
| `-l <レベル>` | ログレベル (`PASS` / `IGNORE` / `INFO` / `WARN` / `FAIL`) |
| `-n <コンテキストファイル>` | コンテキストファイルを使用 |
| `-z <ZAP オプション>` | ZAP CLI オプションを追加渡し |
| `-s` | 既存の ZAP インスタンスに接続 |
| `-T <分>` | スキャンのタイムアウト (分) |
| `-m <分>` | Spider のタイムアウト (分) |

---

## REST API コマンド

ZAP がバックグラウンド常駐モード (デーモンモード) で起動中に `http://localhost:8080` で REST API が利用できます。

### 共通パラメータ

```
apikey=<APIキー>   # 認証キー (設定した場合必須)
```

### Spider (クロール)

```bash
# スパイダースキャン開始
curl "http://localhost:8080/JSON/spider/action/scan/?url=https://example.com&apikey=your-api-key"

# スキャン状況確認 (0〜100%)
curl "http://localhost:8080/JSON/spider/view/status/?scanId=0&apikey=your-api-key"

# クロール結果の URL 一覧
curl "http://localhost:8080/JSON/spider/view/results/?scanId=0&apikey=your-api-key"

# スパイダースキャン停止
curl "http://localhost:8080/JSON/spider/action/stop/?scanId=0&apikey=your-api-key"
```

### Ajax Spider

```bash
# Ajax Spider 開始
curl "http://localhost:8080/JSON/ajaxSpider/action/scan/?url=https://example.com&apikey=your-api-key"

# ステータス確認
curl "http://localhost:8080/JSON/ajaxSpider/view/status/?apikey=your-api-key"

# 停止
curl "http://localhost:8080/JSON/ajaxSpider/action/stop/?apikey=your-api-key"
```

### Active Scan (アクティブスキャン)

```bash
# アクティブスキャン開始
curl "http://localhost:8080/JSON/ascan/action/scan/?url=https://example.com&apikey=your-api-key"

# スキャン状況確認 (0〜100%)
curl "http://localhost:8080/JSON/ascan/view/status/?scanId=0&apikey=your-api-key"

# スキャン停止
curl "http://localhost:8080/JSON/ascan/action/stop/?scanId=0&apikey=your-api-key"

# スキャンポリシー一覧
curl "http://localhost:8080/JSON/ascan/view/scanPolicyNames/?apikey=your-api-key"
```

### アラート (検出結果)

```bash
# 全アラート取得
curl "http://localhost:8080/JSON/alert/view/alerts/?apikey=your-api-key"

# リスクレベル別にフィルタ (High のみ)
curl "http://localhost:8080/JSON/alert/view/alerts/?riskId=3&apikey=your-api-key"
# riskId: 0=Informational, 1=Low, 2=Medium, 3=High

# アラート件数のサマリ
curl "http://localhost:8080/JSON/alert/view/alertsSummary/?apikey=your-api-key"
```

### レポート出力

```bash
# HTML レポート
curl "http://localhost:8080/OTHER/core/other/htmlreport/?apikey=your-api-key" -o report.html

# XML レポート
curl "http://localhost:8080/OTHER/core/other/xmlreport/?apikey=your-api-key" -o report.xml

# JSON レポート
curl "http://localhost:8080/OTHER/core/other/jsonreport/?apikey=your-api-key" -o report.json
```

### セッション管理

```bash
# 新規セッション作成
curl "http://localhost:8080/JSON/core/action/newSession/?apikey=your-api-key"

# セッション保存
curl "http://localhost:8080/JSON/core/action/saveSession/?name=/tmp/session&apikey=your-api-key"

# セッション読み込み
curl "http://localhost:8080/JSON/core/action/loadSession/?name=/tmp/session&apikey=your-api-key"
```

### ZAP 終了

```bash
curl "http://localhost:8080/JSON/core/action/shutdown/?apikey=your-api-key"
```

---

## zap-cli コマンド (Python クライアント)

```bash
pip install zapcli

# ステータス確認
zap-cli status

# Spider スキャン
zap-cli spider https://example.com

# アクティブスキャン
zap-cli active-scan https://example.com

# アラート一覧
zap-cli alerts

# レポート出力
zap-cli report -o report.html -f html

# ZAP 終了
zap-cli shutdown
```

---

## GitHub Actions での使用例

```yaml
jobs:
  zap-scan:
    runs-on: ubuntu-latest
    steps:
      - name: ZAP Baseline Scan
        uses: zaproxy/action-baseline@v0.12.0
        with:
          target: 'https://example.com'
          rules_file_name: '.zap/rules.tsv'
          cmd_options: '-a'

      - name: ZAP Full Scan
        uses: zaproxy/action-full-scan@v0.10.0
        with:
          target: 'https://example.com'

      - name: ZAP API Scan
        uses: zaproxy/action-api-scan@v0.7.0
        with:
          target: 'https://example.com/openapi.json'
          format: openapi
```

---

## よく使う設定キー (`-config` オプション)

| キー | 説明 | 例 |
|-----|------|-----|
| `api.key` | API キーの設定 | `api.key=mysecretkey` |
| `api.addrs.addr.name` | API アクセスを許可するホスト | `api.addrs.addr.name=.*` |
| `api.addrs.addr.regex` | 正規表現で指定するか | `api.addrs.addr.regex=true` |
| `connection.timeoutInSecs` | 接続タイムアウト (秒) | `connection.timeoutInSecs=20` |
| `scanner.threadPerHost` | ホストごとのスレッド数 | `scanner.threadPerHost=5` |
| `spider.maxDepth` | Spider の最大深度 | `spider.maxDepth=10` |
| `spider.maxChildren` | Spider の最大子ノード数 | `spider.maxChildren=100` |

---

## 参考リンク

- [ZAP CLI ドキュメント](https://www.zaproxy.org/docs/desktop/cmdline/)
- [ZAP REST API ドキュメント](https://www.zaproxy.org/docs/api/)
- [ZAP Docker イメージ](https://www.zaproxy.org/docs/docker/)
- [ZAP GitHub Actions](https://github.com/zaproxy/action-baseline)
