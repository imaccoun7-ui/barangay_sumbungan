import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../core/widgets/empty_state.dart';
import '../../providers/app_scope.dart';
import 'announcements/admin_announcements_screen.dart';
import 'dashboard/admin_dashboard_screen.dart';
import 'documents/admin_documents_screen.dart';
import 'more/admin_more_screen.dart';
import 'reports/admin_reports_screen.dart';

/// Administrator container. Role is verified here as well as in the services,
/// so a resident can never reach an administrator screen.
class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    if (!AppScope.of(context).isAdmin) {
      return const AccessDeniedState();
    }

    final List<Widget> pages = <Widget>[
      AdminDashboardScreen(onNavigateTab: (int index) => setState(() => _index = index)),
      const AdminReportsScreen(),
      const AdminDocumentsScreen(),
      const AdminAnnouncementsScreen(),
      const AdminMoreScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _index,
        onSelected: (int index) => setState(() => _index = index),
        items: const <AppNavItem>[
          AppNavItem(
            label: 'Overview',
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard_rounded,
          ),
          AppNavItem(
            label: 'Reports',
            icon: Icons.assignment_outlined,
            activeIcon: Icons.assignment_rounded,
          ),
          AppNavItem(
            label: 'Requests',
            icon: Icons.description_outlined,
            activeIcon: Icons.description_rounded,
          ),
          AppNavItem(
            label: 'Updates',
            icon: Icons.campaign_outlined,
            activeIcon: Icons.campaign_rounded,
          ),
          AppNavItem(
            label: 'More',
            icon: Icons.grid_view_outlined,
            activeIcon: Icons.grid_view_rounded,
          ),
        ],
      ),
    );
  }
}
