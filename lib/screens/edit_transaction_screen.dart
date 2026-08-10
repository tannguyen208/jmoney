import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/category.dart';
import '../models/finance_transaction.dart';
import '../providers/finance_provider.dart';
import '../utils/formatters.dart';
import '../widgets/button_label.dart';
import '../widgets/expense_category_field.dart';
import '../widgets/selection_field.dart';

class EditTransactionScreen extends StatefulWidget {
  const EditTransactionScreen({super.key, required this.transaction});

  final FinanceTransaction transaction;

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  late final TextEditingController _accountController;
  late DateTime _date;
  int? _jarId;
  int? _destinationJarId;
  int? _categoryId;
  bool _didLocalizeAmount = false;

  @override
  void initState() {
    super.initState();
    final item = widget.transaction;
    _amountController = TextEditingController(text: item.amount.toString());
    _noteController = TextEditingController(text: item.note);
    _accountController = TextEditingController(text: item.accountName);
    _date = item.date;
    _jarId = item.jarId;
    _destinationJarId = item.destinationJarId;
    _categoryId = item.categoryId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.transaction.type == TransactionType.income &&
        _categoryId == null) {
      _categoryId =
          context.read<FinanceProvider>().incomeCategories.firstOrNull?.id;
    }
    if (_didLocalizeAmount) return;
    localizeMoneyController(context, _amountController);
    _didLocalizeAmount = true;
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
    final item = widget.transaction;
    final categories =
        _jarId == null ? <Category>[] : provider.categoriesForJar(_jarId!);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.edit)),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              TextFormField(
                controller: _amountController,
                autofocus: true,
                keyboardType: TextInputType.number,
                inputFormatters: [localizedMoneyInputFormatter(context)],
                decoration: InputDecoration(
                  labelText: l10n.amount,
                  suffixText: '₫',
                ),
                validator: (value) {
                  final amount = parseMoney(value ?? '');
                  return amount == null || amount <= 0
                      ? l10n.invalidAmount
                      : null;
                },
              ),
              if (item.type == TransactionType.income) ...[
                const SizedBox(height: 16),
                ExpenseCategoryField(
                  key: const ValueKey('edit-income-category-select'),
                  jarId: null,
                  selectedCategoryId: _categoryId,
                  categories: provider.incomeCategories,
                  type: CategoryType.income,
                  onChanged: (value) => setState(() => _categoryId = value),
                ),
              ],
              if (item.type != TransactionType.income) ...[
                const SizedBox(height: 16),
                SelectionField<int?>(
                  key: const ValueKey('edit-expense-jar-select'),
                  value: _jarId,
                  decoration: InputDecoration(
                    labelText: item.type == TransactionType.transfer
                        ? l10n.sourceJar
                        : l10n.selectJar,
                  ),
                  options: [
                    for (final jar in provider.jars)
                      SelectionOption(value: jar.id, label: jar.name),
                  ],
                  onChanged: (value) => setState(() {
                    _jarId = value;
                    _categoryId = null;
                  }),
                  validator: (value) =>
                      value == null ? l10n.requiredField : null,
                ),
              ],
              if (item.type == TransactionType.expense) ...[
                const SizedBox(height: 16),
                ExpenseCategoryField(
                  jarId: _jarId,
                  selectedCategoryId: _categoryId,
                  categories: categories,
                  onChanged: (value) => setState(() => _categoryId = value),
                ),
              ],
              if (item.type == TransactionType.transfer) ...[
                const SizedBox(height: 16),
                SelectionField<int?>(
                  value: _destinationJarId,
                  decoration: InputDecoration(
                    labelText: l10n.destinationJar,
                  ),
                  options: [
                    for (final jar in provider.jars)
                      SelectionOption(value: jar.id, label: jar.name),
                  ],
                  onChanged: (value) =>
                      setState(() => _destinationJarId = value),
                  validator: (value) {
                    if (value == null) return l10n.requiredField;
                    if (value == _jarId) return l10n.sameJarError;
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 8),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                leading: const Icon(Icons.calendar_today_outlined),
                title: Text(l10n.date),
                subtitle: Text(formatDate(context, _date)),
                onTap: _pickDate,
              ),
              TextFormField(
                controller: _noteController,
                maxLength: 120,
                decoration: InputDecoration(
                  labelText: '${l10n.note} · ${l10n.optional}',
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _accountController,
                maxLength: 60,
                decoration: InputDecoration(
                  labelText: '${l10n.accountSource} · ${l10n.optional}',
                  hintText: l10n.accountSourceHint,
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                key: const ValueKey('edit-transaction-save'),
                onPressed: provider.isSaving ? null : _save,
                icon: const Icon(Icons.check_rounded),
                label: ButtonLabel(l10n.save),
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);
    final previous = widget.transaction;
    final updated = FinanceTransaction(
      id: previous.id,
      type: previous.type,
      amount: parseMoney(_amountController.text)!,
      jarId: previous.type == TransactionType.income ? null : _jarId,
      destinationJarId:
          previous.type == TransactionType.transfer ? _destinationJarId : null,
      categoryId:
          previous.type == TransactionType.transfer ? null : _categoryId,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      date: _date,
      accountName: _accountController.text.trim().isEmpty
          ? null
          : _accountController.text.trim(),
      incomeAllocations: previous.type == TransactionType.income
          ? _scaledIncomeAllocations(
              previous.incomeAllocations,
              parseMoney(_amountController.text)!,
            )
          : const {},
      recurringRuleId: previous.recurringRuleId,
      occurrenceKey: previous.occurrenceKey,
      createdAt: previous.createdAt,
      updatedAt: previous.updatedAt,
    );
    final success =
        await context.read<FinanceProvider>().updateTransaction(updated);
    if (!mounted) return;
    if (success) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.transactionUpdated)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.saveFailed)),
      );
    }
  }

  Map<int, int> _scaledIncomeAllocations(
    Map<int, int> previous,
    int newAmount,
  ) {
    if (previous.isEmpty || previous.values.every((value) => value == 0)) {
      return const {};
    }
    final entries = previous.entries.toList();
    final total = entries.fold<int>(0, (sum, entry) => sum + entry.value);
    var distributed = 0;
    final result = <int, int>{};
    for (var index = 0; index < entries.length; index++) {
      final entry = entries[index];
      final amount = index == entries.length - 1
          ? newAmount - distributed
          : (newAmount * entry.value / total).round();
      result[entry.key] = amount;
      distributed += amount;
    }
    return result;
  }
}
