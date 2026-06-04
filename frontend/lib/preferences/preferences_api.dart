import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/api_config.dart';
import 'user_preferences.dart';

class PreferencesApi {
  const PreferencesApi({this.baseUrl});

  final String? baseUrl;

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
      debugPrint('PreferencesApi: no session, signing in anonymously');
      final response = await auth.signInAnonymously();
      final accessToken = response.session?.accessToken;
      if (accessToken == null) {
        throw const PreferencesApiException('User is not signed in');
      }

      return accessToken;
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
