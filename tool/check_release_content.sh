#!/usr/bin/env bash
# Release guard: refuses a build that would ship provisional content.
#
#   bash tool/check_release_content.sh [ROOT]
#
# Fails when an audio pack manifest (assets/audio/<language>/manifest.json)
# lists a provisional file, or when a machine-made Wolof mark
# « (machine, à relire) » or « (Google, à relire) » is left in the content
# tables or the math words asset. Run by tool/build_release.sh, not by
# `tool/check.sh build`: the provisional files are meant to be tested on
# devices until the real recordings arrive.
set -euo pipefail

root="${1:-$(cd "$(dirname "$0")/.." && pwd)}"
failed=0

for manifest in "$root"/assets/audio/*/manifest.json; do
  [ -e "$manifest" ] || continue
  count=$(python3 -c '
import json, sys
data = json.load(open(sys.argv[1], encoding="utf-8"))
flag = data.get("provisional")
print(len(flag) if isinstance(flag, list) else (1 if flag is True else 0))
' "$manifest")
  if [ "$count" != "0" ]; then
    echo "provisional audio: $manifest lists $count provisional file(s)" >&2
    failed=1
  fi
done

for file in \
  "$root/docs/product/math-words.md" \
  "$root/docs/product/problems.md" \
  "$root/assets/math_words/math_words.json"; do
  [ -e "$file" ] || continue
  if grep -q -e '(machine, à relire)' -e '(Google, à relire)' "$file"; then
    echo "machine-made Wolof text left in $file" >&2
    failed=1
  fi
done

if [ "$failed" -ne 0 ]; then
  echo "Release refused: replace the provisional Wolof with real recordings" \
    "(docs/product/audio-recording.md, section 11)." >&2
  exit 1
fi
echo "Release content OK: no provisional audio or machine text."
