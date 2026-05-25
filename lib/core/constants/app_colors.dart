import 'package:flutter/material.dart';

abstract final class AppColors {
  // Primary brand
  static const Color primary = Color(0xFF1A56DB);
  static const Color primaryDark = Color(0xFF1E3A8A);
  static const Color primaryLight = Color(0xFF3B82F6);

  // Semantic alert colors
  static const Color emergencyRed = Color(0xFFDC2626);
  static const Color emergencyRedDark = Color(0xFFB91C1C);
  static const Color warningAmber = Color(0xFFD97706);
  static const Color warningAmberLight = Color(0xFFFBBF24);
  static const Color safeGreen = Color(0xFF16A34A);
  static const Color safeGreenLight = Color(0xFF22C55E);

  // Backgrounds (light / dark)
  static const Color backgroundLight = Color(0xFFF9FAFB);
  static const Color backgroundDark = Color(0xFF111827);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1F2937);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF374151);

  // Text
  static const Color textPrimary = Color(0xFF111928);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textDisabled = Color(0xFF9CA3AF);
  static const Color textOnDark = Color(0xFFF9FAFB);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Borders
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color borderDark = Color(0xFF374151);

  // Severity chips
  static const Color severityCritical = emergencyRed;
  static const Color severityHigh = Color(0xFFEA580C);
  static const Color severityMedium = warningAmber;
  static const Color severityLow = safeGreen;

  // Health metric backgrounds
  static const Color heartRateBg = Color(0xFFFEF2F2);
  static const Color spo2Bg = Color(0xFFEFF6FF);
  static const Color activityBg = Color(0xFFF0FDF4);
  static const Color sleepBg = Color(0xFFF5F3FF);
}
