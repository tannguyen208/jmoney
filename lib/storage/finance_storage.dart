import 'dart:convert';

import '../l10n/app_localizations.dart';
import '../l10n/app_localizations_vi.dart';
import '../models/budget_plan.dart';
import '../models/category.dart';
import '../models/finance_transaction.dart';
import '../models/financial_goal.dart';
import '../models/jar.dart';
import '../models/recurring_rule.dart';
import '../models/spending_summary.dart';
import '../utils/income_distribution.dart';
import 'key_value_store.dart';

class FinanceStorage {
  FinanceStorage({
    required KeyValueStore keyValueStore,
    AppLocalizations? localizations,
  })  : _keyValueStore = keyValueStore,
        _localizations = localizations ?? AppLocalizationsVi();

  static const _snapshotKey = 'finance.snapshot';
  static const _backupKey = 'finance.backup.latest';
  final KeyValueStore _keyValueStore;
  final AppLocalizations _localizations;
  _FinanceState? _state;

  _FinanceState get _loadedState => _state ??= _load();

  _FinanceState _load() {
    final encoded = _keyValueStore.readString(_snapshotKey);
    if (encoded == null || encoded.isEmpty) {
      final seeded = _FinanceState.seeded(_localizations);
      _persist(seeded);
      return seeded;
    }
    final decoded = _decodeSnapshot(encoded);
    final version = (decoded['schema_version'] as num?)?.toInt() ?? 1;
    if (version == _FinanceState.schemaVersion) {
      return _FinanceState.fromJson(decoded);
    }
    if (version == 3) {
      _writeBackup(encoded);
      final migrated = _FinanceState.fromV3(decoded, _localizations);
      _persist(migrated);
      return migrated;
    }
    if (version == 2) {
      _writeBackup(encoded);
      final migrated = _FinanceState.fromV2(decoded, _localizations);
      _persist(migrated);
      return migrated;
    }
    if (version == 1) {
      _writeBackup(encoded);
      final migrated = _FinanceState.fromV1(decoded, _localizations);
      _persist(migrated);
      return migrated;
    }
    throw FormatException('Unsupported finance snapshot version: $version');
  }

  static Map<String, Object?> _decodeSnapshot(String encoded) {
    final decoded = jsonDecode(encoded);
    if (decoded is! Map) {
      throw const FormatException('Invalid finance snapshot');
    }
    return Map<String, Object?>.from(decoded);
  }

  void _writeBackup(String encoded) {
    if (!_keyValueStore.writeString(_backupKey, encoded)) {
      throw StateError('MMKV failed to persist the finance backup');
    }
  }

  void _persist(_FinanceState state) {
    final encoded = jsonEncode(state.toJson());
    if (!_keyValueStore.writeString(_snapshotKey, encoded)) {
      throw StateError('MMKV failed to persist the finance snapshot');
    }
  }

  T _commit<T>(T Function(_FinanceState draft) mutation) {
    final draft = _loadedState.copy();
    final result = mutation(draft);
    _persist(draft);
    _state = draft;
    return result;
  }

  Future<String> exportSnapshot() async => jsonEncode(_loadedState.toJson());

  Future<String?> getLatestBackup() async =>
      _keyValueStore.readString(_backupKey);

  Future<void> importSnapshot(String encoded) async {
    final decoded = _decodeSnapshot(encoded);
    final version = (decoded['schema_version'] as num?)?.toInt() ?? 1;
    final imported = switch (version) {
      _FinanceState.schemaVersion => _FinanceState.fromJson(decoded),
      3 => _FinanceState.fromV3(decoded, _localizations),
      2 => _FinanceState.fromV2(decoded, _localizations),
      1 => _FinanceState.fromV1(decoded, _localizations),
      _ => throw FormatException(
          'Unsupported finance snapshot version: $version',
        ),
    };
    final current = jsonEncode(_loadedState.toJson());
    _writeBackup(current);
    _persist(imported);
    _state = imported;
  }

  Future<void> resetAllData() async {
    final previous = _loadedState;
    final previousSnapshot = jsonEncode(previous.toJson());
    final reset = _FinanceState.seeded(_localizations);
    _persist(reset);
    if (!_keyValueStore.remove(_backupKey)) {
      if (_keyValueStore.writeString(_snapshotKey, previousSnapshot)) {
        _state = previous;
      } else {
        _state = reset;
      }
      throw StateError('MMKV failed to remove the finance backup');
    }
    _state = reset;
  }

  Future<List<Jar>> getAllJars() async {
    final result = [..._loadedState.jars]..sort((a, b) {
        final order = a.orderIndex.compareTo(b.orderIndex);
        return order != 0 ? order : (a.id ?? 0).compareTo(b.id ?? 0);
      });
    return List.unmodifiable(result);
  }

  Future<List<Jar>> getJarsForMonth({
    required int year,
    required int month,
  }) async {
    final state = _loadedState;
    final period = state.jarPeriods
        .where(
          (item) => item.year == year && item.month == month,
        )
        .firstOrNull;
    final percentages = period?.percentages ??
        _percentagesForNewPeriod(state, year: year, month: month);
    final balances = _monthlyJarBalances(state, year, month);
    final result = [
      for (final jar in state.jars)
        jar.copyWith(
          percentage: percentages[jar.id] ?? 0,
          balance: balances[jar.id] ?? 0,
        ),
    ]..sort((a, b) {
        final order = a.orderIndex.compareTo(b.orderIndex);
        return order != 0 ? order : (a.id ?? 0).compareTo(b.id ?? 0);
      });
    return List.unmodifiable(result);
  }

  Future<int> insertJar(Jar jar, {int? year, int? month}) async {
    return _commit((draft) {
      final target = _resolvePeriod(year, month);
      final period = _ensureJarPeriod(draft, target.year, target.month);
      final id = draft.nextJarId++;
      draft.jars.add(
        Jar(
          id: id,
          name: jar.name,
          description: jar.description,
          templateKey: jar.templateKey,
          percentage: jar.percentage,
          balance: jar.balance,
          color: jar.color,
          orderIndex: jar.orderIndex,
          isBalanceHidden: jar.isBalanceHidden,
        ),
      );
      period.percentages[id] = jar.percentage;
      return id;
    });
  }

  Future<void> updateJar(Jar jar, {int? year, int? month}) async {
    final id = jar.id;
    if (id == null) throw ArgumentError('Jar id is required');
    _commit((draft) {
      final target = _resolvePeriod(year, month);
      final period = _ensureJarPeriod(draft, target.year, target.month);
      _replaceJar(draft, jar);
      period.percentages[id] = jar.percentage;
    });
  }

  Future<void> reorderJars(List<int> orderedIds) async {
    _commit((draft) {
      final existingIds = draft.jars.map((jar) => jar.id).toSet();
      if (orderedIds.length != draft.jars.length ||
          orderedIds.toSet().length != orderedIds.length ||
          !existingIds.containsAll(orderedIds)) {
        throw ArgumentError('Jar order must contain every jar exactly once');
      }
      for (var index = 0; index < orderedIds.length; index++) {
        final jar = _jarById(draft, orderedIds[index]);
        _replaceJar(draft, jar.copyWith(orderIndex: index));
      }
    });
  }

  Future<void> deleteJar(int id) async {
    _commit((draft) {
      if (draft.jars.length <= 1) {
        throw StateError('At least one jar is required');
      }
      if (_jarHasFinancialHistory(draft, id)) {
        throw StateError('A jar with financial history cannot be deleted');
      }
      final previousLength = draft.jars.length;
      draft.jars.removeWhere((jar) => jar.id == id);
      if (draft.jars.length == previousLength) {
        throw StateError('The selected jar does not exist');
      }
      draft.categories = [
        for (final category in draft.categories)
          if (category.jarId == id)
            category.copyWith(clearJar: true)
          else
            category,
      ];
      draft.budgetLimits.removeWhere((item) => item.jarId == id);
      draft.goals = [
        for (final goal in draft.goals)
          if (goal.jarId == id) goal.copyWith(clearJar: true) else goal,
      ];
      for (final period in draft.jarPeriods) {
        period.percentages.remove(id);
      }
    });
  }

  Future<bool> jarHasFinancialHistory(int id) async =>
      _jarHasFinancialHistory(_loadedState, id);

  static bool _jarHasFinancialHistory(_FinanceState state, int id) {
    return state.transactions.any(
      (item) =>
          item.jarId == id ||
          item.destinationJarId == id ||
          item.incomeAllocations.containsKey(id),
    );
  }

  Future<List<Category>> getAllCategories() async {
    final result = [..._loadedState.categories]..sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
    return List.unmodifiable(result);
  }

  Future<List<Category>> getCategoriesByJar(int jarId) async {
    final result = _loadedState.categories
        .where(
          (category) =>
              category.type == CategoryType.expense &&
              (category.jarId == null || category.jarId == jarId),
        )
        .toList()
      ..sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
    return List.unmodifiable(result);
  }

  Future<int> insertCategory(Category category) async {
    return _commit((draft) {
      _validateCategoryJar(draft, category.jarId);
      final id = draft.nextCategoryId++;
      draft.categories.add(
        Category(
          id: id,
          name: category.name,
          icon: category.icon,
          jarId: category.jarId,
          color: category.color,
          type: category.type,
        ),
      );
      return id;
    });
  }

  Future<void> updateCategory(Category category) async {
    final id = category.id;
    if (id == null) throw ArgumentError('Category id is required');
    _commit((draft) {
      _validateCategoryJar(draft, category.jarId);
      final index = draft.categories.indexWhere((item) => item.id == id);
      if (index < 0) throw StateError('The category does not exist');
      draft.categories[index] = category;
    });
  }

  static void _validateCategoryJar(_FinanceState state, int? jarId) {
    if (jarId != null && !state.jars.any((jar) => jar.id == jarId)) {
      throw StateError('The selected jar does not exist');
    }
  }

  Future<void> deleteCategory(int id) async {
    _commit((draft) {
      final previousLength = draft.categories.length;
      draft.categories.removeWhere((category) => category.id == id);
      if (draft.categories.length == previousLength) {
        throw StateError('The category does not exist');
      }
      draft.transactions = [
        for (final item in draft.transactions)
          if (item.categoryId == id)
            item.copyWith(clearCategory: true)
          else
            item,
      ];
      draft.budgetLimits.removeWhere((item) => item.categoryId == id);
    });
  }

  Future<int> insertTransaction(FinanceTransaction transaction) async {
    return _commit((draft) {
      final id = draft.nextTransactionId++;
      final now = DateTime.now();
      final stored = transaction.copyWith(
        id: id,
        createdAt: transaction.createdAt ?? now,
        updatedAt: transaction.updatedAt ?? now,
      );
      _applyTransaction(draft, stored);
      draft.transactions.add(stored.type == TransactionType.income
          ? stored.copyWith(
              incomeAllocations: _incomeAllocationsFor(draft, stored),
            )
          : stored);
      return id;
    });
  }

  Future<void> updateTransaction(FinanceTransaction transaction) async {
    final id = transaction.id;
    if (id == null) throw ArgumentError('Transaction id is required');
    _commit((draft) {
      final index = draft.transactions.indexWhere((item) => item.id == id);
      if (index < 0) throw StateError('The transaction does not exist');
      final previous = draft.transactions[index];
      _reverseTransaction(draft, previous);
      final updated = transaction.copyWith(
        createdAt: previous.createdAt ?? previous.date,
        updatedAt: DateTime.now(),
      );
      _applyTransaction(draft, updated);
      draft.transactions[index] = updated.type == TransactionType.income
          ? updated.copyWith(
              incomeAllocations: _incomeAllocationsFor(draft, updated),
            )
          : updated;
    });
  }

  static void _applyTransaction(
    _FinanceState draft,
    FinanceTransaction transaction,
  ) {
    if (transaction.amount <= 0) {
      throw ArgumentError('Amount must be greater than zero');
    }
    switch (transaction.type) {
      case TransactionType.income:
        if (transaction.categoryId case final int categoryId) {
          final category = draft.categories
              .where((item) => item.id == categoryId)
              .firstOrNull;
          if (category == null || category.type != CategoryType.income) {
            throw StateError('The income category does not exist');
          }
        }
        final allocations = _incomeAllocationsFor(draft, transaction);
        for (final entry in allocations.entries) {
          final jar = _jarById(draft, entry.key);
          _replaceJar(
            draft,
            jar.copyWith(balance: jar.balance + entry.value),
          );
        }
      case TransactionType.expense:
        final jarId = transaction.jarId;
        final categoryId = transaction.categoryId;
        if (jarId == null || categoryId == null) {
          throw ArgumentError('Expense requires a jar and a category');
        }
        final jar = _jarById(draft, jarId);
        final category =
            draft.categories.where((item) => item.id == categoryId).firstOrNull;
        if (category == null ||
            category.type != CategoryType.expense ||
            (category.jarId != null && category.jarId != jarId)) {
          throw StateError('The category is not available for this jar');
        }
        _replaceJar(
          draft,
          jar.copyWith(balance: jar.balance - transaction.amount),
        );
      case TransactionType.transfer:
        final sourceId = transaction.jarId;
        final destinationId = transaction.destinationJarId;
        if (sourceId == null || destinationId == null) {
          throw ArgumentError('Transfer requires two jars');
        }
        if (sourceId == destinationId) {
          throw ArgumentError('Transfer jars must be different');
        }
        final source = _jarById(draft, sourceId);
        final destination = _jarById(draft, destinationId);
        _replaceJar(
          draft,
          source.copyWith(balance: source.balance - transaction.amount),
        );
        _replaceJar(
          draft,
          destination.copyWith(
            balance: destination.balance + transaction.amount,
          ),
        );
    }
  }

  static Map<int, int> _incomeAllocationsFor(
    _FinanceState state,
    FinanceTransaction transaction,
  ) {
    if (transaction.incomeAllocations.isNotEmpty) {
      final allocations = Map<int, int>.from(transaction.incomeAllocations);
      if (allocations.values.any((value) => value < 0) ||
          allocations.values.fold<int>(0, (sum, value) => sum + value) !=
              transaction.amount) {
        throw ArgumentError('Income allocations must equal the income amount');
      }
      for (final jarId in allocations.keys) {
        _jarById(state, jarId);
      }
      return allocations;
    }
    final jars = [...state.jars]..sort((a, b) {
        final order = a.orderIndex.compareTo(b.orderIndex);
        return order != 0 ? order : (a.id ?? 0).compareTo(b.id ?? 0);
      });
    final period = _ensureJarPeriod(
      state,
      transaction.date.year,
      transaction.date.month,
    );
    final amounts = distributeIncome(
      amount: transaction.amount,
      percentages: [
        for (final jar in jars) period.percentages[jar.id] ?? 0,
      ],
    );
    return {
      for (var index = 0; index < jars.length; index++)
        jars[index].id!: amounts[index],
    };
  }

  Future<List<FinanceTransaction>> getAllTransactions({int? limit}) async {
    final result = [..._loadedState.transactions]..sort((a, b) {
        final dateOrder = b.date.compareTo(a.date);
        return dateOrder != 0 ? dateOrder : (b.id ?? 0).compareTo(a.id ?? 0);
      });
    return List.unmodifiable(
      limit == null ? result : result.take(limit).toList(),
    );
  }

  Future<void> deleteTransaction(FinanceTransaction item) async {
    final id = item.id;
    if (id == null) throw ArgumentError('Transaction id is required');
    _commit((draft) {
      final index = draft.transactions.indexWhere(
        (transaction) => transaction.id == id,
      );
      if (index < 0) throw StateError('The transaction does not exist');
      _reverseTransaction(draft, draft.transactions[index]);
      draft.transactions.removeAt(index);
    });
  }

  static void _reverseTransaction(
    _FinanceState draft,
    FinanceTransaction transaction,
  ) {
    switch (transaction.type) {
      case TransactionType.income:
        for (final allocation in transaction.incomeAllocations.entries) {
          final jar =
              draft.jars.where((item) => item.id == allocation.key).firstOrNull;
          if (jar != null) {
            _replaceJar(
              draft,
              jar.copyWith(balance: jar.balance - allocation.value),
            );
          }
        }
      case TransactionType.expense:
        final jar = draft.jars
            .where((item) => item.id == transaction.jarId)
            .firstOrNull;
        if (jar != null) {
          _replaceJar(
            draft,
            jar.copyWith(balance: jar.balance + transaction.amount),
          );
        }
      case TransactionType.transfer:
        final source = draft.jars
            .where((item) => item.id == transaction.jarId)
            .firstOrNull;
        final destination = draft.jars
            .where((item) => item.id == transaction.destinationJarId)
            .firstOrNull;
        if (source != null) {
          _replaceJar(
            draft,
            source.copyWith(balance: source.balance + transaction.amount),
          );
        }
        if (destination != null) {
          _replaceJar(
            draft,
            destination.copyWith(
              balance: destination.balance - transaction.amount,
            ),
          );
        }
    }
  }

  Future<List<SpendingSummary>> getExpenseByCategory({
    int? year,
    int? month,
  }) async {
    final categories = {
      for (final category in _loadedState.categories) category.id: category,
    };
    final totals = <int, int>{};
    for (final item in _loadedState.transactions) {
      if (item.type != TransactionType.expense ||
          (year != null && item.date.year != year) ||
          (month != null && item.date.month != month)) {
        continue;
      }
      totals.update(
        item.categoryId ?? 0,
        (value) => value + item.amount,
        ifAbsent: () => item.amount,
      );
    }
    final summaries = [
      for (final entry in totals.entries)
        SpendingSummary(
          id: entry.key,
          label: categories[entry.key]?.name ?? _localizations.otherCategory,
          amount: entry.value,
          color: categories[entry.key]?.color,
          icon: categories[entry.key]?.icon,
        ),
    ]..sort((a, b) => b.amount.compareTo(a.amount));
    return List.unmodifiable(summaries);
  }

  Future<List<BudgetPlan>> getBudgetPlans() async =>
      List.unmodifiable(_loadedState.budgetPlans);

  Future<BudgetPlan> applyBudgetTemplate(
    BudgetMethod method, {
    int? year,
    int? month,
  }) async {
    return _commit((draft) {
      final target = _resolvePeriod(year, month);
      final period = _ensureJarPeriod(draft, target.year, target.month);
      final preset = _BudgetPreset.forMethod(method, _localizations);
      draft.budgetPlans = [
        for (final plan in draft.budgetPlans) plan.copyWith(isActive: false),
      ];
      final plan = BudgetPlan(
        id: draft.nextBudgetPlanId++,
        name: preset.name,
        method: method,
        isActive: true,
        effectiveFrom: target,
      );
      draft.budgetPlans.add(plan);

      if (method == BudgetMethod.custom) return plan;
      final matchedIds = <int>{};
      for (var index = 0; index < preset.jars.length; index++) {
        final item = preset.jars[index];
        final existing = draft.jars
                .where((jar) => jar.templateKey == item.key)
                .firstOrNull ??
            draft.jars
                .where(
                  (jar) => jar.name.toLowerCase() == item.name.toLowerCase(),
                )
                .firstOrNull;
        if (existing == null) {
          final id = draft.nextJarId++;
          draft.jars.add(
            Jar(
              id: id,
              name: item.name,
              description: item.description,
              templateKey: item.key,
              percentage: item.percentage,
              color: item.color,
              orderIndex: index,
            ),
          );
          matchedIds.add(id);
        } else {
          matchedIds.add(existing.id!);
          _replaceJar(
            draft,
            existing.copyWith(
              name: item.name,
              description: existing.description?.isNotEmpty == true
                  ? existing.description
                  : item.description,
              templateKey: item.key,
              percentage: item.percentage,
              color: item.color,
              orderIndex: index,
            ),
          );
        }
      }
      var inactiveOrder = preset.jars.length;
      for (final jar in [...draft.jars]) {
        if (!matchedIds.contains(jar.id)) {
          _replaceJar(
            draft,
            jar.copyWith(percentage: 0, orderIndex: inactiveOrder++),
          );
        }
      }
      period.percentages = {
        for (final jar in draft.jars) jar.id!: jar.percentage,
      };
      return plan;
    });
  }

  Future<List<BudgetLimit>> getBudgetLimits({
    required int year,
    required int month,
  }) async {
    return List.unmodifiable(
      _loadedState.budgetLimits.where(
        (item) => item.year == year && item.month == month,
      ),
    );
  }

  Future<int> saveBudgetLimit(BudgetLimit limit) async {
    if (limit.plannedAmount < 0) {
      throw ArgumentError('Budget cannot be negative');
    }
    return _commit((draft) {
      if (limit.jarId != null) _jarById(draft, limit.jarId!);
      if (limit.categoryId != null &&
          !draft.categories.any((item) => item.id == limit.categoryId)) {
        throw StateError('The category does not exist');
      }
      var index = limit.id == null
          ? -1
          : draft.budgetLimits.indexWhere((item) => item.id == limit.id);
      index = index >= 0
          ? index
          : draft.budgetLimits.indexWhere(
              (item) =>
                  item.year == limit.year &&
                  item.month == limit.month &&
                  item.jarId == limit.jarId &&
                  item.categoryId == limit.categoryId,
            );
      if (index >= 0) {
        final id = draft.budgetLimits[index].id!;
        draft.budgetLimits[index] = limit.copyWith(id: id);
        return id;
      }
      final id = draft.nextBudgetLimitId++;
      draft.budgetLimits.add(limit.copyWith(id: id));
      return id;
    });
  }

  Future<void> deleteBudgetLimit(int id) async {
    _commit((draft) {
      draft.budgetLimits.removeWhere((item) => item.id == id);
    });
  }

  Future<int> spentForBudget(BudgetLimit limit) async {
    return _spentForBudget(_loadedState, limit);
  }

  static int _spentForBudget(_FinanceState state, BudgetLimit limit) {
    return state.transactions
        .where(
          (item) =>
              item.type == TransactionType.expense &&
              item.date.year == limit.year &&
              item.date.month == limit.month &&
              (limit.jarId == null || item.jarId == limit.jarId) &&
              (limit.categoryId == null || item.categoryId == limit.categoryId),
        )
        .fold<int>(0, (sum, item) => sum + item.amount);
  }

  Future<int> copyBudgetLimitsToMonth({
    required int fromYear,
    required int fromMonth,
    required int toYear,
    required int toMonth,
    bool includeRollover = true,
  }) async {
    return _commit((draft) {
      final source = draft.budgetLimits
          .where(
            (item) => item.year == fromYear && item.month == fromMonth,
          )
          .toList();
      var copied = 0;
      for (final limit in source) {
        final spent = _spentForBudget(draft, limit);
        final unused =
            (limit.availableAmount - spent).clamp(0, 1 << 62).toInt();
        final existingIndex = draft.budgetLimits.indexWhere(
          (item) =>
              item.year == toYear &&
              item.month == toMonth &&
              item.jarId == limit.jarId &&
              item.categoryId == limit.categoryId,
        );
        final target = BudgetLimit(
          id: existingIndex < 0
              ? draft.nextBudgetLimitId++
              : draft.budgetLimits[existingIndex].id,
          year: toYear,
          month: toMonth,
          jarId: limit.jarId,
          categoryId: limit.categoryId,
          plannedAmount: limit.plannedAmount,
          rolloverAmount: includeRollover ? unused : 0,
        );
        if (existingIndex < 0) {
          draft.budgetLimits.add(target);
        } else {
          draft.budgetLimits[existingIndex] = target;
        }
        copied++;
      }
      return copied;
    });
  }

  Future<List<FinancialGoal>> getGoals() async {
    final result = [..._loadedState.goals]..sort((a, b) {
        final priority = a.priority.compareTo(b.priority);
        if (priority != 0) return priority;
        final aDate = a.deadline ?? DateTime(9999);
        final bDate = b.deadline ?? DateTime(9999);
        return aDate.compareTo(bDate);
      });
    return List.unmodifiable(result);
  }

  Future<int> saveGoal(FinancialGoal goal) async {
    if (goal.targetAmount <= 0) {
      throw ArgumentError('Goal target must be greater than zero');
    }
    return _commit((draft) {
      if (goal.jarId != null) _jarById(draft, goal.jarId!);
      if (goal.id == null) {
        final id = draft.nextGoalId++;
        draft.goals.add(goal.copyWith(id: id));
        return id;
      }
      final index = draft.goals.indexWhere((item) => item.id == goal.id);
      if (index < 0) throw StateError('The goal does not exist');
      draft.goals[index] = goal;
      return goal.id!;
    });
  }

  Future<void> deleteGoal(int id) async {
    _commit((draft) {
      draft.goals.removeWhere((item) => item.id == id);
      draft.goalContributions.removeWhere((item) => item.goalId == id);
    });
  }

  Future<List<GoalContribution>> getGoalContributions(int goalId) async {
    final result = _loadedState.goalContributions
        .where((item) => item.goalId == goalId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return List.unmodifiable(result);
  }

  Future<int> addGoalContribution(GoalContribution contribution) async {
    if (contribution.amount == 0) {
      throw ArgumentError('Contribution cannot be zero');
    }
    return _commit((draft) {
      final index =
          draft.goals.indexWhere((item) => item.id == contribution.goalId);
      if (index < 0) throw StateError('The goal does not exist');
      final goal = draft.goals[index];
      final nextAmount = goal.currentAmount + contribution.amount;
      if (nextAmount < 0) {
        throw StateError('Goal balance cannot be negative');
      }
      final id = draft.nextGoalContributionId++;
      draft.goalContributions.add(
        GoalContribution(
          id: id,
          goalId: contribution.goalId,
          amount: contribution.amount,
          date: contribution.date,
          note: contribution.note,
        ),
      );
      draft.goals[index] = goal.copyWith(currentAmount: nextAmount);
      return id;
    });
  }

  Future<int> suggestEmergencyFundTarget({int months = 6}) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month - 3, 1);
    final essentialJar = _loadedState.jars.firstOrNull;
    if (essentialJar == null) return 0;
    final total = _loadedState.transactions
        .where(
          (item) =>
              item.type == TransactionType.expense &&
              item.jarId == essentialJar.id &&
              !item.date.isBefore(start) &&
              !item.date.isAfter(now),
        )
        .fold(0, (sum, item) => sum + item.amount);
    final average = (total / 3).round();
    return average * months;
  }

  Future<List<RecurringRule>> getRecurringRules() async =>
      List.unmodifiable(_loadedState.recurringRules);

  Future<int> saveRecurringRule(RecurringRule rule) async {
    _validateRecurringRule(rule);
    return _commit((draft) {
      _validateRecurringReferences(draft, rule);
      if (rule.id == null) {
        final id = draft.nextRecurringRuleId++;
        draft.recurringRules.add(rule.copyWith(id: id));
        return id;
      }
      final index =
          draft.recurringRules.indexWhere((item) => item.id == rule.id);
      if (index < 0) throw StateError('The recurring rule does not exist');
      draft.recurringRules[index] = rule;
      return rule.id!;
    });
  }

  Future<void> deleteRecurringRule(int id) async {
    _commit((draft) {
      draft.recurringRules.removeWhere((item) => item.id == id);
      draft.recurringOccurrences.removeWhere(
        (item) =>
            item.ruleId == id &&
            item.status == RecurringOccurrenceStatus.pending,
      );
    });
  }

  static void _validateRecurringRule(RecurringRule rule) {
    if (rule.amount <= 0 || rule.interval <= 0) {
      throw ArgumentError('Invalid recurring rule amount or interval');
    }
  }

  static void _validateRecurringReferences(
    _FinanceState state,
    RecurringRule rule,
  ) {
    if (rule.type == TransactionType.expense) {
      if (rule.jarId == null || rule.categoryId == null) {
        throw ArgumentError('Recurring expense requires jar and category');
      }
      _jarById(state, rule.jarId!);
      if (!state.categories.any(
        (item) =>
            item.id == rule.categoryId && item.type == CategoryType.expense,
      )) {
        throw StateError('The category does not exist');
      }
    } else if (rule.type == TransactionType.income &&
        rule.categoryId != null &&
        !state.categories.any(
          (item) =>
              item.id == rule.categoryId && item.type == CategoryType.income,
        )) {
      throw StateError('The income category does not exist');
    } else if (rule.type == TransactionType.transfer) {
      if (rule.jarId == null || rule.destinationJarId == null) {
        throw ArgumentError('Recurring transfer requires two jars');
      }
      _jarById(state, rule.jarId!);
      _jarById(state, rule.destinationJarId!);
    }
  }

  Future<List<RecurringOccurrence>> processDueRecurringRules(
    DateTime now,
  ) async {
    return _commit((draft) {
      for (var index = 0; index < draft.recurringRules.length; index++) {
        var rule = draft.recurringRules[index];
        if (!rule.isEnabled) continue;
        var safety = 0;
        while (!rule.nextRunAt.isAfter(now) && safety++ < 120) {
          if (rule.endAt != null && rule.nextRunAt.isAfter(rule.endAt!)) {
            rule = rule.copyWith(isEnabled: false);
            break;
          }
          final scheduledAt = rule.nextRunAt;
          final key = '${rule.id}:${scheduledAt.toUtc().toIso8601String()}';
          if (!draft.recurringOccurrences.any((item) => item.key == key)) {
            var occurrence = RecurringOccurrence(
              key: key,
              ruleId: rule.id!,
              scheduledAt: scheduledAt,
            );
            if (rule.autoPost) {
              final transactionId = draft.nextTransactionId++;
              final transaction = _transactionForRule(
                rule,
                scheduledAt,
                key,
                transactionId,
              );
              _applyTransaction(draft, transaction);
              draft.transactions.add(
                transaction.type == TransactionType.income
                    ? transaction.copyWith(
                        incomeAllocations:
                            _incomeAllocationsFor(draft, transaction),
                      )
                    : transaction,
              );
              occurrence = occurrence.copyWith(
                status: RecurringOccurrenceStatus.completed,
                transactionId: transactionId,
              );
            }
            draft.recurringOccurrences.add(occurrence);
          }
          rule = rule.copyWith(
            nextRunAt: _advanceDate(
              scheduledAt,
              rule.frequency,
              rule.interval,
            ),
          );
        }
        draft.recurringRules[index] = rule;
      }
      return List.unmodifiable(
        draft.recurringOccurrences
            .where(
              (item) => item.status == RecurringOccurrenceStatus.pending,
            )
            .toList()
          ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt)),
      );
    });
  }

  Future<List<RecurringOccurrence>> getPendingOccurrences() async {
    final result = _loadedState.recurringOccurrences
        .where(
          (item) => item.status == RecurringOccurrenceStatus.pending,
        )
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    return List.unmodifiable(result);
  }

  Future<void> completeOccurrence(String key) async {
    _commit((draft) {
      final occurrenceIndex =
          draft.recurringOccurrences.indexWhere((item) => item.key == key);
      if (occurrenceIndex < 0) {
        throw StateError('The recurring occurrence does not exist');
      }
      final occurrence = draft.recurringOccurrences[occurrenceIndex];
      if (occurrence.status != RecurringOccurrenceStatus.pending) return;
      final rule = draft.recurringRules
          .where((item) => item.id == occurrence.ruleId)
          .firstOrNull;
      if (rule == null) throw StateError('The recurring rule does not exist');
      final transactionId = draft.nextTransactionId++;
      final transaction = _transactionForRule(
        rule,
        occurrence.scheduledAt,
        key,
        transactionId,
      );
      _applyTransaction(draft, transaction);
      draft.transactions.add(
        transaction.type == TransactionType.income
            ? transaction.copyWith(
                incomeAllocations: _incomeAllocationsFor(draft, transaction),
              )
            : transaction,
      );
      draft.recurringOccurrences[occurrenceIndex] = occurrence.copyWith(
        status: RecurringOccurrenceStatus.completed,
        transactionId: transactionId,
      );
    });
  }

  Future<void> skipOccurrence(String key) async {
    _commit((draft) {
      final index =
          draft.recurringOccurrences.indexWhere((item) => item.key == key);
      if (index < 0) {
        throw StateError('The recurring occurrence does not exist');
      }
      draft.recurringOccurrences[index] = draft.recurringOccurrences[index]
          .copyWith(status: RecurringOccurrenceStatus.skipped);
    });
  }

  static FinanceTransaction _transactionForRule(
    RecurringRule rule,
    DateTime date,
    String occurrenceKey,
    int id,
  ) {
    return FinanceTransaction(
      id: id,
      type: rule.type,
      amount: rule.amount,
      jarId: rule.jarId,
      destinationJarId: rule.destinationJarId,
      categoryId: rule.categoryId,
      note: rule.note ?? rule.name,
      date: date,
      accountName: rule.accountName,
      recurringRuleId: rule.id,
      occurrenceKey: occurrenceKey,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  static DateTime _advanceDate(
    DateTime date,
    RecurrenceFrequency frequency,
    int interval,
  ) {
    switch (frequency) {
      case RecurrenceFrequency.weekly:
        return date.add(Duration(days: 7 * interval));
      case RecurrenceFrequency.monthly:
        return _addMonths(date, interval);
      case RecurrenceFrequency.quarterly:
        return _addMonths(date, 3 * interval);
      case RecurrenceFrequency.yearly:
        return _addMonths(date, 12 * interval);
    }
  }

  static DateTime _addMonths(DateTime date, int months) {
    final first = DateTime(date.year, date.month + months, 1);
    final lastDay = DateTime(first.year, first.month + 1, 0).day;
    return DateTime(
      first.year,
      first.month,
      date.day.clamp(1, lastDay).toInt(),
      date.hour,
      date.minute,
      date.second,
      date.millisecond,
      date.microsecond,
    );
  }

  Future<void> close() async {}

  static DateTime _resolvePeriod(int? year, int? month) {
    final now = DateTime.now();
    return DateTime(year ?? now.year, month ?? now.month);
  }

  static _JarPeriod _ensureJarPeriod(
    _FinanceState state,
    int year,
    int month,
  ) {
    for (final period in state.jarPeriods) {
      if (period.year == year && period.month == month) return period;
    }
    final created = _JarPeriod(
      year: year,
      month: month,
      percentages: _percentagesForNewPeriod(
        state,
        year: year,
        month: month,
      ),
    );
    state.jarPeriods.add(created);
    return created;
  }

  static Map<int, double> _percentagesForNewPeriod(
    _FinanceState state, {
    required int year,
    required int month,
  }) {
    final previousDate = DateTime(year, month - 1);
    final previous = state.jarPeriods
        .where(
          (period) =>
              period.year == previousDate.year &&
              period.month == previousDate.month,
        )
        .firstOrNull;
    if (previous == null) return _defaultJarPercentages(state.jars);
    return {
      for (final jar in state.jars) jar.id!: previous.percentages[jar.id] ?? 0,
    };
  }

  static Map<int, double> _defaultJarPercentages(List<Jar> jars) {
    const defaults = {
      'essentials': 55.0,
      'savings_investments': 25.0,
      'enjoyment': 10.0,
      'education_development': 10.0,
    };
    final availableKeys = jars.map((jar) => jar.templateKey).toSet();
    if (defaults.keys.every(availableKeys.contains)) {
      return {
        for (final jar in jars) jar.id!: defaults[jar.templateKey] ?? 0,
      };
    }
    final ordered = [...jars]..sort((a, b) {
        final order = a.orderIndex.compareTo(b.orderIndex);
        return order != 0 ? order : (a.id ?? 0).compareTo(b.id ?? 0);
      });
    const fallback = [55.0, 25.0, 10.0, 10.0];
    return {
      for (var index = 0; index < ordered.length; index++)
        ordered[index].id!: index < fallback.length ? fallback[index] : 0,
    };
  }

  static Map<int, int> _monthlyJarBalances(
    _FinanceState state,
    int year,
    int month,
  ) {
    final balances = {for (final jar in state.jars) jar.id!: 0};
    for (final transaction in state.transactions) {
      if (transaction.date.year != year || transaction.date.month != month) {
        continue;
      }
      switch (transaction.type) {
        case TransactionType.income:
          for (final allocation in transaction.incomeAllocations.entries) {
            balances.update(
              allocation.key,
              (value) => value + allocation.value,
              ifAbsent: () => allocation.value,
            );
          }
        case TransactionType.expense:
          if (transaction.jarId case final int jarId) {
            balances.update(
              jarId,
              (value) => value - transaction.amount,
              ifAbsent: () => -transaction.amount,
            );
          }
        case TransactionType.transfer:
          if (transaction.jarId case final int sourceId) {
            balances.update(
              sourceId,
              (value) => value - transaction.amount,
              ifAbsent: () => -transaction.amount,
            );
          }
          if (transaction.destinationJarId case final int destinationId) {
            balances.update(
              destinationId,
              (value) => value + transaction.amount,
              ifAbsent: () => transaction.amount,
            );
          }
      }
    }
    return balances;
  }

  static Jar _jarById(_FinanceState state, int id) {
    final jar = state.jars.where((item) => item.id == id).firstOrNull;
    if (jar == null) throw StateError('The selected jar does not exist');
    return jar;
  }

  static void _replaceJar(_FinanceState state, Jar jar) {
    final index = state.jars.indexWhere((item) => item.id == jar.id);
    if (index < 0) throw StateError('The selected jar does not exist');
    state.jars[index] = jar;
  }
}

class _JarPeriod {
  _JarPeriod({
    required this.year,
    required this.month,
    required this.percentages,
  });

  final int year;
  final int month;
  Map<int, double> percentages;

  factory _JarPeriod.fromJars(int year, int month, List<Jar> jars) {
    return _JarPeriod(
      year: year,
      month: month,
      percentages: {
        for (final jar in jars) jar.id!: jar.percentage,
      },
    );
  }

  factory _JarPeriod.fromMap(Map<String, Object?> map) {
    final encoded = Map<String, Object?>.from(
      (map['percentages'] as Map?) ?? const {},
    );
    return _JarPeriod(
      year: (map['year'] as num).toInt(),
      month: (map['month'] as num).toInt(),
      percentages: {
        for (final entry in encoded.entries)
          int.parse(entry.key): (entry.value as num).toDouble(),
      },
    );
  }

  _JarPeriod copy() => _JarPeriod(
        year: year,
        month: month,
        percentages: Map<int, double>.from(percentages),
      );

  Map<String, Object?> toMap() => {
        'year': year,
        'month': month,
        'percentages': {
          for (final entry in percentages.entries) '${entry.key}': entry.value,
        },
      };
}

class _FinanceState {
  _FinanceState({
    required this.jars,
    required this.jarPeriods,
    required this.categories,
    required this.transactions,
    required this.budgetPlans,
    required this.budgetLimits,
    required this.goals,
    required this.goalContributions,
    required this.recurringRules,
    required this.recurringOccurrences,
    required this.nextJarId,
    required this.nextCategoryId,
    required this.nextTransactionId,
    required this.nextBudgetPlanId,
    required this.nextBudgetLimitId,
    required this.nextGoalId,
    required this.nextGoalContributionId,
    required this.nextRecurringRuleId,
  });

  static const schemaVersion = 4;
  List<Jar> jars;
  List<_JarPeriod> jarPeriods;
  List<Category> categories;
  List<FinanceTransaction> transactions;
  List<BudgetPlan> budgetPlans;
  List<BudgetLimit> budgetLimits;
  List<FinancialGoal> goals;
  List<GoalContribution> goalContributions;
  List<RecurringRule> recurringRules;
  List<RecurringOccurrence> recurringOccurrences;
  int nextJarId;
  int nextCategoryId;
  int nextTransactionId;
  int nextBudgetPlanId;
  int nextBudgetLimitId;
  int nextGoalId;
  int nextGoalContributionId;
  int nextRecurringRuleId;

  factory _FinanceState.seeded(AppLocalizations l10n) {
    final jars = [
      Jar(
        id: 1,
        name: l10n.jarEssentials,
        description: l10n.jarEssentialsDescription,
        templateKey: 'essentials',
        percentage: 55,
        color: '#247A68',
        orderIndex: 0,
      ),
      Jar(
        id: 2,
        name: l10n.jarSavingsInvestments,
        description: l10n.jarSavingsInvestmentsDescription,
        templateKey: 'savings_investments',
        percentage: 25,
        color: '#3566A8',
        orderIndex: 1,
      ),
      Jar(
        id: 3,
        name: l10n.jarEnjoyment,
        description: l10n.jarEnjoymentDescription,
        templateKey: 'enjoyment',
        percentage: 10,
        color: '#C97832',
        orderIndex: 2,
      ),
      Jar(
        id: 4,
        name: l10n.jarEducationDevelopment,
        description: l10n.jarEducationDevelopmentDescription,
        templateKey: 'education_development',
        percentage: 10,
        color: '#7A559D',
        orderIndex: 3,
      ),
    ];
    final categories = _defaultCategories(l10n, jars);
    final now = DateTime.now();
    return _FinanceState(
      jars: [...jars],
      jarPeriods: [_JarPeriod.fromJars(now.year, now.month, jars)],
      categories: [...categories],
      transactions: [],
      budgetPlans: [
        BudgetPlan(
          id: 1,
          name: l10n.fourJarsPlan,
          method: BudgetMethod.fourJars,
          isActive: true,
          effectiveFrom: DateTime(now.year, now.month, 1),
        ),
      ],
      budgetLimits: [],
      goals: [],
      goalContributions: [],
      recurringRules: [],
      recurringOccurrences: [],
      nextJarId: 5,
      nextCategoryId: 30,
      nextTransactionId: 1,
      nextBudgetPlanId: 2,
      nextBudgetLimitId: 1,
      nextGoalId: 1,
      nextGoalContributionId: 1,
      nextRecurringRuleId: 1,
    );
  }

  static List<Category> _defaultCategories(
    AppLocalizations l10n,
    List<Jar> jars,
  ) {
    int jarId(String templateKey) {
      return jars
              .where((jar) => jar.templateKey == templateKey)
              .firstOrNull
              ?.id ??
          jars.first.id!;
    }

    final essentials = jarId('essentials');
    final enjoyment = jarId('enjoyment');
    final education = jarId('education_development');
    return [
      Category(
        id: 1,
        name: l10n.categoryShopping,
        icon: 'icons8:essential-shopping',
        jarId: enjoyment,
      ),
      Category(
        id: 2,
        name: l10n.categoryFood,
        icon: 'icons8:food',
        jarId: essentials,
      ),
      Category(
        id: 28,
        name: l10n.categorySnacks,
        icon: 'icons8:coffee',
        jarId: essentials,
      ),
      Category(
        id: 29,
        name: l10n.categoryChildren,
        icon: 'icons8:family',
        jarId: essentials,
      ),
      Category(
        id: 3,
        name: l10n.categoryCoffee,
        icon: 'icons8:coffee',
        jarId: enjoyment,
      ),
      Category(
        id: 4,
        name: l10n.categoryGroceries,
        icon: 'icons8:groceries',
        jarId: essentials,
      ),
      Category(
        id: 5,
        name: l10n.categoryRent,
        icon: 'icons8:rent',
        jarId: essentials,
      ),
      Category(
        id: 6,
        name: l10n.categoryUtilities,
        icon: 'icons8:utilities',
        jarId: essentials,
      ),
      Category(
        id: 7,
        name: l10n.categoryInternet,
        icon: 'icons8:internet',
        jarId: essentials,
      ),
      Category(
        id: 8,
        name: l10n.categoryPhone,
        icon: 'icons8:phone',
        jarId: essentials,
      ),
      Category(
        id: 9,
        name: l10n.categoryFuel,
        icon: 'icons8:fuel',
        jarId: essentials,
      ),
      Category(
        id: 10,
        name: l10n.categoryTransport,
        icon: 'icons8:transport',
        jarId: essentials,
      ),
      Category(
        id: 11,
        name: l10n.categoryHealthcare,
        icon: 'icons8:healthcare',
        jarId: essentials,
      ),
      Category(
        id: 12,
        name: l10n.categoryBeauty,
        icon: 'icons8:beauty',
        jarId: enjoyment,
      ),
      Category(
        id: 13,
        name: l10n.categoryEntertainment,
        icon: 'icons8:entertainment',
        jarId: enjoyment,
      ),
      Category(
        id: 14,
        name: l10n.categoryTravel,
        icon: 'icons8:travel',
        jarId: enjoyment,
      ),
      Category(
        id: 15,
        name: l10n.categoryEducation,
        icon: 'icons8:courses-books',
        jarId: education,
      ),
      Category(
        id: 16,
        name: l10n.categorySubscriptions,
        icon: 'icons8:subscriptions',
        jarId: enjoyment,
      ),
      Category(
        id: 17,
        name: l10n.categoryTechnology,
        icon: 'icons8:technology',
        jarId: enjoyment,
      ),
      Category(
        id: 18,
        name: l10n.categoryGifts,
        icon: 'icons8:gifts',
        jarId: enjoyment,
      ),
      Category(
        id: 19,
        name: l10n.categoryFamily,
        icon: 'icons8:family',
        jarId: essentials,
      ),
      Category(
        id: 20,
        name: l10n.categoryOtherExpenses,
        icon: 'icons8:other-expenses',
      ),
      Category(
        id: 21,
        name: l10n.incomeCategorySalary,
        icon: 'icons8:income-salary',
        type: CategoryType.income,
      ),
      Category(
        id: 22,
        name: l10n.incomeCategoryBonus,
        icon: 'icons8:income-bonus',
        type: CategoryType.income,
      ),
      Category(
        id: 23,
        name: l10n.incomeCategorySideJob,
        icon: 'icons8:income-side-job',
        type: CategoryType.income,
      ),
      Category(
        id: 24,
        name: l10n.incomeCategoryFreelance,
        icon: 'icons8:income-freelance',
        type: CategoryType.income,
      ),
      Category(
        id: 25,
        name: l10n.incomeCategoryBusiness,
        icon: 'icons8:income-business',
        type: CategoryType.income,
      ),
      Category(
        id: 26,
        name: l10n.incomeCategoryInvestment,
        icon: 'icons8:income-investment',
        type: CategoryType.income,
      ),
      Category(
        id: 27,
        name: l10n.incomeCategoryOther,
        icon: 'icons8:income-other',
        type: CategoryType.income,
      ),
    ];
  }

  static _FinanceState _mergeDefaultCategories(
    _FinanceState state,
    AppLocalizations l10n,
  ) {
    final usedCategoryIds = <int>{
      for (final item in state.transactions)
        if (item.categoryId != null) item.categoryId!,
      for (final limit in state.budgetLimits)
        if (limit.categoryId != null) limit.categoryId!,
      for (final rule in state.recurringRules)
        if (rule.categoryId != null) rule.categoryId!,
    };
    final retiredNames = {
      l10n.categoryHousingUtilities,
      l10n.categoryEssentialShopping,
      l10n.categoryBankSavings,
      l10n.categoryStockInvestment,
      l10n.categoryEntertainmentCafe,
      l10n.categoryCoursesBooks,
      l10n.categorySkillsWorkshop,
    };
    state.categories.removeWhere(
      (category) =>
          retiredNames.contains(category.name) &&
          !usedCategoryIds.contains(category.id),
    );

    for (final category in state.categories) {
      final id = category.id ?? 0;
      if (id >= state.nextCategoryId) state.nextCategoryId = id + 1;
    }
    for (final template in _defaultCategories(l10n, state.jars)) {
      final index = state.categories.indexWhere(
        (category) =>
            category.type == template.type && category.name == template.name,
      );
      if (index >= 0) {
        final existing = state.categories[index];
        state.categories[index] = existing.copyWith(
          icon: template.icon,
          jarId: template.jarId,
          clearJar: template.jarId == null,
          type: template.type,
        );
      } else {
        state.categories.add(
          Category(
            id: state.nextCategoryId++,
            name: template.name,
            icon: template.icon,
            jarId: template.jarId,
            type: template.type,
          ),
        );
      }
    }
    return state;
  }

  factory _FinanceState.fromV3(
    Map<String, Object?> json,
    AppLocalizations l10n,
  ) {
    final state = _FinanceState(
      jars: _decodeList(json['jars'], Jar.fromMap),
      jarPeriods: _decodeList(json['jar_periods'], _JarPeriod.fromMap),
      categories: _decodeList(json['categories'], Category.fromMap),
      transactions:
          _decodeList(json['transactions'], FinanceTransaction.fromMap),
      budgetPlans: _decodeList(json['budget_plans'], BudgetPlan.fromMap),
      budgetLimits: _decodeList(json['budget_limits'], BudgetLimit.fromMap),
      goals: _decodeList(json['goals'], FinancialGoal.fromMap),
      goalContributions: _decodeList(
        json['goal_contributions'],
        GoalContribution.fromMap,
      ),
      recurringRules:
          _decodeList(json['recurring_rules'], RecurringRule.fromMap),
      recurringOccurrences: _decodeList(
        json['recurring_occurrences'],
        RecurringOccurrence.fromMap,
      ),
      nextJarId: (json['next_jar_id'] as num).toInt(),
      nextCategoryId: (json['next_category_id'] as num).toInt(),
      nextTransactionId: (json['next_transaction_id'] as num).toInt(),
      nextBudgetPlanId: (json['next_budget_plan_id'] as num?)?.toInt() ?? 1,
      nextBudgetLimitId: (json['next_budget_limit_id'] as num?)?.toInt() ?? 1,
      nextGoalId: (json['next_goal_id'] as num?)?.toInt() ?? 1,
      nextGoalContributionId:
          (json['next_goal_contribution_id'] as num?)?.toInt() ?? 1,
      nextRecurringRuleId:
          (json['next_recurring_rule_id'] as num?)?.toInt() ?? 1,
    );
    return _mergeDefaultCategories(state, l10n);
  }

  factory _FinanceState.fromV1(
    Map<String, Object?> json,
    AppLocalizations l10n,
  ) {
    final now = DateTime.now();
    final jars = _decodeList(json['jars'], Jar.fromMap);
    final state = _FinanceState(
      jars: jars,
      jarPeriods: [_JarPeriod.fromJars(now.year, now.month, jars)],
      categories: _decodeList(json['categories'], Category.fromMap),
      transactions:
          _decodeList(json['transactions'], FinanceTransaction.fromMap),
      budgetPlans: [
        BudgetPlan(
          id: 1,
          name: l10n.fourJarsPlan,
          method: BudgetMethod.fourJars,
          isActive: true,
          effectiveFrom: DateTime(now.year, now.month, 1),
        ),
      ],
      budgetLimits: [],
      goals: [],
      goalContributions: [],
      recurringRules: [],
      recurringOccurrences: [],
      nextJarId: (json['next_jar_id'] as num).toInt(),
      nextCategoryId: (json['next_category_id'] as num).toInt(),
      nextTransactionId: (json['next_transaction_id'] as num).toInt(),
      nextBudgetPlanId: 2,
      nextBudgetLimitId: 1,
      nextGoalId: 1,
      nextGoalContributionId: 1,
      nextRecurringRuleId: 1,
    );
    return _mergeDefaultCategories(state, l10n);
  }

  factory _FinanceState.fromV2(
    Map<String, Object?> json,
    AppLocalizations l10n,
  ) {
    final now = DateTime.now();
    final jars = _decodeList(json['jars'], Jar.fromMap);
    final state = _FinanceState(
      jars: jars,
      jarPeriods: [_JarPeriod.fromJars(now.year, now.month, jars)],
      categories: _decodeList(json['categories'], Category.fromMap),
      transactions:
          _decodeList(json['transactions'], FinanceTransaction.fromMap),
      budgetPlans: _decodeList(json['budget_plans'], BudgetPlan.fromMap),
      budgetLimits: _decodeList(json['budget_limits'], BudgetLimit.fromMap),
      goals: _decodeList(json['goals'], FinancialGoal.fromMap),
      goalContributions: _decodeList(
        json['goal_contributions'],
        GoalContribution.fromMap,
      ),
      recurringRules:
          _decodeList(json['recurring_rules'], RecurringRule.fromMap),
      recurringOccurrences: _decodeList(
        json['recurring_occurrences'],
        RecurringOccurrence.fromMap,
      ),
      nextJarId: (json['next_jar_id'] as num).toInt(),
      nextCategoryId: (json['next_category_id'] as num).toInt(),
      nextTransactionId: (json['next_transaction_id'] as num).toInt(),
      nextBudgetPlanId: (json['next_budget_plan_id'] as num?)?.toInt() ?? 1,
      nextBudgetLimitId: (json['next_budget_limit_id'] as num?)?.toInt() ?? 1,
      nextGoalId: (json['next_goal_id'] as num?)?.toInt() ?? 1,
      nextGoalContributionId:
          (json['next_goal_contribution_id'] as num?)?.toInt() ?? 1,
      nextRecurringRuleId:
          (json['next_recurring_rule_id'] as num?)?.toInt() ?? 1,
    );
    return _mergeDefaultCategories(state, l10n);
  }

  factory _FinanceState.fromJson(Map<String, Object?> json) {
    final version = (json['schema_version'] as num?)?.toInt() ?? 0;
    if (version != schemaVersion) {
      throw FormatException('Unsupported finance snapshot version: $version');
    }
    return _FinanceState(
      jars: _decodeList(json['jars'], Jar.fromMap),
      jarPeriods: _decodeList(json['jar_periods'], _JarPeriod.fromMap),
      categories: _decodeList(json['categories'], Category.fromMap),
      transactions:
          _decodeList(json['transactions'], FinanceTransaction.fromMap),
      budgetPlans: _decodeList(json['budget_plans'], BudgetPlan.fromMap),
      budgetLimits: _decodeList(json['budget_limits'], BudgetLimit.fromMap),
      goals: _decodeList(json['goals'], FinancialGoal.fromMap),
      goalContributions: _decodeList(
        json['goal_contributions'],
        GoalContribution.fromMap,
      ),
      recurringRules:
          _decodeList(json['recurring_rules'], RecurringRule.fromMap),
      recurringOccurrences: _decodeList(
        json['recurring_occurrences'],
        RecurringOccurrence.fromMap,
      ),
      nextJarId: (json['next_jar_id'] as num).toInt(),
      nextCategoryId: (json['next_category_id'] as num).toInt(),
      nextTransactionId: (json['next_transaction_id'] as num).toInt(),
      nextBudgetPlanId: (json['next_budget_plan_id'] as num?)?.toInt() ?? 1,
      nextBudgetLimitId: (json['next_budget_limit_id'] as num?)?.toInt() ?? 1,
      nextGoalId: (json['next_goal_id'] as num?)?.toInt() ?? 1,
      nextGoalContributionId:
          (json['next_goal_contribution_id'] as num?)?.toInt() ?? 1,
      nextRecurringRuleId:
          (json['next_recurring_rule_id'] as num?)?.toInt() ?? 1,
    );
  }

  static List<T> _decodeList<T>(
    Object? value,
    T Function(Map<String, Object?>) decode,
  ) {
    return [
      for (final item in (value as List<Object?>?) ?? const [])
        decode(Map<String, Object?>.from(item! as Map)),
    ];
  }

  _FinanceState copy() {
    return _FinanceState(
      jars: [...jars],
      jarPeriods: [for (final period in jarPeriods) period.copy()],
      categories: [...categories],
      transactions: [...transactions],
      budgetPlans: [...budgetPlans],
      budgetLimits: [...budgetLimits],
      goals: [...goals],
      goalContributions: [...goalContributions],
      recurringRules: [...recurringRules],
      recurringOccurrences: [...recurringOccurrences],
      nextJarId: nextJarId,
      nextCategoryId: nextCategoryId,
      nextTransactionId: nextTransactionId,
      nextBudgetPlanId: nextBudgetPlanId,
      nextBudgetLimitId: nextBudgetLimitId,
      nextGoalId: nextGoalId,
      nextGoalContributionId: nextGoalContributionId,
      nextRecurringRuleId: nextRecurringRuleId,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'schema_version': schemaVersion,
      'next_jar_id': nextJarId,
      'next_category_id': nextCategoryId,
      'next_transaction_id': nextTransactionId,
      'next_budget_plan_id': nextBudgetPlanId,
      'next_budget_limit_id': nextBudgetLimitId,
      'next_goal_id': nextGoalId,
      'next_goal_contribution_id': nextGoalContributionId,
      'next_recurring_rule_id': nextRecurringRuleId,
      'jars': [for (final jar in jars) jar.toMap()],
      'jar_periods': [for (final period in jarPeriods) period.toMap()],
      'categories': [for (final category in categories) category.toMap()],
      'transactions': [
        for (final transaction in transactions) transaction.toMap(),
      ],
      'budget_plans': [for (final plan in budgetPlans) plan.toMap()],
      'budget_limits': [for (final limit in budgetLimits) limit.toMap()],
      'goals': [for (final goal in goals) goal.toMap()],
      'goal_contributions': [
        for (final contribution in goalContributions) contribution.toMap(),
      ],
      'recurring_rules': [
        for (final rule in recurringRules) rule.toMap(),
      ],
      'recurring_occurrences': [
        for (final occurrence in recurringOccurrences) occurrence.toMap(),
      ],
    };
  }
}

class _BudgetPreset {
  const _BudgetPreset(this.name, this.jars);

  final String name;
  final List<_PresetJar> jars;

  static _BudgetPreset forMethod(
    BudgetMethod method,
    AppLocalizations l10n,
  ) {
    return switch (method) {
      BudgetMethod.fourJars => _BudgetPreset(
          l10n.fourJarsPlan,
          [
            _PresetJar(
              l10n.jarEssentials,
              55,
              '#247A68',
              'essentials',
              description: l10n.jarEssentialsDescription,
            ),
            _PresetJar(
              l10n.jarSavingsInvestments,
              25,
              '#3566A8',
              'savings_investments',
              description: l10n.jarSavingsInvestmentsDescription,
            ),
            _PresetJar(
              l10n.jarEnjoyment,
              10,
              '#C97832',
              'enjoyment',
              description: l10n.jarEnjoymentDescription,
            ),
            _PresetJar(
              l10n.jarEducationDevelopment,
              10,
              '#7A559D',
              'education_development',
              description: l10n.jarEducationDevelopmentDescription,
            ),
          ],
        ),
      BudgetMethod.sixJars => _BudgetPreset(
          l10n.sixJarsPlan,
          [
            _PresetJar(
              l10n.jarEssentials,
              55,
              '#247A68',
              'essentials',
              description: l10n.jarEssentialsDescription,
            ),
            _PresetJar(
              l10n.jarLongTermSavings,
              10,
              '#3566A8',
              'long_term_savings',
              description: l10n.jarLongTermSavingsDescription,
            ),
            _PresetJar(
              l10n.jarFinancialFreedom,
              10,
              '#3E7C8B',
              'financial_freedom',
              description: l10n.jarFinancialFreedomDescription,
            ),
            _PresetJar(
              l10n.jarEducation,
              10,
              '#7A559D',
              'education',
              description: l10n.jarEducationDescription,
            ),
            _PresetJar(
              l10n.jarEnjoyment,
              10,
              '#C97832',
              'enjoyment',
              description: l10n.jarEnjoymentDescription,
            ),
            _PresetJar(
              l10n.jarGiving,
              5,
              '#B24B63',
              'giving',
              description: l10n.jarGivingDescription,
            ),
          ],
        ),
      BudgetMethod.fiftyTwentyThirty => _BudgetPreset(
          l10n.fiftyPlan,
          [
            _PresetJar(
              l10n.jarEssentials,
              50,
              '#247A68',
              'essentials',
              description: l10n.jarEssentialsDescription,
            ),
            _PresetJar(
              l10n.jarSavingsInvestments,
              20,
              '#3566A8',
              'savings_investments',
              description: l10n.jarSavingsInvestmentsDescription,
            ),
            _PresetJar(
              l10n.jarPersonalWants,
              30,
              '#C97832',
              'personal_wants',
              description: l10n.jarPersonalWantsDescription,
            ),
          ],
        ),
      BudgetMethod.custom => _BudgetPreset(l10n.customPlan, const []),
    };
  }
}

class _PresetJar {
  const _PresetJar(
    this.name,
    this.percentage,
    this.color,
    this.key, {
    this.description,
  });

  final String name;
  final double percentage;
  final String color;
  final String key;
  final String? description;
}
