import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/finance_transaction.dart';
import '../models/jar.dart';
import '../models/jar_activity.dart';
import '../providers/finance_provider.dart';
import '../theme/finance_semantic_colors.dart';
import '../utils/formatters.dart';
import '../widgets/button_label.dart';
import '../widgets/category_icon.dart';
import '../widgets/empty_state.dart';
import 'add_expense_screen.dart';
import 'edit_transaction_screen.dart';
import 'jar_deposit_screen.dart';

class JarDetailScreen extends StatelessWidget {
  const JarDetailScreen({super.key, required this.jarId});

  final int jarId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<FinanceProvider>();
    final jar = provider.jarById(jarId);
    if (jar == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.jarUnavailable)),
      );
    }
    final activities = provider.activitiesForJar(jarId);

    return Scaffold(
      appBar: AppBar(title: Text(jar.name)),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: provider.refresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                sliver: SliverList.list(
                  children: [
                    _JarHero(jar: jar),
                    const SizedBox(height: 14),
                    _JarActions(
                      onExpense: () => _openExpense(context),
                      onDeposit: () => _openDeposit(context),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      l10n.jarActivity,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
              if (activities.isEmpty)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 36),
                  sliver: SliverToBoxAdapter(
                    child: EmptyState(
                      icon: Icons.timeline_rounded,
                      title: l10n.noJarActivity,
                      body: l10n.noJarActivityBody,
                    ),
                  ),
                )
              else
                _ActivityTimeline(
                  activities: activities,
                  onEdit: (transaction) =>
                      _editTransaction(context, transaction),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openExpense(BuildContext context) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddExpenseScreen(
          initialJarId: jarId,
          lockJarSelection: true,
          initialDate: context.read<FinanceProvider>().suggestedTransactionDate,
        ),
      ),
    );
    if (saved == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).savedSuccessfully)),
      );
    }
  }

  Future<void> _openDeposit(BuildContext context) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => JarDepositScreen(
          jarId: jarId,
          initialDate: context.read<FinanceProvider>().suggestedTransactionDate,
        ),
      ),
    );
    if (saved == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).savedSuccessfully)),
      );
    }
  }

  Future<void> _editTransaction(
    BuildContext context,
    FinanceTransaction transaction,
  ) async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditTransactionScreen(transaction: transaction),
      ),
    );
  }
}

class _JarHero extends StatelessWidget {
  const _JarHero({required this.jar});

  final Jar jar;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final jarColor = colorFromHex(jar.color);
    return Card(
      color: Color.alphaBlend(
        jarColor.withValues(alpha: 0.10),
        const Color(0xF2FFFFFF),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: jarColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    jar.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                const SizedBox(width: 10),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Text(
                      '${jar.percentage.toStringAsFixed(jar.percentage % 1 == 0 ? 0 : 1)}%',
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (jar.description?.trim().isNotEmpty == true) ...[
              const SizedBox(height: 10),
              Text(
                jar.description!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                      height: 1.4,
                    ),
              ),
            ],
            const SizedBox(height: 24),
            Text(
              l10n.currentBalance,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 5),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                jar.isBalanceHidden
                    ? '••••••'
                    : formatCurrency(context, jar.balance),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.7,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JarActions extends StatelessWidget {
  const _JarActions({required this.onExpense, required this.onDeposit});

  final VoidCallback onExpense;
  final VoidCallback onDeposit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final vertical = constraints.maxWidth < 340;
        final expense = FilledButton.icon(
          onPressed: onExpense,
          icon: const Icon(Icons.north_east_rounded),
          label: ButtonLabel(l10n.addExpense),
        );
        final deposit = FilledButton.tonalIcon(
          onPressed: onDeposit,
          icon: const Icon(Icons.south_west_rounded),
          label: ButtonLabel(l10n.depositToJar),
        );
        if (vertical) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [expense, const SizedBox(height: 10), deposit],
          );
        }
        return Row(
          children: [
            Expanded(child: expense),
            const SizedBox(width: 10),
            Expanded(child: deposit),
          ],
        );
      },
    );
  }
}

class _ActivityTimeline extends StatelessWidget {
  const _ActivityTimeline({
    required this.activities,
    required this.onEdit,
  });

  final List<JarActivity> activities;
  final ValueChanged<FinanceTransaction> onEdit;

  @override
  Widget build(BuildContext context) {
    final dailyExpenses = <DateTime, int>{};
    for (final activity in activities) {
      if (activity.type != JarActivityType.expense) continue;
      final day = DateUtils.dateOnly(activity.transaction.date);
      dailyExpenses[day] = (dailyExpenses[day] ?? 0) + activity.delta.abs();
    }
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 36),
      sliver: SliverList.builder(
        itemCount: activities.length,
        itemBuilder: (context, index) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_startsMonth(index))
              Padding(
                padding: EdgeInsets.fromLTRB(4, index == 0 ? 0 : 4, 4, 8),
                child: Text(
                  formatMonthYear(
                    context,
                    activities[index].transaction.date,
                  ),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            if (_startsDay(index))
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        formatDate(context, activities[index].transaction.date),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                    Icon(
                      Icons.north_east_rounded,
                      size: 14,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      formatCurrency(
                          context,
                          dailyExpenses[DateUtils.dateOnly(
                                activities[index].transaction.date,
                              )] ??
                              0),
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            Card(
              child: InkWell(
                onTap: () => onEdit(activities[index].transaction),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _ActivityRow(
                    activity: activities[index],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  bool _startsMonth(int index) {
    if (index == 0) return true;
    final current = activities[index].transaction.date;
    final previous = activities[index - 1].transaction.date;
    return current.year != previous.year || current.month != previous.month;
  }

  bool _startsDay(int index) {
    if (index == 0) return true;
    final current = activities[index].transaction.date;
    final previous = activities[index - 1].transaction.date;
    return current.year != previous.year ||
        current.month != previous.month ||
        current.day != previous.day;
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.activity});

  final JarActivity activity;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.read<FinanceProvider>();
    final colors = Theme.of(context).colorScheme;
    final financeColors = Theme.of(context).extension<FinanceSemanticColors>()!;
    final transaction = activity.transaction;
    final category = provider.categoryById(transaction.categoryId);
    final sourceJar = provider.jarById(transaction.jarId);
    final destinationJar = provider.jarById(transaction.destinationJarId);
    final color = switch (activity.type) {
      JarActivityType.income => financeColors.income,
      JarActivityType.expense => colors.error,
      JarActivityType.transferIn ||
      JarActivityType.transferOut =>
        financeColors.transfer,
    };
    final icon = switch (activity.type) {
      JarActivityType.income => Icons.south_west_rounded,
      JarActivityType.expense => Icons.north_east_rounded,
      JarActivityType.transferIn => Icons.call_received_rounded,
      JarActivityType.transferOut => Icons.call_made_rounded,
    };
    final title = switch (activity.type) {
      JarActivityType.income => category?.name ?? l10n.jarIncomeActivity,
      JarActivityType.expense =>
        category == null ? l10n.jarExpenseActivity : category.name,
      JarActivityType.transferIn => sourceJar == null
          ? l10n.jarTransferInActivity
          : l10n.jarTransferInFromActivity(sourceJar.name),
      JarActivityType.transferOut => destinationJar == null
          ? l10n.jarTransferOutActivity
          : l10n.jarTransferOutToActivity(destinationJar.name),
    };
    final amount = '${activity.delta > 0 ? '+' : '−'}'
        '${formatCurrency(context, activity.delta.abs())}';
    final stackAmount = MediaQuery.sizeOf(context).width < 360;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withValues(alpha: 0.12),
            foregroundColor: color,
            child: activity.type == JarActivityType.income
                ? category == null
                    ? const KoboyoAssetIcon(
                        asset: JMoneyIconAssets.income,
                        size: 29,
                      )
                    : CategoryIcon(category: category, size: 29)
                : activity.type == JarActivityType.expense
                    ? category == null
                        ? const KoboyoAssetIcon(
                            asset: JMoneyIconAssets.expense,
                            size: 29,
                          )
                        : CategoryIcon(category: category, size: 29)
                    : Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const KoboyoAssetIcon(
                            asset: JMoneyIconAssets.transfer,
                            size: 28,
                          ),
                          PositionedDirectional(
                            end: -4,
                            bottom: -4,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(2),
                                child: Icon(
                                  icon,
                                  size: 11,
                                  color: colors.onPrimary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (stackAmount) ...[
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    amount,
                    style: TextStyle(color: color, fontWeight: FontWeight.w800),
                  ),
                ] else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        amount,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                if (transaction.note?.trim().isNotEmpty == true) ...[
                  const SizedBox(height: 4),
                  Text(
                    transaction.note!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
