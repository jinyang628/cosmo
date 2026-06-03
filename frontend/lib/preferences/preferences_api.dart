import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'user_preferences.dart';

class PreferencesApi {
  const PreferencesApi({this.baseUrl});

  final String? baseUrl;

  Future<void> savePreferences(UserPreferences preferences) async {
    final resolvedBaseUrl = baseUrl ?? ApiConfig.apiBaseUrl;
    final response = await http.post(
      Uri.parse('$resolvedBaseUrl/api/v1/preferences'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(preferences.toJson()),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw PreferencesApiException(
        'Failed to save preferences with status ${response.statusCode}',
      );
    }
  }
}

class PreferencesApiException implements Exception {
  const PreferencesApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
