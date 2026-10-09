#!/usr/bin/env bash
# One-time project setup: downloads the bundled fonts, adds the packages and
# installs the git hooks.
# Run it from anywhere:  bash tool/setup.sh
set -euo pipefail
cd "$(dirname "$0")/.."

FONT_DIR="assets/fonts"
FONT_REPO="https://raw.githubusercontent.com/google/fonts/main/ofl"
mkdir -p "$FONT_DIR"

download_font() {
  local target="$1"
  local url="$2"
  if [ -s "$target" ]; then
    echo "Font already present: $target"
    return 0
  fi
  echo "Downloading $target"
  if ! curl -fL --retry 2 -o "$target" "$url"; then
    rm -f "$target"
    echo "ERROR: could not download $url" >&2
    echo "Download the variable font from https://fonts.google.com and" >&2
    echo "save it as $target, then run this script again." >&2
    exit 1
  fi
}

download_font "$FONT_DIR/Fredoka-Variable.ttf" \
  "$FONT_REPO/fredoka/Fredoka%5Bwdth%2Cwght%5D.ttf"
download_font "$FONT_DIR/Nunito-Variable.ttf" \
  "$FONT_REPO/nunito/Nunito%5Bwght%5D.ttf"

flutter pub add \
  flutter_bloc \
  get_it \
  go_router \
  sqflite \
  path \
  shared_preferences \
  uuid \
  meta \
  json_annotation

flutter pub add --dev \
  build_runner \
  json_serializable \
  bloc_test \
  mocktail \
  sqflite_common_ffi

# Branch and commit rules of docs/git-workflow.md.
git config core.hooksPath .githooks
echo "Git hooks installed from .githooks/"

echo
echo "Setup done. Now run: bash tool/check.sh"
