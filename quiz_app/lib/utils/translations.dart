import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/providers/locale_provider.dart';
import 'package:quiz_app/utils/app_strings.dart';

/// A simple extension to translate strings using the current locale
/// Usage: 'settings'.tr(ref) or tr('settings', ref)
extension TranslateString on String {
  String tr(WidgetRef ref) {
    final locale = ref.watch(localeStateProvider);
    return AppStrings.get(this, locale.languageCode);
  }
}

/// Global translation function for use in widgets
String tr(String key, WidgetRef ref) {
  final locale = ref.watch(localeStateProvider);
  return AppStrings.get(key, locale.languageCode);
}

/// A translated text widget that automatically updates when language changes
class TrText extends ConsumerWidget {
  final String textKey;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const TrText(
    this.textKey, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeStateProvider);
    return Text(
      AppStrings.get(textKey, locale.languageCode),
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
