import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

Future<DateTime?> pickMonth(
  BuildContext context, {
  required DateTime initialDate,
}) {
  return showDialog<DateTime>(
    context: context,
    builder: (_) => _MonthPickerDialog(initialDate: initialDate),
  );
}

class _MonthPickerDialog extends StatefulWidget {
  const _MonthPickerDialog({required this.initialDate});

  final DateTime initialDate;

  @override
  State<_MonthPickerDialog> createState() => _MonthPickerDialogState();
}

class _MonthPickerDialogState extends State<_MonthPickerDialog> {
  late int _year;

  @override
  void initState() {
    super.initState();
    _year = widget.initialDate.year;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final selectedMonth =
        widget.initialDate.year == _year ? widget.initialDate.month : null;
    return AlertDialog(
      title: Row(
        children: [
          IconButton(
            tooltip: l10n.previousMonth,
            onPressed: () => setState(() => _year--),
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          Expanded(
            child: Text(
              '$_year',
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            tooltip: l10n.nextMonth,
            onPressed: () => setState(() => _year++),
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () {
                final now = DateTime.now();
                Navigator.pop(context, DateTime(now.year, now.month, 1));
              },
              child: Text(l10n.thisMonth),
            ),
            GridView.builder(
              shrinkWrap: true,
              itemCount: 12,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisExtent: 44,
              ),
              itemBuilder: (context, index) {
                final month = index + 1;
                final selected = month == selectedMonth;
                return TextButton(
                  key: ValueKey('month-picker-$_year-$month'),
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: EdgeInsets.zero,
                    backgroundColor: selected
                        ? Theme.of(context).colorScheme.primaryContainer
                        : null,
                  ),
                  onPressed: () => Navigator.pop(
                    context,
                    DateTime(_year, month, 1),
                  ),
                  child: Text(month.toString().padLeft(2, '0')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
