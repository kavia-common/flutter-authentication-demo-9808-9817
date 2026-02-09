import 'dart:convert';

import 'package:http/http.dart' as http;

/// Simple exception wrapper to surface API errors to the UI.
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Auth API client for the required FastAPI endpoints.
///
/// Note: Base URL is intentionally configurable. If you need to point this app at
/// a specific backend host, set it via `AuthApi(baseUrl: ...)` from a config
/// layer (e.g., dotenv). This task keeps it simple and uses a default.
///
/// IMPORTANT: Do not hardcode secrets in the client.
class AuthApi {
  AuthApi({String? baseUrl}) : _baseUrl = (baseUrl ?? 'http://localhost:8000');

  final String _baseUrl;

  Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  Future<Map<String, dynamic>> _postJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    final http.Response res = await http.post(
      _uri(path),
      headers: const <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      String message = 'Request failed';
      try {
        final dynamic decoded = jsonDecode(res.body);
        if (decoded is Map && decoded['detail'] is String) {
          message = decoded['detail'] as String;
        } else if (decoded is Map && decoded['message'] is String) {
          message = decoded['message'] as String;
        }
      } catch (_) {
        // Keep generic message.
      }
      throw ApiException(message, statusCode: res.statusCode);
    }

    if (res.body.trim().isEmpty) {
      return <String, dynamic>{};
    }

    final dynamic decoded = jsonDecode(res.body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw ApiException('Unexpected response format', statusCode: res.statusCode);
  }

  /// Login with password:
  /// POST /auth/login { phoneOrEmail, password }
  Future<Map<String, dynamic>> loginWithPassword({
    required String phoneOrEmail,
    required String password,
  }) {
    return _postJson('/auth/login', <String, dynamic>{
      'phoneOrEmail': phoneOrEmail,
      'password': password,
    });
  }

  /// Request OTP for login/signup:
  /// POST /auth/otp/request
  Future<Map<String, dynamic>> requestOtp({
    required String phone,
  }) {
    return _postJson('/auth/otp/request', <String, dynamic>{
      'phone': phone,
    });
  }

  /// Verify OTP for login/signup:
  /// POST /auth/otp/verify
  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String otp,
  }) {
    return _postJson('/auth/otp/verify', <String, dynamic>{
      'phone': phone,
      'otp': otp,
    });
  }

  /// Password flow signup:
  /// POST /auth/signup { phone, email?, password }
  Future<Map<String, dynamic>> signupWithPassword({
    required String phone,
    String? email,
    required String password,
    String? name,
    required bool consentAccepted,
  }) {
    return _postJson('/auth/signup', <String, dynamic>{
      'phone': phone,
      if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
      'password': password,
      if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
      'consentAccepted': consentAccepted,
    });
  }

  /// Refresh token:
  /// POST /auth/token/refresh
  Future<Map<String, dynamic>> refreshToken({required String refreshToken}) {
    return _postJson('/auth/token/refresh', <String, dynamic>{
      'refreshToken': refreshToken,
    });
  }

  /// Password reset request:
  /// POST /auth/password/reset/request
  Future<Map<String, dynamic>> passwordResetRequest({
    required String phoneOrEmail,
  }) {
    return _postJson('/auth/password/reset/request', <String, dynamic>{
      'phoneOrEmail': phoneOrEmail,
    });
  }

  /// Password reset confirm:
  /// POST /auth/password/reset/confirm
  Future<Map<String, dynamic>> passwordResetConfirm({
    required String phoneOrEmail,
    required String otp,
    required String newPassword,
  }) {
    return _postJson('/auth/password/reset/confirm', <String, dynamic>{
      'phoneOrEmail': phoneOrEmail,
      'otp': otp,
      'newPassword': newPassword,
    });
  }
}
