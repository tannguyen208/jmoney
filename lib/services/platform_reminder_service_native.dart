import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../l10n/app_localizations.dart';
import '../models/recurring_rule.dart';
import 'reminder_service.dart';

Future<ReminderService> initializePlatformReminderService(
  AppLocalizations localizations,
) async {
  final service = LocalReminderService(localizations);
  await service.initialize();
  return service;
}

class LocalReminderService implements ReminderService {
  LocalReminderService(this._localizations);

  final AppLocalizations _localizations;
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  @override
  Future<void> initialize() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));
    const android = AndroidInitializationSettings('ic_notification');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: android,
        iOS: darwin,
        macOS: darwin,
      ),
    );
  }

  @override
  Future<void> requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    await _plugin
        .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  @override
  Future<void> schedule(RecurringRule rule) async {
    final id = rule.id;
    if (id == null) return;
    await cancel(id);
    if (!rule.isEnabled || !rule.nextRunAt.isAfter(DateTime.now())) return;
    final scheduledDate = tz.TZDateTime.from(rule.nextRunAt, tz.local);
    await _plugin.zonedSchedule(
      id: id,
      title: '${_localizations.appName} · ${rule.name}',
      body: _localizations.notificationDue(_amountLabel(rule.amount)),
      scheduledDate: scheduledDate,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'jmoney_recurring',
          _localizations.recurringChannelName,
          channelDescription: _localizations.recurringChannelDescription,
          importance: Importance.high,
          priority: Priority.high,
          icon: 'ic_notification',
        ),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: 'recurring:$id',
    );
  }

  @override
  Future<void> cancel(int ruleId) => _plugin.cancel(id: ruleId);

  @override
  Future<void> cancelAll() => _plugin.cancelAll();

  String _amountLabel(int amount) => NumberFormat.currency(
        locale: _localizations.localeName,
        symbol: '₫',
        decimalDigits: 0,
      ).format(amount);
}
