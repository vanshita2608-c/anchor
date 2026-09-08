import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'anchor_colors.dart';

/// Anchor Typography System — Otama Typography Family
/// All text elements in Anchor use Otama Display & Otama Text.
class AnchorTypography {
  AnchorTypography._();

  static const String fontOtama = 'Otama';
  static const String fontOtamaDisplay = 'OtamaDisplay';

  // Fallback font family style (Serif / Playfair Display) for seamless compilation
  static TextStyle get _baseStyle => GoogleFonts.playfairDisplay(
        color: AnchorColors.textPrimary,
      );

  // 1. BRAND & LOGO (Otama Display Bold)
  static TextStyle get brandTitle => _baseStyle.copyWith(
        fontFamily: fontOtamaDisplay,
        fontSize: 32,
        fontWeight: FontWeight.bold,
        letterSpacing: 2.0,
        color: AnchorColors.primaryNavy,
      );

  static TextStyle get brandSubtitle => _baseStyle.copyWith(
        fontFamily: fontOtama,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.2,
        color: AnchorColors.ceruleanTeal,
      );

  // 2. DISPLAY & HEADINGS (Otama Display)
  static TextStyle get displayLarge => _baseStyle.copyWith(
        fontFamily: fontOtamaDisplay,
        fontSize: 28,
        fontWeight: FontWeight.bold,
        height: 1.2,
        color: AnchorColors.textPrimary,
      );

  static TextStyle get displayMedium => _baseStyle.copyWith(
        fontFamily: fontOtamaDisplay,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        height: 1.25,
        color: AnchorColors.textPrimary,
      );

  static TextStyle get headlineLarge => _baseStyle.copyWith(
        fontFamily: fontOtama,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AnchorColors.textPrimary,
      );

  static TextStyle get headlineMedium => _baseStyle.copyWith(
        fontFamily: fontOtama,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AnchorColors.textPrimary,
      );

  // 3. CARD TITLES & SECTION HEADERS (Otama Text)
  static TextStyle get titleLarge => _baseStyle.copyWith(
        fontFamily: fontOtama,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AnchorColors.textPrimary,
      );

  static TextStyle get titleMedium => _baseStyle.copyWith(
        fontFamily: fontOtama,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AnchorColors.textPrimary,
      );

  static TextStyle get titleSmall => _baseStyle.copyWith(
        fontFamily: fontOtama,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AnchorColors.textPrimary,
      );

  // 4. BODY TEXT (Otama Text Regular)
  static TextStyle get bodyLarge => _baseStyle.copyWith(
        fontFamily: fontOtama,
        fontSize: 16,
        fontWeight: FontWeight.normal,
        height: 1.4,
        color: AnchorColors.textPrimary,
      );

  static TextStyle get bodyMedium => _baseStyle.copyWith(
        fontFamily: fontOtama,
        fontSize: 14,
        fontWeight: FontWeight.normal,
        height: 1.4,
        color: AnchorColors.textPrimary,
      );

  static TextStyle get bodySmall => _baseStyle.copyWith(
        fontFamily: fontOtama,
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: AnchorColors.textSecondary,
      );

  // 5. BUTTONS & LABELS (Otama Text SemiBold)
  static TextStyle get buttonText => _baseStyle.copyWith(
        fontFamily: fontOtama,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: Colors.white,
      );

  static TextStyle get labelLarge => _baseStyle.copyWith(
        fontFamily: fontOtama,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AnchorColors.textPrimary,
      );

  static TextStyle get labelMedium => _baseStyle.copyWith(
        fontFamily: fontOtama,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AnchorColors.textSecondary,
      );

  // 6. NUMBERS & SECURITY SCORE
  static TextStyle get securityScore => _baseStyle.copyWith(
        fontFamily: fontOtamaDisplay,
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: AnchorColors.primaryNavy,
      );

  static TextStyle get statNumber => _baseStyle.copyWith(
        fontFamily: fontOtamaDisplay,
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AnchorColors.textPrimary,
      );
}
