# Burp Suite コマンド・操作一覧

## CLI 起動オプション

```bash
# GUI 起動
burpsuite

# 画面なしで起動 (Enterprise / Pro)
java -jar burpsuite_pro.jar --project-file=project.burp

# 設定ファイルを指定して起動
java -jar burpsuite_pro.jar \
  --project-file=project.burp \
  --config-file=config.json

# 新規プロジェクトを画面なしで起動
java -jar burpsuite_pro.jar \
  --project-file=new_project.burp \
  --config-file=config.json \
  --unpause-spider-and-scanner
```

| オプション | 説明 |
|-----------|------|
| `--project-file=<ファイル>` | プロジェクトファイルを指定 |
| `--config-file=<ファイル>` | 設定ファイル (JSON) を指定 |
| `--user-config-file=<ファイル>` | ユーザ設定ファイルを指定 |
| `--unpause-spider-and-scanner` | 起動時に Spider / Scanner を自動開始 |
| `--collaborator-server` | Collaborator サーバとして起動 |
| `--collaborator-config=<ファイル>` | Collaborator 設定ファイルを指定 |
| `--diagnostics` | 診断情報を出力 |

---

## REST API (Professional / Enterprise)

Burp Suite Professional はローカル REST API を提供します。

### API を有効化

1. Burp メニュー → 設定 → REST API
2. 「サービスを有効化」にチェック
3. API キーを設定 (任意)

デフォルトエンドポイント: `http://localhost:1337`

### スキャンの実行

```bash
# スキャン開始
curl -X POST http://localhost:1337/v0.1/scan \
  -H "Content-Type: application/json" \
  -d '{
    "urls": ["https://example.com"],
    "scan_configurations": [
      {"name": "Crawl and Audit - Fast"}
    ]
  }'

# 認証が必要な場合
curl -X POST "http://localhost:1337/v0.1/scan?api-key=your-api-key" \
  -H "Content-Type: application/json" \
  -d '{
    "urls": ["https://example.com"],
    "application_logins": [
      {
        "login_url": "https://example.com/login",
        "username": "testuser",
        "password": "testpass"
      }
    ]
  }'
```

### スキャン状況の確認

```bash
# スキャン ID を指定してステータス確認
curl "http://localhost:1337/v0.1/scan/<scan-id>"

# レスポンス例
# {
#   "scan_status": "running",
#   "scan_metrics": {
#     "crawl_requests_made": 150,
#     "audit_items_completed": 80
#   }
# }
```

### スキャン結果の取得

```bash
# 問題一覧を取得
curl "http://localhost:1337/v0.1/scan/<scan-id>/issues"

# 重要度でフィルタ (high のみ)
curl "http://localhost:1337/v0.1/scan/<scan-id>/issues?severity=high"
```

### スキャン設定プロファイル一覧

```bash
curl "http://localhost:1337/v0.1/scan/configurations"
```

---

## Burp CLI ツール (コマンドライン実行)

### bamda (Burp Suite Enterprise)

```bash
# スキャンの実行
bamda scan start --target https://example.com --scan-configuration "Crawl and Audit - Fast"

# スキャン一覧
bamda scan list

# スキャン結果の取得
bamda scan get --id <scan-id>

# レポート出力
bamda report generate --id <scan-id> --format html --output report.html
```

---

## Burp Proxy の設定・操作

### プロキシリスナーの設定

| 操作 | 場所 |
|------|------|
| リスナーの追加・変更 | Proxy → Options → Proxy Listeners |
| デフォルトポートの変更 | Proxy → Options → `127.0.0.1:8080` を編集 |
| HTTPS のインターセプト | Proxy → Options → SSL Pass Through を設定 |

### Intercept の操作

| キー操作 | 説明 |
|---------|------|
| `Forward` ボタン | インターセプトしたリクエストを転送 |
| `Drop` ボタン | リクエストを破棄 |
| `Intercept is on/off` | インターセプトの有効・無効を切り替え |
| `Action` ボタン | Repeater / Intruder などへ送信 |

### キーボードショートカット

| ショートカット | 説明 |
|-------------|------|
| `Ctrl + R` | Repeater に送信 |
| `Ctrl + I` | Intruder に送信 |
| `Ctrl + S` | スキャンに送信 |
| `Ctrl + F` | 検索 |
| `Ctrl + Z` | 元に戻す |
| `Ctrl + Space` | コンテンツ補完 |
| `Ctrl + Shift + R` | HTTP リクエストを整形 |

---

## Repeater の使い方

```
Proxy → HTTP history → リクエストを右クリック → Send to Repeater
```

| 操作 | 説明 |
|------|------|
| `Send` ボタン | リクエストを送信 |
| `Cancel` ボタン | 送信をキャンセル |
| `<` / `>` ボタン | 以前のリクエスト/レスポンスに移動 |
| タブの + | 新しい Repeater タブを追加 |
| 右クリック → Send to Comparer | レスポンスを Comparer で比較 |

### エンコード操作 (入力欄内)

| ショートカット | 説明 |
|-------------|------|
| `Ctrl + U` | URL エンコード |
| `Ctrl + Shift + U` | URL デコード |
| `Ctrl + B` | Base64 エンコード |
| `Ctrl + Shift + B` | Base64 デコード |
| `Ctrl + H` | HTML エンコード |
| `Ctrl + Shift + H` | HTML デコード |

---

## Intruder の使い方

```
Proxy → HTTP history → リクエストを右クリック → Send to Intruder
```

### アタックタイプ

| タイプ | 説明 |
|--------|------|
| `Sniper` | 1 パラメータずつ順番にペイロードを適用 |
| `Battering ram` | 全パラメータに同じペイロードを同時適用 |
| `Pitchfork` | 複数パラメータに別々のペイロードリストを並行適用 |
| `Cluster bomb` | 全パラメータの組み合わせを網羅 |

### ペイロードの設定

```
Intruder → Payloads タブ
```

| ペイロードタイプ | 説明 |
|--------------|------|
| Simple list | 手動入力・ファイルのリスト |
| Runtime file | 実行時にファイルから読み込み |
| Custom iterator | 複数リストの組み合わせ |
| Character frobber | 各文字を変更 |
| Bit flipper | ビット反転 |
| Username generator | ユーザ名のバリエーション生成 |
| Null payloads | 空のペイロード (リクエスト繰り返し用) |
| Brute forcer | 文字セットからブルートフォース |
| Numbers | 数値の範囲指定 |
| Dates | 日付のバリエーション |

---

## Scanner の操作 (Professional)

### スキャンの開始方法

```
# 方法 1: URL を直接指定
Dashboard → New Scan → Enter URL

# 方法 2: HTTP history から
Proxy → HTTP history → 右クリック → Scan

# 方法 3: Repeater から
Repeater → 右クリック → Scan
```

### スキャン設定プロファイル

| プロファイル | 説明 |
|------------|------|
| `Crawl and Audit - Fast` | 高速クロール＋スキャン |
| `Crawl and Audit - Balanced` | バランス型 |
| `Crawl and Audit - Thorough` | 徹底スキャン |
| `Audit selected insertion points` | 特定パラメータのみスキャン |
| `Crawl only` | クロールのみ |

---

## Sequencer (トークン分析)

```
Proxy → HTTP history → セッションレスポンスを右クリック → Send to Sequencer
```

| 操作 | 説明 |
|------|------|
| `Start live capture` | リアルタイムでトークンを収集・分析 |
| `Analyze now` | 収集済みトークンを即時分析 |
| `Manual load` | 手動でトークンリストを貼り付け |

---

## Decoder の操作

```
Decoder タブ → テキストを入力
```

| エンコード/デコード | 操作 |
|-----------------|------|
| URL | `Encode as` → `URL` / `Decode as` → `URL` |
| Base64 | `Encode as` → `Base64` / `Decode as` → `Base64` |
| HTML | `Encode as` → `HTML` / `Decode as` → `HTML` |
| Hex | `Encode as` → `Hex` / `Decode as` → `Hex` |
| ASCII Hex | `Encode as` → `ASCII Hex` |
| Gzip | `Encode as` → `Gzip` / `Decode as` → `Gzip` |
| Hash (MD5/SHA) | `Hash` → アルゴリズムを選択 |

---

## Comparer の操作

```
# Repeater / Proxy などから
右クリック → Send to Comparer (request / response)
```

| 操作 | 説明 |
|------|------|
| `Words` | 単語単位で差分を比較 |
| `Bytes` | バイト単位で差分を比較 |

---

## Burp Collaborator の使い方

```
Burp メニュー → Burp Collaborator client
```

| 操作 | 説明 |
|------|------|
| `Copy to clipboard` | Collaborator ペイロード URL をコピー |
| `Poll now` | Collaborator サーバへのコールバックを確認 |

```bash
# Collaborator ペイロードの使用例 (Repeater 内)
# パラメータに Collaborator URL を埋め込む
url=https://abcde.burpcollaborator.net

# Poll で DNS/HTTP コールバックを確認
```

---

## BApp Store 拡張機能のインストール

```
Extensions → BApp Store → インストールしたい拡張を選択 → Install
```

### よく使う拡張機能のインストール (コマンドライン / API)

```bash
# Burp API 経由で拡張機能の状態確認
curl "http://localhost:1337/v0.1/extensions"
```

---

## プロジェクトファイルの操作

```
# 保存
File → Save project (Ctrl + S)

# 別名で保存
File → Save project as

# 開く
File → Open project
```

---

## 参考リンク

- [Burp Suite ドキュメント](https://portswigger.net/burp/documentation)
- [Burp REST API ドキュメント](https://portswigger.net/burp/documentation/desktop/api)
- [PortSwigger Web Security Academy](https://portswigger.net/web-security)
- [BApp Store](https://portswigger.net/bappstore)
