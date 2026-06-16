import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'config/api_config.dart';
import 'theme/theme_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  const themePreferences = ThemePreferences();
  var themeMode = ThemeMode.light;
  try {
    themeMode = await themePreferences.loadThemeMode();
  } catch (error, stackTrace) {
    debugPrint('CosmoApp: could not load theme preference: $error');
    debugPrintStack(stackTrace: stackTrace);
  }
  await Supabase.initialize(
    url: ApiConfig.supabaseUrl,
    anonKey: ApiConfig.supabaseAnonKey,
  );
  runApp(
    CosmoApp(initialThemeMode: themeMode, themePreferences: themePreferences),
  );
}
