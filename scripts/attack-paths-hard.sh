#!/usr/bin/env bash
set -euo pipefail
BASE="${BASE:-http://127.0.0.1:8081}"

echo "== health =="
curl -sS "$BASE/health"; echo

echo "== BOLA blocked: user 1 reads order 2 =="
curl -sS -H 'X-User-Id: 1' "$BASE/orders/2"; echo

echo "== SQLi should not dump all =="
curl -sS --get "$BASE/search" --data-urlencode "q=' OR '1'='1"; echo

echo "== SSRF blocked =="
curl -sS -X POST "$BASE/fetch" -H 'Content-Type: application/json' \
  -d '{"url":"http://127.0.0.1:8081/health"}'; echo
