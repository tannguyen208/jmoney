import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:jmoney/models/budget_plan.dart';
import 'package:jmoney/models/category.dart';
import 'package:jmoney/models/finance_transaction.dart';
import 'package:jmoney/models/financial_goal.dart';
import 'package:jmoney/models/recurring_rule.dart';
import 'package:jmoney/providers/finance_provider.dart';
import 'package:jmoney/services/reminder_service.dart';
import 'package:jmoney/storage/finance_storage.dart';
import 'package:jmoney/storage/key_value_store.dart';

void main() {
  late MemoryKeyValueStore backend;
  late FinanceStorage storage;

  setUp(() {
    backend = MemoryKeyValueStore();
    storage = FinanceStorage(keyValueStore: backend);
  });

  test('seeds four jars, twenty-two expense and seven income categories',
      () async {
    final jars = await storage.getAllJars();

    expect(jars, hasLength(4));
    expect(jars.map((jar) => jar.percentage).reduce((a, b) => a + b), 100);
    final categories = await storage.getAllCategories();
    expect(categories, hasLength(29));
    expect(
      categories.where((item) => item.type == CategoryType.expense),
      hasLength(22),
    );
    expect(
      categories.where((item) => item.type == CategoryType.income),
      hasLength(7),
    );
  });

  test('reloads the complete snapshot from the same local store', () async {
    final jar = (await storage.getAllJars()).first;
    final category = (await storage.getCategoriesByJar(jar.id!)).first;
    await storage.insertTransaction(
      FinanceTransaction(
        type: TransactionType.income,
        amount: 1000000,
        date: DateTime(2026, 7, 31),
      ),
    );
    await storage.insertTransaction(
      FinanceTransaction(
        type: TransactionType.expense,
        amount: 50000,
        jarId: jar.id,
        categoryId: category.id,
        date: DateTime(2026, 7, 31),
      ),
    );

    final reloaded = FinanceStorage(keyValueStore: backend);
    final jars = await reloaded.getAllJars();
    final transactions = await reloaded.getAllTransactions();

    expect(jars.first.balance, 500000);
    expect(transactions, hasLength(2));
    expect(transactions.last.incomeAllocations.values.reduce((a, b) => a + b),
        1000000);
  });

  test('normalizes income and persists every whole VND', () async {
    final jars = await storage.getAllJars();
    const percentages = [50.0, 25.0, 10.0, 5.0];
    for (var index = 0; index < jars.length; index++) {
      await storage.updateJar(
        jars[index].copyWith(percentage: percentages[index]),
        year: 2026,
        month: 7,
      );
    }

    await storage.insertTransaction(
      FinanceTransaction(
        type: TransactionType.income,
        amount: 9000001,
        date: DateTime(2026, 7, 31),
      ),
    );

    final balances =
        (await storage.getAllJars()).map((jar) => jar.balance).toList();
    expect(balances.reduce((a, b) => a + b), 9000001);
    expect(balances, [5000001, 2500000, 1000000, 500000]);
  });

  test('deleting income restores its saved allocations', () async {
    final id = await storage.insertTransaction(
      FinanceTransaction(
        type: TransactionType.income,
        amount: 200003,
        date: DateTime(2026, 7, 31),
      ),
    );
    final income = (await storage.getAllTransactions())
        .firstWhere((item) => item.id == id);

    await storage.deleteTransaction(income);

    final jars = await storage.getAllJars();
    expect(jars.every((jar) => jar.balance == 0), isTrue);
  });

  test('persists income sources and rejects expense categories for income',
      () async {
    final categories = await storage.getAllCategories();
    final incomeCategory = categories.firstWhere(
      (category) => category.type == CategoryType.income,
    );
    final expenseCategory = categories.firstWhere(
      (category) => category.type == CategoryType.expense,
    );

    final id = await storage.insertTransaction(
      FinanceTransaction(
        type: TransactionType.income,
        amount: 100000,
        categoryId: incomeCategory.id,
        date: DateTime(2026, 8, 2),
      ),
    );
    final saved = (await storage.getAllTransactions()).firstWhere(
      (transaction) => transaction.id == id,
    );

    expect(saved.categoryId, incomeCategory.id);
    expect(
      () => storage.insertTransaction(
        FinanceTransaction(
          type: TransactionType.income,
          amount: 50000,
          categoryId: expenseCategory.id,
          date: DateTime(2026, 8, 2),
        ),
      ),
      throwsStateError,
    );
  });

  test('rejects an expense category assigned to another jar', () async {
    final jars = await storage.getAllJars();
    final category = (await storage.getCategoriesByJar(jars.first.id!))
        .firstWhere((item) => item.jarId == jars.first.id);

    expect(
      () => storage.insertTransaction(
        FinanceTransaction(
          type: TransactionType.expense,
          amount: 10000,
          jarId: jars[1].id,
          categoryId: category.id,
          date: DateTime(2026, 7, 31),
        ),
      ),
      throwsStateError,
    );
  });

  test('does not delete a jar that owns financial history', () async {
    await storage.insertTransaction(
      FinanceTransaction(
        type: TransactionType.income,
        amount: 100000,
        date: DateTime(2026, 7, 31),
      ),
    );
    final jar = (await storage.getAllJars()).first;

    expect(() => storage.deleteJar(jar.id!), throwsStateError);
    expect(await storage.getAllJars(), hasLength(4));
  });

  test('migrates schema v1 and keeps a restorable backup', () async {
    final legacy = {
      'schema_version': 1,
      'next_jar_id': 2,
      'next_category_id': 2,
      'next_transaction_id': 2,
      'jars': [
        {
          'id': 1,
          'name': 'Cũ',
          'percentage': 100,
          'balance': 90000,
          'color': '#247A68',
          'order_index': 0,
        },
      ],
      'categories': [
        {
          'id': 1,
          'name': 'Ăn uống',
          'icon': '🍜',
          'jar_id': 1,
          'color': null,
        },
      ],
      'transactions': [
        {
          'id': 1,
          'type': 'income',
          'amount': 90000,
          'jar_id': null,
          'category_id': null,
          'note': null,
          'date': '2026-07-31T00:00:00.000',
          'description': null,
          'income_allocations': {'1': 90000},
        },
      ],
    };
    backend.writeString('finance.snapshot', jsonEncode(legacy));

    final migrated = FinanceStorage(keyValueStore: backend);

    expect((await migrated.getAllJars()).single.balance, 90000);
    expect(await migrated.getBudgetPlans(), hasLength(1));
    expect(await migrated.getLatestBackup(), jsonEncode(legacy));
    expect(
      jsonDecode(await migrated.exportSnapshot())['schema_version'],
      4,
    );
  });

  test('separates jar balances by month and inherits previous percentages',
      () async {
    final augustJars = await storage.getJarsForMonth(year: 2026, month: 8);
    const augustPercentages = [50.0, 25.0, 15.0, 10.0];
    for (var index = 0; index < augustJars.length; index++) {
      await storage.updateJar(
        augustJars[index].copyWith(
          percentage: augustPercentages[index],
        ),
        year: 2026,
        month: 8,
      );
    }
    await storage.insertTransaction(
      FinanceTransaction(
        type: TransactionType.income,
        amount: 100000,
        date: DateTime(2026, 8, 15),
      ),
    );

    final august = await storage.getJarsForMonth(year: 2026, month: 8);
    final september = await storage.getJarsForMonth(year: 2026, month: 9);
    final july = await storage.getJarsForMonth(year: 2026, month: 7);

    expect(august.map((jar) => jar.balance), [50000, 25000, 15000, 10000]);
    expect(august.map((jar) => jar.percentage), augustPercentages);
    expect(september.map((jar) => jar.balance), everyElement(0));
    expect(september.map((jar) => jar.percentage), augustPercentages);
    expect(july.map((jar) => jar.balance), everyElement(0));
    expect(july.map((jar) => jar.percentage), [55, 25, 10, 10]);

    await storage.insertTransaction(
      FinanceTransaction(
        type: TransactionType.income,
        amount: 200000,
        date: DateTime(2026, 9, 1),
      ),
    );
    expect(
      (await storage.getJarsForMonth(year: 2026, month: 9))
          .map((jar) => jar.balance),
      [100000, 50000, 30000, 20000],
    );
    expect(
      (await storage.getJarsForMonth(year: 2026, month: 8))
          .map((jar) => jar.balance),
      [50000, 25000, 15000, 10000],
    );
  });

  test('viewing a future month does not freeze inherited percentages',
      () async {
    const updatedPercentages = [45.0, 30.0, 15.0, 10.0];
    await storage.getJarsForMonth(year: 2040, month: 2);

    final january = await storage.getJarsForMonth(year: 2040, month: 1);
    for (var index = 0; index < january.length; index++) {
      await storage.updateJar(
        january[index].copyWith(percentage: updatedPercentages[index]),
        year: 2040,
        month: 1,
      );
    }

    final february = await storage.getJarsForMonth(year: 2040, month: 2);
    expect(february.map((jar) => jar.percentage), updatedPercentages);
  });

  test('migrates schema v2 into a current monthly jar period', () async {
    final legacy = jsonDecode(await storage.exportSnapshot()) as Map;
    legacy['schema_version'] = 2;
    legacy.remove('jar_periods');
    final encoded = jsonEncode(legacy);
    backend.writeString('finance.snapshot', encoded);

    final migrated = FinanceStorage(keyValueStore: backend);
    final now = DateTime.now();
    final jars = await migrated.getJarsForMonth(
      year: now.year,
      month: now.month,
    );

    expect(jars.map((jar) => jar.percentage), [55, 25, 10, 10]);
    expect(await migrated.getLatestBackup(), encoded);
    expect(jsonDecode(await migrated.exportSnapshot())['schema_version'], 4);
  });

  test('migrates schema v3 and adds the new category catalogs', () async {
    final legacy = jsonDecode(await storage.exportSnapshot()) as Map;
    legacy['schema_version'] = 3;
    legacy['categories'] = [
      {
        'id': 1,
        'name': 'Ăn uống',
        'icon': '🍜',
        'jar_id': 1,
        'color': null,
      },
    ];
    legacy['next_category_id'] = 2;
    final encoded = jsonEncode(legacy);
    backend.writeString('finance.snapshot', encoded);

    final migrated = FinanceStorage(keyValueStore: backend);
    final categories = await migrated.getAllCategories();

    expect(categories, hasLength(29));
    expect(
      categories.where((item) => item.type == CategoryType.expense),
      hasLength(22),
    );
    expect(
      categories.where((item) => item.type == CategoryType.income),
      hasLength(7),
    );
    expect(
      categories.firstWhere((item) => item.name == 'Ăn uống').icon,
      'icons8:food',
    );
    expect(jsonDecode(await migrated.exportSnapshot())['schema_version'], 4);
    expect(await migrated.getLatestBackup(), encoded);
  });

  test('exports and imports data while backing up the previous state',
      () async {
    await storage.insertTransaction(
      FinanceTransaction(
        type: TransactionType.income,
        amount: 123000,
        date: DateTime(2026, 8, 1),
      ),
    );
    final exported = await storage.exportSnapshot();
    final targetBackend = MemoryKeyValueStore();
    final target = FinanceStorage(keyValueStore: targetBackend);
    await target.getAllJars();

    await target.importSnapshot(exported);

    expect((await target.getAllTransactions()).single.amount, 123000);
    expect(await target.getLatestBackup(), isNotNull);
  });

  test('resets all local data and restores the default JMoney setup', () async {
    await storage.insertTransaction(
      FinanceTransaction(
        type: TransactionType.income,
        amount: 123000,
        date: DateTime(2026, 8, 2),
      ),
    );
    await storage.applyBudgetTemplate(BudgetMethod.sixJars);
    final snapshotWithUserData = await storage.exportSnapshot();
    await storage.importSnapshot(snapshotWithUserData);
    expect(await storage.getLatestBackup(), isNotNull);

    await storage.resetAllData();

    final jars = await storage.getAllJars();
    expect(jars, hasLength(4));
    expect(jars.map((jar) => jar.percentage), [55, 25, 10, 10]);
    expect(jars.map((jar) => jar.balance), everyElement(0));
    expect(await storage.getAllCategories(), hasLength(29));
    expect(await storage.getAllTransactions(), isEmpty);
    expect(await storage.getBudgetLimits(year: 2026, month: 8), isEmpty);
    expect(await storage.getGoals(), isEmpty);
    expect(await storage.getRecurringRules(), isEmpty);
    expect(
        (await storage.getBudgetPlans()).single.method, BudgetMethod.fourJars);
    expect(await storage.getLatestBackup(), isNull);

    final reloaded = FinanceStorage(keyValueStore: backend);
    expect(await reloaded.getAllTransactions(), isEmpty);
    expect((await reloaded.getAllJars()).map((jar) => jar.percentage),
        [55, 25, 10, 10]);
  });

  test('rolls back the snapshot when reset cannot remove the backup', () async {
    final failingBackend = _FailingRemoveKeyValueStore();
    final failingStorage = FinanceStorage(keyValueStore: failingBackend);
    await failingStorage.insertTransaction(
      FinanceTransaction(
        type: TransactionType.income,
        amount: 456000,
        date: DateTime(2026, 8, 2),
      ),
    );
    failingBackend.writeString('finance.backup.latest', 'existing backup');
    final snapshotBefore = await failingStorage.exportSnapshot();
    failingBackend.failNextRemove = true;

    await expectLater(failingStorage.resetAllData(), throwsStateError);

    expect(await failingStorage.exportSnapshot(), snapshotBefore);
    expect((await failingStorage.getAllTransactions()).single.amount, 456000);
    expect(
      failingBackend.readString('finance.backup.latest'),
      'existing backup',
    );
    final reloaded = FinanceStorage(keyValueStore: failingBackend);
    expect((await reloaded.getAllTransactions()).single.amount, 456000);
  });

  test('does not reset data when notification cleanup fails', () async {
    final reminderService = _RecordingReminderService(failCancelAll: true);
    final provider = FinanceProvider(
      storage: FinanceStorage(keyValueStore: MemoryKeyValueStore()),
      reminderService: reminderService,
    );
    await provider.initialize();
    await provider.addIncome(
      amount: 789000,
      date: DateTime(2026, 8, 2),
    );

    final success = await provider.resetAllData();

    expect(success, isFalse);
    expect(reminderService.cancelAllCalls, 1);
    expect(provider.totalBalance, 789000);
    expect(provider.transactions, hasLength(1));
  });

  test('cleans every notification before resetting local data', () async {
    final reminderService = _RecordingReminderService();
    final provider = FinanceProvider(
      storage: FinanceStorage(keyValueStore: MemoryKeyValueStore()),
      reminderService: reminderService,
    );
    await provider.initialize();
    await provider.addIncome(
      amount: 321000,
      date: DateTime(2026, 8, 2),
    );

    final success = await provider.resetAllData();

    expect(success, isTrue);
    expect(reminderService.cancelAllCalls, 1);
    expect(provider.totalBalance, 0);
    expect(provider.transactions, isEmpty);
  });

  test('transfers money atomically without changing total balance', () async {
    await storage.insertTransaction(
      FinanceTransaction(
        type: TransactionType.income,
        amount: 100000,
        date: DateTime(2026, 8, 1),
      ),
    );
    final jars = await storage.getAllJars();
    final totalBefore = jars.fold<int>(0, (sum, jar) => sum + jar.balance);

    await storage.insertTransaction(
      FinanceTransaction(
        type: TransactionType.transfer,
        amount: 10000,
        jarId: jars.first.id,
        destinationJarId: jars.last.id,
        date: DateTime(2026, 8, 2),
      ),
    );

    final updated = await storage.getAllJars();
    expect(updated.fold<int>(0, (sum, jar) => sum + jar.balance), totalBefore);
    expect(updated.first.balance, jars.first.balance - 10000);
    expect(updated.last.balance, jars.last.balance + 10000);
  });

  test('editing an expense reverses its previous balance impact', () async {
    final jars = await storage.getAllJars();
    final firstJar = jars.first;
    final secondJar = jars[1];
    final firstCategory =
        (await storage.getCategoriesByJar(firstJar.id!)).first;
    final secondCategory =
        (await storage.getCategoriesByJar(secondJar.id!)).first;
    final id = await storage.insertTransaction(
      FinanceTransaction(
        type: TransactionType.expense,
        amount: 10000,
        jarId: firstJar.id,
        categoryId: firstCategory.id,
        date: DateTime(2026, 8, 2),
      ),
    );
    final saved = (await storage.getAllTransactions()).single;

    await storage.updateTransaction(
      saved.copyWith(
        id: id,
        amount: 25000,
        jarId: secondJar.id,
        categoryId: secondCategory.id,
      ),
    );

    final updated = await storage.getAllJars();
    expect(updated.first.balance, 0);
    expect(updated[1].balance, -25000);
  });

  test('applies six-jar template and keeps allocation balanced', () async {
    final plan = await storage.applyBudgetTemplate(BudgetMethod.sixJars);
    final jars = await storage.getAllJars();

    expect(plan.method, BudgetMethod.sixJars);
    expect(jars.where((jar) => jar.percentage > 0), hasLength(6));
    expect(
      jars.fold<double>(0, (sum, jar) => sum + jar.percentage),
      100,
    );
  });

  test('applies preset descriptions and preserves user descriptions', () async {
    final originalJars = await storage.getAllJars();
    await storage.updateJar(
      originalJars.first.copyWith(
        name: 'Chi tiêu gia đình',
        description: 'Mô tả riêng của người dùng',
      ),
    );

    final plan = await storage.applyBudgetTemplate(BudgetMethod.sixJars);
    final jars = await storage.getAllJars();
    final activeJars = jars.where((jar) => jar.percentage > 0).toList();

    expect(plan.method, BudgetMethod.sixJars);
    expect(activeJars, hasLength(6));
    expect(
      activeJars.map((jar) => jar.percentage),
      orderedEquals([55, 10, 10, 10, 10, 5]),
    );
    expect(activeJars.every((jar) => jar.description?.isNotEmpty ?? false),
        isTrue);
    expect(activeJars.first.description, 'Mô tả riêng của người dùng');

    await storage.applyBudgetTemplate(BudgetMethod.fiftyTwentyThirty);
    final simplifiedJars = (await storage.getAllJars())
        .where((jar) => jar.percentage > 0)
        .toList();
    expect(
      simplifiedJars.map((jar) => jar.percentage),
      orderedEquals([50, 20, 30]),
    );
    expect(simplifiedJars.first.description, 'Mô tả riêng của người dùng');
  });

  test('maps removed budget methods to custom without changing jars', () async {
    final before = await storage.getAllJars();

    final plan = await storage.applyBudgetTemplate(BudgetMethod.custom);
    final after = await storage.getAllJars();

    expect(plan.method, BudgetMethod.custom);
    expect(after.map((jar) => jar.toMap()), before.map((jar) => jar.toMap()));
    expect(
      BudgetMethod.fromStorage('personalFourJars'),
      BudgetMethod.custom,
    );
    expect(BudgetMethod.fromStorage('custom'), BudgetMethod.custom);
  });

  test('tracks monthly budget spending', () async {
    final jar = (await storage.getAllJars()).first;
    final category = (await storage.getCategoriesByJar(jar.id!)).first;
    await storage.insertTransaction(
      FinanceTransaction(
        type: TransactionType.expense,
        amount: 30000,
        jarId: jar.id,
        categoryId: category.id,
        date: DateTime(2026, 8, 2),
      ),
    );
    final limit = BudgetLimit(
      year: 2026,
      month: 8,
      jarId: jar.id,
      plannedAmount: 100000,
    );
    final id = await storage.saveBudgetLimit(limit);

    expect(id, greaterThan(0));
    expect(await storage.spentForBudget(limit), 30000);
  });

  test('copies a monthly budget and rolls unused money forward', () async {
    final jar = (await storage.getAllJars()).first;
    final category = (await storage.getCategoriesByJar(jar.id!)).first;
    await storage.saveBudgetLimit(
      BudgetLimit(
        year: 2026,
        month: 7,
        jarId: jar.id,
        plannedAmount: 100000,
      ),
    );
    await storage.insertTransaction(
      FinanceTransaction(
        type: TransactionType.expense,
        amount: 30000,
        jarId: jar.id,
        categoryId: category.id,
        date: DateTime(2026, 7, 20),
      ),
    );

    final copied = await storage.copyBudgetLimitsToMonth(
      fromYear: 2026,
      fromMonth: 7,
      toYear: 2026,
      toMonth: 8,
    );
    final august = await storage.getBudgetLimits(year: 2026, month: 8);

    expect(copied, 1);
    expect(august.single.plannedAmount, 100000);
    expect(august.single.rolloverAmount, 70000);
  });

  test('tracks goal contributions and emergency fund suggestion', () async {
    final goalId = await storage.saveGoal(
      FinancialGoal(
        name: 'Quỹ dự phòng',
        targetAmount: 6000000,
        isEmergencyFund: true,
        createdAt: DateTime(2026, 8, 1),
      ),
    );
    await storage.addGoalContribution(
      GoalContribution(
        goalId: goalId,
        amount: 500000,
        date: DateTime(2026, 8, 2),
      ),
    );

    expect((await storage.getGoals()).single.currentAmount, 500000);
  });

  test('creates each recurring occurrence once and posts on confirmation',
      () async {
    final ruleId = await storage.saveRecurringRule(
      RecurringRule(
        name: 'Lương',
        type: TransactionType.income,
        amount: 1000000,
        frequency: RecurrenceFrequency.monthly,
        nextRunAt: DateTime(2026, 8, 1),
      ),
    );

    final first = await storage.processDueRecurringRules(
      DateTime(2026, 8, 2),
    );
    final second = await storage.processDueRecurringRules(
      DateTime(2026, 8, 2),
    );

    expect(first, hasLength(1));
    expect(second, hasLength(1));
    expect(first.single.ruleId, ruleId);

    await storage.completeOccurrence(first.single.key);
    expect(await storage.getPendingOccurrences(), isEmpty);
    expect((await storage.getAllTransactions()).single.amount, 1000000);
  });
}

class _FailingRemoveKeyValueStore implements KeyValueStore {
  final MemoryKeyValueStore _delegate = MemoryKeyValueStore();
  bool failNextRemove = false;

  @override
  String? readString(String key) => _delegate.readString(key);

  @override
  bool writeString(String key, String value) =>
      _delegate.writeString(key, value);

  @override
  bool remove(String key) {
    if (failNextRemove) {
      failNextRemove = false;
      return false;
    }
    return _delegate.remove(key);
  }
}

class _RecordingReminderService implements ReminderService {
  _RecordingReminderService({this.failCancelAll = false});

  final bool failCancelAll;
  int cancelAllCalls = 0;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> requestPermissions() async {}

  @override
  Future<void> schedule(RecurringRule rule) async {}

  @override
  Future<void> cancel(int ruleId) async {}

  @override
  Future<void> cancelAll() async {
    cancelAllCalls++;
    if (failCancelAll) throw StateError('Notification cleanup failed');
  }
}
