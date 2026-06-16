import 'dart:async';

import 'package:flutter/material.dart';

import 'auth/auth_service.dart';
import 'pages/sign_in_page.dart';
import 'preferences/preferences_api.dart';
import 'restaurants/restaurants_api.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';
import 'theme/theme_preferences.dart';

class CosmoApp extends StatefulWidget {
  CosmoApp({
    this.preferencesApi = const PreferencesApi(),
    this.restaurantsApi = const RestaurantsApi(),
    this.initialThemeMode,
    this.themePreferences = const ThemePreferences(),
    AuthService? authService,
    super.key,
  }) : authService = authService ?? SupabaseAuthService();

  final PreferencesApi preferencesApi;
  final RestaurantsApi restaurantsApi;
  final AuthService authService;
  final ThemeMode? initialThemeMode;
  final ThemePreferences themePreferences;

  @override
  State<CosmoApp> createState() => _CosmoAppState();
}

class _CosmoAppState extends State<CosmoApp> {
  late ThemeMode _themeMode;
  late bool _isSignedIn;
  StreamSubscription<bool>? _authSubscription;
  bool _hasUserSelectedThemeMode = false;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialThemeMode ?? ThemeMode.light;
    if (widget.initialThemeMode == null) {
      unawaited(_loadThemeMode());
    }
    _isSignedIn = widget.authService.isSignedIn;
    _authSubscription = widget.authService.signedInChanges.listen((isSignedIn) {
      setState(() => _isSignedIn = isSignedIn);
    });
  }

  @override
  void dispose() {
    unawaited(_authSubscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cosmo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,
      home: _isSignedIn
          ? HomeScreen(
              preferencesApi: widget.preferencesApi,
              restaurantsApi: widget.restaurantsApi,
              themeMode: _themeMode,
              userEmail: widget.authService.currentUser?.email,
              onSignOut: widget.authService.signOut,
              onThemeModeChanged: (themeMode) {
                unawaited(_setThemeMode(themeMode));
              },
            )
          : SignInPage(authService: widget.authService),
    );
  }

  Future<void> _loadThemeMode() async {
    try {
      final themeMode = await widget.themePreferences.loadThemeMode();
      if (!mounted || _hasUserSelectedThemeMode) {
        return;
      }

      setState(() => _themeMode = themeMode);
    } catch (error, stackTrace) {
      debugPrint('CosmoApp: could not load theme preference: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> _setThemeMode(ThemeMode themeMode) async {
    _hasUserSelectedThemeMode = true;
    setState(() => _themeMode = themeMode);

    try {
      await widget.themePreferences.saveThemeMode(themeMode);
    } catch (error, stackTrace) {
      debugPrint('CosmoApp: could not save theme preference: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}
