import 'package:flutter_test/flutter_test.dart';
import 'package:jmoney/models/category.dart';
import 'package:jmoney/models/finance_transaction.dart';
import 'package:jmoney/models/jar.dart';

void main() {
  test('Jar maps stored values without losing numeric precision', () {
    final jar = Jar.fromMap({
      'id': 4,
      'name': 'Giáo dục',
      'percentage': 10,
      'balance': 125000,
      'color': '#7A559D',
      'order_index': 3,
    });

    expect(jar.percentage, 10);
    expect(jar.balance, 125000);
    expect(jar.toMap()['order_index'], 3);
  });

  test('Category supports a shared category with no jar', () {
    final category = Category.fromMap({
      'id': 1,
      'name': 'Khác',
      'icon': '📌',
      'jar_id': null,
      'color': null,
    });

    expect(category.jarId, isNull);
    expect(category.toMap()['jar_id'], isNull);
  });

  test('Finance transaction round-trips its date and type', () {
    final date = DateTime(2026, 7, 31, 8, 30);
    final transaction = FinanceTransaction(
      id: 8,
      type: TransactionType.expense,
      amount: 45000,
      jarId: 1,
      categoryId: 2,
      note: 'Xăng xe',
      date: date,
      incomeAllocations: const {1: 25000, 2: 20000},
    );

    final restored = FinanceTransaction.fromMap(transaction.toMap());

    expect(restored.type, TransactionType.expense);
    expect(restored.date, date);
    expect(restored.amount, 45000);
    expect(restored.incomeAllocations, {1: 25000, 2: 20000});
  });
}
