#!/usr/bin/env bash
# Runs code generation, formatting, analysis, every test and the git hook
# tests, and writes the whole output to tool/logs/check.log. Exits with a
# non-zero status when a step fails.
# Run it from anywhere:  bash tool/check.sh
#
# On a CI runner (CI=true, set by GitHub Actions) nothing is rewritten: the
# format step fails on unformatted code, and generated files that differ from
# the committed ones fail the run.
set -uo pipefail
cd "$(dirname "$0")/.."

LOG_DIR="tool/logs"
LOG_FILE="$LOG_DIR/check.log"
mkdir -p "$LOG_DIR"

FAILED_STEPS=()
IS_CI="${CI:-false}"

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

# Fails when code generation changed or created a file: generated code must
# be committed with its source.
check_clean_tree() {
  local changes
  changes="$(git status --porcelain)"
  if [ -n "$changes" ]; then
    echo "Generated files are not up to date; run tool/check.sh and commit:"
    echo "$changes"
    return 1
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
  if [ "$IS_CI" = "true" ]; then
    run_step "generated files committed" check_clean_tree
    run_step "format" dart format --output=none --set-exit-if-changed lib test
  else
    run_step "format" dart format lib test
  fi
  run_step "analyze" flutter analyze
  run_step "test" flutter test
  run_step "git hooks" bash tool/hooks_test.sh
  echo
  if [ "${#FAILED_STEPS[@]}" -eq 0 ]; then
    echo "===== SUMMARY: ALL STEPS OK ====="
  else
    echo "===== SUMMARY: FAILED STEPS: ${FAILED_STEPS[*]} ====="
    return 1
  fi
}

run_all 2>&1 | tee "$LOG_FILE"
status="${PIPESTATUS[0]}"
echo
echo "Full output saved to $LOG_FILE"
exit "$status"
