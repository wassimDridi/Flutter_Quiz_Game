import 'package:flutter/material.dart';
import 'package:quizzz/parameter/app_localizations.dart';

extension Translate on String {
  String tr(BuildContext context) {
    return AppLocalizations.of(context)!.translate(this);
  }

  String trWithArgs(BuildContext context, Map<String, dynamic> args) {
    return AppLocalizations.of(context)!.translateWithArgs(this, args);
  }
}
