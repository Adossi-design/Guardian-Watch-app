import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/app_spacing.dart';

abstract final class LightTheme {
  static ThemeData get data => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          onPrimary: AppColors.textOnPrimary,
          primaryContainer: Color(0xFFDBEAFE),
          onPrimaryContainer: AppColors.primaryDark,
          secondary: AppColors.safeGreen,
          onSecondary: AppColors.textOnPrimary,
          error: AppColors.emergencyRed,
          onError: AppColors.textOnPrimary,
          surface: AppColors.surfaceLight,
          onSurface: AppColors.textPrimary,
          surfaceContainerHighest: Color(0xFFF3F4F6),
          outline: AppColors.borderLight,
          outlineVariant: Color(0xFFE5E7EB),
        ),
        scaffoldBackgroundColor: AppColors.backgroundLight,
        cardTheme: const CardThemeData(
          color: AppColors.cardLight,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusLg)),
            side: BorderSide(color: AppColors.borderLight, width: 1),
          ),
          margin: EdgeInsets.zero,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.backgroundLight,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          scrolledUnderElevation: 1,
          centerTitle: false,
          titleTextStyle: AppTypography.titleLarge,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
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
            foregroundColor: AppColors.primary,
            minimumSize: const Size(double.infinity, AppSpacing.touchTargetMin),
            side: const BorderSide(color: AppColors.primary, width: 1.5),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(AppSpacing.radiusMd)),
            ),
            textStyle: AppTypography.button,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            minimumSize: const Size(56, AppSpacing.touchTargetMin),
            textStyle: AppTypography.bodyMedium,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceLight,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          border: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(AppSpacing.radiusMd)),
            borderSide: const BorderSide(color: AppColors.borderLight, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(AppSpacing.radiusMd)),
            borderSide: const BorderSide(color: AppColors.borderLight, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(AppSpacing.radiusMd)),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
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
          displayLarge: AppTypography.display,
          headlineLarge: AppTypography.headline,
          titleLarge: AppTypography.titleLarge,
          titleMedium: AppTypography.titleMedium,
          bodyLarge: AppTypography.bodyLarge,
          bodyMedium: AppTypography.body,
          bodySmall: AppTypography.label,
          labelLarge: AppTypography.button,
          labelMedium: AppTypography.label,
          labelSmall: AppTypography.labelSmall,
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.borderLight,
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
          backgroundColor: AppColors.surfaceLight,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: AppTypography.labelSmall,
          unselectedLabelStyle: AppTypography.labelSmall,
        ),
        chipTheme: ChipThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusCircle),
          ),
          labelStyle: AppTypography.label,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
        ),
      );
}
