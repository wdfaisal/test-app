import 'package:flutter/material.dart';

/// YallaTalabat design tokens — extracted from the supplied Stitch exports.
///
/// Canvas is white-first: #FFFFFF cards over #F7F9FF, hairline #EEEEEE borders.
/// Brand orange #FF591B drives primary actions, crimson #AD3300 anchors text
/// accents, and dark #181C20 powers the floating pills / snackbars.
class AppColors {
  // Brand
  static const primary = Color(0xFFFF591B);
  static const primaryDark = Color(0xFFAD3300);
  static const primarySoft = Color(0xFFFFEDE3);
  static const crimson = Color(0xFFFF3E00);

  // Neutrals
  static const charcoal = Color(0xFF181C20);
  static const dark = Color(0xFF181C20);
  static const darkSoft = Color(0xFF2D3135);
  static const background = Color(0xFFF7F9FF);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceLow = Color(0xFFF1F4F9);
  static const surfaceContainer = Color(0xFFEBEEF3);
  static const surfaceHigh = Color(0xFFE5E8ED);
  static const surfaceHighest = Color(0xFFE0E3E8);
  static const inkSoft = Color(0xFFF1F4F9);

  // Text
  static const textPrimary = Color(0xFF181C20);
  static const textSecondary = Color(0xFF5F5E5E);
  static const textTertiary = Color(0xFF9AA0A6);

  // Semantic
  static const success = Color(0xFF10B981);
  static const green = Color(0xFF00A673);
  static const greenDark = Color(0xFF006C49);
  static const border = Color(0xFFEEEEEE);
  static const cream = Color(0xFFF1F4F9);
  static const amber = Color(0xFFF59E0B);
  static const amberDeep = Color(0xFFD97706);
  static const danger = Color(0xFFEF4444);

  // Signature orange glow used by floating dark pills.
  static const List<BoxShadow> pillGlow = [
    BoxShadow(
      color: Color(0x73FF591B),
      blurRadius: 25,
      offset: Offset(0, 10),
    ),
    BoxShadow(
      color: Color(0x59FF591B),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];
}

/// Formats [value] as a Saudi Riyal price string, e.g. `42 ر.س`.
String money(num value, {bool decimals = false}) {
  final text = decimals
      ? value.toStringAsFixed(2).replaceAll('.00', '')
      : (value == value.roundToDouble()
            ? value.toStringAsFixed(0)
            : value.toStringAsFixed(2));
  return '$text ر.س';
}

class AppTextStyles {
  static const display = TextStyle(
    fontFamily: 'IBM Plex Sans Arabic',
    fontSize: 26,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static const headline = TextStyle(
    fontFamily: 'IBM Plex Sans Arabic',
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.4,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  static const title = TextStyle(
    fontFamily: 'IBM Plex Sans Arabic',
    fontSize: 17,
    fontWeight: FontWeight.w700,
    height: 1.4,
    color: AppColors.textPrimary,
    letterSpacing: -0.15,
  );

  static const titleSmall = TextStyle(
    fontFamily: 'IBM Plex Sans Arabic',
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.45,
    color: AppColors.textPrimary,
  );

  static const body = TextStyle(
    fontFamily: 'IBM Plex Sans Arabic',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.65,
    color: AppColors.textSecondary,
  );

  static const bodySmall = TextStyle(
    fontFamily: 'IBM Plex Sans Arabic',
    fontSize: 12.5,
    fontWeight: FontWeight.w400,
    height: 1.55,
    color: AppColors.textSecondary,
  );

  static const label = TextStyle(
    fontFamily: 'IBM Plex Sans Arabic',
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  static const caption = TextStyle(
    fontFamily: 'IBM Plex Sans Arabic',
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  static const price = TextStyle(
    fontFamily: 'IBM Plex Sans Arabic',
    fontSize: 17,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: AppColors.primaryDark,
  );

  static const latinBrand = TextStyle(
    fontFamily: 'IBM Plex Sans Arabic',
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 3.2,
    color: AppColors.textSecondary,
  );
}

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: 'IBM Plex Sans Arabic',
    scaffoldBackgroundColor: AppColors.background,
  );

  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: Colors.white,
    secondary: AppColors.charcoal,
    onSecondary: Colors.white,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    error: AppColors.danger,
  );

  return base.copyWith(
    colorScheme: scheme,
    textTheme: base.textTheme.copyWith(
      displayLarge: AppTextStyles.display,
      headlineLarge: AppTextStyles.display.copyWith(fontSize: 24),
      headlineMedium: AppTextStyles.headline,
      headlineSmall: AppTextStyles.headline.copyWith(fontSize: 18),
      titleLarge: AppTextStyles.title,
      titleMedium: AppTextStyles.titleSmall,
      bodyLarge: AppTextStyles.body.copyWith(fontSize: 15),
      bodyMedium: AppTextStyles.body,
      bodySmall: AppTextStyles.bodySmall,
      labelLarge: AppTextStyles.label,
      labelMedium: AppTextStyles.caption,
      labelSmall: AppTextStyles.caption.copyWith(fontSize: 10.5),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 1,
      space: 1,
    ),
    splashFactory: InkSparkle.splashFactory,
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      hintStyle: AppTextStyles.body.copyWith(color: AppColors.textTertiary),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.danger),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 50),
        textStyle: AppTextStyles.titleSmall.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.charcoal,
      contentTextStyle: AppTextStyles.bodySmall.copyWith(color: Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      insetPadding: const EdgeInsets.all(16),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppTextStyles.title,
      iconTheme: IconThemeData(color: AppColors.textPrimary),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.primary
            : AppColors.surfaceHighest,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      side: const BorderSide(color: AppColors.border, width: 1.4),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.primary
            : AppColors.textTertiary,
      ),
    ),
  );
}
