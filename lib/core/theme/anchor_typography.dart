import 'package:flutter/material.dart';
import 'anchor_colors.dart';

/// Anchor Typography System — Pure Otama Didone Serif Family
/// Strictly uses Otama & OtamaDisplay typography throughout the application.
class AnchorTypography {
  AnchorTypography._();

  static const String fontOtama = 'Otama';
  static const String fontOtamaDisplay = 'OtamaDisplay';

  // 1. BRAND & LOGO (Otama Display Bold)
  static TextStyle get brandTitle => const TextStyle(
        fontFamily: fontOtamaDisplay,
        fontSize: 34,
        fontWeight: FontWeight.bold,
        letterSpacing: 3.0,
        color: AnchorColors.primaryNavy,
      );

  static TextStyle get brandSubtitle => const TextStyle(
        fontFamily: fontOtama,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
        color: AnchorColors.ceruleanTeal,
      );

  // 2. DISPLAY & HEADINGS (Otama Display)
  static TextStyle get displayLarge => const TextStyle(
        fontFamily: fontOtamaDisplay,
        fontSize: 28,
        fontWeight: FontWeight.bold,
        height: 1.2,
        color: AnchorColors.textPrimary,
      );

  static TextStyle get displayMedium => const TextStyle(
        fontFamily: fontOtamaDisplay,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        height: 1.25,
        color: AnchorColors.textPrimary,
      );

  static TextStyle get headlineLarge => const TextStyle(
        fontFamily: fontOtama,
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AnchorColors.textPrimary,
      );

  static TextStyle get headlineMedium => const TextStyle(
        fontFamily: fontOtama,
        fontSize: 19,
        fontWeight: FontWeight.w600,
        color: AnchorColors.textPrimary,
      );

  // 3. CARD TITLES & SECTION HEADERS
  static TextStyle get titleLarge => const TextStyle(
        fontFamily: fontOtama,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AnchorColors.textPrimary,
      );

  static TextStyle get titleMedium => const TextStyle(
        fontFamily: fontOtama,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AnchorColors.textPrimary,
      );

  static TextStyle get titleSmall => const TextStyle(
        fontFamily: fontOtama,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AnchorColors.textPrimary,
      );

  // 4. BODY TEXT (Otama Serif Body)
  static TextStyle get bodyLarge => const TextStyle(
        fontFamily: fontOtama,
        fontSize: 15,
        fontWeight: FontWeight.normal,
        height: 1.4,
        color: AnchorColors.textPrimary,
      );

  static TextStyle get bodyMedium => const TextStyle(
        fontFamily: fontOtama,
        fontSize: 14,
        fontWeight: FontWeight.normal,
        height: 1.4,
        color: AnchorColors.textPrimary,
      );

  static TextStyle get bodySmall => const TextStyle(
        fontFamily: fontOtama,
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: AnchorColors.textSecondary,
      );

  // 5. BUTTONS & LABELS
  static TextStyle get buttonText => const TextStyle(
        fontFamily: fontOtama,
        fontSize: 15,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        color: Colors.white,
      );

  static TextStyle get labelLarge => const TextStyle(
        fontFamily: fontOtama,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AnchorColors.textPrimary,
      );

  static TextStyle get labelMedium => const TextStyle(
        fontFamily: fontOtama,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AnchorColors.textSecondary,
      );

  // 6. NUMBERS & SECURITY SCORE
  static TextStyle get securityScore => const TextStyle(
        fontFamily: fontOtamaDisplay,
        fontSize: 38,
        fontWeight: FontWeight.bold,
        color: AnchorColors.primaryNavy,
      );

  static TextStyle get statNumber => const TextStyle(
        fontFamily: fontOtamaDisplay,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AnchorColors.textPrimary,
      );
}
