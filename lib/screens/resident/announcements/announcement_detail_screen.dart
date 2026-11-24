import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../models/announcement_model.dart';
import '../../../providers/app_scope.dart';

class AnnouncementDetailScreen extends StatelessWidget {
  const AnnouncementDetailScreen({super.key, required this.announcementId});

  final String announcementId;

  Color _color(String category) {
    switch (category) {
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

  Color _background(String category) {
    switch (category) {
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

  IconData _icon(String category) {
    switch (category) {
      case 'Health':
        return Icons.health_and_safety_outlined;
      case 'Infrastructure':
        return Icons.construction_outlined;
      case 'Disaster Alert':
        return Icons.thunderstorm_outlined;
      default:
        return Icons.campaign_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AnnouncementModel? announcement =
        AppScope.of(context).announcementById(announcementId);
    if (announcement == null) {
      return const Scaffold(
        body: EmptyState(
          icon: Icons.search_off_rounded,
          title: 'Announcement not found',
          message: 'This announcement may have been archived by the barangay.',
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Announcement'),
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
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: _background(announcement.category),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Center(
                child: Container(
                  height: 76,
                  width: 76,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _icon(announcement.category),
                    size: 36,
                    color: _color(announcement.category),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: <Widget>[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _background(announcement.category),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    announcement.category,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: _color(announcement.category),
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  Formatters.relative(announcement.createdAt),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              announcement.title,
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w700,
                height: 1.3,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 14),
            ...announcement.content.split('\n\n').map(
                  (String paragraph) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      paragraph,
                      style: const TextStyle(
                        fontSize: 13.5,
                        height: 1.7,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                const Icon(Icons.account_balance_outlined,
                    size: 15, color: AppColors.textHint),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    announcement.createdBy.isEmpty
                        ? 'Barangay Office'
                        : announcement.createdBy,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Text(
                  Formatters.fullDate(announcement.createdAt),
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
