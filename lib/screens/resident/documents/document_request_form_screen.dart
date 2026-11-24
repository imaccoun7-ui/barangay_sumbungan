import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_dialogs.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../models/document_model.dart';
import '../../../models/user_model.dart';
import '../../../providers/app_scope.dart';
import '../../../providers/app_state.dart';
import '../../../services/backend/barangay_backend.dart';
import 'my_documents_screen.dart';

class DocumentRequestFormScreen extends StatefulWidget {
  const DocumentRequestFormScreen({super.key, required this.documentType});

  final String documentType;

  @override
  State<DocumentRequestFormScreen> createState() =>
      _DocumentRequestFormScreenState();
}

class _DocumentRequestFormScreenState extends State<DocumentRequestFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullName;
  late final TextEditingController _address;
  late final TextEditingController _contact;
  final TextEditingController _purpose = TextEditingController();
  final TextEditingController _additional = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final UserModel? user = AppScope.read(context).user;
    _fullName = TextEditingController(text: user?.fullName ?? '');
    _address = TextEditingController(text: user?.address ?? '');
    _contact = TextEditingController(text: user?.contactNumber ?? '');
  }

  @override
  void dispose() {
    _fullName.dispose();
    _address.dispose();
    _contact.dispose();
    _purpose.dispose();
    _additional.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    final AppState state = AppScope.read(context);
    final NavigatorState navigator = Navigator.of(context);
    try {
      final DocumentRequestModel request = await state.submitDocumentRequest(
        documentType: widget.documentType,
        fullName: _fullName.text,
        address: _address.text,
        purpose: _purpose.text,
        contactNumber: _contact.text,
        additionalInformation: _additional.text,
      );
      if (!mounted) return;
      await AppDialogs.showSuccess(
        context,
        title: 'Request submitted',
        message:
            'Reference ${request.referenceNumber}\n\nYou can track this '
            '${widget.documentType.toLowerCase()} request from My document '
            'requests. The barangay will notify you when its status changes.',
        primaryLabel: 'Track my request',
        onPrimary: () {
          Navigator.of(context).pop();
          navigator.pushReplacement(
            MaterialPageRoute<void>(builder: (_) => const MyDocumentsScreen()),
          );
        },
      );
    } on BackendException catch (error) {
      if (!mounted) return;
      AppDialogs.toast(context, error.message, error: true);
    } catch (_) {
      if (!mounted) return;
      AppDialogs.toast(
        context,
        'Your request could not be saved. Please try again.',
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
        title: Text(widget.documentType, style: const TextStyle(fontSize: 17)),
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
                AppCard(
                  color: AppColors.primarySoft,
                  showShadow: false,
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: <Widget>[
                      const Icon(Icons.description_outlined,
                          size: 20, color: AppColors.primaryDark),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Requesting ${widget.documentType}. Please review your '
                          'details before submitting.',
                          style: const TextStyle(
                            fontSize: 11.5,
                            height: 1.5,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                AppTextField(
                  label: 'Full name',
                  hint: 'Full name',
                  controller: _fullName,
                  validator: (String? v) =>
                      Validators.minLength(v, 3, label: 'Full name'),
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Address',
                  hint: 'House no., street, zone',
                  controller: _address,
                  validator: (String? v) =>
                      Validators.minLength(v, 5, label: 'Address'),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Contact number',
                  hint: '0912 345 6789',
                  controller: _contact,
                  validator: Validators.contactNumber,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Purpose of request',
                  hint: 'e.g. Employment requirement',
                  controller: _purpose,
                  validator: (String? v) =>
                      Validators.minLength(v, 5, label: 'Purpose'),
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Additional information (optional)',
                  hint: 'Anything the barangay should know',
                  controller: _additional,
                  maxLines: 3,
                  minLines: 2,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: 'Submit request',
                  loading: _loading,
                  onPressed: _submit,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Submitting a request does not issue the document. The '
                  'barangay still verifies your information and follows its '
                  'official approval process.',
                  style: TextStyle(
                    fontSize: 10.5,
                    height: 1.5,
                    color: AppColors.textHint,
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
