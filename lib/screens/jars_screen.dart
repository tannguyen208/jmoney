import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/jar.dart';
import '../providers/finance_provider.dart';
import '../utils/formatters.dart';
import '../widgets/button_label.dart';

class JarsScreen extends StatelessWidget {
  const JarsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<FinanceProvider>();
    final isBalanced = (provider.totalPercentage - 100).abs() < 0.01;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.jarsTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEditor(context),
        icon: const Icon(Icons.add_rounded),
        label: ButtonLabel(l10n.addJar),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: isBalanced
                    ? Theme.of(context).colorScheme.secondaryContainer
                    : Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      isBalanced
                          ? Icons.check_circle_outline_rounded
                          : Icons.info_outline_rounded,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.allocationTotal(
                              provider.totalPercentage.toStringAsFixed(
                                provider.totalPercentage % 1 == 0 ? 0 : 1,
                              ),
                            ),
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isBalanced
                                ? l10n.allocationBalanced
                                : l10n.allocationMismatch,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              itemCount: provider.jars.length,
              onReorderItem: provider.reorderJars,
              itemBuilder: (context, index) {
                final jar = provider.jars[index];
                return Padding(
                  key: ValueKey(jar.id),
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: ListTile(
                      minTileHeight: 82,
                      contentPadding: const EdgeInsets.fromLTRB(18, 8, 4, 8),
                      onTap: () => _showEditor(context, jar: jar),
                      leading: CircleAvatar(
                        backgroundColor: colorFromHex(jar.color),
                        child: Text(
                          '${jar.percentage.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      title: Text(
                        jar.name,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (jar.description?.isNotEmpty ?? false)
                            Text(
                              jar.description!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          Text(
                            jar.isBalanceHidden
                                ? '••••••'
                                : formatCurrency(context, jar.balance),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ReorderableDragStartListener(
                            index: index,
                            child: const Padding(
                              padding: EdgeInsets.all(12),
                              child: Icon(Icons.drag_handle_rounded),
                            ),
                          ),
                          PopupMenuButton<_JarAction>(
                            onSelected: (action) {
                              if (action == _JarAction.edit) {
                                _showEditor(context, jar: jar);
                              } else {
                                _delete(context, jar);
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: _JarAction.edit,
                                child: Text(l10n.editJar),
                              ),
                              PopupMenuItem(
                                value: _JarAction.delete,
                                child: Text(l10n.delete),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditor(BuildContext context, {Jar? jar}) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<FinanceProvider>(),
        child: _JarEditor(jar: jar),
      ),
    );
  }

  Future<void> _delete(BuildContext context, Jar jar) async {
    final l10n = AppLocalizations.of(context);
    final provider = context.read<FinanceProvider>();
    if (provider.jars.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.cannotDeleteLastJar)),
      );
      return;
    }
    if (await provider.jarHasFinancialHistory(jar)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.cannotDeleteJarWithHistory)),
        );
      }
      return;
    }
    if (!context.mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteJarTitle),
        content: Text(l10n.deleteJarMessage),
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
    if (confirmed != true || !context.mounted) return;
    final success = await provider.deleteJar(jar);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? l10n.jarDeleted : l10n.saveFailed)),
      );
    }
  }
}

enum _JarAction { edit, delete }

class _JarEditor extends StatefulWidget {
  const _JarEditor({this.jar});

  final Jar? jar;

  @override
  State<_JarEditor> createState() => _JarEditorState();
}

class _JarEditorState extends State<_JarEditor> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _percentageController;
  late String _color;
  late bool _isBalanceHidden;

  static const colors = [
    '#247A68',
    '#3566A8',
    '#C97832',
    '#7A559D',
    '#B24B63',
    '#4C7B9B',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.jar?.name);
    _descriptionController = TextEditingController(
      text: widget.jar?.description,
    );
    _percentageController = TextEditingController(
      text: widget.jar?.percentage.toStringAsFixed(
        widget.jar!.percentage % 1 == 0 ? 0 : 1,
      ),
    );
    _color = widget.jar?.color ?? colors.first;
    _isBalanceHidden = widget.jar?.isBalanceHidden ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _percentageController.dispose();
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
                widget.jar == null ? l10n.addJar : l10n.editJar,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(labelText: l10n.jarName),
                validator: (value) => value == null || value.trim().isEmpty
                    ? l10n.requiredField
                    : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _descriptionController,
                textCapitalization: TextCapitalization.sentences,
                maxLength: 160,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: '${l10n.jarDescription} · ${l10n.optional}',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _percentageController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                decoration: InputDecoration(labelText: l10n.percentage),
                validator: (value) {
                  final parsed =
                      double.tryParse((value ?? '').replaceAll(',', '.'));
                  return parsed == null || parsed < 0 || parsed > 100
                      ? l10n.requiredField
                      : null;
                },
              ),
              const SizedBox(height: 18),
              Text(l10n.color),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final value in colors)
                    InkWell(
                      onTap: () => setState(() => _color = value),
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: colorFromHex(value),
                          shape: BoxShape.circle,
                          border: value == _color
                              ? Border.all(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  width: 3,
                                )
                              : null,
                        ),
                        child: value == _color
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _isBalanceHidden,
                title: Text(
                  _isBalanceHidden ? l10n.hideBalance : l10n.showBalance,
                ),
                onChanged: (value) => setState(() => _isBalanceHidden = value),
              ),
              const SizedBox(height: 24),
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
    final previous = widget.jar;
    final jar = Jar(
      id: previous?.id,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      templateKey: previous?.templateKey,
      percentage: double.parse(_percentageController.text.replaceAll(',', '.')),
      balance: previous?.balance ?? 0,
      color: _color,
      orderIndex: previous?.orderIndex ?? 0,
      isBalanceHidden: _isBalanceHidden,
    );
    final success = await context.read<FinanceProvider>().saveJar(jar);
    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.jarSaved)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.saveFailed)),
      );
    }
  }
}
