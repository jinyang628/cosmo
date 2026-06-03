import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/main.dart';

void main() {
  testWidgets('Preferences page shows food recommendation controls', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CosmoApp());

    expect(find.byType(LandingPage), findsOneWidget);

    await tester.tap(find.text('Preferences').last);
    await tester.pumpAndSettle();

    expect(find.text('Distance'), findsOneWidget);
    expect(find.text('Budget'), findsOneWidget);
    expect(find.text('Diet'), findsOneWidget);
    expect(find.byType(Slider), findsNWidgets(2));

    for (final option in ['Spicy Ok', 'Vegetarian', 'Vegan', 'Pescatarian']) {
      expect(find.text(option), findsOneWidget);
    }

    final veganChipFinder = find.widgetWithText(FilterChip, 'Vegan');
    await tester.drag(find.byType(ListView), const Offset(0, -120));
    await tester.pumpAndSettle();
    await tester.tap(veganChipFinder);
    await tester.pumpAndSettle();

    final veganChip = tester.widget<FilterChip>(veganChipFinder);
    expect(veganChip.selected, isTrue);
  });
}
