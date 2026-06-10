import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/api_config.dart';
import '../location/location_service.dart';
import '../preferences/diet_preference.dart';
import 'restaurant.dart';

class RestaurantsApi {
  const RestaurantsApi({this.baseUrl});

  final String? baseUrl;

  Future<List<Restaurant>> searchNearby({
    required UserLocation location,
    required double radiusMeters,
    required Set<DietPreference> dietPreferences,
    int maxResultCount = 10,
  }) async {
    debugPrint('RestaurantsApi: searching nearby restaurants');

    try {
      final resolvedBaseUrl = baseUrl ?? ApiConfig.apiBaseUrl;
      final accessToken = await _currentAccessToken;
      final response = await http.post(
        Uri.parse('$resolvedBaseUrl/api/v1/restaurants/nearby'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'latitude': location.latitude,
          'longitude': location.longitude,
          'radius_meters': radiusMeters.round(),
          'max_result_count': maxResultCount,
          'diet_preferences':
              dietPreferences.map((preference) => preference.apiValue).toList()
                ..sort(),
        }),
      );

      debugPrint(
        'RestaurantsApi: nearby restaurants response ${response.statusCode}',
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw RestaurantsApiException(
          'Failed to search restaurants with status ${response.statusCode}: ${response.body}',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, Object?>) {
        throw const RestaurantsApiException('Restaurants response was invalid');
      }

      final restaurantsJson = decoded['restaurants'];
      if (restaurantsJson is! List) {
        throw const RestaurantsApiException('Restaurants response was invalid');
      }

      return [
        for (final restaurantJson in restaurantsJson)
          if (restaurantJson is Map<String, Object?>)
            Restaurant.fromJson(restaurantJson),
      ];
    } catch (error, stackTrace) {
      debugPrint('RestaurantsApi: could not search restaurants: $error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<String> get _currentAccessToken async {
    final auth = Supabase.instance.client.auth;
    final session = auth.currentSession;
    if (session == null) {
      throw const RestaurantsApiException('User is not signed in');
    }

    return session.accessToken;
  }
}

class RestaurantsApiException implements Exception {
  const RestaurantsApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
