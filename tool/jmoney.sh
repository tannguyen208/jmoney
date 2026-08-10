#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT_DIR"

usage() {
  cat <<'EOF'
JMoney development tool

Usage:
  ./tool/jmoney.sh <command> [arguments]

Run:
  web | chrome       Run on Chrome
  android            Run on Android
  ios                Run on iOS
  macos              Run on macOS
  windows            Run on Windows
  linux              Run on Linux
  run <platform>     Run on a selected platform

Project:
  get                Install dependencies
  l10n               Generate localizations
  bootstrap          Run get + l10n
  clean              Remove Flutter build artifacts
  reset              Clean, then bootstrap dependencies and localizations
  analyze            Run Flutter analyzer
  test               Run tests; extra arguments are passed to flutter test
  format             Format lib and test Dart files
  check              Run format check, analyze, and tests
  devices            List available Flutter devices
  help               Show this help

Build:
  build-web          Build Web
  build-android      Build Android APK
  build-ios          Build iOS without code signing
  build-macos        Build macOS
  build-windows      Build Windows
  build-linux        Build Linux
EOF
}

run_platform() {
  platform=$1
  shift
  case "$platform" in
    web|chrome) device=chrome ;;
    android) device=android ;;
    ios) device=ios ;;
    macos) device=macos ;;
    windows) device=windows ;;
    linux) device=linux ;;
    *)
      printf 'Unknown platform: %s\n\n' "$platform" >&2
      usage >&2
      exit 2
      ;;
  esac
  flutter run -d "$device" "$@"
}

command=${1:-help}
if [ "$#" -gt 0 ]; then shift; fi

case "$command" in
  web|chrome|android|ios|macos|windows|linux)
    run_platform "$command" "$@"
    ;;
  run)
    if [ "$#" -eq 0 ]; then
      printf 'A platform is required for run.\n\n' >&2
      usage >&2
      exit 2
    fi
    platform=$1
    shift
    run_platform "$platform" "$@"
    ;;
  get)
    flutter pub get
    ;;
  l10n)
    flutter gen-l10n
    ;;
  bootstrap)
    flutter pub get
    flutter gen-l10n
    ;;
  clean)
    flutter clean
    ;;
  reset)
    flutter clean
    flutter pub get
    flutter gen-l10n
    ;;
  analyze)
    flutter analyze "$@"
    ;;
  test)
    flutter test "$@"
    ;;
  format)
    dart format lib test "$@"
    ;;
  check)
    dart format --output=none --set-exit-if-changed lib test
    flutter analyze
    flutter test
    ;;
  devices)
    flutter devices
    ;;
  build-web)
    flutter build web "$@"
    ;;
  build-android)
    flutter build apk "$@"
    ;;
  build-ios)
    flutter build ios --no-codesign "$@"
    ;;
  build-macos)
    flutter build macos "$@"
    ;;
  build-windows)
    flutter build windows "$@"
    ;;
  build-linux)
    flutter build linux "$@"
    ;;
  help|-h|--help)
    usage
    ;;
  *)
    printf 'Unknown command: %s\n\n' "$command" >&2
    usage >&2
    exit 2
    ;;
esac
