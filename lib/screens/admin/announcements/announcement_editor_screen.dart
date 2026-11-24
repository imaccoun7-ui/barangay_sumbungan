import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_dialogs.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../models/announcement_model.dart';
import '../../../providers/app_scope.dart';
import '../../../providers/app_state.dart';
import '../../../services/backend/barangay_backend.dart';

/// Create or edit an announcement. Publishing also notifies every active
/// resident through the notification service.
class AnnouncementEditorScreen extends StatefulWidget {
  const AnnouncementEditorScreen({super.key, this.announcement});

  final AnnouncementModel? announcement;

  @override
  State<AnnouncementEditorScreen> createState() =>
      _AnnouncementEditorScreenState();
}

class _AnnouncementEditorScreenState extends State<AnnouncementEditorScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _content;
  late String _category;
  late bool _published;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.announcement?.title ?? '');
    _content = TextEditingController(text: widget.announcement?.content ?? '');
    _category = widget.announcement?.category ?? 'Announcements';
    _published = widget.announcement?.published ?? true;
  }

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    final AppState state = AppScope.read(context);
    try {
      await state.saveAnnouncement(
        existing: widget.announcement,
        title: _title.text,
        content: _content.text,
        category: _category,
        published: _published,
      );
      if (!mounted) return;
      AppDialogs.toast(
        context,
        _published
            ? 'Announcement published. Residents have been notified.'
            : 'Draft saved.',
      );
      Navigator.of(context).pop();
    } on BackendException catch (error) {
      if (!mounted) return;
      AppDialogs.toast(context, error.message, error: true);
    } catch (_) {
      if (!mounted) return;
      AppDialogs.toast(context, 'Could not save the announcement. Try again.',
          error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool editing = widget.announcement != null;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(editing ? 'Edit announcement' : 'New announcement'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.chevron_left_rounded, size: 28),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 30),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AppTextField(
                  label: 'Title',
                  hint: 'e.g. Heavy rainfall advisory',
                  controller: _title,
                  validator: (String? v) =>
                      Validators.minLength(v, 5, label: 'Title'),
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 14),
                const Padding(
                  padding: EdgeInsets.only(left: 6, bottom: 7),
                  child: Text(
                    'Category',
                    style: TextStyle(
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
                      value: _category,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded,
                          color: AppColors.textSecondary),
                      borderRadius: BorderRadius.circular(16),
                      items: AppConstants.announcementCategories
                          .map((String category) => DropdownMenuItem<String>(
                                value: category,
                                child: Text(category),
                              ))
                          .toList(),
                      onChanged: (String? value) {
                        if (value != null) setState(() => _category = value);
                      },
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Content',
                  hint:
                      'Write the full advisory. Separate paragraphs with a blank line.',
                  controller: _content,
                  validator: (String? v) =>
                      Validators.minLength(v, 20, label: 'Content'),
                  maxLines: 10,
                  minLines: 6,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    value: _published,
                    activeColor: AppColors.primary,
                    title: const Text(
                      'Publish immediately',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      _published
                          ? 'Residents can read this and receive a notification.'
                          : 'Saved as a draft; residents cannot see it yet.',
                      style: const TextStyle(
                        fontSize: 11,
                        height: 1.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    onChanged: (bool value) =>
                        setState(() => _published = value),
                  ),
                ),
                const SizedBox(height: 22),
                PrimaryButton(
                  label: _published ? 'Publish announcement' : 'Save draft',
                  loading: _saving,
                  onPressed: _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
