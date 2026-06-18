import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../preferences/sex.dart';

class BasicProfileQuestions extends StatelessWidget {
  const BasicProfileQuestions({
    required this.name,
    required this.age,
    required this.sex,
    required this.selectedHealthConditions,
    required this.otherHealthCondition,
    required this.onNameChanged,
    required this.onAgeChanged,
    required this.onSexChanged,
    required this.onHealthConditionToggled,
    required this.onOtherHealthConditionChanged,
    super.key,
  });

  final String name;
  final String age;
  final Sex sex;
  final Set<String> selectedHealthConditions;
  final String otherHealthCondition;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onAgeChanged;
  final ValueChanged<Sex> onSexChanged;
  final ValueChanged<String> onHealthConditionToggled;
  final ValueChanged<String> onOtherHealthConditionChanged;

  static const healthConditionOptions = [
    'High cholesterol',
    'High BP',
    'Pre-diabetic / diabetic',
    'None',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        Text(
          'Welcome to Cosmo',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "First, the basics - so Cosmo's numbers fit you.",
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 28),
        _QuestionLabel('What can Cosmo call you?'),
        const SizedBox(height: 10),
        TextFormField(
          initialValue: name,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
          decoration: _fieldDecoration('e.g. Elkan'),
          onChanged: onNameChanged,
        ),
        const SizedBox(height: 28),
        _QuestionLabel('How old are you?'),
        const SizedBox(height: 10),
        TextFormField(
          initialValue: age,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: _fieldDecoration('e.g. 34'),
          onChanged: onAgeChanged,
        ),
        const SizedBox(height: 28),
        const _QuestionLabel('Sex'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final option in Sex.values)
              ChoiceChip(
                label: Text(option.label),
                selected: sex == option,
                onSelected: (_) => onSexChanged(option),
              ),
          ],
        ),
        const SizedBox(height: 28),
        const _QuestionLabel('Any health conditions?'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final option in healthConditionOptions)
              FilterChip(
                label: Text(option),
                selected: selectedHealthConditions.contains(option),
                onSelected: (_) => onHealthConditionToggled(option),
              ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: otherHealthCondition,
          textInputAction: TextInputAction.done,
          textCapitalization: TextCapitalization.sentences,
          decoration: _fieldDecoration('Anything else? (optional)'),
          onChanged: onOtherHealthConditionChanged,
        ),
      ],
    );
  }
}

InputDecoration _fieldDecoration(String hintText) {
  return InputDecoration(
    hintText: hintText,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
  );
}

class _QuestionLabel extends StatelessWidget {
  const _QuestionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}
