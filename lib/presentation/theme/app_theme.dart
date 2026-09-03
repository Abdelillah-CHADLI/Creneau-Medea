import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  // Primary - Green
  static const Color primary = Color(0xFF0D5C35);
  static const Color primaryLight = Color(0xFF1A7A4A);
  static const Color primarySurface = Color(0xFFE8F5EE);
  static const Color primaryContainer = Color(0xFFD4EDDA);

  // Secondary - Blue
  static const Color secondary = Color(0xFF1A4B84);
  static const Color secondaryLight = Color(0xFF2B6CB0);
  static const Color secondarySurface = Color(0xFFE8F0FE);

  // Tertiary - Red/Maroon
  static const Color tertiary = Color(0xFF81393F);
  static const Color tertiaryLight = Color(0xFFA04A52);
  static const Color tertiarySurface = Color(0xFFFCE8EA);

  // Neutral - Dark Navy
  static const Color neutral = Color(0xFF0F172A);
  static const Color neutralLight = Color(0xFF334155);
  static const Color neutralMuted = Color(0xFF64748B);
  static const Color neutralSurface = Color(0xFFF1F5F9);

  // Background
  static const Color background = Colors.white;
  static const Color surface = Color(0xFFF8FAFC);
  static const Color card = Colors.white;

  // Semantic
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);
  static const Color placeholder = Color(0xFF94A3B8);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);
  static const Color dotInactive = Color(0xFFCBD5E1);
  static const Color accent = Color(0xFF7B5EA7);
  static const Color success = Color(0xFF0D5C35);
  static const Color warning = Color(0xFFD97706);

  // Button variants
  static const Color buttonPrimary = Color(0xFF0D5C35);
  static const Color buttonInverted = Color(0xFF0F172A);
}

class AppTheme {
  static ThemeData get theme {
    // Cairo has complete Arabic glyph coverage and much more natural metrics
    // for the RTL-first UI than the default Latin-oriented typefaces.
    final textTheme = GoogleFonts.cairoTextTheme();

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.surface,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.tertiary,
        surface: AppColors.surface,
        onSurface: AppColors.textDark,
        error: AppColors.tertiary,
      ),
      textTheme: textTheme.copyWith(
        headlineLarge: textTheme.headlineLarge?.copyWith(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
        headlineMedium: textTheme.headlineMedium?.copyWith(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
        headlineSmall: textTheme.headlineSmall?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
        titleLarge: textTheme.titleLarge?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
        titleMedium: textTheme.titleMedium?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
        bodyLarge: textTheme.bodyLarge?.copyWith(
          fontSize: 16,
          color: AppColors.textDark,
        ),
        bodyMedium: textTheme.bodyMedium?.copyWith(
          fontSize: 14,
          color: AppColors.textMuted,
        ),
        bodySmall: textTheme.bodySmall?.copyWith(
          fontSize: 12,
          color: AppColors.textMuted,
        ),
        labelLarge: textTheme.labelLarge?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
        labelMedium: textTheme.labelMedium?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textMuted,
        ),
        labelSmall: textTheme.labelSmall?.copyWith(
          fontSize: 11,
          color: AppColors.placeholder,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          // Arabic glyphs have taller ascenders/descenders than Latin text.
          // A fixed, compact button with the old 16px vertical padding clipped
          // labels on several devices.
          minimumSize: const Size.fromHeight(58),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            height: 1.35,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textDark,
          side: const BorderSide(color: AppColors.border),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 1.35,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        hintStyle: GoogleFonts.cairo(
          fontSize: 14,
          color: AppColors.placeholder,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.background,
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        labelStyle: GoogleFonts.cairo(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.textDark,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.background,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.placeholder,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(fontSize: 11),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 0,
      ),
    );
  }
}
