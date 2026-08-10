import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/category.dart';
import '../models/jar.dart';
import '../providers/finance_provider.dart';
import '../utils/formatters.dart';
import '../widgets/button_label.dart';
import '../widgets/category_icon.dart';
import '../widgets/empty_state.dart';
import '../widgets/selection_field.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<FinanceProvider>();
    final groups = _groupsFor(provider, l10n);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.categoriesTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEditor(context),
        icon: const Icon(Icons.add_rounded),
        label: ButtonLabel(l10n.addCategory),
      ),
      body: SafeArea(
        top: false,
        child: provider.expenseCategories.isEmpty
            ? EmptyState(
                icon: Icons.category_outlined,
                title: l10n.noCategories,
                body: l10n.noCategoriesBody,
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                itemCount: groups.length,
                itemBuilder: (context, index) {
                  final group = groups[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index == groups.length - 1 ? 0 : 24,
                    ),
                    child: _CategoryGroupSection(
                      group: group,
                      onEdit: (category) =>
                          _showEditor(context, category: category),
                      onDelete: (category) => _delete(context, category),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Future<void> _showEditor(
    BuildContext context, {
    Category? category,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<FinanceProvider>(),
        child: _CategoryEditor(category: category),
      ),
    );
  }

  Future<void> _delete(BuildContext context, Category category) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteCategoryTitle),
        content: Text(l10n.deleteCategoryMessage),
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
    final success =
        await context.read<FinanceProvider>().deleteCategory(category);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? l10n.categoryDeleted : l10n.saveFailed),
        ),
      );
    }
  }

  static List<_CategoryGroup> _groupsFor(
    FinanceProvider provider,
    AppLocalizations l10n,
  ) {
    final sharedCategories = <Category>[];
    final orphanCategories = <Category>[];
    final categoriesByJar = <int, List<Category>>{};
    for (final category in provider.expenseCategories) {
      if (category.jarId == null) {
        sharedCategories.add(category);
        continue;
      }
      final jar = provider.jarById(category.jarId);
      if (jar == null) {
        orphanCategories.add(category);
        continue;
      }
      categoriesByJar.putIfAbsent(jar.id!, () => []).add(category);
    }

    return [
      if (sharedCategories.isNotEmpty)
        _CategoryGroup(
          keyValue: 'all',
          label: l10n.allJars,
          categories: sharedCategories,
        ),
      if (orphanCategories.isNotEmpty)
        _CategoryGroup(
          keyValue: 'unknown',
          label: l10n.unknownJar,
          categories: orphanCategories,
          isOrphan: true,
        ),
      for (final jar in provider.jars)
        if (categoriesByJar[jar.id] case final List<Category> categories)
          _CategoryGroup(
            keyValue: '${jar.id}',
            label: jar.name,
            jar: jar,
            categories: categories,
          ),
    ];
  }
}

class _CategoryGroup {
  const _CategoryGroup({
    required this.keyValue,
    required this.label,
    required this.categories,
    this.jar,
    this.isOrphan = false,
  });

  final String keyValue;
  final String label;
  final Jar? jar;
  final List<Category> categories;
  final bool isOrphan;
}

class _CategoryGroupSection extends StatelessWidget {
  const _CategoryGroupSection({
    required this.group,
    required this.onEdit,
    required this.onDelete,
  });

  final _CategoryGroup group;
  final ValueChanged<Category> onEdit;
  final ValueChanged<Category> onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final groupColor = group.isOrphan
        ? colorScheme.error
        : group.jar == null
            ? colorScheme.secondary
            : colorFromHex(group.jar!.color, fallback: colorScheme.primary);
    return Semantics(
      container: true,
      child: Column(
        key: ValueKey('category-group-${group.keyValue}'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: groupColor,
                        shape: BoxShape.circle,
                      ),
                      child: const SizedBox.square(dimension: 12),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.label,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.categoryCount(group.categories.length),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var index = 0;
                    index < group.categories.length;
                    index++) ...[
                  if (index > 0) const SizedBox(height: 1),
                  _CategoryTile(
                    category: group.categories[index],
                    groupColor: groupColor,
                    onEdit: onEdit,
                    onDelete: onDelete,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.groupColor,
    required this.onEdit,
    required this.onDelete,
  });

  final Category category;
  final Color groupColor;
  final ValueChanged<Category> onEdit;
  final ValueChanged<Category> onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListTile(
      key: ValueKey('category-item-${category.id}'),
      minTileHeight: 68,
      contentPadding: const EdgeInsetsDirectional.only(start: 16, end: 4),
      onTap: () => onEdit(category),
      leading: CircleAvatar(
        backgroundColor: groupColor.withValues(alpha: 0.14),
        child: CategoryIcon(
          category: category,
          size: 30,
          fallbackColor: groupColor,
        ),
      ),
      title: Text(
        category.name,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      trailing: PopupMenuButton<_CategoryAction>(
        onSelected: (action) {
          if (action == _CategoryAction.edit) {
            onEdit(category);
          } else {
            onDelete(category);
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: _CategoryAction.edit,
            child: Text(l10n.editCategory),
          ),
          PopupMenuItem(
            value: _CategoryAction.delete,
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}

enum _CategoryAction { edit, delete }

class _CategoryEditor extends StatefulWidget {
  const _CategoryEditor({this.category});

  final Category? category;

  @override
  State<_CategoryEditor> createState() => _CategoryEditorState();
}

class _CategoryEditorState extends State<_CategoryEditor> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late String? _selectedIcon;
  int? _jarId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name);
    _selectedIcon = normalizeCategoryIcon(widget.category?.icon) ??
        categoryIconOptions.first.key;
    _jarId = widget.category?.jarId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<FinanceProvider>();
    final selectedJarId = provider.jarById(_jarId)?.id;
    final iconLabels = [
      l10n.categoryShopping,
      l10n.categoryFood,
      l10n.categoryCoffee,
      l10n.categoryGroceries,
      l10n.categoryRent,
      l10n.categoryUtilities,
      l10n.categoryInternet,
      l10n.categoryPhone,
      l10n.categoryFuel,
      l10n.categoryTransport,
      l10n.categoryHealthcare,
      l10n.categoryBeauty,
      l10n.categoryEntertainment,
      l10n.categoryTravel,
      l10n.categoryEducation,
      l10n.categorySubscriptions,
      l10n.categoryTechnology,
      l10n.categoryGifts,
      l10n.categoryFamily,
      l10n.categoryOtherExpenses,
    ];
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
                widget.category == null ? l10n.addCategory : l10n.editCategory,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(labelText: l10n.categoryName),
                validator: (value) => value == null || value.trim().isEmpty
                    ? l10n.requiredField
                    : null,
              ),
              const SizedBox(height: 14),
              Text(
                l10n.categoryIcon,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.categoryIconHint,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var index = 0;
                      index < categoryIconOptions.length;
                      index++)
                    _IconChoice(
                      option: categoryIconOptions[index],
                      label: iconLabels[index],
                      selected: _selectedIcon == categoryIconOptions[index].key,
                      onTap: () => setState(
                        () => _selectedIcon = categoryIconOptions[index].key,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              SelectionField<int?>(
                value: selectedJarId ?? -1,
                decoration: InputDecoration(labelText: l10n.categoryJar),
                options: [
                  SelectionOption<int?>(
                    value: -1,
                    label: l10n.allJars,
                  ),
                  for (final jar in provider.jars)
                    SelectionOption<int?>(
                      value: jar.id,
                      label: jar.name,
                    ),
                ],
                onChanged: (value) => setState(
                  () => _jarId = value == -1 ? null : value,
                ),
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
    final provider = context.read<FinanceProvider>();
    final previous = widget.category;
    final category = Category(
      id: previous?.id,
      name: _nameController.text.trim(),
      icon: _selectedIcon,
      jarId: provider.jarById(_jarId)?.id,
      color: previous?.color,
    );
    final success = await provider.saveCategory(category);
    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.categorySaved)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.saveFailed)),
      );
    }
  }
}

class _IconChoice extends StatelessWidget {
  const _IconChoice({
    required this.option,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final CategoryIconOption option;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Tooltip(
      message: label,
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: Material(
          color: selected
              ? colors.primaryContainer
              : colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(4),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            key: ValueKey('category-icon-${option.key}'),
            onTap: onTap,
            child: Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: selected
                    ? Border.all(color: colors.primary, width: 2)
                    : null,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Transform.scale(
                scale: categoryIconVisualScale(option.key),
                child: KoboyoAssetIcon(
                  asset: option.asset,
                  size: 27.2,
                  horizontalScale: categoryIconHorizontalScale(option.key),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
