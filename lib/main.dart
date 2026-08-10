import 'package:flutter/material.dart';

import 'app.dart';
import 'l10n/app_localizations.dart';
import 'providers/finance_provider.dart';
import 'services/platform_reminder_service.dart';
import 'services/reminder_service.dart';
import 'storage/finance_storage.dart';
import 'storage/platform_key_value_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final localizations = lookupAppLocalizations(JMoneyApp.defaultLocale);
    final keyValueStore = await initializePlatformKeyValueStore();
    ReminderService reminderService = NoopReminderService();
    try {
      reminderService = await initializePlatformReminderService(localizations);
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'jmoney local reminders',
        ),
      );
    }
    final provider = FinanceProvider(
      storage: FinanceStorage(
        keyValueStore: keyValueStore,
        localizations: localizations,
      ),
      reminderService: reminderService,
    );
    await provider.initialize();
    if (provider.error != null) throw provider.error!;
    runApp(JMoneyApp(provider: provider));
  } catch (error, stackTrace) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'jmoney storage bootstrap',
      ),
    );
    runApp(const _StorageStartupErrorApp());
  }
}

class _StorageStartupErrorApp extends StatelessWidget {
  const _StorageStartupErrorApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: JMoneyApp.defaultLocale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: const _StorageStartupErrorScreen(),
    );
  }
}

class _StorageStartupErrorScreen extends StatelessWidget {
  const _StorageStartupErrorScreen();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.storage_rounded, size: 56),
                  const SizedBox(height: 20),
                  Text(
                    l10n.storageStartupTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.storageStartupBody,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
