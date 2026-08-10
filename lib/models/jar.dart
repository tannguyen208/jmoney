class Jar {
  const Jar({
    this.id,
    required this.name,
    this.description,
    this.templateKey,
    required this.percentage,
    this.balance = 0,
    this.color,
    this.orderIndex = 0,
    this.isBalanceHidden = false,
  });

  final int? id;
  final String name;
  final String? description;
  final String? templateKey;
  final double percentage;
  final int balance;
  final String? color;
  final int orderIndex;
  final bool isBalanceHidden;

  Map<String, Object?> toMap({bool includeId = true}) {
    return {
      if (includeId) 'id': id,
      'name': name,
      'description': description,
      'template_key': templateKey,
      'percentage': percentage,
      'balance': balance,
      'color': color,
      'order_index': orderIndex,
      'is_balance_hidden': isBalanceHidden,
    };
  }

  factory Jar.fromMap(Map<String, Object?> map) {
    return Jar(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String?,
      templateKey: map['template_key'] as String?,
      percentage: (map['percentage'] as num).toDouble(),
      balance: (map['balance'] as num?)?.toInt() ?? 0,
      color: map['color'] as String?,
      orderIndex: map['order_index'] as int? ?? 0,
      isBalanceHidden: map['is_balance_hidden'] as bool? ?? false,
    );
  }

  Jar copyWith({
    int? id,
    String? name,
    String? description,
    bool clearDescription = false,
    String? templateKey,
    bool clearTemplateKey = false,
    double? percentage,
    int? balance,
    String? color,
    int? orderIndex,
    bool? isBalanceHidden,
  }) {
    return Jar(
      id: id ?? this.id,
      name: name ?? this.name,
      description: clearDescription ? null : (description ?? this.description),
      templateKey: clearTemplateKey ? null : (templateKey ?? this.templateKey),
      percentage: percentage ?? this.percentage,
      balance: balance ?? this.balance,
      color: color ?? this.color,
      orderIndex: orderIndex ?? this.orderIndex,
      isBalanceHidden: isBalanceHidden ?? this.isBalanceHidden,
    );
  }
}
