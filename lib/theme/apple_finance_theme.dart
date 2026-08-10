import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'finance_semantic_colors.dart';

// THESIS: JMoney is a calm local ledger, not a decorative finance dashboard.
// OWN-WORLD: warm cream, calm system type, hairline rules, 4px controls, and one
// dark ledger surface. STORY: read the period, inspect a jar, then act.
// FIRST VIEWPORT: title, period, balance, and the next useful action in order.
// FORM: flat grouped lists and ledger rows, with one dark balance surface.
abstract final class AppleFinanceTheme {
  static const _ink = Color(0xFF201D1D);
  static const _inkDeep = Color(0xFF0F0000);
  static const _charcoal = Color(0xFF302C2C);
  static const _body = Color(0xFF424245);
  static const _mute = Color(0xFF646262);
  static const _stone = Color(0xFF6E6E73);
  static const _ash = Color(0xFF9A9898);
  static const _canvas = Color(0xFFFDFCFC);
  static const _surfaceSoft = Color(0xFFF8F7F7);
  static const _surfaceCard = Color(0xFFF1EEEE);
  static const _darkSurface = Color(0xFF201D1D);
  static const _darkElevated = Color(0xFF302C2C);
  static const _accent = Color(0xFF007AFF);
  static const _danger = Color(0xFFFF3B30);
  static const _warning = Color(0xFFFF9F0A);

  static ThemeData build({
    required Brightness brightness,
  }) {
    final dark = brightness == Brightness.dark;
    final canvas = dark ? _inkDeep : _canvas;
    final surface = dark ? _darkSurface : _surfaceSoft;
    final surfaceVariant = dark ? _darkElevated : _surfaceCard;
    final label = dark ? _canvas : _ink;
    final body = dark ? const Color(0xFFE5E1E1) : _body;
    final secondary = dark ? _ash : _mute;
    final outline = dark ? _stone : _mute;
    final separator = dark ? _charcoal : const Color(0x1F0F0000);
    final error = dark ? const Color(0xFFFF453A) : _danger;
    final scheme = ColorScheme.fromSeed(
      seedColor: _accent,
      brightness: brightness,
      surface: canvas,
    ).copyWith(
      primary: _accent,
      onPrimary: _canvas,
      primaryContainer:
          dark ? const Color(0xFF004085) : const Color(0xFFE5F0FF),
      onPrimaryContainer: dark ? _canvas : const Color(0xFF004085),
      secondary: _charcoal,
      onSecondary: _canvas,
      secondaryContainer: surfaceVariant,
      onSecondaryContainer: label,
      tertiary: _warning,
      onTertiary: _ink,
      tertiaryContainer:
          dark ? const Color(0xFF5B3200) : const Color(0xFFFFF0D6),
      onTertiaryContainer:
          dark ? const Color(0xFFFFE0AE) : const Color(0xFF5B3200),
      error: error,
      onError: _canvas,
      errorContainer: dark ? const Color(0xFF650A05) : const Color(0xFFFFE3E0),
      onErrorContainer:
          dark ? const Color(0xFFFFDAD6) : const Color(0xFF650A05),
      surface: canvas,
      surfaceContainerLowest: canvas,
      surfaceContainerLow: surface,
      surfaceContainer: surface,
      surfaceContainerHigh: surfaceVariant,
      surfaceContainerHighest: dark ? const Color(0xFF424245) : _surfaceCard,
      onSurface: label,
      onSurfaceVariant: secondary,
      outline: outline,
      outlineVariant: separator,
      shadow: Colors.transparent,
      scrim: _inkDeep,
    );
    final textTheme = _textTheme(brightness, body: body, label: label);
    final controlShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      scaffoldBackgroundColor: canvas,
      canvasColor: canvas,
      splashFactory: NoSplash.splashFactory,
      highlightColor: label.withValues(alpha: 0.06),
      hoverColor: label.withValues(alpha: 0.04),
      visualDensity: VisualDensity.standard,
      extensions: <ThemeExtension<dynamic>>[
        dark
            ? FinanceSemanticColors.appleDark
            : FinanceSemanticColors.appleLight,
      ],
      cupertinoOverrideTheme: CupertinoThemeData(
        brightness: brightness,
        primaryColor: _accent,
        scaffoldBackgroundColor: canvas,
        barBackgroundColor: surface,
        textTheme: CupertinoTextThemeData(primaryColor: _accent),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: canvas,
        foregroundColor: label,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(color: label),
        systemOverlayStyle:
            dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: label,
        textColor: label,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        minTileHeight: 52,
        titleTextStyle: textTheme.bodyLarge?.copyWith(color: label),
        subtitleTextStyle: textTheme.bodyMedium?.copyWith(color: secondary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        labelStyle: TextStyle(color: secondary),
        hintStyle: TextStyle(color: secondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: separator),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: separator),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: dark ? _canvas : _ink, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: error, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      searchBarTheme: SearchBarThemeData(
        elevation: const WidgetStatePropertyAll(0),
        backgroundColor: WidgetStatePropertyAll(surface),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        shape: WidgetStatePropertyAll(controlShape),
        hintStyle: WidgetStatePropertyAll(
          textTheme.bodyLarge?.copyWith(color: secondary),
        ),
        textStyle: WidgetStatePropertyAll(
          textTheme.bodyLarge?.copyWith(color: label),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        height: 64,
        backgroundColor: canvas,
        indicatorColor: Colors.transparent,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? label : secondary,
            size: 22,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelSmall?.copyWith(
            color: selected ? label : secondary,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
          );
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        elevation: 0,
        backgroundColor: canvas,
        indicatorColor: Colors.transparent,
        selectedIconTheme: IconThemeData(color: label),
        unselectedIconTheme: IconThemeData(color: secondary),
        selectedLabelTextStyle: textTheme.labelMedium?.copyWith(
          color: label,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelTextStyle:
            textTheme.labelMedium?.copyWith(color: secondary),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          backgroundColor: _ink,
          foregroundColor: _canvas,
          disabledBackgroundColor: surfaceVariant,
          disabledForegroundColor: _ash,
          shape: controlShape,
          textStyle: textTheme.labelLarge?.copyWith(height: 1.25),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          foregroundColor: label,
          side: BorderSide(color: outline),
          shape: controlShape,
          textStyle: textTheme.labelLarge?.copyWith(height: 1.25),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(44, 44),
          foregroundColor: label,
          shape: controlShape,
          textStyle: textTheme.labelLarge?.copyWith(height: 1.25),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size.square(44),
          foregroundColor: label,
          shape: controlShape,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 0,
        highlightElevation: 0,
        backgroundColor: _ink,
        foregroundColor: _canvas,
        shape: controlShape,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(44, 40)),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            return states.contains(WidgetState.selected)
                ? surfaceVariant
                : null;
          }),
          foregroundColor: WidgetStatePropertyAll(label),
          side: WidgetStatePropertyAll(BorderSide(color: separator)),
          shape: WidgetStatePropertyAll(controlShape),
          textStyle: WidgetStatePropertyAll(textTheme.labelMedium),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStatePropertyAll(_canvas),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? _accent
              : surfaceVariant;
        }),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? _ink
              : Colors.transparent;
        }),
        checkColor: const WidgetStatePropertyAll(_canvas),
        side: BorderSide(color: secondary),
        shape: controlShape,
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected) ? _ink : secondary;
        }),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        modalBackgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: controlShape,
        titleTextStyle: textTheme.titleLarge?.copyWith(color: label),
        contentTextStyle: textTheme.bodyLarge?.copyWith(color: body),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: _ink,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: _canvas),
        shape: controlShape,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: _accent,
        linearTrackColor: surfaceVariant,
      ),
    );
  }

  static TextTheme _textTheme(
    Brightness brightness, {
    required Color body,
    required Color label,
  }) {
    final typography = Typography.material2021(platform: defaultTargetPlatform);
    final base =
        brightness == Brightness.dark ? typography.white : typography.black;
    final system = base.apply(bodyColor: body, displayColor: label);
    return system.copyWith(
      displaySmall: system.displaySmall?.copyWith(
        fontSize: 38,
        fontWeight: FontWeight.w700,
        height: 1.5,
        letterSpacing: 0,
      ),
      headlineMedium: system.headlineMedium?.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.5,
        letterSpacing: 0,
      ),
      headlineSmall: system.headlineSmall?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 1.5,
        letterSpacing: 0,
      ),
      titleLarge: system.titleLarge?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.5,
        letterSpacing: 0,
      ),
      titleMedium: system.titleMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        height: 1.5,
      ),
      titleSmall: system.titleSmall?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 2,
      ),
      bodyLarge: system.bodyLarge?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      bodyMedium: system.bodyMedium?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      bodySmall: system.bodySmall?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 2,
      ),
      labelLarge: system.labelLarge?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 2,
      ),
      labelMedium: system.labelMedium?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 2,
      ),
      labelSmall: system.labelSmall?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
    );
  }
}
