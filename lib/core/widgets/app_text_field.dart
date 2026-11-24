import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';

/// Fidelity V1 input: pill shaped, outlined, hint-only labelling.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.hint,
    this.controller,
    this.label,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines,
    this.prefixIcon,
    this.suffix,
    this.textInputAction,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.inputFormatters,
    this.autofillHints,
    this.textCapitalization = TextCapitalization.none,
    this.maxLength,
    this.enabled = true,
  });

  final String hint;
  final String? label;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int maxLines;
  final int? minLines;
  final IconData? prefixIcon;
  final Widget? suffix;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;
  final TextCapitalization textCapitalization;
  final int? maxLength;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final Widget field = TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: obscureText ? 1 : maxLines,
      minLines: minLines,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onTap: onTap,
      readOnly: readOnly,
      inputFormatters: inputFormatters,
      autofillHints: autofillHints,
      textCapitalization: textCapitalization,
      maxLength: maxLength,
      enabled: enabled,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        counterText: '',
        prefixIcon: prefixIcon == null
            ? null
            : Icon(prefixIcon, size: 19, color: AppColors.textHint),
        suffixIcon: suffix,
        contentPadding: EdgeInsets.symmetric(
          horizontal: prefixIcon == null ? 18 : 6,
          vertical: maxLines > 1 ? 16 : 0,
        ),
      ),
    );

    if (label == null) return field;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 6, bottom: 7),
          child: Text(
            label!,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        field,
      ],
    );
  }
}

/// Read-only labelled value row used on detail screens.
class LabeledValue extends StatelessWidget {
  const LabeledValue({
    super.key,
    required this.label,
    required this.value,
    this.icon,
  });

  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(icon, size: 16, color: AppColors.textHint),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                    color: AppColors.textHint,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
