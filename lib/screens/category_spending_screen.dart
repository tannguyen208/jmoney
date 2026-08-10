import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/finance_transaction.dart';
import '../models/spending_summary.dart';
import '../providers/finance_provider.dart';
import '../utils/formatters.dart';
import '../widgets/empty_state.dart';
import '../widgets/transaction_tile.dart';
import 'edit_transaction_screen.dart';

class CategorySpendingScreen extends StatelessWidget {
  const CategorySpendingScreen({
    super.key,
    required this.summary,
  });

  final SpendingSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<FinanceProvider>();
    final transactions = provider.periodTransactions
        .where(
          (item) =>
              item.type == TransactionType.expense &&
              item.categoryId == summary.id,
        )
        .toList();
    final groupedTransactions = <DateTime, List<FinanceTransaction>>{};
    for (final transaction in transactions) {
      final day = DateUtils.dateOnly(transaction.date);
      groupedTransactions.putIfAbsent(day, () => []).add(transaction);
    }

    return Scaffold(
      appBar: AppBar(title: Text(summary.label)),
      body: SafeArea(
        top: false,
        child: transactions.isEmpty
            ? EmptyState(
                icon: Icons.receipt_long_outlined,
                title: l10n.noTransactions,
                body: l10n.noTransactionsBody,
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.total,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatCurrency(context, summary.amount),
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  for (final entry in groupedTransactions.entries) ...[
                    Builder(
                      builder: (context) {
                        final colors = Theme.of(context).colorScheme;
                        final dailyTotal = entry.value
                            .fold<int>(0, (sum, item) => sum + item.amount);
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(4, 8, 4, 6),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  formatDate(context, entry.key),
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge
                                      ?.copyWith(
                                          color: colors.onSurfaceVariant,
                                          fontWeight: FontWeight.w700),
                                ),
                              ),
                              Icon(Icons.north_east_rounded,
                                  size: 14, color: colors.error),
                              const SizedBox(width: 3),
                              Text(
                                formatCurrency(context, dailyTotal),
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    for (final transaction in entry.value)
                      TransactionTile(
                        item: transaction,
                        provider: provider,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditTransactionScreen(
                              transaction: transaction,
                            ),
                          ),
                        ),
                      ),
                  ],
                ],
              ),
      ),
    );
  }
}
