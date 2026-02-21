import '../models/user_model.dart';
import 'storage_service.dart';
import 'email_otp_service.dart';

class AuthService {
  final StorageService _storage = StorageService();
  final EmailOtpService emailOtpService = EmailOtpService();

  Future<UserModel> login(String email, String password) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 800));
    final user = UserModel(
      name: email.split('@').first,
      email: email,
      role: 'User',
    );
    await _storage.saveUser(user);
    return user;
  }

  Future<UserModel> signup(String name, String email, String password, String role) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final user = UserModel(name: name, email: email, role: role);
    await _storage.saveUser(user);
    return user;
  }

  Future<void> logout() async {
    await _storage.clearUser();
  }

  Future<UserModel?> getCurrentUser() async {
    return await _storage.getUser();
  }

  Future<void> saveUser(UserModel user) async {
    await _storage.saveUser(user);
  }
}
