import 'package:flutter/material.dart';

class SelectionOption<T> {
  const SelectionOption({required this.value, required this.label});

  final T value;
  final String label;
}

class SelectionField<T> extends StatelessWidget {
  const SelectionField({
    super.key,
    required this.value,
    required this.options,
    required this.decoration,
    this.onChanged,
    this.validator,
  });

  final T value;
  final List<SelectionOption<T>> options;
  final InputDecoration decoration;
  final ValueChanged<T>? onChanged;
  final FormFieldValidator<T>? validator;

  @override
  Widget build(BuildContext context) {
    return FormField<T>(
      initialValue: value,
      validator: validator,
      builder: (field) {
        final selected = options.where((option) => option.value == field.value);
        final selectedLabel = selected.isEmpty ? null : selected.first.label;
        return InkWell(
          onTap: onChanged == null
              ? null
              : () async {
                  final option = await showModalBottomSheet<SelectionOption<T>>(
                    context: context,
                    showDragHandle: true,
                    builder: (sheetContext) => SafeArea(
                      child: ListView(
                        shrinkWrap: true,
                        padding: const EdgeInsets.only(bottom: 12),
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                            child: Text(
                              decoration.labelText ?? '',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ),
                          for (final option in options)
                            ListTile(
                              minVerticalPadding: 12,
                              title: Text(option.label),
                              trailing: option.value == field.value
                                  ? Icon(
                                      Icons.check_rounded,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    )
                                  : null,
                              onTap: () => Navigator.pop(sheetContext, option),
                            ),
                        ],
                      ),
                    ),
                  );
                  if (option != null) {
                    field.didChange(option.value);
                    onChanged!(option.value);
                  }
                },
          child: InputDecorator(
            decoration: decoration.copyWith(errorText: field.errorText),
            isEmpty: selectedLabel == null,
            child: Text(
              selectedLabel ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      },
    );
  }
}
