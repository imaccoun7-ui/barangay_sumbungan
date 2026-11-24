import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_dialogs.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../models/report_model.dart';
import '../../../providers/app_scope.dart';
import '../../../providers/app_state.dart';
import '../../../services/backend/barangay_backend.dart';
import '../../../services/storage_service.dart';

class SubmitReportScreen extends StatefulWidget {
  const SubmitReportScreen({super.key});

  @override
  State<SubmitReportScreen> createState() => _SubmitReportScreenState();
}

class _SubmitReportScreenState extends State<SubmitReportScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _title = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _location = TextEditingController();
  final List<XFile> _photos = <XFile>[];
  String? _category;
  DateTime _date = DateTime.now();
  bool _loading = false;
  bool _uploadingPhoto = false;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _location.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 120)),
      lastDate: DateTime.now(),
      helpText: 'Select date of the concern',
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _addPhoto(ImageSource source) async {
    final AppState state = AppScope.read(context);
    if (_photos.length >= AppConstants.maxReportPhotos) {
      AppDialogs.toast(context,
          'You can attach up to ${AppConstants.maxReportPhotos} photos.');
      return;
    }
    setState(() => _uploadingPhoto = true);
    try {
      final XFile? file = await state.storage.pickImage(source: source);
      if (file == null) return;
      if (!mounted) return;
      setState(() => _photos.add(file));
    } on StorageException catch (error) {
      if (!mounted) return;
      AppDialogs.toast(context, error.message, error: true);
    } catch (_) {
      if (!mounted) return;
      AppDialogs.toast(
        context,
        'Photos could not be opened on this device. You can still submit the '
        'report without an attachment.',
        error: true,
      );
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Take a photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  _addPhoto(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _addPhoto(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_category == null) {
      AppDialogs.toast(context, 'Please select a category.', error: true);
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    final AppState state = AppScope.read(context);
    final NavigatorState navigator = Navigator.of(context);
    try {
      final List<String> uploaded = <String>[];
      for (final XFile photo in _photos) {
        uploaded.add(await state.storage.upload(photo));
      }
      final ReportModel report = await state.submitReport(
        title: _title.text,
        category: _category!,
        description: _description.text,
        location: _location.text,
        imageUrls: uploaded,
      );
      if (!mounted) return;
      await AppDialogs.showSuccess(
        context,
        title: 'Your concern has been\nsuccessfully submitted',
        message:
            'Reference ${report.referenceNumber}\n\nThank you for reaching out. '
            'We will keep you updated on the progress.',
        primaryLabel: 'View my reports',
        onPrimary: () {
          Navigator.of(context).pop();
          navigator.pop();
        },
      );
    } on BackendException catch (error) {
      if (!mounted) return;
      AppDialogs.toast(context, error.message, error: true);
    } catch (_) {
      if (!mounted) return;
      AppDialogs.toast(
        context,
        'Your report could not be saved. Please try again.',
        error: true,
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Submit a report'),
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
                Container(
                  padding: const EdgeInsets.all(12),
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
                          'Please make sure that your report is true and accurate.',
                          style: TextStyle(
                            fontSize: 11.5,
                            height: 1.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                AppTextField(
                  label: 'Report title',
                  hint: 'What is the concern?',
                  controller: _title,
                  validator: (String? v) =>
                      Validators.minLength(v, 5, label: 'Report title'),
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),
                const _FieldLabel('Category'),
                _CategoryDropdown(
                  value: _category,
                  onChanged: (String? value) => setState(() => _category = value),
                ),
                const SizedBox(height: 14),
                const _FieldLabel('Date'),
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: AppColors.divider, width: 1.2),
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            Formatters.fullDate(_date),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const Icon(Icons.calendar_today_outlined,
                            size: 17, color: AppColors.textHint),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Description',
                  hint: 'Provide more details about the issue…',
                  controller: _description,
                  validator: (String? v) =>
                      Validators.minLength(v, 15, label: 'Description'),
                  maxLines: 5,
                  minLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Location',
                  hint: 'Street, zone or landmark',
                  controller: _location,
                  validator: (String? v) =>
                      Validators.minLength(v, 3, label: 'Location'),
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 18),
                const _FieldLabel('Add photos'),
                _PhotoPicker(
                  photos: _photos,
                  uploading: _uploadingPhoto,
                  onAdd: _showPhotoOptions,
                  onRemove: (int index) =>
                      setState(() => _photos.removeAt(index)),
                ),
                const SizedBox(height: 26),
                PrimaryButton(
                  label: 'Submit report',
                  loading: _loading,
                  onPressed: _submit,
                ),
                const SizedBox(height: 10),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, bottom: 7),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _CategoryDropdown extends StatelessWidget {
  const _CategoryDropdown({required this.value, required this.onChanged});

  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          hint: const Text(
            'Select a category',
            style: TextStyle(fontSize: 14, color: AppColors.textHint),
          ),
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: AppColors.textSecondary),
          borderRadius: BorderRadius.circular(16),
          padding: const EdgeInsets.symmetric(vertical: 4),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          items: AppConstants.reportCategories
              .map(
                (String category) => DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _PhotoPicker extends StatelessWidget {
  const _PhotoPicker({
    required this.photos,
    required this.uploading,
    required this.onAdd,
    required this.onRemove,
  });

  final List<XFile> photos;
  final bool uploading;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              ...List<Widget>.generate(photos.length, (int index) {
                final XFile photo = photos[index];
                return Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: kIsWeb
                          ? Container(
                              height: 74,
                              width: 74,
                              color: AppColors.primarySoft,
                              child: const Icon(Icons.image_outlined),
                            )
                          : Image.file(
                              File(photo.path),
                              height: 74,
                              width: 74,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                height: 74,
                                width: 74,
                                color: AppColors.primarySoft,
                                child: const Icon(Icons.broken_image_outlined),
                              ),
                            ),
                    ),
                    Positioned(
                      top: -6,
                      right: -6,
                      child: GestureDetector(
                        onTap: () => onRemove(index),
                        child: Container(
                          height: 22,
                          width: 22,
                          decoration: const BoxDecoration(
                            color: AppColors.danger,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close_rounded,
                              size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              }),
              if (photos.length < AppConstants.maxReportPhotos)
                GestureDetector(
                  onTap: uploading ? null : onAdd,
                  child: Container(
                    height: 74,
                    width: 74,
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: uploading
                        ? const Padding(
                            padding: EdgeInsets.all(24),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.add_a_photo_outlined,
                            color: AppColors.primaryDark, size: 24),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Tap to add photos · up to ${AppConstants.maxReportPhotos} photos',
            style: const TextStyle(
              fontSize: 10.5,
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }
}
