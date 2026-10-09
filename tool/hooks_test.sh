#!/usr/bin/env bash
# Tests the git hooks of .githooks/ against good and bad inputs.
# Run it from anywhere:  bash tool/hooks_test.sh
set -uo pipefail
cd "$(dirname "$0")/.."

readonly commit_msg_hook=".githooks/commit-msg"
readonly pre_commit_hook=".githooks/pre-commit"
readonly pre_push_hook=".githooks/pre-push"

failures=0
work_dir="$(mktemp -d)"
trap 'rm -rf "$work_dir"' EXIT

expect_message() {
  local expected="$1"
  local message="$2"
  local message_file="$work_dir/COMMIT_EDITMSG"
  printf '%b' "$message" > "$message_file"
  if bash "$commit_msg_hook" "$message_file" 2>/dev/null; then
    actual="accepted"
  else
    actual="rejected"
  fi
  if [ "$actual" != "$expected" ]; then
    echo "FAIL commit-msg: expected $expected, got $actual for: $message"
    failures=$((failures + 1))
  fi
}

expect_branch() {
  local expected="$1"
  local branch="$2"
  local repo="$work_dir/repo"
  rm -rf "$repo"
  git init --quiet --initial-branch="$branch" "$repo"
  if (cd "$repo" && bash "$OLDPWD/$pre_commit_hook") 2>/dev/null; then
    actual="accepted"
  else
    actual="rejected"
  fi
  if [ "$actual" != "$expected" ]; then
    echo "FAIL pre-commit: expected $expected, got $actual for: $branch"
    failures=$((failures + 1))
  fi
}

expect_push() {
  local expected="$1"
  local remote_ref="$2"
  local sha="0123456789abcdef0123456789abcdef01234567"
  if printf 'refs/heads/x %s %s %s\n' "$sha" "$remote_ref" "$sha" |
    bash "$pre_push_hook" origin url 2>/dev/null; then
    actual="accepted"
  else
    actual="rejected"
  fi
  if [ "$actual" != "$expected" ]; then
    echo "FAIL pre-push: expected $expected, got $actual for: $remote_ref"
    failures=$((failures + 1))
  fi
}

expect_message accepted 'feat(profile): add the nickname uniqueness check'
expect_message accepted 'fix: keep the tab bar at its natural height'
expect_message accepted 'refactor(learning-path)!: rename the node states'
expect_message accepted 'feat(quiz): add the timer\n\nBody line.\n\nRefs: F3-02'
expect_message accepted '# comment\nchore(deps): add sqflite'
expect_message accepted "Merge branch 'feat/f1-03-profile-repository'"
expect_message accepted 'fixup! feat(profile): add the repository'
expect_message rejected 'Add profile repository'
expect_message rejected 'feat: Add profile repository'
expect_message rejected 'feat(profile): add the repository.'
expect_message rejected 'Feat(profile): add the repository'
expect_message rejected 'feature(profile): add the repository'
expect_message rejected 'feat(Profile): add the repository'
expect_message rejected 'feat(profile):add the repository'
expect_message rejected 'feat(profile): add the repository\nno blank line'
expect_message rejected "feat(profile): $(printf 'x%.0s' {1..70})"
expect_message rejected ''

expect_branch accepted 'feat/f1-03-profile-repository'
expect_branch accepted 'fix/f0-tab-bar-height'
expect_branch accepted 'chore/git-workflow'
expect_branch rejected 'main'
expect_branch rejected 'master'
expect_branch rejected 'feature/profile'
expect_branch rejected 'feat/Profile_Repository'
expect_branch rejected 'my-branch'

expect_push accepted 'refs/heads/feat/f1-03-profile-repository'
expect_push accepted 'refs/tags/v1.0.0'
expect_push rejected 'refs/heads/main'
expect_push rejected 'refs/heads/master'

if [ "$failures" -eq 0 ]; then
  echo "All hook tests passed."
else
  echo "$failures hook test(s) failed."
  exit 1
fi
