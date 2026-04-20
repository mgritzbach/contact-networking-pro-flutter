import 'package:flutter/material.dart';

const kBackground      = Color(0xFF0C0C0C);
const kCopper          = Color(0xFFC4784A);
const kSurfaceDark     = Color(0xFF141414);
const kSurfaceElevated = Color(0xFF1A1410);
const kCopperContainer = Color(0xFF1E120A);
const kTextPrimary     = Color(0xFFF5F0EB);
const kTextSecondary   = Color(0xFF9E8E80);
const kTextTertiary    = Color(0xFF5C4D44);
const kBorder          = Color(0xFF2A2118);
const kDivider         = Color(0xFF1E1812);
const kErrorRed        = Color(0xFFCF6679);

class AppTheme {
  static ThemeData get theme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: kBackground,
    colorScheme: const ColorScheme.dark(
      primary: kCopper,
      surface: kSurfaceDark,
      background: kBackground,
      error: kErrorRed,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: kBackground,
      foregroundColor: kTextPrimary,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      displayMedium: TextStyle(
        fontFamily: 'serif',
        fontSize: 40,
        fontWeight: FontWeight.w300,
        color: kTextPrimary,
        height: 1.15,
      ),
      headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: kTextPrimary),
      titleLarge:    TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: kTextPrimary),
      titleMedium:   TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kCopper, letterSpacing: 2),
      titleSmall:    TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: kTextPrimary, letterSpacing: 1),
      bodyMedium:    TextStyle(fontSize: 14, color: kTextSecondary),
      bodySmall:     TextStyle(fontSize: 12, color: kTextSecondary),
      labelLarge:    TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 2, color: kTextPrimary),
      labelSmall:    TextStyle(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.5, color: kTextTertiary),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kSurfaceDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: kBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: kBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: kCopper, width: 1.5),
      ),
      labelStyle: const TextStyle(color: kTextTertiary),
      prefixIconColor: kTextTertiary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kCopper,
        foregroundColor: kTextPrimary,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 2),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: kCopper,
        side: const BorderSide(color: kCopper, width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    dividerTheme: const DividerThemeData(color: kDivider, thickness: 1),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: kSurfaceElevated,
      contentTextStyle: const TextStyle(color: kTextPrimary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

// Shared decorations
BoxDecoration cardDecoration({Color? border}) => BoxDecoration(
  color: kSurfaceDark,
  borderRadius: BorderRadius.circular(20),
  border: Border.all(color: border ?? kBorder),
);

BoxDecoration copperCardDecoration() => BoxDecoration(
  color: kCopperContainer,
  borderRadius: BorderRadius.circular(14),
  border: Border.all(color: kCopper.withOpacity(0.35)),
);
