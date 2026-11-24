import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/list_cards.dart';
import '../../../models/announcement_model.dart';
import '../../../models/report_model.dart';
import '../../../models/user_model.dart';
import '../../../providers/app_scope.dart';
import '../../../providers/app_state.dart';
import '../announcements/announcement_detail_screen.dart';
import '../directory/directory_screen.dart';
import '../documents/document_types_screen.dart';
import '../documents/my_documents_screen.dart';
import '../map/barangay_map_screen.dart';
import '../notifications/notifications_screen.dart';
import '../reports/report_detail_screen.dart';
import '../reports/submit_report_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.onNavigateTab});

  final ValueChanged<int> onNavigateTab;

  @override
  Widget build(BuildContext context) {
    final AppState state = AppScope.of(context);
    final UserModel? user = state.user;
    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final List<AnnouncementModel> advisories = state.publishedAnnouncements;
    final List<ReportModel> reports = state.reportList;
    final ReportModel? latestReport = reports.isEmpty ? null : reports.first;

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: state.refresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _HomeHeader(
              user: user,
              unread: state.unreadNotificationCount,
              onNotifications: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const NotificationsScreen(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _EmergencyBanner(
                    onTap: () => onNavigateTab(3),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'What do you need?',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraints) {
                      final int columns = constraints.maxWidth > 620 ? 3 : 2;
                      return GridView.count(
                        crossAxisCount: columns,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: columns == 3 ? 1.22 : 1.12,
                        children: <Widget>[
                          _ServiceTile(
                            icon: Icons.rate_review_outlined,
                            title: 'Submit Report',
                            subtitle: 'Raise a concern',
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const SubmitReportScreen(),
                              ),
                            ),
                          ),
                          _ServiceTile(
                            icon: Icons.map_outlined,
                            title: 'Barangay Map',
                            subtitle: 'Find community facilities',
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const BarangayMapScreen(),
                              ),
                            ),
                          ),
                          _ServiceTile(
                            icon: Icons.description_outlined,
                            title: 'Request Documents',
                            subtitle: 'Clearances & certificates',
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const DocumentTypesScreen(),
                              ),
                            ),
                          ),
                          _ServiceTile(
                            icon: Icons.contact_page_outlined,
                            title: 'Official Directory',
                            subtitle: 'Find local offices',
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const DirectoryScreen(),
                              ),
                            ),
                          ),
                          _ServiceTile(
                            icon: Icons.emergency_outlined,
                            title: 'Emergency',
                            subtitle: 'Hotlines & responders',
                            badgeColor: AppColors.danger,
                            onTap: () => onNavigateTab(3),
                          ),
                          _ServiceTile(
                            icon: Icons.notifications_none_rounded,
                            title: 'Notifications',
                            subtitle: state.unreadNotificationCount > 0
                                ? '${state.unreadNotificationCount} unread updates'
                                : 'Barangay updates',
                            badgeColor: AppColors.accentYellow,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const NotificationsScreen(),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  if (latestReport != null) ...<Widget>[
                    const SizedBox(height: 24),
                    SectionHeader(
                      title: 'Your latest report',
                      actionLabel: 'View all',
                      onAction: () => onNavigateTab(2),
                    ),
                    ReportListCard(
                      report: latestReport,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => ReportDetailScreen(reportId: latestReport.id),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  SectionHeader(
                    title: 'Latest advisories',
                    actionLabel: 'View all',
                    onAction: () => onNavigateTab(1),
                  ),
                  if (advisories.isEmpty)
                    AppCard(
                      child: Row(
                        children: <Widget>[
                          const IconTile(icon: Icons.campaign_outlined),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'No announcements have been published yet.',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...advisories.take(2).map(
                          (AnnouncementModel announcement) => AnnouncementCard(
                            announcement: announcement,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => AnnouncementDetailScreen(
                                  announcementId: announcement.id,
                                ),
                              ),
                            ),
                          ),
                        ),
                  const SizedBox(height: 14),
                  _QuickDocumentsTile(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const MyDocumentsScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Center(
                    child: Text(
                      AppConstants.sampleDataNotice,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 10.5,
                        height: 1.5,
                        color: AppColors.textHint,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.user,
    required this.unread,
    required this.onNotifications,
  });

  final UserModel user;
  final int unread;
  final VoidCallback onNotifications;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                AppAvatar(
                  initials: user.initials,
                  size: 44,
                  fontSize: 15,
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onNotifications,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      Container(
                        height: 38,
                        width: 38,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.14),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.notifications_none_rounded,
                          size: 21,
                          color: Colors.white,
                        ),
                      ),
                      if (unread > 0)
                        Positioned(
                          top: -2,
                          right: -2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 1.5),
                            constraints: const BoxConstraints(minWidth: 18),
                            decoration: BoxDecoration(
                              color: AppColors.danger,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.primaryDark,
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              unread > 9 ? '9+' : '$unread',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              Formatters.greeting(DateTime.now()),
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(0.72),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${user.firstName}!',
              style: const TextStyle(
                fontSize: 29,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Icon(Icons.verified_rounded,
                          size: 14, color: Colors.white),
                      const SizedBox(width: 5),
                      Text(
                        user.verified ? 'Verified Resident' : 'Resident',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.location_on_outlined,
                        size: 14, color: Colors.white.withOpacity(0.75)),
                    const SizedBox(width: 4),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 220),
                      child: Text(
                        user.address.isEmpty
                            ? AppConstants.barangayName
                            : user.address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.78),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmergencyBanner extends StatelessWidget {
  const _EmergencyBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.dangerSoft,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
          child: Row(
            children: <Widget>[
              Container(
                height: 44,
                width: 44,
                decoration: const BoxDecoration(
                  color: AppColors.danger,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.priority_high_rounded,
                    size: 24, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Emergency assistance',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.dangerStrong,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Get help from responders now',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.dangerStrong),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badgeColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? badgeColor;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              IconTile(icon: icon),
              const Spacer(),
              if (badgeColor != null)
                Container(
                  height: 8,
                  width: 8,
                  decoration: BoxDecoration(
                    color: badgeColor,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          const Spacer(),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickDocumentsTile extends StatelessWidget {
  const _QuickDocumentsTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      color: AppColors.primarySoft,
      showShadow: false,
      padding: const EdgeInsets.all(15),
      child: Row(
        children: <Widget>[
          IconTile(
            icon: Icons.folder_shared_outlined,
            background: Colors.white,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'My document requests',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Track clearances and certificates',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              color: AppColors.primaryDark),
        ],
      ),
    );
  }
}
