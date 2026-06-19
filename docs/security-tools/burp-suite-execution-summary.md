# Burp Suite — 実施内容まとめ

## テスト概要

| 項目 | 内容 |
|------|------|
| ツール名 | Burp Suite Community Edition |
| バージョン | Help → About Burp Suite で確認 |
| 実施日 | YYYY-MM-DD |
| 実施者 | |
| 対象システム | Go バックエンド (Gin) + React フロントエンド |
| 対象 URL | http://localhost:8080 |
| 実施環境 | ローカル開発環境 |

> **Community 版の制約**: 自動スキャナなし / Intruder は速度制限あり / Collaborator (OOB) なし。手動テストと BApp (Turbo Intruder 等) で補完する。

---

## 実施したテストの一覧

### 1. プロキシ経由のトラフィックキャプチャ

すべての HTTP/HTTPS 通信を Burp 経由でキャプチャし、HTTP history に記録する。

**実施手順**:
```
Proxy → Intercept is on
ブラウザプロキシ設定: 127.0.0.1:8080
CA 証明書インポート完了確認
対象サイトを一通り操作
```

**確認項目**:
- HTTP history に主要エンドポイントが記録されているか
- HTTPS 通信が復号されているか (証明書エラーが出ていないか)
- Authorization ヘッダ (JWT) が含まれているか

---

### 2. SQL インジェクション — 手動検証 (Repeater)

Repeater でリクエストを自由に改ざんして SQLi を手動で確認する。

**実施手順**:
```
HTTP history → GET /api/users?id=1 → 右クリック → Send to Repeater
```

**実施したテストケース**:

| テスト名 | ペイロード | 期待する結果 |
|---------|-----------|------------|
| シングルクォートエラー誘発 | `id=1'` | 500 + SQLエラーメッセージ |
| Boolean True (条件の真偽値で差異を確認) | `id=1 AND 1=1--` | 通常レスポンス |
| Boolean False (条件の真偽値で差異を確認) | `id=1 AND 1=2--` | 空レスポンス / 404 |
| UNION カラム数確認 | `id=1 ORDER BY 1--` | 正常 |
| UNION データ抽出 | `id=-1 UNION SELECT 1,version()--` | DB バージョン文字列 |
| 時間ベース Blind | `id=1;SELECT pg_sleep(5)--` | 5 秒以上の遅延 |

**判定基準**:
- Boolean テストでレスポンスに差異あり → SQLi 確定
- 時間ベーステストで遅延あり → Blind SQLi 確定

---

### 3. SQL インジェクション — JSON ボディ (Repeater)

POST エンドポイントの JSON フィールドに SQLi ペイロードを挿入する。

**実施手順**:
```
HTTP history → POST /api/login → Send to Repeater

Body を以下に変更して "Send":
{"username":"alice' --","password":"anything"}
```

**実施したテストケース**:

| テスト名 | ペイロード (username フィールド) | 期待する結果 |
|---------|-------------------------------|------------|
| コメントアウトによるパスワードバイパス | `alice' --` | 200 OK + JWT トークン (認証バイパス) |
| OR 条件によるバイパス | `' OR '1'='1` | 200 OK + JWT トークン |
| シングルクォートエラー | `alice'` | 500 + SQLエラー |

---

### 4. レートリミット検証 (Intruder)

ログインエンドポイントへの連続リクエストでレートリミットの有無を確認する。

**実施手順**:
```
HTTP history → POST /api/login → Send to Intruder
Positions タブ: password の値を § で囲む
Payloads タブ: Numbers 1〜200
Start attack
```

**判定基準**:
- 200 回中に HTTP 429 が 1 件でも出る → レートリミットあり (正常)
- 200 回すべてが 401 → レートリミットなし (脆弱)

**Turbo Intruder を使った高速確認** (BApp Store からインストール):
```python
def queueRequests(target, wordlists):
    engine = RequestEngine(endpoint=target.endpoint, concurrentConnections=10)
    for i in range(500):
        engine.queue(target.req, str(i))

def handleResponse(req, interesting):
    if '429' in req.response:
        table.add(req)
```

---

### 5. XSS (クロスサイトスクリプティング) — 手動検証 (Repeater)

URL パラメータ・フォームフィールドに XSS ペイロードを挿入する。

**実施したテストケース**:

| エンドポイント | パラメータ | ペイロード | 判定 |
|--------------|-----------|----------|------|
| /api/search | q | `<script>alert(1)</script>` | レスポンスに文字列がそのまま含まれるか |
| /api/search | q | `"><img src=x onerror=alert(1)>` | 属性エスケープの確認 |
| /api/users | name | `<svg onload=alert(1)>` | SVG インジェクション |

**判定基準**:
- レスポンスボディにペイロードがエスケープなしで含まれる → Reflected XSS 確定
- 別リクエストで保存されたペイロードが返ってくる → Stored XSS 確定

---

### 6. ReDoS — 応答時間分析 (Intruder)

段階的に長い ReDoS ペイロードを送信し、応答時間の変化を計測する。

**実施手順**:
```
HTTP history → GET /api/search?q=test → Send to Intruder
Positions タブ: q の値を § で囲む
Payloads タブ: Simple list で以下を追加:
  hello
  aaaaaaaaaaaaaaaaaaaab
  aaaaaaaaaaaaaaaaaaaaab
  aaaaaaaaaaaaaaaaaaaaaab
  aaaaaaaaaaaaaaaaaaaaaaab
  ...
Start attack → Time 列で応答時間を確認
```

**判定基準**:
- 応答時間が入力長に比例して線形増加 → 正常
- 入力長が 2 倍で応答時間が 4 倍以上 → ReDoS の疑い
- 応答時間が 5 秒を超える → ReDoS 確定

---

### 7. 巨大ペイロード / JSON Bomb (Repeater)

大きなリクエストボディやネストした JSON でサーバリソースを枯渇させる脆弱性を確認する。

**実施したテストケース**:

| テスト名 | 内容 | 期待する結果 |
|---------|------|------------|
| 1 MB JSON | `{"data":"A"*1000000}` を POST | 413 / 400 (制限あり) |
| 10 MB JSON | `{"data":"A"*10000000}` を POST | 413 / 400 (制限あり) |
| JSON Bomb (25段ネスト) | `{"a":{"a":{"a":...}}}` | 即座に 400 (深さ制限あり) |

---

### 8. JWT の検証 (JWT Editor BApp)

JWT の署名検証・アルゴリズム変更攻撃を確認する。

**使用 BApp**: JWT Editor (BApp Store からインストール)

**実施したテストケース**:

| テスト名 | 内容 | 期待する結果 |
|---------|------|------------|
| alg:none 攻撃 | JWT の alg を "none" に変更して署名を削除 | 401 Unauthorized (正常) / 200 OK (脆弱) |
| ペイロード改ざん | JWT の sub / role フィールドを変更 | 401 Unauthorized (署名検証で拒否) |
| HS256 → RS256 | 非対称アルゴリズムへの切り替え攻撃 | 401 Unauthorized (正常) |

---

### 9. Comparer でのレスポンス差異確認

Boolean テスト等で2つのレスポンスを視覚的に比較する。

**実施手順**:
```
Repeater で "真" レスポンス → 右クリック → Send to Comparer (response)
Repeater で "偽" レスポンス → 右クリック → Send to Comparer (response)
Comparer タブ → "Words" ボタン → 差異をハイライト表示
```

---

## 実施結果サマリ (記入欄)

| テスト項目 | 実施 | 脆弱性検出 | 対象エンドポイント |
|-----------|------|-----------|-----------------|
| SQLi (URL パラメータ) | ○ / × | あり / なし | |
| SQLi (JSON ボディ) | ○ / × | あり / なし | |
| レートリミット | ○ / × | あり / なし | |
| XSS | ○ / × | あり / なし | |
| ReDoS | ○ / × | あり / なし | |
| 巨大ペイロード | ○ / × | あり / なし | |
| JSON Bomb | ○ / × | あり / なし | |
| JWT 検証 | ○ / × | あり / なし | |

---

## 未実施・対象外の項目

| 項目 | 理由 |
|------|------|
| OOB (帯域外) 脆弱性 | Collaborator は Professional 版のみ。Community では未実施 |
| 自動スキャン | Community 版にスキャナなし。ZAP で補完 |
| Intruder 高速ブルートフォース | Community 版は速度制限あり。Turbo Intruder で部分補完 |
