import 'finance_transaction.dart';

enum RecurrenceFrequency {
  weekly,
  monthly,
  quarterly,
  yearly;

  String get storageValue => name;

  static RecurrenceFrequency fromStorage(String? value) {
    return RecurrenceFrequency.values.firstWhere(
      (item) => item.storageValue == value,
      orElse: () => RecurrenceFrequency.monthly,
    );
  }
}

enum RecurringOccurrenceStatus {
  pending,
  completed,
  skipped;

  String get storageValue => name;

  static RecurringOccurrenceStatus fromStorage(String? value) {
    return RecurringOccurrenceStatus.values.firstWhere(
      (item) => item.storageValue == value,
      orElse: () => RecurringOccurrenceStatus.pending,
    );
  }
}

class RecurringRule {
  const RecurringRule({
    this.id,
    required this.name,
    required this.type,
    required this.amount,
    this.jarId,
    this.destinationJarId,
    this.categoryId,
    this.note,
    this.accountName,
    required this.frequency,
    this.interval = 1,
    required this.nextRunAt,
    this.endAt,
    this.isEnabled = true,
    this.autoPost = false,
  });

  final int? id;
  final String name;
  final TransactionType type;
  final int amount;
  final int? jarId;
  final int? destinationJarId;
  final int? categoryId;
  final String? note;
  final String? accountName;
  final RecurrenceFrequency frequency;
  final int interval;
  final DateTime nextRunAt;
  final DateTime? endAt;
  final bool isEnabled;
  final bool autoPost;

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'type': type.storageValue,
        'amount': amount,
        'jar_id': jarId,
        'destination_jar_id': destinationJarId,
        'category_id': categoryId,
        'note': note,
        'account_name': accountName,
        'frequency': frequency.storageValue,
        'interval': interval,
        'next_run_at': nextRunAt.toIso8601String(),
        'end_at': endAt?.toIso8601String(),
        'is_enabled': isEnabled,
        'auto_post': autoPost,
      };

  factory RecurringRule.fromMap(Map<String, Object?> map) {
    return RecurringRule(
      id: (map['id'] as num?)?.toInt(),
      name: map['name'] as String,
      type: TransactionType.fromDatabase(map['type'] as String),
      amount: (map['amount'] as num).toInt(),
      jarId: (map['jar_id'] as num?)?.toInt(),
      destinationJarId: (map['destination_jar_id'] as num?)?.toInt(),
      categoryId: (map['category_id'] as num?)?.toInt(),
      note: map['note'] as String?,
      accountName: map['account_name'] as String?,
      frequency: RecurrenceFrequency.fromStorage(map['frequency'] as String?),
      interval: (map['interval'] as num?)?.toInt() ?? 1,
      nextRunAt: DateTime.parse(map['next_run_at'] as String),
      endAt: map['end_at'] == null
          ? null
          : DateTime.parse(map['end_at'] as String),
      isEnabled: map['is_enabled'] as bool? ?? true,
      autoPost: map['auto_post'] as bool? ?? false,
    );
  }

  RecurringRule copyWith({
    int? id,
    String? name,
    TransactionType? type,
    int? amount,
    int? jarId,
    bool clearJar = false,
    int? destinationJarId,
    bool clearDestinationJar = false,
    int? categoryId,
    bool clearCategory = false,
    String? note,
    String? accountName,
    RecurrenceFrequency? frequency,
    int? interval,
    DateTime? nextRunAt,
    DateTime? endAt,
    bool clearEndAt = false,
    bool? isEnabled,
    bool? autoPost,
  }) {
    return RecurringRule(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      jarId: clearJar ? null : (jarId ?? this.jarId),
      destinationJarId: clearDestinationJar
          ? null
          : (destinationJarId ?? this.destinationJarId),
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      note: note ?? this.note,
      accountName: accountName ?? this.accountName,
      frequency: frequency ?? this.frequency,
      interval: interval ?? this.interval,
      nextRunAt: nextRunAt ?? this.nextRunAt,
      endAt: clearEndAt ? null : (endAt ?? this.endAt),
      isEnabled: isEnabled ?? this.isEnabled,
      autoPost: autoPost ?? this.autoPost,
    );
  }
}

class RecurringOccurrence {
  const RecurringOccurrence({
    required this.key,
    required this.ruleId,
    required this.scheduledAt,
    this.status = RecurringOccurrenceStatus.pending,
    this.transactionId,
  });

  final String key;
  final int ruleId;
  final DateTime scheduledAt;
  final RecurringOccurrenceStatus status;
  final int? transactionId;

  Map<String, Object?> toMap() => {
        'key': key,
        'rule_id': ruleId,
        'scheduled_at': scheduledAt.toIso8601String(),
        'status': status.storageValue,
        'transaction_id': transactionId,
      };

  factory RecurringOccurrence.fromMap(Map<String, Object?> map) {
    return RecurringOccurrence(
      key: map['key'] as String,
      ruleId: (map['rule_id'] as num).toInt(),
      scheduledAt: DateTime.parse(map['scheduled_at'] as String),
      status: RecurringOccurrenceStatus.fromStorage(map['status'] as String?),
      transactionId: (map['transaction_id'] as num?)?.toInt(),
    );
  }

  RecurringOccurrence copyWith({
    RecurringOccurrenceStatus? status,
    int? transactionId,
  }) {
    return RecurringOccurrence(
      key: key,
      ruleId: ruleId,
      scheduledAt: scheduledAt,
      status: status ?? this.status,
      transactionId: transactionId ?? this.transactionId,
    );
  }
}
