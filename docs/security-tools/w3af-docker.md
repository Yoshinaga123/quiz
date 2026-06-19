# w3af — Docker コンテナ構成

## 概要

w3af は Linux ネイティブのツールであり、公式ではないが Docker イメージが存在する。依存ライブラリのバージョン問題を回避するためにも Docker 経由での使用が推奨される。ただしイメージが古く、安定性に課題がある。

---

## イメージの取得

```bash
# コミュニティが管理するイメージ (最もよく使われる)
docker pull andresriancho/w3af

# 動作確認
docker run --rm andresriancho/w3af ./w3af_console --version
```

---

## 起動パターン

### パターン 1: 対話型コンソール

```bash
docker run -it \
  --network host \
  andresriancho/w3af \
  ./w3af_console
```

`--network host` にすることで、ホストマシン上で動いている Go API (`localhost:8080`) に直接アクセスできる。

### パターン 2: スクリプトファイルを使った自動実行

```bash
# スクリプトファイルを作成
cat << 'EOF' > scan.w3af
plugins
audit sqli blind_sqli xss redos buffer_overflow
crawl web_spider
grep error_pages
output console html_file
output config html_file
set output_file /tmp/report.html
back
back
target
set target http://localhost:8080
back
start
exit
EOF

# スクリプトとレポート出力先をマウントして実行
docker run --rm \
  --network host \
  -v $(pwd)/scan.w3af:/home/w3af/scan.w3af \
  -v $(pwd)/reports:/tmp \
  andresriancho/w3af \
  ./w3af_console -s /home/w3af/scan.w3af
```

---

## Docker Compose での構成

```yaml
# docker-compose.w3af.yml
services:
  go-api:
    build: ./backend
    ports:
      - "8080:8080"
    networks:
      - scan-net

  w3af:
    image: andresriancho/w3af
    stdin_open: true
    tty: true
    volumes:
      - ./scan.w3af:/home/w3af/scan.w3af
      - ./reports:/tmp
    networks:
      - scan-net
    depends_on:
      - go-api
    command: ./w3af_console -s /home/w3af/scan.w3af

networks:
  scan-net:
```

```bash
docker compose -f docker-compose.w3af.yml up

# スキャン完了後にレポートを確認
ls -la reports/
```

> **注意**: Docker 内部ネットワークを使う場合、スクリプト内のターゲット URL は `localhost` ではなく Compose サービス名を使う。
> ```
> set target http://go-api:8080
> ```

---

## レポートの取り出し

```bash
# ボリュームマウントでホストに直接出力
-v $(pwd)/reports:/tmp

# または docker cp でコンテナからコピー
docker cp w3af_container:/tmp/report.html ./w3af_report.html
```

---

## コンテナ運用上の注意点

| 項目 | 注意内容 |
|------|---------|
| イメージの鮮度 | `andresriancho/w3af` は更新が止まっており、最新の脆弱性パターンに未対応の可能性あり |
| Python 依存 | コンテナ内の Python / ライブラリが古く、一部プラグインが実行時エラーになる場合あり |
| クラッシュ | 長時間スキャン中にクラッシュする報告がある。重要な検査は ZAP で補完する |
| JSON API | JSON ボディへの注入テスト精度が低い。`--network host` で ZAP を別途動かす方が確実 |
| ログ出力 | `-s` オプションでスクリプト実行時は標準出力のログが少なくなる。`output console` を plugins に追加する |

---

## CI/CD での使用 (限定的)

w3af はスキャン中にクラッシュする可能性があるため、CI/CD の主力には向かない。補完的な用途に限定する。

```yaml
# GitHub Actions での例 (ZAP の補完として)
- name: w3af ReDoS Check
  run: |
    docker run --rm \
      --network host \
      -v ${{ github.workspace }}/scan.w3af:/home/w3af/scan.w3af \
      -v ${{ github.workspace }}/reports:/tmp \
      andresriancho/w3af \
      ./w3af_console -s /home/w3af/scan.w3af || true
    # || true : クラッシュしても CI を止めない
```
