# w3af コマンド一覧

## CLI 起動オプション

```bash
# コンソールモードで起動
./w3af_console

# GUI モードで起動
./w3af_gui

# スクリプトファイルを指定して実行
./w3af_console -s <スクリプトファイル>

# ノーカラーモード (CI 向け)
./w3af_console --no-color

# デバッグモード
./w3af_console -d
```

| オプション | 説明 |
|-----------|------|
| `-s <ファイル>` | w3af スクリプトファイルを実行 |
| `--no-color` | カラー出力を無効化 |
| `-d` | デバッグモード (詳細ログ出力) |
| `-v <0-10>` | ログの詳細レベルを指定 |
| `-h` | ヘルプを表示 |

---

## コンソールモードのコマンド体系

w3af_console は階層的なコマンド構造になっています。

```
w3af>>>                     # トップレベル
w3af/plugins>>>             # プラグイン設定
w3af/config:target>>>       # ターゲット設定
w3af/profiles>>>            # プロファイル選択
w3af/kb>>>                  # スキャン結果の保存場所 (ナレッジベース)
w3af/exploit>>>             # エクスプロイト
```

---

## トップレベルコマンド

| コマンド | 説明 |
|---------|------|
| `help` | ヘルプを表示 |
| `start` | スキャンを開始 |
| `stop` | スキャンを停止 |
| `pause` | スキャンを一時停止 |
| `resume` | スキャンを再開 |
| `plugins` | プラグイン設定モードに移行 |
| `target` | ターゲット設定モードに移行 |
| `profiles` | プロファイル管理モードに移行 |
| `kb` | スキャン結果の保存場所 (ナレッジベース) を表示 |
| `exploit` | エクスプロイトモードに移行 |
| `http-settings` | HTTP 接続設定モードに移行 |
| `misc-settings` | その他の設定モードに移行 |
| `back` | 1 つ上の階層に戻る |
| `exit` | w3af を終了 |
| `assert` | 条件を評価 (スクリプト用) |
| `version` | バージョン情報を表示 |
| `keys` | キーボードショートカットを表示 |

---

## ターゲット設定

```
w3af>>> target
w3af/config:target>>> help

# ターゲット URL を設定 (単一)
w3af/config:target>>> set target https://example.com

# 複数 URL を設定 (カンマ区切り)
w3af/config:target>>> set target https://example.com, https://example.com/api

# 現在の設定を確認
w3af/config:target>>> view

# 設定を保存して戻る
w3af/config:target>>> back
```

---

## プラグインコマンド

```
w3af>>> plugins
```

| コマンド | 説明 |
|---------|------|
| `list <カテゴリ>` | プラグイン一覧を表示 |
| `<カテゴリ> <プラグイン名>` | プラグインを有効化 |
| `<カテゴリ> config <プラグイン名>` | プラグインの設定を変更 |
| `<カテゴリ> all` | カテゴリ内の全プラグインを有効化 |
| `back` | 上の階層に戻る |

### プラグインカテゴリ一覧

```bash
# 各カテゴリのプラグインを一覧表示
w3af/plugins>>> list audit
w3af/plugins>>> list crawl
w3af/plugins>>> list grep
w3af/plugins>>> list infrastructure
w3af/plugins>>> list auth
w3af/plugins>>> list output
w3af/plugins>>> list mangle
w3af/plugins>>> list evasion
w3af/plugins>>> list bruteforce
```

### よく使うプラグインの有効化

```
w3af/plugins>>> audit sqli xss csrf os_commanding file_read rfi lfi
w3af/plugins>>> crawl web_spider
w3af/plugins>>> grep dom_xss error_pages backup_file_name
w3af/plugins>>> output console text_file html_file
```

### プラグインの設定変更

```
w3af/plugins>>> output config text_file
w3af/plugins/output/config:text_file>>> set output_file /tmp/w3af_output.txt
w3af/plugins/output/config:text_file>>> set verbose True
w3af/plugins/output/config:text_file>>> back

w3af/plugins>>> output config html_file
w3af/plugins/output/config:html_file>>> set output_file /tmp/report.html
w3af/plugins/output/config:html_file>>> back
```

---

## 主要 audit プラグイン

| プラグイン名 | 検査対象の脆弱性 |
|------------|--------------|
| `sqli` | SQL インジェクション |
| `blind_sqli` | ブラインド SQL インジェクション |
| `xss` | クロスサイトスクリプティング |
| `csrf` | CSRF |
| `os_commanding` | OS コマンドインジェクション |
| `file_read` | パストラバーサル |
| `lfi` | ローカルファイルインクルード |
| `rfi` | リモートファイルインクルード |
| `xxe` | XML External Entity インジェクション |
| `ssrf` | サーバサイドリクエストフォージェリ |
| `ssti` | サーバサイドテンプレートインジェクション |
| `open_redirect` | オープンリダイレクト |
| `xpath` | XPath インジェクション |
| `ldapi` | LDAP インジェクション |
| `buffer_overflow` | バッファオーバーフロー |
| `format_string` | フォーマット文字列攻撃 |
| `http_header_injection` | HTTP ヘッダインジェクション |
| `basic_auth` | HTTP 基本認証のブルートフォース |

---

## 主要 crawl プラグイン

| プラグイン名 | 説明 |
|------------|------|
| `web_spider` | 通常の Web クローリング |
| `forced_browsing` | 既知パスへの強制アクセス |
| `google_spider` | Google 検索結果からの URL 収集 |
| `robots_txt` | robots.txt から URL を収集 |
| `sitemap_xml` | sitemap.xml から URL を収集 |
| `url_fuzzer` | URL のファジング |

---

## プロファイルコマンド

```
w3af>>> profiles
```

| コマンド | 説明 |
|---------|------|
| `list` | 利用可能なプロファイル一覧 |
| `use <プロファイル名>` | プロファイルを読み込む |
| `save_as <名前>` | 現在の設定をプロファイルとして保存 |
| `delete <プロファイル名>` | プロファイルを削除 |
| `back` | 上の階層に戻る |

### 標準プロファイル

| プロファイル名 | 用途 |
|-------------|------|
| `OWASP_TOP10` | OWASP Top 10 チェック |
| `fast_scan` | 高速スキャン |
| `full_audit` | 全プラグインを使った網羅的スキャン |
| `bruteforce` | 認証ブルートフォース |
| `web_infrastructure` | インフラ情報収集 |
| `empty_profile` | 空のプロファイル |

```
w3af>>> profiles
w3af/profiles>>> list
w3af/profiles>>> use OWASP_TOP10
w3af/profiles>>> back
w3af>>> start
```

---

## HTTP 設定コマンド

```
w3af>>> http-settings
```

| 設定キー | 説明 | 例 |
|---------|------|-----|
| `timeout` | リクエストタイムアウト (秒) | `set timeout 30` |
| `headers_file` | カスタムヘッダファイル | `set headers_file /tmp/headers.txt` |
| `user_agent` | User-Agent 文字列 | `set user_agent Mozilla/5.0` |
| `proxy_address` | プロキシアドレス | `set proxy_address 127.0.0.1` |
| `proxy_port` | プロキシポート | `set proxy_port 8080` |
| `basic_auth_user` | HTTP 基本認証ユーザ | `set basic_auth_user admin` |
| `basic_auth_pass` | HTTP 基本認証パスワード | `set basic_auth_pass password` |
| `cookie_jar_file` | Cookie ファイル | `set cookie_jar_file /tmp/cookies.txt` |

---

## スクリプトによる自動化

`.w3af` 拡張子のスクリプトファイルでコマンドを自動実行できます。

```bash
# scan.w3af
profiles
use OWASP_TOP10
back
target
set target https://example.com
back
plugins
output console, html_file
output config html_file
set output_file /tmp/report.html
back
back
start
exit
```

```bash
# スクリプトを実行
./w3af_console -s scan.w3af
```

---

## Docker での実行

```bash
# Docker コンテナ内でスクリプト実行
docker run -it \
  -v $(pwd)/scan.w3af:/home/w3af/scan.w3af \
  -v $(pwd)/reports:/tmp/reports \
  andresriancho/w3af \
  ./w3af_console -s /home/w3af/scan.w3af

# コンテナに入って手動操作
docker run -it andresriancho/w3af /bin/bash
```

---

## スキャン結果の確認 (ナレッジベース)

```
w3af>>> kb
```

| コマンド | 説明 |
|---------|------|
| `list` | 検出した脆弱性の一覧 |
| `list <脆弱性名>` | 指定した脆弱性の詳細一覧 |
| `get <脆弱性名> <番号>` | 特定の脆弱性の詳細を表示 |
| `back` | 上の階層に戻る |

```
w3af>>> kb
w3af/kb>>> list
w3af/kb>>> list sqli
w3af/kb>>> get sqli 0
```

---

## 参考リンク

- [w3af ドキュメント](http://docs.w3af.org/)
- [w3af GitHub リポジトリ](https://github.com/andresriancho/w3af)
- [w3af プラグイン一覧](http://docs.w3af.org/en/latest/plugins.html)
