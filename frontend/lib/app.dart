import 'dart:async';

import 'package:flutter/material.dart';

import 'auth/auth_service.dart';
import 'pages/sign_in_page.dart';
import 'preferences/preferences_api.dart';
import 'restaurants/restaurants_api.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

class CosmoApp extends StatefulWidget {
  CosmoApp({
    this.preferencesApi = const PreferencesApi(),
    this.restaurantsApi = const RestaurantsApi(),
    AuthService? authService,
    super.key,
  }) : authService = authService ?? SupabaseAuthService();

  final PreferencesApi preferencesApi;
  final RestaurantsApi restaurantsApi;
  final AuthService authService;

  @override
  State<CosmoApp> createState() => _CosmoAppState();
}

class _CosmoAppState extends State<CosmoApp> {
  ThemeMode _themeMode = ThemeMode.light;
  late bool _isSignedIn;
  StreamSubscription<bool>? _authSubscription;

  @override
  void initState() {
    super.initState();
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
                setState(() => _themeMode = themeMode);
              },
            )
          : SignInPage(authService: widget.authService),
    );
  }
}
