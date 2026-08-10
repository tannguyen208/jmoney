import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/category.dart';
import '../models/jar.dart';
import '../providers/finance_provider.dart';
import '../theme/finance_semantic_colors.dart';
import '../utils/formatters.dart';
import '../widgets/category_icon.dart';
import '../widgets/empty_state.dart';
import 'add_expense_screen.dart';
import 'add_income_screen.dart';
import 'transfer_screen.dart';

class TransactionPickerScreen extends StatelessWidget {
  const TransactionPickerScreen({
    super.key,
    this.categorySelectionJarId,
    this.categorySelectionType,
    this.categorySelectionAllowWholeJar = false,
    this.categorySelectionWholeJarLabel,
  });

  final int? categorySelectionJarId;
  final CategoryType? categorySelectionType;
  final bool categorySelectionAllowWholeJar;
  final String? categorySelectionWholeJarLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (categorySelectionType != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            categorySelectionType == CategoryType.income
                ? l10n.chooseIncomeCategory
                : l10n.chooseExpenseCategory,
          ),
        ),
        body: SafeArea(
          top: false,
          child: categorySelectionType == CategoryType.income
              ? const _IncomeEntryList(selectionOnly: true)
              : _ExpenseCategoryList(
                  selectionJarId: categorySelectionJarId,
                  allowWholeJar: categorySelectionAllowWholeJar,
                  wholeJarLabel: categorySelectionWholeJarLabel,
                ),
        ),
      );
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.addTransaction),
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.moneyOut),
              Tab(text: l10n.moneyIn),
              Tab(text: l10n.transferTransaction),
            ],
          ),
        ),
        body: const SafeArea(
          top: false,
          child: TabBarView(
            children: [
              _ExpenseCategoryList(),
              _IncomeEntryList(),
              _TransferJarList(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpenseCategoryList extends StatelessWidget {
  const _ExpenseCategoryList({
    this.selectionJarId,
    this.allowWholeJar = false,
    this.wholeJarLabel,
  });

  final int? selectionJarId;
  final bool allowWholeJar;
  final String? wholeJarLabel;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FinanceProvider>();
    final l10n = AppLocalizations.of(context);
    final sharedCategories = provider.expenseCategories
        .where((category) => category.jarId == null)
        .toList();
    final sections = <Widget>[
      if (allowWholeJar)
        ListTile(
          key: const ValueKey('transaction-category-whole-jar'),
          leading: const Icon(Icons.all_inclusive_rounded),
          title: Text(wholeJarLabel ?? l10n.wholeJar),
          onTap: () => Navigator.pop(context, -1),
        ),
      for (final jar in provider.jars)
        if (selectionJarId == null || selectionJarId == jar.id)
          if (provider.expenseCategories
              .any((category) => category.jarId == jar.id)) ...[
            _SectionLabel(
              label: jar.name,
              color: colorFromHex(jar.color),
            ),
            _PickerGroup(
              children: [
                for (final category in provider.expenseCategories.where(
                  (category) => category.jarId == jar.id,
                ))
                  _CategoryTile(
                    category: category,
                    color: colorFromHex(jar.color),
                    onTap: () => _openExpense(
                      context,
                      category: category,
                      jar: jar,
                    ),
                  ),
              ],
            ),
          ],
      if (sharedCategories.isNotEmpty) ...[
        _SectionLabel(
          label: l10n.allJars,
          color: Theme.of(context).colorScheme.primary,
        ),
        _PickerGroup(
          children: [
            for (final category in sharedCategories)
              _CategoryTile(
                category: category,
                color: Theme.of(context).colorScheme.primary,
                onTap: () => _openExpense(context, category: category),
              ),
          ],
        ),
      ],
    ];

    if (provider.expenseCategories.isEmpty) {
      return EmptyState(
        icon: Icons.category_outlined,
        title: l10n.noCategories,
        body: l10n.noCategoriesBody,
      );
    }

    return ListView(
      key: const PageStorageKey('expense-category-picker'),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        // Text(
        //   l10n.chooseExpenseCategory,
        //   style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        //         color: Theme.of(context).colorScheme.onSurfaceVariant,
        //       ),
        // ),
        // const SizedBox(height: 8),
        ...sections,
      ],
    );
  }

  Future<void> _openExpense(
    BuildContext context, {
    required Category category,
    Jar? jar,
  }) async {
    if (selectionJarId != null) {
      Navigator.pop(context, category.id);
      return;
    }
    final provider = context.read<FinanceProvider>();
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddExpenseScreen(
          initialJarId: jar?.id,
          initialCategoryId: category.id,
          initialDate: provider.suggestedTransactionDate,
        ),
      ),
    );
    if (saved == true && context.mounted) Navigator.pop(context, true);
  }
}

class _IncomeEntryList extends StatelessWidget {
  const _IncomeEntryList({this.selectionOnly = false});

  final bool selectionOnly;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FinanceProvider>();
    final l10n = AppLocalizations.of(context);
    final financeColors = Theme.of(context).extension<FinanceSemanticColors>()!;
    if (provider.incomeCategories.isEmpty) {
      return EmptyState(
        icon: Icons.south_west_rounded,
        title: l10n.noIncomeCategories,
        body: l10n.noIncomeCategoriesBody,
      );
    }
    return ListView(
      key: const PageStorageKey('income-entry-picker'),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        Text(
          l10n.chooseIncomeCategory,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 8),
        _PickerGroup(
          children: [
            for (final category in provider.incomeCategories)
              _CategoryTile(
                category: category,
                color: financeColors.income,
                onTap: () => _openIncome(context, category),
              ),
          ],
        ),
      ],
    );
  }

  Future<void> _openIncome(
    BuildContext context,
    Category category,
  ) async {
    if (selectionOnly) {
      Navigator.pop(context, category.id);
      return;
    }
    final provider = context.read<FinanceProvider>();
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddIncomeScreen(
          initialDate: provider.suggestedTransactionDate,
          initialCategoryId: category.id,
        ),
      ),
    );
    if (saved == true && context.mounted) Navigator.pop(context, true);
  }
}

class _TransferJarList extends StatelessWidget {
  const _TransferJarList();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FinanceProvider>();
    final l10n = AppLocalizations.of(context);
    final financeColors = Theme.of(context).extension<FinanceSemanticColors>()!;
    if (provider.jars.length < 2) {
      return EmptyState(
        icon: Icons.swap_horiz_rounded,
        title: l10n.notEnoughJars,
        body: l10n.notEnoughJarsBody,
      );
    }
    return ListView(
      key: const PageStorageKey('transfer-jar-picker'),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        Text(
          l10n.chooseSourceJar,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 8),
        _PickerGroup(
          children: [
            for (final jar in provider.jars)
              ListTile(
                key: ValueKey('transfer-source-jar-${jar.id}'),
                minTileHeight: 64,
                leading: _LeadingSymbol(
                  color: colorFromHex(jar.color),
                  child: const KoboyoAssetIcon(
                    asset: JMoneyIconAssets.jar,
                    size: 29,
                  ),
                ),
                title: Text(
                  jar.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  formatCurrency(context, jar.balance),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: financeColors.transfer,
                ),
                onTap: () => _openTransfer(context, jar),
              ),
          ],
        ),
      ],
    );
  }

  Future<void> _openTransfer(BuildContext context, Jar jar) async {
    final provider = context.read<FinanceProvider>();
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => TransferScreen(
          initialDate: provider.suggestedTransactionDate,
          initialSourceJarId: jar.id,
        ),
      ),
    );
    if (saved == true && context.mounted) Navigator.pop(context, true);
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PickerGroup extends StatelessWidget {
  const _PickerGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(4),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var index = 0; index < children.length; index++) ...[
            children[index],
            if (index != children.length - 1) const SizedBox(height: 1),
          ],
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.color,
    required this.onTap,
  });

  final Category category;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: ValueKey('transaction-category-${category.id}'),
      minTileHeight: 64,
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.14),
        child: CategoryIcon(
          category: category,
          size: 30,
          fallbackColor: color,
        ),
      ),
      title: Text(
        category.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}

class _LeadingSymbol extends StatelessWidget {
  const _LeadingSymbol({required this.child, required this.color});

  final Widget child;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}
