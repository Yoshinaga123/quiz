# OWASP ZAP — ツール選定基準

## このファイルの目的

OWASP ZAP を選ぶべき状況・選ぶべきでない状況を整理し、意思決定の根拠を明確にする。

---

## ZAP の基本プロファイル

| 項目 | 内容 |
|------|------|
| ライセンス | Apache 2.0 (完全無償) |
| 開発元 | OWASP / Software Security Project |
| 最終更新 | 活発にメンテナンスされている (2025年も定期リリース) |
| 動作環境 | Linux / macOS / Windows / Docker |
| 主な用途 | 自動スキャン・CI/CD 統合・教育目的 |
| 習得難易度 | ★★☆☆☆ (初心者でも始めやすい) |

---

## ZAP を選ぶべき条件

### 1. コストが最優先のプロジェクト

```
✓ 予算がない個人・スタートアップ・OSS プロジェクト
✓ すべての機能が無償で使える唯一の主要スキャナ
✓ ライセンスコストをかけずにチーム全員が使える
```

### 2. CI/CD パイプラインへの自動統合

```
✓ GitHub Actions / GitLab CI / Jenkins への組み込みが最も容易
✓ 公式 GitHub Actions (zaproxy/action-full-scan 等) が存在
✓ Docker イメージ (ghcr.io/zaproxy/zaproxy:stable) で即座に使用可
✓ JSON / HTML / XML / Markdown レポートを自動生成
```

```yaml
# GitHub Actions での典型例 (数行で組み込める)
- uses: zaproxy/action-api-scan@v0.7.0
  with:
    target: 'http://localhost:8080/openapi.json'
```

### 3. OpenAPI / Swagger を持つ REST API のスキャン

```
✓ OpenAPI 定義ファイルを読み込んでエンドポイントを自動探索
✓ Go + Gin の swag コメントから生成した openapi.json を直接指定可
✓ Postman コレクションのインポートにも対応
```

### 4. SPA (Single Page Application) のスキャン

```
✓ Ajax Spider が JavaScript によるルーティングを追跡
✓ React Router / Vue Router で生成されるページを探索可
✓ Selenium との統合も可能
```

### 5. セキュリティ教育・学習目的

```
✓ OWASP 公式ドキュメントと直接リンクした解説
✓ GUI がわかりやすく初学者向け
✓ OWASP WebGoat / DVWA との組み合わせ学習事例が豊富
```

### 6. Docker 化されたマイクロサービス環境

```
✓ --network オプションで内部 Docker ネットワークに参加可
✓ compose ファイルにサービスとして追加しやすい
✓ CI 環境での一時的なスキャンに向いている
```

---

## ZAP を選ぶべきでない条件

### 1. 手動侵入テストが中心の業務

```
✗ Burp Suite の Repeater / Intruder に相当する使い勝手がない
✗ リクエストの手動改ざん・再送が Burp より不便
✗ ペネトレーションテスト専門家には Burp が業界標準
```

### 2. OOB (帯域外) 脆弱性の検出が必要

```
✗ Burp Collaborator に相当する OOB コールバック機能がない
✗ Blind SSRF / Blind SQLi / OOB XXE の確実な検出は困難
```

### 3. 非常に複雑な認証フローを持つアプリ

```
✗ OAuth 2.0 / SAML / MFA を含む複雑なログインは設定が難しい
✗ セッション維持が不安定になりスキャンが不完全になる場合がある
```

---

## 適合度スコア (対象スタック別)

| 対象 | 適合度 | 理由 |
|------|--------|------|
| Go REST API (OpenAPI あり) | ★★★★★ | OpenAPI スキャンが最も容易 |
| React SPA | ★★★★☆ | Ajax Spider で対応可 |
| Flutter モバイル | ★★★☆☆ | プロキシ設定が必要 |
| Docker 環境 | ★★★★★ | 公式 Docker イメージあり |
| マイクロサービス | ★★★★☆ | 複数 URL のスキャンに対応 |
| 複雑な認証フロー | ★★☆☆☆ | 設定に工数がかかる |

---

## 他ツールとの比較における ZAP の優位点

| 比較軸 | ZAP | w3af | Burp Suite |
|--------|-----|------|-----------|
| コスト | 無償 | 無償 | Community 無償 / Pro 有償 |
| CI/CD 統合 | ◎ 最も容易 | △ 難しい | ○ Pro のみ容易 |
| 自動スキャン精度 | ○ | △ (メンテ低調) | ◎ (Pro) |
| 手動テスト | △ | △ | ◎ |
| OOB 検出 | △ | × | ◎ (Pro) |
| 学習コスト | 低 | 中 | 中〜高 |
| メンテナンス状況 | ◎ 活発 | △ 低調 | ◎ 活発 |

---

## 意思決定フローチャート

```
予算がない?
  └── YES → ZAP 一択

CI/CD に自動組み込みしたい?
  └── YES → ZAP が最適

OpenAPI / Swagger 定義がある?
  └── YES → ZAP の OpenAPI スキャンが最も効率的

手動ペネトレーションテストが主目的?
  └── YES → Burp Suite を検討

OOB 脆弱性 (Blind SSRF 等) を検出したい?
  └── YES → Burp Suite Pro を検討
```

---

## 推奨導入シナリオ

### シナリオ A: スタートアップの DevSecOps 導入

```
目的: 開発サイクルにセキュリティテストを組み込みたい
予算: なし
チーム: 開発者 3 名 (セキュリティ専門家なし)

→ ZAP を GitHub Actions に組み込む
   PR マージ前に毎回自動スキャン
   High / Medium アラートが出たらマージをブロック
```

### シナリオ B: OSS プロジェクトのセキュリティ向上

```
目的: OSS として公開するアプリの基本的な脆弱性チェック
予算: なし

→ ZAP の action-full-scan を使って
   リリース前の自動チェックを設定
```

### シナリオ C: 教育・学習目的

```
目的: チームメンバーにセキュリティを学ばせたい
予算: 最小限

→ ZAP + OWASP WebGoat / DVWA を Docker Compose で立ち上げ
   実際に攻撃・防御を体験
```
