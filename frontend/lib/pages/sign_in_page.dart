import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../auth/auth_service.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({required this.authService, super.key});

  final AuthService authService;

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  bool _isSigningIn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Cosmo',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Sign in to save your food preferences.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    onPressed: _isSigningIn ? null : _signInWithGoogle,
                    icon: _isSigningIn
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.login),
                    label: const Text('Sign in with Google'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isSigningIn = true);

    try {
      await widget.authService.signInWithGoogle();
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not sign in: ${signInErrorMessage(error)}'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSigningIn = false);
      }
    }
  }
}

String signInErrorMessage(Object error) {
  if (error is GoogleSignInException) {
    return switch (error.code) {
      GoogleSignInExceptionCode.canceled => 'Sign-in was canceled.',
      GoogleSignInExceptionCode.interrupted =>
        'Sign-in was interrupted. Please try again.',
      GoogleSignInExceptionCode.uiUnavailable =>
        'Sign-in is unavailable right now.',
      GoogleSignInExceptionCode.clientConfigurationError ||
      GoogleSignInExceptionCode.providerConfigurationError =>
        'Sign-in is not configured correctly.',
      GoogleSignInExceptionCode.userMismatch =>
        'Please choose the selected Google account.',
      _ => 'Please try again.',
    };
  }

  if (error is AuthRetryableFetchException || error is TimeoutException) {
    return 'Could not reach the sign-in service.';
  }

  if (error is AuthException) {
    if (error.statusCode == '401' || error.statusCode == '403') {
      return 'Your sign-in session was rejected. Please try again.';
    }

    return 'Authentication failed. Please try again.';
  }

  if (error is AuthServiceException) {
    return switch (error.message) {
      'Native Google sign-in is not supported on this platform' =>
        'Google sign-in is not supported here.',
      'Google did not return an ID token' =>
        'Google sign-in did not finish correctly.',
      _ => 'Please try again.',
    };
  }

  if (error is PlatformException) {
    final code = error.code.toLowerCase();
    if (code.contains('network')) {
      return 'Could not reach the sign-in service.';
    }
    if (code.contains('cancel')) {
      return 'Sign-in was canceled.';
    }

    return 'Sign-in is unavailable right now.';
  }

  return 'Please try again.';
}
