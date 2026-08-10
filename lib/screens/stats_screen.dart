import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/finance_provider.dart';
import '../utils/formatters.dart';
import '../widgets/category_icon.dart';
import '../widgets/empty_state.dart';
import '../widgets/month_picker.dart';
import 'category_spending_screen.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<FinanceProvider>();
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final summaries = provider.spendingByCategory;
    final total = summaries.fold<int>(0, (sum, item) => sum + item.amount);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.statsTitle),
            Text(
              formatMonthYear(context, provider.currentPeriod),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
            ),
          ],
        ),
        actions: [
          IconButton(
            key: const ValueKey('stats-calendar-button'),
            onPressed: provider.isChangingPeriod
                ? null
                : () => _showCalendar(context, provider),
            tooltip: l10n.pickDate,
            icon: const Icon(Icons.calendar_month_rounded),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: provider.refresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              if (summaries.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    icon: Icons.donut_large_outlined,
                    title: l10n.noStats,
                    body: l10n.noStatsBody,
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                  sliver: SliverList.list(
                    children: [
                      _StatsHeader(total: total),
                      const SizedBox(height: 28),
                      Semantics(
                        label: l10n.spendingByCategory,
                        child: SizedBox(
                          height: 250,
                          child: PieChart(
                            PieChartData(
                              centerSpaceRadius: 54,
                              sectionsSpace: 3,
                              startDegreeOffset: -90,
                              sections: [
                                for (var index = 0;
                                    index < summaries.length;
                                    index++)
                                  PieChartSectionData(
                                    value: summaries[index].amount.toDouble(),
                                    color: _summaryColor(
                                      summaries[index].color,
                                      index,
                                    ),
                                    radius: 72,
                                    showTitle: total > 0 &&
                                        summaries[index].amount / total >= 0.08,
                                    title:
                                        '${(summaries[index].amount / total * 100).round()}%',
                                    titleStyle: TextStyle(
                                      color: _onSummaryColor(
                                        _summaryColor(
                                          summaries[index].color,
                                          index,
                                        ),
                                      ),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                            duration: disableAnimations
                                ? Duration.zero
                                : const Duration(milliseconds: 220),
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        l10n.spendingByCategory,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 12),
                      for (var index = 0;
                          index < summaries.length;
                          index++) ...[
                        _LegendRow(
                          icon: summaries[index].icon,
                          label: summaries[index].label,
                          amount: summaries[index].amount,
                          percentage: total == 0
                              ? 0
                              : summaries[index].amount / total * 100,
                          color: _summaryColor(
                            summaries[index].color,
                            index,
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CategorySpendingScreen(
                                summary: summaries[index],
                              ),
                            ),
                          ),
                        ),
                        if (index < summaries.length - 1)
                          const SizedBox(height: 24),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showCalendar(
    BuildContext context,
    FinanceProvider provider,
  ) async {
    final selectedDate = await pickMonth(
      context,
      initialDate: provider.currentPeriod,
    );
    if (selectedDate == null || !context.mounted) return;
    await provider.selectPeriod(selectedDate);
  }

  static Color _summaryColor(String? value, int index) {
    const palette = [
      Color(0xFF007AFF),
      Color(0xFF34C759),
      Color(0xFFFF9500),
      Color(0xFFAF52DE),
      Color(0xFFFF2D55),
      Color(0xFF5AC8FA),
    ];
    return colorFromHex(value, fallback: palette[index % palette.length]);
  }

  static Color _onSummaryColor(Color background) {
    return background.computeLuminance() > 0.179 ? Colors.black : Colors.white;
  }
}

class _StatsHeader extends StatelessWidget {
  const _StatsHeader({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.totalSpent,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: colors.error,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              child: Text(
                formatCurrency(context, total),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.icon,
    required this.label,
    required this.amount,
    required this.percentage,
    required this.color,
    required this.onTap,
  });

  final String? icon;
  final String label;
  final int amount;
  final double percentage;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final amountLabel = Text(
      formatCurrency(context, amount),
      style: const TextStyle(fontWeight: FontWeight.w700),
    );
    final category = Row(
      children: [
        Container(
          width: 12,
          height: 36,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 12),
        _SummaryIcon(icon: icon),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ],
    );

    return InkWell(
      onTap: onTap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stacked = MediaQuery.textScalerOf(context).scale(1) > 1.3 ||
              constraints.maxWidth < 360;
          if (stacked) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                category,
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: FittedBox(fit: BoxFit.scaleDown, child: amountLabel),
                ),
              ],
            );
          }
          return Row(
            children: [
              Expanded(child: category),
              const SizedBox(width: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 150),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: amountLabel,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryIcon extends StatelessWidget {
  const _SummaryIcon({required this.icon});

  final String? icon;

  @override
  Widget build(BuildContext context) {
    final asset = categoryIconAsset(icon);
    if (asset != null) {
      return KoboyoAssetIcon(
        asset: asset,
        size: 22.4,
        horizontalScale: categoryIconHorizontalScale(icon),
      );
    }
    final fallback = icon?.trim();
    if (fallback != null && fallback.isNotEmpty) {
      return Text(fallback, style: const TextStyle(fontSize: 22));
    }
    return Icon(
      Icons.category_outlined,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      size: 24,
    );
  }
}
