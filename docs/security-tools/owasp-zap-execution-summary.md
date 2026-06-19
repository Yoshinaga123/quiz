# OWASP ZAP — 実施内容まとめ

## テスト概要

| 項目 | 内容 |
|------|------|
| ツール名 | OWASP ZAP (Zed Attack Proxy) |
| バージョン | `docker inspect ghcr.io/zaproxy/zaproxy:stable` で確認 |
| 実施日 | YYYY-MM-DD |
| 実施者 | |
| 対象システム | Go バックエンド (Gin) + React フロントエンド |
| 対象 URL | http://localhost:8080 |
| 実施環境 | ローカル開発環境 / Docker |

---

## 実施したテストの一覧

### 1. パッシブスキャン (自動・無害)

対象 URL にブラウザでアクセスしながら、ZAP プロキシを経由させてレスポンスを自動分析する。改ざんや攻撃リクエストを送らず、返ってきたレスポンスのみを検査する。

**実施手順**:
```
ZAP 起動 → ブラウザプロキシ設定 → 対象サイトを手動操作
→ Alerts タブでパッシブスキャン結果を確認
```

**検査項目**:
- セキュリティヘッダの欠如 (X-Content-Type-Options, CSP, HSTS 等)
- Cookie の Secure / HttpOnly フラグ欠如
- 情報漏洩 (サーババージョン、エラー詳細)
- HTTP のみの通信 (HTTPS 未使用)

---

### 2. Spider (クローリング)

対象サイトのリンク・フォーム・API エンドポイントを自動収集する。

**実施手順**:
```
ZAP GUI: 自動スキャン → Spider 実行
ZAP API: POST /JSON/spider/action/scan/
```

**実施コマンド**:
```bash
curl "http://localhost:8080/JSON/spider/action/scan/?url=http://target:8080&apikey=zapkey123"
```

**確認項目**:
- 発見されたエンドポイント数
- 認証が必要なページが正しく収集されているか
- フォームパラメータの収集状況

---

### 3. Ajax Spider (SPA 対応クローリング)

React Router による動的ページ遷移を追跡してエンドポイントを収集する。

**実施手順**:
```
ZAP GUI: Tools → Ajax Spider → ターゲット URL を指定 → Start Scan
```

**確認項目**:
- React Router のルートが探索されているか
- JavaScript 実行後のコンテンツが収集されているか

---

### 4. アクティブスキャン (自動攻撃テスト)

収集したエンドポイントに対して、実際に攻撃ペイロードを送信して脆弱性を検出する。

**実施手順**:
```bash
# スキャン開始
curl "http://localhost:8080/JSON/ascan/action/scan/?url=http://target:8080&apikey=zapkey123"

# 進捗確認
curl "http://localhost:8080/JSON/ascan/view/status/?scanId=0&apikey=zapkey123"
```

**検査項目**:

| カテゴリ | 検査内容 |
|---------|---------|
| インジェクション | SQL インジェクション、コマンドインジェクション、LDAP インジェクション |
| XSS | 反射型 XSS、ストアード XSS |
| パストラバーサル | ディレクトリトラバーサル |
| SSRF | サーバサイドリクエストフォージェリ |
| 認証・認可 | 強制ブラウジング |
| セキュリティ設定 | デフォルト認証情報、不要な HTTP メソッド |

---

### 5. SQL インジェクション 詳細検証

**実施手順**:
```
対象: GET /api/users?id=1
方法: ZAP Fuzzer でペイロードを送信
      Boolean テスト (1 AND 1=1-- / 1 AND 1=2--)
      時間ベーステスト (pg_sleep(5))
```

**使用ペイロード例**:
```
1'
1 AND 1=1--
1 AND 1=2--
1 UNION SELECT NULL--
1; SELECT pg_sleep(5)--
```

**判定基準**:
- Boolean テストでレスポンスに差異あり → SQLi 確定
- 時間ベーステストで 5 秒以上遅延 → Blind SQLi 確定

---

### 6. DoS / レートリミット検証

**実施手順**:
```
ZAP Fuzzer を使用して POST /api/login に 200 回連続でリクエストを送信
→ HTTP 429 が返ればレートリミットあり
→ すべて 401 であればレートリミットなし
```

**実施コマンド**:
```bash
for i in $(seq 1 100); do
  curl -s -o /dev/null -w "%{http_code}\n" \
    -X POST http://localhost:8080/api/login \
    -H "Content-Type: application/json" \
    -d '{"username":"test","password":"wrong"}'
done
```

---

### 7. レポート生成

**実施手順**:
```bash
# HTML レポート出力
curl "http://localhost:8080/OTHER/core/other/htmlreport/?apikey=zapkey123" \
  -o zap_report.html

# JSON レポート出力
curl "http://localhost:8080/OTHER/core/other/jsonreport/?apikey=zapkey123" \
  -o zap_report.json
```

---

## 実施結果サマリ (記入欄)

| リスクレベル | 件数 | 主な脆弱性 |
|-------------|------|-----------|
| High | | |
| Medium | | |
| Low | | |
| Informational | | |

---

## 未実施・対象外の項目

| 項目 | 理由 |
|------|------|
| OOB (帯域外) SQLi | ZAP に DNS コールバック機能なし。Burp Suite Professional で補完 |
| ネットワーク層 DoS | アプリケーション層の検査のみ対象 |
| モバイルアプリ内部 | プロキシ経由の通信のみ対象 |
