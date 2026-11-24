import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_dialogs.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../models/announcement_model.dart';
import '../../../providers/app_scope.dart';
import '../../../providers/app_state.dart';
import 'announcement_editor_screen.dart';

class AdminAnnouncementsScreen extends StatelessWidget {
  const AdminAnnouncementsScreen({super.key});

  Future<void> _delete(BuildContext context, AnnouncementModel announcement) async {
    final bool confirmed = await AppDialogs.confirm(
      context,
      title: 'Delete announcement?',
      message:
          '"${announcement.title}" will be removed for all residents. This cannot '
          'be undone.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;
    try {
      await AppScope.read(context).deleteAnnouncement(announcement);
      if (!context.mounted) return;
      AppDialogs.toast(context, 'Announcement deleted.');
    } catch (_) {
      if (!context.mounted) return;
      AppDialogs.toast(context, 'Could not delete the announcement.',
          error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppState state = AppScope.of(context);
    final List<AnnouncementModel> items = state.announcementList;

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const AnnouncementEditorScreen(),
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New', style: TextStyle(fontSize: 13)),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 18, 20, 16),
              child: ScreenHeading(
                title: 'Announcements',
                subtitle:
                    'Publish advisories, programs and disaster alerts for residents.',
              ),
            ),
            Expanded(
              child: items.isEmpty
                  ? const EmptyState(
                      icon: Icons.campaign_outlined,
                      title: 'No announcements yet',
                      message:
                          'Create your first announcement to keep residents informed.',
                    )
                  : RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: state.refresh,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                        itemCount: items.length,
                        itemBuilder: (BuildContext context, int index) {
                          final AnnouncementModel announcement = items[index];
                          return AppCard(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        announcement.title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w600,
                                          height: 1.35,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    Switch.adaptive(
                                      value: announcement.published,
                                      activeColor: AppColors.primary,
                                      onChanged: (_) async {
                                        try {
                                          await state
                                              .toggleAnnouncementPublished(
                                                  announcement);
                                        } catch (_) {
                                          if (!context.mounted) return;
                                          AppDialogs.toast(
                                            context,
                                            'Could not change the publish state.',
                                            error: true,
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${announcement.category} · ${Formatters.date(announcement.createdAt)} · ${announcement.published ? 'Published' : 'Draft'}',
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    color: AppColors.textHint,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  announcement.content,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    height: 1.5,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: <Widget>[
                                    TextButton.icon(
                                      onPressed: () => Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                          builder: (_) => AnnouncementEditorScreen(
                                            announcement: announcement,
                                          ),
                                        ),
                                      ),
                                      icon: const Icon(Icons.edit_outlined,
                                          size: 15),
                                      label: const Text('Edit',
                                          style: TextStyle(fontSize: 11.5)),
                                    ),
                                    TextButton.icon(
                                      onPressed: () =>
                                          _delete(context, announcement),
                                      icon: const Icon(Icons.delete_outline_rounded,
                                          size: 15),
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppColors.danger,
                                      ),
                                      label: const Text('Delete',
                                          style: TextStyle(fontSize: 11.5)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
