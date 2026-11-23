import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Типографическая шкала. Один шрифт на весь проект — Inter.
///
/// Файл `assets/fonts/Inter.ttf` — вариативный (оси `opsz`, `wght`), поэтому
/// вес задаётся не только `fontWeight`, но и осью `fontVariations`.
abstract final class AppTypography {
  static const String fontFamily = 'Inter';

  /// Герой-число: результат броска. Единственное место, где размер выше 40.
  static const TextStyle displayHero = TextStyle(
    fontFamily: fontFamily,
    fontSize: 72,
    height: 1,
    fontWeight: FontWeight.w900,
    fontVariations: [FontVariation('wght', 900)],
    letterSpacing: -2.0,
    color: AppColors.textPrimary,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 40,
    height: 44 / 40,
    fontWeight: FontWeight.w900,
    fontVariations: [FontVariation('wght', 900)],
    letterSpacing: -1.0,
    color: AppColors.textPrimary,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    height: 36 / 32,
    fontWeight: FontWeight.w900,
    fontVariations: [FontVariation('wght', 900)],
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    height: 28 / 24,
    fontWeight: FontWeight.w800,
    fontVariations: [FontVariation('wght', 800)],
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    height: 24 / 20,
    fontWeight: FontWeight.w700,
    fontVariations: [FontVariation('wght', 700)],
    letterSpacing: -0.2,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 20 / 16,
    fontWeight: FontWeight.w600,
    fontVariations: [FontVariation('wght', 600)],
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    height: 22 / 15,
    fontWeight: FontWeight.w400,
    fontVariations: [FontVariation('wght', 400)],
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
    fontVariations: [FontVariation('wght', 400)],
    color: AppColors.textSecondary,
  );

  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    height: 16 / 15,
    fontWeight: FontWeight.w600,
    fontVariations: [FontVariation('wght', 600)],
    letterSpacing: 0.2,
    color: AppColors.onAccent,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    height: 14 / 11,
    fontWeight: FontWeight.w600,
    fontVariations: [FontVariation('wght', 600)],
    letterSpacing: 0.6,
    color: AppColors.textMuted,
  );

  /// Готовая [TextTheme] для [ThemeData].
  static const TextTheme textTheme = TextTheme(
    displayLarge: displayLarge,
    displayMedium: displayMedium,
    headlineMedium: headlineMedium,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    labelLarge: labelLarge,
    labelSmall: labelSmall,
  );
}
