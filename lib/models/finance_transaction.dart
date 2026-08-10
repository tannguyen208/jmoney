enum TransactionType {
  income,
  expense,
  transfer;

  String get storageValue => name;

  static TransactionType fromDatabase(String value) {
    return TransactionType.values.firstWhere(
      (type) => type.storageValue == value,
    );
  }
}

class FinanceTransaction {
  const FinanceTransaction({
    this.id,
    required this.type,
    required this.amount,
    this.jarId,
    this.destinationJarId,
    this.categoryId,
    this.note,
    required this.date,
    this.description,
    this.incomeAllocations = const {},
    this.accountName,
    this.recurringRuleId,
    this.occurrenceKey,
    this.createdAt,
    this.updatedAt,
  });

  final int? id;
  final TransactionType type;
  final int amount;
  final int? jarId;
  final int? destinationJarId;
  final int? categoryId;
  final String? note;
  final DateTime date;
  final String? description;
  final Map<int, int> incomeAllocations;
  final String? accountName;
  final int? recurringRuleId;
  final String? occurrenceKey;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, Object?> toMap({bool includeId = true}) {
    return {
      if (includeId) 'id': id,
      'type': type.storageValue,
      'amount': amount,
      'jar_id': jarId,
      'destination_jar_id': destinationJarId,
      'category_id': categoryId,
      'note': note,
      'date': date.toIso8601String(),
      'description': description,
      'income_allocations': {
        for (final entry in incomeAllocations.entries)
          entry.key.toString(): entry.value,
      },
      'account_name': accountName,
      'recurring_rule_id': recurringRuleId,
      'occurrence_key': occurrenceKey,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory FinanceTransaction.fromMap(Map<String, Object?> map) {
    return FinanceTransaction(
      id: map['id'] as int?,
      type: TransactionType.fromDatabase(map['type'] as String),
      amount: (map['amount'] as num).toInt(),
      jarId: map['jar_id'] as int?,
      destinationJarId: map['destination_jar_id'] as int?,
      categoryId: map['category_id'] as int?,
      note: map['note'] as String?,
      date: DateTime.parse(map['date'] as String),
      description: map['description'] as String?,
      incomeAllocations: {
        for (final entry
            in ((map['income_allocations'] as Map<Object?, Object?>?) ??
                    const {})
                .entries)
          int.parse(entry.key.toString()): (entry.value as num).toInt(),
      },
      accountName: map['account_name'] as String?,
      recurringRuleId: map['recurring_rule_id'] as int?,
      occurrenceKey: map['occurrence_key'] as String?,
      createdAt: map['created_at'] == null
          ? null
          : DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] == null
          ? null
          : DateTime.parse(map['updated_at'] as String),
    );
  }

  FinanceTransaction copyWith({
    int? id,
    TransactionType? type,
    int? amount,
    int? jarId,
    bool clearJar = false,
    int? destinationJarId,
    bool clearDestinationJar = false,
    int? categoryId,
    bool clearCategory = false,
    String? note,
    DateTime? date,
    String? description,
    Map<int, int>? incomeAllocations,
    String? accountName,
    bool clearAccountName = false,
    int? recurringRuleId,
    bool clearRecurringRule = false,
    String? occurrenceKey,
    bool clearOccurrenceKey = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FinanceTransaction(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      jarId: clearJar ? null : (jarId ?? this.jarId),
      destinationJarId: clearDestinationJar
          ? null
          : (destinationJarId ?? this.destinationJarId),
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      note: note ?? this.note,
      date: date ?? this.date,
      description: description ?? this.description,
      incomeAllocations: incomeAllocations ?? this.incomeAllocations,
      accountName: clearAccountName ? null : (accountName ?? this.accountName),
      recurringRuleId:
          clearRecurringRule ? null : (recurringRuleId ?? this.recurringRuleId),
      occurrenceKey:
          clearOccurrenceKey ? null : (occurrenceKey ?? this.occurrenceKey),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
