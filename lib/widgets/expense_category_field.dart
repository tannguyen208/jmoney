import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/category.dart';
import '../screens/transaction_picker_screen.dart';
import 'category_icon.dart';

class ExpenseCategoryField extends StatelessWidget {
  const ExpenseCategoryField({
    super.key,
    required this.jarId,
    required this.selectedCategoryId,
    required this.categories,
    required this.onChanged,
    this.type = CategoryType.expense,
    this.allowWholeJar = false,
    this.wholeJarLabel,
  });

  final int? jarId;
  final int? selectedCategoryId;
  final List<Category> categories;
  final ValueChanged<int?> onChanged;
  final CategoryType type;
  final bool allowWholeJar;
  final String? wholeJarLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final selectedId = categories.any(
      (category) => category.id == selectedCategoryId,
    )
        ? selectedCategoryId
        : null;

    final selectedCategory = selectedId == null
        ? null
        : categories.firstWhere((category) => category.id == selectedId);

    final enabled = type == CategoryType.income || jarId != null;
    return FormField<int>(
      key: ValueKey('expense-category-select-${jarId ?? 'none'}'),
      initialValue: selectedId,
      validator: (_) =>
          allowWholeJar || selectedId != null ? null : l10n.requiredField,
      builder: (state) => InkWell(
        onTap: !enabled
            ? null
            : () async {
                final categoryId = await Navigator.push<int>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TransactionPickerScreen(
                      categorySelectionJarId: jarId,
                      categorySelectionType: type,
                      categorySelectionAllowWholeJar: allowWholeJar,
                      categorySelectionWholeJarLabel: wholeJarLabel,
                    ),
                  ),
                );
                if (categoryId != null && context.mounted) {
                  onChanged(categoryId);
                  state.didChange(categoryId);
                }
              },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: l10n.selectCategory,
            prefixIcon: const Icon(Icons.category_outlined),
            suffixIcon: const Icon(Icons.chevron_right_rounded),
            errorText: state.errorText,
          ),
          child: selectedCategory == null && !allowWholeJar
              ? Text(
                  l10n.selectCategory,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                )
              : selectedCategory == null
                  ? Text(wholeJarLabel ?? l10n.wholeJar)
                  : CategoryOptionLabel(category: selectedCategory),
        ),
      ),
    );
  }
}
