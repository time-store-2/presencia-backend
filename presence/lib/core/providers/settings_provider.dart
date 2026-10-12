import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../themes/app_themes.dart';

class SettingsProvider with ChangeNotifier {
  AppThemeType _themeType = AppThemeType.warmCommunity;
  Locale _locale = const Locale('fr');

  AppThemeType get themeType => _themeType;
  Locale get locale => _locale;

  SettingsProvider() {
    _loadSettings();
  }

  void setTheme(AppThemeType type) async {
    _themeType = type;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_type', type.name);
  }

  void setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    final savedTheme = prefs.getString('theme_type');
    if (savedTheme != null) {
      _themeType = AppThemeType.values.firstWhere(
        (e) => e.name == savedTheme,
        orElse: () => AppThemeType.warmCommunity,
      );
    }

    final savedLanguage = prefs.getString('language_code');
    if (savedLanguage != null) {
      _locale = Locale(savedLanguage);
    }
    
    notifyListeners();
  }

  ThemeData get currentTheme {
    switch (_themeType) {
      case AppThemeType.auraLuxury:
        return AppThemes.auraLuxury();
      case AppThemeType.etherealSerenity:
        return AppThemes.etherealSerenity();
      case AppThemeType.warmCommunity:
      default:
        return AppThemes.warmCommunity();
    }
  }
}
