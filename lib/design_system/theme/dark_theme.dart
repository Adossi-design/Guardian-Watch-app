import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/app_spacing.dart';

abstract final class DarkTheme {
  static ThemeData get data => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primaryLight,
          onPrimary: AppColors.textOnPrimary,
          primaryContainer: AppColors.primaryDark,
          onPrimaryContainer: Color(0xFFDBEAFE),
          secondary: AppColors.safeGreenLight,
          onSecondary: AppColors.textPrimary,
          error: AppColors.emergencyRed,
          onError: AppColors.textOnPrimary,
          surface: AppColors.surfaceDark,
          onSurface: AppColors.textOnDark,
          surfaceContainerHighest: AppColors.cardDark,
          outline: AppColors.borderDark,
          outlineVariant: Color(0xFF4B5563),
        ),
        scaffoldBackgroundColor: AppColors.backgroundDark,
        cardTheme: const CardThemeData(
          color: AppColors.cardDark,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusLg)),
            side: BorderSide(color: AppColors.borderDark, width: 1),
          ),
          margin: EdgeInsets.zero,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.backgroundDark,
          foregroundColor: AppColors.textOnDark,
          elevation: 0,
          scrolledUnderElevation: 1,
          centerTitle: false,
          titleTextStyle: AppTypography.titleLarge,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryLight,
            foregroundColor: AppColors.textOnPrimary,
            minimumSize: const Size(double.infinity, AppSpacing.touchTargetMin),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusMd)),
            ),
            textStyle: AppTypography.button,
            elevation: 0,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryLight,
            minimumSize: const Size(double.infinity, AppSpacing.touchTargetMin),
            side: const BorderSide(color: AppColors.primaryLight, width: 1.5),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusMd)),
            ),
            textStyle: AppTypography.button,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primaryLight,
            minimumSize: const Size(56, AppSpacing.touchTargetMin),
            textStyle: AppTypography.bodyMedium,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceDark,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          border: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(AppSpacing.radiusMd)),
            borderSide: const BorderSide(color: AppColors.borderDark, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(AppSpacing.radiusMd)),
            borderSide: const BorderSide(color: AppColors.borderDark, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(AppSpacing.radiusMd)),
            borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(AppSpacing.radiusMd)),
            borderSide: const BorderSide(color: AppColors.emergencyRed, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(AppSpacing.radiusMd)),
            borderSide: const BorderSide(color: AppColors.emergencyRed, width: 2),
          ),
          labelStyle: AppTypography.body.copyWith(color: AppColors.textSecondary),
          hintStyle: AppTypography.body.copyWith(color: AppColors.textDisabled),
          errorStyle: AppTypography.label.copyWith(color: AppColors.emergencyRed),
        ),
        textTheme: TextTheme(
          displayLarge: AppTypography.display.copyWith(color: AppColors.textOnDark),
          headlineLarge: AppTypography.headline.copyWith(color: AppColors.textOnDark),
          titleLarge: AppTypography.titleLarge.copyWith(color: AppColors.textOnDark),
          titleMedium: AppTypography.titleMedium.copyWith(color: AppColors.textOnDark),
          bodyLarge: AppTypography.bodyLarge.copyWith(color: AppColors.textOnDark),
          bodyMedium: AppTypography.body.copyWith(color: AppColors.textOnDark),
          bodySmall: AppTypography.label.copyWith(color: AppColors.textSecondary),
          labelLarge: AppTypography.button.copyWith(color: AppColors.textOnDark),
          labelMedium: AppTypography.label.copyWith(color: AppColors.textSecondary),
          labelSmall: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.borderDark,
          thickness: 1,
          space: 0,
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: AppColors.surfaceDark,
          selectedItemColor: AppColors.primaryLight,
          unselectedItemColor: AppColors.textSecondary,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: AppTypography.labelSmall,
          unselectedLabelStyle: AppTypography.labelSmall,
        ),
      );
}
