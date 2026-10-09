#!/usr/bin/env bash
# Runs the project checks and writes the whole output to tool/logs/check.log
# (tool/logs/check-<group>.log for a single group). Exits with a non-zero
# status when a step fails.
#
# Usage, from anywhere:
#   bash tool/check.sh            analyze + test: the check after every change
#   bash tool/check.sh analyze    code generation, format, analyze
#   bash tool/check.sh test       tests with coverage, git hook tests
#   bash tool/check.sh build      build-android, plus build-ios on macOS;
#                                 slow, run it before a pull request that
#                                 touches android/, ios/ or dependencies
#   bash tool/check.sh build-android   debug APK
#   bash tool/check.sh build-ios       debug iOS app without signing (macOS)
#   bash tool/check.sh all        analyze + test + build
#
# The CI workflow runs one group per job. On a CI runner (CI=true, set by
# GitHub Actions) nothing is rewritten: the format step fails on unformatted
# code, and generated files that differ from the committed ones fail the run.
set -uo pipefail
cd "$(dirname "$0")/.."

readonly group="${1:-default}"
readonly is_ci="${CI:-false}"
readonly log_dir="tool/logs"
if [ "$group" = "default" ]; then
  readonly log_file="$log_dir/check.log"
else
  readonly log_file="$log_dir/check-$group.log"
fi
mkdir -p "$log_dir"

failed_steps=()

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
    failed_steps+=("$name")
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

run_analyze() {
  run_step "gen-l10n" flutter gen-l10n
  if grep -rq "@JsonSerializable" lib; then
    run_step "build_runner" \
      dart run build_runner build --delete-conflicting-outputs
  fi
  if [ "$is_ci" = "true" ]; then
    run_step "generated files committed" check_clean_tree
    run_step "format" dart format --output=none --set-exit-if-changed lib test
  else
    run_step "format" dart format lib test
  fi
  run_step "analyze" flutter analyze
}

run_test() {
  run_step "test" flutter test --coverage
  run_step "git hooks" bash tool/hooks_test.sh
}

run_build_android() {
  run_step "build android" flutter build apk --debug
}

run_build_ios() {
  run_step "build ios" flutter build ios --debug --no-codesign
}

run_build() {
  run_build_android
  if [ "$(uname -s)" = "Darwin" ]; then
    run_build_ios
  fi
}

run_group() {
  echo "Check '$group' started: $(date)"
  flutter --version
  run_step "pub get" flutter pub get
  case "$group" in
    default) run_analyze && run_test ;;
    analyze) run_analyze ;;
    test) run_test ;;
    build) run_build ;;
    build-android) run_build_android ;;
    build-ios) run_build_ios ;;
    all) run_analyze && run_test && run_build ;;
    *)
      echo "Unknown group '$group': use analyze, test, build,"
      echo "build-android, build-ios or all."
      return 2
      ;;
  esac
  echo
  if [ "${#failed_steps[@]}" -eq 0 ]; then
    echo "===== SUMMARY: ALL STEPS OK ====="
  else
    echo "===== SUMMARY: FAILED STEPS: ${failed_steps[*]} ====="
    return 1
  fi
}

run_group 2>&1 | tee "$log_file"
status="${PIPESTATUS[0]}"
echo
echo "Full output saved to $log_file"
exit "$status"
