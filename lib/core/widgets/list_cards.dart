import 'package:flutter/material.dart';

import '../../models/announcement_model.dart';
import '../../models/directory_model.dart';
import '../../models/document_model.dart';
import '../../models/notification_model.dart';
import '../../models/report_model.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';
import 'app_card.dart';
import 'status_badge.dart';

class ReportListCard extends StatelessWidget {
  const ReportListCard({
    super.key,
    required this.report,
    required this.onTap,
    this.showResident = false,
  });

  final ReportModel report;
  final VoidCallback onTap;
  final bool showResident;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              IconTile(
                icon: Icons.warning_amber_rounded,
                background: report.status.background,
                foreground: report.status.foreground,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      report.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      report.referenceNumber,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.2,
                      ),
                    ),
                    if (showResident) ...<Widget>[
                      const SizedBox(height: 3),
                      Text(
                        report.residentName,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge(
                label: report.status.label,
                foreground: report.status.foreground,
                background: report.status.background,
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),
          _MetaRow(
            icon: Icons.calendar_today_outlined,
            text: Formatters.date(report.createdAt),
          ),
          const SizedBox(height: 5),
          _MetaRow(
            icon: Icons.location_on_outlined,
            text: report.location.isEmpty ? 'No location provided' : report.location,
          ),
        ],
      ),
    );
  }
}

class DocumentRequestCard extends StatelessWidget {
  const DocumentRequestCard({
    super.key,
    required this.request,
    required this.onTap,
    this.showResident = false,
  });

  final DocumentRequestModel request;
  final VoidCallback onTap;
  final bool showResident;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              IconTile(
                icon: Icons.description_outlined,
                background: request.status.background,
                foreground: request.status.foreground,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      request.documentType,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      request.referenceNumber,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (showResident) ...<Widget>[
                      const SizedBox(height: 3),
                      Text(
                        request.residentName,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge(
                label: request.status.label,
                foreground: request.status.foreground,
                background: request.status.background,
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),
          _MetaRow(
            icon: Icons.calendar_today_outlined,
            text: Formatters.date(request.createdAt),
          ),
          const SizedBox(height: 5),
          _MetaRow(
            icon: Icons.info_outline_rounded,
            text: request.purpose,
          ),
        ],
      ),
    );
  }
}

class AnnouncementCard extends StatelessWidget {
  const AnnouncementCard({
    super.key,
    required this.announcement,
    required this.onTap,
    this.hero = false,
  });

  final AnnouncementModel announcement;
  final VoidCallback onTap;
  final bool hero;

  Color get _categoryColor {
    switch (announcement.category) {
      case 'Health':
        return AppColors.primary;
      case 'Infrastructure':
        return const Color(0xFF3B6FB6);
      case 'Disaster Alert':
        return AppColors.danger;
      default:
        return AppColors.primaryDark;
    }
  }

  Color get _categoryBackground {
    switch (announcement.category) {
      case 'Health':
        return AppColors.primarySoft;
      case 'Infrastructure':
        return const Color(0xFFE4EDF9);
      case 'Disaster Alert':
        return AppColors.dangerSoft;
      default:
        return AppColors.primarySoft;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _categoryBackground,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                announcement.category,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: _categoryColor,
                ),
              ),
            ),
            const Spacer(),
            Text(
              Formatters.relative(announcement.createdAt),
              style: const TextStyle(
                fontSize: 10.5,
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          announcement.title,
          maxLines: hero ? 2 : 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: hero ? 16 : 14.5,
            fontWeight: FontWeight.w600,
            height: 1.35,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          announcement.content,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12,
            height: 1.5,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );

    return AppCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      child: body,
    );
  }
}

class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  final NotificationModel notification;
  final VoidCallback onTap;

  IconData get _icon {
    switch (notification.type) {
      case NotificationType.emergency:
        return Icons.emergency_outlined;
      case NotificationType.reportUpdate:
        return Icons.assignment_turned_in_outlined;
      case NotificationType.documentUpdate:
        return Icons.description_outlined;
      case NotificationType.announcement:
        return Icons.campaign_outlined;
      case NotificationType.general:
        return Icons.notifications_none_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool unread = !notification.isRead;
    return AppCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      color: unread ? AppColors.surface : AppColors.surfaceMuted,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          IconTile(
            icon: _icon,
            size: 40,
            background: unread ? AppColors.primarySoft : AppColors.surfaceMuted,
            foreground: unread ? AppColors.primaryDark : AppColors.textSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        notification.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: unread ? FontWeight.w600 : FontWeight.w500,
                          color: AppColors.textPrimary,
                          height: 1.35,
                        ),
                      ),
                    ),
                    if (unread)
                      Container(
                        margin: const EdgeInsets.only(left: 8, top: 4),
                        height: 7,
                        width: 7,
                        decoration: const BoxDecoration(
                          color: AppColors.danger,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification.message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    height: 1.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  Formatters.relative(notification.createdAt),
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
    );
  }
}

class DirectoryEntryCard extends StatelessWidget {
  const DirectoryEntryCard({
    super.key,
    required this.entry,
    required this.onCall,
    this.onEdit,
    this.onDelete,
  });

  final DirectoryEntryModel entry;
  final VoidCallback onCall;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              IconTile(icon: Icons.badge_outlined),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      entry.name,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      entry.position,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              const Icon(Icons.call_outlined,
                  size: 15, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                entry.contactNumber,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const Spacer(),
              if (onEdit != null)
                IconButton(
                  onPressed: onEdit,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  color: AppColors.textSecondary,
                ),
              if (onDelete != null)
                IconButton(
                  onPressed: onDelete,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  color: AppColors.danger,
                ),
              if (onEdit == null)
                TextButton(
                  onPressed: onCall,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    minimumSize: const Size(0, 32),
                  ),
                  child: const Text('Call'),
                ),
            ],
          ),
          if (entry.office.isNotEmpty) ...<Widget>[
            const SizedBox(height: 6),
            _MetaRow(icon: Icons.apartment_rounded, text: entry.office),
          ],
        ],
      ),
    );
  }
}

class EmergencyContactCard extends StatelessWidget {
  const EmergencyContactCard({
    super.key,
    required this.contact,
    required this.onCall,
    this.onEdit,
    this.onDelete,
  });

  final EmergencyContactModel contact;
  final VoidCallback onCall;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  contact.name,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (onEdit == null)
                SizedBox(
                  height: 38,
                  child: ElevatedButton(
                    onPressed: onCall,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(78, 38),
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                    child: const Text('Call',
                        style: TextStyle(fontSize: 12.5)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            contact.contactNumber,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: contact.category == 'Police' ||
                      contact.category == 'Fire' ||
                      contact.category == 'Medical'
                  ? AppColors.danger
                  : AppColors.dangerStrong,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            contact.availableHours,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textHint,
            ),
          ),
          if (onEdit != null || onDelete != null) ...<Widget>[
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                TextButton.icon(
                  onPressed: onCall,
                  icon: const Icon(Icons.call_outlined, size: 16),
                  label: const Text('Call'),
                ),
                const Spacer(),
                if (onEdit != null)
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    color: AppColors.textSecondary,
                  ),
                if (onDelete != null)
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                    color: AppColors.danger,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 14, color: AppColors.textHint),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11.5,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
