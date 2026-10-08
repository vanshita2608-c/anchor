import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';
import '../security/key_hierarchy_manager.dart';
import 'family_service.dart';

/// Result object returned by [GoogleAuthService.signInWithGoogle].
class GoogleAuthResult {
  final AuthResponse? response;
  final GoogleSignInAccount? googleUser;
  final bool cancelled;
  final String? error;

  GoogleAuthResult({
    this.response,
    this.googleUser,
    this.cancelled = false,
    this.error,
  });

  bool get isSuccess => response?.session != null || googleUser != null;
}

class GoogleAuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Generates a cryptographically secure random nonce.
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the SHA256 hex digest of [input].
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Performs Google Sign-In with cryptographic nonce verification for Supabase.
  Future<GoogleAuthResult> signInWithGoogle() async {
    try {
      const webClientId = AppConfig.googleServerClientId;
      const iosClientId = AppConfig.googleIosClientId;

      // Step 1: Generate cryptographic raw nonce & SHA-256 hashed nonce
      final rawNonce = _generateNonce();
      final hashedNonce = _sha256ofString(rawNonce);

      final GoogleSignIn googleSignIn = GoogleSignIn.instance;

      // Step 2: Initialize GoogleSignIn with serverClientId and hashedNonce
      if (kIsWeb) {
        await googleSignIn.initialize(
          serverClientId: webClientId.isNotEmpty ? webClientId : null,
          clientId: webClientId.isNotEmpty ? webClientId : null,
          nonce: hashedNonce,
        );
      } else if (!kIsWeb && Platform.isAndroid) {
        await googleSignIn.initialize(
          serverClientId: webClientId.isNotEmpty ? webClientId : null,
          nonce: hashedNonce,
        );
      } else if (!kIsWeb && Platform.isIOS) {
        await googleSignIn.initialize(
          serverClientId: webClientId.isNotEmpty ? webClientId : null,
          clientId: iosClientId.isNotEmpty ? iosClientId : null,
          nonce: hashedNonce,
        );
      } else {
        await googleSignIn.initialize(
          serverClientId: webClientId.isNotEmpty ? webClientId : null,
          nonce: hashedNonce,
        );
      }

      // Step 3: Trigger the Google sign-in flow
      late final GoogleSignInAccount googleUser;
      try {
        googleUser = await googleSignIn.authenticate();
      } on GoogleSignInException catch (e) {
        debugPrint('🔴 GoogleSignInException during authenticate: code=${e.code}, description=${e.description}');
        if (e.code == GoogleSignInExceptionCode.canceled) {
          return GoogleAuthResult(
            cancelled: true,
            error: 'Authentication was canceled or rejected by Google Play Services: ${e.description ?? e.code.name}',
          );
        }
        rethrow;
      }

      // Step 4: Retrieve authentication ID token
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception(
          'Google Sign-In failed: ID Token was not returned by Google. Verify serverClientId configuration.',
        );
      }

      // Step 5: Authenticate with Supabase using ID token & rawNonce
      final AuthResponse response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        nonce: rawNonce,
      );

      return GoogleAuthResult(
        response: response,
        googleUser: googleUser,
      );
    } on AuthException catch (e) {
      debugPrint('🔴 Supabase AuthException during Google Sign-In: ${e.message}');
      return GoogleAuthResult(error: e.message);
    } on GoogleSignInException catch (e) {
      debugPrint('🔴 GoogleSignInException: ${e.code.name}');
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return GoogleAuthResult(cancelled: true);
      }
      return GoogleAuthResult(error: 'Google Sign-In error: ${e.code.name}');
    } catch (e) {
      debugPrint('🔴 GoogleAuthService unexpected error: $e');
      return GoogleAuthResult(error: e.toString());
    }
  }

  /// Signs out of Google Sign-In, clears the Supabase session and wipes in-memory vault state.
  Future<void> signOut() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;
      await googleSignIn.signOut();
    } catch (e) {
      debugPrint('Google Sign-Out notice: $e');
    }
    await _supabase.auth.signOut();
    KeyHierarchyManager().lockVault();
    FamilyService().reset();
  }
}
