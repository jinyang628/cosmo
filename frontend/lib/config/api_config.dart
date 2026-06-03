import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract final class ApiConfig {
  static String get apiBaseUrl {
    if (!dotenv.isInitialized) {
      throw const ApiConfigException('COSMO_API_BASE_URL is not configured');
    }

    final configuredBaseUrl = dotenv.env['COSMO_API_BASE_URL'];
    if (configuredBaseUrl == null || configuredBaseUrl.trim().isEmpty) {
      throw const ApiConfigException('COSMO_API_BASE_URL is not configured');
    }

    return configuredBaseUrl.trim();
  }
}

class ApiConfigException implements Exception {
  const ApiConfigException(this.message);

  final String message;

  @override
  String toString() => message;
}
