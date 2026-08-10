import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/category.dart';
import '../models/jar.dart';
import '../providers/finance_provider.dart';
import '../utils/formatters.dart';
import '../utils/income_distribution.dart';
import '../widgets/button_label.dart';
import '../widgets/expense_category_field.dart';

class AddIncomeScreen extends StatefulWidget {
  const AddIncomeScreen({
    super.key,
    this.initialDate,
    this.initialCategoryId,
  });

  final DateTime? initialDate;
  final int? initialCategoryId;

  @override
  State<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _accountController = TextEditingController();
  final Map<int, TextEditingController> _manualControllers = {};
  final Set<int> _selectedJarIds = {};
  late DateTime _date;
  _IncomeDistributionMode _mode = _IncomeDistributionMode.automatic;
  bool _initializedJars = false;
  int? _categoryId;

  @override
  void initState() {
    super.initState();
    _categoryId = widget.initialCategoryId;
    _date = widget.initialDate ?? DateTime.now();
    _amountController.addListener(_refreshPreview);
  }

  @override
  void dispose() {
    _amountController.removeListener(_refreshPreview);
    _amountController.dispose();
    _noteController.dispose();
    _accountController.dispose();
    for (final controller in _manualControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initializedJars) return;
    final provider = context.read<FinanceProvider>();
    _categoryId ??= provider.incomeCategories.firstOrNull?.id;
    for (final jar in provider.jars) {
      _selectedJarIds.add(jar.id!);
      _manualControllers[jar.id!] = TextEditingController();
    }
    _initializedJars = true;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<FinanceProvider>();
    final amount = parseMoney(_amountController.text);
    final selectedJars =
        provider.jars.where((jar) => _selectedJarIds.contains(jar.id)).toList();
    final selectedPercentage = selectedJars.fold<double>(
      0,
      (sum, jar) => sum + jar.percentage,
    );
    var hasValidAllocation = selectedJars.isNotEmpty &&
        (_mode != _IncomeDistributionMode.automatic || selectedPercentage > 0);
    List<int>? preview;
    List<double>? displayPercentages;
    if (amount != null && amount > 0 && hasValidAllocation) {
      switch (_mode) {
        case _IncomeDistributionMode.automatic:
          preview = distributeIncome(
            amount: amount,
            percentages: [for (final jar in selectedJars) jar.percentage],
          );
          displayPercentages = [
            for (final jar in selectedJars)
              jar.percentage / selectedPercentage * 100,
          ];
        case _IncomeDistributionMode.equal:
          preview = distributeIncome(
            amount: amount,
            percentages: [for (final _ in selectedJars) 1],
          );
          displayPercentages = [
            for (final _ in selectedJars) 100 / selectedJars.length,
          ];
        case _IncomeDistributionMode.manual:
          preview = [
            for (final jar in selectedJars)
              parseMoney(_manualControllers[jar.id]!.text) ?? 0,
          ];
          hasValidAllocation =
              preview.fold<int>(0, (sum, value) => sum + value) == amount;
          displayPercentages = [
            for (final value in preview) amount == 0 ? 0 : value / amount * 100,
          ];
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.addIncome)),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              _InfoBanner(
                icon: Icons.call_split_rounded,
                text: l10n.incomeDistributionHint,
              ),
              if (!hasValidAllocation) ...[
                const SizedBox(height: 12),
                _InfoBanner(
                  icon: Icons.error_outline_rounded,
                  text: selectedJars.isEmpty
                      ? l10n.selectAtLeastOneJar
                      : _mode == _IncomeDistributionMode.manual
                          ? l10n.allocationMustMatch
                          : l10n.invalidJarAllocation,
                  isError: true,
                ),
              ],
              const SizedBox(height: 24),
              ExpenseCategoryField(
                key: const ValueKey('income-category-select'),
                jarId: null,
                selectedCategoryId: _categoryId,
                categories: provider.incomeCategories,
                type: CategoryType.income,
                onChanged: (value) => setState(() => _categoryId = value),
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const ValueKey('income-amount'),
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
              const SizedBox(height: 20),
              Text(
                l10n.distributionMode,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 10),
              SegmentedButton<_IncomeDistributionMode>(
                segments: [
                  ButtonSegment(
                    value: _IncomeDistributionMode.automatic,
                    label: ButtonLabel(l10n.automatic),
                  ),
                  ButtonSegment(
                    value: _IncomeDistributionMode.equal,
                    label: ButtonLabel(l10n.equal),
                  ),
                  ButtonSegment(
                    value: _IncomeDistributionMode.manual,
                    label: ButtonLabel(l10n.manual),
                  ),
                ],
                selected: {_mode},
                onSelectionChanged: (values) =>
                    setState(() => _mode = values.first),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.selectedJars,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final jar in provider.jars)
                    FilterChip(
                      selected: _selectedJarIds.contains(jar.id),
                      label: ButtonLabel(jar.name),
                      onSelected: (selected) => setState(() {
                        if (selected) {
                          _selectedJarIds.add(jar.id!);
                        } else {
                          _selectedJarIds.remove(jar.id);
                        }
                      }),
                    ),
                ],
              ),
              if (_mode == _IncomeDistributionMode.manual) ...[
                const SizedBox(height: 16),
                for (final jar in selectedJars) ...[
                  TextFormField(
                    key: ValueKey('income-manual-${jar.id}'),
                    controller: _manualControllers[jar.id],
                    keyboardType: TextInputType.number,
                    inputFormatters: [localizedMoneyInputFormatter(context)],
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: '${jar.name} · ${l10n.splitAmount}',
                      suffixText: '₫',
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
              if (preview != null) ...[
                const SizedBox(height: 16),
                _DistributionPreview(
                  jars: selectedJars,
                  amounts: preview,
                  percentages: displayPercentages!,
                  normalizedFromTotal:
                      _mode == _IncomeDistributionMode.automatic
                          ? selectedPercentage
                          : 100,
                ),
              ],
              const SizedBox(height: 16),
              _DateField(
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
                textCapitalization: TextCapitalization.words,
                maxLength: 60,
                decoration: InputDecoration(
                  labelText: '${l10n.accountSource} · ${l10n.optional}',
                  hintText: l10n.accountSourceHint,
                  prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                key: const ValueKey('income-save'),
                onPressed:
                    provider.isSaving || !hasValidAllocation ? null : _submit,
                icon: provider.isSaving
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_rounded),
                label: ButtonLabel(l10n.saveIncome),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _refreshPreview() => setState(() {});

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
    final provider = context.read<FinanceProvider>();
    final amount = parseMoney(_amountController.text)!;
    final selectedJars =
        provider.jars.where((jar) => _selectedJarIds.contains(jar.id)).toList();
    if (selectedJars.isEmpty) return;
    late final List<int> amounts;
    switch (_mode) {
      case _IncomeDistributionMode.automatic:
        final total = selectedJars.fold<double>(
          0,
          (sum, jar) => sum + jar.percentage,
        );
        if (total <= 0) return;
        amounts = distributeIncome(
          amount: amount,
          percentages: [for (final jar in selectedJars) jar.percentage],
        );
      case _IncomeDistributionMode.equal:
        amounts = distributeIncome(
          amount: amount,
          percentages: [for (final _ in selectedJars) 1],
        );
      case _IncomeDistributionMode.manual:
        amounts = [
          for (final jar in selectedJars)
            parseMoney(_manualControllers[jar.id]!.text) ?? 0,
        ];
        if (amounts.fold<int>(0, (sum, value) => sum + value) != amount) {
          setState(() {});
          return;
        }
    }
    final saved = await provider.addIncome(
      amount: amount,
      categoryId: _categoryId,
      date: _date,
      note: _noteController.text,
      accountName: _accountController.text,
      allocations: {
        for (var index = 0; index < selectedJars.length; index++)
          selectedJars[index].id!: amounts[index],
      },
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

class _DistributionPreview extends StatelessWidget {
  const _DistributionPreview({
    required this.jars,
    required this.amounts,
    required this.percentages,
    required this.normalizedFromTotal,
  });

  final List<Jar> jars;
  final List<int> amounts;
  final List<double> percentages;
  final double normalizedFromTotal;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.distributionPreview,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            if ((normalizedFromTotal - 100).abs() >= 0.01) ...[
              const SizedBox(height: 4),
              Text(
                l10n.normalizedFromTotal(
                  normalizedFromTotal.toStringAsFixed(
                    normalizedFromTotal % 1 == 0 ? 0 : 1,
                  ),
                ),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
            const SizedBox(height: 12),
            for (var index = 0; index < jars.length; index++) ...[
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: colorFromHex(jars[index].color),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${jars[index].name} · '
                      '${percentages[index].toStringAsFixed(1)}%',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    formatCurrency(context, amounts[index]),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              if (index < jars.length - 1) const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

enum _IncomeDistributionMode { automatic, equal, manual }

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({
    required this.icon,
    required this.text,
    this.isError = false,
  });

  final IconData icon;
  final String text;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final background =
        isError ? colors.errorContainer : colors.secondaryContainer;
    final foreground =
        isError ? colors.onErrorContainer : colors.onSecondaryContainer;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: foreground),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: foreground,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
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
