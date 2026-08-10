import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/finance_transaction.dart';
import '../providers/finance_provider.dart';
import '../theme/finance_semantic_colors.dart';
import '../utils/formatters.dart';
import '../widgets/button_label.dart';
import '../widgets/empty_state.dart';
import '../widgets/jar_card.dart';
import '../widgets/month_picker.dart';
import '../widgets/transaction_tile.dart';
import 'budget_screen.dart';
import 'edit_transaction_screen.dart';
import 'goals_screen.dart';
import 'history_screen.dart';
import 'jar_detail_screen.dart';
import 'recurring_screen.dart';
import 'transaction_picker_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<FinanceProvider>();
    final periodTransactions = provider.periodTransactions;
    final recentTransactions = periodTransactions.take(5).toList();
    final recentRows = <Widget>[];
    DateTime? previousRecentDate;
    for (final item in recentTransactions) {
      final previousDate = previousRecentDate;
      final isNewDay = previousDate == null ||
          previousDate.year != item.date.year ||
          previousDate.month != item.date.month ||
          previousDate.day != item.date.day;
      if (isNewDay) {
        recentRows.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
            child: Text(
              formatDate(context, item.date),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        );
      }
      recentRows.add(
        TransactionTile(
          item: item,
          provider: provider,
          onTap: () => _editTransaction(context, item),
        ),
      );
      previousRecentDate = item.date;
    }

    return Scaffold(
      floatingActionButton: provider.isLoading
          ? null
          : FloatingActionButton(
              onPressed: () => _showAddMenu(context),
              tooltip: l10n.addTransaction,
              child: const Icon(Icons.add_rounded),
            ),
      body: SafeArea(
        child: provider.isLoading
            ? const _HomeLoading()
            : provider.error != null && provider.jars.isEmpty
                ? EmptyState(
                    icon: Icons.cloud_off_outlined,
                    title: l10n.somethingWentWrong,
                    body: l10n.localStorageBody,
                    action: FilledButton(
                      onPressed: provider.initialize,
                      child: ButtonLabel(l10n.retry),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: provider.refresh,
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
                          sliver: SliverList.list(
                            children: [
                              _AppHeader(provider: provider),
                              const SizedBox(height: 16),
                              _BalancePanel(provider: provider),
                              if (provider.pendingOccurrences.isNotEmpty) ...[
                                const SizedBox(height: 14),
                                _ActionBanner(
                                  icon: Icons.event_repeat_outlined,
                                  text: l10n.dueReminders(
                                    provider.pendingOccurrences.length,
                                  ),
                                  action: l10n.reviewNow,
                                  onTap: () => _push(
                                    context,
                                    const RecurringScreen(),
                                  ),
                                ),
                              ],
                              if (provider.budgetLimits.isNotEmpty) ...[
                                const SizedBox(height: 24),
                                _SectionHeader(
                                  title: l10n.budgetOverview,
                                  action: l10n.seeAll,
                                  onTap: () =>
                                      _push(context, const BudgetScreen()),
                                ),
                                const SizedBox(height: 10),
                                _BudgetOverview(provider: provider),
                              ],
                              const SizedBox(height: 28),
                              _SectionHeader(title: l10n.yourJars),
                              const SizedBox(height: 12),
                              _JarGrid(provider: provider),
                              if (provider.goals.isNotEmpty) ...[
                                const SizedBox(height: 28),
                                _SectionHeader(
                                  title: l10n.goalsProgress,
                                  action: l10n.seeAll,
                                  onTap: () =>
                                      _push(context, const GoalsScreen()),
                                ),
                                const SizedBox(height: 10),
                                for (final goal in provider.goals.take(2)) ...[
                                  _GoalProgressRow(
                                    name: goal.name,
                                    current: goal.currentAmount,
                                    target: goal.targetAmount,
                                    progress: goal.progress,
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ],
                              const SizedBox(height: 30),
                              _SectionHeader(
                                title: l10n.recentTransactions,
                                action: periodTransactions.isEmpty
                                    ? null
                                    : l10n.seeAll,
                                onTap: () => _push(
                                  context,
                                  const HistoryScreen(),
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (periodTransactions.isEmpty)
                                EmptyState(
                                  icon: Icons.receipt_long_outlined,
                                  title: l10n.noTransactions,
                                  body: l10n.noTransactionsBody,
                                )
                              else
                                ...recentRows,
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Future<void> _showAddMenu(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const TransactionPickerScreen()),
    );
    if (saved == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.savedSuccessfully)),
      );
    }
  }

  static void _push(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  static Future<void> _editTransaction(
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
}

class _AppHeader extends StatelessWidget {
  const _AppHeader({required this.provider});

  final FinanceProvider provider;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ExcludeSemantics(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.asset(
              'assets/branding/jmoney_app_mark.png',
              key: const ValueKey('jmoney-brand-mark'),
              width: 44,
              height: 44,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.appName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              Text(
                formatMonthYear(context, provider.currentPeriod),
                key: const ValueKey('home-period-label'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Material(
          color: colors.surfaceContainerHigh,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          child: IconButton(
            key: const ValueKey('home-calendar-button'),
            onPressed:
                provider.isChangingPeriod ? null : () => _showCalendar(context),
            tooltip: l10n.pickDate,
            icon: const Icon(Icons.calendar_month_rounded),
          ),
        ),
      ],
    );
  }

  Future<void> _showCalendar(BuildContext context) async {
    final selectedDate = await pickMonth(
      context,
      initialDate: provider.suggestedTransactionDate,
    );
    if (selectedDate == null || !context.mounted) return;
    await provider.selectPeriod(selectedDate);
  }
}

class _ActionBanner extends StatelessWidget {
  const _ActionBanner({
    required this.icon,
    required this.text,
    required this.action,
    required this.onTap,
  });

  final IconData icon;
  final String text;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.tertiaryContainer,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Row(
          children: [
            Icon(icon, color: colors.onTertiaryContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: colors.onTertiaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(onPressed: onTap, child: ButtonLabel(action)),
          ],
        ),
      ),
    );
  }
}

class _BudgetOverview extends StatelessWidget {
  const _BudgetOverview({required this.provider});

  final FinanceProvider provider;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            for (var index = 0;
                index < provider.budgetLimits.length && index < 3;
                index++) ...[
              Builder(
                builder: (context) {
                  final limit = provider.budgetLimits[index];
                  final jar = provider.jarById(limit.jarId);
                  final progress = limit.jarId == null
                      ? const BudgetProgress(
                          planned: 0,
                          spent: 0,
                          remaining: 0,
                          dailyAllowance: 0,
                        )
                      : provider.budgetProgressForJar(limit.jarId!);
                  final ratio = progress.planned <= 0
                      ? 0.0
                      : (progress.spent / progress.planned)
                          .clamp(0, 1)
                          .toDouble();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              jar?.name ?? l10n.unknownJar,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                          Text('${(ratio * 100).round()}%'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: ratio,
                        minHeight: 7,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        l10n.dailyAllowance(
                          formatCurrency(context, progress.dailyAllowance),
                        ),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  );
                },
              ),
              if (index < provider.budgetLimits.length - 1 && index < 2)
                const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }
}

class _GoalProgressRow extends StatelessWidget {
  const _GoalProgressRow({
    required this.name,
    required this.current,
    required this.target,
    required this.progress,
  });

  final String name;
  final int current;
  final int target;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                Text('${(progress * 100).round()}%'),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 6),
            Text(
              '${formatCurrency(context, current)} / '
              '${formatCurrency(context, target)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _BalancePanel extends StatelessWidget {
  const _BalancePanel({required this.provider});

  final FinanceProvider provider;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final financeColors = Theme.of(context).extension<FinanceSemanticColors>()!;
    const ledgerSurface = Color(0xFF201D1D);
    const foreground = Color(0xFFFDFCFC);
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ledgerSurface,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.totalBalance,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: foreground.withValues(alpha: 0.68),
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 5),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                formatCurrency(context, provider.totalBalance),
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1,
                    ),
              ),
            ),
            const SizedBox(height: 20),
            if (textScale > 1.3) ...[
              _MonthlyMetric(
                icon: Icons.south_west_rounded,
                label: l10n.income,
                value: provider.currentMonthIncome,
                color: financeColors.income,
              ),
              const SizedBox(height: 12),
              const SizedBox(height: 12),
              _MonthlyMetric(
                icon: Icons.north_east_rounded,
                label: l10n.expense,
                value: provider.currentMonthExpense,
                color: colors.error,
              ),
            ] else
              Row(
                children: [
                  Expanded(
                    child: _MonthlyMetric(
                      icon: Icons.south_west_rounded,
                      label: l10n.income,
                      value: provider.currentMonthIncome,
                      color: financeColors.income,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 44,
                    color: foreground.withValues(alpha: 0.18),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _MonthlyMetric(
                      icon: Icons.north_east_rounded,
                      label: l10n.expense,
                      value: provider.currentMonthExpense,
                      color: colors.error,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _MonthlyMetric extends StatelessWidget {
  const _MonthlyMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.72),
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  formatCompactCurrency(context, value),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _JarGrid extends StatelessWidget {
  const _JarGrid({required this.provider});

  final FinanceProvider provider;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textScale = MediaQuery.textScalerOf(context).scale(1);
        final usesAccessibleList = textScale > 1.3;
        final columns = usesAccessibleList
            ? 1
            : constraints.maxWidth >= 900
                ? 4
                : constraints.maxWidth >= 600
                    ? 3
                    : 2;
        final itemWidth = (constraints.maxWidth - (columns - 1) * 12) / columns;
        final childAspectRatio = usesAccessibleList
            ? (itemWidth / 152).clamp(1.6, 2.4).toDouble()
            : (itemWidth / 128).clamp(1.08, 1.85).toDouble();
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: provider.jars.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: childAspectRatio,
          ),
          itemBuilder: (context, index) => JarCard(
            jar: provider.jars[index],
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => JarDetailScreen(
                  jarId: provider.jars[index].id!,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.action,
    this.onTap,
  });

  final String title;
  final String? action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final titleText = Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
    );
    if (MediaQuery.textScalerOf(context).scale(1) > 1.3) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleText,
          if (action != null)
            TextButton(
              onPressed: onTap,
              child: ButtonLabel(action!),
            ),
        ],
      );
    }
    return Row(
      children: [
        Expanded(child: titleText),
        if (action != null)
          TextButton(
            onPressed: onTap,
            child: ButtonLabel(action!),
          ),
      ],
    );
  }
}

class _HomeLoading extends StatelessWidget {
  const _HomeLoading();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 28),
        Container(height: 24, width: 180, color: color),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            for (var index = 0; index < 4; index++)
              DecoratedBox(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
