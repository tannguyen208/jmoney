import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jmoney/app.dart';
import 'package:jmoney/models/category.dart';
import 'package:jmoney/models/finance_transaction.dart';
import 'package:jmoney/providers/finance_provider.dart';
import 'package:jmoney/screens/add_expense_screen.dart';
import 'package:jmoney/screens/budget_screen.dart';
import 'package:jmoney/screens/categories_screen.dart';
import 'package:jmoney/screens/edit_transaction_screen.dart';
import 'package:jmoney/screens/history_screen.dart';
import 'package:jmoney/screens/home_screen.dart';
import 'package:jmoney/screens/jar_detail_screen.dart';
import 'package:jmoney/screens/stats_screen.dart';
import 'package:jmoney/storage/finance_storage.dart';
import 'package:jmoney/storage/key_value_store.dart';
import 'package:jmoney/utils/formatters.dart';
import 'package:jmoney/widgets/expense_category_field.dart';
import 'package:jmoney/widgets/selection_field.dart';

Future<FinanceProvider> _provider() async {
  final provider = FinanceProvider(
    storage: FinanceStorage(keyValueStore: MemoryKeyValueStore()),
  );
  await provider.initialize();
  return provider;
}

Future<void> _selectOverviewDate(
  WidgetTester tester,
  DateTime date,
) async {
  await _selectDateFromCalendar(tester, 'home-calendar-button', date);
}

Future<void> _selectDateFromCalendar(
  WidgetTester tester,
  String key,
  DateTime date,
) async {
  await tester.tap(find.byKey(ValueKey(key)));
  await tester.pumpAndSettle();
  final monthKey = ValueKey('month-picker-${date.year}-${date.month}');
  expect(find.byKey(monthKey), findsOneWidget);
  await tester.tap(find.byKey(monthKey));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Sprint 0-3 management features fit a compact screen',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final provider = await _provider();

    await tester.pumpWidget(JMoneyApp(provider: provider));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Quản lý'));
    await tester.pumpAndSettle();

    expect(find.text('Kế hoạch ngân sách'), findsOneWidget);
    expect(find.text('Mục tiêu & quỹ dự phòng'), findsOneWidget);
    expect(find.text('Giao dịch định kỳ'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Sao lưu & khôi phục'),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Sao lưu & khôi phục'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Kế hoạch ngân sách'),
      -180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Kế hoạch ngân sách'));
    await tester.pumpAndSettle();

    expect(find.text('4 hũ JMoney'), findsWidgets);
    expect(find.text('Quy tắc 6 hũ'), findsOneWidget);
    expect(find.text('Quy tắc 50/20/30'), findsOneWidget);
    await tester.tap(find.text('Quy tắc 6 hũ'));
    await tester.pump();
    await tester.scrollUntilVisible(
      find.text('Áp dụng phương pháp'),
      240,
      scrollable: find.byType(Scrollable).last,
    );
    await Scrollable.ensureVisible(
      tester.element(find.text('Áp dụng phương pháp')),
      alignment: 0.7,
      duration: Duration.zero,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Áp dụng phương pháp'));
    await tester.pumpAndSettle();

    expect(provider.jars.where((jar) => jar.percentage > 0), hasLength(6));
    expect(tester.takeException(), isNull);
  });

  testWidgets('resets all data from Manage after destructive confirmation',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final provider = await _provider();
    await provider.addIncome(
      amount: 1000000,
      date: DateTime(2026, 8, 2),
    );
    expect(provider.totalBalance, 1000000);

    await tester.pumpWidget(JMoneyApp(provider: provider));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Quản lý'));
    await tester.pumpAndSettle();
    final resetTile = find.byKey(const ValueKey('reset-all-data'));
    await tester.scrollUntilVisible(
      resetTile,
      220,
      scrollable: find.byType(Scrollable).first,
    );
    await Scrollable.ensureVisible(
      tester.element(resetTile),
      alignment: 0.45,
      duration: Duration.zero,
    );
    await tester.pumpAndSettle();

    await tester.tap(resetTile);
    await tester.pumpAndSettle();
    expect(find.text('Đặt lại JMoney?'), findsOneWidget);
    expect(find.textContaining('không thể hoàn tác'), findsOneWidget);
    await tester.tap(find.text('Hủy'));
    await tester.pumpAndSettle();
    expect(provider.totalBalance, 1000000);

    await tester.tap(resetTile);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('reset-all-data-confirm')));
    await tester.pumpAndSettle();

    expect(provider.totalBalance, 0);
    expect(provider.transactions, isEmpty);
    expect(provider.jars.map((jar) => jar.percentage), [55, 25, 10, 10]);
    expect(find.text('Đã đặt lại toàn bộ dữ liệu'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('navigates monthly overview and resets jar balances',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final storage = FinanceStorage(keyValueStore: MemoryKeyValueStore());
    final jar = (await storage.getAllJars()).first;
    await storage.insertTransaction(
      FinanceTransaction(
        type: TransactionType.income,
        amount: 100000,
        incomeAllocations: {jar.id!: 100000},
        note: 'Thu tháng 7',
        date: DateTime(2026, 7, 15),
      ),
    );
    await storage.insertTransaction(
      FinanceTransaction(
        type: TransactionType.income,
        amount: 200000,
        incomeAllocations: {jar.id!: 200000},
        note: 'Thu tháng 8',
        date: DateTime(2026, 8, 15),
      ),
    );
    final provider = FinanceProvider(
      storage: storage,
      clock: () => DateTime(2026, 8, 15),
    );
    await provider.initialize();

    await tester.pumpWidget(
      JMoneyApp(provider: provider),
    );
    await tester.pumpAndSettle();

    expect(provider.currentPeriod, DateTime(2026, 8));
    expect(provider.totalBalance, 200000);
    expect(provider.periodTransactions.single.note, 'Thu tháng 8');
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('home-period-label'))).data,
      formatMonthYear(
          tester.element(find.byType(HomeScreen)), DateTime(2026, 8)),
    );

    await _selectOverviewDate(tester, DateTime(2026, 7, 15));
    expect(provider.currentPeriod, DateTime(2026, 7));
    expect(provider.totalBalance, 100000);
    expect(provider.periodTransactions.single.note, 'Thu tháng 7');
    expect(provider.suggestedTransactionDate, DateTime(2026, 7, 15));
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('home-period-label'))).data,
      formatMonthYear(
          tester.element(find.byType(HomeScreen)), DateTime(2026, 7)),
    );

    await _selectOverviewDate(tester, DateTime(2026, 9, 15));
    expect(provider.currentPeriod, DateTime(2026, 9));
    expect(provider.totalBalance, 0);
    expect(provider.periodTransactions, isEmpty);
    expect(provider.jars.map((item) => item.percentage), [55, 25, 10, 10]);

    await _selectOverviewDate(tester, DateTime(2026, 8, 15));
    expect(provider.currentPeriod, DateTime(2026, 8));
    expect(provider.totalBalance, 200000);
    expect(tester.takeException(), isNull);
  });

  testWidgets('navigates monthly spending statistics including empty months',
      (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    final storage = FinanceStorage(keyValueStore: MemoryKeyValueStore());
    final jar = (await storage.getAllJars()).first;
    final category = (await storage.getCategoriesByJar(jar.id!)).first;
    await storage.insertTransaction(
      FinanceTransaction(
        type: TransactionType.expense,
        amount: 100000,
        jarId: jar.id,
        categoryId: category.id,
        date: DateTime(2026, 7, 15),
      ),
    );
    await storage.insertTransaction(
      FinanceTransaction(
        type: TransactionType.expense,
        amount: 250000,
        jarId: jar.id,
        categoryId: category.id,
        date: DateTime(2026, 8, 15),
      ),
    );
    final provider = FinanceProvider(
      storage: storage,
      clock: () => DateTime(2026, 8, 15),
    );
    await provider.initialize();

    await tester.pumpWidget(
      JMoneyApp(provider: provider),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Thống kê'));
    await tester.pumpAndSettle();

    expect(find.byType(StatsScreen), findsOneWidget);
    expect(find.byKey(const ValueKey('stats-calendar-button')), findsOneWidget);
    expect(provider.spendingByCategory.single.amount, 250000);
    await _selectDateFromCalendar(
      tester,
      'stats-calendar-button',
      DateTime(2026, 7, 15),
    );
    expect(provider.currentPeriod, DateTime(2026, 7));
    expect(provider.spendingByCategory.single.amount, 100000);

    await _selectDateFromCalendar(
      tester,
      'stats-calendar-button',
      DateTime(2026, 8, 15),
    );
    expect(provider.currentPeriod, DateTime(2026, 8));

    await tester.scrollUntilVisible(
      find.text(category.name),
      240,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.byType(SvgPicture), findsWidgets);
    expect(
      find.text(
        formatCurrency(
          tester.element(find.byType(StatsScreen)),
          250000,
        ),
      ),
      findsWidgets,
    );
    await _selectDateFromCalendar(
      tester,
      'stats-calendar-button',
      DateTime(2026, 9, 15),
    );
    expect(provider.currentPeriod, DateTime(2026, 9));
    expect(provider.spendingByCategory, isEmpty);
    expect(find.text('Chưa có dữ liệu chi tiêu'), findsOneWidget);

    await _selectDateFromCalendar(
      tester,
      'stats-calendar-button',
      DateTime(2026, 8, 15),
    );
    expect(provider.currentPeriod, DateTime(2026, 8));
    expect(provider.spendingByCategory.single.amount, 250000);
    expect(tester.takeException(), isNull);
  });

  testWidgets('groups expense categories by jar on compact screens',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final provider = await _provider();
    await provider.saveCategory(
      const Category(name: 'Chi phí dùng chung', icon: '🧾'),
    );
    final sharedCategory = provider.categories
        .firstWhere((category) => category.name == 'Chi phí dùng chung');
    final firstJar = provider.jars.first;
    final firstJarCategory = provider.categories
        .firstWhere((category) => category.jarId == firstJar.id);

    await tester.pumpWidget(JMoneyApp(provider: provider));
    await tester.pumpAndSettle();
    tester.state<NavigatorState>(find.byType(Navigator).first).push(
          MaterialPageRoute<void>(builder: (_) => const CategoriesScreen()),
        );
    await tester.pumpAndSettle();

    final sharedGroup = find.byKey(const ValueKey('category-group-all'));
    final firstJarGroup = find.byKey(ValueKey('category-group-${firstJar.id}'));
    expect(sharedGroup, findsOneWidget);
    expect(firstJarGroup, findsOneWidget);
    expect(
      find.descendant(
        of: sharedGroup,
        matching: find.byKey(ValueKey('category-item-${sharedCategory.id}')),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: firstJarGroup,
        matching: find.byKey(ValueKey('category-item-${firstJarCategory.id}')),
      ),
      findsOneWidget,
    );
    expect(
      tester.getTopLeft(sharedGroup).dy,
      lessThan(tester.getTopLeft(firstJarGroup).dy),
    );

    final lastJarGroup =
        find.byKey(ValueKey('category-group-${provider.jars.last.id}'));
    await tester.scrollUntilVisible(
      lastJarGroup,
      220,
      scrollable: find.byType(Scrollable).last,
    );
    expect(lastJarGroup, findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('isolates and safely edits a category whose jar was deleted',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final storage = FinanceStorage(keyValueStore: MemoryKeyValueStore());
    final snapshot = Map<String, Object?>.from(
      jsonDecode(await storage.exportSnapshot()) as Map,
    );
    (snapshot['categories']! as List).add({
      'id': 999,
      'name': 'Danh mục từ hũ cũ',
      'icon': '🗂️',
      'jar_id': 999,
      'color': null,
    });
    snapshot['next_category_id'] = 1000;
    await storage.importSnapshot(jsonEncode(snapshot));
    final provider = FinanceProvider(storage: storage);
    await provider.initialize();

    await tester.pumpWidget(JMoneyApp(provider: provider));
    await tester.pumpAndSettle();
    tester.state<NavigatorState>(find.byType(Navigator).first).push(
          MaterialPageRoute<void>(builder: (_) => const CategoriesScreen()),
        );
    await tester.pumpAndSettle();

    final orphanGroup = find.byKey(const ValueKey('category-group-unknown'));
    final orphanItem = find.byKey(const ValueKey('category-item-999'));
    expect(orphanGroup, findsOneWidget);
    expect(
      find.descendant(of: orphanGroup, matching: orphanItem),
      findsOneWidget,
    );
    expect(find.text('Hũ đã xóa'), findsOneWidget);

    await tester.tap(orphanItem);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(
      tester
          .widget<SelectionField<int?>>(find.byType(SelectionField<int?>))
          .value,
      -1,
    );
    final saveButton = find.widgetWithText(FilledButton, 'Lưu');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(provider.categoryById(999)?.jarId, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('manually allocates income into selected jars', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final provider = await _provider();
    final incomeCategory = provider.incomeCategories.first;

    await tester.pumpWidget(JMoneyApp(provider: provider));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tiền vào'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(
        ValueKey(
          'transaction-category-${incomeCategory.id}',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<ExpenseCategoryField>(
            find.byKey(const ValueKey('income-category-select')),
          )
          .selectedCategoryId,
      incomeCategory.id,
    );

    await tester.enterText(
        find.byKey(const ValueKey('income-amount')), '100000');
    expect(
      tester
          .widget<TextFormField>(
            find.byKey(const ValueKey('income-amount')),
          )
          .controller!
          .text,
      '100.000',
    );
    await tester.tap(find.text('Thủ công'));
    await tester.pumpAndSettle();

    for (var jarId = 1; jarId <= 4; jarId++) {
      final field = find.byKey(ValueKey('income-manual-$jarId'));
      await tester.scrollUntilVisible(
        field,
        140,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.enterText(field, '25000');
      expect(tester.widget<TextFormField>(field).controller!.text, '25.000');
    }
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('income-save')),
      180,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.byKey(const ValueKey('income-save')));
    await tester.pumpAndSettle();

    expect(provider.totalBalance, 100000);
    expect(provider.jars.map((jar) => jar.balance), everyElement(25000));
    expect(provider.transactions.last.categoryId, incomeCategory.id);
    expect(tester.takeException(), isNull);
  });

  testWidgets('add button opens the three transaction picker tabs',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final provider = await _provider();
    final category = provider.expenseCategories.firstWhere(
      (item) => item.jarId == provider.jars.first.id,
    );

    await tester.pumpWidget(JMoneyApp(provider: provider));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('Tiền ra'), findsOneWidget);
    expect(find.text('Tiền vào'), findsOneWidget);
    expect(find.text('Chuyển hũ'), findsOneWidget);
    expect(find.text(category.name), findsOneWidget);

    final categoryTile =
        find.byKey(ValueKey('transaction-category-${category.id}'));
    await tester.ensureVisible(categoryTile);
    await tester.tap(categoryTile);
    await tester.pumpAndSettle();

    expect(find.text('Thêm chi tiêu'), findsOneWidget);
    expect(
      tester
          .widget<SelectionField<int?>>(find.byKey(
            const ValueKey('expense-jar-select'),
          ))
          .value,
      category.jarId,
    );
    expect(
      tester
          .widget<FormField<int>>(
            find.byKey(
              ValueKey('expense-category-select-${category.jarId}'),
            ),
          )
          .initialValue,
      category.id,
    );

    Navigator.of(tester.element(find.byType(AddExpenseScreen))).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chuyển hũ'));
    await tester.pumpAndSettle();
    final sourceJar = provider.jars.first;
    await tester.tap(
      find.byKey(ValueKey('transfer-source-jar-${sourceJar.id}')),
    );
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<SelectionField<int?>>(
            find.byType(SelectionField<int?>).first,
          )
          .value,
      sourceJar.id,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows details for the three supported budget methods',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final provider = await _provider();

    await tester.pumpWidget(JMoneyApp(provider: provider));
    await tester.pumpAndSettle();
    tester.state<NavigatorState>(find.byType(Navigator)).push(
          MaterialPageRoute<void>(
            builder: (_) => const BudgetScreen(),
          ),
        );
    await tester.pumpAndSettle();
    final fourJars = find.byKey(const ValueKey('budget-method-fourJars'));
    final sixJars = find.byKey(const ValueKey('budget-method-sixJars'));
    final fiftyTwentyThirty =
        find.byKey(const ValueKey('budget-method-fiftyTwentyThirty'));

    expect(fourJars, findsOneWidget);
    expect(sixJars, findsOneWidget);
    expect(fiftyTwentyThirty, findsOneWidget);
    expect(
      find.byKey(const ValueKey('budget-method-personalFourJars')),
      findsNothing,
    );
    expect(tester.widget<ListTile>(fourJars).selected, isTrue);
    await tester.scrollUntilVisible(
      find.text('Chi tiết các hũ'),
      160,
      scrollable: find.byType(Scrollable).last,
    );
    await Scrollable.ensureVisible(
      tester.element(find.text('Chi tiết các hũ')),
      alignment: 0.3,
      duration: Duration.zero,
    );
    await tester.pumpAndSettle();
    expect(find.byType(ExpansionTile), findsNothing);
    expect(
      find.textContaining('55% · Nhu cầu thiết yếu', skipOffstage: false),
      findsOneWidget,
    );
    expect(
      find.textContaining('Chi cho nhà ở', skipOffstage: false),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.text('Quản lý hũ'),
      180,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Quản lý hũ'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('creates a financial goal from the management flow',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final provider = await _provider();

    await tester.pumpWidget(JMoneyApp(provider: provider));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Quản lý'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Mục tiêu & quỹ dự phòng'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Thêm mục tiêu'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.enterText(find.byType(TextFormField).at(0), 'Du lịch');
    await tester.enterText(find.byType(TextFormField).at(1), '5000000');
    expect(
      tester
          .widget<TextFormField>(find.byType(TextFormField).at(1))
          .controller!
          .text,
      '5.000.000',
    );
    await tester.ensureVisible(find.text('Lưu'));
    await tester.tap(find.text('Lưu'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    expect(provider.goals.single.name, 'Du lịch');
    expect(find.text('Du lịch'), findsOneWidget);
  });

  testWidgets('recurring transaction editor fits a compact screen',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final provider = await _provider();

    await tester.pumpWidget(JMoneyApp(provider: provider));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Quản lý'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Giao dịch định kỳ'),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Giao dịch định kỳ'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Thêm lịch'));
    await tester.pumpAndSettle();

    expect(find.text('Loại giao dịch'), findsNothing);
    expect(find.text('Thu nhập'), findsOneWidget);
    expect(find.text('Chi tiêu'), findsOneWidget);
    expect(find.text('Chuyển hũ'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('groups transaction history by month without deleting old data',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final storage = FinanceStorage(keyValueStore: MemoryKeyValueStore());
    final jar = (await storage.getAllJars()).first;
    final category = (await storage.getCategoriesByJar(jar.id!)).first;
    for (final date in [DateTime(2026, 7, 31), DateTime(2026, 8, 1)]) {
      await storage.insertTransaction(
        FinanceTransaction(
          type: TransactionType.expense,
          amount: 100000,
          jarId: jar.id,
          categoryId: category.id,
          date: date,
        ),
      );
    }
    final provider = FinanceProvider(
      storage: storage,
      clock: () => DateTime(2026, 8, 15),
    );
    await provider.initialize();

    await tester.pumpWidget(
      JMoneyApp(provider: provider),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lịch sử'));
    await tester.pumpAndSettle();
    expect(find.byType(HistoryScreen), findsOneWidget);

    expect(
      find.byKey(const ValueKey('transaction-month-2026-8')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('transaction-month-2026-7')),
      findsOneWidget,
    );
    expect(provider.transactions, hasLength(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('swiping a history item reveals edit and delete actions',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final provider = await _provider();
    final jar = provider.jars.first;
    final category = provider.categoriesForJar(jar.id!).first;
    await provider.addExpense(
      amount: 100000,
      jarId: jar.id!,
      categoryId: category.id!,
      date: DateTime(2026, 8, 2),
    );
    final transaction = provider.transactions.single;

    await tester.pumpWidget(JMoneyApp(provider: provider));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lịch sử'));
    await tester.pumpAndSettle();
    await tester.drag(
      find.byKey(ValueKey(transaction.id)),
      const Offset(-260, 0),
    );
    await tester.pumpAndSettle();

    final editAction = find.byKey(ValueKey('history-edit-${transaction.id}'));
    final deleteAction =
        find.byKey(ValueKey('history-delete-${transaction.id}'));
    expect(editAction, findsOneWidget);
    expect(deleteAction, findsOneWidget);
    expect(find.text('Sửa'), findsNothing);
    expect(find.text('Xóa'), findsNothing);
    expect(
      tester
          .widget<Icon>(
            find.descendant(
              of: editAction,
              matching: find.byIcon(Icons.edit_outlined),
            ),
          )
          .semanticLabel,
      'Sửa',
    );
    expect(
      tester
          .widget<Icon>(
            find.descendant(
              of: deleteAction,
              matching: find.byIcon(Icons.delete_outline_rounded),
            ),
          )
          .semanticLabel,
      'Xóa',
    );
    await tester.tap(editAction);
    await tester.pumpAndSettle();
    expect(find.byType(EditTransactionScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('history swipe actions support 200% text on compact screens',
      (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final provider = await _provider();
    final jar = provider.jars.first;
    final category = provider.categoriesForJar(jar.id!).first;
    await provider.addExpense(
      amount: 999999999,
      jarId: jar.id!,
      categoryId: category.id!,
      date: DateTime(2026, 8, 2),
    );
    final transaction = provider.transactions.single;

    await tester.pumpWidget(JMoneyApp(provider: provider));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lịch sử'));
    await tester.pumpAndSettle();
    final historyItem = find.byKey(ValueKey(transaction.id));
    await tester.drag(
      find.byType(ListView).last,
      const Offset(0, -200),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(historyItem);
    await tester.drag(
      find.byType(ListView).last,
      const Offset(0, -100),
    );
    await tester.pumpAndSettle();
    await tester.drag(
      historyItem,
      const Offset(-250, 0),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(ValueKey('history-edit-${transaction.id}')),
      findsOneWidget,
    );
    expect(
      find.byKey(ValueKey('history-delete-${transaction.id}')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('every history transaction type can be edited and deleted',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final provider = await _provider();
    final sourceJar = provider.jars.first;
    final destinationJar = provider.jars[1];
    final category = provider.categoriesForJar(sourceJar.id!).first;
    final date = DateTime(2026, 8, 3);
    await provider.addIncome(amount: 1000000, date: date);
    await provider.addExpense(
      amount: 100000,
      jarId: sourceJar.id!,
      categoryId: category.id!,
      date: date,
    );
    await provider.transferBetweenJars(
      sourceJarId: sourceJar.id!,
      destinationJarId: destinationJar.id!,
      amount: 50000,
      date: date,
    );
    final transactions = {
      for (final transaction in provider.transactions)
        transaction.type: transaction,
    };

    await tester.pumpWidget(JMoneyApp(provider: provider));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lịch sử'));
    await tester.pumpAndSettle();
    final historyScroll = find
        .descendant(
          of: find.byType(HistoryScreen),
          matching: find.byType(Scrollable),
        )
        .last;

    for (final type in TransactionType.values) {
      final transaction = transactions[type]!;
      final historyItem = find.byKey(ValueKey(transaction.id));
      await tester.scrollUntilVisible(
        historyItem,
        140,
        scrollable: historyScroll,
      );
      await tester.drag(
        historyItem,
        const Offset(-260, 0),
      );
      await tester.pumpAndSettle();

      final editAction = find.byKey(ValueKey('history-edit-${transaction.id}'));
      expect(editAction, findsOneWidget);
      expect(
        find.byKey(ValueKey('history-delete-${transaction.id}')),
        findsOneWidget,
      );
      await tester.tap(editAction);
      await tester.pumpAndSettle();
      expect(find.byType(EditTransactionScreen), findsOneWidget);
      Navigator.of(tester.element(find.byType(EditTransactionScreen))).pop();
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        historyItem,
        140,
        scrollable: historyScroll,
      );
      await tester.drag(historyItem, const Offset(-260, 0));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(ValueKey('history-delete-${transaction.id}')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Xóa giao dịch?'), findsOneWidget);
      await tester.tap(find.text('Hủy'));
      await tester.pumpAndSettle();
    }

    expect(provider.transactions, hasLength(3));
    expect(tester.takeException(), isNull);
  });

  testWidgets('opens jar details and records deposits and expenses',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final provider = await _provider();
    final jar = provider.jars.first;
    final category = provider.categoriesForJar(jar.id!).first;

    await tester.pumpWidget(JMoneyApp(provider: provider));
    await tester.pumpAndSettle();
    await tester.tap(find.text(jar.name));
    await tester.pumpAndSettle();

    expect(find.text('Biến động số dư'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Thêm chi tiêu'),
      180,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Thêm chi tiêu'), findsOneWidget);
    expect(find.text('Nạp tiền vào hũ'), findsOneWidget);

    await tester.tap(find.text('Nạp tiền vào hũ'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('jar-deposit-amount')),
      '200000',
    );
    await tester.tap(find.byKey(const ValueKey('jar-deposit-save')));
    await tester.pumpAndSettle();

    expect(provider.jarById(jar.id)!.balance, 200000);
    expect(provider.activitiesForJar(jar.id!).single.delta, 200000);

    await tester.tap(find.text('Thêm chi tiêu'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('expense-amount')),
      '50000',
    );
    await tester.tap(
      find.byKey(ValueKey('expense-category-select-${jar.id}')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining(category.name).last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('expense-save')));
    await tester.pumpAndSettle();

    final activities = provider.activitiesForJar(jar.id!);
    expect(provider.jarById(jar.id)!.balance, 150000);
    expect(activities.map((item) => item.delta), [-50000, 200000]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('jar details support 200% system text on compact screens',
      (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final provider = await _provider();
    final jar = provider.jars.first;
    await provider.addIncome(
      amount: 999999999,
      date: DateTime(2026, 8, 1),
      allocations: {jar.id!: 999999999},
    );

    await tester.pumpWidget(JMoneyApp(provider: provider));
    await tester.pumpAndSettle();
    tester.state<NavigatorState>(find.byType(Navigator)).push(
          MaterialPageRoute<void>(
            builder: (_) => JarDetailScreen(jarId: jar.id!),
          ),
        );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.scrollUntilVisible(
      find.text('Thêm chi tiêu'),
      180,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Thêm chi tiêu'), findsOneWidget);
    expect(find.text('Nạp tiền vào hũ'), findsOneWidget);
    expect(
      MediaQuery.textScalerOf(
        tester.element(find.text('Thêm chi tiêu')),
      ).scale(16),
      32,
    );
    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(
      find.text('Biến động số dư'),
      180,
      scrollable: find.byType(Scrollable).last,
    );
    expect(tester.takeException(), isNull);
    final scrollable = tester.state<ScrollableState>(
      find.byType(Scrollable).last,
    );
    scrollable.position.jumpTo(scrollable.position.maxScrollExtent);
    await tester.pumpAndSettle();
    expect(find.text('Tiền vào hũ'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('jar details preserve hidden balances and name transfer jars',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final provider = await _provider();
    final source = provider.jars.first;
    final destination = provider.jars[1];
    await provider.addIncome(
      amount: 1000000,
      date: DateTime(2026, 8, 1),
      allocations: {source.id!: 1000000},
    );
    await provider.transferBetweenJars(
      sourceJarId: source.id!,
      destinationJarId: destination.id!,
      amount: 100000,
      date: DateTime(2026, 8, 2),
    );
    await provider.saveJar(
      provider.jarById(source.id)!.copyWith(isBalanceHidden: true),
    );

    await tester.pumpWidget(JMoneyApp(provider: provider));
    await tester.pumpAndSettle();
    tester.state<NavigatorState>(find.byType(Navigator)).push(
          MaterialPageRoute<void>(
            builder: (_) => JarDetailScreen(jarId: source.id!),
          ),
        );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Chuyển đến hũ ${destination.name}'),
      180,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.textContaining('Số dư sau giao dịch:'), findsNothing);
    expect(find.textContaining('900.000'), findsNothing);
    await tester.scrollUntilVisible(
      find.text('Nạp tiền vào hũ'),
      -180,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('Nạp tiền vào hũ'));
    await tester.pumpAndSettle();

    expect(find.textContaining('••••••'), findsOneWidget);
    expect(find.textContaining('900.000'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('expense category selection remaps when the jar changes',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final provider = await _provider();
    final firstJar = provider.jars.first;
    final secondJar = provider.jars[1];
    final firstCategory = provider
        .categoriesForJar(firstJar.id!)
        .firstWhere((category) => category.jarId == firstJar.id);

    await tester.pumpWidget(JMoneyApp(provider: provider));
    await tester.pumpAndSettle();
    tester.state<NavigatorState>(find.byType(Navigator)).push(
          MaterialPageRoute<void>(builder: (_) => const AddExpenseScreen()),
        );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('expense-jar-select')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(firstJar.name).last);
    await tester.pumpAndSettle();
    final firstSelect =
        find.byKey(ValueKey('expense-category-select-${firstJar.id}'));
    await tester.tap(firstSelect);
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining(firstCategory.name).last);
    await tester.pumpAndSettle();
    expect(
      tester.widget<FormField<int>>(firstSelect).initialValue,
      firstCategory.id,
    );

    await tester.tap(find.byKey(const ValueKey('expense-jar-select')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(secondJar.name).last);
    await tester.pumpAndSettle();
    final secondSelect =
        find.byKey(ValueKey('expense-category-select-${secondJar.id}'));
    expect(secondSelect, findsOneWidget);
    expect(
      tester.widget<FormField<int>>(secondSelect).initialValue,
      isNull,
    );
    expect(
      find.byKey(ValueKey('expense-category-${firstCategory.id}')),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('history edit preselects and saves the mapped category',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final provider = await _provider();
    final firstJar = provider.jars.first;
    final secondJar = provider.jars[1];
    final firstCategory = provider.categoriesForJar(firstJar.id!).first;
    final secondCategory = provider.categoriesForJar(secondJar.id!).first;
    await provider.addExpense(
      amount: 50000,
      jarId: firstJar.id!,
      categoryId: firstCategory.id!,
      date: DateTime(2026, 8, 2),
    );
    final expense = provider.transactions.single;

    await tester.pumpWidget(JMoneyApp(provider: provider));
    await tester.pumpAndSettle();
    tester.state<NavigatorState>(find.byType(Navigator)).push(
          MaterialPageRoute<void>(
            builder: (_) => EditTransactionScreen(transaction: expense),
          ),
        );
    await tester.pumpAndSettle();

    final initialSelect =
        find.byKey(ValueKey('expense-category-select-${firstJar.id}'));
    expect(
      tester.widget<FormField<int>>(initialSelect).initialValue,
      firstCategory.id,
    );
    await tester.tap(
      find.byKey(const ValueKey('edit-expense-jar-select')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(secondJar.name).last);
    await tester.pumpAndSettle();
    final remappedSelect =
        find.byKey(ValueKey('expense-category-select-${secondJar.id}'));
    expect(
      tester.widget<FormField<int>>(remappedSelect).initialValue,
      isNull,
    );
    await tester.tap(remappedSelect);
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining(secondCategory.name).last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('edit-transaction-save')));
    await tester.pumpAndSettle();

    final updated = provider.transactions.single;
    expect(updated.jarId, secondJar.id);
    expect(updated.categoryId, secondCategory.id);
    expect(tester.takeException(), isNull);
  });

  testWidgets('history edit clears a category no longer mapped to its jar',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final provider = await _provider();
    final originalJar = provider.jars.first;
    final newJar = provider.jars[1];
    final category = provider.categoriesForJar(originalJar.id!).first;
    await provider.addExpense(
      amount: 50000,
      jarId: originalJar.id!,
      categoryId: category.id!,
      date: DateTime(2026, 8, 2),
    );
    await provider.saveCategory(category.copyWith(jarId: newJar.id));
    final historicalExpense = provider.transactions.single;

    await tester.pumpWidget(JMoneyApp(provider: provider));
    await tester.pumpAndSettle();
    tester.state<NavigatorState>(find.byType(Navigator)).push(
          MaterialPageRoute<void>(
            builder: (_) => EditTransactionScreen(
              transaction: historicalExpense,
            ),
          ),
        );
    await tester.pumpAndSettle();

    final categorySelect =
        find.byKey(ValueKey('expense-category-select-${originalJar.id}'));
    expect(
      tester.widget<FormField<int>>(categorySelect).initialValue,
      isNull,
    );
    expect(
      find.byKey(ValueKey('expense-category-${category.id}')),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });
}
