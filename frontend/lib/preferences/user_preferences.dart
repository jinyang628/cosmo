import 'diet_preference.dart';

class UserPreferences {
  const UserPreferences({
    required this.distanceMeters,
    required this.budgetLevel,
    required this.dietPreferences,
  });

  final int distanceMeters;
  final int budgetLevel;
  final Set<DietPreference> dietPreferences;

  Map<String, Object> toJson() {
    return {
      'distance_meters': distanceMeters,
      'budget_level': budgetLevel,
      'diet_preferences':
          dietPreferences.map((preference) => preference.apiValue).toList()
            ..sort(),
    };
  }
}
