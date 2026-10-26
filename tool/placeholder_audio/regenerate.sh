#!/usr/bin/env bash
# Regenerates the provisional Wolof audio from the Wolof cells of the two
# content tables. The one command to run after editing a cell:
#
#   bash tool/placeholder_audio/regenerate.sh
#
# The tables (docs/product/math-words.md, docs/product/problems.md) are the
# source of truth: edit a cell in any editor; remove its « (…, à relire) »
# mark once you have checked it. The script creates the virtualenv if it is
# missing, installs the pinned requirements, speaks again only the cells whose
# text changed since the last run (words of rules.txt are never spoken),
# converts the recordings (a checked cell is no longer listed as provisional
# in the manifest) and rebuilds assets/math_words/math_words.json.
#
# Any option of make_wolof_placeholders.py can follow, e.g. --print-french.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
venv="$here/.venv"

if ! command -v ffmpeg > /dev/null 2>&1; then
  echo "ffmpeg is needed: brew install ffmpeg" >&2
  exit 1
fi

if [ ! -x "$venv/bin/python" ]; then
  echo "Creating the virtualenv (once)..."
  python3 -m venv "$venv"
fi
"$venv/bin/python" -m pip install --quiet --disable-pip-version-check \
  -r "$here/requirements.txt"

"$venv/bin/python" "$here/make_wolof_placeholders.py" "$@"
