import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTypography {
  // Inter via google_fonts — cached after first load.
  // Swap to bundled font by replacing GoogleFonts.inter() with
  // TextStyle(fontFamily: 'Inter') once TTFs are in assets/fonts/.
  static TextStyle inter({
    double? fontSize,
    FontWeight? fontWeight,
    double? height,
    double? letterSpacing,
    Color? color,
  }) =>
      GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: height,
        letterSpacing: letterSpacing,
        color: color,
      );

  static TextStyle get display => inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.5,
      );

  static TextStyle get headline => inter(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        height: 1.3,
        letterSpacing: -0.3,
      );

  static TextStyle get titleLarge => inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  static TextStyle get titleMedium => inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  static TextStyle get bodyLarge => inter(
        fontSize: 20,
        fontWeight: FontWeight.w400,
        height: 1.6,
      );

  // 18sp minimum for accessible UI — per spec Section 11
  static TextStyle get body => inter(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 1.6,
      );

  static TextStyle get bodyMedium => inter(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        height: 1.6,
      );

  // 16sp — secondary info only
  static TextStyle get label => inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.4,
      );

  static TextStyle get labelSmall => inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.4,
      );

  static TextStyle get button => inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: 0.2,
      );

  static TextStyle get emergencyTitle => inter(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        height: 1.1,
        letterSpacing: -0.5,
      );
}
