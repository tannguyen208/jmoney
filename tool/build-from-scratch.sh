#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT_DIR"

target="${1:-all}"
if [[ "$target" != "all" && "$target" != "android" && "$target" != "ios" ]]; then
  printf '%s\n' \
    'Usage: ./tool/build-from-scratch.sh [all|android|ios]' >&2
  exit 2
fi

printf '%s\n' '==> Cleaning Flutter build artifacts'
flutter clean

printf '%s\n' '==> Installing dependencies'
flutter pub get

printf '%s\n' '==> Generating localizations'
flutter gen-l10n

printf '%s\n' '==> Running static analysis'
flutter analyze

printf '%s\n' '==> Running tests'
flutter test

if [[ "$target" == "all" || "$target" == "android" ]]; then
  printf '%s\n' '==> Building Android release APK'
  flutter build apk --release
  printf '%s\n' \
    'Android artifact: build/app/outputs/flutter-apk/app-release.apk'
fi

if [[ "$target" == "all" || "$target" == "ios" ]]; then
  printf '%s\n' '==> Building iOS release without code signing'
  flutter build ios --release --no-codesign
  printf '%s\n' 'iOS artifact: build/ios/iphoneos/Runner.app'
fi

printf '==> Build completed: %s\n' "$target"
