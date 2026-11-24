import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/list_cards.dart';
import '../../../models/announcement_model.dart';
import '../../../models/document_model.dart';
import '../../../models/report_model.dart';
import '../../../models/user_model.dart';
import '../../../providers/app_scope.dart';
import '../../../providers/app_state.dart';
import '../documents/admin_document_detail_screen.dart';
import '../reports/admin_report_detail_screen.dart';

/// Barangay administrator overview: service activity at a glance.
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key, required this.onNavigateTab});

  final ValueChanged<int> onNavigateTab;

  @override
  Widget build(BuildContext context) {
    final AppState state = AppScope.of(context);
    final UserModel? user = state.user;
    final List<ReportModel> reports = state.reportList;
    final List<DocumentRequestModel> requests = state.documentRequestList;
    final int residents = state.residents
        .where((UserModel u) => u.role == UserRole.resident)
        .length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: state.refresh,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              decoration: const BoxDecoration(
                color: AppColors.primaryDark,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
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
                          initials: user?.initials ?? 'BA',
                          size: 42,
                          fontSize: 14,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Barangay Administrator',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                              Text(
                                user?.fullName ?? 'Administrator',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Barangay operations',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage reports, document requests and community updates.',
                      style: TextStyle(
                        fontSize: 11.5,
                        height: 1.5,
                        color: Colors.white.withOpacity(0.75),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.55,
                    children: <Widget>[
                      _StatCard(
                        label: 'Registered residents',
                        value: '$residents',
                        icon: Icons.groups_2_outlined,
                        color: AppColors.primary,
                        background: AppColors.primarySoft,
                      ),
                      _StatCard(
                        label: 'Total reports',
                        value: '${reports.length}',
                        icon: Icons.assignment_outlined,
                        color: const Color(0xFF3B6FB6),
                        background: const Color(0xFFE4EDF9),
                      ),
                      _StatCard(
                        label: 'Pending reports',
                        value: '${state.pendingReports}',
                        icon: Icons.pending_actions_outlined,
                        color: AppColors.info,
                        background: AppColors.infoSoft,
                      ),
                      _StatCard(
                        label: 'In progress',
                        value: '${state.inProgressReports}',
                        icon: Icons.autorenew_rounded,
                        color: AppColors.warning,
                        background: AppColors.warningSoft,
                      ),
                      _StatCard(
                        label: 'Solved reports',
                        value: '${state.solvedReports}',
                        icon: Icons.task_alt_rounded,
                        color: AppColors.success,
                        background: AppColors.successSoft,
                      ),
                      _StatCard(
                        label: 'Pending documents',
                        value: '${state.pendingDocumentRequests}',
                        icon: Icons.description_outlined,
                        color: AppColors.danger,
                        background: AppColors.dangerSoft,
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  SectionHeader(
                    title: 'Recently submitted reports',
                    actionLabel: 'Manage',
                    onAction: () => onNavigateTab(1),
                  ),
                  if (reports.isEmpty)
                    const AppCard(
                      child: Text(
                        'No reports have been submitted yet.',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                  else
                    ...reports.take(3).map(
                          (ReportModel report) => ReportListCard(
                            report: report,
                            showResident: true,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => AdminReportDetailScreen(
                                  reportId: report.id,
                                ),
                              ),
                            ),
                          ),
                        ),
                  const SizedBox(height: 6),
                  SectionHeader(
                    title: 'Recent document requests',
                    actionLabel: 'Manage',
                    onAction: () => onNavigateTab(2),
                  ),
                  if (requests.isEmpty)
                    const AppCard(
                      child: Text(
                        'No document requests yet.',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                  else
                    ...requests.take(2).map(
                          (DocumentRequestModel request) => DocumentRequestCard(
                            request: request,
                            showResident: true,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => AdminDocumentDetailScreen(
                                  requestId: request.id,
                                ),
                              ),
                            ),
                          ),
                        ),
                  const SizedBox(height: 6),
                  SectionHeader(
                    title: 'Announcements',
                    actionLabel: 'Manage',
                    onAction: () => onNavigateTab(3),
                  ),
                  if (state.announcementList.isEmpty)
                    const AppCard(
                      child: Text(
                        'No announcements published yet.',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                  else
                    ...state.announcementList.take(3).map(
                          (AnnouncementModel announcement) => AppCard(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: <Widget>[
                                const IconTile(
                                    icon: Icons.campaign_outlined, size: 38),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        announcement.title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${announcement.published ? 'Published' : 'Draft'} · ${Formatters.date(announcement.createdAt)}',
                                        style: const TextStyle(
                                          fontSize: 10.5,
                                          color: AppColors.textHint,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.background,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              IconTile(
                icon: icon,
                size: 34,
                background: background,
                foreground: color,
                radius: 10,
              ),
              const Spacer(),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            label,
            maxLines: 2,
            style: const TextStyle(
              fontSize: 10.5,
              height: 1.35,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
