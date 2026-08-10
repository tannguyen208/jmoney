import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmoney/app.dart';
import 'package:jmoney/l10n/app_localizations_en.dart';
import 'package:jmoney/providers/finance_provider.dart';
import 'package:jmoney/storage/finance_storage.dart';
import 'package:jmoney/storage/key_value_store.dart';
import 'package:jmoney/widgets/jar_card.dart';

void main() {
  testWidgets('uses Vietnamese as the default locale', (tester) async {
    final provider = FinanceProvider(
      storage: FinanceStorage(
        keyValueStore: MemoryKeyValueStore(),
      ),
    );
    await provider.initialize();

    await tester.pumpWidget(JMoneyApp(provider: provider));
    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));

    expect(app.locale, const Locale('vi'));
    expect(app.themeMode, ThemeMode.system);
    expect(app.theme!.textTheme.bodyLarge!.fontSize, 16);
    expect(app.theme!.textTheme.bodyLarge!.fontWeight, FontWeight.w400);
    expect(app.theme!.textTheme.titleLarge!.fontSize, 20);
    expect(app.theme!.textTheme.titleLarge!.fontWeight, FontWeight.w600);
    expect(
      app.theme!.scaffoldBackgroundColor,
      app.theme!.colorScheme.surface,
    );
    expect(
      _contrastRatio(
        app.theme!.colorScheme.onSurfaceVariant,
        app.theme!.colorScheme.surface,
      ),
      greaterThanOrEqualTo(4.5),
    );
    expect(find.text('Tổng số dư'), findsOneWidget);
    expect(find.byKey(const ValueKey('jmoney-brand-mark')), findsOneWidget);
    expect(find.byKey(const ValueKey('home-calendar-button')), findsOneWidget);
    expect(find.byKey(const ValueKey('month-previous')), findsNothing);
    expect(find.byKey(const ValueKey('month-current')), findsNothing);
    expect(find.byKey(const ValueKey('month-next')), findsNothing);
    expect(find.byTooltip('Quản lý hũ'), findsNothing);
    expect(find.text('Thêm giao dịch'), findsNothing);
    expect(find.text('Kế hoạch tháng'), findsNothing);
    expect(find.text('Quản lý hũ'), findsNothing);
    expect(find.byType(FloatingActionButton), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('home-calendar-button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('month-picker-2026-8')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('month-picker-2026-8')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Nhu cầu thiết yếu'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Nhu cầu thiết yếu'), findsOneWidget);
    expect(find.text('Tiết kiệm & Đầu tư'), findsOneWidget);
    expect(find.text('Hưởng thụ'), findsOneWidget);
    expect(find.text('Giáo dục & Phát triển'), findsOneWidget);
  });

  testWidgets('localizes initial data when English is selected',
      (tester) async {
    final provider = FinanceProvider(
      storage: FinanceStorage(
        keyValueStore: MemoryKeyValueStore(),
        localizations: AppLocalizationsEn(),
      ),
    );
    await provider.initialize();

    await tester.pumpWidget(
      JMoneyApp(
        provider: provider,
        locale: const Locale('en'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Total balance'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Essentials'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Essentials'), findsOneWidget);
    expect(find.text('Savings & investments'), findsOneWidget);
    expect(find.text('Enjoyment'), findsOneWidget);
    expect(find.text('Education & growth'), findsOneWidget);
  });

  testWidgets('respects system text scaling at 200%', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final provider = FinanceProvider(
      storage: FinanceStorage(
        keyValueStore: MemoryKeyValueStore(),
      ),
    );
    await provider.initialize();

    await tester.pumpWidget(JMoneyApp(provider: provider));
    await tester.pumpAndSettle();

    final brandContext = tester.element(
      find.byKey(const ValueKey('jmoney-brand-mark')),
    );
    expect(MediaQuery.textScalerOf(brandContext).scale(16), 32);
    await tester.scrollUntilVisible(
      find.text(provider.jars.first.name),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    final accessibleCards = find.byType(JarCard);
    expect(accessibleCards, findsNWidgets(4));
    expect(
      tester.getCenter(accessibleCards.at(0)).dx,
      closeTo(tester.getCenter(accessibleCards.at(1)).dx, 0.1),
    );
    expect(
      tester.getCenter(accessibleCards.at(0)).dy,
      isNot(closeTo(tester.getCenter(accessibleCards.at(1)).dy, 0.1)),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('home jars use a compact two-column grid on phones',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final provider = FinanceProvider(
      storage: FinanceStorage(keyValueStore: MemoryKeyValueStore()),
    );
    await provider.initialize();

    await tester.pumpWidget(JMoneyApp(provider: provider));
    await tester.pumpAndSettle();

    final cards = find.byType(JarCard);
    expect(cards, findsNWidgets(4));
    final firstSize = tester.getSize(cards.at(0));
    expect(firstSize.width, lessThan(180));
    expect(firstSize.height, lessThan(135));
    expect(
      tester.getCenter(cards.at(0)).dy,
      closeTo(tester.getCenter(cards.at(1)).dy, 0.1),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('follows system Dark Mode with accessible Apple colors',
      (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    final provider = FinanceProvider(
      storage: FinanceStorage(keyValueStore: MemoryKeyValueStore()),
    );
    await provider.initialize();

    await tester.pumpWidget(JMoneyApp(provider: provider));
    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    final theme = Theme.of(tester.element(find.text('JMoney')));
    expect(app.themeMode, ThemeMode.system);
    expect(theme.brightness, Brightness.dark);
    expect(
      _contrastRatio(theme.colorScheme.onSurface, theme.colorScheme.surface),
      greaterThanOrEqualTo(4.5),
    );
    expect(tester.takeException(), isNull);
  });
}

double _contrastRatio(Color foreground, Color background) {
  final foregroundLuminance = foreground.computeLuminance();
  final backgroundLuminance = background.computeLuminance();
  final lighter = foregroundLuminance > backgroundLuminance
      ? foregroundLuminance
      : backgroundLuminance;
  final darker = foregroundLuminance > backgroundLuminance
      ? backgroundLuminance
      : foregroundLuminance;
  return (lighter + 0.05) / (darker + 0.05);
}
