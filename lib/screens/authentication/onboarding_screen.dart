import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_button.dart';

class _OnboardingPage {
  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;
}

/// Three-step introduction shown before the first sign in, matching the
/// Fidelity V1 onboarding cards.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  static const List<_OnboardingPage> _pages = <_OnboardingPage>[
    _OnboardingPage(
      icon: Icons.home_work_outlined,
      title: 'A Stronger Barangay, Together',
      message:
          'Barangay Sumbungan brings services, emergency help and community '
          'updates into one place for every resident.',
    ),
    _OnboardingPage(
      icon: Icons.touch_app_outlined,
      title: 'Easy Access to Essential Services',
      message:
          'Find hotlines, request documents and reach barangay officials '
          'without lining up at the barangay hall.',
    ),
    _OnboardingPage(
      icon: Icons.trending_up_rounded,
      title: 'Report, Track & Make a Difference',
      message:
          'Submit community concerns with photos and follow every update until '
          'the concern is resolved.',
    ),
  ];

  Future<void> _finish() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('barangay_sumbungan_onboarding_seen', true);
    } catch (_) {
      // Non-fatal: the walkthrough simply appears again next launch.
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  void _next() {
    if (_index == _pages.length - 1) {
      _finish();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool last = _index == _pages.length - 1;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 22),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Icon(Icons.campaign_rounded,
                      size: 20, color: AppColors.primaryDark),
                  const SizedBox(width: 8),
                  const Text(
                    'Barangay Sumbungan',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _finish,
                    child: const Text(
                      'Skip',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  onPageChanged: (int index) => setState(() => _index = index),
                  itemCount: _pages.length,
                  itemBuilder: (BuildContext context, int index) {
                    final _OnboardingPage page = _pages[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          height: 208,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: Stack(
                            children: <Widget>[
                              Positioned(
                                top: 22,
                                left: 22,
                                child: Container(
                                  height: 34,
                                  width: 34,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.6),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Center(
                                child: Container(
                                  height: 108,
                                  width: 108,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    page.icon,
                                    size: 50,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 26,
                                right: 26,
                                child: Icon(
                                  Icons.wb_sunny_outlined,
                                  size: 26,
                                  color: AppColors.accentYellow
                                      .withOpacity(0.85),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 34),
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          page.message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.6,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List<Widget>.generate(_pages.length, (int index) {
                  final bool active = index == _index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    height: 7,
                    width: active ? 22 : 7,
                    decoration: BoxDecoration(
                      color: active ? AppColors.primary : AppColors.divider,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 22),
              PrimaryButton(
                label: last ? 'Get Started' : 'Next',
                onPressed: _next,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
