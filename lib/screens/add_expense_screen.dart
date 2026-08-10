import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/finance_provider.dart';
import '../utils/formatters.dart';
import '../widgets/button_label.dart';
import '../widgets/expense_category_field.dart';
import '../widgets/selection_field.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({
    super.key,
    this.initialJarId,
    this.initialCategoryId,
    this.lockJarSelection = false,
    this.initialDate,
  });

  final int? initialJarId;
  final int? initialCategoryId;
  final bool lockJarSelection;
  final DateTime? initialDate;

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _accountController = TextEditingController();
  int? _jarId;
  int? _categoryId;
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    _jarId = widget.initialJarId;
    _categoryId = widget.initialCategoryId;
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
    final initialCategory = provider.categoryById(_categoryId);
    final categories = _jarId == null
        ? [if (initialCategory != null) initialCategory]
        : provider.categoriesForJar(_jarId!);
    final selectedJar = provider.jarById(_jarId);
    final amount = parseMoney(_amountController.text) ?? 0;
    final progress =
        _jarId == null ? null : provider.budgetProgressForJar(_jarId!);
    final projectedRatio = progress == null || progress.planned <= 0
        ? 0.0
        : (progress.spent + amount) / progress.planned;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.addExpense)),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              TextFormField(
                key: const ValueKey('expense-amount'),
                controller: _amountController,
                autofocus: true,
                keyboardType: TextInputType.number,
                inputFormatters: [localizedMoneyInputFormatter(context)],
                onChanged: (_) => setState(() {}),
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
              if (progress != null &&
                  progress.planned > 0 &&
                  projectedRatio >= 0.7) ...[
                const SizedBox(height: 12),
                _BudgetWarning(
                  text: projectedRatio > 1
                      ? l10n.overBudget
                      : projectedRatio >= 0.9
                          ? l10n.budgetWarning90
                          : l10n.budgetWarning70,
                  isOver: projectedRatio > 1,
                ),
              ],
              const SizedBox(height: 16),
              if (widget.lockJarSelection && selectedJar != null)
                InputDecorator(
                  decoration: InputDecoration(
                    labelText: l10n.selectJar,
                    prefixIcon: const Icon(Icons.savings_outlined),
                  ),
                  child: Text(
                    selectedJar.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                )
              else
                SelectionField<int?>(
                  key: const ValueKey('expense-jar-select'),
                  value: _jarId,
                  decoration: InputDecoration(
                    labelText: l10n.selectJar,
                    prefixIcon: const Icon(Icons.savings_outlined),
                  ),
                  options: [
                    for (final jar in provider.jars)
                      SelectionOption(
                        value: jar.id,
                        label: jar.name,
                      ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _jarId = value;
                      final selectedCategory =
                          provider.categoryById(_categoryId);
                      if (selectedCategory != null &&
                          selectedCategory.jarId != null &&
                          selectedCategory.jarId != value) {
                        _categoryId = null;
                      }
                    });
                  },
                  validator: (value) =>
                      value == null ? l10n.requiredField : null,
                ),
              if (selectedJar != null) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(
                    l10n.availableBalance(
                      formatCurrency(context, selectedJar.balance),
                    ),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              ExpenseCategoryField(
                jarId: _jarId,
                selectedCategoryId: _categoryId,
                categories: categories,
                onChanged: (value) => setState(() => _categoryId = value),
              ),
              const SizedBox(height: 16),
              _ExpenseDateField(
                date: _date,
                label: l10n.date,
                onTap: _pickDate,
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
                maxLength: 60,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: '${l10n.accountSource} · ${l10n.optional}',
                  hintText: l10n.accountSourceHint,
                  prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                key: const ValueKey('expense-save'),
                onPressed: provider.isSaving ? null : _submit,
                icon: provider.isSaving
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_rounded),
                label: ButtonLabel(l10n.saveExpense),
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
    final saved = await context.read<FinanceProvider>().addExpense(
          amount: parseMoney(_amountController.text)!,
          jarId: _jarId!,
          categoryId: _categoryId!,
          date: _date,
          note: _noteController.text,
          accountName: _accountController.text,
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

class _BudgetWarning extends StatelessWidget {
  const _BudgetWarning({required this.text, required this.isOver});

  final String text;
  final bool isOver;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final background =
        isOver ? colors.errorContainer : colors.tertiaryContainer;
    final foreground =
        isOver ? colors.onErrorContainer : colors.onTertiaryContainer;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: foreground),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: foreground,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpenseDateField extends StatelessWidget {
  const _ExpenseDateField({
    required this.date,
    required this.label,
    required this.onTap,
  });

  final DateTime date;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today_outlined),
        ),
        child: Text(formatDate(context, date)),
      ),
    );
  }
}
