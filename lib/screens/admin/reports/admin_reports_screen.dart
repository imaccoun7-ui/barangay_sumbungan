import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/list_cards.dart';
import '../../../core/widgets/segmented_tabs.dart';
import '../../../models/report_model.dart';
import '../../../providers/app_scope.dart';
import '../../../providers/app_state.dart';
import 'admin_report_detail_screen.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  String _query = '';
  int _filter = 0;

  List<ReportModel> _visible(List<ReportModel> reports) {
    final String query = _query.trim().toLowerCase();
    return reports.where((ReportModel report) {
      final bool matchesFilter = switch (_filter) {
        1 => report.status == ReportStatus.pending,
        2 => report.status == ReportStatus.inProgress,
        3 => report.status == ReportStatus.solved,
        _ => true,
      };
      final bool matchesQuery = query.isEmpty ||
          report.title.toLowerCase().contains(query) ||
          report.referenceNumber.toLowerCase().contains(query) ||
          report.residentName.toLowerCase().contains(query) ||
          report.category.toLowerCase().contains(query);
      return matchesFilter && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final AppState state = AppScope.of(context);
    final List<ReportModel> visible = _visible(state.reportList);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 18, 20, 12),
              child: ScreenHeading(
                title: 'Reports Management',
                subtitle: 'Review resident concerns and update their status.',
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AppTextField(
                hint: 'Search title, reference or resident',
                prefixIcon: Icons.search_rounded,
                onChanged: (String value) => setState(() => _query = value),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SegmentedTabs(
                labels: const <String>[
                  'All',
                  'Pending',
                  'In progress',
                  'Solved',
                ],
                selectedIndex: _filter,
                onSelected: (int index) => setState(() => _filter = index),
                scrollable: true,
              ),
            ),
            Expanded(
              child: visible.isEmpty
                  ? const EmptyState(
                      icon: Icons.assignment_outlined,
                      title: 'No reports found',
                      message:
                          'No reports match the current search or filter.',
                    )
                  : RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: state.refresh,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                        itemCount: visible.length,
                        itemBuilder: (BuildContext context, int index) {
                          final ReportModel report = visible[index];
                          return ReportListCard(
                            report: report,
                            showResident: true,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    AdminReportDetailScreen(reportId: report.id),
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
