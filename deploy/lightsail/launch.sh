#!/bin/bash
# Lightsail の Launch script に貼る。初回起動で root が一度だけ実行する。
# パスワードや JWT_SECRET は書かない。アプリの起動は SSH 後に行う。
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y ca-certificates curl git
curl -fsSL https://get.docker.com | sh

if id ubuntu >/dev/null 2>&1; then
  usermod -aG docker ubuntu
fi

touch /var/lib/socrates-quiz-launch.ok
