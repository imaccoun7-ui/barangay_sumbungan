import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_dialogs.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../models/user_model.dart';
import '../../../providers/app_scope.dart';
import '../../../services/backend/barangay_backend.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullName;
  late final TextEditingController _contact;
  late final TextEditingController _address;
  late final TextEditingController _household;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final UserModel? user = AppScope.read(context).user;
    _fullName = TextEditingController(text: user?.fullName ?? '');
    _contact = TextEditingController(text: user?.contactNumber ?? '');
    _address = TextEditingController(text: user?.address ?? '');
    _household = TextEditingController(text: user?.householdInfo ?? '');
  }

  @override
  void dispose() {
    _fullName.dispose();
    _contact.dispose();
    _address.dispose();
    _household.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    try {
      await AppScope.read(context).updateOwnProfile(
        fullName: _fullName.text,
        contactNumber: _contact.text,
        address: _address.text,
        householdInfo: _household.text,
      );
      if (!mounted) return;
      AppDialogs.toast(context, 'Your details have been updated.');
      Navigator.of(context).pop();
    } on BackendException catch (error) {
      if (!mounted) return;
      AppDialogs.toast(context, error.message, error: true);
    } catch (_) {
      if (!mounted) return;
      AppDialogs.toast(context, 'Could not save your details. Try again.',
          error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Personal information'),
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
                  label: 'Full name',
                  hint: 'Full name',
                  controller: _fullName,
                  validator: (String? v) =>
                      Validators.minLength(v, 3, label: 'Full name'),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Contact number',
                  hint: '0912 345 6789',
                  controller: _contact,
                  validator: Validators.contactNumber,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Address',
                  hint: 'House no., street, zone',
                  controller: _address,
                  validator: (String? v) =>
                      Validators.minLength(v, 5, label: 'Address'),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Household information',
                  hint: 'Household of 5',
                  controller: _household,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Icon(Icons.lock_outline_rounded,
                          size: 16, color: AppColors.textSecondary),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Your email address and role are managed by the barangay '
                          'office and cannot be edited here.',
                          style: TextStyle(
                            fontSize: 11,
                            height: 1.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                PrimaryButton(
                  label: 'Save changes',
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
