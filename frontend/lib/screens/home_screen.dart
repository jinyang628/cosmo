import 'dart:async';

import 'package:flutter/material.dart';

import '../pages/landing_page.dart';
import '../pages/preferences_page.dart';
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
  int _selectedPageIndex = 0;
  double _distanceMeters = 1000;
  int _budgetLevel = 2;
  final Set<DietPreference> _selectedDiets = <DietPreference>{};

  @override
  Widget build(BuildContext context) {
    final pages = [
      LandingPage(
        distanceMeters: _distanceMeters,
        selectedDiets: _selectedDiets,
        restaurantsApi: widget.restaurantsApi,
      ),
      PreferencesPage(
        budgetLevel: _budgetLevel,
        dietOptions: dietPreferences,
        distanceMeters: _distanceMeters,
        selectedDiets: _selectedDiets,
        onBudgetChanged: (value) {
          setState(() => _budgetLevel = value);
          unawaited(_savePreferences());
        },
        onDietToggled: (diet) {
          setState(() {
            if (!_selectedDiets.add(diet)) {
              _selectedDiets.remove(diet);
            }
          });
          unawaited(_savePreferences());
        },
        onDistanceChanged: (value) {
          setState(() => _distanceMeters = value);
          unawaited(_savePreferences());
        },
      ),
    ];

    return Scaffold(
      drawer: SettingsDrawer(
        isDarkMode: widget.themeMode == ThemeMode.dark,
        userEmail: widget.userEmail,
        onSignOut: widget.onSignOut,
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
      body: pages[_selectedPageIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedPageIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedPageIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu),
            label: 'Landing',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_outlined),
            selectedIcon: Icon(Icons.tune),
            label: 'Preferences',
          ),
        ],
      ),
    );
  }

  Future<void> _savePreferences() async {
    try {
      await widget.preferencesApi.savePreferences(
        UserPreferences(
          distanceMeters: _distanceMeters,
          budgetLevel: _budgetLevel,
          dietPreferences: _selectedDiets,
        ),
      );
    } catch (error, stackTrace) {
      debugPrint('HomeScreen: could not save preferences: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save preferences')),
      );
    }
  }
}
