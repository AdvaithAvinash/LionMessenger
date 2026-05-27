import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  bool _isInitialized = false;

  ThemeMode get themeMode => _themeMode;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString('theme_mode') ?? 'dark';
    _themeMode = savedTheme == 'light' ? ThemeMode.light : ThemeMode.dark;
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _themeMode =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'theme_mode',
      _themeMode == ThemeMode.dark ? 'dark' : 'light',
    );
    notifyListeners();
  }

  bool get isDark => _themeMode == ThemeMode.dark;
}
