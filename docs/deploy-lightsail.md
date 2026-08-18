# Lightsail 本番手順

前提: [ADR 0015](./adr/0015-lightsail-production.md)。月おおよそ 100 人。1台。

この文書は **置き場と起動手順** まで。DNS を `socrates-quiz.jp` に向ける作業（WBS 9.3）は、インスタンスの静的 IP が決まってから行う。

## コンソールで作るもの

Lightsail コンソール（東京リージョン）で、次の値に固定する。**Windows** と **Linux app**（WordPress / LAMP など）は選ばない。

### インスタンス（2 GB）

1. [インスタンスの作成] を開く。
2. インスタンスの場所を **東京 (`ap-northeast-1`)** にする。
3. プラットフォームは **Linux OS** にする（画面に Linux/Unix は出ない）。
4. イメージは **Ubuntu 24.04**（無ければ最新の Ubuntu LTS）にする。
5. プランはメモリが **2 GB** と書いてあるもの（公開 IPv4 付き）にする。金額は画面の表示に従う。
6. 名前は `socrates-quiz` にする。
7. Launch script に [`../deploy/lightsail/launch.sh`](../deploy/lightsail/launch.sh) の中身を貼る（パスワードは書かない）。
8. [インスタンスの作成] を押す。起動完了まで待つ。

すでに作ったインスタンスでは Launch script は再実行されない。その場合は SSH 後に下の Docker 手順を手で行う。

### 静的 IP

1. 左メニューの [ネットワーク] → [静的 IP の作成] を開く。
2. リージョンはインスタンスと同じ **東京** にする。
3. 名前は `socrates-quiz-ip` にする。
4. 作成した静的 IP を `socrates-quiz` に割り当てる。
5. 表示された IPv4 を控える。これが DNS の A レコードに書く値である。

### ファイアウォール

インスタンスの [ネットワーク] タブで、インターネットからの受信は **22 / 80 / 443** だけにする。8080 と 5432 は開けない。

Launch script を使った場合、数分待ってから SSH し、次で完了を確認する。

```bash
test -f /var/lib/socrates-quiz-launch.ok && echo ok
docker compose version
```

`ok` が出ない、または Docker が無いときは、同じファイルを root で実行する。

```bash
sudo bash deploy/lightsail/launch.sh
```

（リポジトリをまだ置いていなければ、`launch.sh` の中身をそのまま貼る。）

確認できたら一度ログアウトし、入り直す（`docker` グループを反映するため）。

## リポジトリを置く

```bash
git clone https://github.com/Yoshinaga123/quiz.git
cd quiz
cp deploy/lightsail/.env.example deploy/lightsail/.env
```

`deploy/lightsail/.env` を編集する。`JWT_SECRET` と DB / 管理者パスワードは開発用のままにしない。`CADDY_EMAIL` は Let’s Encrypt 用。

## 起動

リポジトリのルートから:

```bash
docker compose -f deploy/lightsail/docker-compose.yml --env-file deploy/lightsail/.env up -d --build
```

起動後、インスタンスの IP に対して `curl -sS http://127.0.0.1:8080/healthz` はコンテナ内部用。外からは Caddy 経由の 443 を使う。

DNS を向ける前は、`/etc/hosts` で `socrates-quiz.jp` と `admin.socrates-quiz.jp` を静的 IP に向けるか、Caddy を staging にする。

## DNS（公開するとき）

ドメイン側で:

| 名前 | 種別 | 値 |
| --- | --- | --- |
| `socrates-quiz.jp` | A | Lightsail 静的 IP |
| `admin.socrates-quiz.jp` | A | 同じ静的 IP |

反映後、Caddy が証明書を取る。ブラウザで `https://socrates-quiz.jp/healthz` と管理ログインを確認する。

## バックアップ

Lightsail の自動スナップショットを毎日1件残す。DB だけなら:

```bash
docker compose -f deploy/lightsail/docker-compose.yml --env-file deploy/lightsail/.env exec -T db \
  pg_dump -U "$POSTGRES_USER" "$POSTGRES_DB" > quiz-$(date +%Y%m%d).sql
```

## やってはいけないこと

- `.env` を git に入れない
- 8080 / 5432 をインターネットに開けない
- 開発用 `JWT_SECRET` / `ADMIN_PASSWORD` のまま公開しない
