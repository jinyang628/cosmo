import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:frontend/app.dart';
import 'package:frontend/auth/auth_service.dart';
import 'package:frontend/config/api_config.dart';
import 'package:frontend/location/location_service.dart';
import 'package:frontend/pages/landing_page.dart';
import 'package:frontend/pages/sign_in_page.dart';
import 'package:frontend/preferences/diet_preference.dart';
import 'package:frontend/preferences/preferences_api.dart';
import 'package:frontend/preferences/user_preferences.dart';
import 'package:frontend/restaurants/restaurant.dart';
import 'package:frontend/restaurants/restaurants_api.dart';

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

  testWidgets('Landing page searches and displays nearby restaurants', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LandingPage(
          distanceMeters: 1000,
          selectedDiets: const {DietPreference.vegan},
          locationService: FakeLocationService(
            location: const UserLocation(
              latitude: 1.352083,
              longitude: 103.819839,
              accuracyMeters: 24,
            ),
          ),
          restaurantsApi: const FakeRestaurantsApi(
            restaurants: [
              Restaurant(
                id: 'restaurant-1',
                name: 'Nourish Kitchen',
                formattedAddress: '12 Orchard Road',
                rating: 4.6,
                userRatingCount: 120,
                priceLevel: 'PRICE_LEVEL_MODERATE',
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.text('Find restaurants nearby'));
    await tester.pumpAndSettle();

    expect(find.text('Latitude'), findsOneWidget);
    expect(find.text('1.352083'), findsOneWidget);
    expect(find.text('Longitude'), findsOneWidget);
    expect(find.text('103.819839'), findsOneWidget);
    expect(find.text('Accuracy'), findsOneWidget);
    expect(find.text('24m'), findsOneWidget);
    expect(find.text('Restaurants'), findsOneWidget);
    expect(find.text('Nourish Kitchen'), findsOneWidget);
    expect(find.text('12 Orchard Road'), findsOneWidget);
    expect(find.text('4.6 star'), findsOneWidget);
    expect(find.text('120 ratings'), findsOneWidget);
    expect(find.text(r'$$'), findsOneWidget);
    expect(find.text('Refresh'), findsOneWidget);
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

class FakeLocationService implements LocationService {
  const FakeLocationService({required this.location});

  final UserLocation location;

  @override
  Future<UserLocation> getCurrentLocation() async => location;
}

class FakeRestaurantsApi extends RestaurantsApi {
  const FakeRestaurantsApi({required this.restaurants});

  final List<Restaurant> restaurants;

  @override
  Future<List<Restaurant>> searchNearby({
    required UserLocation location,
    required double radiusMeters,
    required Set<DietPreference> dietPreferences,
    int maxResultCount = 10,
  }) async {
    return restaurants;
  }
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
