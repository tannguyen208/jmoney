import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmoney/widgets/button_label.dart';

void main() {
  testWidgets('button labels stay on one line at narrow widths',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 72,
            child: FilledButton(
              onPressed: null,
              child: ButtonLabel('Nhãn nút rất dài'),
            ),
          ),
        ),
      ),
    );

    final text = tester.widget<Text>(find.text('Nhãn nút rất dài'));
    expect(text.maxLines, 1);
    expect(text.softWrap, isFalse);
    expect(text.overflow, TextOverflow.ellipsis);
    expect(tester.takeException(), isNull);
  });
}
