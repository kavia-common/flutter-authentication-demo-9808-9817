import 'package:flutter/material.dart';

import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';
import '../theme/app_theme.dart';

class AuthDemoApp extends StatelessWidget {
  const AuthDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auth Demo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: SignupScreen.routeName,
      routes: <String, WidgetBuilder>{
        SignupScreen.routeName: (_) => const SignupScreen(),
        LoginScreen.routeName: (_) => const LoginScreen(),
      },
    );
  }
}
