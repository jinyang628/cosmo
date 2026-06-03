enum DietPreference {
  spicyOk('Spicy Ok'),
  vegetarian('Vegetarian'),
  vegan('Vegan'),
  pescatarian('Pescatarian');

  const DietPreference(this.label);

  final String label;
}

const dietPreferences = [
  DietPreference.spicyOk,
  DietPreference.vegetarian,
  DietPreference.vegan,
  DietPreference.pescatarian,
];
