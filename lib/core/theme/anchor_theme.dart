import 'package:flutter/material.dart';
import 'anchor_colors.dart';
import 'anchor_typography.dart';

class AnchorTheme {
  AnchorTheme._();

  static ThemeData get lightTheme {
    final baseTextTheme = TextTheme(
      displayLarge: AnchorTypography.displayLarge,
      displayMedium: AnchorTypography.displayMedium,
      headlineLarge: AnchorTypography.headlineLarge,
      headlineMedium: AnchorTypography.headlineMedium,
      titleLarge: AnchorTypography.titleLarge,
      titleMedium: AnchorTypography.titleMedium,
      titleSmall: AnchorTypography.titleSmall,
      bodyLarge: AnchorTypography.bodyLarge,
      bodyMedium: AnchorTypography.bodyMedium,
      bodySmall: AnchorTypography.bodySmall,
      labelLarge: AnchorTypography.labelLarge,
      labelMedium: AnchorTypography.labelMedium,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AnchorColors.primaryNavy,
      scaffoldBackgroundColor: AnchorColors.bgWarmCream,
      textTheme: baseTextTheme,
      primaryTextTheme: baseTextTheme,
      colorScheme: const ColorScheme.light(
        primary: AnchorColors.primaryNavy,
        secondary: AnchorColors.ceruleanTeal,
        surface: AnchorColors.cardWhite,
        background: AnchorColors.bgWarmCream,
        error: AnchorColors.alertCoral,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AnchorColors.textPrimary,
        onBackground: AnchorColors.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AnchorColors.bgWarmCream,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        titleTextStyle: AnchorTypography.headlineLarge,
        iconTheme: const IconThemeData(color: AnchorColors.primaryNavy),
      ),
      cardTheme: CardThemeData(
        color: AnchorColors.cardWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AnchorColors.borderSand, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AnchorColors.primaryNavy,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AnchorTypography.buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AnchorColors.primaryNavy,
          side: const BorderSide(color: AnchorColors.borderSand, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AnchorTypography.buttonText.copyWith(
            color: AnchorColors.primaryNavy,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AnchorColors.cardWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AnchorColors.borderSand),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AnchorColors.borderSand),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AnchorColors.ceruleanTeal, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AnchorColors.alertCoral),
        ),
        hintStyle: AnchorTypography.bodyMedium.copyWith(color: AnchorColors.textMuted),
        labelStyle: AnchorTypography.labelLarge,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AnchorColors.cardWhite,
        selectedItemColor: AnchorColors.primaryNavy,
        unselectedItemColor: AnchorColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: AnchorTypography.labelMedium.copyWith(fontWeight: FontWeight.bold),
        unselectedLabelStyle: AnchorTypography.labelMedium,
      ),
    );
  }
}
