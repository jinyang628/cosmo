import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
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
import 'package:frontend/theme/theme_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

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

    expect(
      await SharedPreferencesAsync().getString(ThemePreferences.themeModeKey),
      'dark',
    );
  });

  testWidgets('App starts with persisted dark mode', (
    WidgetTester tester,
  ) async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.withData({
          ThemePreferences.themeModeKey: 'dark',
        });

    await tester.pumpWidget(
      CosmoApp(
        preferencesApi: RecordingPreferencesApi(),
        authService: RecordingAuthService(initiallySignedIn: true),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      Theme.of(tester.element(find.byType(LandingPage))).brightness,
      Brightness.dark,
    );
  });

  testWidgets('Distance slider saves whole meters', (
    WidgetTester tester,
  ) async {
    final preferencesApi = RecordingPreferencesApi();
    await tester.pumpWidget(
      CosmoApp(
        preferencesApi: preferencesApi,
        authService: RecordingAuthService(initiallySignedIn: true),
      ),
    );

    await tester.tap(find.text('Preferences').last);
    await tester.pumpAndSettle();

    final distanceSlider = tester.widget<Slider>(find.byType(Slider).first);
    distanceSlider.onChanged!(2700.0000000000005);
    await tester.pumpAndSettle();

    expect(preferencesApi.savedPreferences.single.distanceMeters, 2700);
    expect(
      preferencesApi.savedPreferences.single.toJson()['distance_meters'],
      isA<int>(),
    );
  });

  testWidgets('Landing page searches and displays nearby restaurants', (
    WidgetTester tester,
  ) async {
    final openedRestaurantUris = <Uri>[];

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
                shortFormattedAddress: 'Orchard Road',
                primaryTypeDisplayName: 'Vegetarian restaurant',
                rating: 4.6,
                userRatingCount: 120,
                priceLevel: 'PRICE_LEVEL_MODERATE',
                priceRange: r'$10-$20',
                googleMapsUri: 'https://maps.google.com/?cid=restaurant-1',
                openNow: true,
                accessibilityOptions: RestaurantAccessibilityOptions(
                  wheelchairAccessibleEntrance: true,
                  wheelchairAccessibleSeating: true,
                ),
              ),
            ],
          ),
          launchRestaurantUri: (uri) async {
            openedRestaurantUris.add(uri);
            return true;
          },
        ),
      ),
    );

    await tester.tap(find.text('Find restaurants nearby'));
    await tester.pumpAndSettle();

    expect(find.text('Restaurants'), findsOneWidget);
    expect(find.text('Nourish Kitchen'), findsOneWidget);
    expect(find.text('Orchard Road'), findsOneWidget);
    expect(find.text('Open now'), findsOneWidget);
    expect(find.text('4.6 star'), findsOneWidget);
    expect(find.text('120 ratings'), findsOneWidget);
    expect(find.text(r'$10-$20'), findsOneWidget);
    expect(find.text('Vegetarian restaurant'), findsOneWidget);
    expect(find.text('Accessible entrance'), findsOneWidget);
    expect(find.text('Accessible seating'), findsOneWidget);
    expect(find.text('Refresh'), findsOneWidget);

    await tester.tap(find.text('Nourish Kitchen'));
    await tester.pump();

    expect(openedRestaurantUris, [
      Uri.parse('https://maps.google.com/?cid=restaurant-1'),
    ]);
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

  test('Sign-in errors are mapped to concise messages', () {
    expect(
      signInErrorMessage(
        const GoogleSignInException(
          code: GoogleSignInExceptionCode.clientConfigurationError,
          description:
              'OAuth client ID abc123.apps.googleusercontent.com failed',
          details: {'status': 400},
        ),
      ),
      'Sign-in is not configured correctly.',
    );
    expect(
      signInErrorMessage(
        const AuthException(
          'invalid request: leaked API details',
          statusCode: '401',
          code: 'bad_jwt',
        ),
      ),
      'Your sign-in session was rejected. Please try again.',
    );
    expect(
      signInErrorMessage(Exception('secret stack details')),
      'Please try again.',
    );
  });

  testWidgets('Sign-in snackbar masks raw error details', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SignInPage(
          authService: RecordingAuthService(
            initiallySignedIn: false,
            signInError: const AuthException(
              'invalid request: leaked API details',
              statusCode: '401',
              code: 'bad_jwt',
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Sign in with Google'));
    await tester.pump();

    expect(
      find.text(
        'Could not sign in: Your sign-in session was rejected. Please try again.',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('bad_jwt'), findsNothing);
    expect(find.textContaining('leaked API details'), findsNothing);
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
  RecordingAuthService({required bool initiallySignedIn, this._signInError})
    : _isSignedIn = initiallySignedIn;

  final StreamController<bool> _signedInChangesController =
      StreamController<bool>.broadcast();
  final Object? _signInError;
  bool _isSignedIn;

  @override
  Stream<bool> get signedInChanges => _signedInChangesController.stream;

  @override
  bool get isSignedIn => _isSignedIn;

  @override
  User? get currentUser => null;

  @override
  Future<AuthResponse> signInWithGoogle() {
    final signInError = _signInError;
    if (signInError != null) {
      return Future.error(signInError);
    }

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
