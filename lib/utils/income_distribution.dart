List<int> distributeIncome({
  required int amount,
  required List<double> percentages,
}) {
  if (amount < 0) {
    throw ArgumentError.value(amount, 'amount', 'Must not be negative');
  }
  if (percentages.isEmpty) {
    throw StateError('At least one jar is required');
  }
  if (percentages.any((percentage) => percentage < 0)) {
    throw ArgumentError.value(
      percentages,
      'percentages',
      'Must not contain negative values',
    );
  }

  final totalPercentage = percentages.fold<double>(
    0,
    (sum, percentage) => sum + percentage,
  );
  if (totalPercentage <= 0) {
    throw StateError('The total jar percentage must be greater than zero');
  }

  final result = <int>[];
  var distributed = 0;
  for (var index = 0; index < percentages.length; index++) {
    if (index == percentages.length - 1) {
      result.add(amount - distributed);
      continue;
    }

    final normalized = amount * percentages[index] / totalPercentage;
    final remaining = amount - distributed;
    final rounded = normalized.round().clamp(0, remaining);
    result.add(rounded);
    distributed += rounded;
  }
  return result;
}
