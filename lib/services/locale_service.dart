import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleService extends ChangeNotifier {
  static final LocaleService instance = LocaleService._internal();
  LocaleService._internal();

  Locale _currentLocale = const Locale('zh', 'TW');

  Locale get currentLocale => _currentLocale;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('language') ?? 'zh_TW';
    _currentLocale = langCode == 'en' 
        ? const Locale('en') 
        : const Locale('zh', 'TW');
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    final String langCode = locale.languageCode == 'en' ? 'en' : 'zh_TW';
    if (langCode == 'en') {
      _currentLocale = const Locale('en');
    } else {
      _currentLocale = const Locale('zh', 'TW');
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', langCode);
    notifyListeners();
  }
}
