import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/app_scope.dart';
import '../../providers/app_state.dart';

/// Branded launch screen. Checks the persisted session and routes the user to
/// the resident dashboard, the administrator dashboard, or sign in.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _route());
  }

  Future<void> _route() async {
    final AppState state = AppScope.read(context);
    bool showOnboarding = false;
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      showOnboarding =
          !(prefs.getBool('barangay_sumbungan_onboarding_seen') ?? false);
    } catch (_) {
      showOnboarding = false;
    }
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    if (!mounted) return;
    final NavigatorState navigator = Navigator.of(context);
    if (state.user == null) {
      navigator.pushReplacementNamed(
        showOnboarding ? AppRoutes.onboarding : AppRoutes.login,
      );
    } else if (state.isAdmin) {
      navigator.pushReplacementNamed(AppRoutes.adminHome);
    } else {
      navigator.pushReplacementNamed(AppRoutes.residentHome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Color(0xFF1E5B34), Color(0xFF16482A)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: <Widget>[
                const Spacer(flex: 3),
                Image.asset(
                  'assets/images/logo_mark.png',
                  height: 148,
                  fit: BoxFit.contain,
                  semanticLabel: 'Barangay Sumbungan logo',
                ),
                const SizedBox(height: 26),
                const Text(
                  AppConstants.appName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  AppConstants.tagline,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.6,
                    color: Colors.white.withOpacity(0.82),
                  ),
                ),
                const Spacer(flex: 4),
                const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Preparing your barangay services…',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Colors.white.withOpacity(0.62),
                  ),
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
