import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemePreferences {
  const ThemePreferences();

  static const themeModeKey = 'theme_mode';

  Future<ThemeMode> loadThemeMode() async {
    final preferences = SharedPreferencesAsync();
    return _themeModeFromName(await preferences.getString(themeModeKey)) ??
        ThemeMode.light;
  }

  Future<void> saveThemeMode(ThemeMode themeMode) async {
    final preferences = SharedPreferencesAsync();
    await preferences.setString(themeModeKey, themeMode.name);
  }

  ThemeMode? _themeModeFromName(String? name) {
    for (final themeMode in ThemeMode.values) {
      if (themeMode.name == name) {
        return themeMode;
      }
    }

    return null;
  }
}
