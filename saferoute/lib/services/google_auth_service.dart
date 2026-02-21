import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'firebase_service.dart';

class GoogleAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  /// Returns the currently signed-in Google account, if any.
  static GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;

  /// Sign in with Google + Firebase Auth.
  /// Returns a [UserModel] on success, throws on failure.
  static Future<UserModel> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        throw Exception('Google sign-in was cancelled');
      }

      // Authenticate with Firebase
      final googleAuth = await account.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      final name = firebaseUser?.displayName ??
          account.displayName ??
          account.email.split('@').first;
      final email = firebaseUser?.email ?? account.email;
      final photo = firebaseUser?.photoURL ?? account.photoUrl;

      // Persist user in Firestore
      if (firebaseUser != null) {
        await FirebaseService.instance.createUserIfNotExists(
          uid: firebaseUser.uid,
          name: name,
          email: email,
          profilePhoto: photo,
        );
      }

      return UserModel(
        name: name,
        email: email,
        role: 'User',
      );
    } catch (e) {
      throw Exception('Google sign-in failed: $e');
    }
  }

  /// Sign out from Google + Firebase.
  static Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      await _googleSignIn.signOut();
    } catch (_) {
      // Ignore sign-out errors
    }
  }

  /// Disconnect (revoke access).
  static Future<void> disconnect() async {
    try {
      await _googleSignIn.disconnect();
    } catch (_) {
      // Ignore disconnect errors
    }
  }
}
