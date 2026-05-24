import 'package:flutter/material.dart';

const Map<String, String> nativeLanguageNames = {
  'de': 'Deutsch',
  'de_DE': 'Deutsch',
  'en': 'English',
  'en_AU': 'English (Australia)',
  'en_CA': 'English',
  'en_GB': 'English (UK)',
  'en_SG': 'English (Singapore)',
  'en_US': 'English',
  'fil': 'Tagalog / Filipino',
  'fr': 'Français',
  'fr_FR': 'Français',
  'id': 'Bahasa Indonesia',
  'id_ID': 'Bahasa Indonesia',
  'ja': '日本語',
  'ja_JP': '日本語',
  'ko': '한국어',
  'ko_KR': '한국어',
  'ms': 'Bahasa Melayu',
  'ms_MY': 'Bahasa Melayu',
  'th': 'ไทย',
  'th_TH': 'ไทย',
  'tl': 'Tagalog / Filipino',
  'vi': 'Tiếng Việt',
  'vi_VN': 'Tiếng Việt',
  'zh': '简体中文',
  'zh_CN': '简体中文',
  'zh_HK': '繁體中文 (香港)',
  'zh_MO': '繁體中文 (澳門)',
  'zh_SG': '简体中文 (新加坡)',
  'zh_TW': '正體中文',
};

String getNativeLanguageName(Locale locale) {
  final String fullCode = locale.countryCode != null && locale.countryCode!.isNotEmpty
      ? '${locale.languageCode}_${locale.countryCode}'
      : locale.languageCode;
  
  if (nativeLanguageNames.containsKey(fullCode)) {
    return nativeLanguageNames[fullCode]!;
  }
  
  if (nativeLanguageNames.containsKey(locale.languageCode)) {
    return nativeLanguageNames[locale.languageCode]!;
  }
  
  return locale.languageCode;
}
