import 'package:flutter/material.dart';

/// Colour tokens taken from the Fidelity V1 design reference.
///
/// The application never hardcodes a colour outside this file so the whole
/// visual system can be adjusted in one place.
class AppColors {
  AppColors._();

  // Brand greens
  static const Color primary = Color(0xFF2E8B4F);
  static const Color primaryDark = Color(0xFF1E5B34);
  static const Color primaryDarker = Color(0xFF164427);
  static const Color primarySoft = Color(0xFFE4F2E8);
  static const Color primarySoftAlt = Color(0xFFD6EBDD);

  // Surfaces
  static const Color background = Color(0xFFF7F6F1);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF1F1EC);
  static const Color divider = Color(0xFFE6E7E2);

  // Text
  static const Color textPrimary = Color(0xFF14231A);
  static const Color textSecondary = Color(0xFF6B7A70);
  static const Color textHint = Color(0xFFA3ADA6);
  static const Color onPrimary = Colors.white;

  // Semantic
  static const Color danger = Color(0xFFD3312C);
  static const Color dangerStrong = Color(0xFFC2241F);
  static const Color dangerSoft = Color(0xFFFBE7E5);
  static const Color dangerTint = Color(0xFFFDF1EF);

  static const Color warning = Color(0xFFE4761B);
  static const Color warningSoft = Color(0xFFFDF0DC);

  static const Color info = Color(0xFF1D7FBF);
  static const Color infoSoft = Color(0xFFDCEFFB);

  static const Color success = Color(0xFF2E7D4F);
  static const Color successSoft = Color(0xFFE1F1E5);

  static const Color accentYellow = Color(0xFFF3A43B);
  static const Color accentYellowSoft = Color(0xFFFFF3D6);

  static const Color shadow = Color(0x14000000);
}
