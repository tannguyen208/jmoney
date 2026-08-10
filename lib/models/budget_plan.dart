enum BudgetMethod {
  fourJars,
  sixJars,
  fiftyTwentyThirty,
  custom;

  String get storageValue => name;

  static BudgetMethod fromStorage(String? value) {
    return BudgetMethod.values.firstWhere(
      (item) => item.storageValue == value,
      orElse: () => BudgetMethod.custom,
    );
  }
}

enum RolloverPolicy {
  keep,
  moveToSavings,
  redistribute;

  String get storageValue => name;

  static RolloverPolicy fromStorage(String? value) {
    return RolloverPolicy.values.firstWhere(
      (item) => item.storageValue == value,
      orElse: () => RolloverPolicy.keep,
    );
  }
}

class BudgetPlan {
  const BudgetPlan({
    this.id,
    required this.name,
    required this.method,
    this.isActive = false,
    required this.effectiveFrom,
    this.rolloverPolicy = RolloverPolicy.keep,
  });

  final int? id;
  final String name;
  final BudgetMethod method;
  final bool isActive;
  final DateTime effectiveFrom;
  final RolloverPolicy rolloverPolicy;

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'method': method.storageValue,
        'is_active': isActive,
        'effective_from': effectiveFrom.toIso8601String(),
        'rollover_policy': rolloverPolicy.storageValue,
      };

  factory BudgetPlan.fromMap(Map<String, Object?> map) {
    return BudgetPlan(
      id: (map['id'] as num?)?.toInt(),
      name: map['name'] as String,
      method: BudgetMethod.fromStorage(map['method'] as String?),
      isActive: map['is_active'] as bool? ?? false,
      effectiveFrom: DateTime.parse(map['effective_from'] as String),
      rolloverPolicy:
          RolloverPolicy.fromStorage(map['rollover_policy'] as String?),
    );
  }

  BudgetPlan copyWith({
    int? id,
    String? name,
    BudgetMethod? method,
    bool? isActive,
    DateTime? effectiveFrom,
    RolloverPolicy? rolloverPolicy,
  }) {
    return BudgetPlan(
      id: id ?? this.id,
      name: name ?? this.name,
      method: method ?? this.method,
      isActive: isActive ?? this.isActive,
      effectiveFrom: effectiveFrom ?? this.effectiveFrom,
      rolloverPolicy: rolloverPolicy ?? this.rolloverPolicy,
    );
  }
}

class BudgetLimit {
  const BudgetLimit({
    this.id,
    required this.year,
    required this.month,
    this.jarId,
    this.categoryId,
    required this.plannedAmount,
    this.rolloverAmount = 0,
  });

  final int? id;
  final int year;
  final int month;
  final int? jarId;
  final int? categoryId;
  final int plannedAmount;
  final int rolloverAmount;

  int get availableAmount => plannedAmount + rolloverAmount;

  Map<String, Object?> toMap() => {
        'id': id,
        'year': year,
        'month': month,
        'jar_id': jarId,
        'category_id': categoryId,
        'planned_amount': plannedAmount,
        'rollover_amount': rolloverAmount,
      };

  factory BudgetLimit.fromMap(Map<String, Object?> map) {
    return BudgetLimit(
      id: (map['id'] as num?)?.toInt(),
      year: (map['year'] as num).toInt(),
      month: (map['month'] as num).toInt(),
      jarId: (map['jar_id'] as num?)?.toInt(),
      categoryId: (map['category_id'] as num?)?.toInt(),
      plannedAmount: (map['planned_amount'] as num).toInt(),
      rolloverAmount: (map['rollover_amount'] as num?)?.toInt() ?? 0,
    );
  }

  BudgetLimit copyWith({
    int? id,
    int? year,
    int? month,
    int? jarId,
    bool clearJar = false,
    int? categoryId,
    bool clearCategory = false,
    int? plannedAmount,
    int? rolloverAmount,
  }) {
    return BudgetLimit(
      id: id ?? this.id,
      year: year ?? this.year,
      month: month ?? this.month,
      jarId: clearJar ? null : (jarId ?? this.jarId),
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      plannedAmount: plannedAmount ?? this.plannedAmount,
      rolloverAmount: rolloverAmount ?? this.rolloverAmount,
    );
  }
}
