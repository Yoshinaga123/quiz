# Burp Suite セットアップ手順

## 動作環境

- Java 17 以上 (インストーラに同梱)
- Windows / macOS / Linux

---

## 1. インストール

### 公式サイトからダウンロード

1. [https://portswigger.net/burp/releases](https://portswigger.net/burp/releases) にアクセス
2. エディションを選択:
   - **Community Edition** (無料): 基本的なプロキシ・手動テスト
   - **Professional** (有料): 自動スキャン・全機能
3. プラットフォーム向けのインストーラをダウンロードして実行

### Linux (コマンドライン)

```bash
# インストーラをダウンロード (バージョンは最新に合わせて変更)
wget "https://portswigger.net/burp/releases/download?product=community&version=latest&type=Linux" \
  -O burpsuite_community_linux.sh

chmod +x burpsuite_community_linux.sh
./burpsuite_community_linux.sh
```

### macOS (Homebrew)

```bash
brew install --cask burp-suite
```

---

## 2. 初回起動と設定

```bash
# GUI 起動 (インストール後)
burpsuite

# またはインストールディレクトリから
/opt/BurpSuiteCommunity/BurpSuiteCommunity
```

起動後:
1. 「Temporary project」→「Use Burp defaults」→「Start Burp」

---

## 3. CA 証明書のインストール

HTTPS をインターセプトするために CA 証明書のインストールが必要です。

### 証明書のエクスポート

1. Burp を起動した状態でブラウザから `http://burpsuite` にアクセス
2. 「CA Certificate」をクリックしてダウンロード

### Firefox へのインポート

1. 設定 → プライバシーとセキュリティ → 証明書を表示
2. 「認証局」タブ → 「インポート」
3. ダウンロードした `cacert.der` を選択
4. 「この認証局によるウェブサイトの識別を信頼する」にチェック

### Chrome / Chromium へのインポート

```bash
# Linux の場合
certutil -d sql:$HOME/.pki/nssdb -A -t "CT,," \
  -n BurpSuite -i cacert.der
```

### システム全体 (Linux)

```bash
sudo cp cacert.der /usr/local/share/ca-certificates/burpsuite.crt
sudo update-ca-certificates
```

---

## 4. ブラウザのプロキシ設定

Burp はデフォルトで `127.0.0.1:8080` でリッスンします。

### Firefox

1. 設定 → ネットワーク設定 → 接続設定
2. 手動でプロキシを設定:
   - HTTP プロキシ: `127.0.0.1`、ポート: `8080`
   - 「HTTPS にもこのプロキシを使用する」をチェック

### FoxyProxy (拡張機能) を使う場合 (推奨)

1. Firefox に [FoxyProxy](https://addons.mozilla.org/ja/firefox/addon/foxyproxy-standard/) をインストール
2. 新規プロキシを追加: `127.0.0.1:8080`
3. Burp 使用時のみ ON に切り替えることができ便利

---

## 5. Intercept (インターセプト) の使い方

1. Burp の「Proxy」タブ → 「Intercept is on」になっていることを確認
2. ブラウザでターゲットサイトにアクセス
3. Burp にリクエストが停止される
4. 内容を確認・編集後「Forward」で送信、または「Drop」で破棄

---

## 6. 主要機能

| 機能 | 説明 |
|------|------|
| **Proxy** | ブラウザとサーバ間のトラフィックをインターセプト |
| **Repeater** | リクエストを手動で繰り返し送信・編集 |
| **Intruder** | パラメータに対するファジング・ブルートフォース (Community は速度制限あり) |
| **Scanner** | 自動脆弱性スキャン (Professional のみ) |
| **Decoder** | エンコード/デコード (Base64, URL, HTML など) |
| **Comparer** | 2 つのレスポンスの差分比較 |
| **Sequencer** | トークンのランダム性を分析 |

---

## 7. Repeater の使い方

1. 「Proxy」→「HTTP history」でリクエストを右クリック
2. 「Send to Repeater」を選択
3. 「Repeater」タブでリクエストを編集して「Send」

---

## 8. プロジェクトの保存 (Professional)

```
File → Save project
File → Open project
```

Community 版はセッションをまたぐ保存ができません。

---

## 9. 拡張機能 (BApp Store)

1. 「Extensions」タブ → 「BApp Store」
2. 有用な拡張機能の例:
   - **Autorize**: 認可テストの自動化
   - **Logger++**: 高機能ログ記録
   - **JWT Editor**: JWT の解析・改ざん
   - **Param Miner**: 隠しパラメータの発見

---

## 注意事項

- スキャン対象は **自分が管理するシステム** または **明示的に許可されたシステム** のみに限定すること
- Intruder の速度制限 (Community 版) を回避するためのツール使用は利用規約違反
- 本番環境へのスキャンは事前に関係者の承認を得ること

---

## 作業ログ

### 2026-05-29 — 初回セットアップ試行

#### 環境

- OS: Ubuntu 22.04 (ヘッドレスサーバー、VS Code Server 経由)
- Java: OpenJDK 11.0.30

#### snap インストール試行 → 失敗

```bash
$ snap install burpsuite
error: access denied (try with sudo)

$ sudo snap install burpsuite
error: snap "burpsuite" not found
```

> snap ストアに `burpsuite` パッケージが存在しなかった。  
> `snap find burp` で検索しても該当なし。

#### JAR 直接ダウンロード

```bash
$ wget "https://portswigger.net/burp/releases/download?product=community&type=Jar" \
    -O /tmp/burpsuite_community.jar
# → 653MB ダウンロード成功 (2026-04-20 ビルド)
```

#### 起動試行 → Java バージョン不足でエラー

```bash
$ java -Djava.awt.headless=true -jar /tmp/burpsuite_community.jar --version
Error: LinkageError occurred while loading main class burp.StartBurp
    java.lang.UnsupportedClassVersionError: burp/StartBurp has been compiled by a
    more recent version of the Java Runtime (class file version 65.0), this version
    of the Java Runtime only recognizes class file versions up to 55.0
```

**原因:** Burp Suite の最新版は Java 21 (class file version 65.0) でビルドされているが、システムの Java は 11 (class file version 55.0) のため起動不可。

**対処:** Java 21 をインストールすれば起動できるが、このサーバー環境は **GUI なしのヘッドレス環境** であるため、GUI ベースの Burp Suite は実質的に使用できない。

#### 結論

| 問題 | 内容 |
|---|---|
| snap パッケージ | ストアに存在しない |
| Java バージョン不足 | Java 11 では起動不可（Java 21 が必要） |
| GUI 不可 | ヘッドレスサーバー環境のため GUI ツールとして使用できない |
| Docker イメージ | 公式イメージなし（`burp-suite-docker.md` 参照） |

**→ このプロジェクトのサーバー環境では Burp Suite Community の実動作確認は不可。**  
ローカルの GUI 環境（デスクトップ PC）でのみ使用可能。
