import 'package:flutter/material.dart';

/// Anchor Color System — Exact Match to ANCHOR_APP_LOGO.png:
/// Background: Warm Ivory (#FCF4E0) — 100% exact match to logo PNG background
/// Primary: Deep Midnight Navy (#0C1E38)
/// Secondary/Accent: Cerulean Ocean Blue (#0086C0)
/// Light Accent: Azure Blue (#38BDF8)
class AnchorColors {
  AnchorColors._();

  // Primary Logo Blue Shades
  static const Color primaryNavy = Color(0xFF0C1E38);
  static const Color navySurface = Color(0xFF142847);
  static const Color navyDark = Color(0xFF071224);

  // Secondary & Accent Logo Blues
  static const Color ceruleanTeal = Color(0xFF0086C0);
  static const Color ceruleanLight = Color(0xFF38BDF8);
  static const Color ceruleanTint = Color(0xFFE6F4FA);

  // App Background (100% Exact Match to ANCHOR_APP_LOGO.png background: #FCF4E0)
  static const Color bgWarmCream = Color(0xFFFCF4E0);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color borderSand = Color(0xFFEBE0C8);

  // Dark Mode Backgrounds & Surfaces
  static const Color bgDarkAbyssal = Color(0xFF0A111E);
  static const Color cardDarkSurface = Color(0xFF131F33);
  static const Color borderDarkNavy = Color(0xFF1E2E48);

  // Text Colors
  static const Color textPrimary = Color(0xFF0C1E38);
  static const Color textSecondary = Color(0xFF5C6B73);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textDarkPrimary = Color(0xFFF8FAFC);
  static const Color textDarkSecondary = Color(0xFFCBD5E1);

  // Status & Indicator Colors
  static const Color statusMint = Color(0xFF059669);
  static const Color statusMintLight = Color(0xFFD1FAE5);
  static const Color alertCoral = Color(0xFFDC2626);
  static const Color alertCoralLight = Color(0xFFFEE2E2);
  static const Color warningAmber = Color(0xFFD97706);
  static const Color warningAmberLight = Color(0xFFFEF3C7);
}
