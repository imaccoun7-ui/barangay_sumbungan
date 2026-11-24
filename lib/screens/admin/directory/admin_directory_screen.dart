import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_dialogs.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/list_cards.dart';
import '../../../core/widgets/segmented_tabs.dart';
import '../../../models/directory_model.dart';
import '../../../providers/app_scope.dart';
import '../../../providers/app_state.dart';

/// Administrator management for the official directory, emergency hotlines and
/// barangay map locations.
class AdminDirectoryScreen extends StatefulWidget {
  const AdminDirectoryScreen({super.key});

  @override
  State<AdminDirectoryScreen> createState() => _AdminDirectoryScreenState();
}

class _AdminDirectoryScreenState extends State<AdminDirectoryScreen> {
  int _tab = 0;

  Future<void> _editEntry(DirectoryEntryModel? existing) async {
    final _EntryFormResult? result = await showModalBottomSheet<_EntryFormResult>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _EntryForm(existing: existing),
    );
    if (result == null || !mounted) return;
    try {
      await AppScope.read(context).saveDirectoryEntry(
        DirectoryEntryModel(
          id: existing?.id ?? '',
          name: result.name,
          position: result.position,
          contactNumber: result.contactNumber,
          office: result.office,
          description: result.description,
          isActive: result.isActive,
          updatedAt: DateTime.now(),
        ),
      );
      if (!mounted) return;
      AppDialogs.toast(context, 'Directory entry saved.');
    } catch (_) {
      if (!mounted) return;
      AppDialogs.toast(context, 'Could not save the entry.', error: true);
    }
  }

  Future<void> _editContact(EmergencyContactModel? existing) async {
    final _ContactFormResult? result =
        await showModalBottomSheet<_ContactFormResult>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ContactForm(existing: existing),
    );
    if (result == null || !mounted) return;
    try {
      await AppScope.read(context).saveEmergencyContact(
        EmergencyContactModel(
          id: existing?.id ?? '',
          name: result.name,
          category: result.category,
          contactNumber: result.contactNumber,
          description: result.description,
          availableHours: result.availableHours,
          isActive: result.isActive,
        ),
      );
      if (!mounted) return;
      AppDialogs.toast(context, 'Hotline saved.');
    } catch (_) {
      if (!mounted) return;
      AppDialogs.toast(context, 'Could not save the hotline.', error: true);
    }
  }

  Future<void> _editLocation(BarangayLocationModel? existing) async {
    final _LocationFormResult? result =
        await showModalBottomSheet<_LocationFormResult>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _LocationForm(existing: existing),
    );
    if (result == null || !mounted) return;
    try {
      await AppScope.read(context).saveLocation(
        BarangayLocationModel(
          id: existing?.id ?? '',
          name: result.name,
          category: result.category,
          address: result.address,
          latitude: result.latitude,
          longitude: result.longitude,
          description: result.description,
          isActive: result.isActive,
        ),
      );
      if (!mounted) return;
      AppDialogs.toast(context, 'Location saved.');
    } catch (_) {
      if (!mounted) return;
      AppDialogs.toast(context, 'Could not save the location.', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppState state = AppScope.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Directory & Map'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.chevron_left_rounded, size: 28),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          switch (_tab) {
            case 0:
              _editEntry(null);
              break;
            case 1:
              _editContact(null);
              break;
            default:
              _editLocation(null);
          }
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: SegmentedTabs(
                labels: const <String>['Officials', 'Hotlines', 'Facilities'],
                selectedIndex: _tab,
                onSelected: (int index) => setState(() => _tab = index),
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _tab,
                children: <Widget>[
                  _DirectoryTab(state: state, onEdit: _editEntry),
                  _ContactsTab(state: state, onEdit: _editContact),
                  _LocationsTab(state: state, onEdit: _editLocation),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DirectoryTab extends StatelessWidget {
  const _DirectoryTab({required this.state, required this.onEdit});

  final AppState state;
  final ValueChanged<DirectoryEntryModel?> onEdit;

  @override
  Widget build(BuildContext context) {
    final List<DirectoryEntryModel> entries = state.directoryList;
    if (entries.isEmpty) {
      return const EmptyState(
        icon: Icons.contact_page_outlined,
        title: 'No directory entries',
        message: 'Add the barangay officials and offices residents can contact.',
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
      children: <Widget>[
        ...entries.map(
          (DirectoryEntryModel entry) => DirectoryEntryCard(
            entry: entry,
            onCall: () => AppDialogs.toast(
              context,
              'Calling is available from the resident directory.',
            ),
            onEdit: () => onEdit(entry),
            onDelete: () async {
              final bool confirmed = await AppDialogs.confirm(
                context,
                title: 'Remove entry?',
                message: '${entry.name} will be removed from the directory.',
                confirmLabel: 'Remove',
                destructive: true,
              );
              if (!confirmed || !context.mounted) return;
              await AppScope.read(context).deleteDirectoryEntry(entry);
            },
          ),
        ),
      ],
    );
  }
}

class _ContactsTab extends StatelessWidget {
  const _ContactsTab({required this.state, required this.onEdit});

  final AppState state;
  final ValueChanged<EmergencyContactModel?> onEdit;

  @override
  Widget build(BuildContext context) {
    final List<EmergencyContactModel> contacts = state.emergencyContacts;
    if (contacts.isEmpty) {
      return const EmptyState(
        icon: Icons.phone_disabled_outlined,
        title: 'No hotlines',
        message: 'Add the barangay and partner emergency hotlines.',
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
      children: <Widget>[
        ...contacts.map(
          (EmergencyContactModel contact) => EmergencyContactCard(
            contact: contact,
            onCall: () => AppDialogs.toast(
              context,
              'Calling is available from the resident emergency screen.',
            ),
            onEdit: () => onEdit(contact),
            onDelete: () async {
              final bool confirmed = await AppDialogs.confirm(
                context,
                title: 'Remove hotline?',
                message:
                    '${contact.name} will no longer be shown to residents.',
                confirmLabel: 'Remove',
                destructive: true,
              );
              if (!confirmed || !context.mounted) return;
              await AppScope.read(context).deleteEmergencyContact(contact);
            },
          ),
        ),
      ],
    );
  }
}

class _LocationsTab extends StatelessWidget {
  const _LocationsTab({required this.state, required this.onEdit});

  final AppState state;
  final ValueChanged<BarangayLocationModel?> onEdit;

  @override
  Widget build(BuildContext context) {
    final List<BarangayLocationModel> locations = state.locations;
    if (locations.isEmpty) {
      return const EmptyState(
        icon: Icons.map_outlined,
        title: 'No map locations',
        message:
            'Add barangay facilities with verified coordinates so residents can '
            'find them.',
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text(
            'Only add coordinates verified by the barangay. Locations without '
            'coordinates are still listed with directions by name.',
            style: TextStyle(
              fontSize: 10.5,
              height: 1.5,
              color: AppColors.textHint,
            ),
          ),
        ),
        ...locations.map(
          (BarangayLocationModel location) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              leading: IconTile(
                icon: Icons.place_outlined,
                size: 38,
                background: AppColors.primarySoft,
                foreground: AppColors.primaryDark,
              ),
              title: Text(
                location.name,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                '${location.category} · ${location.address}',
                maxLines: 2,
                style: const TextStyle(fontSize: 10.5),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  IconButton(
                    onPressed: () => onEdit(location),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    color: AppColors.textSecondary,
                  ),
                  IconButton(
                    onPressed: () async {
                      final bool confirmed = await AppDialogs.confirm(
                        context,
                        title: 'Remove location?',
                        message:
                            '${location.name} will no longer be shown on the map.',
                        confirmLabel: 'Remove',
                        destructive: true,
                      );
                      if (!confirmed || !context.mounted) return;
                      await AppScope.read(context).deleteLocation(location);
                    },
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                    color: AppColors.danger,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ----------------------------------------------------------------- forms

class _EntryFormResult {
  const _EntryFormResult(this.name, this.position, this.contactNumber,
      this.office, this.description, this.isActive);
  final String name;
  final String position;
  final String contactNumber;
  final String office;
  final String description;
  final bool isActive;
}

class _EntryForm extends StatefulWidget {
  const _EntryForm({this.existing});
  final DirectoryEntryModel? existing;

  @override
  State<_EntryForm> createState() => _EntryFormState();
}

class _EntryFormState extends State<_EntryForm> {
  late final TextEditingController _name =
      TextEditingController(text: widget.existing?.name ?? '');
  late final TextEditingController _position =
      TextEditingController(text: widget.existing?.position ?? '');
  late final TextEditingController _contact =
      TextEditingController(text: widget.existing?.contactNumber ?? '');
  late final TextEditingController _office =
      TextEditingController(text: widget.existing?.office ?? '');
  late final TextEditingController _description =
      TextEditingController(text: widget.existing?.description ?? '');
  late bool _active = widget.existing?.isActive ?? true;

  @override
  Widget build(BuildContext context) {
    return _SheetScaffold(
      title: widget.existing == null ? 'Add directory entry' : 'Edit entry',
      onSave: () {
        if (_name.text.trim().isEmpty ||
            _position.text.trim().isEmpty ||
            _contact.text.trim().isEmpty) {
          AppDialogs.toast(context, 'Name, position and contact are required.',
              error: true);
          return;
        }
        Navigator.of(context).pop(
          _EntryFormResult(
            _name.text.trim(),
            _position.text.trim(),
            _contact.text.trim(),
            _office.text.trim(),
            _description.text.trim(),
            _active,
          ),
        );
      },
      fields: <Widget>[
        AppTextField(label: 'Name', hint: 'Full name', controller: _name),
        const SizedBox(height: 12),
        AppTextField(
            label: 'Position', hint: 'e.g. Barangay Captain', controller: _position),
        const SizedBox(height: 12),
        AppTextField(
            label: 'Contact number',
            hint: '0912 345 6789',
            controller: _contact,
            keyboardType: TextInputType.phone),
        const SizedBox(height: 12),
        AppTextField(label: 'Office', hint: 'e.g. Barangay Hall', controller: _office),
        const SizedBox(height: 12),
        AppTextField(
            label: 'Description',
            hint: 'Office hours or notes',
            controller: _description,
            maxLines: 2,
            minLines: 1),
        const SizedBox(height: 6),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          value: _active,
          activeColor: AppColors.primary,
          title: const Text('Visible to residents',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
          onChanged: (bool value) => setState(() => _active = value),
        ),
      ],
    );
  }
}

class _ContactFormResult {
  const _ContactFormResult(this.name, this.category, this.contactNumber,
      this.description, this.availableHours, this.isActive);
  final String name;
  final String category;
  final String contactNumber;
  final String description;
  final String availableHours;
  final bool isActive;
}

class _ContactForm extends StatefulWidget {
  const _ContactForm({this.existing});
  final EmergencyContactModel? existing;

  @override
  State<_ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<_ContactForm> {
  late final TextEditingController _name =
      TextEditingController(text: widget.existing?.name ?? '');
  late final TextEditingController _contact =
      TextEditingController(text: widget.existing?.contactNumber ?? '');
  late final TextEditingController _description =
      TextEditingController(text: widget.existing?.description ?? '');
  late final TextEditingController _hours =
      TextEditingController(text: widget.existing?.availableHours ?? 'Available 24/7');
  late String _category = widget.existing?.category ?? 'Barangay';
  late bool _active = widget.existing?.isActive ?? true;

  @override
  Widget build(BuildContext context) {
    return _SheetScaffold(
      title: widget.existing == null ? 'Add hotline' : 'Edit hotline',
      onSave: () {
        if (_name.text.trim().isEmpty || _contact.text.trim().isEmpty) {
          AppDialogs.toast(context, 'Hotline name and number are required.',
              error: true);
          return;
        }
        Navigator.of(context).pop(
          _ContactFormResult(
            _name.text.trim(),
            _category,
            _contact.text.trim(),
            _description.text.trim(),
            _hours.text.trim(),
            _active,
          ),
        );
      },
      fields: <Widget>[
        AppTextField(label: 'Name', hint: 'e.g. Barangay Tanod Desk', controller: _name),
        const SizedBox(height: 12),
        AppTextField(
            label: 'Contact number',
            hint: '(02) 8123 4576',
            controller: _contact,
            keyboardType: TextInputType.phone),
        const SizedBox(height: 12),
        _DropdownField(
          label: 'Category',
          value: _category,
          options: AppConstants.emergencyCategories,
          onChanged: (String value) => setState(() => _category = value),
        ),
        const SizedBox(height: 12),
        AppTextField(
            label: 'Availability', hint: 'Available 24/7', controller: _hours),
        const SizedBox(height: 12),
        AppTextField(
            label: 'Description',
            hint: 'Notes for residents',
            controller: _description,
            maxLines: 2,
            minLines: 1),
        const SizedBox(height: 6),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          value: _active,
          activeColor: AppColors.primary,
          title: const Text('Visible to residents',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
          onChanged: (bool value) => setState(() => _active = value),
        ),
      ],
    );
  }
}

class _LocationFormResult {
  const _LocationFormResult(this.name, this.category, this.address,
      this.latitude, this.longitude, this.description, this.isActive);
  final String name;
  final String category;
  final String address;
  final double latitude;
  final double longitude;
  final String description;
  final bool isActive;
}

class _LocationForm extends StatefulWidget {
  const _LocationForm({this.existing});
  final BarangayLocationModel? existing;

  @override
  State<_LocationForm> createState() => _LocationFormState();
}

class _LocationFormState extends State<_LocationForm> {
  late final TextEditingController _name =
      TextEditingController(text: widget.existing?.name ?? '');
  late final TextEditingController _address =
      TextEditingController(text: widget.existing?.address ?? '');
  late final TextEditingController _latitude = TextEditingController(
      text: (widget.existing?.latitude ?? 0) == 0
          ? ''
          : '${widget.existing!.latitude}');
  late final TextEditingController _longitude = TextEditingController(
      text: (widget.existing?.longitude ?? 0) == 0
          ? ''
          : '${widget.existing!.longitude}');
  late final TextEditingController _description =
      TextEditingController(text: widget.existing?.description ?? '');
  late String _category = widget.existing?.category ?? 'Other Facility';
  late bool _active = widget.existing?.isActive ?? true;

  @override
  Widget build(BuildContext context) {
    return _SheetScaffold(
      title: widget.existing == null ? 'Add location' : 'Edit location',
      onSave: () {
        if (_name.text.trim().isEmpty) {
          AppDialogs.toast(context, 'A location name is required.', error: true);
          return;
        }
        Navigator.of(context).pop(
          _LocationFormResult(
            _name.text.trim(),
            _category,
            _address.text.trim(),
            double.tryParse(_latitude.text.trim()) ?? 0,
            double.tryParse(_longitude.text.trim()) ?? 0,
            _description.text.trim(),
            _active,
          ),
        );
      },
      fields: <Widget>[
        AppTextField(label: 'Name', hint: 'e.g. Barangay Health Center', controller: _name),
        const SizedBox(height: 12),
        _DropdownField(
          label: 'Category',
          value: _category,
          options: AppConstants.locationCategories,
          onChanged: (String value) => setState(() => _category = value),
        ),
        const SizedBox(height: 12),
        AppTextField(label: 'Address', hint: 'Street or zone', controller: _address),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(
              child: AppTextField(
                label: 'Latitude',
                hint: '0.000000',
                controller: _latitude,
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true, signed: true),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AppTextField(
                label: 'Longitude',
                hint: '0.000000',
                controller: _longitude,
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true, signed: true),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'Leave coordinates blank if they are not yet verified by the barangay.',
          style: TextStyle(fontSize: 10.5, color: AppColors.textHint),
        ),
        const SizedBox(height: 12),
        AppTextField(
            label: 'Description',
            hint: 'Services offered or landmark',
            controller: _description,
            maxLines: 2,
            minLines: 1),
        const SizedBox(height: 6),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          value: _active,
          activeColor: AppColors.primary,
          title: const Text('Visible to residents',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
          onChanged: (bool value) => setState(() => _active = value),
        ),
      ],
    );
  }
}

class _SheetScaffold extends StatelessWidget {
  const _SheetScaffold({
    required this.title,
    required this.fields,
    required this.onSave,
  });

  final String title;
  final List<Widget> fields;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 18,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Container(
                height: 4,
                width: 44,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ...fields,
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: onSave,
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 6, bottom: 7),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.divider, width: 1.2),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              borderRadius: BorderRadius.circular(16),
              items: options
                  .map((String option) => DropdownMenuItem<String>(
                        value: option,
                        child: Text(option),
                      ))
                  .toList(),
              onChanged: (String? selected) {
                if (selected != null) onChanged(selected);
              },
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
