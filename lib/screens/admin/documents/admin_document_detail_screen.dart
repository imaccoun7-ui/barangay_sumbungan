import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_dialogs.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../models/document_model.dart';
import '../../../providers/app_scope.dart';
import '../../../providers/app_state.dart';
import '../../../services/backend/barangay_backend.dart';

class AdminDocumentDetailScreen extends StatefulWidget {
  const AdminDocumentDetailScreen({super.key, required this.requestId});

  final String requestId;

  @override
  State<AdminDocumentDetailScreen> createState() =>
      _AdminDocumentDetailScreenState();
}

class _AdminDocumentDetailScreenState extends State<AdminDocumentDetailScreen> {
  final TextEditingController _response = TextEditingController();
  DocumentStatus? _status;
  bool _saving = false;
  bool _initialised = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialised) return;
    final DocumentRequestModel? request =
        AppScope.read(context).documentRequestById(widget.requestId);
    if (request != null) {
      _status = request.status;
      _response.text = request.adminResponse;
    }
    _initialised = true;
  }

  @override
  void dispose() {
    _response.dispose();
    super.dispose();
  }

  Future<void> _save(DocumentRequestModel request) async {
    if (_status == null) return;
    setState(() => _saving = true);
    final AppState state = AppScope.read(context);
    try {
      await state.updateDocumentStatus(
        request: request,
        status: _status!,
        adminResponse: _response.text,
      );
      if (!mounted) return;
      AppDialogs.toast(
        context,
        'Request marked ${_status!.label}. The resident has been notified.',
      );
      Navigator.of(context).pop();
    } on BackendException catch (error) {
      if (!mounted) return;
      AppDialogs.toast(context, error.message, error: true);
    } catch (_) {
      if (!mounted) return;
      AppDialogs.toast(context, 'Could not update the request. Try again.',
          error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final DocumentRequestModel? request =
        AppScope.of(context).documentRequestById(widget.requestId);
    if (request == null) {
      return const Scaffold(
        body: EmptyState(
          icon: Icons.search_off_rounded,
          title: 'Request not found',
          message: 'This document request is no longer available.',
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Process Request'),
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
                  label: request.status.label,
                  foreground: request.status.foreground,
                  background: request.status.background,
                ),
                const Spacer(),
                Text(
                  request.referenceNumber,
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
              request.documentType,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                height: 1.3,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 14),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  LabeledValue(label: 'Resident', value: request.residentName),
                  LabeledValue(label: 'Full name', value: request.fullName),
                  LabeledValue(label: 'Address', value: request.address),
                  LabeledValue(
                      label: 'Contact number', value: request.contactNumber),
                  LabeledValue(label: 'Purpose', value: request.purpose),
                  if (request.additionalInformation.isNotEmpty)
                    LabeledValue(
                      label: 'Additional information',
                      value: request.additionalInformation,
                    ),
                  LabeledValue(
                      label: 'Submitted',
                      value: Formatters.dateTime(request.createdAt)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const SectionHeader(title: 'Update status'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: DocumentStatus.values.map((DocumentStatus status) {
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
            const SectionHeader(title: 'Response or instructions'),
            TextField(
              controller: _response,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText:
                    'e.g. Please bring a valid ID and claim the document at '
                    'Window 2.',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'The resident is notified with this message. Marking a request '
              '"Completed" does not sign the document — release it at the '
              'barangay office after verification.',
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
              onPressed: () => _save(request),
            ),
          ],
        ),
      ),
    );
  }
}
