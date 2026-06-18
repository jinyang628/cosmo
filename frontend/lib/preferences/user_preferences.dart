import 'diet_preference.dart';
import 'sex.dart';

class UserPreferences {
  const UserPreferences({
    required this.name,
    required this.age,
    required this.sex,
    required this.healthConditions,
    required this.distanceMeters,
    required this.budgetLevel,
    required this.dietPreferences,
  });

  final String name;
  final int age;
  final Sex sex;
  final List<String> healthConditions;
  final int distanceMeters;
  final int budgetLevel;
  final Set<DietPreference> dietPreferences;

  Map<String, Object> toJson() {
    return {
      'name': name,
      'age': age,
      'sex': sex.apiValue,
      'health_conditions': healthConditions,
      'distance_meters': distanceMeters,
      'budget_level': budgetLevel,
      'diet_preferences':
          dietPreferences.map((preference) => preference.apiValue).toList()
            ..sort(),
    };
  }
}
