import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/category.dart';
import '../models/finance_transaction.dart';
import '../models/recurring_rule.dart';
import '../providers/finance_provider.dart';
import '../utils/formatters.dart';
import '../widgets/button_label.dart';
import '../widgets/category_icon.dart';
import '../widgets/empty_state.dart';
import '../widgets/expense_category_field.dart';
import '../widgets/selection_field.dart';

class RecurringScreen extends StatelessWidget {
  const RecurringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<FinanceProvider>();
    return Scaffold(
      appBar: AppBar(title: Text(l10n.recurringTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEditor(context),
        icon: const Icon(Icons.add_rounded),
        label: ButtonLabel(l10n.addRecurring),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 112),
          children: [
            if (provider.pendingOccurrences.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  l10n.pendingTasks,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              const SizedBox(height: 10),
              for (final occurrence in provider.pendingOccurrences) ...[
                _OccurrenceTile(occurrence: occurrence),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 20),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                l10n.recurringTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
            const SizedBox(height: 10),
            if (provider.recurringRules.isEmpty)
              EmptyState(
                icon: Icons.event_repeat_outlined,
                title: l10n.noRecurring,
                body: l10n.noRecurringBody,
              )
            else
              for (final rule in provider.recurringRules) ...[
                _RuleTile(
                  rule: rule,
                  onTap: () => _showEditor(context, rule: rule),
                ),
                const SizedBox(height: 10),
              ],
          ],
        ),
      ),
    );
  }

  static Future<void> _showEditor(
    BuildContext context, {
    RecurringRule? rule,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<FinanceProvider>(),
        child: _RecurringEditor(rule: rule),
      ),
    );
  }
}

class _OccurrenceTile extends StatelessWidget {
  const _OccurrenceTile({required this.occurrence});

  final RecurringOccurrence occurrence;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<FinanceProvider>();
    final rule = provider.recurringRuleById(occurrence.ruleId);
    if (rule == null) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              rule.name,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              '${formatCurrency(context, rule.amount)} · '
              '${formatDate(context, occurrence.scheduledAt)}',
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: provider.isSaving
                      ? null
                      : () => provider.skipOccurrence(occurrence),
                  child: ButtonLabel(l10n.skip),
                ),
                const SizedBox(width: 8),
                FilledButton.tonal(
                  onPressed: provider.isSaving
                      ? null
                      : () async {
                          final success =
                              await provider.completeOccurrence(occurrence);
                          if (success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.occurrenceCompleted),
                              ),
                            );
                          }
                        },
                  child: ButtonLabel(l10n.confirmPost),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RuleTile extends StatelessWidget {
  const _RuleTile({required this.rule, required this.onTap});

  final RecurringRule rule;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.read<FinanceProvider>();
    final category = provider.categoryById(rule.categoryId);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        minTileHeight: 82,
        onTap: onTap,
        leading: CircleAvatar(
          child: category != null
              ? CategoryIcon(category: category, size: 29)
              : KoboyoAssetIcon(
                  asset: switch (rule.type) {
                    TransactionType.income => JMoneyIconAssets.income,
                    TransactionType.expense => JMoneyIconAssets.expense,
                    TransactionType.transfer => JMoneyIconAssets.transfer,
                  },
                  size: 29,
                ),
        ),
        title: Text(
          rule.name,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          '${formatCurrency(context, rule.amount)} · '
          '${_frequencyLabel(l10n, rule.frequency)}\n'
          '${l10n.nextRun}: ${formatDate(context, rule.nextRunAt)}',
        ),
        isThreeLine: true,
        trailing: Switch(
          value: rule.isEnabled,
          onChanged: (value) =>
              provider.saveRecurringRule(rule.copyWith(isEnabled: value)),
        ),
      ),
    );
  }

  static String _frequencyLabel(
    AppLocalizations l10n,
    RecurrenceFrequency frequency,
  ) {
    return switch (frequency) {
      RecurrenceFrequency.weekly => l10n.weekly,
      RecurrenceFrequency.monthly => l10n.monthly,
      RecurrenceFrequency.quarterly => l10n.quarterly,
      RecurrenceFrequency.yearly => l10n.yearly,
    };
  }
}

class _RecurringEditor extends StatefulWidget {
  const _RecurringEditor({this.rule});

  final RecurringRule? rule;

  @override
  State<_RecurringEditor> createState() => _RecurringEditorState();
}

class _RecurringEditorState extends State<_RecurringEditor> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  late TransactionType _type;
  late RecurrenceFrequency _frequency;
  int? _jarId;
  int? _destinationJarId;
  int? _categoryId;
  late DateTime _nextRunAt;
  DateTime? _endAt;
  bool _autoPost = false;
  bool _didLocalizeAmount = false;

  @override
  void initState() {
    super.initState();
    final rule = widget.rule;
    _nameController = TextEditingController(text: rule?.name);
    _amountController = TextEditingController(text: rule?.amount.toString());
    _noteController = TextEditingController(text: rule?.note);
    _type = rule?.type ?? TransactionType.expense;
    _frequency = rule?.frequency ?? RecurrenceFrequency.monthly;
    _jarId = rule?.jarId;
    _destinationJarId = rule?.destinationJarId;
    _categoryId = rule?.categoryId;
    _nextRunAt = rule?.nextRunAt ?? DateTime.now();
    _endAt = rule?.endAt;
    _autoPost = rule?.autoPost ?? false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLocalizeAmount) return;
    localizeMoneyController(context, _amountController);
    _didLocalizeAmount = true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<FinanceProvider>();
    final categories =
        _jarId == null ? <Category>[] : provider.categoriesForJar(_jarId!);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        4,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.rule == null ? l10n.addRecurring : l10n.editRecurring,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _nameController,
                autofocus: true,
                decoration: InputDecoration(labelText: l10n.ruleName),
                validator: (value) => value == null || value.trim().isEmpty
                    ? l10n.requiredField
                    : null,
              ),
              const SizedBox(height: 14),
              SegmentedButton<TransactionType>(
                segments: [
                  ButtonSegment(
                    value: TransactionType.income,
                    label: ButtonLabel(l10n.income),
                    icon: const Icon(Icons.south_west_rounded),
                  ),
                  ButtonSegment(
                    value: TransactionType.expense,
                    label: ButtonLabel(l10n.expense),
                    icon: const Icon(Icons.north_east_rounded),
                  ),
                  ButtonSegment(
                    value: TransactionType.transfer,
                    label: ButtonLabel(l10n.filterTransfer),
                    icon: const Icon(Icons.swap_horiz_rounded),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (values) => setState(() {
                  _type = values.first;
                  _jarId = null;
                  _destinationJarId = null;
                  _categoryId = null;
                }),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _amountController,
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
              if (_type == TransactionType.income) ...[
                const SizedBox(height: 14),
                ExpenseCategoryField(
                  jarId: null,
                  selectedCategoryId: _categoryId,
                  categories: provider.incomeCategories,
                  type: CategoryType.income,
                  onChanged: (value) => setState(() => _categoryId = value),
                ),
              ],
              if (_type != TransactionType.income) ...[
                const SizedBox(height: 14),
                SelectionField<int?>(
                  value: _jarId,
                  decoration: InputDecoration(
                    labelText: _type == TransactionType.transfer
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
              if (_type == TransactionType.expense) ...[
                const SizedBox(height: 14),
                ExpenseCategoryField(
                  jarId: _jarId,
                  selectedCategoryId: _categoryId,
                  categories: categories,
                  onChanged: (value) => setState(() => _categoryId = value),
                ),
              ],
              if (_type == TransactionType.transfer) ...[
                const SizedBox(height: 14),
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
              const SizedBox(height: 14),
              SelectionField<RecurrenceFrequency>(
                value: _frequency,
                decoration: InputDecoration(labelText: l10n.frequency),
                options: [
                  SelectionOption(
                    value: RecurrenceFrequency.weekly,
                    label: l10n.weekly,
                  ),
                  SelectionOption(
                    value: RecurrenceFrequency.monthly,
                    label: l10n.monthly,
                  ),
                  SelectionOption(
                    value: RecurrenceFrequency.quarterly,
                    label: l10n.quarterly,
                  ),
                  SelectionOption(
                    value: RecurrenceFrequency.yearly,
                    label: l10n.yearly,
                  ),
                ],
                onChanged: (value) {
                  setState(() => _frequency = value);
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                leading: const Icon(Icons.event_repeat_outlined),
                title: Text(l10n.nextRun),
                subtitle: Text(formatDate(context, _nextRunAt)),
                onTap: _pickDate,
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                leading: const Icon(Icons.event_busy_outlined),
                title: Text('${l10n.endDate} · ${l10n.optional}'),
                subtitle: Text(
                  _endAt == null ? l10n.optional : formatDate(context, _endAt!),
                ),
                trailing: _endAt == null
                    ? null
                    : IconButton(
                        onPressed: () => setState(() => _endAt = null),
                        icon: const Icon(Icons.close_rounded),
                      ),
                onTap: _pickEndDate,
              ),
              TextFormField(
                controller: _noteController,
                maxLength: 120,
                decoration: InputDecoration(
                  labelText: '${l10n.note} · ${l10n.optional}',
                ),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _autoPost,
                title: Text(l10n.autoPost),
                subtitle: Text(l10n.autoPostHint),
                onChanged: (value) => setState(() => _autoPost = value),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: provider.isSaving ? null : _save,
                child: ButtonLabel(l10n.save),
              ),
              if (widget.rule != null) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: provider.isSaving ? null : _delete,
                  child: ButtonLabel(l10n.delete),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final value = await showDatePicker(
      context: context,
      initialDate: _nextRunAt,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (value != null && mounted) setState(() => _nextRunAt = value);
  }

  Future<void> _pickEndDate() async {
    final value = await showDatePicker(
      context: context,
      initialDate: _endAt ?? _nextRunAt.add(const Duration(days: 365)),
      firstDate: _nextRunAt,
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (value != null && mounted) setState(() => _endAt = value);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);
    final success = await context.read<FinanceProvider>().saveRecurringRule(
          RecurringRule(
            id: widget.rule?.id,
            name: _nameController.text.trim(),
            type: _type,
            amount: parseMoney(_amountController.text)!,
            jarId: _jarId,
            destinationJarId: _destinationJarId,
            categoryId: _categoryId,
            note: _noteController.text.trim().isEmpty
                ? null
                : _noteController.text.trim(),
            frequency: _frequency,
            nextRunAt: _nextRunAt,
            endAt: _endAt,
            isEnabled: widget.rule?.isEnabled ?? true,
            autoPost: _autoPost,
          ),
        );
    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.ruleSaved)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.saveFailed)),
      );
    }
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteRuleTitle),
        content: Text(l10n.deleteRuleMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: ButtonLabel(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: ButtonLabel(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final success =
        await context.read<FinanceProvider>().deleteRecurringRule(widget.rule!);
    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.ruleDeleted)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.saveFailed)),
      );
    }
  }
}
