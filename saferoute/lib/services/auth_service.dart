import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/user_model.dart';
import 'storage_service.dart';
import 'email_otp_service.dart';
import 'firebase_service.dart';

/// Maps Firebase Auth error codes to user-friendly messages.
String _friendlyAuthError(FirebaseAuthException e) {
  switch (e.code) {
    case 'invalid-email':
      return 'Please enter a valid email address.';
    case 'user-disabled':
      return 'This account has been disabled.';
    case 'user-not-found':
      return 'No account found with this email. Please sign up first.';
    case 'wrong-password':
      return 'Incorrect password. Please try again.';
    case 'email-already-in-use':
      return 'An account already exists with this email.';
    case 'weak-password':
      return 'Password is too weak. Use at least 6 characters.';
    case 'operation-not-allowed':
      return 'Email/password sign-in is not enabled. Please contact support.';
    case 'too-many-requests':
      return 'Too many attempts. Please try again later.';
    case 'network-request-failed':
      return 'Network error. Please check your internet connection.';
    case 'invalid-credential':
      return 'Invalid credentials. Please check your email and password.';
    default:
      return e.message ?? 'Authentication failed. Please try again.';
  }
}

class AuthService {
  final StorageService _storage = StorageService();
  final EmailOtpService emailOtpService = EmailOtpService();

  /// Lazily access FirebaseAuth; returns null when Firebase is not initialised.
  FirebaseAuth? get _firebaseAuth {
    try {
      Firebase.app(); // throws if not initialised
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  Future<UserModel> login(String email, String password) async {
    final auth = _firebaseAuth;
    if (auth == null) {
      // Fallback: offline / web without Firebase
      final user = UserModel(
        name: email.split('@').first,
        email: email,
        role: 'User',
      );
      await _storage.saveUser(user);
      return user;
    }
    try {
      final credential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final fbUser = credential.user;
      final user = UserModel(
        name: fbUser?.displayName ?? email.split('@').first,
        email: fbUser?.email ?? email,
        role: 'User',
      );

      // Sync to Firestore
      if (fbUser != null) {
        await FirebaseService.instance.createUserIfNotExists(
          uid: fbUser.uid,
          name: user.name,
          email: user.email,
        );
      }

      await _storage.saveUser(user);
      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_friendlyAuthError(e));
    }
  }

  Future<UserModel> signup(String name, String email, String password, String role) async {
    final auth = _firebaseAuth;
    if (auth == null) {
      final user = UserModel(name: name, email: email, role: role);
      await _storage.saveUser(user);
      return user;
    }
    try {
      final credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final fbUser = credential.user;

      // Update display name
      await fbUser?.updateDisplayName(name);

      final user = UserModel(name: name, email: email, role: role);

      // Sync to Firestore
      if (fbUser != null) {
        await FirebaseService.instance.createUserIfNotExists(
          uid: fbUser.uid,
          name: name,
          email: email,
          role: role,
        );
      }

      await _storage.saveUser(user);
      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_friendlyAuthError(e));
    }
  }

  Future<void> logout() async {
    await _firebaseAuth?.signOut();
    await _storage.clearUser();
  }

  Future<UserModel?> getCurrentUser() async {
    // Check Firebase Auth first
    final fbUser = _firebaseAuth?.currentUser;
    if (fbUser != null) {
      final user = UserModel(
        name: fbUser.displayName ?? fbUser.email?.split('@').first ?? 'User',
        email: fbUser.email ?? '',
        role: 'User',
      );
      return user;
    }
    // Fallback to local storage
    return await _storage.getUser();
  }

  Future<void> saveUser(UserModel user) async {
    await _storage.saveUser(user);

    // Also store in Firestore if authenticated
    final fbUser = _firebaseAuth?.currentUser;
    if (fbUser != null) {
      await FirebaseService.instance.createUserIfNotExists(
        uid: fbUser.uid,
        name: user.name,
        email: user.email,
      );
    }
  }
}
