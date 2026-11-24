import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_card.dart';
import '../../../models/document_model.dart';
import '../../../providers/app_scope.dart';
import 'document_request_form_screen.dart';
import 'my_documents_screen.dart';

/// Administrator-managed document types a resident can request.
class DocumentTypesScreen extends StatelessWidget {
  const DocumentTypesScreen({super.key});

  static IconData _iconFor(String type) {
    switch (type) {
      case 'Barangay Clearance':
        return Icons.verified_outlined;
      case 'Barangay Certificate':
        return Icons.workspace_premium_outlined;
      case 'Certificate of Indigency':
        return Icons.volunteer_activism_outlined;
      case 'Certificate of Residency':
        return Icons.home_outlined;
      case 'Business Clearance':
        return Icons.storefront_outlined;
      default:
        return Icons.description_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final int activeRequests = AppScope.of(context)
        .documentRequestList
        .where((DocumentRequestModel d) =>
            d.status != DocumentStatus.completed &&
            d.status != DocumentStatus.rejected)
        .length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Request Documents'),
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
            const ScreenHeading(
              title: 'What do you need?',
              subtitle:
                  'Choose a document to request. The barangay office will review '
                  'your request and update its status here.',
            ),
            const SizedBox(height: 18),
            AppCard(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const MyDocumentsScreen(),
                ),
              ),
              color: AppColors.primarySoft,
              showShadow: false,
              padding: const EdgeInsets.all(15),
              child: Row(
                children: <Widget>[
                  IconTile(
                    icon: Icons.folder_shared_outlined,
                    background: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          'My document requests',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          activeRequests == 0
                              ? 'No active requests'
                              : '$activeRequests active request${activeRequests == 1 ? '' : 's'}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColors.primaryDark),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const SectionHeader(title: 'Available documents'),
            ...AppConstants.documentTypes.map(
              (String type) => AppCard(
                margin: const EdgeInsets.only(bottom: 12),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => DocumentRequestFormScreen(documentType: type),
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    IconTile(icon: _iconFor(type)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            type,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Requires 1–2 working days for review',
                            style: TextStyle(
                              fontSize: 10.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded,
                        color: AppColors.textHint),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Processing times are samples. The barangay office confirms the '
              'final schedule and requirements for every request.',
              style: TextStyle(
                fontSize: 10.5,
                height: 1.5,
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
