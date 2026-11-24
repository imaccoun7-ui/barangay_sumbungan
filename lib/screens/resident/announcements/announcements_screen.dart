import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/list_cards.dart';
import '../../../core/widgets/segmented_tabs.dart';
import '../../../models/announcement_model.dart';
import '../../../providers/app_scope.dart';
import '../../../providers/app_state.dart';
import 'announcement_detail_screen.dart';

/// Announcement feed with category filters, matching the Fidelity V1
/// "Announcements" tab.
class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key, required this.onNavigateTab});

  final ValueChanged<int> onNavigateTab;

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  int _filter = 0;

  @override
  Widget build(BuildContext context) {
    final AppState state = AppScope.of(context);
    final List<AnnouncementModel> all = state.publishedAnnouncements;
    final String? category = _filter == 0 ? null : AppConstants.announcementCategories[_filter - 1];
    final List<AnnouncementModel> visible = category == null
        ? all
        : all.where((AnnouncementModel a) => a.category == category).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: const ScreenHeading(
                title: 'Announcements',
                subtitle: 'Official updates from your barangay',
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SegmentedTabs(
                labels: const <String>['All', ...AppConstants.announcementCategories],
                selectedIndex: _filter,
                onSelected: (int index) => setState(() => _filter = index),
                scrollable: true,
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: state.refresh,
                child: visible.isEmpty
                    ? ListView(
                        children: const <Widget>[
                          SizedBox(height: 40),
                          EmptyState(
                            icon: Icons.campaign_outlined,
                            title: 'Nothing here yet',
                            message:
                                'Announcements published by the barangay will appear here.',
                          ),
                        ],
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                        itemCount: visible.length,
                        itemBuilder: (BuildContext context, int index) {
                          final AnnouncementModel announcement = visible[index];
                          return AnnouncementCard(
                            announcement: announcement,
                            hero: index == 0 && _filter == 0,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => AnnouncementDetailScreen(
                                  announcementId: announcement.id,
                                ),
                              ),
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

