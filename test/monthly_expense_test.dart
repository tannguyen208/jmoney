import 'package:flutter_test/flutter_test.dart';
import 'package:jmoney/models/finance_transaction.dart';
import 'package:jmoney/providers/finance_provider.dart';
import 'package:jmoney/storage/finance_storage.dart';
import 'package:jmoney/storage/key_value_store.dart';

void main() {
  test('groups expense summaries by month and resets the active period',
      () async {
    final storage = FinanceStorage(keyValueStore: MemoryKeyValueStore());
    final jar = (await storage.getAllJars()).first;
    final category = (await storage.getCategoriesByJar(jar.id!)).first;

    await storage.insertTransaction(
      FinanceTransaction(
        type: TransactionType.expense,
        amount: 100000,
        jarId: jar.id,
        categoryId: category.id,
        date: DateTime(2026, 7, 31),
      ),
    );
    await storage.insertTransaction(
      FinanceTransaction(
        type: TransactionType.expense,
        amount: 250000,
        jarId: jar.id,
        categoryId: category.id,
        date: DateTime(2026, 8, 1),
      ),
    );

    var now = DateTime(2026, 8, 15);
    final provider = FinanceProvider(storage: storage, clock: () => now);
    await provider.initialize();

    expect(provider.currentPeriod, DateTime(2026, 8));
    expect(provider.currentMonthExpense, 250000);
    expect(provider.spendingByCategory.single.amount, 250000);
    expect(provider.totalBalance, -250000);

    await provider.selectPreviousMonth();
    expect(provider.currentPeriod, DateTime(2026, 7));
    expect(provider.currentMonthExpense, 100000);
    expect(provider.periodTransactions, hasLength(1));
    expect(provider.totalBalance, -100000);

    await provider.selectNextMonth();
    expect(provider.currentPeriod, DateTime(2026, 8));
    expect(provider.totalBalance, -250000);

    await provider.selectNextMonth();
    expect(provider.currentPeriod, DateTime(2026, 9));
    expect(provider.currentMonthExpense, 0);
    expect(provider.totalBalance, 0);
    expect(provider.jars.map((jar) => jar.percentage), [55, 25, 10, 10]);

    await provider.selectCurrentMonth();
    expect(provider.currentPeriod, DateTime(2026, 8));

    now = DateTime(2026, 9, 1);
    await provider.refresh();

    expect(provider.currentPeriod, DateTime(2026, 9));
    expect(provider.currentMonthExpense, 0);
    expect(provider.spendingByCategory, isEmpty);
    expect(provider.transactions, hasLength(2));
  });
}
