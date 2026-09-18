import 'package:flutter/material.dart';

class AppTheme {
  // ==== Palet Light Mode (washi paper, merah torii) ====
  static const Color primaryBlue = Color(0xFFBC3B3B); // merah torii
  static const Color deepBlue = Color(0xFF8C2A2A);
  static const Color skyBlue = Color(0xFFC9A44C); // emas
  static const Color softBlue = Color(0xFFFAF3E8);
  static const Color background = Color(0xFFFAF3E8);
  static const Color surface = Colors.white;
  static const Color textDark = Color(0xFF2B2320);
  static const Color textMuted = Color(0xFF8A7B6E);
  static const Color border = Color(0xFFF2C9C9);

  static const Color torii = Color(0xFFBC3B3B);
  static const Color toriiDark = Color(0xFF8C2A2A);
  static const Color washi = Color(0xFFFAF3E8);
  static const Color sakura = Color(0xFFF2C9C9);
  static const Color gold = Color(0xFFC9A44C);

  // ==== Palet Dark Mode (sumi malam, merah torii tetap jadi aksen) ====
  static const Color darkBackground = Color(0xFF1A1512); // sumi gelap
  static const Color darkSurface = Color(0xFF2B2320); // sumi
  static const Color darkTextLight = Color(0xFFF5EDE3); // krem terang
  static const Color darkTextMuted = Color(0xFFA79A8C);
  static const Color darkBorder = Color(0xFF3D332C);
  static const Color darkTorii = Color(
    0xFFD9534F,
  ); // merah torii sedikit lebih terang biar kontras di gelap

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.light,
        primary: primaryBlue,
        secondary: skyBlue,
        surface: surface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textDark,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryBlue, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: border),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dividerTheme: DividerThemeData(color: border),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: darkTorii,
        brightness: Brightness.dark,
        primary: darkTorii,
        secondary: gold,
        surface: darkSurface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: darkTextLight,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: darkTorii, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: darkBorder),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkTorii,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dividerTheme: DividerThemeData(color: darkBorder),
      textTheme: ThemeData.dark().textTheme.apply(
        bodyColor: darkTextLight,
        displayColor: darkTextLight,
      ),
    );
  }
}
