import 'package:flutter/foundation.dart';

class SettingsProvider with ChangeNotifier {
  bool _isSoundEnabled = true;

  bool get isSoundEnabled => _isSoundEnabled;

  void toggleSound(bool value) {
    _isSoundEnabled = value;
    notifyListeners();
  }
}
