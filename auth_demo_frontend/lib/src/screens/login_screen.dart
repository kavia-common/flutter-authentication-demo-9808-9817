import 'package:flutter/material.dart';

import '../services/auth_api.dart';
import '../utils/validators.dart';
import '../widgets/auth_scaffold.dart';
import 'signup_screen.dart';

enum LoginMode {
  password,
  otp,
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const String routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _phoneOrEmailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _otpPhoneCtrl = TextEditingController();
  final TextEditingController _otpCtrl = TextEditingController();

  final TextEditingController _resetOtpCtrl = TextEditingController();
  final TextEditingController _resetNewPasswordCtrl = TextEditingController();

  final AuthApi _api = AuthApi();

  LoginMode _mode = LoginMode.password;

  bool _isLoading = false;
  bool _otpRequested = false;

  // Client-side edge-case counters (backend should enforce lockout).
  int _failedPasswordAttempts = 0;
  static const int _lockoutAfter = 5;
  bool get _lockedOut => _failedPasswordAttempts >= _lockoutAfter;

  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _phoneOrEmailCtrl.dispose();
    _passwordCtrl.dispose();
    _otpPhoneCtrl.dispose();
    _otpCtrl.dispose();
    _resetOtpCtrl.dispose();
    _resetNewPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _loginWithPassword() async {
    final bool valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    if (_lockedOut) {
      setState(() {
        _errorMessage =
            'Account temporarily locked due to failed attempts. Try again later.';
        _successMessage = null;
      });
      return;
    }

    final String phoneOrEmail = _phoneOrEmailCtrl.text.trim();
    final String password = _passwordCtrl.text;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await _api.loginWithPassword(phoneOrEmail: phoneOrEmail, password: password);

      // On success, backend returns JWT + refresh token.
      // This demo keeps it UI-only; token storage can be added with
      // shared_preferences if needed by the broader project.
      setState(() {
        _isLoading = false;
        _successMessage = 'Logged in successfully.';
      });
    } on ApiException catch (e) {
      setState(() {
        _isLoading = false;
        _failedPasswordAttempts += 1;
        _errorMessage = e.message;
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
        _failedPasswordAttempts += 1;
        _errorMessage = 'Login failed. Please try again.';
      });
    }
  }

  Future<void> _requestOtp() async {
    final String phone = _otpPhoneCtrl.text.trim();
    final String? err = Validators.phone(phone);
    if (err != null) {
      setState(() {
        _errorMessage = err;
        _successMessage = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await _api.requestOtp(phone: phone);
      setState(() {
        _isLoading = false;
        _otpRequested = true;
        _successMessage = 'OTP sent. Enter it below to log in.';
      });
    } on ApiException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to request OTP. Please try again.';
      });
    }
  }

  Future<void> _verifyOtpAndLogin() async {
    final String phone = _otpPhoneCtrl.text.trim();
    final String otp = _otpCtrl.text.trim();

    final String? phoneErr = Validators.phone(phone);
    final String? otpErr = Validators.otp(otp);

    if (phoneErr != null || otpErr != null) {
      setState(() {
        _errorMessage = phoneErr ?? otpErr;
        _successMessage = null;
      });
      return;
    }

    if (!_otpRequested) {
      setState(() {
        _errorMessage = 'Please request an OTP first.';
        _successMessage = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await _api.verifyOtp(phone: phone, otp: otp);

      setState(() {
        _isLoading = false;
        _successMessage = 'Logged in successfully via OTP.';
      });
    } on ApiException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'OTP verification failed. Please try again.';
      });
    }
  }

  Future<void> _passwordResetRequest() async {
    final String phoneOrEmail = _phoneOrEmailCtrl.text.trim();
    final String? err = Validators.phoneOrEmail(phoneOrEmail);
    if (err != null) {
      setState(() {
        _errorMessage = err;
        _successMessage = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await _api.passwordResetRequest(phoneOrEmail: phoneOrEmail);
      setState(() {
        _isLoading = false;
        _successMessage = 'Reset OTP sent. Enter OTP + new password below.';
      });
    } on ApiException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to request password reset.';
      });
    }
  }

  Future<void> _passwordResetConfirm() async {
    final String phoneOrEmail = _phoneOrEmailCtrl.text.trim();
    final String otp = _resetOtpCtrl.text.trim();
    final String newPassword = _resetNewPasswordCtrl.text;

    final String? idErr = Validators.phoneOrEmail(phoneOrEmail);
    final String? otpErr = Validators.otp(otp);
    final String? passErr = Validators.password(newPassword);

    if (idErr != null || otpErr != null || passErr != null) {
      setState(() {
        _errorMessage = idErr ?? otpErr ?? passErr;
        _successMessage = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await _api.passwordResetConfirm(
        phoneOrEmail: phoneOrEmail,
        otp: otp,
        newPassword: newPassword,
      );
      setState(() {
        _isLoading = false;
        _successMessage = 'Password updated. You can now log in.';
        _failedPasswordAttempts = 0;
      });
    } on ApiException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to confirm reset. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool passwordMode = _mode == LoginMode.password;

    return AuthScaffold(
      title: 'Login',
      subtitle: 'Use password or OTP. Reset password if you forgot it.',
      child: Column(
        children: <Widget>[
          SegmentedButton<LoginMode>(
            segments: const <ButtonSegment<LoginMode>>[
              ButtonSegment<LoginMode>(
                value: LoginMode.password,
                label: Text('Password'),
                icon: Icon(Icons.lock_outline),
              ),
              ButtonSegment<LoginMode>(
                value: LoginMode.otp,
                label: Text('OTP'),
                icon: Icon(Icons.sms_outlined),
              ),
            ],
            selected: <LoginMode>{_mode},
            onSelectionChanged: (Set<LoginMode> selection) {
              setState(() {
                _mode = selection.first;
                _errorMessage = null;
                _successMessage = null;
              });
            },
          ),
          const SizedBox(height: 14),
          Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                if (passwordMode) ...<Widget>[
                  TextFormField(
                    controller: _phoneOrEmailCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Phone or email',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (String? v) => Validators.phoneOrEmail(v),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    validator: (String? v) => Validators.password(v),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _isLoading ? null : _passwordResetRequest,
                      child: const Text('Forgot password?'),
                    ),
                  ),
                  if (_successMessage != null) ...<Widget>[
                    const SizedBox(height: 6),
                    Text(
                      _successMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _resetOtpCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Reset OTP',
                        prefixIcon: Icon(Icons.pin_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _resetNewPasswordCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'New password',
                        prefixIcon: Icon(Icons.lock_reset_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: _isLoading ? null : _passwordResetConfirm,
                      child: Text(_isLoading ? 'Updating...' : 'Confirm reset'),
                    ),
                  ],
                  const SizedBox(height: 8),
                  if (_lockedOut)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Locked out after $_lockoutAfter failed attempts.',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _loginWithPassword,
                    child: Text(_isLoading ? 'Logging in...' : 'Login'),
                  ),
                ] else ...<Widget>[
                  TextFormField(
                    controller: _otpPhoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone number',
                      hintText: '+15551234567',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _otpCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'OTP',
                      prefixIcon: const Icon(Icons.pin_outlined),
                      helperText: _otpRequested
                          ? 'Enter the OTP you received.'
                          : 'Tap "Send OTP" first.',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : _requestOtp,
                          child: Text(_isLoading ? 'Sending...' : 'Send OTP'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _verifyOtpAndLogin,
                          child: Text(_isLoading ? 'Verifying...' : 'Login'),
                        ),
                      ),
                    ],
                  ),
                ],
                if (_errorMessage != null) ...<Widget>[
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamed(SignupScreen.routeName);
            },
            child: const Text('New here? Create an account'),
          ),
        ],
      ),
    );
  }
}
