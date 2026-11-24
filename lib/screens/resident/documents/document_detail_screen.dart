import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../models/document_model.dart';
import '../../../providers/app_scope.dart';

class DocumentDetailScreen extends StatelessWidget {
  const DocumentDetailScreen({super.key, required this.requestId});

  final String requestId;

  @override
  Widget build(BuildContext context) {
    final DocumentRequestModel? request =
        AppScope.of(context).documentRequestById(requestId);
    if (request == null) {
      return const Scaffold(
        body: EmptyState(
          icon: Icons.search_off_rounded,
          title: 'Request not found',
          message:
              'This document request is no longer available. Please refresh your list.',
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Request Details'),
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
                fontSize: 23,
                fontWeight: FontWeight.w700,
                height: 1.3,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
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
                    value: Formatters.dateTime(request.createdAt),
                  ),
                  LabeledValue(
                    label: 'Last update',
                    value: Formatters.dateTime(request.updatedAt),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              color: request.adminResponse.isEmpty
                  ? AppColors.surfaceMuted
                  : AppColors.primarySoft,
              showShadow: request.adminResponse.isNotEmpty,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Icon(Icons.support_agent_rounded,
                          size: 17, color: AppColors.primaryDark),
                      const SizedBox(width: 7),
                      const Text(
                        'Barangay response',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    request.adminResponse.isEmpty
                        ? 'Your request is waiting for review by the barangay '
                            'office. You will be notified when instructions are '
                            'added.'
                        : request.adminResponse,
                    style: const TextStyle(
                      fontSize: 12.5,
                      height: 1.6,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.accentYellowSoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(Icons.info_outline_rounded,
                      size: 16, color: AppColors.accentYellow),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '"Ready for Pickup" means the barangay has prepared your '
                      'document for verification at the office. Bring a valid ID. '
                      'This app does not issue signed documents.',
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.55,
                        color: AppColors.textSecondary,
                      ),
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
