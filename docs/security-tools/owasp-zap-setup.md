# OWASP ZAP セットアップ手順

## 動作環境

- Java 11 以上
- Windows / macOS / Linux

---

## 1. インストール

### パッケージマネージャ経由 (推奨)

**Linux (snap)**
```bash
sudo snap install zaproxy --classic
```

**macOS (Homebrew)**
```bash
brew install --cask owasp-zap
```

**Windows (winget)**
```powershell
winget install OWASP.ZAP
```

### 公式インストーラ

1. [https://www.zaproxy.org/download/](https://www.zaproxy.org/download/) からインストーラをダウンロード
2. プラットフォームに合わせたインストーラを実行

### Docker

```bash
docker pull ghcr.io/zaproxy/zaproxy:stable
```

---

## 2. 初回起動

```bash
# GUI 起動
zaproxy

# または Docker で起動
docker run -u zap -p 8080:8080 ghcr.io/zaproxy/zaproxy:stable zap.sh -daemon \
  -host 0.0.0.0 -port 8080 \
  -config api.addrs.addr.name=.* \
  -config api.addrs.addr.regex=true
```

初回起動時に「自動更新チェック」ダイアログが表示されます。アドオンを最新化することを推奨します。

---

## 3. ブラウザのプロキシ設定

ZAP はデフォルトで `localhost:8080` でリッスンします。

### Firefox

1. 設定 → ネットワーク設定 → 接続設定
2. 手動でプロキシを設定
   - HTTP プロキシ: `127.0.0.1`、ポート: `8080`
3. ZAP の CA 証明書をインポート:
   - ZAP メニュー → ツール → オプション → ダイナミック SSL 証明書 → 保存
   - Firefox: 設定 → プライバシーとセキュリティ → 証明書を表示 → インポート

### ZAP 組み込みブラウザ (簡単)

ZAP ツールバーの「Firefox アイコン」をクリックすると、証明書設定済みのブラウザが直接起動します。

---

## 4. スキャンの実行

### クイックスキャン (GUI)

1. 「自動スキャン」をクリック
2. ターゲット URL を入力
3. 「攻撃」ボタンをクリック

### コマンドライン (Baseline スキャン)

```bash
docker run --rm ghcr.io/zaproxy/zaproxy:stable zap-baseline.py \
  -t https://example.com \
  -r report.html
```

### API 経由でのスキャン

```bash
# スパイダースキャン開始
curl "http://localhost:8080/JSON/spider/action/scan/?url=https://example.com&apikey=your-api-key"

# アクティブスキャン開始
curl "http://localhost:8080/JSON/ascan/action/scan/?url=https://example.com&apikey=your-api-key"
```

---

## 5. CI/CD 連携 (GitHub Actions 例)

```yaml
- name: ZAP Baseline Scan
  uses: zaproxy/action-baseline@v0.12.0
  with:
    target: 'https://example.com'
    rules_file_name: '.zap/rules.tsv'
    cmd_options: '-a'
```

---

## 6. レポート出力

```bash
# HTML レポート
zap-cli report -o report.html -f html

# XML レポート (CI/CD 向け)
zap-cli report -o report.xml -f xml
```

---

## 注意事項

- スキャン対象は **自分が管理するシステム** または **明示的に許可されたシステム** のみに限定すること
- 本番環境への自動スキャンは事前に関係者の承認を得ること

---

## 作業ログ

### 2026-05-29 — 初回セットアップ実施

#### 環境確認

```bash
$ docker --version && docker info --format '{{.ServerVersion}}'
Docker version 29.3.1, build c2be9cc
29.3.1
```

#### イメージ取得

```bash
$ docker pull ghcr.io/zaproxy/zaproxy:stable
stable: Pulling from zaproxy/zaproxy
...（各レイヤーのダウンロード・展開）...
Digest: sha256:2ec1d5d5b44d55cfd02ba9b89cd26852f06d92b7fc0ce9f064b9463babc73074
Status: Downloaded newer image for ghcr.io/zaproxy/zaproxy:stable
ghcr.io/zaproxy/zaproxy:stable
```

#### デーモン起動 & API 疎通確認

```bash
$ docker run --rm -d --name zap-test \
  -u zap \
  -p 8090:8090 \
  ghcr.io/zaproxy/zaproxy:stable zap.sh -daemon \
  -host 0.0.0.0 -port 8090 \
  -config api.addrs.addr.name=.* \
  -config api.addrs.addr.regex=true \
  -config api.key=zaptest123
968492b3686261b980a0199754a30d3f51dfa2dccf8e9f84e070d95999e0cdf7

$ curl -s "http://localhost:8090/JSON/core/view/version/?apikey=zaptest123"
{"version":"2.17.0"}

$ docker stop zap-test
zap-test
```

**結果:** 問題なし。ZAP 2.17.0 が正常起動・API 応答を確認。

> **備考:**
> - ポートは手順書記載の `8080` ではなく `8090` を使用（ホスト側の競合回避）
> - API キーは検証用の固定値 `zaptest123` を使用（本番運用時は変更すること）
