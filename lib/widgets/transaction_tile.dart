import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/finance_transaction.dart';
import '../providers/finance_provider.dart';
import '../theme/finance_semantic_colors.dart';
import '../utils/formatters.dart';
import 'category_icon.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.item,
    required this.provider,
    this.onTap,
  });

  final FinanceTransaction item;
  final FinanceProvider provider;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isIncome = item.type == TransactionType.income;
    final isTransfer = item.type == TransactionType.transfer;
    final category = provider.categoryById(item.categoryId);
    final jar = provider.jarById(item.jarId);
    final destination = provider.jarById(item.destinationJarId);
    final title = isIncome
        ? category?.name ?? l10n.incomeTransaction
        : isTransfer
            ? l10n.transferTransaction
            : category?.name ?? l10n.unknownCategory;
    final subtitle = isIncome
        ? l10n.automaticAllocation
        : isTransfer
            ? l10n.fromTo(
                jar?.name ?? l10n.unknownJar,
                destination?.name ?? l10n.unknownJar,
              )
            : null;
    final colors = Theme.of(context).colorScheme;
    final financeColors = Theme.of(context).extension<FinanceSemanticColors>()!;
    final color = isIncome
        ? financeColors.income
        : isTransfer
            ? financeColors.transfer
            : colors.error;

    final amountLabel = '${isIncome ? '+' : isTransfer ? '' : '−'}'
        '${formatCurrency(context, item.amount)}';
    final useStackedAmount = MediaQuery.textScalerOf(context).scale(1) > 1.3;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Card(
        child: ListTile(
          onTap: onTap,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          leading: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(4),
            ),
            child: isIncome
                ? category == null
                    ? const KoboyoAssetIcon(
                        asset: JMoneyIconAssets.income, size: 29)
                    : CategoryIcon(category: category, size: 29)
                : isTransfer
                    ? const KoboyoAssetIcon(
                        asset: JMoneyIconAssets.transfer, size: 29)
                    : category == null
                        ? const KoboyoAssetIcon(
                            asset: JMoneyIconAssets.expense, size: 29)
                        : CategoryIcon(category: category, size: 29),
          ),
          title: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (subtitle != null ||
                  item.accountName != null ||
                  item.note != null)
                Text(
                  [
                    if (subtitle != null) subtitle,
                    if (item.accountName != null) item.accountName,
                    if (item.note != null) item.note,
                  ].join(' · '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              if (useStackedAmount)
                Text(
                  amountLabel,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(color: color, fontWeight: FontWeight.w800),
                ),
            ],
          ),
          trailing: useStackedAmount
              ? null
              : ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 136),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      amountLabel,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(color: color, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
