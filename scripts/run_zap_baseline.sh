#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT_DIR/reports/security/zap"
TARGET_URL="${TARGET_URL:-http://127.0.0.1:8082}"
ZAP_SPIDER_MINUTES="${ZAP_SPIDER_MINUTES:-3}"

mkdir -p "$REPORT_DIR"

echo "[pentest] target: $TARGET_URL"
echo "[pentest] report dir: $REPORT_DIR"

docker run --rm \
  --network=host \
  -v "$REPORT_DIR:/zap/wrk:rw" \
  ghcr.io/zaproxy/zaproxy:stable \
  zap-baseline.py \
  -t "$TARGET_URL" \
  -m "$ZAP_SPIDER_MINUTES" \
  -r zap-report.html \
  -w zap-report.md \
  -x zap-report.xml

echo "[pentest] completed"
echo "[pentest] reports:"
echo "  - $REPORT_DIR/zap-report.html"
echo "  - $REPORT_DIR/zap-report.md"
echo "  - $REPORT_DIR/zap-report.xml"
