import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/finance_provider.dart';
import '../utils/formatters.dart';
import '../widgets/button_label.dart';

class JarDepositScreen extends StatefulWidget {
  const JarDepositScreen({
    super.key,
    required this.jarId,
    this.initialDate,
  });

  final int jarId;
  final DateTime? initialDate;

  @override
  State<JarDepositScreen> createState() => _JarDepositScreenState();
}

class _JarDepositScreenState extends State<JarDepositScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _accountController = TextEditingController();
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    _date = widget.initialDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _accountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<FinanceProvider>();
    final jar = provider.jarById(widget.jarId);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.depositToJar)),
      body: SafeArea(
        top: false,
        child: jar == null
            ? Center(child: Text(l10n.jarUnavailable))
            : Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          children: [
                            Container(
                              width: 14,
                              height: 44,
                              decoration: BoxDecoration(
                                color: colorFromHex(jar.color),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    jar.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    l10n.availableBalance(
                                      jar.isBalanceHidden
                                          ? '••••••'
                                          : formatCurrency(
                                              context,
                                              jar.balance,
                                            ),
                                    ),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.savings_outlined,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSecondaryContainer,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                l10n.directDepositHint(jar.name),
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSecondaryContainer,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    TextFormField(
                      key: const ValueKey('jar-deposit-amount'),
                      controller: _amountController,
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      inputFormatters: [localizedMoneyInputFormatter(context)],
                      decoration: InputDecoration(
                        labelText: l10n.amount,
                        hintText: l10n.amountHint,
                        prefixIcon: const Icon(Icons.payments_outlined),
                        suffixText: '₫',
                      ),
                      validator: (value) {
                        final amount = parseMoney(value ?? '');
                        return amount == null || amount <= 0
                            ? l10n.invalidAmount
                            : null;
                      },
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(4),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: l10n.date,
                          prefixIcon: const Icon(Icons.calendar_today_outlined),
                        ),
                        child: Text(formatDate(context, _date)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _noteController,
                      textCapitalization: TextCapitalization.sentences,
                      maxLength: 120,
                      decoration: InputDecoration(
                        labelText: '${l10n.note} · ${l10n.optional}',
                        hintText: l10n.noteHint,
                        prefixIcon: const Icon(Icons.notes_rounded),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _accountController,
                      textCapitalization: TextCapitalization.words,
                      maxLength: 60,
                      decoration: InputDecoration(
                        labelText: '${l10n.accountSource} · ${l10n.optional}',
                        hintText: l10n.accountSourceHint,
                        prefixIcon:
                            const Icon(Icons.account_balance_wallet_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      key: const ValueKey('jar-deposit-save'),
                      onPressed: provider.isSaving ? null : _submit,
                      icon: provider.isSaving
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.add_rounded),
                      label: ButtonLabel(l10n.depositToJar),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final value = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100, 12, 31),
    );
    if (value != null && mounted) setState(() => _date = value);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);
    final amount = parseMoney(_amountController.text)!;
    final saved = await context.read<FinanceProvider>().addIncome(
      amount: amount,
      date: _date,
      note: _noteController.text,
      accountName: _accountController.text,
      allocations: {widget.jarId: amount},
    );
    if (!mounted) return;
    if (saved) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.saveFailed)),
      );
    }
  }
}
