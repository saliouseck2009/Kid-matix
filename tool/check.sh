#!/usr/bin/env bash
# Runs code generation, formatting, analysis and every test, and writes the
# whole output to tool/logs/check.log.
# Run it from anywhere:  bash tool/check.sh
set -uo pipefail
cd "$(dirname "$0")/.."

LOG_DIR="tool/logs"
LOG_FILE="$LOG_DIR/check.log"
mkdir -p "$LOG_DIR"

FAILED_STEPS=()

run_step() {
  local name="$1"
  shift
  echo
  echo "===== STEP: $name ====="
  echo "\$ $*"
  if "$@"; then
    echo "===== RESULT: $name OK ====="
  else
    echo "===== RESULT: $name FAILED (exit $?) ====="
    FAILED_STEPS+=("$name")
  fi
}

run_all() {
  echo "Check started: $(date)"
  flutter --version
  run_step "pub get" flutter pub get
  run_step "gen-l10n" flutter gen-l10n
  if grep -rq "@JsonSerializable" lib; then
    run_step "build_runner" \
      dart run build_runner build --delete-conflicting-outputs
  fi
  run_step "format" dart format lib test
  run_step "analyze" flutter analyze
  run_step "test" flutter test
  echo
  if [ "${#FAILED_STEPS[@]}" -eq 0 ]; then
    echo "===== SUMMARY: ALL STEPS OK ====="
  else
    echo "===== SUMMARY: FAILED STEPS: ${FAILED_STEPS[*]} ====="
  fi
}

run_all 2>&1 | tee "$LOG_FILE"
echo
echo "Full output saved to $LOG_FILE"
