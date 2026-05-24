import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';

class LocaleService extends ChangeNotifier {
  static final LocaleService instance = LocaleService._internal();
  LocaleService._internal();

  Locale? _currentLocale; // Null indicates "System"

  Locale get currentLocale {
    if (_currentLocale != null) return _currentLocale!;
    return PlatformDispatcher.instance.locale;
  }

  bool get isSystemLocale => _currentLocale == null;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('language') ?? 'system';
    if (langCode == 'en') {
      _currentLocale = const Locale('en');
    } else if (langCode == 'zh') {
      _currentLocale = const Locale('zh');
    } else if (langCode == 'zh_TW') {
      _currentLocale = const Locale('zh', 'TW');
    } else {
      _currentLocale = null; // System
    }
    notifyListeners();
  }

  Future<void> setLocale(Locale? locale) async {
    _currentLocale = locale;
    final String langCode;
    if (locale == null) {
      langCode = 'system';
    } else if (locale.languageCode == 'en') {
      langCode = 'en';
    } else if (locale.languageCode == 'zh' && (locale.countryCode == null || locale.countryCode!.isEmpty)) {
      langCode = 'zh';
    } else {
      langCode = 'zh_TW';
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', langCode);
    notifyListeners();
  }
}
