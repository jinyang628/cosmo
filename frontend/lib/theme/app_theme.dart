import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const _seedColor = Color(0xff2f7d4f);
  static const _lightScaffoldBackgroundColor = Color(0xfff8faf7);
  static const _darkScaffoldBackgroundColor = Color(0xff101411);

  static ThemeData get light {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seedColor,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: _lightScaffoldBackgroundColor,
      useMaterial3: true,
    );
  }

  static ThemeData get dark {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seedColor,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: _darkScaffoldBackgroundColor,
      useMaterial3: true,
    );
  }
}
