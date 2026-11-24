import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_dialogs.dart';
import '../../core/widgets/app_text_field.dart';
import '../../providers/app_scope.dart';
import '../../providers/app_state.dart';
import '../../services/backend/barangay_backend.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _fullName = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _contact = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _household = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirm = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _fullName.dispose();
    _email.dispose();
    _contact.dispose();
    _address.dispose();
    _household.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    final AppState state = AppScope.read(context);
    try {
      await state.registerResident(
        fullName: _fullName.text,
        email: _email.text,
        password: _password.text,
        contactNumber: _contact.text,
        address: _address.text,
        householdInfo: _household.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRoutes.residentHome);
    } on BackendException catch (error) {
      if (!mounted) return;
      AppDialogs.toast(context, error.message, error: true);
    } catch (_) {
      if (!mounted) return;
      AppDialogs.toast(context, 'Registration failed. Please try again.',
          error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Create account'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.chevron_left_rounded, size: 28),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 30),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Join Barangay Sumbungan',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Register as a resident to request documents, submit reports and '
                  'receive barangay updates.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 22),
                AppTextField(
                  label: 'Full name',
                  hint: 'Maria Clara Santos',
                  controller: _fullName,
                  validator: (String? v) =>
                      Validators.minLength(v, 3, label: 'Full name'),
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Email address',
                  hint: 'you@example.com',
                  controller: _email,
                  validator: Validators.email,
                  keyboardType: TextInputType.emailAddress,
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
                  label: 'Address',
                  hint: 'House no., street, zone',
                  controller: _address,
                  validator: (String? v) =>
                      Validators.minLength(v, 5, label: 'Address'),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Household information (optional)',
                  hint: 'Household of 5',
                  controller: _household,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Password',
                  hint: 'At least 8 characters',
                  controller: _password,
                  validator: Validators.password,
                  obscureText: _obscure,
                  textInputAction: TextInputAction.next,
                  suffix: IconButton(
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 19,
                      color: AppColors.textHint,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Confirm password',
                  hint: 'Re-enter your password',
                  controller: _confirm,
                  validator: (String? v) =>
                      Validators.confirmPassword(v, _password.text),
                  obscureText: _obscure,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Icon(Icons.shield_outlined,
                          size: 16, color: AppColors.textSecondary),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'New accounts are registered as residents. Administrator '
                          'access is granted only by the barangay office.',
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
                const SizedBox(height: 20),
                PrimaryButton(
                  label: 'Create account',
                  loading: _loading,
                  onPressed: _submit,
                ),
                const SizedBox(height: 14),
                Center(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      const Text(
                        'Already registered?  ',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context)
                            .pushReplacementNamed(AppRoutes.login),
                        child: const Text(
                          'Sign in',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
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
