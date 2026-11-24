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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    final AppState state = AppScope.read(context);
    try {
      await state.signIn(email: _email.text, password: _password.text);
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(
        state.isAdmin ? AppRoutes.adminHome : AppRoutes.residentHome,
      );
    } on BackendException catch (error) {
      if (!mounted) return;
      AppDialogs.toast(context, error.message, error: true);
    } catch (_) {
      if (!mounted) return;
      AppDialogs.toast(
        context,
        'We could not sign you in. Please check your connection and try again.',
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    IconButton(
                      onPressed: () => Navigator.of(context)
                          .pushReplacementNamed(AppRoutes.onboarding),
                      icon: const Icon(Icons.chevron_left_rounded, size: 28),
                      color: AppColors.textPrimary,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Sign in',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                const Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Hello there, sign in to continue',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Image.asset(
                    'assets/images/login_illustration.jpg',
                    height: 190,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 8),
                AppTextField(
                  hint: 'Email',
                  controller: _email,
                  validator: Validators.email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const <String>[AutofillHints.email],
                ),
                const SizedBox(height: 14),
                AppTextField(
                  hint: 'Password',
                  controller: _password,
                  validator: Validators.password,
                  obscureText: _obscure,
                  textInputAction: TextInputAction.done,
                  autofillHints: const <String>[AutofillHints.password],
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
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context)
                        .pushNamed(AppRoutes.forgotPassword),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 6),
                      foregroundColor: AppColors.textSecondary,
                    ),
                    child: const Text(
                      'Forgot your password ?',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                PrimaryButton(
                  label: 'Sign in',
                  loading: _loading,
                  onPressed: _submit,
                ),
                const SizedBox(height: 16),
                Center(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      const Text(
                        "Don't have an account?  ",
                        style: TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () =>
                            Navigator.of(context).pushNamed(AppRoutes.register),
                        child: const Text(
                          'Sign Up',
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
                const SizedBox(height: 26),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
