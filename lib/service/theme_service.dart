import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const String _themeKey = 'isDarkMode';

  // Islamic theme colors
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFFF5E6CA), // Cream
    scaffoldBackgroundColor: const Color(0xFFFAF3E0), // Light cream
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF5E6CA), // Cream
      elevation: 0,
      iconTheme: IconThemeData(color: Color(0xFF2D3250)), // Dark navy
      titleTextStyle: TextStyle(
        color: Color(0xFF2D3250),
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    ),
    iconTheme: const IconThemeData(color: Color(0xFF2D3250)), // Dark navy
    cardTheme: CardTheme(
      color: const Color(0xFFF8EEDB), // Slightly darker cream
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFF5E6CA), // Cream
      primary: const Color(0xFF82A284), // Islamic green
      secondary: const Color(0xFFD4B996), // Soft gold
      tertiary: const Color(0xFF2D3250), // Dark navy
    ),
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF2D3250), // Dark navy
    scaffoldBackgroundColor: const Color(0xFF1A1E33), // Darker navy
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF2D3250), // Dark navy
      elevation: 0,
      iconTheme: IconThemeData(color: Color(0xFFF5E6CA)), // Cream
      titleTextStyle: TextStyle(
        color: Color(0xFFF5E6CA),
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    ),
    iconTheme: const IconThemeData(color: Color(0xFFF5E6CA)), // Cream
    cardTheme: CardTheme(
      color: const Color(0xFF3E4566), // Lighter navy
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF2D3250), // Dark navy
      brightness: Brightness.dark,
      primary: const Color(0xFF82A284), // Islamic green
      secondary: const Color(0xFFD4B996), // Soft gold
      tertiary: const Color(0xFFF5E6CA), // Cream
    ),
  );

  // Save theme preference
  static Future<void> saveThemePreference(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDarkMode);
  }

  // Get saved theme preference
  static Future<bool> getThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? false; // Default to light mode
  }
}