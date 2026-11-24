import 'package:flutter/material.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_dialogs.dart';
import '../../../models/document_model.dart';
import '../../../models/report_model.dart';
import '../../../models/user_model.dart';
import '../../../providers/app_scope.dart';
import '../../../providers/app_state.dart';
import '../documents/my_documents_screen.dart';
import '../notifications/notifications_screen.dart';
import '../reports/reports_screen.dart';
import 'change_password_screen.dart';
import 'edit_profile_screen.dart';
import 'help_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState state = AppScope.of(context);
    final UserModel? user = state.user;
    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final int reportCount = state.reportList.length;
    final int resolved = state.reportList
        .where((ReportModel r) => r.status == ReportStatus.solved)
        .length;
    final int documents = state.documentRequestList.length;
    final int activeDocuments = state.documentRequestList
        .where((DocumentRequestModel d) =>
            d.status != DocumentStatus.completed &&
            d.status != DocumentStatus.rejected)
        .length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 8),
                child: Text(
                  'Profile',
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            SoftGreenBanner(
              child: Column(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.55),
                      shape: BoxShape.circle,
                    ),
                    child: AppAvatar(
                      initials: user.initials,
                      size: 72,
                      background: const Color(0xFF7ED08C),
                      foreground: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    user.fullName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${user.address.isEmpty ? 'Barangay Sumbungan' : user.address}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        user.verified
                            ? Icons.verified_rounded
                            : Icons.pending_outlined,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        user.verified ? 'Verified Resident' : 'Resident',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -18),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AppCard(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    children: <Widget>[
                      _ProfileStat(value: '$reportCount', label: 'Reports'),
                      _divider(),
                      _ProfileStat(value: '$resolved', label: 'Resolved'),
                      _divider(),
                      _ProfileStat(value: '$documents', label: 'Documents'),
                    ],
                  ),
                ),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -8),
              child: Column(
                children: <Widget>[
                  if (activeDocuments > 0)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: AppCard(
                        color: AppColors.primarySoft,
                        showShadow: false,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const MyDocumentsScreen(),
                          ),
                        ),
                        child: Row(
                          children: <Widget>[
                            const Icon(Icons.folder_open_rounded,
                                size: 18, color: AppColors.primaryDark),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '$activeDocuments document request${activeDocuments == 1 ? '' : 's'} in progress',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded,
                                color: AppColors.primaryDark),
                          ],
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: AppCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: <Widget>[
                          _MenuRow(
                            title: 'Personal information',
                            subtitle: 'Manage your resident details',
                            icon: Icons.person_outline_rounded,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const EditProfileScreen(),
                              ),
                            ),
                          ),
                          const Divider(height: 1),
                          _MenuRow(
                            title: 'My Report History',
                            subtitle: 'View all submitted concerns',
                            icon: Icons.assignment_outlined,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const ReportsScreen(),
                              ),
                            ),
                          ),
                          const Divider(height: 1),
                          _MenuRow(
                            title: 'My Document Requests',
                            subtitle: 'Track clearances and certificates',
                            icon: Icons.description_outlined,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const MyDocumentsScreen(),
                              ),
                            ),
                          ),
                          const Divider(height: 1),
                          _MenuRow(
                            title: 'Notifications',
                            subtitle: state.unreadNotificationCount > 0
                                ? '${state.unreadNotificationCount} unread update${state.unreadNotificationCount == 1 ? '' : 's'}'
                                : 'Barangay updates and alerts',
                            icon: Icons.notifications_none_rounded,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const NotificationsScreen(),
                              ),
                            ),
                          ),
                          const Divider(height: 1),
                          _MenuRow(
                            title: 'Account & Security',
                            subtitle: 'Password and preferences',
                            icon: Icons.lock_outline_rounded,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const ChangePasswordScreen(),
                              ),
                            ),
                          ),
                          const Divider(height: 1),
                          _MenuRow(
                            title: 'Help & FAQs',
                            subtitle: 'How to use barangay services',
                            icon: Icons.help_outline_rounded,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const HelpScreen(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final bool confirmed = await AppDialogs.confirm(
                          context,
                          title: 'Sign out?',
                          message:
                              'You will need to sign in again to access your '
                              'reports and barangay services.',
                          confirmLabel: 'Sign out',
                        );
                        if (!confirmed) return;
                        final AppState state = AppScope.read(context);
                        await state.signOut();
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
                  ),
                  const SizedBox(height: 26),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Container(
        height: 32,
        width: 1,
        color: AppColors.divider,
      );
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: <Widget>[
          Text(
            value,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
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
