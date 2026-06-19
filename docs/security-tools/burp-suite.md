## Burp Suite とは

Web アプリケーションのセキュリティテストに使う専門ツールです。  
セキュリティの専門家（ペネトレーションテスター）が「手動で攻撃を試みる」ときに使う**業界標準ツール**です。  
開発元は英国のセキュリティ企業 **PortSwigger**。

---

## このツールを候補にした理由

OWASP ZAP の比較対象として選定。手動テストや OOB（間接的な）脆弱性の検出を ZAP が苦手とするため、その補完ツールとして検討。

---

## 基本情報

| 項目 | Community 版（無償） | Professional 版（有償） |
|---|---|---|
| ライセンス | 無償 | 約 $449/年 |
| 開発元 | PortSwigger | PortSwigger |
| メンテナンス状況 | 活発（定期リリースあり） | 活発 |
| 動作環境 | Linux / macOS / Windows（**GUI 必須**） | 同左 |
| 主な用途 | 手動ペネトレーションテスト | 自動スキャン + 手動テスト |
| 自動スキャナ | なし | あり |
| Intruder 速度 | 制限あり（低速） | 無制限 |
| OOB コールバック（Collaborator） | なし | あり |

---

## Burp Suite の使い方（スキャンの流れ）

Burp Suite は ZAP のように「自動でサイトを探索して攻撃する」ツールではなく、  
**人間が操作しながら手動でテストする**ことを前提とした設計です。

```
① Proxy（プロキシ）
   ブラウザと Web サーバーの間に割り込んで、通信内容を盗み見る・止める
        ↓
② Intercept（インターセプト）
   ブラウザが送ったリクエストを途中で止めて、内容を確認・書き換える
        ↓
③ Repeater（リピーター）
   書き換えたリクエストを何度でも手動で再送して、反応を観察する
        ↓
④ Intruder（イントルーダー）
   特定の場所に大量のパターンを自動で試す
   （例: パスワード欄に辞書攻撃を試す）
        ↓
⑤ 結果を人間が判断して脆弱性として報告する
```

> **ZAP との最大の違い:**  
> ZAP は「全自動で走らせる」。Burp は「人間が考えながら操作する」。  
> 精密なテストが必要な場合は Burp、CI/CD への自動組み込みは ZAP が向いている。

---

## 得意なこと・苦手なこと

### 得意なこと ✓

- **手動でリクエストを改ざん・再送する細かい操作**  
  Repeater でリクエストを自由に編集して即座に送り直せる。

- **OOB（帯域外）脆弱性の検出 — Professional 版**  
  → OOB（Out-of-Band）とは「攻撃の結果が直接の返答には現れず、外部サーバーを経由して初めてわかる」タイプの脆弱性のこと。  
  Burp Collaborator という仕組みで DNS・HTTP のコールバックを受け取れるため、ZAP では検出できない Blind SSRF・Blind SQLi などを確実に検出できる。

- **複雑な認証フローのテスト**  
  JWT（ログイン用トークン）の解析・改ざん、OAuth（ソーシャルログイン）などの複雑な認証も GUI で操作できる。

- **ペネトレーションテストの業界標準**  
  OSCP / CEH などのセキュリティ資格試験でも使われる。

- **BApp Store（拡張機能）**  
  用途に合わせた拡張機能を追加できる（JWT 解析、隠しパラメータ発見、認可テストなど）。

### 苦手なこと ✗

- **CI/CD への自動組み込み**  
  → CI/CD とは「コードを変更するたびに自動でテストやチェックを行う仕組み」のこと。  
  Community 版には自動スキャン機能がなく、Enterprise 版（別料金）が必要。

- **GUI なし環境（サーバー・コンテナ）での動作**  
  公式 Docker イメージは存在しない。ヘッドレスサーバーでは使用できない。

- **Intruder の速度制限（Community 版）**  
  無償版では自動送信の速度が人工的に制限されており、大量テストには向かない。

---

## Burp Suite を選ぶ基準

| 状況 | 判断 |
|---|---|
| 手動ペネトレーションテストを実施したい | **Burp Suite を採用** |
| Blind SSRF など OOB 脆弱性を検出したい | **Professional 版を採用** |
| 複雑な JWT / OAuth 認証のテストが必要 | **Burp Suite を採用** |
| 予算がない | 見送り（ZAP を検討） |
| CI/CD に自動組み込みたい | 見送り（ZAP を検討） |
| ヘッドレスサーバー環境で使いたい | 見送り（GUI 必須のため不可） |

---

## 導入方法

> **前提:** Burp Suite は GUI アプリのため、**画面のあるデスクトップ PC（Windows / macOS / Linux デスクトップ）でのみ使用可能**。  
> ヘッドレスサーバーや CLI のみの環境では動作しない。

### Step 1 — インストーラのダウンロード

1. [https://portswigger.net/burp/releases](https://portswigger.net/burp/releases) にアクセス
2. **Community Edition**（無償）を選択
3. 自分の OS に合ったインストーラをダウンロード

### Step 2 — インストール

| OS | 手順 |
|---|---|
| Windows | `.exe` インストーラを実行してウィザードに従う |
| macOS | `.dmg` を開いてアプリケーションフォルダにドラッグ |
| Linux | `.sh` インストーラを実行（`chmod +x` してから） |

```bash
# Linux の場合
chmod +x burpsuite_community_linux.sh
./burpsuite_community_linux.sh
```

> インストーラに Java 21 が同梱されているため、Java を別途インストールする必要はない。

### Step 3 — 初回起動

1. インストール後、Burp Suite を起動
2. 「Temporary project」→「Use Burp defaults」→「Start Burp」を選択

### Step 4 — ブラウザの設定（プロキシ接続）

Burp はブラウザと Web サーバーの間に割り込んで通信を監視するため、ブラウザのプロキシ設定が必要。

1. Burp Suite 起動後、**「Proxy」タブ → 「Open Browser」** をクリック  
   → Burp 専用の設定済みブラウザが自動で立ち上がる（証明書設定も自動）  
   → これが最も簡単な方法

または Firefox に手動で設定する場合：
1. Firefox → 設定 → ネットワーク設定 → 手動でプロキシを設定
   - HTTP プロキシ: `127.0.0.1`、ポート: `8080`
2. `http://burpsuite` にアクセスして CA 証明書をダウンロード・インポート

### Step 5 — 通信の確認

1. 「Proxy」タブ → 「Intercept is on」になっていることを確認
2. ブラウザでスキャン対象（例: `http://localhost:8082`）にアクセス
3. Burp の画面にリクエストが表示されれば設定完了

---

## 起動確認（2026-05-29）

- バージョン: **Burp Suite Community Edition v2026.4.3**
- 環境: Windows 10

### 確認手順

1. 公式インストーラ（[https://portswigger.net/burp/releases](https://portswigger.net/burp/releases)）から Community Edition をダウンロードしてインストール ✓
2. 「Temporary project in memory」→「Use Burp defaults」→「Start Burp」で起動 ✓
3. 「Proxy」→「Open Browser」でBurp 内蔵ブラウザを起動 ✓
4. `http://localhost:8082/health` にアクセス → `{"status":"ok"}` が返ることを確認 ✓

### Intercept 動作確認

1. 「Proxy」→「Intercept is on」の状態で `/health` にアクセス → リクエストが Burp で止まることを確認 ✓
2. Raw タブで `GET /health` を `GET /health?test=1` に書き換えて「Forward」
3. サーバーが `{"status":"ok"}` を返すことを確認 ✓  
   （`/health` はクエリパラメータを無視する実装）

---

## このプロジェクトでの実際の使い方

### ① リクエストを傍受して内容を確認する

1. 「Proxy」タブ → 「Intercept is on」になっていることを確認
2. ブラウザでログインやクイズ取得などの操作を行う
3. Burp にリクエストが止まる → ヘッダー・パラメータを確認・書き換えて「Forward」

### ② Repeater で認可テスト

1. 「HTTP history」からリクエストを右クリック → 「Send to Repeater」
2. Authorization ヘッダーを削除 or 別ユーザーのトークンに改ざんして送信
3. レスポンスが `401 Unauthorized` / `403 Forbidden` になっているか確認  
   → 想定外のレスポンスが返れば認可バイパスの可能性

### ③ Intruder でパラメータを一括テスト（Community 版 — 速度制限あり）

1. リクエストを「Send to Intruder」
2. テストしたいパラメータ値を `§` で囲む
3. Payloads タブに試したい値リストを入力 → 「Start attack」

### ④ スキャナ（Active Scan）— Professional 版のみ

Community 版にはスキャナ機能がないため、自動脆弱性スキャンは Professional 版が必要。

---

## このプロジェクトへの採用判断

| 観点 | 評価 |
|---|---|
| CI/CD への自動組み込み |（Enterprise 版が必要） |
| ヘッドレスサーバーでの動作 | ✗ 不可（GUI 必須） |
| 無償で使えるか | △ Community 版は無償だが自動スキャンなし |
| 手動テストでの有用性 | ◎ 業界最高水準 |
| OOB 脆弱性の検出 | ◎ Professional 版なら可能（有償） |

**→ このプロジェクトの主目的（CI/CD 統合・自動スキャン）には不向き。  
手動で深掘りテストをする場面が出た際には Professional 版の導入を検討する。**
