import 'package:flutter/material.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_dialogs.dart';
import '../../../models/user_model.dart';
import '../../../providers/app_scope.dart';
import '../../../providers/app_state.dart';
import '../directory/admin_directory_screen.dart';
import '../notifications/admin_notifications_screen.dart';
import '../residents/admin_residents_screen.dart';

class AdminMoreScreen extends StatelessWidget {
  const AdminMoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState state = AppScope.of(context);
    final UserModel? user = state.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          children: <Widget>[
            const ScreenHeading(
              title: 'More',
              subtitle: 'Manage barangay information and your account.',
            ),
            const SizedBox(height: 18),
            AppCard(
              color: AppColors.primaryDark,
              showShadow: false,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: <Widget>[
                  AppAvatar(
                    initials: user?.initials ?? 'BA',
                    size: 46,
                    fontSize: 15,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          user?.fullName ?? 'Administrator',
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user?.email ?? '',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.75),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      'Admin',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: <Widget>[
                  _MoreRow(
                    icon: Icons.contact_page_outlined,
                    title: 'Directory & Map',
                    subtitle: 'Officials, hotlines and facilities',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const AdminDirectoryScreen(),
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  _MoreRow(
                    icon: Icons.groups_2_outlined,
                    title: 'Residents',
                    subtitle: 'Registered accounts and status',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const AdminResidentsScreen(),
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  _MoreRow(
                    icon: Icons.notifications_active_outlined,
                    title: 'Notifications',
                    subtitle: 'Send updates and review records',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const AdminNotificationsScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            AppCard(
              padding: const EdgeInsets.all(15),
              color: AppColors.surfaceMuted,
              showShadow: false,
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(Icons.shield_outlined,
                      size: 16, color: AppColors.textSecondary),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Administrator actions are checked by role in the service '
                      'layer and must also be enforced by Firestore Security '
                      'Rules once Firebase is connected.',
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: () async {
                final bool confirmed = await AppDialogs.confirm(
                  context,
                  title: 'Sign out?',
                  message: 'You will return to the sign-in screen.',
                  confirmLabel: 'Sign out',
                );
                if (!confirmed || !context.mounted) return;
                await AppScope.read(context).signOut();
                if (!context.mounted) return;
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.login,
                  (Route<dynamic> route) => false,
                );
              },
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text('Sign out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger,
                side: const BorderSide(color: AppColors.dangerSoft),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoreRow extends StatelessWidget {
  const _MoreRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: <Widget>[
            Icon(icon, size: 19, color: AppColors.primaryDark),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}
