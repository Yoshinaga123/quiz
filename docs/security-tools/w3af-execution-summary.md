# w3af — 実施内容まとめ

## テスト概要

| 項目 | 内容 |
|------|------|
| ツール名 | w3af (Web Application Attack and Audit Framework) |
| バージョン | `docker run andresriancho/w3af ./w3af_console --version` で確認 |
| 実施日 | YYYY-MM-DD |
| 実施者 | |
| 対象システム | Go バックエンド (Gin) + React フロントエンド |
| 対象 URL | http://localhost:8080 |
| 実施環境 | Docker (andresriancho/w3af) |

> **前提**: w3af はメンテナンスが低調であり、JSON ボディや SPA の検出精度が低い。本テストでは URL パラメータを中心に検査を行い、JSON API については ZAP / Burp Suite で補完する。

---

## 実施したテストの一覧

### 1. 環境準備・起動確認

**実施手順**:
```bash
docker run -it --network host andresriancho/w3af ./w3af_console
```

**確認項目**:
- コンソールが正常に起動するか
- 対象 URL に疎通できるか (`ping` 相当の HTTP 確認)

---

### 2. SQL インジェクション (URL パラメータ)

URL クエリパラメータに SQL インジェクションペイロードを送信して脆弱性を検出する。

**使用プラグイン**: `audit/sqli`, `audit/blind_sqli`

**実施手順**:
```
w3af>>> plugins
w3af/plugins>>> audit sqli blind_sqli
w3af/plugins>>> crawl web_spider
w3af/plugins>>> output console html_file
w3af/plugins>>> output config html_file
w3af/plugins/output/config:html_file>>> set output_file /tmp/sqli_report.html
w3af/plugins/output/config:html_file>>> back
w3af/plugins>>> back
w3af>>> target
w3af/config:target>>> set target http://localhost:8080/api/users?id=1
w3af/config:target>>> back
w3af>>> start
```

**検査対象エンドポイント**:

| エンドポイント | パラメータ | メソッド |
|--------------|-----------|---------|
| /api/users | id | GET |
| /api/products | category | GET |
| /api/search | q | GET |

**判定基準**:
- `sqli` プラグインが `[High]` アラートを出力 → SQLi 確定
- `blind_sqli` プラグインが時間差を検出 → Blind SQLi 確定

---

### 3. ReDoS (正規表現 DoS)

悪意のある正規表現入力によってサーバ CPU を枯渇させる脆弱性を検出する。

**使用プラグイン**: `audit/redos`

**実施手順**:
```
w3af>>> plugins
w3af/plugins>>> audit redos
w3af/plugins>>> crawl web_spider
w3af/plugins>>> back
w3af>>> target
w3af/config:target>>> set target http://localhost:8080/api/search?q=test
w3af/config:target>>> back
w3af>>> start
```

**手動補完テスト**:
```bash
# 通常入力
time curl -s "http://localhost:8080/api/search?q=hello"

# ReDoS ペイロード (長さを段階的に増やして応答時間の増加を確認)
time curl -s "http://localhost:8080/api/search?q=aaaaaaaaaaaaaaaaaaaaaaaaaab"
time curl -s "http://localhost:8080/api/search?q=aaaaaaaaaaaaaaaaaaaaaaaaaaaaaab"
```

**判定基準**:
- 応答時間が入力長に対して指数的に増加 → ReDoS 確定
- `redos` プラグインが応答時間比 100 倍以上を検出 → ReDoS 確定

---

### 4. XSS (クロスサイトスクリプティング)

URL パラメータに JavaScript を含むペイロードを挿入して XSS を検出する。

**使用プラグイン**: `audit/xss`

**実施手順**:
```
w3af>>> plugins
w3af/plugins>>> audit xss
w3af/plugins>>> crawl web_spider
w3af/plugins>>> back
w3af>>> target
w3af/config:target>>> set target http://localhost:8080
w3af/config:target>>> back
w3af>>> start
```

**検査対象エンドポイント**:

| エンドポイント | パラメータ | メソッド |
|--------------|-----------|---------|
| /api/search | q | GET |
| /api/users | name | GET |

---

### 5. バッファオーバーフロー / 大きな入力

大きな入力値を送信してサーバのメモリ・CPU リソースを枯渇させる脆弱性を検出する。

**使用プラグイン**: `audit/buffer_overflow`

**実施手順**:
```
w3af>>> plugins
w3af/plugins>>> audit buffer_overflow
w3af/plugins>>> crawl web_spider
w3af/plugins>>> back
w3af>>> start
```

**手動補完テスト**:
```bash
for SIZE in 1000 10000 100000 1000000; do
  CODE=$(curl -s -o /dev/null -w "%{http_code}" \
    "http://localhost:8080/api/search?q=$(python3 -c "print('A'*$SIZE")")
  echo "Size: $SIZE → HTTP $CODE"
done
```

**判定基準**:
- HTTP 400 / 413 が返る → 入力長制限あり (正常)
- HTTP 200 かつ応答が遅延 → 入力長制限なし (脆弱)
- HTTP 500 → サーバエラー誘発 (脆弱)

---

### 6. エラーページ情報漏洩

エラーレスポンスにサーバ内部情報 (スタックトレース、DBエラー等) が含まれないかを確認する。

**使用プラグイン**: `grep/error_pages`

**実施手順**:
```
w3af>>> plugins
w3af/plugins>>> grep error_pages
w3af/plugins>>> back
w3af>>> start
```

**確認項目**:
- SQL エラーメッセージの露出
- Go のスタックトレースの露出
- ファイルパスの露出

---

### 7. レポート生成

**実施手順**:
```
w3af>>> plugins
w3af/plugins>>> output html_file
w3af/plugins>>> output config html_file
w3af/plugins/output/config:html_file>>> set output_file /tmp/w3af_report.html
w3af/plugins/output/config:html_file>>> back
w3af/plugins>>> back
```

スキャン終了後:
```bash
# Docker ボリュームからレポートを取り出す
docker cp w3af_container:/tmp/w3af_report.html ./w3af_report.html
```

---

## 実施結果サマリ (記入欄)

| 脆弱性カテゴリ | 検出件数 | 対象エンドポイント |
|--------------|---------|-----------------|
| SQL インジェクション | | |
| Blind SQL インジェクション | | |
| ReDoS | | |
| XSS | | |
| バッファオーバーフロー | | |
| エラーページ情報漏洩 | | |

---

## 未実施・対象外の項目

| 項目 | 理由 |
|------|------|
| JSON ボディへの注入テスト | w3af の JSON ボディ注入精度が低いため ZAP / Burp Suite で補完 |
| SPA (React) のクローリング | Ajax Spider 相当機能なし。ZAP の Ajax Spider を使用 |
| OOB 脆弱性 | DNS コールバック機能なし。Burp Suite Professional で補完 |
| 認証が必要なエンドポイント | JWT 設定が複雑なため、手動テストまたは Burp Suite で補完 |
