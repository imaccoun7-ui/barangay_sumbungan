import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_dialogs.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../models/report_model.dart';
import '../../../providers/app_scope.dart';
import '../../../providers/app_state.dart';
import '../../../services/backend/barangay_backend.dart';

class AdminReportDetailScreen extends StatefulWidget {
  const AdminReportDetailScreen({super.key, required this.reportId});

  final String reportId;

  @override
  State<AdminReportDetailScreen> createState() =>
      _AdminReportDetailScreenState();
}

class _AdminReportDetailScreenState extends State<AdminReportDetailScreen> {
  final TextEditingController _response = TextEditingController();
  ReportStatus? _status;
  bool _saving = false;
  bool _initialised = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialised) return;
    final ReportModel? report =
        AppScope.read(context).reportById(widget.reportId);
    if (report != null) {
      _status = report.status;
      _response.text = report.adminResponse;
    }
    _initialised = true;
  }

  @override
  void dispose() {
    _response.dispose();
    super.dispose();
  }

  Future<void> _save(ReportModel report) async {
    if (_status == null) return;
    setState(() => _saving = true);
    final AppState state = AppScope.read(context);
    try {
      await state.updateReportStatus(
        report: report,
        status: _status!,
        adminResponse: _response.text,
      );
      if (!mounted) return;
      AppDialogs.toast(
        context,
        'Report updated to ${_status!.label}. The resident has been notified.',
      );
      Navigator.of(context).pop();
    } on BackendException catch (error) {
      if (!mounted) return;
      AppDialogs.toast(context, error.message, error: true);
    } catch (_) {
      if (!mounted) return;
      AppDialogs.toast(context, 'Could not update the report. Try again.',
          error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ReportModel? report =
        AppScope.of(context).reportById(widget.reportId);
    if (report == null) {
      return const Scaffold(
        body: EmptyState(
          icon: Icons.search_off_rounded,
          title: 'Report not found',
          message: 'This report is no longer available.',
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Review Report'),
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
                fontSize: 22,
                fontWeight: FontWeight.w700,
                height: 1.3,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 14),
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _Line(label: 'Submitted by', value: report.residentName),
                  _Line(label: 'Category', value: report.category),
                  _Line(
                      label: 'Location',
                      value: report.location.isEmpty ? '—' : report.location),
                  _Line(
                      label: 'Submitted',
                      value: Formatters.dateTime(report.createdAt)),
                  _Line(
                      label: 'Last update',
                      value: Formatters.dateTime(report.updatedAt)),
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
                    'DESCRIPTION',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textHint,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    report.description,
                    style: const TextStyle(
                      fontSize: 13,
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
                      'EVIDENCE PHOTOS',
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textHint,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: report.imageUrls
                          .map(
                            (String path) => ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: AppImage(
                                reference: path,
                                height: 90,
                                width: 90,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            const SectionHeader(title: 'Update status'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ReportStatus.values.map((ReportStatus status) {
                final bool active = _status == status;
                return GestureDetector(
                  onTap: () => setState(() => _status = status),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: active ? status.background : AppColors.surface,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: active ? status.foreground : AppColors.divider,
                        width: active ? 1.4 : 1,
                      ),
                    ),
                    child: Text(
                      status.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: active
                            ? status.foreground
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const SectionHeader(title: 'Barangay response'),
            TextField(
              controller: _response,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText:
                    'Explain the action taken or the next steps for the resident…',
                fillColor: AppColors.surface,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'The resident receives a notification with this response when the '
              'status is saved.',
              style: TextStyle(
                fontSize: 10.5,
                height: 1.5,
                color: AppColors.textHint,
              ),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Save update & notify resident',
              loading: _saving,
              onPressed: () => _save(report),
            ),
          ],
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 104,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textHint,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                height: 1.4,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
