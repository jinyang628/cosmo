enum DietPreference {
  spicy('Spicy', 'spicy'),
  vegetarian('Vegetarian', 'vegetarian'),
  vegan('Vegan', 'vegan'),
  pescatarian('Pescatarian', 'pescatarian');

  const DietPreference(this.label, this.apiValue);

  final String label;
  final String apiValue;
}

const dietPreferences = [
  DietPreference.spicy,
  DietPreference.vegetarian,
  DietPreference.vegan,
  DietPreference.pescatarian,
];
