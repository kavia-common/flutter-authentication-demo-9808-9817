import 'dart:convert';

/// Supported backend error codes for tailored UI/UX.
///
/// Keep these in sync with backend error responses.
enum BackendErrorCode {
  duplicateUser,
  rateLimited,
  otpExpired,
  otpRetryExceeded,
  unknown,
}

/// Normalized API error payload that UI can map to UX behaviors.
class ApiErrorDetails {
  ApiErrorDetails({
    required this.code,
    required this.userMessage,
    required this.statusCode,
    this.retryAfterSeconds,
    this.lockoutSeconds,
    this.rawDetail,
  });

  final BackendErrorCode code;

  /// A user-friendly message to display when no tailored UX is available.
  final String userMessage;

  final int statusCode;

  /// For RATE_LIMITED, a server-provided cooldown (if any).
  final int? retryAfterSeconds;

  /// For OTP_RETRY_EXCEEDED, a server-provided lockout duration (if any).
  final int? lockoutSeconds;

  /// Raw server detail/message (for debugging/logging if needed).
  final String? rawDetail;

  static BackendErrorCode _codeFromString(String? code) {
    switch ((code ?? '').trim().toUpperCase()) {
      case 'DUPLICATE_USER':
        return BackendErrorCode.duplicateUser;
      case 'RATE_LIMITED':
        return BackendErrorCode.rateLimited;
      case 'OTP_EXPIRED':
        return BackendErrorCode.otpExpired;
      case 'OTP_RETRY_EXCEEDED':
        return BackendErrorCode.otpRetryExceeded;
      default:
        return BackendErrorCode.unknown;
    }
  }

  static int? _intFrom(dynamic v) {
    if (v is int) return v;
    if (v is String) return int.tryParse(v);
    if (v is double) return v.toInt();
    return null;
  }

  /// Parse error details from an HTTP response body.
  ///
  /// Supports common FastAPI shapes:
  /// - { "detail": "...", "errorCode": "RATE_LIMITED", "retryAfterSeconds": 30 }
  /// - { "message": "...", "code": "OTP_EXPIRED" }
  /// - { "detail": { "message": "...", "code": "..." } }
  // PUBLIC_INTERFACE
  static ApiErrorDetails fromHttpBody({
    required int statusCode,
    required String body,
    String fallbackMessage = 'Request failed',
  }) {
    BackendErrorCode code = BackendErrorCode.unknown;
    String message = fallbackMessage;
    int? retryAfterSeconds;
    int? lockoutSeconds;
    String? rawDetail;

    dynamic decoded;
    try {
      decoded = jsonDecode(body);
    } catch (_) {
      decoded = null;
    }

    if (decoded is Map) {
      // Prefer top-level fields.
      final String? codeStr =
          (decoded['errorCode'] ?? decoded['code']) as String?;
      code = _codeFromString(codeStr);

      // Message extraction (keep backward-compat).
      if (decoded['detail'] is String) {
        rawDetail = decoded['detail'] as String;
        message = rawDetail!;
      } else if (decoded['message'] is String) {
        rawDetail = decoded['message'] as String;
        message = rawDetail!;
      } else if (decoded['detail'] is Map) {
        final Map detailMap = decoded['detail'] as Map;
        final String? nestedCode =
            (detailMap['errorCode'] ?? detailMap['code']) as String?;
        if (code == BackendErrorCode.unknown) {
          code = _codeFromString(nestedCode);
        }

        if (detailMap['message'] is String) {
          rawDetail = detailMap['message'] as String;
          message = rawDetail!;
        } else if (detailMap['detail'] is String) {
          rawDetail = detailMap['detail'] as String;
          message = rawDetail!;
        }
      }

      retryAfterSeconds = _intFrom(
        decoded['retryAfterSeconds'] ?? decoded['retry_after_seconds'],
      );
      lockoutSeconds = _intFrom(
        decoded['lockoutSeconds'] ??
            decoded['lockout_seconds'] ??
            decoded['retryAfterSeconds'] ??
            decoded['retry_after_seconds'],
      );
    }

    return ApiErrorDetails(
      code: code,
      userMessage: message,
      statusCode: statusCode,
      retryAfterSeconds: retryAfterSeconds,
      lockoutSeconds: lockoutSeconds,
      rawDetail: rawDetail,
    );
  }
}

/// Simple exception wrapper to surface API errors to the UI, including backend
/// error codes for tailored UX.
///
/// This supports two construction modes:
/// 1) `ApiException(ApiErrorDetails(...))` for rich error handling
/// 2) `ApiException.message('...', statusCode: ...)` for quick failures such as
///    unexpected response shapes.
class ApiException implements Exception {
  ApiException(this.details);

  /// Convenience constructor for quick/unknown errors.
  ///
  /// Kept to match existing call sites that throw with a message and statusCode.
  factory ApiException.message(
    String message, {
    int statusCode = 0,
  }) {
    return ApiException(
      ApiErrorDetails(
        code: BackendErrorCode.unknown,
        userMessage: message,
        statusCode: statusCode,
      ),
    );
  }

  final ApiErrorDetails details;

  String get message => details.userMessage;
  int get statusCode => details.statusCode;
  BackendErrorCode get code => details.code;
  int? get retryAfterSeconds => details.retryAfterSeconds;
  int? get lockoutSeconds => details.lockoutSeconds;

  @override
  String toString() =>
      'ApiException(${details.statusCode}, ${details.code}): ${details.userMessage}';
}
