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
                            l10n.totalSpent,
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
                  for (final transaction in transactions)
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
              ),
      ),
    );
  }
}
