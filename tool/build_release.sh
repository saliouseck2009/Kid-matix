#!/usr/bin/env bash
# Builds the store packages of Kid Matix, obfuscated, with their debug
# symbols kept apart in build/symbols/ (keep them to read crash traces).
#
#   bash tool/build_release.sh android   # build/app/outputs/bundle/release/app-release.aab
#   bash tool/build_release.sh ios       # build/ios/ipa/*.ipa
#   bash tool/build_release.sh           # both
#
# Signing: android/key.properties for Android, the Apple team set in
# Xcode for iOS (see docs/release/signing.md).
set -euo pipefail

cd "$(dirname "$0")/.."
readonly target="${1:-all}"
readonly symbols="build/symbols"

build_android() {
  if [ ! -f android/key.properties ]; then
    echo "android/key.properties is missing: the bundle would be signed" \
      "with the debug key, which the Play Store refuses." >&2
    exit 1
  fi
  flutter build appbundle --release --obfuscate \
    --split-debug-info="$symbols/android"
}

build_ios() {
  flutter build ipa --release --obfuscate \
    --split-debug-info="$symbols/ios"
}

flutter pub get
case "$target" in
  android) build_android ;;
  ios) build_ios ;;
  all) build_android && build_ios ;;
  *)
    echo "Unknown target '$target': use android, ios or all." >&2
    exit 2
    ;;
esac
