class Validators {
  // Very small email validator suitable for UI validation.
  // This is intentionally not RFC-perfect; backend should be authoritative.
  static final RegExp _emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  // E.164-ish phone validation:
  // - optional leading +
  // - 8..15 digits total (common E.164 constraint is 15 digits max)
  static final RegExp _phoneRe = RegExp(r'^\+?[0-9]{8,15}$');

  // OTP validation: 4-8 digits typical.
  static final RegExp _otpRe = RegExp(r'^[0-9]{4,8}$');

  static String? requiredText(String? v, {String fieldName = 'This field'}) {
    final String value = (v ?? '').trim();
    if (value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? phone(String? v) {
    final String value = (v ?? '').trim();
    if (value.isEmpty) return 'Phone is required';
    if (!_phoneRe.hasMatch(value)) {
      return 'Enter a valid phone number (8–15 digits, optional +)';
    }
    return null;
  }

  /// Validates an email address that is required (must be non-empty and valid).
  static String? emailRequired(String? v) {
    final String value = (v ?? '').trim();
    if (value.isEmpty) return 'Email is required';
    if (!_emailRe.hasMatch(value)) return 'Enter a valid email';
    return null;
  }

  static String? emailOptional(String? v) {
    final String value = (v ?? '').trim();
    if (value.isEmpty) return null;
    if (!_emailRe.hasMatch(value)) return 'Enter a valid email';
    return null;
  }

  static String? phoneOrEmail(String? v) {
    final String value = (v ?? '').trim();
    if (value.isEmpty) return 'Phone or email is required';

    final bool isEmail = _emailRe.hasMatch(value);
    final bool isPhone = _phoneRe.hasMatch(value);

    if (!isEmail && !isPhone) return 'Enter a valid phone or email';
    return null;
  }

  static String? password(String? v) {
    // Stronger UI policy (backend must still enforce):
    // - min 8 chars
    // - at least one letter and one number
    // - reject common whitespace-only / accidental leading-trailing spaces
    final String raw = v ?? '';
    if (raw.trim().isEmpty) return 'Password is required';

    final String value = raw;
    if (value.length < 8) return 'Password must be at least 8 characters';

    final bool hasLetter = value.contains(RegExp(r'[A-Za-z]'));
    final bool hasNumber = value.contains(RegExp(r'[0-9]'));
    if (!hasLetter || !hasNumber) {
      return 'Password must include at least 1 letter and 1 number';
    }

    if (value.contains(' ')) {
      return 'Password must not contain spaces';
    }

    return null;
  }

  static String? otp(String? v) {
    final String value = (v ?? '').trim();
    if (value.isEmpty) return 'OTP is required';
    if (!_otpRe.hasMatch(value)) return 'Enter a valid OTP';
    return null;
  }

  static String? fullNameOptional(String? v) {
    final String value = (v ?? '').trim();
    if (value.isEmpty) return null;
    if (value.length < 2) return 'Name is too short';
    return null;
  }
}
