#!/usr/bin/env bash
# Films a marketing scenario on the Android emulator or the iOS simulator
# and saves the raw screen recording in marketing/videos/raw/.
#
# Usage, from anywhere:
#   bash tool/marketing/record.sh android first_launch
#   bash tool/marketing/record.sh ios play_stage
#
# The scenario is integration_test/marketing/<scenario>_test.dart. It ERASES
# the players of the device it runs on: emulator or simulator only.
#
# Environment:
#   DEVICE       emulator serial (emulator-5556) or simulator UDID to film
#                on, when several run (default: the first one running)
#   AVD          Android virtual device to start when none runs
#                (default: the first of `emulator -list-avds`)
#   IOS_DEVICE   simulator to boot when none runs (default: first iPhone)
#   MODE         profile | debug (default: profile on Android; debug on iOS,
#                where the simulator cannot run a profile build)
#   AIRPLANE_MODE=1
#                Android only: films with the airplane mode on and its icon
#                in the status bar, then puts the mode back as it was. The
#                demo status bar hides that icon, so this take keeps the
#                real status bar: real time and battery.
#
# Then cut and caption the recording with tool/marketing/edit.sh.
set -euo pipefail
cd "$(dirname "$0")/../.."

readonly platform="${1:-}"
readonly scenario="${2:-}"
readonly target="integration_test/marketing/${scenario}_test.dart"
readonly out_dir="marketing/videos/raw"
readonly log_dir="tool/logs"
readonly drive_log="$log_dir/marketing-$scenario.log"
readonly start_marker="MARKETING:START"
readonly end_marker="MARKETING:END"
# Longest wait for the build and the first screen, then for the scenario.
readonly build_timeout_s=1200
readonly scenario_timeout_s=170
readonly device_file="/sdcard/kid_matix_marketing.mp4"
readonly sdk="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-$HOME/Library/Android/sdk}}"

usage() {
  sed -n '2,24p' "$0" | sed 's/^# \{0,1\}//'
  echo
  echo "Scenarios:"
  for file in integration_test/marketing/*_test.dart; do
    echo "  $(basename "$file" _test.dart)"
  done
  exit 2
}

case "$platform" in android | ios) ;; *) usage ;; esac
[ -f "$target" ] || usage

mkdir -p "$out_dir" "$log_dir"
readonly output="$out_dir/$scenario-$platform-$(date +%Y%m%d-%H%M%S).mp4"
drive_pid=""
recorder_pid=""
airplane_before=""

# Waits until the drive log holds $1, for at most $2 seconds; fails when
# flutter drive ends first.
wait_for_marker() {
  local marker="$1" deadline=$((SECONDS + $2))
  until grep -q "$marker" "$drive_log" 2>/dev/null; do
    if ! kill -0 "$drive_pid" 2>/dev/null; then
      echo "flutter drive ended before '$marker'; see $drive_log" >&2
      return 1
    fi
    if [ "$SECONDS" -ge "$deadline" ]; then
      echo "Timed out waiting for '$marker'; see $drive_log" >&2
      return 1
    fi
    sleep 0.2
  done
}

# ---------------------------------------------------------------- Android

adb_bin() {
  if command -v adb >/dev/null 2>&1; then echo adb; else echo "$sdk/platform-tools/adb"; fi
}

android_serial() {
  "$(adb_bin)" devices | awk '$1 ~ /^emulator-/ && $2 == "device" { print $1; exit }'
}

android_start_emulator() {
  local emulator_bin="$sdk/emulator/emulator" avd
  avd="${AVD:-$("$emulator_bin" -list-avds | head -n 1)}"
  [ -n "$avd" ] || { echo "No Android virtual device; create one first." >&2; exit 1; }
  echo "Starting the emulator $avd..."
  nohup "$emulator_bin" -avd "$avd" -no-snapshot-save >"$log_dir/marketing-emulator.log" 2>&1 &
  "$(adb_bin)" wait-for-device
  until [ "$("$(adb_bin)" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" = "1" ]; do
    sleep 2
  done
}

demo_broadcast() {
  "$adb" -s "$serial" shell am broadcast -a com.android.systemui.demo "$@" >/dev/null
}

android_prepare() {
  # Portrait, whatever the emulator window was doing.
  "$adb" -s "$serial" shell settings put system accelerometer_rotation 0
  "$adb" -s "$serial" shell settings put system user_rotation 0
  # Normal animations: the videos show the real celebrations.
  for scale in window_animation_scale transition_animation_scale animator_duration_scale; do
    "$adb" -s "$serial" shell settings put global "$scale" 1
  done
  if [ "${AIRPLANE_MODE:-0}" = "1" ]; then
    airplane_before="$("$adb" -s "$serial" shell settings get global airplane_mode_on | tr -d '\r')"
    "$adb" -s "$serial" shell cmd connectivity airplane-mode enable
    # The icon only shows on the real status bar.
    sleep 2
    return
  fi
  # Demo status bar: 9:41, full battery, full signal, no notification.
  "$adb" -s "$serial" shell settings put global sysui_demo_allowed 1
  demo_broadcast -e command enter
  demo_broadcast -e command clock -e hhmm 0941
  demo_broadcast -e command battery -e level 100 -e plugged false
  demo_broadcast -e command network -e wifi show -e level 4
  demo_broadcast -e command network -e mobile show -e datatype none -e level 4
  demo_broadcast -e command notifications -e visible false
}

android_restore() {
  if [ "${AIRPLANE_MODE:-0}" = "1" ]; then
    if [ "${airplane_before:-1}" != "1" ]; then
      "$adb" -s "$serial" shell cmd connectivity airplane-mode disable || true
    fi
    return
  fi
  demo_broadcast -e command exit || true
}

android_start_recording() {
  "$adb" -s "$serial" shell rm -f "$device_file"
  "$adb" -s "$serial" shell screenrecord --bit-rate 16000000 --time-limit 180 "$device_file" &
  recorder_pid=$!
}

android_stop_recording() {
  "$adb" -s "$serial" shell pkill -INT screenrecord || true
  wait "$recorder_pid" 2>/dev/null || true
  # screenrecord finishes writing the file after the signal.
  sleep 2
  "$adb" -s "$serial" pull "$device_file" "$output" >/dev/null
  "$adb" -s "$serial" shell rm -f "$device_file"
}

# -------------------------------------------------------------------- iOS

ios_booted_udid() {
  xcrun simctl list devices booted | sed -n 's/.*(\([0-9A-F-]\{36\}\)) (Booted).*/\1/p' | head -n 1
}

ios_boot_simulator() {
  local name udid
  name="${IOS_DEVICE:-}"
  if [ -n "$name" ]; then
    udid="$(xcrun simctl list devices available | grep -F "$name (" | sed -n 's/.*(\([0-9A-F-]\{36\}\)).*/\1/p' | head -n 1)"
  else
    udid="$(xcrun simctl list devices available | grep 'iPhone' | sed -n 's/.*(\([0-9A-F-]\{36\}\)).*/\1/p' | head -n 1)"
  fi
  [ -n "$udid" ] || { echo "No iPhone simulator found." >&2; exit 1; }
  echo "Booting the simulator $udid..."
  xcrun simctl boot "$udid"
  # The window is only for watching: the recording works without it.
  open -a Simulator 2>/dev/null || true
  xcrun simctl bootstatus "$udid" >/dev/null
}

ios_prepare() {
  # Demo status bar: 9:41, full battery, full signal.
  xcrun simctl status_bar "$serial" override --time "9:41" \
    --batteryState charged --batteryLevel 100 \
    --wifiBars 3 --cellularBars 4 --dataNetwork wifi --cellularMode active
  xcrun simctl ui "$serial" appearance light
}

ios_restore() {
  xcrun simctl status_bar "$serial" clear || true
}

ios_start_recording() {
  xcrun simctl io "$serial" recordVideo --codec h264 --force "$output" >/dev/null 2>&1 &
  recorder_pid=$!
}

ios_stop_recording() {
  kill -INT "$recorder_pid" 2>/dev/null || true
  wait "$recorder_pid" 2>/dev/null || true
}

# ------------------------------------------------------------------- Run

cleanup() {
  if [ -n "$recorder_pid" ] && kill -0 "$recorder_pid" 2>/dev/null; then
    "${platform}_stop_recording" || true
  fi
  if [ -n "$drive_pid" ] && kill -0 "$drive_pid" 2>/dev/null; then
    kill "$drive_pid" 2>/dev/null || true
  fi
  "${platform}_restore" 2>/dev/null || true
}

if [ "$platform" = "android" ]; then
  adb="$(adb_bin)"
  serial="${DEVICE:-$(android_serial)}"
  if [ -z "$serial" ]; then
    android_start_emulator
    serial="$(android_serial)"
  fi
  mode="${MODE:-profile}"
else
  serial="${DEVICE:-$(ios_booted_udid)}"
  if [ -z "$serial" ]; then
    ios_boot_simulator
    serial="$(ios_booted_udid)"
  fi
  mode="${MODE:-debug}"
fi
trap cleanup EXIT

echo "Device: $serial ($platform, $mode build)"
"${platform}_prepare"

echo "Building and starting '$scenario'; output in $drive_log"
: >"$drive_log"
flutter drive "--$mode" \
  --driver=tool/marketing/driver.dart \
  --target="$target" \
  -d "$serial" >"$drive_log" 2>&1 &
drive_pid=$!

wait_for_marker "$start_marker" "$build_timeout_s"
"${platform}_start_recording"
echo "Recording..."
wait_for_marker "$end_marker" "$scenario_timeout_s"
"${platform}_stop_recording"
recorder_pid=""

if wait "$drive_pid"; then
  drive_pid=""
  echo "Raw recording: $output"
else
  drive_pid=""
  echo "The scenario failed; see $drive_log. Recording kept: $output" >&2
  exit 1
fi
