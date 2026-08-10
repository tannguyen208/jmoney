import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../providers/finance_provider.dart';
import '../utils/formatters.dart';
import 'button_label.dart';

class MonthNavigator extends StatelessWidget {
  const MonthNavigator({
    super.key,
    required this.provider,
    this.keyPrefix = 'month',
  });

  final FinanceProvider provider;
  final String keyPrefix;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final period = provider.currentPeriod;
    final monthLabel = AnimatedSwitcher(
      duration:
          disableAnimations ? Duration.zero : const Duration(milliseconds: 180),
      switchInCurve: Curves.easeOutCubic,
      child: Text(
        formatMonthYear(context, period),
        key: ValueKey('${period.year}-${period.month}'),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.w800),
      ),
    );
    return Material(
      color: colors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(4),
      clipBehavior: Clip.antiAlias,
      child: Semantics(
        container: true,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    key: ValueKey('$keyPrefix-previous'),
                    onPressed: provider.isChangingPeriod
                        ? null
                        : provider.selectPreviousMonth,
                    tooltip: l10n.previousMonth,
                    icon: const Icon(Icons.chevron_left_rounded),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: monthLabel,
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    key: ValueKey('$keyPrefix-next'),
                    onPressed: provider.isChangingPeriod
                        ? null
                        : provider.selectNextMonth,
                    tooltip: l10n.nextMonth,
                    icon: const Icon(Icons.chevron_right_rounded),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 1),
            TextButton.icon(
              key: ValueKey('$keyPrefix-current'),
              onPressed: provider.isCurrentPeriod || provider.isChangingPeriod
                  ? null
                  : provider.selectCurrentMonth,
              icon: const Icon(Icons.today_rounded, size: 18),
              label: ButtonLabel(l10n.thisMonth),
            ),
            if (provider.isChangingPeriod)
              const LinearProgressIndicator(minHeight: 2),
          ],
        ),
      ),
    );
  }
}
