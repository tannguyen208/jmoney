import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/budget_plan.dart';
import '../models/category.dart';
import '../providers/finance_provider.dart';
import '../utils/formatters.dart';
import '../widgets/button_label.dart';
import '../widgets/selection_field.dart';
import '../widgets/category_icon.dart';
import '../widgets/empty_state.dart';
import '../widgets/expense_category_field.dart';
import 'jars_screen.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  BudgetMethod? _selectedMethod;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<FinanceProvider>();
    final activeMethod =
        provider.activeBudgetPlan?.method ?? BudgetMethod.fourJars;
    final selected = _selectedMethod ??
        switch (activeMethod) {
          BudgetMethod.fourJars ||
          BudgetMethod.sixJars ||
          BudgetMethod.fiftyTwentyThirty =>
            activeMethod,
          BudgetMethod.custom => BudgetMethod.fourJars,
        };
    final selectedBody = _methodBody(l10n, selected);
    final selectedDetails = _methodDetails(l10n, selected);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.budgetTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showBudgetEditor(context),
        icon: const Icon(Icons.add_rounded),
        label: ButtonLabel(l10n.addBudget),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 112),
          children: [
            Text(
              l10n.budgetMethod,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.currentPlan(
                provider.activeBudgetPlan?.name ?? l10n.fourJarsPlan,
              ),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  _MethodTile(
                    title: l10n.fourJarsPlan,
                    subtitle: l10n.fourJarsRatio,
                    value: BudgetMethod.fourJars,
                    selected: selected,
                    onChanged: _selectMethod,
                  ),
                  const SizedBox(height: 1),
                  _MethodTile(
                    title: l10n.sixJarsPlan,
                    subtitle: l10n.sixJarsRatio,
                    value: BudgetMethod.sixJars,
                    selected: selected,
                    onChanged: _selectMethod,
                  ),
                  const SizedBox(height: 1),
                  _MethodTile(
                    title: l10n.fiftyPlan,
                    subtitle: l10n.fiftyPlanRatio,
                    value: BudgetMethod.fiftyTwentyThirty,
                    selected: selected,
                    onChanged: _selectMethod,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Card(
              key: ValueKey('budget-method-details-${selected.name}'),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.jarMethodDetails,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      selectedBody,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 16),
                    for (var index = 0;
                        index < selectedDetails.length;
                        index++) ...[
                      Text(
                        l10n.jarAllocationDetail(
                          selectedDetails[index].percentage.toStringAsFixed(0),
                          selectedDetails[index].name,
                        ),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        selectedDetails[index].description,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                      if (index != selectedDetails.length - 1) ...[
                        const SizedBox(height: 12),
                        const SizedBox(height: 1),
                        const SizedBox(height: 12),
                      ],
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.templateWarning,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: provider.isSaving || selected == activeMethod
                  ? null
                  : () => _applyMethod(selected),
              icon: provider.isSaving
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.call_split_rounded),
              label: ButtonLabel(l10n.applyPlan),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const JarsScreen()),
              ),
              icon: const Icon(Icons.tune_rounded),
              label: ButtonLabel(l10n.manageJars),
            ),
            const SizedBox(height: 32),
            Text(
              l10n.monthlyBudgets,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 12),
            if (provider.budgetLimits.isEmpty)
              Column(
                children: [
                  EmptyState(
                    icon: Icons.speed_outlined,
                    title: l10n.noBudgets,
                    body: l10n.noBudgetsBody,
                  ),
                  OutlinedButton.icon(
                    onPressed: provider.isSaving
                        ? null
                        : () => _copyPreviousMonth(context),
                    icon: const Icon(Icons.content_copy_rounded),
                    label: ButtonLabel(l10n.copyPreviousMonth),
                  ),
                ],
              )
            else
              for (final limit in provider.budgetLimits) ...[
                _BudgetLimitTile(
                  limit: limit,
                  onEdit: () => _showBudgetEditor(context, limit: limit),
                  onDelete: () => _confirmDeleteBudget(limit),
                ),
                const SizedBox(height: 10),
              ],
          ],
        ),
      ),
    );
  }

  void _selectMethod(BudgetMethod? value) {
    if (value != null) setState(() => _selectedMethod = value);
  }

  Future<void> _applyMethod(BudgetMethod method) async {
    final l10n = AppLocalizations.of(context);
    final success =
        await context.read<FinanceProvider>().applyBudgetTemplate(method);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? l10n.planApplied : l10n.saveFailed)),
    );
  }

  Future<void> _showBudgetEditor(
    BuildContext context, {
    BudgetLimit? limit,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<FinanceProvider>(),
        child: _BudgetEditor(limit: limit),
      ),
    );
  }

  Future<void> _copyPreviousMonth(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final success = await context
        .read<FinanceProvider>()
        .copyPreviousMonthBudgets(includeRollover: true);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? l10n.budgetsCopied : l10n.saveFailed)),
    );
  }

  Future<void> _confirmDeleteBudget(BudgetLimit limit) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteBudgetTitle),
        content: Text(l10n.deleteBudgetMessage),
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
        await context.read<FinanceProvider>().deleteBudgetLimit(limit);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? l10n.budgetDeleted : l10n.saveFailed)),
    );
  }
}

class _MethodTile extends StatelessWidget {
  const _MethodTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.selected,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final BudgetMethod value;
  final BudgetMethod selected;
  final ValueChanged<BudgetMethod?> onChanged;

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selected;
    return ListTile(
      key: ValueKey('budget-method-${value.name}'),
      selected: isSelected,
      onTap: () => onChanged(value),
      leading: Icon(
        isSelected
            ? Icons.radio_button_checked_rounded
            : Icons.radio_button_unchecked_rounded,
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
    );
  }
}

String _methodBody(AppLocalizations l10n, BudgetMethod method) {
  return switch (method) {
    BudgetMethod.fourJars => l10n.fourJarsPlanBody,
    BudgetMethod.sixJars => l10n.sixJarsPlanBody,
    BudgetMethod.fiftyTwentyThirty => l10n.fiftyPlanBody,
    BudgetMethod.custom => l10n.fourJarsPlanBody,
  };
}

List<_MethodDetail> _methodDetails(
  AppLocalizations l10n,
  BudgetMethod method,
) {
  return switch (method) {
    BudgetMethod.fourJars => [
        _MethodDetail(
          name: l10n.jarEssentials,
          description: l10n.jarEssentialsDescription,
          percentage: 55,
        ),
        _MethodDetail(
          name: l10n.jarSavingsInvestments,
          description: l10n.jarSavingsInvestmentsDescription,
          percentage: 25,
        ),
        _MethodDetail(
          name: l10n.jarEnjoyment,
          description: l10n.jarEnjoymentDescription,
          percentage: 10,
        ),
        _MethodDetail(
          name: l10n.jarEducationDevelopment,
          description: l10n.jarEducationDevelopmentDescription,
          percentage: 10,
        ),
      ],
    BudgetMethod.sixJars => [
        _MethodDetail(
          name: l10n.jarEssentials,
          description: l10n.jarEssentialsDescription,
          percentage: 55,
        ),
        _MethodDetail(
          name: l10n.jarLongTermSavings,
          description: l10n.jarLongTermSavingsDescription,
          percentage: 10,
        ),
        _MethodDetail(
          name: l10n.jarFinancialFreedom,
          description: l10n.jarFinancialFreedomDescription,
          percentage: 10,
        ),
        _MethodDetail(
          name: l10n.jarEducation,
          description: l10n.jarEducationDescription,
          percentage: 10,
        ),
        _MethodDetail(
          name: l10n.jarEnjoyment,
          description: l10n.jarEnjoymentDescription,
          percentage: 10,
        ),
        _MethodDetail(
          name: l10n.jarGiving,
          description: l10n.jarGivingDescription,
          percentage: 5,
        ),
      ],
    BudgetMethod.fiftyTwentyThirty => [
        _MethodDetail(
          name: l10n.jarEssentials,
          description: l10n.jarEssentialsDescription,
          percentage: 50,
        ),
        _MethodDetail(
          name: l10n.jarSavingsInvestments,
          description: l10n.jarSavingsInvestmentsDescription,
          percentage: 20,
        ),
        _MethodDetail(
          name: l10n.jarPersonalWants,
          description: l10n.jarPersonalWantsDescription,
          percentage: 30,
        ),
      ],
    BudgetMethod.custom => const [],
  };
}

class _MethodDetail {
  const _MethodDetail({
    required this.name,
    required this.description,
    required this.percentage,
  });

  final String name;
  final String description;
  final double percentage;
}

class _BudgetLimitTile extends StatelessWidget {
  const _BudgetLimitTile({
    required this.limit,
    required this.onEdit,
    required this.onDelete,
  });

  final BudgetLimit limit;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<FinanceProvider>();
    final jar = provider.jarById(limit.jarId);
    final category = provider.categoryById(limit.categoryId);
    final progress = provider.budgetProgressForLimit(limit);
    final ratio = limit.availableAmount <= 0
        ? 0.0
        : (progress.spent / limit.availableAmount).clamp(0, 1).toDouble();
    final warningColor = progress.isOverBudget
        ? Theme.of(context).colorScheme.error
        : ratio >= 0.9
            ? Theme.of(context).colorScheme.tertiary
            : Theme.of(context).colorScheme.primary;

    return Card(
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        if (category != null) ...[
                          CategoryIcon(category: category, size: 25),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: Text(
                            category?.name ?? jar?.name ?? l10n.unknownJar,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) =>
                        value == 'delete' ? onDelete() : onEdit(),
                    itemBuilder: (context) => [
                      PopupMenuItem(value: 'edit', child: Text(l10n.edit)),
                      PopupMenuItem(value: 'delete', child: Text(l10n.delete)),
                    ],
                  ),
                ],
              ),
              Text(
                '${l10n.spent}: ${formatCurrency(context, progress.spent)} · '
                '${l10n.planned}: '
                '${formatCurrency(context, limit.availableAmount)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: ratio,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
                color: warningColor,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      progress.isOverBudget
                          ? l10n.overBudget
                          : l10n.dailyAllowance(
                              formatCurrency(
                                context,
                                progress.dailyAllowance,
                              ),
                            ),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: warningColor,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  Text(
                    '${(ratio * 100).round()}%',
                    style: TextStyle(
                      color: warningColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BudgetEditor extends StatefulWidget {
  const _BudgetEditor({this.limit});

  final BudgetLimit? limit;

  @override
  State<_BudgetEditor> createState() => _BudgetEditorState();
}

class _BudgetEditorState extends State<_BudgetEditor> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  int? _jarId;
  int? _categoryId;
  bool _didLocalizeAmount = false;

  @override
  void initState() {
    super.initState();
    _jarId = widget.limit?.jarId;
    _categoryId = widget.limit?.categoryId;
    _amountController = TextEditingController(
      text: widget.limit?.plannedAmount.toString(),
    );
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
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<FinanceProvider>();
    final List<Category> categories = _jarId == null
        ? const <Category>[]
        : provider.categoriesForJar(_jarId!);
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
                widget.limit == null ? l10n.addBudget : l10n.editBudget,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 20),
              SelectionField<int?>(
                value: _jarId,
                decoration: InputDecoration(labelText: l10n.budgetJar),
                options: [
                  for (final jar in provider.jars)
                    SelectionOption(value: jar.id, label: jar.name),
                ],
                onChanged: (value) => setState(() {
                  _jarId = value;
                  _categoryId = null;
                }),
                validator: (value) => value == null ? l10n.requiredField : null,
              ),
              const SizedBox(height: 14),
              ExpenseCategoryField(
                jarId: _jarId,
                selectedCategoryId: _categoryId,
                categories: categories,
                allowWholeJar: true,
                wholeJarLabel: l10n.wholeJar,
                onChanged: (value) => setState(() => _categoryId = value),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [localizedMoneyInputFormatter(context)],
                decoration: InputDecoration(
                  labelText: l10n.plannedAmount,
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);
    final provider = context.read<FinanceProvider>();
    final period = provider.currentPeriod;
    final success = await provider.saveBudgetLimit(
      BudgetLimit(
        id: widget.limit?.id,
        year: period.year,
        month: period.month,
        jarId: _jarId,
        categoryId: _categoryId,
        plannedAmount: parseMoney(_amountController.text)!,
        rolloverAmount: widget.limit?.rolloverAmount ?? 0,
      ),
    );
    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.budgetSaved)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.saveFailed)),
      );
    }
  }
}
