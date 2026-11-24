import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/list_cards.dart';
import '../../../models/announcement_model.dart';
import '../../../models/document_model.dart';
import '../../../models/notification_model.dart';
import '../../../models/report_model.dart';
import '../../../providers/app_scope.dart';
import '../../../providers/app_state.dart';
import '../announcements/announcement_detail_screen.dart';
import '../documents/document_detail_screen.dart';
import '../reports/report_detail_screen.dart';

/// Notification history. Opening a notification marks it read and routes the
/// resident to the record it refers to.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  Future<void> _open(BuildContext context, NotificationModel notification) async {
    final AppState state = AppScope.read(context);
    await state.markNotificationRead(notification);
    if (!context.mounted) return;

    switch (notification.type) {
      case NotificationType.reportUpdate:
        final ReportModel? report = state.reportById(notification.relatedRecordId);
        if (report != null) {
          await Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ReportDetailScreen(reportId: report.id),
            ),
          );
          return;
        }
        break;
      case NotificationType.documentUpdate:
        final DocumentRequestModel? request =
            state.documentRequestById(notification.relatedRecordId);
        if (request != null) {
          await Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => DocumentDetailScreen(requestId: request.id),
            ),
          );
          return;
        }
        break;
      case NotificationType.announcement:
        final AnnouncementModel? announcement =
            state.announcementById(notification.relatedRecordId);
        if (announcement != null) {
          await Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) =>
                  AnnouncementDetailScreen(announcementId: announcement.id),
            ),
          );
          return;
        }
        break;
      case NotificationType.emergency:
      case NotificationType.general:
        break;
    }

    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        contentPadding: const EdgeInsets.all(22),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              notification.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              notification.message,
              style: const TextStyle(
                fontSize: 13,
                height: 1.55,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              Formatters.dateTime(notification.createdAt),
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppState state = AppScope.of(context);
    final List<NotificationModel> items = state.notificationList;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.chevron_left_rounded, size: 28),
        ),
        actions: <Widget>[
          if (items.any((NotificationModel n) => !n.isRead))
            TextButton(
              onPressed: state.markAllNotificationsRead,
              child: const Text(
                'Mark all read',
                style: TextStyle(fontSize: 11.5),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        child: items.isEmpty
            ? const EmptyState(
                icon: Icons.notifications_none_rounded,
                title: 'No notifications yet',
                message:
                    'Updates about your reports, document requests and barangay '
                    'announcements will appear here.',
              )
            : RefreshIndicator(
                color: AppColors.primary,
                onRefresh: state.refresh,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
                  itemCount: items.length,
                  itemBuilder: (BuildContext context, int index) {
                    final NotificationModel notification = items[index];
                    return NotificationTile(
                      notification: notification,
                      onTap: () => _open(context, notification),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
