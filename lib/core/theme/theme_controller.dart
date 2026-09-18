import 'package:flutter/material.dart';

/// Pengatur tema global aplikasi (light/dark).
/// Dipakai sebagai singleton supaya bisa diakses dari mana saja
/// (misal dari ProfileScreen) tanpa perlu package state management.
class ThemeController {
  ThemeController._();
  static final ThemeController instance = ThemeController._();

  /// Dengarkan ini di MaterialApp lewat ValueListenableBuilder.
  final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.light);

  bool get isDarkMode => themeMode.value == ThemeMode.dark;

  void toggleTheme(bool enableDark) {
    themeMode.value = enableDark ? ThemeMode.dark : ThemeMode.light;
  }
}
