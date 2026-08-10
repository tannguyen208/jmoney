import 'package:flutter_test/flutter_test.dart';
import 'package:jmoney/models/finance_transaction.dart';
import 'package:jmoney/models/jar_activity.dart';
import 'package:jmoney/providers/finance_provider.dart';
import 'package:jmoney/storage/finance_storage.dart';
import 'package:jmoney/storage/key_value_store.dart';

void main() {
  test('reconstructs jar balance after deposits, expenses, and transfers',
      () async {
    final storage = FinanceStorage(keyValueStore: MemoryKeyValueStore());
    final jars = await storage.getAllJars();
    final source = jars[0];
    final destination = jars[1];
    final category = (await storage.getCategoriesByJar(source.id!)).first;

    await storage.insertTransaction(
      FinanceTransaction(
        type: TransactionType.income,
        amount: 1000000,
        incomeAllocations: {
          source.id!: 700000,
          destination.id!: 300000,
        },
        date: DateTime(2026, 8, 1),
      ),
    );
    await storage.insertTransaction(
      FinanceTransaction(
        type: TransactionType.expense,
        amount: 100000,
        jarId: source.id,
        categoryId: category.id,
        date: DateTime(2026, 8, 2),
      ),
    );
    await storage.insertTransaction(
      FinanceTransaction(
        type: TransactionType.transfer,
        amount: 50000,
        jarId: source.id,
        destinationJarId: destination.id,
        date: DateTime(2026, 8, 3),
      ),
    );

    final provider = FinanceProvider(storage: storage);
    await provider.initialize();
    final sourceActivities = provider.activitiesForJar(source.id!);
    final destinationActivities = provider.activitiesForJar(destination.id!);

    expect(
      sourceActivities.map((item) => item.type),
      [
        JarActivityType.transferOut,
        JarActivityType.expense,
        JarActivityType.income,
      ],
    );
    expect(
        sourceActivities.map((item) => item.delta), [-50000, -100000, 700000]);
    expect(sourceActivities.map((item) => item.balanceAfter),
        [550000, 600000, 700000]);
    expect(
      destinationActivities.map((item) => item.type),
      [JarActivityType.transferIn, JarActivityType.income],
    );
    expect(destinationActivities.map((item) => item.balanceAfter),
        [350000, 300000]);
  });
}
