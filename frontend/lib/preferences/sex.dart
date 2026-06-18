enum Sex {
  male('Male', 'Male'),
  female('Female', 'Female'),
  preferNotToSay('Prefer not to say', 'Prefer not to say');

  const Sex(this.label, this.apiValue);

  final String label;
  final String apiValue;
}
