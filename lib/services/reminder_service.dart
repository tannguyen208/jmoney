import '../models/recurring_rule.dart';

abstract interface class ReminderService {
  Future<void> initialize();

  Future<void> requestPermissions();

  Future<void> schedule(RecurringRule rule);

  Future<void> cancel(int ruleId);

  Future<void> cancelAll();
}

class NoopReminderService implements ReminderService {
  @override
  Future<void> initialize() async {}

  @override
  Future<void> requestPermissions() async {}

  @override
  Future<void> schedule(RecurringRule rule) async {}

  @override
  Future<void> cancel(int ruleId) async {}

  @override
  Future<void> cancelAll() async {}
}
