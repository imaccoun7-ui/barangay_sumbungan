import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_bottom_nav.dart';
import 'account/account_screen.dart';
import 'announcements/announcements_screen.dart';
import 'dashboard/dashboard_screen.dart';
import 'emergency/emergency_screen.dart';
import 'reports/reports_screen.dart';

/// Resident container: Home, Advisory, Reports, Emergency and Account tabs.
class ResidentShell extends StatefulWidget {
  const ResidentShell({super.key});

  @override
  State<ResidentShell> createState() => _ResidentShellState();
}

class _ResidentShellState extends State<ResidentShell> {
  int _index = 0;

  void goToTab(int index) {
    if (index == _index) return;
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = <Widget>[
      DashboardScreen(onNavigateTab: goToTab),
      AnnouncementsScreen(onNavigateTab: goToTab),
      const ReportsScreen(),
      const EmergencyScreen(),
      const AccountScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _index,
        onSelected: goToTab,
        items: const <AppNavItem>[
          AppNavItem(
            label: 'Home',
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
          ),
          AppNavItem(
            label: 'Advisory',
            icon: Icons.campaign_outlined,
            activeIcon: Icons.campaign_rounded,
          ),
          AppNavItem(
            label: 'Reports',
            icon: Icons.bar_chart_outlined,
            activeIcon: Icons.bar_chart_rounded,
          ),
          AppNavItem(
            label: 'Emergency',
            icon: Icons.warning_amber_rounded,
            activeIcon: Icons.warning_rounded,
          ),
          AppNavItem(
            label: 'Account',
            icon: Icons.person_outline_rounded,
            activeIcon: Icons.person_rounded,
          ),
        ],
      ),
    );
  }
}
