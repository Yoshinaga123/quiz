# w3af — Go + React + Flutter + Docker 構成での注意点

## 対象構成

```
[Flutter Mobile] ─┐
[React SPA]      ─┼─ HTTPS ──► [Go API Server] ──► [DB / 外部サービス]
                   └─── Docker コンテナで稼働
```

> **前提注意**: w3af は現在メンテナンスが低調であり、この構成でのスキャンには以下に述べる多くの制限がある。本番環境のセキュリティ診断では OWASP ZAP または Burp Suite との**併用を強く推奨する**。

---

## Go バックエンド (REST API) の注意点

### ① OpenAPI / Swagger 定義に対応していない

w3af は OpenAPI 定義ファイルを使ったエンドポイントの自動探索機能を持たない。Go の REST API は URL パスが静的な HTML リンクを持たないため、**w3af の Spider がエンドポイントを見つけられない**可能性が高い。

**回避策**: `crawl/web_spider` と `crawl/forced_browsing` を組み合わせ、既知のエンドポイントを手動でターゲットリストに追加する。

```
w3af/config:target>>> set target https://api.example.com/v1/users, https://api.example.com/v1/posts
```

### ② JSON ボディのインジェクションテストが弱い

w3af の audit プラグインは主に URL パラメータとフォームパラメータを対象としており、**JSON ボディへのインジェクション精度が低い**。Go の REST API は JSON ボディでほとんどのパラメータを受け取るため、インジェクションの見落としが発生しやすい。

**確認すべき設定**:
```
w3af/plugins>>> audit config sqli
# json_payload オプションが有効かを確認
```

> この制限は w3af の構造的な問題であり、完全な解決策はない。SQL インジェクションの網羅的なテストには **sqlmap** または **Burp Suite** の使用を推奨。

### ③ JWT 認証への対応が限定的

w3af には JWT を自動的に取得・更新する仕組みが標準で備わっていない。スキャン中に JWT が期限切れになると、以降のリクエストがすべて 401 エラーになり、**スキャンが実質的に停止する**。

**回避策**:
```
w3af/plugins>>> auth config generic
# ログイン URL・ユーザ名・パスワードを設定して定期再認証を試みる
```

ただし JWT の自動更新は確実ではないため、有効期限の長いテスト用トークンをヘッダに直接設定する方が現実的。

```
w3af>>> http-settings
w3af/config:http-settings>>> set headers_file /tmp/headers.txt
# headers.txt の内容:
# Authorization: Bearer <long-lived-test-token>
```

### ④ Go の独自エラーレスポンスを誤検知する可能性

Go のフレームワーク (Gin, Echo など) はデフォルトで独自のエラーレスポンス形式を返す。w3af のエラー検出プラグインが **誤検知 (False Positive)** を出しやすいため、結果の精査が必要。

---

## React フロントエンド (SPA) の注意点

### ⑤ JavaScript の動的解析が非常に弱い

w3af は JavaScript を実行してコンテンツを生成する SPA (React) のクロールが**ほぼできない**。`web_spider` プラグインは静的な HTML リンクしか追わないため、React Router で管理されているページのほとんどを見落とす。

**実質的な影響**:
- React アプリのページが 1 つも検出されない可能性がある
- `index.html` のみがターゲットとして認識される

**回避策**: フロントエンドの診断には w3af を使わず、ZAP の Ajax Spider または Burp Suite を使う。w3af は **Go バックエンド API の直接スキャンに集中させる**のが現実的。

### ⑥ CSP・セキュリティヘッダの検出精度が低い

w3af の `grep` プラグインによるセキュリティヘッダの検出は、最新のヘッダ (`Permissions-Policy` など) に対応していない可能性がある。

---

## Flutter モバイルの注意点

### ⑦ Flutter との組み合わせは非推奨

Flutter アプリのトラフィックをプロキシ経由でインターセプトする場合、w3af をプロキシとして使う構成は公式にはサポートされていない。w3af はプロキシモードを持つが、モバイルアプリとの連携で安定して動作するかは保証されない。

**現実的な対応**:
- Flutter アプリのトラフィックインターセプトには **Burp Suite** を使う
- w3af は Flutter が呼び出す **Go API エンドポイントを直接スキャン**する用途に限定する

### ⑧ 証明書ピンニング

Flutter が証明書ピンニングを実装している場合、w3af のプロキシ証明書を信頼しないため通信がブロックされる。ZAP・Burp Suite と同様の問題だが、w3af でのバイパス手順はドキュメントが少ない。

---

## Docker 環境の注意点

### ⑨ Docker 内コンテナへの疎通

w3af をホスト上で実行する場合、Docker コンテナが公開しているポートに対してスキャンする。

```
# ターゲットをコンテナの公開ポートで指定
w3af/config:target>>> set target http://localhost:8080
```

w3af 自体を Docker で実行する場合はネットワーク設定が必要。

```bash
docker run -it \
  --network host \          # ホストネットワークを使用
  andresriancho/w3af \
  ./w3af_console
```

または同じ Docker ネットワークに参加させる。

```bash
docker run -it \
  --network your-app-network \
  andresriancho/w3af \
  ./w3af_console
```

### ⑩ Docker イメージが古い

w3af の公式 Docker イメージ (`andresriancho/w3af`) は最終更新が古く、**Python 依存ライブラリの互換性問題が発生しやすい**。起動時にエラーが出た場合は依存関係の手動修正が必要になる。

```bash
# 起動時のエラー例
# ImportError: cannot import name 'X' from 'Y'
# → pip install --upgrade <package> で解消を試みる
```

---

## スクリプトによる自動化例 (Go API 直接スキャン)

```bash
# go_api_scan.w3af
plugins
audit sqli xss csrf os_commanding rfi lfi xxe ssrf
crawl web_spider
grep error_pages http_in_body
output console html_file
output config html_file
set output_file /tmp/report.html
back
back
http-settings
set timeout 30
back
target
set target http://go-api:8080/v1/users, http://go-api:8080/v1/posts, http://go-api:8080/v1/auth/login
back
start
exit
```

```bash
docker run -it \
  --network your-app-network \
  -v $(pwd)/go_api_scan.w3af:/home/w3af/scan.w3af \
  -v $(pwd)/reports:/tmp \
  andresriancho/w3af \
  ./w3af_console -s /home/w3af/scan.w3af
```

---

## まとめ: この構成で w3af を使う際の優先確認事項

| 優先度 | 確認事項 |
|-------|---------|
| 🔴 高 | Go API のエンドポイントをターゲットリストに手動で追加する |
| 🔴 高 | JSON ボディのインジェクションテストの限界を認識し、sqlmap で補完する |
| 🔴 高 | JWT の有効期限切れ対策として長期トークンをヘッダファイルで設定する |
| 🟡 中 | React SPA のスキャンには w3af を使わず ZAP に任せる |
| 🟡 中 | Flutter トラフィックのインターセプトには Burp Suite を使う |
| 🟡 中 | Docker イメージの古さによる依存関係エラーに備える |
| 🟢 低 | 誤検知 (False Positive) が多いため、結果を手動で精査する |

> **総合判断**: w3af はこの構成に対して **Go バックエンドの API 直接スキャン**に用途を絞るのが現実的。React・Flutter の診断は他ツールに委ねることを推奨する。
