import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'light_theme.dart';
import 'dark_theme.dart';

export 'light_theme.dart';
export 'dark_theme.dart';

abstract final class AppTheme {
  static ThemeData get light => LightTheme.data;
  static ThemeData get dark => DarkTheme.data;

  static SystemUiOverlayStyle get lightSystemUi => const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0xFFF9FAFB),
        systemNavigationBarIconBrightness: Brightness.dark,
      );

  static SystemUiOverlayStyle get darkSystemUi => const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF111827),
        systemNavigationBarIconBrightness: Brightness.light,
      );
}
