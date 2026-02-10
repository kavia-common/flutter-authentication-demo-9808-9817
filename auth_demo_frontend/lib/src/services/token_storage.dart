import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure token storage for access + refresh tokens.
///
/// Uses platform secure storage (Keychain/Keystore) via flutter_secure_storage.
class TokenStorage {
  TokenStorage({FlutterSecureStorage? secureStorage})
      : _storage = secureStorage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const String _kAccessToken = 'access_token';
  static const String _kRefreshToken = 'refresh_token';

  // PUBLIC_INTERFACE
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _kAccessToken, value: accessToken);
    await _storage.write(key: _kRefreshToken, value: refreshToken);
  }

  // PUBLIC_INTERFACE
  Future<String?> readAccessToken() => _storage.read(key: _kAccessToken);

  // PUBLIC_INTERFACE
  Future<String?> readRefreshToken() => _storage.read(key: _kRefreshToken);

  // PUBLIC_INTERFACE
  Future<void> clear() async {
    await _storage.delete(key: _kAccessToken);
    await _storage.delete(key: _kRefreshToken);
  }
}
