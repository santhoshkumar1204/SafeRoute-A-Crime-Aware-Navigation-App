import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/google_auth_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? error;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.error,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;

  AuthState copyWith({AuthStatus? status, UserModel? user, String? error}) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  // ── Pending signup data (held until OTP is verified) ────────
  String? _pendingName;
  String? _pendingEmail;
  String? _pendingPassword;
  String? _pendingRole;

  AuthNotifier(this._authService) : super(const AuthState()) {
    _init();
  }

  Future<void> _init() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        state = AuthState(status: AuthStatus.authenticated, user: user);
      } else {
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    } catch (_) {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final user = await _authService.login(email, password);
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: e.toString(),
      );
    }
  }

  Future<void> signup(String name, String email, String password, String role) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      // Store pending signup data — actual account creation happens after OTP
      _pendingName = name;
      _pendingEmail = email;
      _pendingPassword = password;
      _pendingRole = role;

      // Send OTP to the email
      await _authService.emailOtpService.sendOtp(email);

      // Stay unauthenticated — UI will navigate to OTP verification page
      state = const AuthState(status: AuthStatus.unauthenticated);
    } catch (e) {
      _clearPending();
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  /// Google Sign-In
  Future<void> loginWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final user = await GoogleAuthService.signIn();
      await _authService.saveUser(user);
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  /// Email OTP Login – step 1: send OTP
  Future<void> sendOtp(String email) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      await _authService.emailOtpService.sendOtp(email);
      // Stay unauthenticated – UI will navigate to OTP entry
      state = const AuthState(status: AuthStatus.unauthenticated);
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  /// Email OTP – step 2: verify OTP.
  ///
  /// If pending signup data exists (user came from the signup page), the
  /// verified OTP triggers Firebase Auth account creation + Firestore sync.
  /// Otherwise it's a login-via-OTP flow — creates a local session.
  Future<void> verifyOtp(String email, String otp) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      await _authService.emailOtpService.verifyOtp(email, otp);

      // ── Signup flow: create Firebase account after OTP verified ──
      if (_hasPendingSignup) {
        final user = await _authService.signup(
          _pendingName!,
          _pendingEmail!,
          _pendingPassword!,
          _pendingRole!,
        );
        _clearPending();
        state = AuthState(status: AuthStatus.authenticated, user: user);
        return;
      }

      // ── Login OTP flow: create local session ────────────────────
      final user = UserModel(
        name: email.split('@').first,
        email: email,
        role: 'User',
      );
      await _authService.saveUser(user);
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  /// Whether there is a pending signup waiting for OTP verification.
  bool get _hasPendingSignup =>
      _pendingName != null &&
      _pendingEmail != null &&
      _pendingPassword != null;

  void _clearPending() {
    _pendingName = null;
    _pendingEmail = null;
    _pendingPassword = null;
    _pendingRole = null;
  }

  Future<void> logout() async {
    await GoogleAuthService.signOut();
    await _authService.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider));
});
