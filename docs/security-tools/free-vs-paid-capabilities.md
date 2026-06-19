# セキュリティツール — 無料 / 有料でできる範囲

## 概要

3 ツールの無料・有料の境界線を整理する。ZAP と w3af は完全無料だが、Burp Suite は Community (無料) と Professional (有料) で機能差が大きい。

---

## OWASP ZAP

**ライセンス**: Apache 2.0 — すべての機能が永続無料

| 機能 | 無料 | 備考 |
|------|------|------|
| パッシブスキャン | ○ | |
| Spider (クローリング) | ○ | |
| Ajax Spider (SPA 対応) | ○ | |
| アクティブスキャン (自動攻撃) | ○ | |
| Fuzzer | ○ | |
| REST API | ○ | |
| Docker イメージ | ○ | ghcr.io/zaproxy/zaproxy:stable |
| GitHub Actions 公式連携 | ○ | zaproxy/action-full-scan 等 |
| HTML / JSON レポート生成 | ○ | |
| OpenAPI / Swagger スキャン | ○ | |
| スクリプト拡張 (Python/Groovy) | ○ | |
| Marketplace アドオン | ○ | 大半が無料 |
| OOB (帯域外) コールバック | △ | OAST アドオンで一部対応 (Collaborator 相当ではない) |
| クラウドスキャン管理 | × | 存在しない |

**結論**: ZAP に有料プランは存在しない。すべての機能を無料で使える唯一の主要スキャナ。

---

## w3af

**ライセンス**: GPL v2 — すべての機能が永続無料

| 機能 | 無料 | 備考 |
|------|------|------|
| コンソール / GUI | ○ | |
| audit プラグイン全種 (sqli, xss 等) | ○ | |
| crawl プラグイン (web_spider 等) | ○ | |
| grep プラグイン (error_pages 等) | ○ | |
| .w3af スクリプト自動化 | ○ | |
| Docker 実行 | ○ | andresriancho/w3af |
| HTML レポート生成 | ○ | |
| Python 独自プラグイン開発 | ○ | |
| OOB コールバック | × | 機能なし |
| クラウドスキャン管理 | × | 存在しない |

**結論**: w3af にも有料プランは存在しない。ただしメンテナンスが停滞しており、機能の充実度は限定的。

---

## Burp Suite

**ライセンス**: 3 エディションに分かれる

| エディション | 価格 | 主な用途 |
|------------|------|---------|
| Community | 無料 | 個人学習・手動テスト |
| Professional | 約 $449/年 (個人) | ペネトレーションテスト・自動スキャン |
| Enterprise | 要見積もり | チーム管理・CI/CD 統合 |

### Community (無料) でできること

| 機能 | 可否 | 備考 |
|------|------|------|
| Proxy (インターセプト) | ○ | |
| HTTP history | ○ | |
| Repeater | ○ | リクエスト手動改ざん・再送 |
| Decoder | ○ | エンコード変換 |
| Comparer | ○ | レスポンス差異比較 |
| Sequencer | ○ (制限あり) | トークンのランダム性分析 |
| Intruder | △ | **速度制限あり** |
| BApp Store (拡張機能) | △ | 一部の BApp のみ無料 |
| Turbo Intruder (BApp) | ○ | 高速リクエスト送信 (無料 BApp) |
| JWT Editor (BApp) | ○ | JWT 解析・改ざん (無料 BApp) |
| Autorize (BApp) | ○ | 認可テスト (無料 BApp) |
| 自動スキャナ | × | Professional のみ |
| Collaborator (OOB) | × | Professional のみ |
| REST API | × | Enterprise のみ |
| レポート自動生成 | × | Professional のみ |

### Professional ($449/年〜) でできること

Community のすべてに加えて:

| 機能 | 概要 |
|------|------|
| 自動スキャナ | 広範な脆弱性を自動検出 (SQLi, XSS, SSRF 等) |
| Intruder 無制限 | 速度制限なしでの高速ブルートフォース |
| Burp Collaborator | OOB (帯域外) コールバック — Blind SSRF / OOB SQLi / OOB XXE の検出 |
| スキャンプロファイル保存 | カスタムスキャン設定の保存・再利用 |
| レポート自動生成 | HTML / XML 形式の詳細レポート |
| ライブスキャン | ブラウジング中にバックグラウンドで自動スキャン |
| スケジュールスキャン | 指定時刻での自動スキャン |

### Enterprise (要見積もり) でのみできること

| 機能 | 概要 |
|------|------|
| REST API | CI/CD パイプラインからスキャンを API 経由で起動 |
| チーム管理ダッシュボード | 複数のスキャン結果を一元管理 |
| 複数エージェント | 並列スキャンの実行 |
| GitHub / GitLab 統合 | PR 単位でのスキャン結果表示 |

---

## 3 ツール横断比較表

| 機能 | ZAP (無料) | w3af (無料) | Burp Community (無料) | Burp Professional (有料) |
|------|-----------|------------|----------------------|------------------------|
| 自動スキャン | ◎ | ○ (不安定) | × | ◎ |
| 手動テスト (Repeater 相当) | △ | △ | ◎ | ◎ |
| OOB コールバック | △ (OAST) | × | × | ◎ (Collaborator) |
| CI/CD 統合 | ◎ | △ | × | ○ |
| JSON API テスト | ○ | △ | ◎ | ◎ |
| SPA (React 等) 対応 | ○ (Ajax Spider) | × | ○ | ◎ |
| JWT 操作 | △ | × | ◎ (JWT Editor BApp) | ◎ |
| Intruder 高速 | △ (Fuzzer) | × | × (速度制限) | ◎ |
| レポート生成 | ◎ | ○ | × | ◎ |
| Python/スクリプト拡張 | ○ | ◎ | × | ○ |

---

## 無料の組み合わせで補完する戦略

Burp Professional を購入しない場合でも、以下の組み合わせで多くをカバーできる。

```
ZAP (無料)
  → 自動スキャン・CI/CD 統合・レポート生成・OpenAPI スキャン

Burp Community (無料) + 無料 BApp
  → Repeater での手動精査
  → Turbo Intruder でレートリミットテスト
  → JWT Editor で JWT 脆弱性確認
  → Autorize で認可制御テスト

w3af (無料) — 限定的な補完
  → redos / buffer_overflow プラグインなど ZAP にない特定チェックのみ

カバーできない項目 (有料が必要):
  × Blind SSRF / OOB SQLi / OOB XXE → Burp Professional の Collaborator が必要
  × 大規模 CI/CD 自動管理 → Burp Enterprise が必要
  × Intruder 高速ブルートフォース → Burp Professional が必要
```

---

## 予算別の推奨構成

| 予算 | 推奨構成 |
|------|---------|
| ¥0 | ZAP (主力) + Burp Community (手動補完) |
| ~$50/月 | ZAP + Burp Professional (個人ライセンス) |
| ~$200/月 | ZAP + Burp Professional (チーム) |
| $200~/月 | Burp Enterprise (CI/CD 完全統合) + ZAP |
