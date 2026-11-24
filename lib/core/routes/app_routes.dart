import 'package:flutter/material.dart';

import '../../screens/admin/admin_home_screen.dart';
import '../../screens/authentication/forgot_password_screen.dart';
import '../../screens/authentication/login_screen.dart';
import '../../screens/authentication/onboarding_screen.dart';
import '../../screens/authentication/register_screen.dart';
import '../../screens/resident/resident_shell.dart';
import '../../screens/splash/splash_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String residentHome = '/home';
  static const String adminHome = '/admin';

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _route(settings, const SplashScreen());
      case onboarding:
        return _route(settings, const OnboardingScreen());
      case login:
        return _route(settings, const LoginScreen());
      case register:
        return _route(settings, const RegisterScreen());
      case forgotPassword:
        return _route(settings, const ForgotPasswordScreen());
      case residentHome:
        return _route(settings, const ResidentShell());
      case adminHome:
        return _route(settings, const AdminHomeScreen());
      default:
        return _route(settings, const SplashScreen());
    }
  }

  static MaterialPageRoute<dynamic> _route(RouteSettings settings, Widget page) {
    return MaterialPageRoute<dynamic>(builder: (_) => page, settings: settings);
  }
}
