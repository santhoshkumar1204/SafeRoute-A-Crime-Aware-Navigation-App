import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Email OTP service backed by Firebase Cloud Functions + Firestore.
///
/// **Production**: When [_useCloudFunctions] is `true`, calls deployed Cloud
/// Functions (`sendOtp`, `verifyOtp`) that generate OTP server-side, hash with
/// SHA-256, store in Firestore `otp_verifications/{email}`, and send the email
/// via Nodemailer.
///
/// **Development / demo**: OTP is generated locally, hashed, stored in
/// Firestore (with in-memory fallback), and printed to the debug console.
class EmailOtpService {
  static const int otpLength = 6;
  static const Duration otpValidDuration = Duration(minutes: 5);
  static const int maxAttempts = 5;
  static const Duration resendCooldown = Duration(seconds: 60);

  /// ★ Set to `true` AFTER deploying Cloud Functions with:
  ///   cd functions && npm install
  ///   firebase functions:config:set smtp.email="..." smtp.password="..."
  ///   firebase deploy --only functions
  static const bool _useCloudFunctions = false;

  static const String _functionsBaseUrl =
      'https://us-central1-mtc-commuter-app.cloudfunctions.net';

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  // ─── In-memory OTP store (fallback when Firestore is unavailable) ────
  final Map<String, _OtpRecord> _memoryStore = {};

  // ─── Firestore helpers ───────────────────────────────────────

  FirebaseFirestore? get _db {
    try {
      Firebase.app();
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  DocumentReference<Map<String, dynamic>>? _otpDoc(String email) {
    return _db?.collection('otp_verifications').doc(email.trim().toLowerCase());
  }

  String _sha256(String input) {
    return sha256.convert(utf8.encode(input)).toString();
  }

  // ═══════════════════════════════════════════════════════════════
  //  SEND OTP
  // ═══════════════════════════════════════════════════════════════

  Future<bool> sendOtp(String email) async {
    final normalizedEmail = email.trim().toLowerCase();

    // ── Production: use deployed Cloud Functions ──────────────────
    if (_useCloudFunctions) {
      return _sendOtpViaCloudFunction(normalizedEmail);
    }

    // ── Development: generate locally ────────────────────────────
    return _sendOtpLocally(normalizedEmail);
  }

  Future<bool> _sendOtpViaCloudFunction(String email) async {
    try {
      final response = await _dio.post(
        '$_functionsBaseUrl/sendOtp',
        data: {'email': email},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        debugPrint('[EmailOtpService] OTP sent via Cloud Function to $email');
        return true;
      }
      throw Exception(response.data['error'] ?? 'Failed to send OTP');
    } on DioException catch (e) {
      if (e.response?.data is Map) {
        throw Exception(e.response!.data['error'] ?? 'Failed to send OTP');
      }
      // Cloud Function unreachable → fall back to local
      debugPrint('[EmailOtpService] Cloud Function unavailable — local fallback');
      return _sendOtpLocally(email);
    }
  }

  Future<bool> _sendOtpLocally(String email) async {
    // ── Rate-limit check ────────────────────────────────────────
    final memRecord = _memoryStore[email];
    if (memRecord != null) {
      final elapsed = DateTime.now().difference(memRecord.createdAt);
      if (elapsed < resendCooldown) {
        final wait = resendCooldown.inSeconds - elapsed.inSeconds;
        throw Exception('Please wait $wait seconds before requesting a new OTP.');
      }
    }

    // ── Generate OTP ────────────────────────────────────────────
    final random = Random.secure();
    final otp = List.generate(otpLength, (_) => random.nextInt(10)).join();
    final hashedOtp = _sha256(otp);
    final expiresAt = DateTime.now().add(otpValidDuration);

    // ── Store in Firestore (best-effort) ────────────────────────
    try {
      final docRef = _otpDoc(email);
      if (docRef != null) {
        await docRef.set({
          'hashedOtp': hashedOtp,
          'expiresAt': Timestamp.fromDate(expiresAt),
          'attempts': 0,
          'createdAt': FieldValue.serverTimestamp(),
        });
        debugPrint('[EmailOtpService] OTP stored in Firestore for $email');
      }
    } catch (e) {
      debugPrint('[EmailOtpService] Firestore write failed ($e) — using memory');
    }

    // ── Always store in memory as reliable fallback ─────────────
    _memoryStore[email] = _OtpRecord(
      hashedOtp: hashedOtp,
      expiresAt: expiresAt,
      attempts: 0,
      createdAt: DateTime.now(),
    );

    // ── Log OTP to console for development / demo ───────────────
    debugPrint('');
    debugPrint('╔══════════════════════════════════════════╗');
    debugPrint('║  OTP for $email');
    debugPrint('║  Code:  $otp');
    debugPrint('║  Expires in 5 minutes');
    debugPrint('╚══════════════════════════════════════════╝');
    debugPrint('');

    return true;
  }

  // ═══════════════════════════════════════════════════════════════
  //  VERIFY OTP
  // ═══════════════════════════════════════════════════════════════

  Future<bool> verifyOtp(String email, String otp) async {
    final normalizedEmail = email.trim().toLowerCase();

    if (_useCloudFunctions) {
      return _verifyOtpViaCloudFunction(normalizedEmail, otp.trim());
    }

    return _verifyOtpLocally(normalizedEmail, otp.trim());
  }

  Future<bool> _verifyOtpViaCloudFunction(String email, String otp) async {
    try {
      final response = await _dio.post(
        '$_functionsBaseUrl/verifyOtp',
        data: {'email': email, 'otp': otp},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return true;
      }
      throw Exception(response.data['error'] ?? 'Invalid OTP');
    } on DioException catch (e) {
      if (e.response?.data is Map) {
        throw Exception(e.response!.data['error'] ?? 'Verification failed');
      }
      debugPrint('[EmailOtpService] Cloud Function unavailable — local verify');
      return _verifyOtpLocally(email, otp);
    }
  }

  Future<bool> _verifyOtpLocally(String email, String otp) async {
    final inputHash = _sha256(otp);

    // ── Try Firestore first ─────────────────────────────────────
    try {
      final docRef = _otpDoc(email);
      if (docRef != null) {
        final snap = await docRef.get();
        if (snap.exists) {
          final data = snap.data()!;
          final result = _checkOtpData(data, inputHash);
          if (result == _OtpResult.valid) {
            await docRef.delete();
            _memoryStore.remove(email);
            return true;
          } else if (result == _OtpResult.expired) {
            await docRef.delete();
            _memoryStore.remove(email);
            throw Exception('OTP has expired. Please request a new one.');
          } else if (result == _OtpResult.tooManyAttempts) {
            await docRef.delete();
            _memoryStore.remove(email);
            throw Exception('Too many attempts. Please request a new OTP.');
          } else {
            await docRef.update({'attempts': FieldValue.increment(1)});
            final attempts = (data['attempts'] as int?) ?? 0;
            final remaining = maxAttempts - attempts - 1;
            throw Exception(
              'Invalid OTP. $remaining attempt${remaining != 1 ? 's' : ''} remaining.',
            );
          }
        }
      }
    } catch (e) {
      // If it's our own thrown exception, rethrow
      if (e is Exception && e.toString().contains('OTP')) rethrow;
      debugPrint('[EmailOtpService] Firestore read failed — trying memory');
    }

    // ── Fallback: in-memory store ───────────────────────────────
    final record = _memoryStore[email];
    if (record == null) {
      throw Exception('No OTP found. Please request a new one.');
    }

    if (DateTime.now().isAfter(record.expiresAt)) {
      _memoryStore.remove(email);
      throw Exception('OTP has expired. Please request a new one.');
    }

    if (record.attempts >= maxAttempts) {
      _memoryStore.remove(email);
      throw Exception('Too many attempts. Please request a new OTP.');
    }

    if (inputHash != record.hashedOtp) {
      record.attempts++;
      final remaining = maxAttempts - record.attempts;
      throw Exception(
        'Invalid OTP. $remaining attempt${remaining != 1 ? 's' : ''} remaining.',
      );
    }

    // Success
    _memoryStore.remove(email);
    return true;
  }

  _OtpResult _checkOtpData(Map<String, dynamic> data, String inputHash) {
    final expiresAt = (data['expiresAt'] as Timestamp?)?.toDate();
    if (expiresAt == null || DateTime.now().isAfter(expiresAt)) {
      return _OtpResult.expired;
    }
    final attempts = (data['attempts'] as int?) ?? 0;
    if (attempts >= maxAttempts) {
      return _OtpResult.tooManyAttempts;
    }
    if (inputHash == data['hashedOtp']) {
      return _OtpResult.valid;
    }
    return _OtpResult.invalid;
  }
}

enum _OtpResult { valid, invalid, expired, tooManyAttempts }

class _OtpRecord {
  final String hashedOtp;
  final DateTime expiresAt;
  int attempts;
  final DateTime createdAt;

  _OtpRecord({
    required this.hashedOtp,
    required this.expiresAt,
    required this.attempts,
    required this.createdAt,
  });
}
