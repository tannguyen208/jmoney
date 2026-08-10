#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT_DIR"

if [[ ! -f .env ]]; then
  printf '%s\n' 'Missing .env. Add ANDROID_DEVICE_ID=<device-id>.' >&2
  exit 1
fi

# shellcheck disable=SC1091
source .env

if [[ -z "${ANDROID_DEVICE_ID:-}" ]]; then
  printf '%s\n' 'ANDROID_DEVICE_ID is missing from .env.' >&2
  exit 1
fi

printf '%s\n' '==> Building from scratch for Android'
./tool/build-from-scratch.sh android

devices_output=$(flutter devices --device-timeout 10)
if [[ "$devices_output" != *"$ANDROID_DEVICE_ID"* ]]; then
  printf 'Device not found: %s\n\n' "$ANDROID_DEVICE_ID" >&2
  printf '%s\n' "$devices_output"
  exit 1
fi

apk_path="build/app/outputs/flutter-apk/app-release.apk"
printf '==> Installing release APK on %s\n' "$ANDROID_DEVICE_ID"
flutter install --release \
  -d "$ANDROID_DEVICE_ID" \
  --use-application-binary "$apk_path"

printf '%s\n' '==> Android build and install completed'
