import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract final class ApiConfig {
  static String get apiBaseUrl {
    return _requiredEnv('COSMO_API_BASE_URL');
  }

  static String get supabaseUrl {
    return _requiredEnv('SUPABASE_URL');
  }

  static String get supabaseAnonKey {
    return _requiredEnv('SUPABASE_ANON_KEY');
  }

  static String _requiredEnv(String name) {
    if (!dotenv.isInitialized) {
      throw ApiConfigException('$name is not configured');
    }

    final value = dotenv.env[name];
    if (value == null || value.trim().isEmpty) {
      throw ApiConfigException('$name is not configured');
    }

    return value.trim();
  }
}

class ApiConfigException implements Exception {
  const ApiConfigException(this.message);

  final String message;

  @override
  String toString() => message;
}
