# w3af セットアップ手順

## 動作環境

- Python 3.x
- Linux (推奨) / macOS
- Windows は非推奨 (動作不安定)

> **注意**: w3af は現在メンテナンスが低調です。Python の依存ライブラリの互換性問題が発生することがあります。Docker 経由の使用を推奨します。

---

## 1. インストール

### Docker (推奨)

```bash
docker pull andresriancho/w3af
```

### ソースからインストール (Linux)

```bash
# 依存パッケージのインストール
sudo apt-get update
sudo apt-get install -y python3 python3-pip python3-dev git \
  libssl-dev libffi-dev build-essential

# リポジトリのクローン
git clone https://github.com/andresriancho/w3af.git
cd w3af

# 依存ライブラリのインストール
pip3 install -r requirements.txt

# 不足パッケージがある場合は自動インストールスクリプトを実行
./w3af_console
# 不足パッケージを検出したら y で自動インストール
```

---

## 2. 起動方法

### Docker で起動

```bash
# コンソールモード
docker run -it andresriancho/w3af /bin/bash
# コンテナ内で
./w3af_console

# GUI モード (X11 が必要)
docker run -it \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  andresriancho/w3af ./w3af_gui
```

### ネイティブ起動

```bash
cd w3af

# コンソールモード
./w3af_console

# GUI モード
./w3af_gui
```

---

## 3. コンソールモードでのスキャン

```
# w3af_console 起動後

# プロファイルの読み込み (推奨)
w3af>>> profiles
w3af/profiles>>> use OWASP_TOP10
w3af/profiles>>> back

# ターゲット設定
w3af>>> target
w3af/config:target>>> set target https://example.com
w3af/config:target>>> back

# スキャン開始
w3af>>> start

# 結果確認
w3af>>> kb
```

---

## 4. プロファイル一覧

| プロファイル名 | 用途 |
|--------------|------|
| `bruteforce` | 認証ブルートフォース |
| `fast_scan` | 高速スキャン |
| `full_audit` | フルスキャン |
| `OWASP_TOP10` | OWASP Top 10 チェック |
| `web_infrastructure` | インフラ情報収集 |

---

## 5. スクリプトによる自動化

w3af はスクリプトファイル (`.w3af`) を使って自動化できます。

```bash
# scan_script.w3af
plugins
output console, text_file
output config text_file
set output_file /tmp/w3af_output.txt
back
audit sqli, xss
crawl web_spider
back
target
set target https://example.com
back
start
exit
```

```bash
./w3af_console -s scan_script.w3af
```

---

## 6. レポート出力

```
w3af>>> plugins
w3af/plugins>>> output html_file
w3af/plugins>>> output config html_file
w3af/plugins/output/config:html_file>>> set output_file /tmp/report.html
w3af/plugins/output/config:html_file>>> back
w3af/plugins>>> back
```

---

## トラブルシューティング

### 依存ライブラリエラー

```bash
# pip パッケージを強制再インストール
pip3 install --force-reinstall -r requirements.txt

# 特定バージョンの Python を使用する場合
python3.8 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### `ModuleNotFoundError` が出る場合

```bash
# 不足モジュールを個別インストール
pip3 install <module_name>
```

---

## 注意事項

- スキャン対象は **自分が管理するシステム** または **明示的に許可されたシステム** のみに限定すること
- w3af はメンテナンスが低調なため、最新の脆弱性への対応が不完全な場合がある
