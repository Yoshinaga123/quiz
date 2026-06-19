# Docker イメージセキュリティ — OWASP ZAP / w3af / Burp Suite 評価

## 前提: 3 ツールの本来の用途

OWASP ZAP・w3af・Burp Suite はいずれも **Web アプリケーションの脆弱性診断ツール**です。  
Docker イメージのセキュリティチェックとは用途が異なるため、まず「何ができて何ができないか」を明確にします。

---

## Docker イメージセキュリティの観点一覧

Docker イメージのセキュリティは大きく以下の層に分かれます。

| 層 | チェック内容 | 対象ツールの守備範囲 |
|----|------------|------------------|
| **イメージ層** | ベースイメージの脆弱性 (CVE)、不要パッケージ、秘密情報の混入 | ✕ 対象外 |
| **コンテナ設定層** | `root` 実行、capabilities、read-only FS | ✕ 対象外 |
| **ネットワーク層** | 不要ポートの公開、TLS 設定 | △ 部分的 |
| **Web アプリ層** | コンテナ上で動く Web アプリの脆弱性 | ◎ 本来の用途 |

---

## 各ツールの評価

### OWASP ZAP

| 観点 | 評価 | 詳細 |
|------|------|------|
| ベースイメージの CVE 検出 | ✕ | OS パッケージの脆弱性は検出不可 |
| 秘密情報のハードコード検出 | ✕ | Dockerfile・環境変数の静的解析は不可 |
| コンテナ設定の検査 | ✕ | `docker inspect` 相当の検査は不可 |
| 公開ポートの Web サービス検査 | ◎ | コンテナが公開する Web アプリをスキャン可能 |
| HTTP ヘッダ・TLS 設定の検査 | ◎ | コンテナ上の Web サービスに対してパッシブスキャン可能 |
| CI/CD パイプラインへの組み込み | ◎ | Docker イメージとして提供されており、コンテナ上のアプリを自動スキャン可能 |

**ZAP を Docker で使う例 (コンテナ上のアプリをスキャン)**

```bash
# コンテナ上で動く Web アプリを ZAP でスキャン
docker run --rm --network host ghcr.io/zaproxy/zaproxy:stable \
  zap-baseline.py \
  -t http://localhost:8080 \
  -r report.html
```

**結論**: ZAP は「Docker コンテナ上で動く Web アプリ」の検査には有効だが、**イメージ自体のセキュリティ (CVE・設定不備) は検査できない**。

---

### w3af

| 観点 | 評価 | 詳細 |
|------|------|------|
| ベースイメージの CVE 検出 | ✕ | OS パッケージの脆弱性は検出不可 |
| 秘密情報のハードコード検出 | ✕ | 静的解析機能なし |
| コンテナ設定の検査 | ✕ | Docker API へのアクセス手段なし |
| 公開ポートの Web サービス検査 | ○ | コンテナが公開する Web アプリをスキャン可能 |
| HTTP ヘッダ・TLS 設定の検査 | △ | 最新ヘッダへの対応が不十分 (メンテナンス低調) |
| CI/CD パイプラインへの組み込み | △ | Docker イメージは存在するが更新が少ない |

**結論**: w3af も「コンテナ上の Web アプリ」の検査は可能だが、ZAP・Burp Suite と比べて信頼性・最新性が劣る。**Docker イメージ自体のセキュリティは検査できない**。

---

### Burp Suite

| 観点 | 評価 | 詳細 |
|------|------|------|
| ベースイメージの CVE 検出 | ✕ | OS パッケージの脆弱性は検出不可 |
| 秘密情報のハードコード検出 | ✕ | 静的解析機能なし |
| コンテナ設定の検査 | ✕ | Docker API へのアクセス手段なし |
| 公開ポートの Web サービス検査 | ◎ | コンテナが公開する Web アプリを高精度でスキャン |
| HTTP ヘッダ・TLS 設定の検査 | ◎ | パッシブスキャンで網羅的に検出 |
| CI/CD パイプラインへの組み込み | ○ | Enterprise 版で対応 / Community・Pro は手動操作前提 |

**結論**: Burp Suite も「コンテナ上の Web アプリ」の検査精度は最高水準だが、**Docker イメージ自体のセキュリティは検査できない**。Enterprise 版以外は CI/CD 自動化が難しい。

---

## 3 ツールの総合比較 (Docker 観点)

| チェック項目 | OWASP ZAP | w3af | Burp Suite |
|------------|-----------|------|------------|
| ベースイメージの CVE | ✕ | ✕ | ✕ |
| Dockerfile の秘密情報検出 | ✕ | ✕ | ✕ |
| コンテナの root 実行検出 | ✕ | ✕ | ✕ |
| 不要な capabilities 検出 | ✕ | ✕ | ✕ |
| **公開 Web アプリの脆弱性** | ◎ | ○ | ◎ |
| **セキュリティヘッダの検査** | ◎ | △ | ◎ |
| **TLS 設定の検査** | ○ | △ | ◎ |
| **Blind 系脆弱性の検出** | △ | △ | ◎ (Pro) |
| CI/CD 自動化 | ◎ | △ | △〜○ |
| 無料で使えるか | ◎ | ◎ | △ |

---

## Docker イメージセキュリティに本来必要なツール

3 ツールが対応できない「イメージ層・コンテナ設定層」のチェックには、専用ツールを使う必要があります。

| ツール | 用途 | 無料 |
|-------|------|------|
| **Trivy** (推奨) | イメージの CVE スキャン・秘密情報検出・設定不備検出 | ◎ |
| **Grype** | イメージの CVE スキャン | ◎ |
| **Docker Scout** | Docker 公式の CVE・SBOM 分析 | ◎ (基本機能) |
| **Hadolint** | Dockerfile の Lint・ベストプラクティスチェック | ◎ |
| **Dockle** | CIS Benchmark に基づくコンテナ設定検査 | ◎ |
| **Checkov** | Dockerfile・docker-compose の IaC セキュリティスキャン | ◎ |

### Trivy によるイメージスキャン例

```bash
# イメージの CVE スキャン
trivy image nginx:latest

# 秘密情報のスキャン
trivy image --scanners secret myapp:latest

# Dockerfile のスキャン
trivy config ./Dockerfile

# CI/CD での利用 (GitHub Actions)
- name: Run Trivy vulnerability scanner
  uses: aquasecurity/trivy-action@master
  with:
    image-ref: myapp:latest
    format: sarif
    output: trivy-results.sarif
```

---

## 推奨アーキテクチャ: 多層防御

Docker 環境のセキュリティを網羅するには、ツールを組み合わせる必要があります。

```
┌─────────────────────────────────────────────────┐
│                CI/CD パイプライン                  │
│                                                  │
│  [イメージビルド]                                  │
│      └─ Hadolint      Dockerfile の Lint          │
│      └─ Trivy         イメージ CVE・秘密情報スキャン │
│      └─ Dockle        CIS Benchmark チェック       │
│                                                  │
│  [デプロイ後・Web アプリ検査]                       │
│      └─ OWASP ZAP     Web アプリ自動スキャン        │
│      └─ Burp Suite    手動ペネトレーションテスト     │
└─────────────────────────────────────────────────┘
```

| フェーズ | ツール | 役割 |
|---------|-------|------|
| Dockerfile 作成時 | Hadolint, Checkov | ベストプラクティス違反を早期検出 |
| イメージビルド時 | Trivy, Grype | CVE・秘密情報の混入を防止 |
| デプロイ前 | Dockle | コンテナ設定の検査 |
| デプロイ後 | **OWASP ZAP** | Web アプリの自動スキャン (CI/CD 向き) |
| ペネトレーションテスト | **Burp Suite Pro** | 手動による高精度テスト |

---

## まとめ

> **OWASP ZAP・w3af・Burp Suite の 3 ツールは、Docker イメージ自体のセキュリティ (CVE・Dockerfile の設定ミス・秘密情報混入) を検査することはできない。**

これらのツールの価値は「コンテナ上で動く Web アプリケーションの脆弱性診断」に限定される。  
Docker イメージのセキュリティを包括的にカバーするには **Trivy などの専用ツールと組み合わせる多層防御**が必要。
