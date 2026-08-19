# Lightsail 静的 IP を HTTPS で公開する（ADR 0015）

ドメインなし・**HTTPS + 静的 IP** で公開する手順を正とする。  
Compose は [`../deploy/lightsail/`](../deploy/lightsail/)。Caddy が Let's Encrypt の短期 IP アドレス証明書を取得・自動更新する。

## 構成

```text
Internet --:80/443--> Caddy --+--> web (nginx SPA)
                              +--> api:8080 (/v1, /healthz, /counter)
                              +--> db (Postgres, not published)
```

- 公開ポートは **22 / 80 / 443 のみ**（8080 / 5432 は開けない）
- `/api`（管理・会員 API）と `/admin` は HTTPS 経由で公開する。管理者ログインは検証コード必須
- ファイアウォールは **22 / 80 / 443**。22 は管理者 IP に限定する
- SPA の API ベースはビルド時の `VITE_API_BASE_URL=https://<静的IP>`
- 160 時間の短期証明書を自動更新するため、`caddy_data` ボリュームを削除しない

## 前提

1. AWS にログインできること（このマシンで切れているときは `aws login`）
2. リポジトリをインスタンスへ置けること（`git clone` または `scp`）

## 手順

### 1. Lightsail インスタンス

- リージョン: `ap-northeast-1`（東京）推奨
- OS: Ubuntu 24.04
- プラン: 1 GB RAM 以上推奨（Compose ビルド用）
- ネットワーク: **TCP 22 / 80 / 443** を許可
- **静的 IP** を作成してインスタンスにアタッチし、値を控える

### 2. ホスト準備（SSH 後）

Docker 公式リポジトリが入っているマシンでは `docker.io` は入れない（`containerd` と衝突する）。

```bash
sudo apt update
# すでに docker.com のリポジトリがある場合
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin git
# 公式リポジトリが無い場合のみ: sudo apt install -y docker.io docker-compose-v2 git

sudo usermod -aG docker "$USER"
# 一度ログアウトして入り直す
docker version
docker compose version
```

### 3. アプリ配置

```bash
git clone https://github.com/Yoshinaga123/quiz.git
cd quiz/deploy/lightsail
cp .env.example .env
```

`.env` を編集する。

- `PUBLIC_IP` … 静的 IP
- `DB_PASSWORD` / `ADMIN_PASSWORD` / `JWT_SECRET` … プレースホルダを必ず変更

```bash
chmod +x launch.sh
./launch.sh
```

### 4. 確認

```bash
curl -fsS https://<静的IP>/healthz
curl -fsS https://<静的IP>/v1/sections
```

ブラウザで `https://<静的IP>/` を開き、1 セッション解いて結果まで進む。  
`POST /v1/attempts` は結果確定時に best-effort 送信される。

`http://<静的IP>/` は HTTPS へ恒久リダイレクトされる。

### 5. 更新（手動）

```bash
cd ~/quiz
git pull
cd deploy/lightsail
./launch.sh
```

または CD 用スクリプト:

```bash
~/quiz/deploy/lightsail/remote-update.sh
```

IP を変えたときは `.env` の `PUBLIC_IP` を直し、**web イメージを再ビルド**する（`VITE_API_BASE_URL` が焼き付くため）。

## CD（GitHub Actions → Lightsail）

`develop` への push（web / admin-web / backend / deploy の変更）または workflow_dispatch で  
[`.github/workflows/deploy-lightsail.yml`](../.github/workflows/deploy-lightsail.yml) が動く。

### なぜ self-hosted か

ファイアウォールで **22 を管理者 IP のみ**にしているため、GitHub ホストランナーからの SSH は届かない。  
インスタンス上に Actions runner を置き、**外向き通信だけ**でジョブを取る方式にする。

### 初回セットアップ（インスタンス上）

1. GitHub → Settings → Actions → Runners → **New self-hosted runner**（Linux x64）
2. 表示された `config.sh` / `run.sh` 手順に従う
3. ラベルに **`lightsail`** を付ける（workflow の `runs-on: [self-hosted, lightsail]`）
4. サービス化して常駐させる（公式の `svc.sh install` / `start`）
5. runner ユーザーが `docker` グループに入り、`~/quiz` が clone 済みであること
6. `deploy/lightsail/.env` は手で用意済みであること（CD は `.env` を作らない）

確認:

```bash
# Actions タブで "Deploy Lightsail" → Run workflow
# または develop に deploy 対象パスを push
curl -fsS https://<静的IP>/healthz
```

### 安全上の注意

- runner は本番ホスト上の権限を持つ。リポジトリへの書き込み権限を持つ人だけが Actions を起動できる前提
- `.env` や PEM を workflow に載せない
- 失敗時は Actions ログと `docker compose -f ~/quiz/deploy/lightsail/docker-compose.yml ps` を見る

## 秘密情報

- `.env` はコミットしない
- プレースホルダのまま `launch.sh` は起動しない
- 確認が終わったらインスタンス停止か、ファイアウォールを絞る

## あとからドメインを追加するとき

1. ドメインを取得し、A レコードを同じ静的 IP へ向ける
2. Caddyfile のサイトアドレスをホスト名へ変更する
3. `VITE_API_BASE_URL` / `CORS_ALLOWED_ORIGINS` を `https://…` にして再ビルド

## 関連

- [ADR 0015](./adr/0015-lightsail-production.md)
- [`deploy/lightsail/docker-compose.yml`](../deploy/lightsail/docker-compose.yml)
- [`SECURITY.md`](../SECURITY.md)
