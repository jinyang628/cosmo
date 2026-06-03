import 'package:flutter/material.dart';

import '../pages/landing_page.dart';
import '../pages/preferences_page.dart';
import '../preferences/diet_preference.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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
      const LandingPage(),
      PreferencesPage(
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
          setState(() => _distanceMeters = value);
        },
      ),
    ];

    return Scaffold(
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
}
