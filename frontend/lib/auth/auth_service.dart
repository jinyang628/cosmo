import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/api_config.dart';

abstract class AuthService {
  Stream<bool> get signedInChanges;
  bool get isSignedIn;
  User? get currentUser;

  Future<AuthResponse> signInWithGoogle();
  Future<void> signOut();
}

class SupabaseAuthService implements AuthService {
  SupabaseAuthService({SupabaseClient? supabaseClient})
    : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  static const List<String> _googleScopes = ['email', 'profile'];

  final SupabaseClient _supabaseClient;
  bool _googleSignInInitialized = false;

  @override
  Stream<bool> get signedInChanges {
    return _supabaseClient.auth.onAuthStateChange
        .map((state) => state.session != null)
        .distinct();
  }

  @override
  bool get isSignedIn => _supabaseClient.auth.currentSession != null;

  @override
  User? get currentUser => _supabaseClient.auth.currentUser;

  @override
  Future<AuthResponse> signInWithGoogle() async {
    await _initializeGoogleSignIn();

    if (!GoogleSignIn.instance.supportsAuthenticate()) {
      throw const AuthServiceException(
        'Native Google sign-in is not supported on this platform',
      );
    }

    final googleUser = await GoogleSignIn.instance.authenticate(
      scopeHint: _googleScopes,
    );

    final idToken = googleUser.authentication.idToken;
    if (idToken == null) {
      throw const AuthServiceException('Google did not return an ID token');
    }

    final authorization =
        await googleUser.authorizationClient.authorizationForScopes(
          _googleScopes,
        ) ??
        await googleUser.authorizationClient.authorizeScopes(_googleScopes);

    return _supabaseClient.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: authorization.accessToken,
    );
  }

  @override
  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();

    if (_googleSignInInitialized) {
      await GoogleSignIn.instance.signOut();
    }
  }

  Future<void> _initializeGoogleSignIn() async {
    if (_googleSignInInitialized) {
      return;
    }

    if (kIsWeb) {
      await GoogleSignIn.instance.initialize(
        clientId: ApiConfig.googleWebClientId,
      );
    } else {
      await GoogleSignIn.instance.initialize(
        clientId: ApiConfig.googleIosClientId,
        serverClientId: ApiConfig.googleWebClientId,
      );
    }
    _googleSignInInitialized = true;
  }
}

class AuthServiceException implements Exception {
  const AuthServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}
