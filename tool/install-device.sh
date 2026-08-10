#!/usr/bin/env bash

set -euo pipefail

usage() {
  printf '%s\n' \
    'Usage:' \
    '  ./tool/install-device.sh android <device-id>' \
    '  ./tool/install-device.sh ios <device-id>' \
    '' \
    'Use `flutter devices` to find the device ID.'
}

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT_DIR"

if [[ $# -ne 2 || ("$1" != "android" && "$1" != "ios") ]]; then
  usage >&2
  exit 2
fi

platform="$1"
device_id="$2"

if ! command -v flutter >/dev/null 2>&1; then
  printf '%s\n' 'Flutter was not found in PATH.' >&2
  exit 1
fi

devices_output=$(flutter devices --device-timeout 10)
if [[ "$devices_output" != *"$device_id"* ]]; then
  printf 'Device not found: %s\n\n' "$device_id" >&2
  printf '%s\n' "$devices_output"
  exit 1
fi

case "$platform" in
  android)
    apk_path="build/app/outputs/flutter-apk/app-release.apk"
    printf 'Building release APK...\n'
    flutter build apk --release
    if [[ ! -f "$apk_path" ]]; then
      printf 'Release APK was not created: %s\n' "$apk_path" >&2
      exit 1
    fi
    printf 'Installing release APK on %s...\n' "$device_id"
    flutter install --release \
      -d "$device_id" \
      --use-application-binary "$apk_path"
    ;;
  ios)
    printf 'Building and installing release app on %s...\n' "$device_id"
    flutter install --release -d "$device_id"
    ;;
esac
