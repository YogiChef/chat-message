import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDark = false;

  bool get isDark => _isDark;

  ThemeProvider() {
    _loadTheme();
  }

  void _loadTheme() async {
    final saveThemeMode = await AdaptiveTheme.getThemeMode();
    _isDark = saveThemeMode == AdaptiveThemeMode.dark;
    notifyListeners();
  }

  void toggleTheme(bool isOn, BuildContext context) {
    _isDark = isOn;
    if (isOn) {
      AdaptiveTheme.of(context).setDark();
    } else {
      AdaptiveTheme.of(context).setLight();
    }
    notifyListeners();
  }
}
