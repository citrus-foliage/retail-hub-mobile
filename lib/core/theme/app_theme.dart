import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  static const Color background   = Color(0xFFF5F0E8);
  static const Color primaryText  = Color(0xFF2C2C2C);
  static const Color mutedText    = Color(0xFF8C8070);
  static const Color saleRed      = Color(0xFF8B2E2E);
  static const Color stockGreen   = Color(0xFF4A6741);
  static const Color cardBg       = Color(0xFFEDE8DF);
  static const Color border       = Color(0xFFE0D8CC);
  static const Color white        = Color(0xFFFFFFFF);

  static const Color adminAccent  = Color(0xFF5C4A32);
  static const Color consumerAccent = Color(0xFF2C2C2C);
}

class AppTextStyles {
  AppTextStyles._();

  static TextStyle heading1() => GoogleFonts.cormorantGaramond(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryText,
    letterSpacing: 0.3,
  );

  static TextStyle heading2() => GoogleFonts.cormorantGaramond(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryText,
    letterSpacing: 0.2,
  );

  static TextStyle heading3() => GoogleFonts.cormorantGaramond(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryText,
  );

  static TextStyle label() => const TextStyle(
    fontFamily: 'Inter',
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.4,
    color: AppColors.mutedText,
  );

  static TextStyle body() => const TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    color: AppColors.primaryText,
    height: 1.5,
  );

  static TextStyle bodySmall() => const TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    color: AppColors.mutedText,
    height: 1.4,
  );

  static TextStyle price() => GoogleFonts.cormorantGaramond(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryText,
  );

  static TextStyle priceStrike() => GoogleFonts.cormorantGaramond(
    fontSize: 16,
    color: AppColors.mutedText,
    decoration: TextDecoration.lineThrough,
  );
}

class AppTheme {
  AppTheme._();

  static ThemeData consumerTheme() {
    return _base(AppColors.consumerAccent);
  }

  static ThemeData adminTheme() {
    return _base(AppColors.adminAccent).copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.adminAccent,
        foregroundColor: AppColors.white,
        titleTextStyle: GoogleFonts.cormorantGaramond(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
          letterSpacing: 0.5,
        ),
        elevation: 0,
        centerTitle: true,
      ),
    );
  }

  static ThemeData _base(Color accent) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: accent,
        onPrimary: AppColors.white,
        secondary: AppColors.mutedText,
        onSecondary: AppColors.white,
        error: AppColors.saleRed,
        onError: AppColors.white,
        surface: AppColors.background,
        onSurface: AppColors.primaryText,
      ),
      scaffoldBackgroundColor: AppColors.background,
      cardTheme: CardThemeData(
        color: AppColors.cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerColor: AppColors.border,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: accent, width: 1.5),
        ),
        labelStyle: AppTextStyles.label(),
        hintStyle: AppTextStyles.bodySmall(),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.primaryText,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.cormorantGaramond(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryText,
          letterSpacing: 0.5,
        ),
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.cardBg,
        selectedItemColor: accent,
        unselectedItemColor: AppColors.mutedText,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 10,
          letterSpacing: 0.5,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: accent,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.primaryText,
        contentTextStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          color: AppColors.white,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        behavior: SnackBarBehavior.floating,
      ),
    );
    return base;
  }
}