import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/category.dart';
import '../models/finance_transaction.dart';
import '../providers/finance_provider.dart';
import '../utils/formatters.dart';
import '../widgets/button_label.dart';
import '../widgets/empty_state.dart';
import '../widgets/transaction_tile.dart';
import 'edit_transaction_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  TransactionType? _filter;
  DateTimeRange? _dateRange;
  int? _categoryId;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<FinanceProvider>();
    const filterHeight = 40.0;
    final query = _searchController.text.trim().toLowerCase();
    final items = provider.transactions
        .where((item) => _filter == null || item.type == _filter)
        .where((item) {
          final range = _dateRange;
          if (range == null) return true;
          final date = DateUtils.dateOnly(item.date);
          return !date.isBefore(DateUtils.dateOnly(range.start)) &&
              !date.isAfter(DateUtils.dateOnly(range.end));
        })
        .where((item) => _categoryId == null || item.categoryId == _categoryId)
        .where((item) {
          if (query.isEmpty) return true;
          final jar = provider.jarById(item.jarId)?.name ?? '';
          final destination =
              provider.jarById(item.destinationJarId)?.name ?? '';
          final category = provider.categoryById(item.categoryId)?.name ?? '';
          return [
            item.note ?? '',
            item.accountName ?? '',
            jar,
            destination,
            category,
          ].any((value) => value.toLowerCase().contains(query));
        })
        .toList();
    final dailyExpenses = <DateTime, int>{};
    for (final transaction in items) {
      if (transaction.type != TransactionType.expense) continue;
      final day = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );
      dailyExpenses[day] = (dailyExpenses[day] ?? 0) + transaction.amount;
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.historyTitle)),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: SearchBar(
                constraints: const BoxConstraints(
                  minHeight: 40,
                  maxHeight: 40,
                ),
                padding: const WidgetStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: 12),
                ),
                controller: _searchController,
                hintText: l10n.searchTransactions,
                leading: const Icon(Icons.search_rounded),
                trailing: [
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
                ],
                onChanged: (_) => setState(() {}),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _setCurrentMonth,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, filterHeight),
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    icon: const Icon(Icons.calendar_month_outlined),
                    label: Text(l10n.thisMonth),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: _pickDateRange,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, filterHeight),
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    icon: const Icon(Icons.date_range_outlined),
                    label: Text(_dateRangeLabel(context)),
                  ),
                  const SizedBox(width: 8),
                  _CategoryFilter(
                    categories: provider.categories,
                    selectedId: _categoryId,
                    allLabel: l10n.filterAll,
                    categoryLabel: l10n.selectCategory,
                    onChanged: (value) => setState(() => _categoryId = value),
                  ),
                  const SizedBox(width: 8),
                  SegmentedButton<TransactionType?>(
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment(
                        value: null,
                        label: Transform.translate(
                          offset: const Offset(0, -2),
                          child: ButtonLabel(l10n.filterAll),
                        ),
                      ),
                      ButtonSegment(
                        value: TransactionType.income,
                        label: Transform.translate(
                          offset: const Offset(0, -2),
                          child: ButtonLabel(l10n.filterIncome),
                        ),
                        icon: const Icon(
                          Icons.south_west_rounded,
                          color: Color(0xFF34C759),
                        ),
                      ),
                      ButtonSegment(
                        value: TransactionType.expense,
                        label: Transform.translate(
                          offset: const Offset(0, -2),
                          child: ButtonLabel(l10n.filterExpense),
                        ),
                        icon: const Icon(
                          Icons.north_east_rounded,
                          color: Color(0xFFFF3B30),
                        ),
                      ),
                      ButtonSegment(
                        value: TransactionType.transfer,
                        label: Transform.translate(
                          offset: const Offset(0, -2),
                          child: ButtonLabel(l10n.filterTransfer),
                        ),
                        icon: const Icon(
                          Icons.swap_horiz_rounded,
                          color: Color(0xFF007AFF),
                        ),
                      ),
                    ],
                    selected: {_filter},
                    style: ButtonStyle(
                      minimumSize: const WidgetStatePropertyAll(
                        Size(0, filterHeight),
                      ),
                      alignment: Alignment.center,
                      backgroundColor: WidgetStateProperty.resolveWith(
                        (states) => states.contains(WidgetState.selected)
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Colors.transparent,
                      ),
                      visualDensity: const VisualDensity(
                        horizontal: -2,
                        vertical: -2,
                      ),
                      padding: const WidgetStatePropertyAll(
                        EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                    onSelectionChanged: (values) =>
                        setState(() => _filter = values.first),
                  ),
                ],
              ),
            ),
            Expanded(
              child: items.isEmpty
                  ? EmptyState(
                      icon: Icons.receipt_long_outlined,
                      title: l10n.noTransactions,
                      body: l10n.noTransactionsBody,
                    )
                  : RefreshIndicator(
                      onRefresh: provider.refresh,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final colors = Theme.of(context).colorScheme;
                          final availableWidth =
                              MediaQuery.sizeOf(context).width - 32;
                          final actionExtentRatio = (120 / availableWidth)
                              .clamp(0.12, 0.42)
                              .toDouble();
                          final previous =
                              index == 0 ? null : items[index - 1].date;
                          final showMonthHeader = previous == null ||
                              previous.year != item.date.year ||
                              previous.month != item.date.month;
                          final showDayHeader =
                              showMonthHeader || previous.day != item.date.day;
                          final dailyExpense = dailyExpenses[DateTime(
                                item.date.year,
                                item.date.month,
                                item.date.day,
                              )] ??
                              0;
                          final compactDayHeader =
                              MediaQuery.sizeOf(context).width < 360 ||
                                  MediaQuery.textScalerOf(context).scale(1) >
                                      1.3;
                          final dayLabel = Text(
                            formatDate(context, item.date),
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                  fontWeight: FontWeight.w700,
                                ),
                          );
                          final dailyTotalLabel = Text(
                            '${l10n.totalSpent}: '
                            '${formatCurrency(context, dailyExpense)}',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                  fontWeight: FontWeight.w700,
                                ),
                          );

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (showMonthHeader)
                                Padding(
                                  key: ValueKey(
                                    'transaction-month-'
                                    '${item.date.year}-${item.date.month}',
                                  ),
                                  padding:
                                      const EdgeInsets.fromLTRB(4, 24, 4, 4),
                                  child: Text(
                                    formatMonthYear(context, item.date),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                ),
                              if (showDayHeader)
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(4, 10, 4, 6),
                                  child: compactDayHeader
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            dayLabel,
                                            const SizedBox(height: 2),
                                            dailyTotalLabel,
                                          ],
                                        )
                                      : Row(
                                          children: [
                                            Expanded(child: dayLabel),
                                            dailyTotalLabel,
                                          ],
                                        ),
                                ),
                              Slidable(
                                key: ValueKey(item.id),
                                endActionPane: ActionPane(
                                  motion: const BehindMotion(),
                                  extentRatio: actionExtentRatio,
                                  children: [
                                    CustomSlidableAction(
                                      key: ValueKey('history-edit-${item.id}'),
                                      onPressed: (_) => _edit(context, item),
                                      backgroundColor:
                                          colors.secondaryContainer,
                                      foregroundColor:
                                          colors.onSecondaryContainer,
                                      borderRadius:
                                          const BorderRadius.horizontal(
                                        left: Radius.circular(16),
                                      ),
                                      child: Tooltip(
                                        message: l10n.edit,
                                        excludeFromSemantics: true,
                                        child: Icon(
                                          Icons.edit_outlined,
                                          semanticLabel: l10n.edit,
                                        ),
                                      ),
                                    ),
                                    CustomSlidableAction(
                                      key: ValueKey(
                                        'history-delete-${item.id}',
                                      ),
                                      onPressed: (_) => _delete(context, item),
                                      backgroundColor: colors.error,
                                      foregroundColor: colors.onError,
                                      borderRadius:
                                          const BorderRadius.horizontal(
                                        right: Radius.circular(16),
                                      ),
                                      child: Tooltip(
                                        message: l10n.delete,
                                        excludeFromSemantics: true,
                                        child: Icon(
                                          Icons.delete_outline_rounded,
                                          semanticLabel: l10n.delete,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                child: TransactionTile(
                                  item: item,
                                  provider: provider,
                                  onTap: () => _edit(context, item),
                                ),
                              ),
                              const SizedBox(height: 1),
                            ],
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _edit(
    BuildContext context,
    FinanceTransaction item,
  ) async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditTransactionScreen(transaction: item),
      ),
    );
  }

  Future<void> _delete(
    BuildContext context,
    FinanceTransaction item,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDelete),
        content: Text(l10n.deleteTransactionMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: ButtonLabel(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: ButtonLabel(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final deleted =
        await context.read<FinanceProvider>().deleteTransaction(item);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          deleted ? l10n.transactionDeleted : l10n.saveFailed,
        ),
      ),
    );
  }

  void _setCurrentMonth() {
    final now = DateTime.now();
    setState(() {
      _dateRange = DateTimeRange(
        start: DateTime(now.year, now.month),
        end: DateTime(now.year, now.month + 1, 0),
      );
    });
  }

  Future<void> _pickDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100, 12, 31),
      initialDateRange: _dateRange,
    );
    if (range != null && mounted) setState(() => _dateRange = range);
  }

  String _dateRangeLabel(BuildContext context) {
    final range = _dateRange;
    if (range == null) return AppLocalizations.of(context).date;
    return '${formatDate(context, range.start)} - '
        '${formatDate(context, range.end)}';
  }
}

class _CategoryFilter extends StatelessWidget {
  const _CategoryFilter({
    required this.categories,
    required this.selectedId,
    required this.allLabel,
    required this.categoryLabel,
    required this.onChanged,
  });

  final List<Category> categories;
  final int? selectedId;
  final String allLabel;
  final String categoryLabel;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    var selected = categoryLabel;
    if (selectedId != null) {
      for (final category in categories) {
        if (category.id == selectedId) selected = category.name;
      }
    }
    return OutlinedButton.icon(
      onPressed: () => showModalBottomSheet<void>(
        context: context,
        builder: (context) => SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                title: Text(allLabel),
                selected: selectedId == null,
                onTap: () {
                  onChanged(null);
                  Navigator.pop(context);
                },
              ),
              for (final category in categories)
                ListTile(
                  title: Text(category.name),
                  selected: category.id == selectedId,
                  onTap: () {
                    onChanged(category.id);
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        ),
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 40),
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
      icon: const Icon(Icons.category_outlined, size: 18),
      label: Text(selected),
    );
  }
}
