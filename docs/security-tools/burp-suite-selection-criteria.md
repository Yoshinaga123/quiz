# Burp Suite — ツール選定基準

## このファイルの目的

Burp Suite を選ぶべき状況・選ぶべきでない状況を整理し、Community 版と Professional 版の使い分けも含めて意思決定の根拠を明確にする。

---

## Burp Suite の基本プロファイル

| 項目 | Community 版 | Professional 版 |
|------|-------------|----------------|
| ライセンス | 無償 | 有償 (約 $449/年) |
| 開発元 | PortSwigger |
| 最終更新 | 活発にメンテナンスされている |
| 動作環境 | Linux / macOS / Windows |
| 主な用途 | 手動ペネトレーションテスト・高精度自動スキャン |
| 習得難易度 | ★★★☆☆ |
| 自動スキャナ | なし | あり |
| Intruder 速度 | 制限あり | 無制限 |
| Collaborator (OOB) | なし | あり |

---

## Burp Suite を選ぶべき条件

### 1. 手動ペネトレーションテストが中心

```
✓ Repeater で任意のリクエストを手動改ざんして即座に再送
✓ リクエスト/レスポンスの詳細を素早く確認・編集
✓ Intruder で特定パラメータへのペイロードブルートフォース
✓ ペンテスター向けの業界標準ツール
✓ OSCP / CEH / GPEN などのセキュリティ資格試験での使用実績豊富
```

### 2. OOB (帯域外) 脆弱性の検出が必要 (Professional)

```
✓ Burp Collaborator が DNS / HTTP コールバックを提供
✓ Blind SSRF の確実な検出
✓ OOB SQLi (DNS exfiltration) の検出
✓ OOB XXE の検出
✓ これらは ZAP / w3af では検出困難

# コールバック URL の例
abcde1234.burpcollaborator.net

SSRF テスト例:
{"url":"http://abcde1234.burpcollaborator.net"}
→ Collaborator client に DNS/HTTP 記録が届く = SSRF 確定
```

### 3. 複雑な認証フローを持つアプリ

```
✓ OAuth 2.0 / SAML / JWT の操作が GUI で直感的
✓ JWT Editor (BApp) でトークンの改ざん・検証が容易
✓ Session Handling Rules で複雑な認証フローを維持
✓ Macro でログインフロー全体を記録・再生
```

### 4. JSON / REST API の精密なテスト

```
✓ JSON ボディのパラメータを自動的に挿入ポイントとして認識
✓ JSON パラメータへのペイロード挿入が ZAP / w3af より精度が高い
✓ GraphQL エンドポイントへの対応 (InQL BApp)
✓ gRPC の操作 (Protobuf BApp)
```

### 5. チームでの共同作業 (Enterprise 版)

```
✓ Burp Suite Enterprise Edition: CI/CD + チームスキャン管理
✓ 複数のスキャンを一元管理
✓ REST API でスキャンを自動化
✓ セキュリティチームのダッシュボード
```

### 6. BApp Store による機能拡張

```
主要な BApp (拡張機能):

  Turbo Intruder     → 高速 HTTP リクエスト送信 (レートリミットテスト)
  JWT Editor         → JWT の解析・改ざん・CVE 検証
  Autorize           → 認可制御の自動テスト (IDOR 検出)
  Retire.js          → 脆弱な JavaScript ライブラリの検出
  InQL               → GraphQL インジェクション
  Hackvertor         → エンコード変換ユーティリティ
  Logger++           → 高機能リクエストログ
```

---

## Burp Suite を選ぶべきでない条件

### 1. CI/CD への自動統合が主目的 (Community 版)

```
✗ Community 版に自動スキャナがない
✗ REST API は Enterprise/Professional のみ
✗ CI/CD 統合には ZAP の方が容易で無償
```

### 2. 予算がゼロ

```
✗ Professional 版は約 $449/年 (個人) / $1,999/年 (組織)
✗ Community 版は Intruder に速度制限 (スロットル) があり実用性が低い
✗ この条件では ZAP を第一選択とすべき
```

### 3. スキャンの完全自動化のみが目的

```
✗ Burp は人間がインタラクティブに操作する設計
✗ 完全無人の自動スキャンは Enterprise 版 ($) が必要
✗ ZAP の方が安価・容易に自動化できる
```

---

## 適合度スコア (対象スタック別)

| 対象 | Community | Professional | 理由 |
|------|-----------|-------------|------|
| Go REST API (JSON) | ★★★★☆ | ★★★★★ | JSON ボディ挿入が最も精密 |
| React SPA | ★★★☆☆ | ★★★★☆ | Chromium クローラで対応 |
| Flutter モバイル | ★★★★☆ | ★★★★★ | Android/iOS プロキシ設定が充実 |
| GraphQL | ★★★★☆ | ★★★★★ | InQL BApp が強力 |
| 複雑な認証フロー | ★★★★☆ | ★★★★★ | Session Rules + Collaborator |
| OOB 脆弱性 | ★☆☆☆☆ | ★★★★★ | Community に Collaborator なし |
| CI/CD 統合 | ★★☆☆☆ | ★★★★☆ | Enterprise が最適 |

---

## 他ツールとの比較における Burp の優位点

| 比較軸 | Burp Suite | ZAP | w3af |
|--------|-----------|-----|------|
| 手動テストの効率 | ◎ | △ | △ |
| OOB 検出 | ◎ (Pro) | △ | × |
| JSON API 対応 | ◎ | ○ | △ |
| 拡張機能の充実度 | ◎ (BApp) | ○ (Marketplace) | ○ (Python) |
| コスト | △ (Pro は有償) | ◎ 無償 | ◎ 無償 |
| CI/CD 統合 | ○ (Pro/Enterprise) | ◎ 容易 | △ 不安定 |
| SPA 対応 | ○ | ○ | × |
| 業界での普及率 | ◎ (ペンテスト標準) | ○ | △ |

---

## Community 版 vs Professional 版 の使い分け

```
Community 版で十分なケース:
  ├── 個人学習・スキル習得
  ├── 手動テスト (Repeater でのリクエスト改ざん)
  ├── Turbo Intruder などの BApp を活用した手動検証
  └── 予算なしでのペンテスト基礎練習

Professional 版が必要なケース:
  ├── Collaborator による OOB 脆弱性 (Blind SSRF 等) の検出
  ├── 自動スキャナによる広範な脆弱性検出
  ├── Intruder の速度制限なしでのブルートフォース
  └── 商用ペネトレーションテスト報告書の作成
```

---

## 意思決定フローチャート

```
手動ペネトレーションテストが主目的?
  └── YES → Burp Suite (Community / Professional)

OOB 脆弱性 (Blind SSRF / OOB SQLi) の検出が必要?
  └── YES → Burp Suite Professional 一択

予算がある (年間 $449 以上)?
  └── YES → Professional を選ぶ価値あり
  └── NO  → Community + ZAP の組み合わせ

CI/CD 自動統合が主目的で予算なし?
  └── YES → ZAP を選ぶ

GraphQL / gRPC のテストが必要?
  └── YES → Burp Suite (InQL / Protobuf BApp)

JWT の操作・脆弱性検証が必要?
  └── YES → Burp Suite (JWT Editor BApp)
```

---

## 推奨導入シナリオ

### シナリオ A: セキュリティ専門チームによるペンテスト

```
目的: 顧客向けのペネトレーションテスト報告書を作成
チーム: セキュリティエンジニア 2〜3 名
予算: あり

→ Burp Suite Professional を導入
   Collaborator で OOB 脆弱性を確実に検出
   Repeater / Intruder で手動検証
   Scanner でカバレッジを補完
   ZAP を CI/CD 統合の補完として並用
```

### シナリオ B: スタートアップでの本格的なセキュリティ評価

```
目的: プロダクトの本番リリース前に包括的な脆弱性評価
予算: 限定的

→ Burp Suite Community + ZAP の組み合わせ
   ZAP: CI/CD に組み込んで自動スキャン (無償)
   Burp Community: 手動で疑わしいエンドポイントを精査
   資金ができたら Professional にアップグレード
```

### シナリオ C: 個人学習・セキュリティ資格取得

```
目的: OSCP / CEH などの資格取得に向けた実習
予算: なし〜最小限

→ Burp Suite Community を使いこなす
   HackTheBox / TryHackMe などの実習環境で Repeater を練習
   BApp Store から Turbo Intruder などの無償拡張を活用
   将来的に Professional にアップグレードを視野に入れる
```

### シナリオ D: Flutter モバイルアプリのセキュリティテスト

```
目的: Android / iOS アプリと Go バックエンドの通信を検査
チーム: モバイルエンジニア + セキュリティエンジニア

→ Burp Suite が最も向いている
   Android: Burp CA → network_security_config に追加
   iOS: プロファイルインストール
   certificate pinning: Frida + objection でバイパス
   JWT や API キーの漏洩を Repeater で確認
```
