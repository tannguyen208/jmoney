import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/financial_goal.dart';
import '../providers/finance_provider.dart';
import '../theme/finance_semantic_colors.dart';
import '../utils/formatters.dart';
import '../widgets/button_label.dart';
import '../widgets/empty_state.dart';
import '../widgets/selection_field.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<FinanceProvider>();
    return Scaffold(
      appBar: AppBar(title: Text(l10n.goalsTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEditor(context),
        icon: const Icon(Icons.add_rounded),
        label: ButtonLabel(l10n.addGoal),
      ),
      body: SafeArea(
        top: false,
        child: provider.goals.isEmpty
            ? EmptyState(
                icon: Icons.flag_outlined,
                title: l10n.noGoals,
                body: l10n.noGoalsBody,
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 112),
                itemCount: provider.goals.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) => _GoalTile(
                  goal: provider.goals[index],
                  onEdit: () =>
                      _showEditor(context, goal: provider.goals[index]),
                  onContribute: () => _showContribution(
                    context,
                    provider.goals[index],
                  ),
                  onDelete: () => _delete(context, provider.goals[index]),
                ),
              ),
      ),
    );
  }

  static Future<void> _showEditor(
    BuildContext context, {
    FinancialGoal? goal,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<FinanceProvider>(),
        child: _GoalEditor(goal: goal),
      ),
    );
  }

  static Future<void> _showContribution(
    BuildContext context,
    FinancialGoal goal,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<FinanceProvider>(),
        child: _ContributionEditor(goal: goal),
      ),
    );
  }

  static Future<void> _delete(
    BuildContext context,
    FinancialGoal goal,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteGoalTitle),
        content: Text(l10n.deleteGoalMessage),
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
    if (confirmed == true && context.mounted) {
      await context.read<FinanceProvider>().deleteGoal(goal);
    }
  }
}

class _GoalTile extends StatelessWidget {
  const _GoalTile({
    required this.goal,
    required this.onEdit,
    required this.onContribute,
    required this.onDelete,
  });

  final FinancialGoal goal;
  final VoidCallback onEdit;
  final VoidCallback onContribute;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final reached = goal.currentAmount >= goal.targetAmount;
    final color = reached
        ? Theme.of(context).extension<FinanceSemanticColors>()!.income
        : colors.secondary;
    final remaining = (goal.targetAmount - goal.currentAmount)
        .clamp(
          0,
          goal.targetAmount,
        )
        .toInt();
    final days = goal.deadline?.difference(DateTime.now()).inDays ?? 0;
    final months = days <= 0 ? 1 : (days / 30).ceil();
    final monthlyNeeded = (remaining / months).ceil();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  goal.isEmergencyFund
                      ? Icons.health_and_safety_outlined
                      : Icons.flag_outlined,
                  color: color,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    goal.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit();
                    } else if (value == 'delete') {
                      onDelete();
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(value: 'edit', child: Text(l10n.edit)),
                    PopupMenuItem(value: 'delete', child: Text(l10n.delete)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            LinearProgressIndicator(
              value: goal.progress,
              minHeight: 9,
              borderRadius: BorderRadius.circular(4),
              color: color,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${formatCurrency(context, goal.currentAmount)} / '
                    '${formatCurrency(context, goal.targetAmount)}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                Text('${(goal.progress * 100).round()}%'),
              ],
            ),
            if (goal.deadline != null) ...[
              const SizedBox(height: 4),
              Text(
                '${l10n.deadline}: ${formatDate(context, goal.deadline!)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
              ),
            ],
            if (!reached && goal.deadline != null) ...[
              const SizedBox(height: 4),
              Text(
                l10n.monthlyContributionNeeded(
                  formatCurrency(context, monthlyNeeded),
                ),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonalIcon(
                onPressed: onContribute,
                icon: const Icon(Icons.add_rounded),
                label: ButtonLabel(
                  reached ? l10n.goalCompleted : l10n.addContribution,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalEditor extends StatefulWidget {
  const _GoalEditor({this.goal});

  final FinancialGoal? goal;

  @override
  State<_GoalEditor> createState() => _GoalEditorState();
}

class _GoalEditorState extends State<_GoalEditor> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _targetController;
  DateTime? _deadline;
  int? _jarId;
  int _priority = 2;
  bool _isEmergencyFund = false;
  int? _suggestedTarget;
  bool _didLocalizeTarget = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.goal?.name);
    _targetController = TextEditingController(
      text: widget.goal?.targetAmount.toString(),
    );
    _deadline = widget.goal?.deadline;
    _jarId = widget.goal?.jarId;
    _priority = widget.goal?.priority ?? 2;
    _isEmergencyFund = widget.goal?.isEmergencyFund ?? false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLocalizeTarget) return;
    localizeMoneyController(context, _targetController);
    _didLocalizeTarget = true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<FinanceProvider>();
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
                widget.goal == null ? l10n.addGoal : l10n.editGoal,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(labelText: l10n.goalName),
                validator: (value) => value == null || value.trim().isEmpty
                    ? l10n.requiredField
                    : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _targetController,
                keyboardType: TextInputType.number,
                inputFormatters: [localizedMoneyInputFormatter(context)],
                decoration: InputDecoration(
                  labelText: l10n.targetAmount,
                  suffixText: '₫',
                ),
                validator: (value) {
                  final amount = parseMoney(value ?? '');
                  return amount == null || amount <= 0
                      ? l10n.invalidAmount
                      : null;
                },
              ),
              const SizedBox(height: 14),
              SelectionField<int?>(
                value: _jarId,
                decoration: InputDecoration(
                  labelText: '${l10n.selectJar} · ${l10n.optional}',
                ),
                options: [
                  SelectionOption(value: null, label: l10n.optional),
                  for (final jar in provider.jars)
                    SelectionOption(value: jar.id, label: jar.name),
                ],
                onChanged: (value) => setState(() => _jarId = value),
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                leading: const Icon(Icons.event_outlined),
                title: Text(l10n.deadline),
                subtitle: Text(
                  _deadline == null
                      ? l10n.optional
                      : formatDate(context, _deadline!),
                ),
                trailing: _deadline == null
                    ? null
                    : IconButton(
                        onPressed: () => setState(() => _deadline = null),
                        icon: const Icon(Icons.close_rounded),
                      ),
                onTap: _pickDeadline,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _isEmergencyFund,
                title: Text(l10n.isEmergencyFund),
                onChanged: (value) async {
                  setState(() => _isEmergencyFund = value);
                  if (value) {
                    final suggestion = await context
                        .read<FinanceProvider>()
                        .suggestEmergencyFundTarget();
                    if (mounted) setState(() => _suggestedTarget = suggestion);
                  }
                },
              ),
              if (_isEmergencyFund && _suggestedTarget != null)
                TextButton.icon(
                  onPressed: _suggestedTarget! <= 0
                      ? null
                      : () => _targetController.text = formatMoneyInput(
                            Localizations.localeOf(context),
                            _suggestedTarget!,
                          ),
                  icon: const Icon(Icons.auto_awesome_outlined),
                  label: ButtonLabel(
                    l10n.emergencySuggestion(
                      formatCurrency(context, _suggestedTarget!),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Text('${l10n.priority}: $_priority'),
              Slider(
                value: _priority.toDouble(),
                min: 1,
                max: 3,
                divisions: 2,
                label: '$_priority',
                onChanged: (value) => setState(() => _priority = value.round()),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: provider.isSaving ? null : _save,
                child: ButtonLabel(l10n.save),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final value = await showDatePicker(
      context: context,
      initialDate: _deadline ?? now.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: DateTime(now.year + 30),
    );
    if (value != null && mounted) setState(() => _deadline = value);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);
    final success = await context.read<FinanceProvider>().saveGoal(
          FinancialGoal(
            id: widget.goal?.id,
            name: _nameController.text.trim(),
            targetAmount: parseMoney(_targetController.text)!,
            currentAmount: widget.goal?.currentAmount ?? 0,
            deadline: _deadline,
            jarId: _jarId,
            priority: _priority,
            isEmergencyFund: _isEmergencyFund,
            createdAt: widget.goal?.createdAt ?? DateTime.now(),
          ),
        );
    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.goalSaved)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.saveFailed)),
      );
    }
  }
}

class _ContributionEditor extends StatefulWidget {
  const _ContributionEditor({required this.goal});

  final FinancialGoal goal;

  @override
  State<_ContributionEditor> createState() => _ContributionEditorState();
}

class _ContributionEditorState extends State<_ContributionEditor> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

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
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        4,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.goal.name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _amountController,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [localizedMoneyInputFormatter(context)],
              decoration: InputDecoration(
                labelText: l10n.contribution,
                suffixText: '₫',
              ),
              validator: (value) {
                final amount = parseMoney(value ?? '');
                return amount == null || amount <= 0
                    ? l10n.invalidAmount
                    : null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: '${l10n.note} · ${l10n.optional}',
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: provider.isSaving ? null : _save,
              child: ButtonLabel(l10n.addContribution),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);
    final success = await context.read<FinanceProvider>().addGoalContribution(
          goalId: widget.goal.id!,
          amount: parseMoney(_amountController.text)!,
          date: DateTime.now(),
          note: _noteController.text,
        );
    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.saveFailed)),
      );
    }
  }
}
