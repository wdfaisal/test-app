import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF06C167);
  static const primaryDark = Color(0xFF049E55);
  static const primarySoft = Color(0xFFE8F9F0);
  static const charcoal = Color(0xFF202020);
  static const background = Color(0xFFF8F8F8);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF202020);
  static const textSecondary = Color(0xFF757575);
  static const textTertiary = Color(0xFFA0A0A0);
  static const success = Color(0xFF16A34A);
  static const border = Color(0xFFEEEEEE);
  static const cream = Color(0xFFF3F0E8);
  static const amber = Color(0xFFFFB020);
  static const danger = Color(0xFFE5484D);
  static const inkSoft = Color(0xFFF2F3F2);
}

class AppTextStyles {
  static const display = TextStyle(
    fontFamily: 'Noto Kufi Arabic',
    fontVariations: [FontVariation('wght', 700)],
    fontSize: 30,
    height: 1.35,
    color: AppColors.textPrimary,
    letterSpacing: -0.6,
  );

  static const headline = TextStyle(
    fontFamily: 'Noto Kufi Arabic',
    fontVariations: [FontVariation('wght', 700)],
    fontSize: 21,
    height: 1.45,
    color: AppColors.textPrimary,
    letterSpacing: -0.25,
  );

  static const title = TextStyle(
    fontFamily: 'IBM Plex Sans Arabic',
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.45,
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
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: AppColors.textPrimary,
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
      headlineLarge: AppTextStyles.display.copyWith(fontSize: 27),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      hintStyle: AppTextStyles.body.copyWith(color: AppColors.textTertiary),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.danger),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 56),
        textStyle: AppTextStyles.titleSmall.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        elevation: 0,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.charcoal,
      contentTextStyle: AppTextStyles.bodySmall.copyWith(color: Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.all(16),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppTextStyles.title,
    ),
  );
}

String money(num value, {bool decimals = false}) {
  final text = decimals
      ? value.toStringAsFixed(2).replaceAll('.00', '')
      : (value == value.roundToDouble()
            ? value.toStringAsFixed(0)
            : value.toStringAsFixed(2));
  return '$text ر.س';
}

String twoDigits(double value) => value.toStringAsFixed(2);

Color surfaceShadow = Colors.black.withValues(alpha: 0.055);
