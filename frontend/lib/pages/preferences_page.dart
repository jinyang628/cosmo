import 'package:flutter/material.dart';

import '../preferences/diet_preference.dart';

class PreferencesPage extends StatelessWidget {
  const PreferencesPage({
    required this.budgetLevel,
    required this.dietOptions,
    required this.distanceMeters,
    required this.selectedDiets,
    required this.onBudgetChanged,
    required this.onDietToggled,
    required this.onDistanceChanged,
    super.key,
  });

  final int budgetLevel;
  final List<DietPreference> dietOptions;
  final double distanceMeters;
  final Set<DietPreference> selectedDiets;
  final ValueChanged<int> onBudgetChanged;
  final ValueChanged<DietPreference> onDietToggled;
  final ValueChanged<double> onDistanceChanged;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Text(
            'Preferences',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Tune how far, how fancy, and what kind of healthy food Cosmo should recommend.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 28),
          PreferenceSection(
            title: 'Distance',
            value: formatDistance(distanceMeters),
            child: Slider(
              value: distanceMeters,
              min: 100,
              max: 10000,
              divisions: 99,
              label: formatDistance(distanceMeters),
              onChanged: onDistanceChanged,
            ),
          ),
          const SizedBox(height: 20),
          PreferenceSection(
            title: 'Budget',
            value: budgetLabel(budgetLevel),
            child: Slider(
              value: budgetLevel.toDouble(),
              min: 1,
              max: 4,
              divisions: 3,
              label: budgetLabel(budgetLevel),
              onChanged: (value) => onBudgetChanged(value.round()),
            ),
          ),
          const SizedBox(height: 20),
          PreferenceSection(
            title: 'Diet',
            value: formatDietSelection(selectedDiets),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final option in dietOptions)
                  FilterChip(
                    label: Text(option.label),
                    selected: selectedDiets.contains(option),
                    onSelected: (_) => onDietToggled(option),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PreferenceSection extends StatelessWidget {
  const PreferenceSection({
    required this.title,
    required this.value,
    required this.child,
    super.key,
  });

  final String title;
  final String value;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

String budgetLabel(int level) {
  return r'$$$$'.substring(0, level.clamp(1, 4));
}

String formatDistance(double meters) {
  final roundedMeters = meters.round();
  if (roundedMeters < 1000) {
    return '${(roundedMeters / 100).round() * 100}m';
  }

  final kilometers = roundedMeters / 1000;
  if (kilometers == kilometers.roundToDouble()) {
    return '${kilometers.round()}km';
  }

  return '${kilometers.toStringAsFixed(1)}km';
}

String formatDietSelection(Set<DietPreference> selectedDiets) {
  if (selectedDiets.isEmpty) {
    return 'Any';
  }

  final diets = selectedDiets.map((diet) => diet.label).toList()..sort();
  return diets.join(', ');
}
