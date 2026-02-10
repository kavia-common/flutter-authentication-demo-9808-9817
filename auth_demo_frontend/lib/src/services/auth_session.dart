import 'auth_api.dart';
import 'token_storage.dart';

/// Manages authentication session state (tokens) and refresh flow.
///
/// This is intentionally lightweight (no streams) and can be wrapped by Provider
/// if needed later.
class AuthSession {
  AuthSession({
    AuthApi? api,
    TokenStorage? tokenStorage,
  })  : _api = api ?? AuthApi(),
        _tokenStorage = tokenStorage ?? TokenStorage();

  final AuthApi _api;
  final TokenStorage _tokenStorage;

  /// Prevent concurrent refresh calls from racing.
  Future<String?>? _refreshInFlight;

  // PUBLIC_INTERFACE
  Future<void> saveTokensFromResponse(Map<String, dynamic> json) async {
    final String? accessToken =
        (json['accessToken'] ?? json['access_token']) as String?;
    final String? refreshToken =
        (json['refreshToken'] ?? json['refresh_token']) as String?;

    if (accessToken == null || refreshToken == null) return;

    await _tokenStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  // PUBLIC_INTERFACE
  Future<String?> getAccessToken() => _tokenStorage.readAccessToken();

  // PUBLIC_INTERFACE
  Future<void> clearSession() => _tokenStorage.clear();

  // PUBLIC_INTERFACE
  Future<String?> refreshAccessToken() {
    _refreshInFlight ??= _refreshInternal();
    return _refreshInFlight!.whenComplete(() {
      _refreshInFlight = null;
    });
  }

  Future<String?> _refreshInternal() async {
    final String? refreshToken = await _tokenStorage.readRefreshToken();
    if (refreshToken == null || refreshToken.trim().isEmpty) return null;

    final Map<String, dynamic> json =
        await _api.refreshToken(refreshToken: refreshToken);

    await saveTokensFromResponse(json);
    return _tokenStorage.readAccessToken();
  }
}
