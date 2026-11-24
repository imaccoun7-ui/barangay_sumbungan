import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/list_cards.dart';
import '../../../core/widgets/segmented_tabs.dart';
import '../../../models/document_model.dart';
import '../../../providers/app_scope.dart';
import '../../../providers/app_state.dart';
import 'document_detail_screen.dart';
import 'document_types_screen.dart';

class MyDocumentsScreen extends StatefulWidget {
  const MyDocumentsScreen({super.key});

  @override
  State<MyDocumentsScreen> createState() => _MyDocumentsScreenState();
}

class _MyDocumentsScreenState extends State<MyDocumentsScreen> {
  int _filter = 0;

  List<DocumentRequestModel> _visible(List<DocumentRequestModel> items) {
    switch (_filter) {
      case 1:
        return items
            .where((DocumentRequestModel d) =>
                d.status == DocumentStatus.pending ||
                d.status == DocumentStatus.processing)
            .toList();
      case 2:
        return items
            .where((DocumentRequestModel d) =>
                d.status == DocumentStatus.readyForPickup)
            .toList();
      case 3:
        return items
            .where((DocumentRequestModel d) =>
                d.status == DocumentStatus.completed ||
                d.status == DocumentStatus.rejected)
            .toList();
      default:
        return items;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppState state = AppScope.of(context);
    final List<DocumentRequestModel> visible =
        _visible(state.documentRequestList);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Document Requests'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.chevron_left_rounded, size: 28),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const DocumentTypesScreen(),
              ),
            ),
            icon: const Icon(Icons.add_rounded, size: 26),
            tooltip: 'New request',
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: SegmentedTabs(
                labels: const <String>[
                  'All',
                  'In review',
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
                  ? EmptyState(
                      icon: Icons.description_outlined,
                      title: 'No document requests',
                      message: 'Request a barangay clearance or certificate and '
                          'track its status here.',
                      actionLabel: 'Request a document',
                      onAction: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const DocumentTypesScreen(),
                        ),
                      ),
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
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => DocumentDetailScreen(
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
