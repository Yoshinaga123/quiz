# OWASP ZAP — 検証記録
---

## OWASP ZAP とは

世界最大のセキュリティ団体 **OWASP** が開発・公開しており、完全無償で使えます。

---

## このツールの利点

最近読んだオライリーの書籍で推奨されていたため候補に挙げた。  
主要なスキャナのなかで**すべての機能が無償で使える唯一のツール**であり、ライセンス費用がかからない。

---

## 基本情報

| 項目 | 内容 |
|---|---|
| ライセンス | Apache 2.0（商用・非商用を問わず無償で使用・改変・再配布可能） |
| 開発元 | OWASP / Software Security Project |
| メンテナンス状況 | 活発（2025 年も定期リリースあり） |
| 動作環境 | Linux / macOS / Windows / Docker |
| 主な用途 | 自動スキャン・CI/CD 統合・教育目的 |

---

## フルスキャンの流れ（`zap-full-scan.py`）

今回実行したのは**フルスキャン**です。API の仕様書を使うのではなく、ZAP 自身がサイトを探索しながら脆弱性を調べます。

```
① Spider（クローリング）
   対象サイトのリンクを辿って、存在するページや API の窓口を自動で洗い出す
        ↓
② Ajax Spider
   JavaScript で動的に生成されるページも追加で探索する
   （通常の Spider では見つけられないページに対応）
        ↓
③ Passive Scan（受動スキャン）
   探索中に受け取ったレスポンスを分析する
   ※ 攻撃リクエストは送らず、返ってきた内容を観察するだけ
        ↓
④ Active Scan（能動スキャン）
   見つかった窓口それぞれに、悪意のあるリクエストを実際に送信する
   （SQL インジェクション・XSS などの攻撃パターンを試す）
        ↓
⑤ レポート生成
   検出された問題をまとめて HTML / JSON 形式で出力する
```

**API スキャン（`zap-api-scan.py`）との違い:**  
API スキャンは OpenAPI などの仕様ファイルを読んでエンドポイントを列挙する。  
フルスキャンは仕様ファイルなしでサイトを自力で探索するため、より広範囲をカバーできる一方、認証が必要なページは探索できない。

---

## 得意なこと・苦手なこと

### 得意なこと ✓

- **予算ゼロで本格的なスキャンができる**
- **CI/CD への自動組み込みが最も簡単**  
  → CI/CD とは「コードを変更するたびに自動でテストやチェックを行う仕組み」のこと。  
    GitHub Actions などに数行書くだけで、プルリクエストのたびに自動スキャンできる。

  ```yaml
  # GitHub Actions での組み込み例
  - uses: zaproxy/action-api-scan@v0.7.0
    with:
      target: 'http://localhost:8080/openapi.json'
  ```

- **OpenAPI スキャン**  
  → OpenAPI とは「API の仕様を記述する標準的なフォーマット」のこと。  
    仕様ファイルがあればエンドポイントを自動で列挙してスキャンできる。

- **JavaScript で動くページも探索できる**  
  React Router / Vue Router で生成されるページを「Ajax Spider」という機能で追跡できる。  
  （Ajax Spider = JavaScript によるページ遷移を理解して探索するクローラー）

### 苦手なこと ✗

- **手動でリクエストを改ざん・再送するような細かい操作は Burp Suite の方が使いやすい**  
  → ペネトレーションテスト専門家には Burp Suite が業界標準とされている。

- **間接的な脆弱性（OOB 系）の検出は困難**  
  → OOB（Out-of-Band）とは「攻撃の結果が直接の返答には現れず、外部サーバーを経由して初めてわかる」タイプの脆弱性のこと。  
    Blind SSRF・Blind SQLi・OOB XXE などがこれに該当する。

---

## ZAP を選ぶ基準

| 状況 | 判断 |
|---|---|
| 予算がない | **ZAP を採用** |
| CI/CD に自動組み込みたい | **ZAP を採用** |
| OpenAPI 定義でスキャンしたい | **ZAP を採用** |
| 手動ペネトレーションテストを実施したい | 見送り（Burp Suite を検討） |
| Blind SSRF など間接的な脆弱性を検出したい | 見送り（Burp Suite Pro などを検討） |

---

## 導入方法

### Docker（本プロジェクトで採用）

```bash
# イメージの取得
docker pull ghcr.io/zaproxy/zaproxy:stable

# CLI（画面なし）でバックグラウンド起動
docker run -u zap -p 8080:8080 ghcr.io/zaproxy/zaproxy:stable zap.sh -daemon \
  -host 0.0.0.0 -port 8080 \
  -config api.addrs.addr.name=.* \
  -config api.addrs.addr.regex=true
```

> `-daemon` オプション = GUI（操作画面）なしでバックグラウンドだけで動くモード。  
> サーバー上やスクリプトからの自動実行に使う。

### Linux（snap）

```bash
sudo snap install zaproxy --classic
# --classic = システムへの完全アクセスを許可するオプション
zaproxy  # GUI 起動
```

### レポート出力

```bash
zap-cli report -o report.html -f html   # HTML レポート（人が読む用）
zap-cli report -o report.xml  -f xml    # XML レポート（CI/CD ツールが読む用）
```

---

## スキャン実施記録

### 実行環境

- スキャン対象: このプロジェクトの Go バックエンド (`http://localhost:8082`)
- スキャン種別: フルスキャン（`zap-full-scan.py`）
- 実行方法: `--network host` でホストのポートに直接接続

```bash
docker run --rm \
  --network host \
  -v /home/yoshinaga_kosuke/workspace/quiz/reports:/zap/wrk \
  ghcr.io/zaproxy/zaproxy:stable \
  zap-full-scan.py \
  -t http://localhost:8082 \
  -r report.html \
  -J report.json
```

### 結果サマリー

| 判定 | 件数 | 意味 |
|---|---|---|
| PASS | 139 | 問題なし |
| WARN-NEW | **3 種** | 注意が必要な項目 |
| FAIL | 0 | 重大な問題なし |

---

### 検出された警告の詳細

#### 1. X-Content-Type-Options ヘッダーがない [10021] — 4 URL

**かんたんに言うと:**  
ブラウザが「このファイルは何の種類か」を勝手に判断しないようにする設定が抜けている。

**技術的な説明:**  
レスポンスヘッダーに `X-Content-Type-Options: nosniff` がない。  
これがないと、ブラウザが HTML 以外のファイル（例: テキストファイル）を HTML として解釈して実行してしまう MIME スニッフィングという攻撃を受ける可能性がある。

**対象 URL:** `/`, `/sitemap.xml`, `/robots.txt` など 4 箇所  
**対処:** Go の HTTP ハンドラーでレスポンスヘッダーに `X-Content-Type-Options: nosniff` を追加する。

---

#### 2. CORS の設定ミス [40040] — 4 URL

**かんたんに言うと:**  
「どのウェブサイトからのアクセスを許可するか」のルールが緩すぎる可能性がある。

**技術的な説明:**  
CORS（Cross-Origin Resource Sharing）とは、異なるドメイン（例: `app.example.com` と `api.example.com`）間でデータをやり取りするときの許可ルールのこと。  
`Access-Control-Allow-Origin` の設定が過度に広いと、悪意のある第三者サイトからの API 呼び出しを許してしまう。

**対象 URL:** `/`, `/robots.txt` など 4 箇所  
**対処:** CORS の許可オリジンを必要最小限のドメインだけに絞る。

---

#### 3. Spring Actuator の情報漏えい [40042] — 1 URL  誤検知の可能性あり

**かんたんに言うと:**  
「Spring Boot」という別のフレームワーク向けの診断エンドポイントが公開されている、という警告だが、**このプロジェクトは Go 製なので誤検知の可能性が高い**。

**技術的な説明:**  
ZAP が `/actuator/health` に 200 OK のレスポンスを確認し、Spring Boot の管理エンドポイントと誤認した。  
実際は `/health` という名前の Go の独自ヘルスチェックエンドポイントが反応しただけ。  
Spring Boot は使っていないため、Spring Actuator 固有のリスク（詳細な環境情報の漏えいなど）は該当しない。

**対処:** 誤検知として記録。ただし `/health` エンドポイントが外部から叩けることは事実なので、認証なしで公開する情報の範囲は確認しておく。

---

### レポートファイル

| ファイル | 場所 |
|---|---|
| HTML レポート（人が読む用） | `reports/report.html` |
| JSON レポート（ツールが読む用） | `reports/report.json` |
