import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/user_model.dart';
import 'firebase_service.dart';

class GoogleAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  /// Lazily access FirebaseAuth; returns null when Firebase is not initialised.
  static FirebaseAuth? get _firebaseAuth {
    try {
      Firebase.app();
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  /// Returns the currently signed-in Google account, if any.
  static GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;

  /// Sign in with Google + Firebase Auth.
  /// On **web** uses `signInWithPopup` (no OAuth Client ID needed).
  /// On **mobile** uses the `google_sign_in` package.
  static Future<UserModel> signIn() async {
    final auth = _firebaseAuth;
    if (auth == null) {
      throw Exception('Firebase is not initialised. Cannot use Google Sign-In.');
    }

    try {
      final User? firebaseUser;

      if (kIsWeb) {
        // ── Web: use Firebase Auth popup (no client-id meta tag needed) ──
        final provider = GoogleAuthProvider();
        provider.addScope('email');
        provider.addScope('profile');
        // Always show the account chooser so users can pick a different account
        provider.setCustomParameters({'prompt': 'select_account'});
        final userCredential = await auth.signInWithPopup(provider);
        firebaseUser = userCredential.user;
      } else {
        // ── Mobile: use google_sign_in package ──────────────────────────
        final account = await _googleSignIn.signIn();
        if (account == null) {
          throw Exception('Google sign-in was cancelled');
        }

        final googleAuth = await account.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final userCredential = await auth.signInWithCredential(credential);
        firebaseUser = userCredential.user;
      }

      if (firebaseUser == null) {
        throw Exception('Google sign-in failed — no user returned.');
      }

      final name = firebaseUser.displayName ??
          firebaseUser.email?.split('@').first ??
          'User';
      final email = firebaseUser.email ?? '';
      final photo = firebaseUser.photoURL;

      // Persist user in Firestore with provider=google, emailVerified=true
      await FirebaseService.instance.createUserIfNotExists(
        uid: firebaseUser.uid,
        name: name,
        email: email,
        profilePhoto: photo,
        provider: 'google',
        emailVerified: true,
      );

      return UserModel(
        name: name,
        email: email,
        role: 'User',
      );
    } catch (e) {
      // Surface a friendly message instead of raw assertion errors
      final msg = e.toString();
      if (msg.contains('popup-closed-by-user') || msg.contains('cancelled')) {
        throw Exception('Google sign-in was cancelled.');
      }
      throw Exception('Google sign-in failed. Please try again.');
    }
  }

  /// Sign out from Google + Firebase.
  static Future<void> signOut() async {
    try {
      await _firebaseAuth?.signOut();
      if (!kIsWeb) {
        await _googleSignIn.signOut();
      }
    } catch (_) {
      // Ignore sign-out errors
    }
  }

  /// Disconnect (revoke access).
  static Future<void> disconnect() async {
    try {
      if (!kIsWeb) {
        await _googleSignIn.disconnect();
      }
    } catch (_) {
      // Ignore disconnect errors
    }
  }
}
