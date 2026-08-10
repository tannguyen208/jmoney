import '../l10n/app_localizations.dart';
import 'reminder_service.dart';

Future<ReminderService> initializePlatformReminderService(
  AppLocalizations localizations,
) async {
  final service = NoopReminderService();
  await service.initialize();
  return service;
}
