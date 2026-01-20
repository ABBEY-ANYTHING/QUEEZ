import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'locale_provider.g.dart';

class AppLanguage {
  final String code;
  final String name;
  final String nativeName;
  final String flag;

  const AppLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
  });
}

const List<AppLanguage> supportedLanguages = [
  AppLanguage(code: 'en', name: 'English', nativeName: 'English', flag: '🇺🇸'),
  AppLanguage(code: 'es', name: 'Spanish', nativeName: 'Español', flag: '🇪🇸'),
  AppLanguage(code: 'fr', name: 'French', nativeName: 'Français', flag: '🇫🇷'),
  AppLanguage(code: 'de', name: 'German', nativeName: 'Deutsch', flag: '🇩🇪'),
  AppLanguage(code: 'hi', name: 'Hindi', nativeName: 'हिन्दी', flag: '🇮🇳'),
  AppLanguage(code: 'ar', name: 'Arabic', nativeName: 'العربية', flag: '🇸🇦'),
  AppLanguage(code: 'zh', name: 'Chinese', nativeName: '中文', flag: '🇨🇳'),
  AppLanguage(code: 'ja', name: 'Japanese', nativeName: '日本語', flag: '🇯🇵'),
  AppLanguage(
    code: 'pt',
    name: 'Portuguese',
    nativeName: 'Português',
    flag: '🇧🇷',
  ),
  AppLanguage(code: 'ru', name: 'Russian', nativeName: 'Русский', flag: '🇷🇺'),
];

@Riverpod(keepAlive: true)
class LocaleState extends _$LocaleState {
  static const String _localeKey = 'app_locale';

  @override
  Locale build() {
    _init();
    return const Locale('en');
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString(_localeKey);

    if (savedCode == null) return;

    // ✅ only apply if supported
    final isSupported = supportedLanguages.any(
      (lang) => lang.code == savedCode,
    );

    if (isSupported) {
      state = Locale(savedCode);
    } else {
      // fallback: remove invalid saved locale
      await prefs.remove(_localeKey);
      state = const Locale('en');
    }
  }

  Future<void> setLocale(String languageCode) async {
    // ✅ avoid saving invalid language
    final isSupported = supportedLanguages.any(
      (lang) => lang.code == languageCode,
    );

    if (!isSupported) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, languageCode);
    state = Locale(languageCode);
  }

  AppLanguage get currentLanguage {
    return supportedLanguages.firstWhere(
      (lang) => lang.code == state.languageCode,
      orElse: () => supportedLanguages.first,
    );
  }
}
