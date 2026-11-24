import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/launchers.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_dialogs.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/list_cards.dart';
import '../../../models/directory_model.dart';
import '../../../providers/app_scope.dart';

/// Official Directory: officials and offices with one-tap calling.
class DirectoryScreen extends StatefulWidget {
  const DirectoryScreen({super.key});

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> {
  String _query = '';

  Future<void> _call(DirectoryEntryModel entry) async {
    final bool launched = await Launchers.call(entry.contactNumber);
    if (!mounted) return;
    if (!launched) {
      AppDialogs.toast(
        context,
        'No phone app is available on this device. Dial ${entry.contactNumber} manually.',
        error: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<DirectoryEntryModel> entries = AppScope.of(context)
        .directoryList
        .where((DirectoryEntryModel e) => e.isActive)
        .toList();
    final String query = _query.trim().toLowerCase();
    final List<DirectoryEntryModel> visible = query.isEmpty
        ? entries
        : entries
            .where((DirectoryEntryModel e) =>
                e.name.toLowerCase().contains(query) ||
                e.position.toLowerCase().contains(query) ||
                e.office.toLowerCase().contains(query))
            .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Official Directory'),
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
              title: 'Barangay Officials',
              subtitle:
                  'Official contact details of barangay officials and offices.',
            ),
            const SizedBox(height: 16),
            AppTextField(
              hint: 'Search by name, position or office',
              prefixIcon: Icons.search_rounded,
              onChanged: (String value) => setState(() => _query = value),
            ),
            const SizedBox(height: 16),
            if (visible.isEmpty)
              const EmptyState(
                icon: Icons.contact_page_outlined,
                title: 'No matching entries',
                message:
                    'The barangay has not published a matching official or office yet.',
              )
            else
              ...visible.map(
                (DirectoryEntryModel entry) => DirectoryEntryCard(
                  entry: entry,
                  onCall: () => _call(entry),
                ),
              ),
            const SizedBox(height: 6),
            const Text(
              AppConstants.sampleDataNotice,
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
