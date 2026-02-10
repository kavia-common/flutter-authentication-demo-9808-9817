import 'package:flutter/material.dart';

import '../services/api_error.dart';
import '../services/auth_api.dart';
import '../services/auth_session.dart';
import '../utils/validators.dart';
import '../widgets/auth_scaffold.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart';

enum SignupMode {
  otp,
  password,
}

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  static const String routeName = '/signup';

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _otpCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();

  final AuthApi _api = AuthApi();
  final AuthSession _session = AuthSession();

  SignupMode _mode = SignupMode.otp;
  bool _consentAccepted = false;

  bool _isLoading = false;
  bool _otpRequested = false;

  bool _navigateToDashboard = false;

  // Keep all user-facing messages in primitives only to avoid async context issues.
  String? _errorMessage;
  String? _successMessage;

  // OTP edge-case counters (client-side guard; backend should also enforce rate limits).
  int _otpRequestCount = 0;
  int _otpVerifyFailCount = 0;

  static const int _maxOtpRequests = 3;
  static const int _maxOtpVerifyFails = 5;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _nameCtrl.dispose();
    _otpCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  bool get _canRequestOtp => _otpRequestCount < _maxOtpRequests;
  bool get _canVerifyOtp => _otpVerifyFailCount < _maxOtpVerifyFails;

  Future<void> _requestOtp() async {
    final bool valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    if (!_consentAccepted) {
      setState(() {
        _errorMessage = 'Please accept Terms & Privacy to continue.';
        _successMessage = null;
      });
      return;
    }

    if (!_canRequestOtp) {
      setState(() {
        _errorMessage = 'OTP request limit reached. Please try again later.';
        _successMessage = null;
      });
      return;
    }

    final String phone = _phoneCtrl.text.trim();

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
        _otpRequestCount += 1;
        _successMessage = 'OTP sent. Please check your messages.';
      });
    } on ApiException catch (e) {
      if (e.code == BackendErrorCode.rateLimited) {
        // Mirror server rate limit with a friendlier message; keep existing local caps.
        setState(() {
          _isLoading = false;
          _errorMessage = e.retryAfterSeconds != null
              ? 'Too many requests. Try again in ${e.retryAfterSeconds} seconds.'
              : 'Too many requests. Please wait before trying again.';
          _successMessage = null;
        });
        return;
      }

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

  Future<void> _verifyOtpAndCreate() async {
    final bool valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    if (!_consentAccepted) {
      setState(() {
        _errorMessage = 'Please accept Terms & Privacy to continue.';
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

    if (!_canVerifyOtp) {
      setState(() {
        _errorMessage = 'Too many incorrect OTP attempts. Try again later.';
        _successMessage = null;
      });
      return;
    }

    final String phone = _phoneCtrl.text.trim();
    final String otp = _otpCtrl.text.trim();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final Map<String, dynamic> res = await _api.verifyOtp(phone: phone, otp: otp);
      await _session.saveTokensFromResponse(res);

      setState(() {
        _isLoading = false;
        _successMessage = 'Account created and verified successfully.';
        _navigateToDashboard = true;
      });
    } on ApiException catch (e) {
      if (e.code == BackendErrorCode.otpExpired) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'OTP expired. Please request a new OTP.';
          _successMessage = null;
          _otpRequested = false;
        });
        return;
      }

      if (e.code == BackendErrorCode.otpRetryExceeded) {
        // Force local lock immediately (existing guard uses _maxOtpVerifyFails).
        setState(() {
          _isLoading = false;
          _otpVerifyFailCount = _maxOtpVerifyFails;
          _errorMessage = 'Too many incorrect OTP attempts. Try again later.';
          _successMessage = null;
        });
        return;
      }

      if (e.code == BackendErrorCode.rateLimited) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.retryAfterSeconds != null
              ? 'Too many requests. Try again in ${e.retryAfterSeconds} seconds.'
              : 'Too many requests. Please wait before trying again.';
          _successMessage = null;
        });
        return;
      }

      final bool isOtpWrong = (e.statusCode == 400 || e.statusCode == 401);
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
        if (isOtpWrong) _otpVerifyFailCount += 1;
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Verification failed. Please try again.';
      });
    }
  }

  Future<void> _signupWithPassword() async {
    final bool valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    if (!_consentAccepted) {
      setState(() {
        _errorMessage = 'Please accept Terms & Privacy to continue.';
        _successMessage = null;
      });
      return;
    }

    final String phone = _phoneCtrl.text.trim();
    final String email = _emailCtrl.text.trim();
    final String name = _nameCtrl.text.trim();
    final String password = _passwordCtrl.text;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final Map<String, dynamic> res = await _api.signupWithPassword(
        phone: phone,
        // Email is required for the password-based signup flow.
        email: email,
        name: name.isEmpty ? null : name,
        password: password,
        consentAccepted: true,
      );

      await _session.saveTokensFromResponse(res);

      setState(() {
        _isLoading = false;
        _successMessage = 'Account created successfully.';
        _navigateToDashboard = true;
      });
    } on ApiException catch (e) {
      if (e.code == BackendErrorCode.duplicateUser) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'An account already exists for this phone/email. Please log in instead.';
          _successMessage = null;
        });
        return;
      }

      if (e.code == BackendErrorCode.rateLimited) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.retryAfterSeconds != null
              ? 'Too many requests. Try again in ${e.retryAfterSeconds} seconds.'
              : 'Too many requests. Please wait before trying again.';
          _successMessage = null;
        });
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Signup failed. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_navigateToDashboard) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          DashboardScreen.routeName,
          (Route<dynamic> r) => false,
        );
      });
    }

    final bool otpMode = _mode == SignupMode.otp;

    return AuthScaffold(
      title: 'Create account',
      subtitle: 'Sign up with phone (OTP) or set a password for multi-login.',
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            SegmentedButton<SignupMode>(
              segments: const <ButtonSegment<SignupMode>>[
                ButtonSegment<SignupMode>(
                  value: SignupMode.otp,
                  label: Text('OTP'),
                  icon: Icon(Icons.sms_outlined),
                ),
                ButtonSegment<SignupMode>(
                  value: SignupMode.password,
                  label: Text('Password'),
                  icon: Icon(Icons.lock_outline),
                ),
              ],
              selected: <SignupMode>{_mode},
              onSelectionChanged: (Set<SignupMode> selection) {
                setState(() {
                  _mode = selection.first;
                  _errorMessage = null;
                  _successMessage = null;
                });
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone number',
                hintText: '+15551234567',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              validator: (String? v) => Validators.phone(v),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: otpMode ? 'Email (optional)' : 'Email',
                prefixIcon: const Icon(Icons.email_outlined),
              ),
              // Email is optional for OTP signup, required for password signup.
              validator: (String? v) =>
                  otpMode ? Validators.emailOptional(v) : Validators.emailRequired(v),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameCtrl,
              keyboardType: TextInputType.name,
              decoration: const InputDecoration(
                labelText: 'Full name (optional)',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (String? v) => Validators.fullNameOptional(v),
            ),
            if (otpMode) ...<Widget>[
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
                validator: (String? v) {
                  if (!_otpRequested) return null; // avoid blocking before request
                  return Validators.otp(v);
                },
              ),
            ] else ...<Widget>[
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
            ],
            const SizedBox(height: 10),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _consentAccepted,
              onChanged: (bool? v) {
                setState(() {
                  _consentAccepted = v ?? false;
                  _errorMessage = null;
                });
              },
              title: const Text('I accept Terms & Privacy'),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            if (_errorMessage != null) ...<Widget>[
              const SizedBox(height: 8),
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
            if (_successMessage != null) ...<Widget>[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _successMessage!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 14),
            if (otpMode) ...<Widget>[
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
                      onPressed: _isLoading ? null : _verifyOtpAndCreate,
                      child: Text(_isLoading ? 'Verifying...' : 'Create account'),
                    ),
                  ),
                ],
              ),
            ] else ...<Widget>[
              ElevatedButton(
                onPressed: _isLoading ? null : _signupWithPassword,
                child: Text(_isLoading ? 'Creating...' : 'Create account'),
              ),
            ],
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed(LoginScreen.routeName);
              },
              child: const Text('Already have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }
}
