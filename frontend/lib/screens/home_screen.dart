import 'dart:async';

import 'package:flutter/material.dart';

import '../onboarding/onboarding_flow.dart';
import '../pages/landing_page.dart';
import '../preferences/diet_preference.dart';
import '../preferences/preferences_api.dart';
import '../preferences/user_preferences.dart';
import '../restaurants/restaurants_api.dart';
import '../settings/settings_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.preferencesApi,
    required this.restaurantsApi,
    required this.themeMode,
    required this.onSignOut,
    required this.onThemeModeChanged,
    this.userEmail,
    super.key,
  });

  final PreferencesApi preferencesApi;
  final RestaurantsApi restaurantsApi;
  final ThemeMode themeMode;
  final String? userEmail;
  final Future<void> Function() onSignOut;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _distanceMeters = 1000;
  int _budgetLevel = 2;
  bool _isCheckingOnboarding = true;
  bool _isOnboardingVisible = false;
  final Set<DietPreference> _selectedDiets = <DietPreference>{};

  @override
  void initState() {
    super.initState();
    unawaited(_checkOnboardingStatus());
  }

  @override
  Widget build(BuildContext context) {
    final body = _isCheckingOnboarding
        ? const _OnboardingStatusLoader()
        : _isOnboardingVisible
        ? OnboardingFlow(
            budgetLevel: _budgetLevel,
            dietOptions: dietPreferences,
            distanceMeters: _distanceMeters,
            selectedDiets: _selectedDiets,
            onBudgetChanged: (value) {
              setState(() => _budgetLevel = value);
            },
            onDietToggled: (diet) {
              setState(() {
                if (!_selectedDiets.add(diet)) {
                  _selectedDiets.remove(diet);
                }
              });
            },
            onDistanceChanged: (value) {
              setState(() => _distanceMeters = value.roundToDouble());
            },
            onComplete: _completeOnboarding,
          )
        : LandingPage(
            distanceMeters: _distanceMeters,
            selectedDiets: _selectedDiets,
            restaurantsApi: widget.restaurantsApi,
          );

    return Scaffold(
      drawer: SettingsDrawer(
        isDarkMode: widget.themeMode == ThemeMode.dark,
        userEmail: widget.userEmail,
        onSignOut: widget.onSignOut,
        onRedoOnboarding: () {
          setState(() => _isOnboardingVisible = true);
        },
        onDarkModeChanged: (isDarkMode) {
          widget.onThemeModeChanged(
            isDarkMode ? ThemeMode.dark : ThemeMode.light,
          );
        },
      ),
      appBar: AppBar(
        title: const Text('Cosmo'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: body,
    );
  }

  Future<void> _checkOnboardingStatus() async {
    try {
      final hasOnboarded = await widget.preferencesApi.hasOnboarded();
      if (!mounted) {
        return;
      }

      setState(() {
        _isCheckingOnboarding = false;
        _isOnboardingVisible = !hasOnboarded;
      });
    } catch (error, stackTrace) {
      debugPrint('HomeScreen: could not check onboarding status: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not check onboarding status')),
      );
      setState(() => _isCheckingOnboarding = false);
    }
  }

  Future<void> _completeOnboarding() async {
    final didSave = await _savePreferences();
    if (!mounted || !didSave) {
      return;
    }

    setState(() => _isOnboardingVisible = false);
  }

  Future<bool> _savePreferences() async {
    try {
      await widget.preferencesApi.savePreferences(
        UserPreferences(
          distanceMeters: _distanceMeters.round(),
          budgetLevel: _budgetLevel,
          dietPreferences: _selectedDiets,
        ),
      );
      return true;
    } catch (error, stackTrace) {
      debugPrint('HomeScreen: could not save preferences: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) {
        return false;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save preferences')),
      );
      return false;
    }
  }
}

class _OnboardingStatusLoader extends StatelessWidget {
  const _OnboardingStatusLoader();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
