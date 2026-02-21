import 'dart:math';

/// Simulates an Email OTP service.
///
/// In production, replace the mock implementation with actual API calls
/// to your backend that sends OTP emails via SendGrid/SMTP/Firebase.
class EmailOtpService {
  // Store the generated OTP and its expiry
  String? _generatedOtp;
  DateTime? _otpExpiry;
  String? _otpEmail;

  static const int otpLength = 6;
  static const Duration otpValidDuration = Duration(minutes: 5);

  /// Send OTP to the given email.
  /// Returns true if OTP was "sent" successfully.
  Future<bool> sendOtp(String email) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 1200));

    // Generate a 6-digit OTP
    final random = Random();
    _generatedOtp = List.generate(otpLength, (_) => random.nextInt(10)).join();
    _otpExpiry = DateTime.now().add(otpValidDuration);
    _otpEmail = email;

    // In production, this would call your backend API:
    // await _dio.post('/api/auth/send-otp', data: {'email': email});

    // For demo purposes, print OTP (remove in production)
    // ignore: avoid_print
    print('[EmailOtpService] OTP for $email: $_generatedOtp');

    return true;
  }

  /// Verify the OTP entered by the user.
  /// Returns true if OTP is valid and not expired.
  Future<bool> verifyOtp(String email, String otp) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 800));

    if (_generatedOtp == null || _otpExpiry == null || _otpEmail == null) {
      throw Exception('No OTP was sent. Please request a new OTP.');
    }

    if (_otpEmail != email) {
      throw Exception('OTP was sent to a different email.');
    }

    if (DateTime.now().isAfter(_otpExpiry!)) {
      _generatedOtp = null;
      _otpExpiry = null;
      throw Exception('OTP has expired. Please request a new one.');
    }

    if (_generatedOtp != otp) {
      throw Exception('Invalid OTP. Please try again.');
    }

    // OTP is valid — clear it
    _generatedOtp = null;
    _otpExpiry = null;
    _otpEmail = null;

    return true;
  }

  /// Check if OTP has expired.
  bool get isExpired {
    if (_otpExpiry == null) return true;
    return DateTime.now().isAfter(_otpExpiry!);
  }

  /// Get remaining seconds until OTP expires.
  int get remainingSeconds {
    if (_otpExpiry == null) return 0;
    final diff = _otpExpiry!.difference(DateTime.now()).inSeconds;
    return diff > 0 ? diff : 0;
  }
}
