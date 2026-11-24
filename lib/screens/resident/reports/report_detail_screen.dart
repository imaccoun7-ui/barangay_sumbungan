import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../models/report_model.dart';
import '../../../providers/app_scope.dart';

class ReportDetailScreen extends StatelessWidget {
  const ReportDetailScreen({super.key, required this.reportId});

  final String reportId;

  @override
  Widget build(BuildContext context) {
    final ReportModel? report = AppScope.of(context).reportById(reportId);
    if (report == null) {
      return const Scaffold(
        body: EmptyState(
          icon: Icons.search_off_rounded,
          title: 'Report not found',
          message:
              'This report is no longer available. Please refresh My Reports.',
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Report Details'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.chevron_left_rounded, size: 28),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 30),
          children: <Widget>[
            Row(
              children: <Widget>[
                StatusBadge(
                  label: report.status.label,
                  foreground: report.status.foreground,
                  background: report.status.background,
                ),
                const Spacer(),
                Text(
                  report.referenceNumber,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              report.title,
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w700,
                height: 1.3,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _IconLine(
                    icon: Icons.location_on_outlined,
                    label: 'Location',
                    value: report.location.isEmpty ? '—' : report.location,
                  ),
                  const SizedBox(height: 12),
                  _IconLine(
                    icon: Icons.event_outlined,
                    label: 'Submitted',
                    value: Formatters.dateTime(report.createdAt),
                  ),
                  const SizedBox(height: 12),
                  _IconLine(
                    icon: Icons.category_outlined,
                    label: 'Category',
                    value: report.category,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textHint,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    report.description,
                    style: const TextStyle(
                      fontSize: 13.5,
                      height: 1.6,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            if (report.imageUrls.isNotEmpty) ...<Widget>[
              const SizedBox(height: 14),
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Attached photos',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textHint,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: report.imageUrls
                          .map((String path) => ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: AppImage(
                                  reference: path,
                                  height: 84,
                                  width: 84,
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            const SectionHeader(
                title: 'Resolution progress',
                padding: EdgeInsets.only(bottom: 10)),
            AppCard(
              padding: const EdgeInsets.all(16),
              child: _Timeline(report: report),
            ),
            const SizedBox(height: 16),
            AppCard(
              color: report.adminResponse.isEmpty
                  ? AppColors.surfaceMuted
                  : AppColors.primarySoft,
              showShadow: report.adminResponse.isNotEmpty,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.support_agent_rounded,
                        size: 17,
                        color: report.adminResponse.isEmpty
                            ? AppColors.textSecondary
                            : AppColors.primaryDark,
                      ),
                      const SizedBox(width: 7),
                      const Expanded(
                        child: Text(
                          'Official barangay remarks',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    report.adminResponse.isEmpty
                        ? 'No remarks yet. The barangay desk has not responded to '
                            'this report. You will receive a notification when the '
                            'status changes.'
                        : report.adminResponse,
                    style: const TextStyle(
                      fontSize: 12.5,
                      height: 1.6,
                      color: AppColors.textSecondary,
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

class _IconLine extends StatelessWidget {
  const _IconLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, size: 16, color: AppColors.textHint),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  fontSize: 9.5,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textHint,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.report});

  final ReportModel report;

  @override
  Widget build(BuildContext context) {
    final bool inProgress = report.status != ReportStatus.pending;
    final bool solved = report.status == ReportStatus.solved;
    final List<_Step> steps = <_Step>[
      _Step(
        title: 'Submitted & received',
        subtitle: Formatters.dateTime(report.createdAt),
        done: true,
      ),
      _Step(
        title: 'Reviewed by Barangay Desk',
        subtitle: inProgress ? 'Report accepted for action' : 'Awaiting review',
        done: inProgress,
      ),
      _Step(
        title: 'Assigned to action team',
        subtitle:
            inProgress ? 'Concern is being worked on' : 'Pending assignment',
        done: inProgress,
      ),
      _Step(
        title: 'Resolved & case closed',
        subtitle: solved
            ? Formatters.dateTime(report.updatedAt)
            : 'Awaiting completion',
        done: solved,
      ),
    ];

    return Column(
      children: List<Widget>.generate(steps.length, (int index) {
        final _Step step = steps[index];
        final bool last = index == steps.length - 1;
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(
                width: 26,
                child: Column(
                  children: <Widget>[
                    Container(
                      height: 20,
                      width: 20,
                      decoration: BoxDecoration(
                        color: step.done
                            ? AppColors.primary
                            : AppColors.surfaceMuted,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              step.done ? AppColors.primary : AppColors.divider,
                          width: 1.4,
                        ),
                      ),
                      child: step.done
                          ? const Icon(Icons.check_rounded,
                              size: 13, color: Colors.white)
                          : null,
                    ),
                    if (!last)
                      Expanded(
                        child: Container(
                          width: 2,
                          margin: const EdgeInsets.symmetric(vertical: 3),
                          color: step.done
                              ? AppColors.primarySoftAlt
                              : AppColors.surfaceMuted,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: last ? 0 : 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        step.title,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight:
                              step.done ? FontWeight.w600 : FontWeight.w500,
                          color: step.done
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        step.subtitle,
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _Step {
  const _Step({
    required this.title,
    required this.subtitle,
    required this.done,
  });

  final String title;
  final String subtitle;
  final bool done;
}
