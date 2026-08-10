enum CategoryType {
  expense,
  income;

  String get storageValue => name;

  static CategoryType fromStorage(Object? value) {
    return CategoryType.values.firstWhere(
      (type) => type.storageValue == value,
      orElse: () => CategoryType.expense,
    );
  }
}

class Category {
  const Category({
    this.id,
    required this.name,
    this.icon,
    this.jarId,
    this.color,
    this.type = CategoryType.expense,
  });

  final int? id;
  final String name;
  final String? icon;
  final int? jarId;
  final String? color;
  final CategoryType type;

  Map<String, Object?> toMap({bool includeId = true}) {
    return {
      if (includeId) 'id': id,
      'name': name,
      'icon': icon,
      'jar_id': jarId,
      'color': color,
      'type': type.storageValue,
    };
  }

  factory Category.fromMap(Map<String, Object?> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] as String,
      icon: map['icon'] as String?,
      jarId: map['jar_id'] as int?,
      color: map['color'] as String?,
      type: CategoryType.fromStorage(map['type']),
    );
  }

  Category copyWith({
    int? id,
    String? name,
    String? icon,
    int? jarId,
    bool clearJar = false,
    String? color,
    CategoryType? type,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      jarId: clearJar ? null : (jarId ?? this.jarId),
      color: color ?? this.color,
      type: type ?? this.type,
    );
  }
}
