import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Единственная точка сборки темы. `ThemeData.dark()` напрямую не использовать.
ThemeData buildAppTheme() {
  const colorScheme = ColorScheme.dark(
    primary: AppColors.accent,
    onPrimary: AppColors.onAccent,
    secondary: AppColors.accent,
    onSecondary: AppColors.onAccent,
    surface: AppColors.surface1,
    onSurface: AppColors.textPrimary,
    surfaceContainerHighest: AppColors.surface2,
    error: AppColors.error,
    onError: AppColors.onAccent,
    outline: AppColors.border,
    outlineVariant: AppColors.divider,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.void0,
    canvasColor: AppColors.void0,
    fontFamily: AppTypography.fontFamily,
    textTheme: AppTypography.textTheme,
    splashFactory: InkSparkle.splashFactory,
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 0.5,
      space: 0.5,
    ),
    // Одно поле ввода на весь проект: имя персонажа, будущий поиск, фильтры.
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface1,
      hintStyle: AppTypography.bodyLarge.copyWith(color: AppColors.textMuted),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      border: const OutlineInputBorder(
        borderRadius: AppRadii.allMd,
        borderSide: BorderSide(color: AppColors.divider, width: 0.5),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: AppRadii.allMd,
        borderSide: BorderSide(color: AppColors.divider, width: 0.5),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: AppRadii.allMd,
        borderSide: BorderSide(color: AppColors.accentLine),
      ),
    ),
    iconTheme: const IconThemeData(color: AppColors.textSecondary, size: 24),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.void0,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: AppTypography.titleLarge,
      iconTheme: IconThemeData(color: AppColors.textPrimary),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface1,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadii.allMd,
        side: const BorderSide(color: AppColors.divider, width: 0.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.onAccent,
        disabledBackgroundColor: AppColors.surface3,
        disabledForegroundColor: AppColors.textMuted,
        elevation: 0,
        minimumSize: const Size.fromHeight(56),
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.allMd),
        textStyle: AppTypography.labelLarge,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.accent,
        textStyle: AppTypography.labelLarge.copyWith(color: AppColors.accent),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface2,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      dragHandleColor: AppColors.surface3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.lg)),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.void0,
      surfaceTintColor: Colors.transparent,
      indicatorColor: AppColors.accentSoft,
      elevation: 0,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => AppTypography.labelSmall.copyWith(
          color: states.contains(WidgetState.selected)
              ? AppColors.accent
              : AppColors.textMuted,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? AppColors.accent
              : AppColors.textMuted,
        ),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.surface2,
      contentTextStyle: AppTypography.bodyMedium,
      behavior: SnackBarBehavior.floating,
      elevation: 0,
    ),
  );
}
