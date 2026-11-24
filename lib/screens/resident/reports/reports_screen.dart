import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/list_cards.dart';
import '../../../core/widgets/segmented_tabs.dart';
import '../../../models/report_model.dart';
import '../../../providers/app_scope.dart';
import '../../../providers/app_state.dart';
import 'report_detail_screen.dart';
import 'submit_report_screen.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int _filter = 0;

  List<ReportModel> _visible(List<ReportModel> reports) {
    switch (_filter) {
      case 1:
        return reports
            .where((ReportModel r) => r.status != ReportStatus.solved)
            .toList();
      case 2:
        return reports
            .where((ReportModel r) => r.status == ReportStatus.solved)
            .toList();
      default:
        return reports;
    }
  }

  Future<void> _openSubmit() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const SubmitReportScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppState state = AppScope.of(context);
    final List<ReportModel> reports = state.reportList;
    final List<ReportModel> visible = _visible(reports);

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: _openSubmit,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        child: const Icon(Icons.add_rounded, size: 26),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 18, 20, 14),
              child: Center(
                child: Text(
                  'My Reports',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SegmentedTabs(
                labels: const <String>['All', 'In Progress', 'Resolved'],
                selectedIndex: _filter,
                onSelected: (int index) => setState(() => _filter = index),
              ),
            ),
            const SizedBox(height: 14),
            _StatsStrip(
              total: reports.length,
              active: reports
                  .where((ReportModel r) => r.status != ReportStatus.solved)
                  .length,
              resolved: reports
                  .where((ReportModel r) => r.status == ReportStatus.solved)
                  .length,
            ),
            Expanded(
              child: visible.isEmpty
                  ? EmptyState(
                      icon: Icons.assignment_outlined,
                      title: 'No reports here yet',
                      message: _filter == 0
                          ? 'Submit a community concern and follow its progress '
                              'right from this screen.'
                          : 'No reports match this filter right now.',
                      actionLabel: _filter == 0 ? 'Submit a report' : null,
                      onAction: _filter == 0 ? _openSubmit : null,
                    )
                  : RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: state.refresh,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                        itemCount: visible.length,
                        itemBuilder: (BuildContext context, int index) {
                          final ReportModel report = visible[index];
                          return ReportListCard(
                            report: report,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    ReportDetailScreen(reportId: report.id),
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

class _StatsStrip extends StatelessWidget {
  const _StatsStrip({
    required this.total,
    required this.active,
    required this.resolved,
  });

  final int total;
  final int active;
  final int resolved;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: <Widget>[
          _Stat(value: '$total', label: 'Total reports'),
          _divider(),
          _Stat(value: '$active', label: 'Active'),
          _divider(),
          _Stat(value: '$resolved', label: 'Resolved'),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        height: 34,
        width: 1,
        color: Colors.white.withOpacity(0.22),
      );
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

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
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
