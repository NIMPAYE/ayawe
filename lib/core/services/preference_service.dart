import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferenceService {
  final SharedPreferences _prefs;

  PreferenceService(this._prefs);

  static const String _themeModeKey = 'theme_mode';

  ThemeMode getThemeMode() {
    final String? themeValue = _prefs.getString(_themeModeKey);
    if (themeValue == null) return ThemeMode.system;

    return ThemeMode.values.firstWhere(
      (e) => e.toString() == themeValue,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setString(_themeModeKey, mode.toString());
  }
}
