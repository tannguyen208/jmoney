class SpendingSummary {
  const SpendingSummary({
    required this.id,
    required this.label,
    required this.amount,
    this.color,
    this.icon,
  });

  final int id;
  final String label;
  final int amount;
  final String? color;
  final String? icon;
}
