#!/usr/bin/env bash
# Build and start the static-IP HTTPS stack on the Lightsail host.
set -euo pipefail

cd "$(dirname "$0")"

if [[ ! -f .env ]]; then
  echo "error: .env is missing. Copy .env.example and fill secrets + PUBLIC_IP." >&2
  exit 1
fi

# shellcheck disable=SC1091
set -a && source .env && set +a

if [[ -z "${PUBLIC_IP:-}" || "${PUBLIC_IP}" == "YOUR.STATIC.IP.HERE" ]]; then
  echo "error: set PUBLIC_IP in .env to the Lightsail static IP." >&2
  exit 1
fi

if [[ "${JWT_SECRET}" == "change-me-long-random-secret" || "${DB_PASSWORD}" == "change-me-db-password" ]]; then
  echo "error: replace placeholder secrets in .env before launching." >&2
  exit 1
fi
if [[ "${MEMBER_JWT_SECRET:-}" == "change-me-member-jwt-secret" || -z "${MEMBER_JWT_SECRET:-}" ]]; then
  echo "error: set MEMBER_JWT_SECRET in .env (separate from JWT_SECRET)." >&2
  exit 1
fi

# Expand ${PUBLIC_IP} inside VITE_ / CORS_ if the user left the template form.
if [[ "${VITE_API_BASE_URL}" == *'${PUBLIC_IP}'* ]]; then
  VITE_API_BASE_URL="https://${PUBLIC_IP}"
  export VITE_API_BASE_URL
fi
if [[ "${CORS_ALLOWED_ORIGINS}" == *'${PUBLIC_IP}'* ]]; then
  CORS_ALLOWED_ORIGINS="https://${PUBLIC_IP}"
  export CORS_ALLOWED_ORIGINS
fi

docker compose pull caddy
docker compose up --build -d
docker compose ps
echo "open:  https://${PUBLIC_IP}/"
echo "admin: https://${PUBLIC_IP}/admin/"
echo "apk:   https://${PUBLIC_IP}/downloads/socrates-quiz.apk"
echo "health: curl -fsS https://${PUBLIC_IP}/healthz"
