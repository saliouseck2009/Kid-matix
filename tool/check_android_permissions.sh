#!/usr/bin/env bash
# Fails when the release APK asks for a network permission: the app never
# goes online (privacy policy), and a plugin (ML Kit of mobile_scanner)
# declares INTERNET and ACCESS_NETWORK_STATE that the manifest removes.
#
# Usage: bash tool/check_android_permissions.sh [path/to/app-release.apk]
set -euo pipefail

apk="${1:-build/app/outputs/flutter-apk/app-release.apk}"
sdk="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-$HOME/Library/Android/sdk}}"
aapt2="$(ls -1 "$sdk"/build-tools/*/aapt2 2>/dev/null | sort -V | tail -n 1 || true)"
if [ -z "$aapt2" ]; then
  echo "aapt2 not found under $sdk/build-tools" >&2
  exit 1
fi

permissions="$("$aapt2" dump permissions "$apk")"
echo "$permissions"
forbidden=0
for name in android.permission.INTERNET android.permission.ACCESS_NETWORK_STATE; do
  if echo "$permissions" | grep -q "name='$name'"; then
    echo "Forbidden permission in the release APK: $name" >&2
    forbidden=1
  fi
done
exit "$forbidden"
