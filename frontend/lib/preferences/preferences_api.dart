import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/api_config.dart';
import 'user_preferences.dart';

class PreferencesApi {
  const PreferencesApi({this.baseUrl});

  final String? baseUrl;

  Future<bool> hasOnboarded() async {
    debugPrint('PreferencesApi: checking onboarding status');

    try {
      final resolvedBaseUrl = baseUrl ?? ApiConfig.apiBaseUrl;
      final accessToken = await _currentAccessToken;
      final response = await http.get(
        Uri.parse('$resolvedBaseUrl/api/v1/preferences/status'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      debugPrint(
        'PreferencesApi: onboarding status response ${response.statusCode}',
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw PreferencesApiException(
          'Failed to load preferences status with status ${response.statusCode}: ${response.body}',
        );
      }

      final payload = jsonDecode(response.body);
      if (payload case {'has_preferences': final bool hasPreferences}) {
        return hasPreferences;
      }

      throw const PreferencesApiException(
        'Preferences status response was malformed',
      );
    } catch (error, stackTrace) {
      debugPrint('PreferencesApi: could not check onboarding status: $error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> savePreferences(UserPreferences preferences) async {
    debugPrint('PreferencesApi: saving preferences');

    try {
      final resolvedBaseUrl = baseUrl ?? ApiConfig.apiBaseUrl;
      final accessToken = await _currentAccessToken;
      final response = await http.post(
        Uri.parse('$resolvedBaseUrl/api/v1/preferences'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(preferences.toJson()),
      );

      debugPrint(
        'PreferencesApi: save preferences response ${response.statusCode}',
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw PreferencesApiException(
          'Failed to save preferences with status ${response.statusCode}: ${response.body}',
        );
      }
    } catch (error, stackTrace) {
      debugPrint('PreferencesApi: could not save preferences: $error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<String> get _currentAccessToken async {
    final auth = Supabase.instance.client.auth;
    final session = auth.currentSession;
    if (session == null) {
      throw const PreferencesApiException('User is not signed in');
    }

    return session.accessToken;
  }
}

class PreferencesApiException implements Exception {
  const PreferencesApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
