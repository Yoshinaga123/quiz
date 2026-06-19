# OWASP ZAP — Go + React + Flutter + Docker 構成での注意点

## 対象構成

```
[Flutter Mobile] ─┐
[React SPA]      ─┼─ HTTPS ──► [Go API Server] ──► [DB / 外部サービス]
                   └─── Docker コンテナで稼働
```

---

## Go バックエンド (REST API) の注意点

### ① OpenAPI / Swagger 定義を活用する

ZAP の API スキャンは OpenAPI 定義ファイルがあると **クロールできないエンドポイントも網羅的に検査できる**。

```bash
# OpenAPI 定義を使ったスキャン
docker run --rm ghcr.io/zaproxy/zaproxy:stable \
  zap-api-scan.py \
  -t http://localhost:8080/openapi.json \
  -f openapi \
  -r report.html
```

> **注意**: Go の API が OpenAPI 定義を公開していない場合、ZAP の Spider は JSON レスポンスの中のリンクを追いにくく、エンドポイントを見落とす可能性がある。

### ② JSON ボディへのインジェクションテスト

Go の REST API は多くの場合 JSON ボディでパラメータを受け取る。ZAP のデフォルトスキャンは **URL パラメータ・フォームパラメータを主な対象**としており、JSON ボディへのインジェクションは設定が必要。

```
ZAP → Options → Active Scan Input Vectors
→ "JSON" にチェックを入れる
```

### ③ JWT 認証への対応

Go API が JWT で認証している場合、スキャン中にトークンが期限切れになると認証が切れてスキャンが不完全になる。

**対策**:
- ZAP のスクリプト機能で定期的にトークンを再取得するよう設定する
- コンテキスト設定で認証スクリプトを登録する

```
ZAP → Sites → 右クリック → Flag as Context → Authentication
→ Script-based Authentication を選択
```

### ④ CORS 設定の検証

Go の API サーバが `Access-Control-Allow-Origin: *` など緩い CORS 設定をしていないかをパッシブスキャンで検出できる。ZAP はデフォルトでこれを検出するが、**ワイルドカードと認証情報の組み合わせ** (`credentials: true` + `*`) は手動確認が必要。

---

## React フロントエンド (SPA) の注意点

### ⑤ Ajax Spider の使用が必須

React は JavaScript で動的にコンテンツを生成するため、通常の Spider ではページを正しくクロールできない。

```bash
# Ajax Spider を有効化してスキャン
docker run --rm ghcr.io/zaproxy/zaproxy:stable \
  zap-full-scan.py \
  -t http://localhost:3000 \
  -a \        # Ajax Spider を有効化
  -r report.html
```

> **注意**: Ajax Spider は通常の Spider より時間がかかる。タイムアウト設定を調整すること。

### ⑥ React Router のルーティング

React Router を使っている場合、URL がハッシュベース (`/#/path`) かヒストリーベース (`/path`) かによってクロールの挙動が異なる。ヒストリーベースの場合は ZAP が正しくルートを認識しやすいが、複雑なネスト構造は見落としが出やすい。

**対策**: 手動でブラウザを操作して全ページを ZAP に認識させてからスキャンを開始する。

### ⑦ Content Security Policy (CSP) の検証

React アプリが適切な CSP ヘッダを返しているかをパッシブスキャンで確認する。ZAP はデフォルトで CSP 未設定を検出する。

---

## Flutter モバイルの注意点

### ⑧ プロキシ設定

Flutter アプリはデフォルトでシステムプロキシを使用しない場合がある。コードレベルでプロキシを設定する必要がある。

**開発・テスト用の設定例 (Dart)**:

```dart
// テスト環境のみ: ZAP をプロキシとして設定
import 'dart:io';

final client = HttpClient();
client.findProxy = (uri) => 'PROXY 127.0.0.1:8080';
// ZAP の CA 証明書を信頼するよう設定
client.badCertificateCallback = (cert, host, port) => true; // ※本番では絶対に使わない
```

> **警告**: `badCertificateCallback` で証明書を無効化するコードが本番ビルドに混入しないよう、フラグ管理を徹底すること。

### ⑨ 証明書ピンニング

Flutter アプリが証明書ピンニングを実装している場合、ZAP の CA 証明書を信頼せず通信が遮断される。

**確認方法**:
```bash
# ZAP プロキシ経由でアプリを起動してエラーが出るか確認
# エラー例: "CERTIFICATE_VERIFY_FAILED"
```

**対策**: テスト環境ではピンニングを無効化したビルドを用意する。

### ⑩ HTTP/2 の対応

Flutter アプリは HTTP/2 を使う場合がある。ZAP は HTTP/2 のサポートが限定的。

**対策**:
```
ZAP → Options → Network → Connection
→ HTTP/2 を無効化するか、HTTP/1.1 フォールバックを確認
```

---

## Docker 環境の注意点

### ⑪ ネットワーク設定

ZAP コンテナからスキャン対象コンテナへの疎通を確保する必要がある。

```bash
# 同じ Docker ネットワークに ZAP を参加させる
docker run --rm \
  --network your-app-network \
  ghcr.io/zaproxy/zaproxy:stable \
  zap-baseline.py \
  -t http://go-api:8080 \   # コンテナ名で指定
  -r report.html
```

```yaml
# docker-compose.yml での設定例
services:
  zap:
    image: ghcr.io/zaproxy/zaproxy:stable
    networks:
      - app-network
    command: zap-baseline.py -t http://go-api:8080 -r /zap/reports/report.html
    volumes:
      - ./reports:/zap/reports

  go-api:
    build: ./backend
    networks:
      - app-network

networks:
  app-network:
```

### ⑫ HTTPS 環境でのスキャン

本番に近い環境 (HTTPS) でスキャンする場合、自己署名証明書に対して ZAP が警告を出す場合がある。

```bash
# 自己署名証明書を許可してスキャン
zap-baseline.py -t https://localhost:8443 -r report.html
```

---

## CI/CD パイプラインへの組み込み例

```yaml
# GitHub Actions での ZAP スキャン (Go + React 構成)
name: Security Scan

on: [push]

jobs:
  security-scan:
    runs-on: ubuntu-latest
    services:
      go-api:
        image: your-go-api-image
        ports:
          - 8080:8080

    steps:
      - uses: actions/checkout@v4

      - name: ZAP API Scan (Go backend)
        uses: zaproxy/action-api-scan@v0.7.0
        with:
          target: 'http://localhost:8080/openapi.json'
          format: openapi

      - name: ZAP Baseline Scan (React frontend)
        uses: zaproxy/action-baseline@v0.12.0
        with:
          target: 'http://localhost:3000'
          cmd_options: '-a'  # Ajax Spider
```

---

## まとめ: この構成で ZAP を使う際の優先確認事項

| 優先度 | 確認事項 |
|-------|---------|
| 🔴 高 | OpenAPI 定義ファイルを用意して API を網羅的にスキャンする |
| 🔴 高 | JSON ボディへのインジェクションテストを有効化する |
| 🔴 高 | JWT 認証の期限切れ対策を設定する |
| 🟡 中 | Ajax Spider を有効化して React SPA をクロールする |
| 🟡 中 | Flutter のプロキシ設定と CA 証明書インストールを行う |
| 🟡 中 | Docker ネットワーク設定でコンテナ間の疎通を確保する |
| 🟢 低 | 証明書ピンニングの無効化ビルドを用意する |
