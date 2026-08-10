import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmoney/models/category.dart';
import 'package:jmoney/widgets/category_icon.dart';

void main() {
  test('maps every default and legacy category icon to a unique Koboyo asset',
      () {
    expect(categoryIconOptions, hasLength(20));
    expect(incomeCategoryIconOptions, hasLength(7));
    expect(
      [...categoryIconOptions, ...incomeCategoryIconOptions]
          .map((option) => option.asset)
          .toSet(),
      hasLength(27),
    );
    for (final option in [
      ...categoryIconOptions,
      ...incomeCategoryIconOptions,
    ]) {
      expect(categoryIconAsset(option.key), option.asset);
      expect(categoryIconAsset(option.legacyIcon), option.asset);
    }
  });

  testWidgets('renders a bundled Koboyo asset for a legacy category',
      (tester) async {
    const category = Category(name: 'Ăn uống', icon: '🍜');
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CategoryIcon(category: category),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SvgPicture), findsOneWidget);
    expect(categoryIconAsset('🍜'), 'assets/koboyo/food.svg');
    expect(tester.takeException(), isNull);
  });

  test('bundles the branding and Koboyo asset files', () async {
    expect(
        (await rootBundle.load('assets/branding/jmoney_app_mark.png'))
            .lengthInBytes,
        greaterThan(0));
    expect((await rootBundle.load('assets/koboyo/food.svg')).lengthInBytes,
        greaterThan(0));
  });
}
