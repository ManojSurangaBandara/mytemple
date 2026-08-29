import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _prefKey = 'app_language_code';
  Locale _locale = const Locale('si'); // Default to Sinhala for Sri Lankan Buddhist Temples

  Locale get locale => _locale;
  bool get isSinhala => _locale.languageCode == 'si';

  LanguageProvider() {
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString(_prefKey);
    if (savedCode != null && (savedCode == 'en' || savedCode == 'si')) {
      _locale = Locale(savedCode);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale newLocale) async {
    if (_locale == newLocale) return;
    _locale = newLocale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, newLocale.languageCode);
  }

  Future<void> toggleLanguage() async {
    if (isSinhala) {
      await setLocale(const Locale('en'));
    } else {
      await setLocale(const Locale('si'));
    }
  }
}
