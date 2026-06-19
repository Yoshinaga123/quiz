# Burp Suite で検査できる脆弱性と強み

## 概要

Burp Suite は手動テストと自動スキャンを高度に統合したプラットフォームです。  
単なる脆弱性スキャナではなく「テスターの操作を拡張するツール」として設計されており、OWASP ZAP や w3af と比べて **手動テストの精度・効率** が際立った強みです。

| スキャン種別 | 説明 |
|------------|------|
| **パッシブスキャン** | プロキシ通信を観察して自動検出 (Community でも動作) |
| **アクティブスキャン** | 攻撃リクエストを送信して検出 (Professional / Enterprise のみ) |
| **手動テスト** | Repeater・Intruder などを使った人手による検証 |

---

## OWASP Top 10 対応状況

| # | カテゴリ | Burp Suite での検出 |
|---|---------|-------------------|
| A01 | アクセス制御の不備 | ◎ (Autorize 拡張で強力に対応) |
| A02 | 暗号化の失敗 | ◎ |
| A03 | インジェクション | ◎ |
| A04 | 安全でない設計 | ○ (手動テストで対応) |
| A05 | セキュリティの設定ミス | ◎ |
| A06 | 脆弱なコンポーネント | ○ (拡張機能で対応) |
| A07 | 認証・セッション管理の失敗 | ◎ |
| A08 | ソフトウェアとデータの整合性の失敗 | ○ (JWT Editor 等で対応) |
| A09 | セキュリティログ・監視の失敗 | ✕ |
| A10 | SSRF | ◎ (Burp Collaborator で帯域外検出) |

---

## Burp Suite ならではの強み

### 1. Burp Collaborator による帯域外 (OOB) 検出

通常のスキャンでは検出できない **盲目的 (Blind) な脆弱性** を外部サーバへのコールバックで検出します。

- Blind SQL インジェクション
- Blind XXE
- Blind SSRF
- Blind OS Command インジェクション
- DNS リバインディング攻撃の検証

```
攻撃者(Burp) → ターゲットサーバ → Burp Collaborator サーバ
                                ↑ DNS/HTTP コールバックで脆弱性を確認
```

### 2. Intruder による高精度ファジング

パラメータに対して大量のペイロードを送り込み、レスポンスの差異から脆弱性を検出します。

| アタックタイプ | 用途 |
|-------------|------|
| Sniper | 1 つのパラメータに対してペイロードを順番に送信 |
| Battering ram | 全パラメータに同じペイロードを同時に送信 |
| Pitchfork | 複数パラメータにそれぞれ別のペイロードリストを使用 |
| Cluster bomb | 全パラメータの組み合わせ網羅 |

> Community 版は速度制限あり。Professional では制限なし。

### 3. Repeater による精密な手動テスト

1 つのリクエストを自由に編集・繰り返し送信できます。

- パラメータ値の細かな変更
- ヘッダの追加・削除
- エンコード形式の変換 (URL / Base64 / HTML など)
- レスポンスの差分を即座に確認

### 4. Scanner の高精度自動スキャン (Professional)

- 機械学習ベースのペイロード最適化
- JavaScript の動的解析による DOM XSS 検出
- 認証状態を維持したままのスキャン
- スキャン設定のカスタマイズ (速度・深度・対象パス の制御)

---

## インジェクション系

### SQL インジェクション
- エラーベース・ブラインド・時間ベース・帯域外 (OOB) SQL インジェクション
- **強み**: Collaborator を使った Blind SQLi の自動検出
- **スキャン種別**: アクティブ (Pro) / 手動 (Community)

### コマンドインジェクション
- Unix / Windows コマンドの注入
- Blind コマンドインジェクションも Collaborator で検出
- **スキャン種別**: アクティブ (Pro) / 手動 (Community)

### Server-Side Template Injection (SSTI)
- Jinja2, Freemarker, Thymeleaf, Pebble など多数のエンジンに対応
- **スキャン種別**: アクティブ (Pro) / 手動 (Community)

### LDAP / XPath / Header インジェクション
- **スキャン種別**: アクティブ (Pro)

---

## クロスサイトスクリプティング (XSS)

### 反射型 XSS
- HTML コンテキスト・属性・JavaScript 内など多様なコンテキストに対応
- **スキャン種別**: アクティブ (Pro) / 手動 (Community)

### 格納型 XSS
- スキャン後に別リクエストでコールバックを確認する2段階検出
- **スキャン種別**: アクティブ (Pro)

### DOM ベース XSS
- JavaScript エンジンによる動的解析で検出精度が高い
- **強み**: 他ツールより DOM XSS の検出精度が高い
- **スキャン種別**: アクティブ (Pro)

---

## 認証・セッション管理

### CSRF
- トークンの欠如・予測可能なトークンを検出
- **スキャン種別**: アクティブ (Pro) / 手動 (Community)

### セッション管理の問題
- Sequencer ツールでトークンのエントロピーを統計的に分析
- **強み**: トークンのランダム性を数値で評価できる唯一の主要ツール

### JWT の脆弱性 (JWT Editor 拡張)
- `alg: none` 攻撃
- 署名検証スキップ
- 弱い秘密鍵によるブルートフォース
- RS256 → HS256 アルゴリズム混乱攻撃

### 認可の不備 / IDOR (Autorize 拡張)
- 2 ユーザのセッションを並列で比較し、権限外アクセスを自動検出
- **強み**: IDOR は他の主要ツールでは自動検出が難しいが Autorize で半自動化可能

---

## SSRF / XXE

### SSRF
- Collaborator を使った帯域外コールバックで Blind SSRF も検出
- **強み**: DNS コールバックを使うため、レスポンスに何も返らない Blind SSRF を確実に検出

### XXE
- エラーベース・帯域外 XXE を検出
- **スキャン種別**: アクティブ (Pro) / 手動 (Community)

---

## セキュリティ設定ミス

### セキュリティヘッダの不備
- `Content-Security-Policy`, `HSTS`, `X-Frame-Options` などの欠如を検出
- **スキャン種別**: パッシブ (Community でも動作)

### TLS / SSL の問題
- 弱い暗号スイート・旧プロトコルの使用を検出
- **スキャン種別**: パッシブ

### 情報漏洩
- レスポンスヘッダ・エラーメッセージ・HTML コメント内のサーバ情報
- **スキャン種別**: パッシブ (Community でも動作)

---

## ファイル・パス操作

### パストラバーサル / LFI / RFI
- **スキャン種別**: アクティブ (Pro) / 手動 (Community)

---

## 主要拡張機能 (BApp Store) と対応脆弱性

| 拡張機能 | 対応する脆弱性・用途 |
|---------|------------------|
| **Autorize** | IDOR・認可の不備の半自動検出 |
| **JWT Editor** | JWT の脆弱性検証 |
| **Logger++** | 高機能ログ記録・フィルタリング |
| **Param Miner** | 隠しパラメータ・キャッシュポイズニングの発見 |
| **Turbo Intruder** | 高速ファジング・レースコンディション検証 |
| **CSRF Scanner** | CSRF トークンの網羅的チェック |
| **Active Scan++** | スキャナの検出精度向上 |
| **Retire.js** | 脆弱な JavaScript ライブラリの検出 |

---

## Burp Suite では検出が難しい / できない脆弱性

| 脆弱性 | 理由 |
|--------|------|
| ビジネスロジックの欠陥 | 仕様の理解が必要。手動テストで対応 |
| サプライチェーン攻撃 | 依存ライブラリの静的解析が必要 |
| セキュリティログ・監視の失敗 | サーバ側の設定確認が必要 |
| インフラ脆弱性 | ネットワーク・OS レイヤは対象外 |

---

## 他ツールとの比較まとめ

| 観点 | OWASP ZAP | w3af | Burp Suite Pro |
|------|-----------|------|----------------|
| Blind 脆弱性の検出 | △ | △ | ◎ (Collaborator) |
| DOM XSS の検出精度 | ○ | △ | ◎ |
| IDOR の半自動検出 | ✕ | ✕ | ◎ (Autorize) |
| JWT 攻撃の検証 | △ | ✕ | ◎ (JWT Editor) |
| セッションエントロピー分析 | ✕ | ✕ | ◎ (Sequencer) |
| レースコンディション検証 | ✕ | ✕ | ○ (Turbo Intruder) |
| CI/CD 連携 | ◎ | ○ | ○ (Enterprise) |
| 無料で使えるか | ◎ | ◎ | △ (Community のみ) |

---

## 参考リンク

- [Burp Suite ドキュメント](https://portswigger.net/burp/documentation)
- [PortSwigger Web Security Academy](https://portswigger.net/web-security)
- [BApp Store](https://portswigger.net/bappstore)
- [OWASP Top 10 (2021)](https://owasp.org/Top10/)
