import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart';

class LionTheme {
  static ThemeData get light {
    const Color primary = LionColors.primary;
    const Color background = LionColors.backgroundLight;
    const Color surface = LionColors.surfaceLight;
    const Color textPrimary = LionColors.textPrimaryLight;
    const Color textSecondary = LionColors.textSecondaryLight;
    const Color border = LionColors.borderLight;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: LionColors.accent,
        surface: surface,
        background: background,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onBackground: textPrimary,
        outline: border,
      ),
      scaffoldBackgroundColor: background,
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.light().textTheme.copyWith(
              displayLarge: GoogleFonts.inter(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: textPrimary,
                letterSpacing: -0.5,
              ),
              displayMedium: GoogleFonts.inter(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: textPrimary,
                letterSpacing: -0.3,
              ),
              headlineLarge: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
              headlineMedium: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
              headlineSmall: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
              titleLarge: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
              titleMedium: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textPrimary,
              ),
              bodyLarge: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: textPrimary,
              ),
              bodyMedium: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: textPrimary,
              ),
              bodySmall: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: textSecondary,
              ),
              labelLarge: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.2,
              ),
            ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: border.withOpacity(0.5),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: primary.withOpacity(0.12),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const IconThemeData(color: primary, size: 24);
          }
          return const IconThemeData(color: textSecondary, size: 24);
        }),
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: primary,
            );
          }
          return GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: textSecondary,
          );
        }),
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardTheme(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LionRadius.lg),
          side: const BorderSide(color: border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF3F4F6),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LionRadius.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LionRadius.md),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LionRadius.md),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LionRadius.md),
          borderSide: const BorderSide(color: LionColors.busy, width: 1.5),
        ),
        hintStyle: GoogleFonts.inter(
          fontSize: 14,
          color: textSecondary,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          color: textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LionRadius.md),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LionRadius.sm),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: LionColors.dividerLight,
        thickness: 1,
        space: 0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: primary.withOpacity(0.08),
        labelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: primary,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LionRadius.full),
        ),
        side: BorderSide.none,
      ),
    );
  }

  static ThemeData get dark {
    const Color primary = LionColors.primary;
    const Color background = LionColors.backgroundDark;
    const Color surface = LionColors.surfaceDark;
    const Color card = LionColors.cardDark;
    const Color textPrimary = LionColors.textPrimaryDark;
    const Color textSecondary = LionColors.textSecondaryDark;
    const Color border = LionColors.borderDark;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: primary,
        secondary: LionColors.accent,
        surface: surface,
        background: background,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onBackground: textPrimary,
        outline: border,
      ),
      scaffoldBackgroundColor: background,
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme.copyWith(
              displayLarge: GoogleFonts.inter(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: textPrimary,
                letterSpacing: -0.5,
              ),
              displayMedium: GoogleFonts.inter(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
              headlineLarge: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
              headlineMedium: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
              headlineSmall: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
              titleLarge: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
              titleMedium: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textPrimary,
              ),
              bodyLarge: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: textPrimary,
              ),
              bodyMedium: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: textPrimary,
              ),
              bodySmall: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: textSecondary,
              ),
              labelLarge: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: border,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: primary.withOpacity(0.15),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const IconThemeData(color: primary, size: 24);
          }
          return const IconThemeData(color: textSecondary, size: 24);
        }),
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: primary,
            );
          }
          return GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: textSecondary,
          );
        }),
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardTheme(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LionRadius.lg),
          side: const BorderSide(color: border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E1E35),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LionRadius.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LionRadius.md),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LionRadius.md),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LionRadius.md),
          borderSide: const BorderSide(color: LionColors.busy, width: 1.5),
        ),
        hintStyle: GoogleFonts.inter(
          fontSize: 14,
          color: textSecondary,
          fontWeight: FontWeight.w400,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LionRadius.md),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: LionColors.dividerDark,
        thickness: 1,
        space: 0,
      ),
    );
  }
}
