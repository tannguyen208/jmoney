// THESIS: JMoney behaves like a private local ledger, not a decorative
// dashboard. OWN-WORLD: warm cream, calm system type, hairline rules, and one
// dark balance surface. STORY: choose a month, understand available money,
// then act on jars or transactions. FORM: a flat, readable ledger interface.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'l10n/app_localizations.dart';
import 'providers/finance_provider.dart';
import 'screens/app_shell.dart';
import 'theme/apple_finance_theme.dart';

class JMoneyApp extends StatelessWidget {
  const JMoneyApp({
    super.key,
    required this.provider,
    this.locale = defaultLocale,
  });

  static const defaultLocale = Locale('vi');
  final FinanceProvider provider;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final app = MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(textScaler: TextScaler.noScaling),
          child: child!,
        );
      },
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppleFinanceTheme.build(
        brightness: Brightness.light,
      ),
      darkTheme: AppleFinanceTheme.build(
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: const AppShell(),
    );
    return ChangeNotifierProvider.value(
      value: provider,
      child: app,
    );
  }
}
