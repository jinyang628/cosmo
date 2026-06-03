import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

class CosmoApp extends StatefulWidget {
  const CosmoApp({super.key});

  @override
  State<CosmoApp> createState() => _CosmoAppState();
}

class _CosmoAppState extends State<CosmoApp> {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cosmo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,
      home: HomeScreen(
        themeMode: _themeMode,
        onThemeModeChanged: (themeMode) {
          setState(() => _themeMode = themeMode);
        },
      ),
    );
  }
}
