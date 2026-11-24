import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/list_cards.dart';
import '../../../core/widgets/segmented_tabs.dart';
import '../../../models/document_model.dart';
import '../../../providers/app_scope.dart';
import '../../../providers/app_state.dart';
import 'admin_document_detail_screen.dart';

class AdminDocumentsScreen extends StatefulWidget {
  const AdminDocumentsScreen({super.key});

  @override
  State<AdminDocumentsScreen> createState() => _AdminDocumentsScreenState();
}

class _AdminDocumentsScreenState extends State<AdminDocumentsScreen> {
  String _query = '';
  int _filter = 0;

  List<DocumentRequestModel> _visible(List<DocumentRequestModel> items) {
    final String query = _query.trim().toLowerCase();
    return items.where((DocumentRequestModel request) {
      final bool matchesFilter = switch (_filter) {
        1 => request.status == DocumentStatus.pending,
        2 => request.status == DocumentStatus.processing,
        3 => request.status == DocumentStatus.readyForPickup,
        4 => request.status == DocumentStatus.completed ||
            request.status == DocumentStatus.rejected,
        _ => true,
      };
      final bool matchesQuery = query.isEmpty ||
          request.documentType.toLowerCase().contains(query) ||
          request.referenceNumber.toLowerCase().contains(query) ||
          request.fullName.toLowerCase().contains(query);
      return matchesFilter && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final AppState state = AppScope.of(context);
    final List<DocumentRequestModel> visible =
        _visible(state.documentRequestList);

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
                title: 'Document Requests',
                subtitle:
                    'Process clearance and certificate requests from residents.',
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AppTextField(
                hint: 'Search reference, document or resident',
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
                  'Processing',
                  'For pickup',
                  'Closed',
                ],
                selectedIndex: _filter,
                onSelected: (int index) => setState(() => _filter = index),
                scrollable: true,
              ),
            ),
            Expanded(
              child: visible.isEmpty
                  ? const EmptyState(
                      icon: Icons.description_outlined,
                      title: 'No requests found',
                      message:
                          'No document requests match the current search or filter.',
                    )
                  : RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: state.refresh,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                        itemCount: visible.length,
                        itemBuilder: (BuildContext context, int index) {
                          final DocumentRequestModel request = visible[index];
                          return DocumentRequestCard(
                            request: request,
                            showResident: true,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => AdminDocumentDetailScreen(
                                  requestId: request.id,
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
