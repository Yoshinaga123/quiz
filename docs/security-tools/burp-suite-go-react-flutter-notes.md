# Burp Suite — Go + React + Flutter + Docker 構成での注意点

## 対象構成

```
[Flutter Mobile] ─┐
[React SPA]      ─┼─ HTTPS ──► [Go API Server] ──► [DB / 外部サービス]
                   └─── Docker コンテナで稼働
```

---

## Go バックエンド (REST API) の注意点

### ① OpenAPI 定義を使った網羅的スキャン

Burp Suite Pro の Scanner は OpenAPI / Swagger 定義ファイルを読み込み、クロールできないエンドポイントも含めて網羅的にスキャンできる。

```
Dashboard → New Scan → API scanning
→ OpenAPI definition URL: http://localhost:8080/openapi.json
```

> **注意**: Go の API が Swagger を公開していない場合、`swag init` (gin-swagger) などで生成するか、Burp の HTTP history から手動でエンドポイントを Scanner に追加する必要がある。

### ② JSON ボディへのインジェクションテスト

Burp Suite は JSON ボディのパラメータを自動的に挿入ポイントとして認識する。Go API のリクエストを Repeater で手動テストする場合も、`Content-Type: application/json` のボディを直接編集できる。

**Scanner の挿入ポイント設定確認**:
```
Scan configuration → Audit optimization
→ "Scan only in-scope items" / "JSON parameter values" が有効か確認
```

### ③ JWT 認証の期限切れ対策

Go API が JWT 認証を使っている場合、スキャン中にトークンが失効すると 401 エラーが続発する。

**対策 1: セッションハンドリングルールで自動更新**
```
Project Options → Sessions → Session Handling Rules
→ Add → Run a macro → ログインマクロを登録
→ スキャン中に自動でトークンを再取得
```

**対策 2: JWT Editor 拡張でトークンを編集・延長**
```
Extensions → BApp Store → JWT Editor をインストール
→ 有効期限を書き換えたトークンでテスト
→ 署名なし (alg: none) で通過しないかも検証
```

### ④ Go の CORS 設定の検証

Go API で `gin-cors` や `rs/cors` を使っている場合、設定ミスによる過剰な許可が起きやすい。

```
Repeater でリクエストに以下を追加して確認:
Origin: https://evil.example.com

レスポンスに
Access-Control-Allow-Origin: https://evil.example.com
Access-Control-Allow-Credentials: true
が返ってきたら問題
```

### ⑤ Burp Collaborator で Blind 系脆弱性を検出

Go API の SSRF・Blind SQL インジェクション・Blind コマンドインジェクションは、Collaborator を使った OOB 検出で発見できる。

```
Burp メニュー → Burp Collaborator client
→ Copy to clipboard でペイロード URL を取得
→ Repeater のパラメータに埋め込む
→ Poll now でコールバックを確認
```

> **注意**: Collaborator は Professional 版のみ。Community 版では使用不可。

---

## React フロントエンド (SPA) の注意点

### ⑥ 内蔵 Chromium ブラウザで SPA をクロール

Burp Suite Pro の Scanner は内蔵 Chromium エンジンで JavaScript を実行し、React Router のページを正しくクロールできる。

```
Dashboard → New Scan
→ Scan type: Crawl and Audit
→ "Use embedded browser" を有効化
```

Community 版では Scanner が使えないため、Proxy 経由で手動ブラウジングして HTTP history に記録させてから Repeater / Intruder で検証する。

### ⑦ React の DOM XSS 検出

Burp Suite Pro は JavaScript を実行して DOM XSS を検出できる。`dangerouslySetInnerHTML` や `eval()` の使用箇所が検出対象になる。

> **注意**: React の仮想 DOM は多くの XSS を防ぐが、`dangerouslySetInnerHTML` を使っている箇所は脆弱になり得る。Scanner の DOM XSS 検出を有効にして確認する。

### ⑧ CSP ヘッダの検証

React アプリのレスポンスに適切な CSP が設定されているかをパッシブスキャンで確認する。

```
Proxy → HTTP history → レスポンスヘッダを確認
Content-Security-Policy が含まれているか確認

含まれていない場合:
→ Issue Activity に "Content security policy not implemented" が記録される
```

---

## Flutter モバイルの注意点

### ⑨ プロキシの設定 (Android エミュレータ)

```bash
# Android エミュレータのプロキシを Burp に向ける
emulator -avd <AVD名> -http-proxy 127.0.0.1:8080

# または ADB で設定
adb shell settings put global http_proxy 127.0.0.1:8080
```

### ⑩ プロキシの設定 (iOS シミュレータ)

```
macOS: システム環境設定 → ネットワーク → Wi-Fi → 詳細 → プロキシ
→ Web プロキシ (HTTP): 127.0.0.1:8080
→ セキュア Web プロキシ (HTTPS): 127.0.0.1:8080
```

### ⑪ Burp CA 証明書のインストール

```
# Burp から証明書をエクスポート
http://burpsuite → CA Certificate をダウンロード → cacert.der

# Android: 設定 → セキュリティ → 証明書のインストール
# iOS: 証明書をデバイスに転送 → 設定 → 一般 → VPN とデバイス管理 → インストール
#      → 設定 → 一般 → 情報 → 証明書信頼設定 → 有効化
```

> **注意**: Android 7 (API 24) 以降、ユーザー証明書はデフォルトでアプリに信頼されない。Flutter アプリが `network_security_config` でユーザー証明書を信頼するよう設定が必要（テスト環境のみ）。

```xml
<!-- android/app/src/main/res/xml/network_security_config.xml -->
<network-security-config>
  <debug-overrides>
    <trust-anchors>
      <certificates src="user" />
    </trust-anchors>
  </debug-overrides>
</network-security-config>
```

### ⑫ 証明書ピンニングのバイパス

Flutter アプリが証明書ピンニングを実装している場合、Burp の CA 証明書を信頼しても通信がブロックされる。

**確認方法**:
```
Burp の Proxy → HTTP history に Flutter アプリの通信が記録されるか確認
記録されない → ピンニングが実装されている可能性大
```

**バイパス方法 (テスト環境のみ)**:

```bash
# Frida を使ったピンニングバイパス
frida -U -f com.example.myapp \
  -l ssl_pinning_bypass.js \
  --no-pause
```

または Flutter のデバッグビルドでピンニングを無効化したビルドを用意する。

> **警告**: ピンニングバイパスは必ずテスト環境のみで実施すること。本番アプリへの適用は不正アクセスにあたる。

### ⑬ HTTP/2 と gRPC の対応

Flutter が gRPC または HTTP/2 を使っている場合、Burp Suite は標準でインターセプト可能。ただし gRPC の protobuf 形式のデコードには **Burp の gRPC 拡張**が必要。

```
Extensions → BApp Store → "gRPC" を検索 → インストール
```

---

## Docker 環境の注意点

### ⑭ localhost ではなくコンテナ名・IP で指定

Burp をホスト上で動かし、Docker コンテナのアプリをスキャンする場合、コンテナが公開するポートの IP を正確に指定する。

```bash
# コンテナの公開ポートを確認
docker ps --format "table {{.Names}}\t{{.Ports}}"

# Burp のターゲット設定
Target → Scope → Add
→ http://localhost:8080 (ポートフォワードされている場合)
```

### ⑮ Docker ネットワーク内の直接スキャン

Burp をコンテナ内部からスキャンしたい場合は、同じ Docker ネットワークに Burp コンテナを配置する。ただし Burp Suite は公式 Docker イメージを提供していないため、画面なし (ヘッドレス) での利用は Enterprise 版が必要。

```yaml
# docker-compose.yml での構成 (Pro を画面なしで使う場合)
services:
  burp-enterprise:
    image: portswigger/enterprise-server:latest
    networks:
      - app-network
    environment:
      - LICENSE_KEY=${BURP_LICENSE_KEY}

  go-api:
    build: ./backend
    networks:
      - app-network
```

### ⑯ HTTPS (自己署名証明書) 環境

本番に近い HTTPS 環境でスキャンする場合、Burp はデフォルトで TLS ハンドシェイクの詳細を記録する。自己署名証明書は Burp が自動的に中間者として処理するため、通常の設定で HTTPS トラフィックをインターセプト可能。

---

## Autorize 拡張を使った認可テスト (IDOR 対策)

Go API の IDOR (Insecure Direct Object Reference) を検出するには Autorize 拡張を使う。

```
1. Extensions → BApp Store → Autorize をインストール
2. Proxy → ユーザー A でログインして通常操作 → HTTP history に記録
3. Autorize タブ → ユーザー B のトークンを設定
4. ユーザー A の操作を Autorize が自動でユーザー B のトークンで再送
5. レスポンスが同じなら IDOR の可能性
```

---

## まとめ: この構成で Burp Suite を使う際の優先確認事項

| 優先度 | 確認事項 | Community | Professional |
|-------|---------|-----------|--------------|
| 🔴 高 | JWT の期限切れ対策 (セッションハンドリングルール) | △ 手動 | ◎ 自動 |
| 🔴 高 | Flutter の CA 証明書インストール + プロキシ設定 | ◎ | ◎ |
| 🔴 高 | 証明書ピンニングの確認・バイパス | ◎ | ◎ |
| 🔴 高 | Android の network_security_config 設定 | ◎ | ◎ |
| 🟡 中 | OpenAPI 定義を使った API 網羅スキャン | ✕ | ◎ |
| 🟡 中 | Collaborator による Blind 系脆弱性検出 | ✕ | ◎ |
| 🟡 中 | Autorize 拡張による IDOR テスト | ◎ | ◎ |
| 🟡 中 | 内蔵 Chromium で React SPA をクロール | ✕ | ◎ |
| 🟡 中 | gRPC を使う場合は gRPC 拡張をインストール | ◎ | ◎ |
| 🟢 低 | Docker ネットワーク設定 | ◎ | ◎ |
