import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('user-facing Dart code contains no hard-coded language', () {
    final dartFiles =
        Directory('lib').listSync(recursive: true).whereType<File>().where(
              (file) =>
                  file.path.endsWith('.dart') &&
                  !file.path.contains(
                      '${Platform.pathSeparator}l10n${Platform.pathSeparator}'),
            );
    final vietnameseText = RegExp(
      r'[ÀÁẠẢÃÂẦẤẬẨẪĂẰẮẶẲẴÈÉẸẺẼÊỀẾỆỂỄÌÍỊỈĨ'
      r'ÒÓỌỎÕÔỒỐỘỔỖƠỜỚỢỞỠÙÚỤỦŨƯỪỨỰỬỮỲÝỴỶỸĐ'
      r'àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩ'
      r'òóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ]',
    );
    final directUiLiteral = RegExp(
      r'''(?:Text|Tooltip|SnackBar)\s*\(\s*(?:const\s*)?["'][A-Za-z]''',
    );
    final violations = <String>[];

    for (final file in dartFiles) {
      final source = file.readAsStringSync();
      if (vietnameseText.hasMatch(source) || directUiLiteral.hasMatch(source)) {
        violations.add(file.path);
      }
    }

    expect(
      violations,
      isEmpty,
      reason: 'Move user-facing strings to AppLocalizations: $violations',
    );
  });
}
