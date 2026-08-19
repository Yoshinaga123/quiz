#!/usr/bin/env bash
# Idempotent update used by CD (self-hosted runner on the Lightsail host).
# Expects the repo already cloned at QUIZ_ROOT (default: ~/quiz).
set -euo pipefail

QUIZ_ROOT="${QUIZ_ROOT:-$HOME/quiz}"
BRANCH="${DEPLOY_BRANCH:-develop}"
COMPOSE_DIR="${QUIZ_ROOT}/deploy/lightsail"

if [[ ! -d "${QUIZ_ROOT}/.git" ]]; then
  echo "error: ${QUIZ_ROOT} is not a git checkout" >&2
  exit 1
fi

if [[ ! -x "${COMPOSE_DIR}/launch.sh" ]]; then
  echo "error: missing ${COMPOSE_DIR}/launch.sh" >&2
  exit 1
fi

cd "${QUIZ_ROOT}"
git fetch origin "${BRANCH}"
git checkout "${BRANCH}"
git reset --hard "origin/${BRANCH}"

cd "${COMPOSE_DIR}"
./launch.sh

# shellcheck disable=SC1091
set -a && source .env && set +a
if [[ "${VITE_API_BASE_URL}" == *'${PUBLIC_IP}'* ]]; then
  VITE_API_BASE_URL="https://${PUBLIC_IP}"
fi

health_url="${VITE_API_BASE_URL%/}/healthz"
echo "smoke: ${health_url}"
curl -fsS --retry 5 --retry-delay 3 --retry-connrefused "${health_url}"
echo
curl -fsS --retry 3 --retry-delay 2 "${VITE_API_BASE_URL%/}/v1/sections" >/dev/null
echo "cd ok: ${VITE_API_BASE_URL%/}/"
