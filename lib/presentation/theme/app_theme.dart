import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  // Stitch: Algerian turf emerald.
  static const Color primary = Color(0xFF0E7845);
  static const Color primaryDark = Color(0xFF005D33);
  static const Color primaryLight = Color(0xFF218F59);
  static const Color primarySurface = Color(0xFFEBF5F0);
  static const Color primaryContainer = Color(0xFFCFF7DD);

  // Athletic slate / informational blue.
  static const Color secondary = Color(0xFF1E293B);
  static const Color slate = secondary;
  static const Color secondaryLight = Color(0xFF475569);
  static const Color secondarySurface = Color(0xFFF1F5F9);
  static const Color info = Color(0xFF356B8C);
  static const Color infoSurface = Color(0xFFE8F0F7);

  // Destructive / absence.
  static const Color tertiary = Color(0xFF991B1B);
  static const Color tertiaryLight = Color(0xFFB91C1C);
  static const Color tertiarySurface = Color(0xFFFEE2E2);

  // Neutral slate.
  static const Color neutral = Color(0xFF0F172A);
  static const Color ink = neutral;
  static const Color neutralLight = Color(0xFF334155);
  static const Color neutralMuted = Color(0xFF64748B);
  static const Color neutralSurface = Color(0xFFF1F5F9);

  // Surfaces.
  static const Color background = Colors.white;
  static const Color surface = Color(0xFFF8FAFC);
  static const Color card = Colors.white;

  // Semantic support.
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);
  static const Color placeholder = Color(0xFF94A3B8);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);
  static const Color dotInactive = Color(0xFFCBD5E1);
  static const Color accent = primary;
  static const Color success = primary;
  static const Color warning = Color(0xFFD97706);
  static const Color warningSurface = Color(0xFFFEF3C7);

  static const Color buttonPrimary = primary;
  static const Color buttonInverted = neutral;
}

class AppTheme {
  static ThemeData get theme {
    final textTheme = GoogleFonts.ibmPlexSansArabicTextTheme();
    const radius = 10.0;

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.surface,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.warning,
        surface: AppColors.surface,
        onSurface: AppColors.textDark,
        error: AppColors.tertiary,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
      ),
      textTheme: textTheme.copyWith(
        headlineLarge: textTheme.headlineLarge?.copyWith(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
          height: 1.35,
        ),
        headlineMedium: textTheme.headlineMedium?.copyWith(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
          height: 1.4,
        ),
        headlineSmall: textTheme.headlineSmall?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
          height: 1.45,
        ),
        titleLarge: textTheme.titleLarge?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
          height: 1.45,
        ),
        titleMedium: textTheme.titleMedium?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
          height: 1.5,
        ),
        bodyLarge: textTheme.bodyLarge?.copyWith(
          fontSize: 16,
          color: AppColors.textDark,
          height: 1.6,
        ),
        bodyMedium: textTheme.bodyMedium?.copyWith(
          fontSize: 14,
          color: AppColors.textMuted,
          height: 1.55,
        ),
        bodySmall: textTheme.bodySmall?.copyWith(
          fontSize: 12,
          color: AppColors.textMuted,
          height: 1.55,
        ),
        labelLarge: textTheme.labelLarge?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
          height: 1.5,
        ),
        labelMedium: textTheme.labelMedium?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textMuted,
          height: 1.5,
        ),
        labelSmall: textTheme.labelSmall?.copyWith(
          fontSize: 11,
          color: AppColors.placeholder,
          height: 1.45,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        toolbarHeight: 60,
        titleTextStyle: GoogleFonts.ibmPlexSansArabic(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
          height: 1.4,
        ),
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
          tapTargetSize: MaterialTapTargetSize.padded,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          textStyle: GoogleFonts.ibmPlexSansArabic(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            height: 1.5,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          textStyle: GoogleFonts.ibmPlexSansArabic(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            height: 1.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textDark,
          side: const BorderSide(color: AppColors.border),
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          textStyle: GoogleFonts.ibmPlexSansArabic(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            height: 1.5,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(44, 44),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          textStyle: GoogleFonts.ibmPlexSansArabic(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            height: 1.5,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.background,
        isDense: false,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: AppColors.tertiary),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: AppColors.tertiary, width: 2),
        ),
        hintStyle: GoogleFonts.ibmPlexSansArabic(
          fontSize: 14,
          color: AppColors.placeholder,
          height: 1.5,
        ),
        errorStyle: GoogleFonts.ibmPlexSansArabic(
          fontSize: 12,
          color: AppColors.tertiary,
          height: 1.45,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.background,
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        labelStyle: GoogleFonts.ibmPlexSansArabic(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
          height: 1.45,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.background,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.placeholder,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
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
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(44, 44),
          tapTargetSize: MaterialTapTargetSize.padded,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.neutral,
        contentTextStyle: GoogleFonts.ibmPlexSansArabic(
          color: Colors.white,
          fontSize: 14,
          height: 1.5,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.border,
      ),
    );
  }
}
