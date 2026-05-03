#!/bin/bash
PASS=0
FAIL=0

check() {
  local desc="$1"
  local cmd="$2"
  if eval "$cmd" >/dev/null 2>&1; then
    echo "  ✅ $desc"
    PASS=$((PASS+1))
  else
    echo "  ❌ FAIL: $desc"
    FAIL=$((FAIL+1))
  fi
}

report_results() {
  echo ""
  echo "============================================"
  echo " Results: $PASS passed, $FAIL failed"
  echo "============================================"
  [[ $FAIL -eq 0 ]]
}
