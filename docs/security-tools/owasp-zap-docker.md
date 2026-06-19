# OWASP ZAP — Docker コンテナ構成

## 概要

ZAP は公式 Docker イメージが提供されており、コンテナでの運用が最も成熟している。GUI なしでバックグラウンド常駐モード (デーモンモード) で動作し、REST API 経由で完全に操作できる。

---

## 公式イメージ

```bash
# 安定版
docker pull ghcr.io/zaproxy/zaproxy:stable

# 最新版 (weekly ビルド)
docker pull ghcr.io/zaproxy/zaproxy:weekly
```

---

## 起動パターン

### パターン 1: バックグラウンド常駐モード・デーモンモード (CI/CD・API 操作向け)

```bash
docker run -u zap -d \
  --name zap \
  -p 8080:8080 \
  ghcr.io/zaproxy/zaproxy:stable \
  zap.sh -daemon \
  -host 0.0.0.0 \
  -port 8080 \
  -config api.addrs.addr.name=.* \
  -config api.addrs.addr.regex=true \
  -config api.key=zapkey123
```

起動確認:
```bash
curl "http://localhost:8080/JSON/core/view/version/?apikey=zapkey123"
# → {"version":"2.x.x"}
```

### パターン 2: フルスキャン (ワンショット実行)

```bash
docker run --rm \
  -v $(pwd)/reports:/zap/wrk \
  ghcr.io/zaproxy/zaproxy:stable \
  zap-full-scan.py \
  -t http://target:8080 \
  -r report.html \
  -J report.json
```

### パターン 3: API スキャン (OpenAPI 定義を使用)

```bash
docker run --rm \
  -v $(pwd)/reports:/zap/wrk \
  ghcr.io/zaproxy/zaproxy:stable \
  zap-api-scan.py \
  -t http://target:8080/openapi.json \
  -f openapi \
  -r api_report.html
```

---

## Docker Compose での構成

対象の Go API と ZAP を同じネットワークで起動する。

```yaml
# docker-compose.zap.yml
services:
  go-api:
    build: ./backend
    ports:
      - "8080:8080"
    networks:
      - scan-net

  zap:
    image: ghcr.io/zaproxy/zaproxy:stable
    user: zap
    command: >
      zap.sh -daemon
      -host 0.0.0.0
      -port 8090
      -config api.addrs.addr.name=.*
      -config api.addrs.addr.regex=true
      -config api.key=zapkey123
    ports:
      - "8090:8090"
    networks:
      - scan-net
    depends_on:
      - go-api

networks:
  scan-net:
```

```bash
docker compose -f docker-compose.zap.yml up -d

# ZAP から Go API をスキャン (Docker 内部 DNS 名で指定)
curl "http://localhost:8090/JSON/ascan/action/scan/?url=http://go-api:8080&apikey=zapkey123"
```

---

## GitHub Actions での使用

```yaml
name: ZAP Scan

on: [push]

jobs:
  zap-scan:
    runs-on: ubuntu-latest
    services:
      go-api:
        image: your-registry/go-api:latest
        ports:
          - 8080:8080

    steps:
      - uses: actions/checkout@v4

      - name: ZAP API Scan
        uses: zaproxy/action-api-scan@v0.7.0
        with:
          target: 'http://localhost:8080/openapi.json'
          format: openapi
          fail_action: true

      - name: Upload Report
        uses: actions/upload-artifact@v4
        with:
          name: zap-report
          path: report_html.html
```

---

## レポートの取り出し

```bash
# バックグラウンド常駐モード (デーモンモード) からレポートを取得
curl "http://localhost:8080/OTHER/core/other/htmlreport/?apikey=zapkey123" \
  -o zap_report.html

# ボリュームマウントしている場合
docker run --rm \
  -v $(pwd)/reports:/zap/wrk \
  ghcr.io/zaproxy/zaproxy:stable \
  zap-full-scan.py -t http://target:8080 -r /zap/wrk/report.html
```

---

## コンテナ運用上の注意点

| 項目 | 注意内容 |
|------|---------|
| ユーザ | `-u zap` を必ず指定。root で動かさない |
| API キー | `api.key` を必ず設定。デフォルト無効化は危険 |
| ネットワーク | 対象サービスと同一 Docker ネットワークに参加させる |
| メモリ | 大規模スキャン時は `--memory 2g` などの制限を設定 |
| ポート公開 | CI 環境では外部公開不要。`--expose` のみでよい場合あり |
