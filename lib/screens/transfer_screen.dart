import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/finance_provider.dart';
import '../utils/formatters.dart';
import '../widgets/button_label.dart';
import '../widgets/selection_field.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({
    super.key,
    this.initialDate,
    this.initialSourceJarId,
  });

  final DateTime? initialDate;
  final int? initialSourceJarId;

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  int? _sourceJarId;
  int? _destinationJarId;
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    _sourceJarId = widget.initialSourceJarId;
    _date = widget.initialDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<FinanceProvider>();
    return Scaffold(
      appBar: AppBar(title: Text(l10n.transferMoney)),
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
                  prefixIcon: const Icon(Icons.swap_horiz_rounded),
                ),
                validator: (value) {
                  final amount = parseMoney(value ?? '');
                  return amount == null || amount <= 0
                      ? l10n.invalidAmount
                      : null;
                },
              ),
              const SizedBox(height: 16),
              SelectionField<int?>(
                value: _sourceJarId,
                decoration: InputDecoration(labelText: l10n.sourceJar),
                options: [
                  for (final jar in provider.jars)
                    SelectionOption(
                      value: jar.id,
                      label:
                          '${jar.name} · ${formatCurrency(context, jar.balance)}',
                    ),
                ],
                onChanged: (value) => setState(() => _sourceJarId = value),
                validator: (value) => value == null ? l10n.requiredField : null,
              ),
              const SizedBox(height: 16),
              SelectionField<int?>(
                value: _destinationJarId,
                decoration: InputDecoration(labelText: l10n.destinationJar),
                options: [
                  for (final jar in provider.jars)
                    SelectionOption(value: jar.id, label: jar.name),
                ],
                onChanged: (value) => setState(() => _destinationJarId = value),
                validator: (value) {
                  if (value == null) return l10n.requiredField;
                  if (value == _sourceJarId) return l10n.sameJarError;
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                leading: const Icon(Icons.calendar_today_outlined),
                title: Text(l10n.date),
                subtitle: Text(formatDate(context, _date)),
                onTap: _pickDate,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _noteController,
                maxLength: 120,
                decoration: InputDecoration(
                  labelText: '${l10n.note} · ${l10n.optional}',
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: provider.isSaving ? null : _submit,
                icon: const Icon(Icons.check_rounded),
                label: ButtonLabel(l10n.transferMoney),
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
    final success = await context.read<FinanceProvider>().transferBetweenJars(
          sourceJarId: _sourceJarId!,
          destinationJarId: _destinationJarId!,
          amount: parseMoney(_amountController.text)!,
          date: _date,
          note: _noteController.text,
        );
    if (!mounted) return;
    if (success) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.transferSaved)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.saveFailed)),
      );
    }
  }
}
