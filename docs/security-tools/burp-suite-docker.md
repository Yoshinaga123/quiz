# Burp Suite — Docker / コンテナ構成

## 概要

> **推奨**: 手動ペンテストには **方法 1: ホストへの直接インストール** を使ってください。  
> VNC / X11 による方法は特殊な環境向けの参考情報です。

Burp Suite Community / Professional は **GUI デスクトップアプリ**であり、公式の Docker イメージは存在しない。コンテナ上で動かすには VNC または X11 転送を使って GUI をホスト側に映す構成が必要になる。

実用的な自動化は **Burp Suite Enterprise Edition** (有料) の専用エージェントを使う方法が公式サポートされている。

---

## 方法の比較

| 方法 | 難易度 | 実用性 | 用途 |
|------|--------|--------|------|
| ホストに直接インストール | 低 | ◎ | 手動ペンテスト (推奨) |
| VNC 経由でコンテナ上の GUI を操作 | 高 | △ | リモート環境での GUI 操作 |
| X11 転送でコンテナの GUI をホストに表示 | 中 | △ | Linux ホスト環境 |
| Burp Enterprise エージェント (有料) | 低 | ◎ | CI/CD 自動スキャン |

---

## 方法 1: ホストへの直接インストール (推奨)

手動ペンテストには最もシンプルで安定したアプローチ。

```bash
# Linux (Debian/Ubuntu)
wget "https://portswigger.net/burp/releases/download?product=community&type=Linux" \
  -O burpsuite_installer.sh
chmod +x burpsuite_installer.sh
./burpsuite_installer.sh

# または snap
sudo snap install burpsuite

# 起動
burpsuite
```

対象の Go API が Docker で動いている場合は、ホスト側から `http://localhost:8080` でアクセスできるので問題ない。

---

<!-- 方法 2・3 は特殊な環境向けの参考情報。通常の手動ペンテストでは方法 1 を使うこと。

## 方法 2: VNC 経由でコンテナ上の Burp GUI を操作

リモートサーバや GUI のないマシンで Burp を動かしたい場合に使う。

### Dockerfile

```dockerfile
FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    wget \
    x11vnc \
    xvfb \
    fluxbox \
    default-jdk \
    && rm -rf /var/lib/apt/lists/*

# Burp Suite Community のインストール
RUN wget -q "https://portswigger.net/burp/releases/download?product=community&type=Jar" \
    -O /opt/burpsuite.jar

# VNC 起動スクリプト
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 5900

CMD ["/start.sh"]
```

### start.sh

```bash
#!/bin/bash
# 仮想ディスプレイの起動
Xvfb :1 -screen 0 1280x800x24 &
export DISPLAY=:1

# ウィンドウマネージャ起動
fluxbox &

# Burp Suite 起動
java -jar /opt/burpsuite.jar &

# VNC サーバ起動 (パスワードなし — 信頼できる環境のみ)
x11vnc -display :1 -nopw -listen 0.0.0.0 -xkb -forever
```

### コンテナの起動

```bash
docker build -t burp-vnc .

docker run -d \
  --name burp \
  -p 5900:5900 \
  burp-vnc
```

### VNC クライアントで接続

```bash
# Linux
vncviewer localhost:5900

# macOS
open vnc://localhost:5900
```

> **セキュリティ注意**: VNC はパスワードなし設定にしている。信頼できるローカル環境のみで使用すること。本番・共有環境では必ず `-passwd /tmp/vncpass` でパスワードを設定する。

---

## 方法 3: X11 転送でコンテナの GUI をホストに表示 (Linux ホスト)

Linux ホストであれば、X11 ソケットを共有してコンテナ内の GUI をホストの画面に表示できる。

```bash
# ホストの X11 への接続を許可
xhost +local:docker

docker run -it --rm \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v $(pwd)/burpsuite.jar:/opt/burpsuite.jar \
  openjdk:17 \
  java -jar /opt/burpsuite.jar
```

-->

---

## 方法 4: Burp Suite Enterprise エージェント (有料・CI/CD 向け)

Enterprise Edition は画面なし (ヘッドレス) エージェントを提供しており、コンテナネイティブな自動スキャンが可能。

```yaml
# docker-compose.burp-enterprise.yml
services:
  go-api:
    build: ./backend
    networks:
      - scan-net

  burp-agent:
    image: portswigger/burp-enterprise-agent:latest
    environment:
      - BURP_ENTERPRISE_SERVER_URL=https://your-enterprise-server
      - BURP_ENTERPRISE_AGENT_KEY=your-agent-key
    networks:
      - scan-net

networks:
  scan-net:
```

REST API でスキャンを起動:
```bash
curl -X POST "https://your-enterprise-server/api/v1/scan" \
  -H "Authorization: Bearer $API_KEY" \
  -d '{"urls":["http://go-api:8080"]}'
```

---

## Burp Proxy をコンテナ化したアプリへ向ける構成

Burp 自体はホストで動かしつつ、コンテナで動く Go API の通信をプロキシ経由にする。

```
[ブラウザ]
    ↓ プロキシ設定 127.0.0.1:8080
[Burp Suite (ホスト)] ← GUI 操作
    ↓ 転送
[Go API コンテナ (localhost:8080)]
```

```bash
# Go API を通常通り起動
docker compose up -d

# Burp をホストで起動してプロキシ設定
burpsuite
# Proxy → Options → Proxy Listeners: 127.0.0.1:8080
# ブラウザのプロキシを 127.0.0.1:8080 に向ける
# → localhost:8080 の Go API へのアクセスが Burp を経由する
```

---

## まとめ: 用途別の選択指針

| 用途 | 推奨方法 |
|------|---------|
| 日常的な手動ペンテスト | ホストに直接インストール |
| リモートサーバで GUI を使いたい | VNC 方式 |
| Linux 環境で手軽に試したい | X11 転送 |
| CI/CD に自動スキャンを組み込みたい | Burp Enterprise (有料) または ZAP (無料) |

> **結論**: Burp Suite の手動テスト用途ではホストへの直接インストールが最もシンプルで安定している。コンテナで動く対象アプリに対しても、ホスト側の Burp からプロキシ経由でアクセスできるため、コンテナ化は必須ではない。
