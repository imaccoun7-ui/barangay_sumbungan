import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Full-width primary action used at the bottom of forms and dialogs.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
    this.color,
    this.foregroundColor,
    this.expanded = true,
    this.height = 52,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;
  final Color? color;
  final Color? foregroundColor;
  final bool expanded;
  final double height;

  @override
  Widget build(BuildContext context) {
    final Widget content = loading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(icon, size: 18, color: foregroundColor ?? Colors.white),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: TextStyle(
                  color: foregroundColor ?? Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );

    final Widget button = SizedBox(
      height: height,
      width: expanded ? double.infinity : null,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? AppColors.primary,
          disabledBackgroundColor:
              (color ?? AppColors.primary).withOpacity(loading ? 1 : 0.45),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: EdgeInsets.symmetric(horizontal: expanded ? 20 : 26),
        ),
        child: content,
      ),
    );
    return button;
  }
}

/// Compact green pill button, e.g. the "Call" action on hotline cards.
class SmallPillButton extends StatelessWidget {
  const SmallPillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = AppColors.primary,
    this.foregroundColor = Colors.white,
    this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final Color color;
  final Color foregroundColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(icon, size: 15, color: foregroundColor),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  color: foregroundColor,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
