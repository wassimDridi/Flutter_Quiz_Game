import 'package:flutter/material.dart';
import 'package:quizzz/parameter/app_localizations.dart';

extension LocalizationExtension on String {
  String tr(BuildContext context, {List<String>? args}) {
    String translated = Localizations.of(context, AppLocalizations).translate(this) ?? this;
    if (args != null && args.isNotEmpty) {
      for (int i = 0; i < args.length; i++) {
        translated = translated.replaceAll('{$i}', args[i]);
      }
    }
    return translated;
  }
}

