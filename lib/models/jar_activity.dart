import 'finance_transaction.dart';

enum JarActivityType {
  income,
  expense,
  transferIn,
  transferOut,
}

class JarActivity {
  const JarActivity({
    required this.transaction,
    required this.type,
    required this.delta,
    required this.balanceAfter,
  });

  final FinanceTransaction transaction;
  final JarActivityType type;
  final int delta;
  final int balanceAfter;
}
