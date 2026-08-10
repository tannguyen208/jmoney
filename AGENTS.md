# JMoney Agent Guide

## Commands

- This is a single Flutter app; run commands from the repository root.
- Bootstrap dependencies and generated localizations with `flutter pub get` then `flutter gen-l10n`.
- Run static checks with `flutter analyze`.
- Run the full test suite with `flutter test`; focus a file with `flutter test test/finance_storage_test.dart` or a named test with `flutter test test/app_test.dart --plain-name "uses Vietnamese as the default locale"`.
- Format Dart changes with `dart format lib test` and verify formatting with `dart format --output=none --set-exit-if-changed lib test`.
- Start a target device with `flutter run`; Web/Chrome uses the browser storage path and has no native notifications.
- `tool/bootstrap.sh` is the clean-project setup path: it requires Flutter, runs `flutter pub get`, `flutter gen-l10n`, and `flutter test`.
- `tool/jmoney.sh` is the daily helper: use `./tool/jmoney.sh web|android|ios|macos|windows|linux`, `reset`, `check`, or `help` instead of guessing platform flags.

## Structure

- `lib/main.dart` initializes platform storage, reminders, and `FinanceProvider`; `lib/app.dart` builds the localized app and theme.
- Business state and mutations live in `lib/providers/finance_provider.dart`; persistence, validation, migrations, and seed data live in `lib/storage/finance_storage.dart`.
- `lib/models` contains domain data, `lib/screens` contains feature screens, `lib/widgets` contains reusable UI, and `lib/services` contains reminder behavior.
- Platform-specific storage and reminders use conditional exports: native builds use MMKV and local notifications, while Web uses `localStorage` and a no-op reminder service.

## Invariants

- User-facing strings must come through `AppLocalizations`; add or update both `lib/l10n/app_vi.arb` and `lib/l10n/app_en.arb`, then run `flutter gen-l10n`. Do not edit generated localization Dart files.
- Vietnamese (`vi`) is the default locale; English is the fallback locale. The `l10n_audit_test.dart` test rejects hard-coded UI strings in `lib`.
- Financial data is local-only. Native persistence is the MMKV instance `jmoney.finance`; Web persistence is browser `localStorage`.
- The current finance snapshot schema is version 4 in `finance_storage.dart`; v1, v2, and v3 are migrated with a backup. Update migration and storage tests when changing persisted JSON.
- Transaction mutations are committed as a snapshot and update jar balances atomically; preserve this behavior when changing storage or provider code.
- Generated files under `lib/l10n` are part of the build output used by the app, but their ARB files and `l10n.yaml` are the sources to change.

## UI Rules

- Calendar controls must use numbers only for month, day, and year values; do not display words such as month or day inside calendar controls.
- Do not use dropdown lists for any interaction case. Use a modal list, bottom sheet, segmented control, or another explicit selection surface instead.
