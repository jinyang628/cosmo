import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:frontend/app.dart';
import 'package:frontend/auth/auth_service.dart';
import 'package:frontend/config/api_config.dart';
import 'package:frontend/pages/landing_page.dart';
import 'package:frontend/pages/sign_in_page.dart';
import 'package:frontend/preferences/diet_preference.dart';
import 'package:frontend/preferences/preferences_api.dart';
import 'package:frontend/preferences/user_preferences.dart';

void main() {
  testWidgets('Preferences page shows food recommendation controls', (
    WidgetTester tester,
  ) async {
    final preferencesApi = RecordingPreferencesApi();
    await tester.pumpWidget(
      CosmoApp(
        preferencesApi: preferencesApi,
        authService: RecordingAuthService(initiallySignedIn: true),
      ),
    );

    expect(find.byType(LandingPage), findsOneWidget);

    await tester.tap(find.text('Preferences').last);
    await tester.pumpAndSettle();

    expect(find.text('Distance'), findsOneWidget);
    expect(find.text('Budget'), findsOneWidget);
    expect(find.text('Diet'), findsOneWidget);
    expect(find.byType(Slider), findsNWidgets(2));

    for (final preference in dietPreferences) {
      expect(find.text(preference.label), findsOneWidget);
    }

    final veganChipFinder = find.widgetWithText(
      FilterChip,
      DietPreference.vegan.label,
    );
    await tester.drag(find.byType(ListView), const Offset(0, -120));
    await tester.pumpAndSettle();
    await tester.tap(veganChipFinder);
    await tester.pumpAndSettle();

    final veganChip = tester.widget<FilterChip>(veganChipFinder);
    expect(veganChip.selected, isTrue);
    expect(preferencesApi.savedPreferences, hasLength(1));
    expect(
      preferencesApi.savedPreferences.single.dietPreferences,
      contains(DietPreference.vegan),
    );
  });

  testWidgets('Settings drawer toggles dark mode', (WidgetTester tester) async {
    await tester.pumpWidget(
      CosmoApp(
        preferencesApi: RecordingPreferencesApi(),
        authService: RecordingAuthService(initiallySignedIn: true),
      ),
    );

    expect(
      Theme.of(tester.element(find.byType(LandingPage))).brightness,
      Brightness.light,
    );

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Dark mode'), findsOneWidget);
    expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
    expect(
      Theme.of(tester.element(find.byType(LandingPage))).brightness,
      Brightness.dark,
    );
  });

  test('API config throws when base URL is not configured', () {
    dotenv.clean();

    expect(() => ApiConfig.apiBaseUrl, throwsA(isA<ApiConfigException>()));
  });

  testWidgets('Signed-out users see the Google sign-in page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      CosmoApp(
        preferencesApi: RecordingPreferencesApi(),
        authService: RecordingAuthService(initiallySignedIn: false),
      ),
    );

    expect(find.byType(SignInPage), findsOneWidget);
    expect(find.text('Sign in with Google'), findsOneWidget);
  });
}

class RecordingPreferencesApi extends PreferencesApi {
  RecordingPreferencesApi() : super(baseUrl: '');

  final List<UserPreferences> savedPreferences = [];

  @override
  Future<void> savePreferences(UserPreferences preferences) async {
    savedPreferences.add(preferences);
  }
}

class RecordingAuthService implements AuthService {
  RecordingAuthService({required bool initiallySignedIn})
    : _isSignedIn = initiallySignedIn;

  final StreamController<bool> _signedInChangesController =
      StreamController<bool>.broadcast();
  bool _isSignedIn;

  @override
  Stream<bool> get signedInChanges => _signedInChangesController.stream;

  @override
  bool get isSignedIn => _isSignedIn;

  @override
  User? get currentUser => null;

  @override
  Future<AuthResponse> signInWithGoogle() {
    _isSignedIn = true;
    _signedInChangesController.add(true);
    return Future.value(AuthResponse());
  }

  @override
  Future<void> signOut() async {
    _isSignedIn = false;
    _signedInChangesController.add(false);
  }
}
