import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmoney/utils/formatters.dart';

void main() {
  test('groups Vietnamese money input with dots', () {
    final formatter = MoneyInputFormatter(locale: const Locale('vi'));

    final result = formatter.formatEditUpdate(
      TextEditingValue.empty,
      const TextEditingValue(
        text: '1000000',
        selection: TextSelection.collapsed(offset: 7),
      ),
    );

    expect(result.text, '1.000.000');
    expect(result.selection.extentOffset, result.text.length);
    expect(parseMoney(result.text), 1000000);
  });

  test('groups English money input with commas', () {
    final formatter = MoneyInputFormatter(locale: const Locale('en'));

    final result = formatter.formatEditUpdate(
      TextEditingValue.empty,
      const TextEditingValue(
        text: '123456789',
        selection: TextSelection.collapsed(offset: 9),
      ),
    );

    expect(result.text, '123,456,789');
    expect(parseMoney(result.text), 123456789);
  });

  test('keeps the cursor near the edited digit', () {
    final formatter = MoneyInputFormatter(locale: const Locale('vi'));

    final result = formatter.formatEditUpdate(
      const TextEditingValue(
        text: '12.345',
        selection: TextSelection.collapsed(offset: 2),
      ),
      const TextEditingValue(
        text: '102.345',
        selection: TextSelection.collapsed(offset: 2),
      ),
    );

    expect(result.text, '102.345');
    expect(result.selection.extentOffset, 2);
  });
}
