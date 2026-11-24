import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_dialogs.dart';
import '../../core/widgets/app_text_field.dart';
import '../../providers/app_scope.dart';
import '../../services/backend/barangay_backend.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  bool _loading = false;
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    try {
      await AppScope.read(context).requestPasswordReset(_email.text.trim());
      if (!mounted) return;
      setState(() => _sent = true);
    } on BackendException catch (error) {
      if (!mounted) return;
      AppDialogs.toast(context, error.message, error: true);
    } catch (_) {
      if (!mounted) return;
      AppDialogs.toast(context, 'Could not send the reset link. Try again.',
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
        title: const Text('Reset password'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.chevron_left_rounded, size: 28),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 30),
          child: _sent ? _sentBody() : _formBody(),
        ),
      ),
    );
  }

  Widget _formBody() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Forgot your password?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Enter the email address you registered with. We will send you a '
            'link to choose a new password.',
            style: TextStyle(
              fontSize: 13,
              height: 1.55,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          AppTextField(
            label: 'Email address',
            hint: 'you@example.com',
            controller: _email,
            validator: Validators.email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            label: 'Send reset link',
            loading: _loading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }

  Widget _sentBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          height: 72,
          width: 72,
          decoration: const BoxDecoration(
            color: AppColors.primarySoft,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.mark_email_read_outlined,
              size: 32, color: AppColors.primaryDark),
        ),
        const SizedBox(height: 20),
        const Text(
          'Check your inbox',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'If an account exists for ${_email.text.trim()}, a password reset link '
          'is on its way. Follow the instructions in that email to continue.',
          style: const TextStyle(
            fontSize: 13,
            height: 1.6,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          label: 'Back to sign in',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
