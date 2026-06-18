import 'dart:async';

import 'package:flutter/material.dart';

import '../preferences/sex.dart';
import '../preferences/diet_preference.dart';
import '../preferences/preference_questions.dart';
import 'basic_profile_questions.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({
    required this.name,
    required this.age,
    required this.sex,
    required this.selectedHealthConditions,
    required this.otherHealthCondition,
    required this.budgetLevel,
    required this.dietOptions,
    required this.distanceMeters,
    required this.selectedDiets,
    required this.onNameChanged,
    required this.onAgeChanged,
    required this.onSexChanged,
    required this.onHealthConditionToggled,
    required this.onOtherHealthConditionChanged,
    required this.onBudgetChanged,
    required this.onDietToggled,
    required this.onDistanceChanged,
    required this.onComplete,
    super.key,
  });

  final String name;
  final String age;
  final Sex sex;
  final Set<String> selectedHealthConditions;
  final String otherHealthCondition;
  final int budgetLevel;
  final List<DietPreference> dietOptions;
  final double distanceMeters;
  final Set<DietPreference> selectedDiets;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onAgeChanged;
  final ValueChanged<Sex> onSexChanged;
  final ValueChanged<String> onHealthConditionToggled;
  final ValueChanged<String> onOtherHealthConditionChanged;
  final ValueChanged<int> onBudgetChanged;
  final ValueChanged<DietPreference> onDietToggled;
  final ValueChanged<double> onDistanceChanged;
  final Future<void> Function() onComplete;

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  static const _stepCount = 3;

  int _stepIndex = 0;
  bool _isCompleting = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLastStep = _stepIndex == _stepCount - 1;
    final canContinue = _stepIndex != 0 || _hasValidBasicProfile;

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                for (var index = 0; index < _stepCount; index++) ...[
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 4,
                      decoration: BoxDecoration(
                        color: index <= _stepIndex
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  if (index != _stepCount - 1) const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: _stepIndex,
              children: [
                BasicProfileQuestions(
                  name: widget.name,
                  age: widget.age,
                  sex: widget.sex,
                  selectedHealthConditions: widget.selectedHealthConditions,
                  otherHealthCondition: widget.otherHealthCondition,
                  onNameChanged: widget.onNameChanged,
                  onAgeChanged: widget.onAgeChanged,
                  onSexChanged: widget.onSexChanged,
                  onHealthConditionToggled: widget.onHealthConditionToggled,
                  onOtherHealthConditionChanged:
                      widget.onOtherHealthConditionChanged,
                ),
                ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  children: [
                    Text(
                      'Food preferences',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Set the range, budget, and dietary filters for your recommendations.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 28),
                    PreferenceQuestions(
                      budgetLevel: widget.budgetLevel,
                      dietOptions: widget.dietOptions,
                      distanceMeters: widget.distanceMeters,
                      selectedDiets: widget.selectedDiets,
                      onBudgetChanged: widget.onBudgetChanged,
                      onDietToggled: widget.onDietToggled,
                      onDistanceChanged: widget.onDistanceChanged,
                    ),
                  ],
                ),
                const _DummyOnboardingStep(
                  icon: Icons.check_circle_outline,
                  title: 'All set',
                  body:
                      'Your profile is ready. Cosmo will use these choices when finding places nearby.',
                ),
              ],
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                top: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Row(
                children: [
                  if (_stepIndex > 0)
                    TextButton.icon(
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back'),
                      onPressed: _isCompleting
                          ? null
                          : () => setState(() => _stepIndex -= 1),
                    )
                  else
                    const Spacer(),
                  const Spacer(),
                  FilledButton.icon(
                    icon: _isCompleting
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colorScheme.onPrimary,
                            ),
                          )
                        : Icon(isLastStep ? Icons.check : Icons.arrow_forward),
                    label: Text(isLastStep ? 'Finish' : 'Next'),
                    onPressed: _isCompleting || !canContinue
                        ? null
                        : () {
                            if (isLastStep) {
                              unawaited(_complete());
                              return;
                            }

                            setState(() => _stepIndex += 1);
                          },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _complete() async {
    setState(() => _isCompleting = true);
    await widget.onComplete();

    if (!mounted) {
      return;
    }

    setState(() => _isCompleting = false);
  }

  bool get _hasValidBasicProfile {
    final parsedAge = int.tryParse(widget.age);
    return widget.name.trim().isNotEmpty &&
        parsedAge != null &&
        parsedAge >= 1 &&
        parsedAge <= 120;
  }
}

class _DummyOnboardingStep extends StatelessWidget {
  const _DummyOnboardingStep({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 72, color: theme.colorScheme.primary),
              const SizedBox(height: 24),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                body,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
