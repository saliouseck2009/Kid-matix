#!/usr/bin/env bash
# Tests of tool/check_release_content.sh with fixture trees.
set -euo pipefail

guard="$(cd "$(dirname "$0")" && pwd)/check_release_content.sh"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
failures=0

fixture() { # name provisional-json-fragment table-text
  local dir="$tmp/$1"
  mkdir -p "$dir/assets/audio/wo" "$dir/assets/math_words" "$dir/docs/product"
  printf '{"language":"wo","format":"m4a",%s"words":{}}\n' "$2" \
    > "$dir/assets/audio/wo/manifest.json"
  printf '%s\n' "$3" > "$dir/docs/product/math-words.md"
  printf 'rien\n' > "$dir/docs/product/problems.md"
  printf '{"words":[]}\n' > "$dir/assets/math_words/math_words.json"
}

expect() { # name expected-exit
  local code=0
  bash "$guard" "$tmp/$1" > /dev/null 2>&1 || code=$?
  if [ "$code" != "$2" ]; then
    echo "FAIL: $1 exited $code, expected $2" >&2
    failures=$((failures + 1))
  fi
}

fixture clean '' '| texte |'
fixture empty_list '"provisional":[],' '| texte |'
fixture provisional_audio '"provisional":["wo_a.m4a"],' '| texte |'
fixture old_flag '"provisional":true,' '| texte |'
fixture machine_text '' '| wolof (machine, à relire) |'
fixture status_line_only '' 'Wolof provisoire : cellules « (machine, à relire) ».
| texte |'
fixture google_text '' '| wolof (Google, à relire) |'

expect clean 0
expect status_line_only 0
expect empty_list 0
expect provisional_audio 1
expect old_flag 1
expect machine_text 1
expect google_text 1

if [ "$failures" -ne 0 ]; then exit 1; fi
echo "OK"
