#!/usr/bin/env sh
set -eu

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter SDK is required and must be available in PATH." >&2
  exit 1
fi

if [ ! -f .metadata ]; then
  flutter create --project-name jmoney --org com.jmoney .
fi

flutter pub get
flutter gen-l10n
flutter test
