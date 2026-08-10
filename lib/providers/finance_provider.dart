import 'dart:collection';

import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../models/budget_plan.dart';
import '../models/category.dart';
import '../models/finance_transaction.dart';
import '../models/financial_goal.dart';
import '../models/jar.dart';
import '../models/jar_activity.dart';
import '../models/recurring_rule.dart';
import '../models/spending_summary.dart';
import '../services/reminder_service.dart';
import '../storage/finance_storage.dart';

class FinanceProvider extends ChangeNotifier {
  FinanceProvider({
    required FinanceStorage storage,
    ReminderService? reminderService,
    DateTime Function()? clock,
  })  : _storage = storage,
        _reminderService = reminderService ?? NoopReminderService(),
        _clock = clock ?? DateTime.now {
    final period = _monthOf(_clock());
    _selectedPeriod = period;
    _systemPeriod = period;
  }

  final FinanceStorage _storage;
  final ReminderService _reminderService;
  final DateTime Function() _clock;
  final List<Jar> _jars = [];
  final List<Category> _categories = [];
  final List<FinanceTransaction> _transactions = [];
  final List<SpendingSummary> _spendingByCategory = [];
  final List<BudgetPlan> _budgetPlans = [];
  final List<BudgetLimit> _budgetLimits = [];
  final List<FinancialGoal> _goals = [];
  final List<RecurringRule> _recurringRules = [];
  final List<RecurringOccurrence> _pendingOccurrences = [];

  bool _isLoading = false;
  bool _isSaving = false;
  bool _isChangingPeriod = false;
  Object? _error;
  late DateTime _selectedPeriod;
  late DateTime _systemPeriod;

  UnmodifiableListView<Jar> get jars => UnmodifiableListView(_jars);
  UnmodifiableListView<Category> get categories =>
      UnmodifiableListView(_categories);
  List<Category> get expenseCategories => _sortedCategories(
        _categories.where((category) => category.type == CategoryType.expense),
      );
  List<Category> get incomeCategories => _sortedCategories(
        _categories.where((category) => category.type == CategoryType.income),
      );
  UnmodifiableListView<FinanceTransaction> get transactions =>
      UnmodifiableListView(_transactions);
  List<FinanceTransaction> get periodTransactions => List.unmodifiable(
        _transactions.where(_isInSelectedPeriod),
      );
  UnmodifiableListView<SpendingSummary> get spendingByCategory =>
      UnmodifiableListView(_spendingByCategory);
  UnmodifiableListView<BudgetPlan> get budgetPlans =>
      UnmodifiableListView(_budgetPlans);
  UnmodifiableListView<BudgetLimit> get budgetLimits =>
      UnmodifiableListView(_budgetLimits);
  UnmodifiableListView<FinancialGoal> get goals => UnmodifiableListView(_goals);
  UnmodifiableListView<RecurringRule> get recurringRules =>
      UnmodifiableListView(_recurringRules);
  UnmodifiableListView<RecurringOccurrence> get pendingOccurrences =>
      UnmodifiableListView(_pendingOccurrences);

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get isChangingPeriod => _isChangingPeriod;
  Object? get error => _error;
  int get totalBalance => _jars.fold(0, (sum, jar) => sum + jar.balance);
  double get totalPercentage =>
      _jars.fold(0, (sum, jar) => sum + jar.percentage);
  BudgetPlan? get activeBudgetPlan {
    for (final plan in _budgetPlans.reversed) {
      if (plan.isActive) return plan;
    }
    return null;
  }

  int get currentMonthIncome => _sumCurrentMonth(TransactionType.income);
  int get currentMonthExpense => _sumCurrentMonth(TransactionType.expense);
  DateTime get currentPeriod => _selectedPeriod;
  DateTime get actualCurrentPeriod => _systemPeriod;
  bool get isCurrentPeriod => _sameMonth(_selectedPeriod, _systemPeriod);
  DateTime get suggestedTransactionDate {
    final now = _clock();
    if (isCurrentPeriod) return now;
    final lastDay = DateTime(
      _selectedPeriod.year,
      _selectedPeriod.month + 1,
      0,
    ).day;
    return DateTime(
      _selectedPeriod.year,
      _selectedPeriod.month,
      now.day.clamp(1, lastDay),
    );
  }

  int _sumCurrentMonth(TransactionType type) {
    return _transactions
        .where(
          (item) =>
              item.type == type &&
              item.date.year == _selectedPeriod.year &&
              item.date.month == _selectedPeriod.month,
        )
        .fold(0, (sum, item) => sum + item.amount);
  }

  Future<void> initialize() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _storage.processDueRecurringRules(_clock());
      await _reload();
      for (final rule in _recurringRules) {
        try {
          await _reminderService.schedule(rule);
        } catch (_) {
          // Reminder delivery must never block access to financial data.
        }
      }
    } catch (error) {
      _error = error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    final wasViewingCurrent = isCurrentPeriod;
    _systemPeriod = _monthOf(_clock());
    if (wasViewingCurrent) _selectedPeriod = _systemPeriod;
    try {
      _error = null;
      await _reload();
    } catch (error) {
      _error = error;
    }
    notifyListeners();
  }

  Future<void> _reload() async {
    final period = _selectedPeriod;
    final results = await Future.wait([
      _storage.getJarsForMonth(year: period.year, month: period.month),
      _storage.getAllCategories(),
      _storage.getAllTransactions(),
      _storage.getExpenseByCategory(year: period.year, month: period.month),
      _storage.getBudgetPlans(),
      _storage.getBudgetLimits(
        year: period.year,
        month: period.month,
      ),
      _storage.getGoals(),
      _storage.getRecurringRules(),
      _storage.getPendingOccurrences(),
    ]);
    _jars
      ..clear()
      ..addAll(results[0] as List<Jar>);
    _categories
      ..clear()
      ..addAll(results[1] as List<Category>);
    _transactions
      ..clear()
      ..addAll(results[2] as List<FinanceTransaction>);
    _spendingByCategory
      ..clear()
      ..addAll(results[3] as List<SpendingSummary>);
    _budgetPlans
      ..clear()
      ..addAll(results[4] as List<BudgetPlan>);
    _budgetLimits
      ..clear()
      ..addAll(results[5] as List<BudgetLimit>);
    _goals
      ..clear()
      ..addAll(results[6] as List<FinancialGoal>);
    _recurringRules
      ..clear()
      ..addAll(results[7] as List<RecurringRule>);
    _pendingOccurrences
      ..clear()
      ..addAll(results[8] as List<RecurringOccurrence>);
  }

  Future<void> selectPreviousMonth() =>
      selectPeriod(DateTime(_selectedPeriod.year, _selectedPeriod.month - 1));

  Future<void> selectNextMonth() =>
      selectPeriod(DateTime(_selectedPeriod.year, _selectedPeriod.month + 1));

  Future<void> selectCurrentMonth() => selectPeriod(_systemPeriod);

  Future<void> selectPeriod(DateTime value) async {
    final target = _monthOf(value);
    if (_sameMonth(target, _selectedPeriod) || _isChangingPeriod) return;
    final previous = _selectedPeriod;
    _selectedPeriod = target;
    _isChangingPeriod = true;
    _error = null;
    notifyListeners();
    try {
      await _reload();
    } catch (error) {
      _selectedPeriod = previous;
      _error = error;
      await _reload();
    } finally {
      _isChangingPeriod = false;
      notifyListeners();
    }
  }

  List<Category> categoriesForJar(int jarId) {
    return _sortedCategories(
      _categories.where(
        (category) =>
            category.type == CategoryType.expense &&
            (category.jarId == null || category.jarId == jarId),
      ),
    );
  }

  static List<Category> _sortedCategories(Iterable<Category> categories) {
    const priorityById = <int, int>{
      2: 10, // Food
      28: 20, // Snacks
      29: 30, // Children
      4: 40, // Groceries
      5: 50, // Rent
      6: 60, // Utilities
      7: 70, // Internet
      8: 80, // Phone
      9: 90, // Fuel
      10: 100, // Transport
      11: 110, // Healthcare
    };
    return [
      ...categories,
    ]..sort((a, b) {
        final priorityA = priorityById[a.id] ?? 1000 + (a.id ?? 0);
        final priorityB = priorityById[b.id] ?? 1000 + (b.id ?? 0);
        return priorityA.compareTo(priorityB);
      });
  }

  Jar? jarById(int? id) {
    if (id == null) return null;
    for (final jar in _jars) {
      if (jar.id == id) return jar;
    }
    return null;
  }

  Category? categoryById(int? id) {
    if (id == null) return null;
    for (final category in _categories) {
      if (category.id == id) return category;
    }
    return null;
  }

  List<JarActivity> activitiesForJar(int jarId) {
    final jar = jarById(jarId);
    if (jar == null) return const [];
    var runningBalance = jar.balance;
    final activities = <JarActivity>[];

    for (final transaction in _transactions.where(_isInSelectedPeriod)) {
      final (type, delta) = switch (transaction.type) {
        TransactionType.income => (
            JarActivityType.income,
            transaction.incomeAllocations[jarId] ?? 0,
          ),
        TransactionType.expense when transaction.jarId == jarId => (
            JarActivityType.expense,
            -transaction.amount,
          ),
        TransactionType.transfer when transaction.destinationJarId == jarId => (
            JarActivityType.transferIn,
            transaction.amount,
          ),
        TransactionType.transfer when transaction.jarId == jarId => (
            JarActivityType.transferOut,
            -transaction.amount,
          ),
        _ => (JarActivityType.income, 0),
      };
      if (delta == 0) continue;
      activities.add(
        JarActivity(
          transaction: transaction,
          type: type,
          delta: delta,
          balanceAfter: runningBalance,
        ),
      );
      runningBalance -= delta;
    }

    return List.unmodifiable(activities);
  }

  Future<bool> addIncome({
    required int amount,
    required DateTime date,
    int? categoryId,
    String? note,
    String? accountName,
    Map<int, int> allocations = const {},
  }) {
    return _perform(
      () => _storage.insertTransaction(
        FinanceTransaction(
          type: TransactionType.income,
          amount: amount,
          categoryId: categoryId,
          note: _clean(note),
          date: date,
          accountName: _clean(accountName),
          incomeAllocations: allocations,
        ),
      ),
    );
  }

  Future<bool> addExpense({
    required int amount,
    required int jarId,
    required int categoryId,
    required DateTime date,
    String? note,
    String? accountName,
  }) {
    return _perform(
      () => _storage.insertTransaction(
        FinanceTransaction(
          type: TransactionType.expense,
          amount: amount,
          jarId: jarId,
          categoryId: categoryId,
          note: _clean(note),
          date: date,
          accountName: _clean(accountName),
        ),
      ),
    );
  }

  Future<bool> deleteTransaction(FinanceTransaction item) {
    return _perform(() => _storage.deleteTransaction(item));
  }

  Future<bool> updateTransaction(FinanceTransaction item) {
    return _perform(() => _storage.updateTransaction(item));
  }

  Future<bool> transferBetweenJars({
    required int sourceJarId,
    required int destinationJarId,
    required int amount,
    required DateTime date,
    String? note,
  }) {
    return _perform(
      () => _storage.insertTransaction(
        FinanceTransaction(
          type: TransactionType.transfer,
          amount: amount,
          jarId: sourceJarId,
          destinationJarId: destinationJarId,
          note: _clean(note),
          date: date,
        ),
      ),
    );
  }

  Future<bool> saveJar(Jar jar) {
    return _perform(() async {
      final description = jar.description?.trim();
      final normalized = jar.copyWith(
        name: jar.name.trim(),
        description: description,
        clearDescription: description == null || description.isEmpty,
        orderIndex: jar.id == null ? _jars.length : jar.orderIndex,
      );
      if (jar.id == null) {
        await _storage.insertJar(
          normalized,
          year: _selectedPeriod.year,
          month: _selectedPeriod.month,
        );
      } else {
        await _storage.updateJar(
          normalized,
          year: _selectedPeriod.year,
          month: _selectedPeriod.month,
        );
      }
    });
  }

  Future<bool> deleteJar(Jar jar) async {
    if (_jars.length <= 1 || jar.id == null) {
      _error = StateError('At least one jar is required');
      notifyListeners();
      return false;
    }
    return _perform(() => _storage.deleteJar(jar.id!));
  }

  Future<bool> reorderJars(int oldIndex, int newIndex) {
    final ordered = [..._jars];
    final moved = ordered.removeAt(oldIndex);
    ordered.insert(newIndex, moved);
    return _perform(
      () => _storage.reorderJars([
        for (final jar in ordered) jar.id!,
      ]),
    );
  }

  Future<bool> jarHasFinancialHistory(Jar jar) async {
    final id = jar.id;
    if (id == null) return true;
    return _storage.jarHasFinancialHistory(id);
  }

  Future<bool> saveCategory(Category category) {
    return _perform(() async {
      final normalized = category.copyWith(name: category.name.trim());
      if (category.id == null) {
        await _storage.insertCategory(normalized);
      } else {
        await _storage.updateCategory(normalized);
      }
    });
  }

  Future<bool> deleteCategory(Category category) async {
    if (category.id == null) return false;
    return _perform(() => _storage.deleteCategory(category.id!));
  }

  BudgetLimit? budgetForJar(int jarId) {
    for (final limit in _budgetLimits) {
      if (limit.jarId == jarId && limit.categoryId == null) return limit;
    }
    return null;
  }

  BudgetLimit? budgetForCategory(int categoryId) {
    for (final limit in _budgetLimits) {
      if (limit.categoryId == categoryId) return limit;
    }
    return null;
  }

  int currentMonthExpenseForJar(int jarId) {
    return _transactions
        .where(
          (item) =>
              item.type == TransactionType.expense &&
              item.jarId == jarId &&
              item.date.year == _selectedPeriod.year &&
              item.date.month == _selectedPeriod.month,
        )
        .fold<int>(0, (sum, item) => sum + item.amount);
  }

  BudgetProgress budgetProgressForJar(int jarId) {
    final limit = budgetForJar(jarId);
    if (limit == null) {
      return const BudgetProgress(
        planned: 0,
        spent: 0,
        remaining: 0,
        dailyAllowance: 0,
      );
    }
    return budgetProgressForLimit(limit);
  }

  BudgetProgress budgetProgressForLimit(BudgetLimit limit) {
    final now = _clock();
    final spent = _transactions
        .where(
          (item) =>
              item.type == TransactionType.expense &&
              item.date.year == limit.year &&
              item.date.month == limit.month &&
              (limit.jarId == null || item.jarId == limit.jarId) &&
              (limit.categoryId == null || item.categoryId == limit.categoryId),
        )
        .fold<int>(0, (sum, item) => sum + item.amount);
    final available = limit.availableAmount;
    final daysInMonth = DateTime(limit.year, limit.month + 1, 0).day;
    final isActiveMonth = limit.year == now.year && limit.month == now.month;
    final remainingDays = isActiveMonth
        ? (daysInMonth - now.day + 1).clamp(1, daysInMonth)
        : daysInMonth;
    final remaining = available - spent;
    return BudgetProgress(
      planned: available,
      spent: spent,
      remaining: remaining,
      dailyAllowance: available <= 0 ? 0 : (remaining / remainingDays).floor(),
    );
  }

  Future<bool> applyBudgetTemplate(BudgetMethod method) {
    return _perform(
      () => _storage.applyBudgetTemplate(
        method,
        year: _selectedPeriod.year,
        month: _selectedPeriod.month,
      ),
    );
  }

  Future<bool> saveBudgetLimit(BudgetLimit limit) {
    return _perform(() => _storage.saveBudgetLimit(limit));
  }

  Future<bool> deleteBudgetLimit(BudgetLimit limit) {
    final id = limit.id;
    if (id == null) return Future.value(false);
    return _perform(() => _storage.deleteBudgetLimit(id));
  }

  Future<bool> copyPreviousMonthBudgets({
    bool includeRollover = true,
  }) {
    final previous =
        DateTime(_selectedPeriod.year, _selectedPeriod.month - 1, 1);
    return _perform(
      () => _storage.copyBudgetLimitsToMonth(
        fromYear: previous.year,
        fromMonth: previous.month,
        toYear: _selectedPeriod.year,
        toMonth: _selectedPeriod.month,
        includeRollover: includeRollover,
      ),
    );
  }

  Future<String> exportSnapshot() => _storage.exportSnapshot();

  Future<String?> getLatestBackup() => _storage.getLatestBackup();

  Future<bool> importSnapshot(String encoded) {
    return _perform(() => _storage.importSnapshot(encoded));
  }

  Future<bool> resetAllData() {
    final recurringRules = [..._recurringRules];
    return _perform(() async {
      try {
        await _reminderService.cancelAll();
        await _storage.resetAllData();
      } catch (_) {
        for (final rule in recurringRules) {
          try {
            await _reminderService.schedule(rule);
          } catch (_) {
            // Keep restoring the remaining reminders before reporting failure.
          }
        }
        rethrow;
      }
    });
  }

  Future<bool> saveGoal(FinancialGoal goal) {
    return _perform(() => _storage.saveGoal(goal));
  }

  Future<bool> deleteGoal(FinancialGoal goal) {
    final id = goal.id;
    if (id == null) return Future.value(false);
    return _perform(() => _storage.deleteGoal(id));
  }

  Future<bool> addGoalContribution({
    required int goalId,
    required int amount,
    required DateTime date,
    String? note,
  }) {
    return _perform(
      () => _storage.addGoalContribution(
        GoalContribution(
          goalId: goalId,
          amount: amount,
          date: date,
          note: _clean(note),
        ),
      ),
    );
  }

  Future<int> suggestEmergencyFundTarget({int months = 6}) {
    return _storage.suggestEmergencyFundTarget(months: months);
  }

  RecurringRule? recurringRuleById(int id) {
    for (final rule in _recurringRules) {
      if (rule.id == id) return rule;
    }
    return null;
  }

  Future<bool> saveRecurringRule(RecurringRule rule) {
    return _perform(() async {
      final id = await _storage.saveRecurringRule(rule);
      try {
        await _reminderService.requestPermissions();
        await _reminderService.schedule(rule.copyWith(id: id));
      } catch (_) {
        // The in-app due list remains available when OS permission is denied.
      }
    });
  }

  Future<bool> deleteRecurringRule(RecurringRule rule) {
    final id = rule.id;
    if (id == null) return Future.value(false);
    return _perform(() async {
      await _storage.deleteRecurringRule(id);
      try {
        await _reminderService.cancel(id);
      } catch (_) {
        // Storage deletion is authoritative even if OS cancellation fails.
      }
    });
  }

  Future<bool> completeOccurrence(RecurringOccurrence occurrence) {
    return _perform(() => _storage.completeOccurrence(occurrence.key));
  }

  Future<bool> skipOccurrence(RecurringOccurrence occurrence) {
    return _perform(() => _storage.skipOccurrence(occurrence.key));
  }

  Future<bool> _perform(Future<void> Function() action) async {
    _isSaving = true;
    _error = null;
    notifyListeners();
    try {
      await action();
      await _reload();
      return true;
    } catch (error) {
      _error = error;
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  static String? _clean(String? value) {
    final cleaned = value?.trim();
    return cleaned == null || cleaned.isEmpty ? null : cleaned;
  }

  bool _isInSelectedPeriod(FinanceTransaction item) =>
      item.date.year == _selectedPeriod.year &&
      item.date.month == _selectedPeriod.month;

  static DateTime _monthOf(DateTime value) => DateTime(value.year, value.month);

  static bool _sameMonth(DateTime first, DateTime second) =>
      first.year == second.year && first.month == second.month;
}

class BudgetProgress {
  const BudgetProgress({
    required this.planned,
    required this.spent,
    required this.remaining,
    required this.dailyAllowance,
  });

  final int planned;
  final int spent;
  final int remaining;
  final int dailyAllowance;

  double get ratio => planned <= 0 ? 0 : spent / planned;
  bool get isOverBudget => planned > 0 && spent > planned;
}
