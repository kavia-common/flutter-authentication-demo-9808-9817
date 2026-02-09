class Validators {
  // Very small email validator suitable for UI validation.
  static final RegExp _emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  // E.164-ish phone validation (basic): + optional, 8-15 digits.
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
    if (!_phoneRe.hasMatch(value)) return 'Enter a valid phone number';
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
    final String value = (v ?? '');
    if (value.trim().isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
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
