class FinancialGoal {
  const FinancialGoal({
    this.id,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0,
    this.deadline,
    this.jarId,
    this.priority = 2,
    this.isEmergencyFund = false,
    required this.createdAt,
  });

  final int? id;
  final String name;
  final int targetAmount;
  final int currentAmount;
  final DateTime? deadline;
  final int? jarId;
  final int priority;
  final bool isEmergencyFund;
  final DateTime createdAt;

  double get progress =>
      targetAmount <= 0 ? 0 : (currentAmount / targetAmount).clamp(0, 1);

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'target_amount': targetAmount,
        'current_amount': currentAmount,
        'deadline': deadline?.toIso8601String(),
        'jar_id': jarId,
        'priority': priority,
        'is_emergency_fund': isEmergencyFund,
        'created_at': createdAt.toIso8601String(),
      };

  factory FinancialGoal.fromMap(Map<String, Object?> map) {
    return FinancialGoal(
      id: (map['id'] as num?)?.toInt(),
      name: map['name'] as String,
      targetAmount: (map['target_amount'] as num).toInt(),
      currentAmount: (map['current_amount'] as num?)?.toInt() ?? 0,
      deadline: map['deadline'] == null
          ? null
          : DateTime.parse(map['deadline'] as String),
      jarId: (map['jar_id'] as num?)?.toInt(),
      priority: (map['priority'] as num?)?.toInt() ?? 2,
      isEmergencyFund: map['is_emergency_fund'] as bool? ?? false,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  FinancialGoal copyWith({
    int? id,
    String? name,
    int? targetAmount,
    int? currentAmount,
    DateTime? deadline,
    bool clearDeadline = false,
    int? jarId,
    bool clearJar = false,
    int? priority,
    bool? isEmergencyFund,
    DateTime? createdAt,
  }) {
    return FinancialGoal(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      deadline: clearDeadline ? null : (deadline ?? this.deadline),
      jarId: clearJar ? null : (jarId ?? this.jarId),
      priority: priority ?? this.priority,
      isEmergencyFund: isEmergencyFund ?? this.isEmergencyFund,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class GoalContribution {
  const GoalContribution({
    this.id,
    required this.goalId,
    required this.amount,
    required this.date,
    this.note,
  });

  final int? id;
  final int goalId;
  final int amount;
  final DateTime date;
  final String? note;

  Map<String, Object?> toMap() => {
        'id': id,
        'goal_id': goalId,
        'amount': amount,
        'date': date.toIso8601String(),
        'note': note,
      };

  factory GoalContribution.fromMap(Map<String, Object?> map) {
    return GoalContribution(
      id: (map['id'] as num?)?.toInt(),
      goalId: (map['goal_id'] as num).toInt(),
      amount: (map['amount'] as num).toInt(),
      date: DateTime.parse(map['date'] as String),
      note: map['note'] as String?,
    );
  }
}
