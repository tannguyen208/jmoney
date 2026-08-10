import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

String formatCurrency(BuildContext context, int value) => NumberFormat.currency(
      locale: Localizations.localeOf(context).toLanguageTag(),
      symbol: '₫',
      decimalDigits: 0,
    ).format(value);

String formatCompactCurrency(BuildContext context, int value) =>
    NumberFormat.compactCurrency(
      locale: Localizations.localeOf(context).toLanguageTag(),
      symbol: '₫',
      decimalDigits: 0,
    ).format(value);

String formatDate(BuildContext context, DateTime value) => DateFormat.yMd(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(value);

String formatMonthYear(BuildContext context, DateTime value) {
  final formatted = DateFormat.yMMMM(
    Localizations.localeOf(context).toLanguageTag(),
  ).format(value);
  if (formatted.isEmpty) return formatted;
  return '${formatted[0].toUpperCase()}${formatted.substring(1)}';
}

int? parseMoney(String value) {
  final normalized = value.replaceAll(RegExp(r'[^0-9]'), '');
  return int.tryParse(normalized);
}

String formatMoneyInput(Locale locale, int value) =>
    NumberFormat.decimalPattern(locale.toLanguageTag()).format(value);

MoneyInputFormatter localizedMoneyInputFormatter(BuildContext context) =>
    MoneyInputFormatter(locale: Localizations.localeOf(context));

void localizeMoneyController(
  BuildContext context,
  TextEditingController controller,
) {
  final amount = parseMoney(controller.text);
  if (amount == null) return;
  final formatted = formatMoneyInput(Localizations.localeOf(context), amount);
  controller.value = TextEditingValue(
    text: formatted,
    selection: TextSelection.collapsed(offset: formatted.length),
  );
}

class MoneyInputFormatter extends TextInputFormatter {
  MoneyInputFormatter({required Locale locale})
      : _separator = NumberFormat.decimalPattern(locale.toLanguageTag())
            .symbols
            .GROUP_SEP;

  final String _separator;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return TextEditingValue.empty;

    final normalized = digits.replaceFirst(RegExp(r'^0+(?=\d)'), '');
    final formatted = _groupDigits(normalized);
    final digitsAfterCursor = _digitCountAfterCursor(newValue);
    final cursorOffset = _cursorOffsetFromRight(
      formatted,
      digitsAfterCursor,
    );

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: cursorOffset),
    );
  }

  String _groupDigits(String digits) {
    final groups = <String>[];
    for (var end = digits.length; end > 0; end -= 3) {
      final start = end - 3 < 0 ? 0 : end - 3;
      groups.insert(0, digits.substring(start, end));
    }
    return groups.join(_separator);
  }

  int _digitCountAfterCursor(TextEditingValue value) {
    final offset = value.selection.extentOffset.clamp(0, value.text.length);
    return value.text
        .substring(offset)
        .replaceAll(RegExp(r'[^0-9]'), '')
        .length;
  }

  int _cursorOffsetFromRight(String value, int digitsAfterCursor) {
    if (digitsAfterCursor == 0) return value.length;
    var remainingDigits = digitsAfterCursor;
    var offset = value.length;
    while (offset > 0 && remainingDigits > 0) {
      offset--;
      if (RegExp(r'[0-9]').hasMatch(value[offset])) remainingDigits--;
    }
    return offset;
  }
}

Color colorFromHex(String? value, {Color fallback = const Color(0xFF247A68)}) {
  if (value == null) return fallback;
  final hex = value.replaceFirst('#', '');
  final parsed = int.tryParse(hex.length == 6 ? 'FF$hex' : hex, radix: 16);
  return parsed == null ? fallback : Color(parsed);
}
