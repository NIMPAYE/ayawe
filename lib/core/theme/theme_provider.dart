import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../services/preference_service.dart';

class ThemeProvider extends ChangeNotifier {
  final PreferenceService _preferenceService;
  ThemeMode _themeMode = ThemeMode.system;

  ThemeProvider(this._preferenceService) {
    _loadTheme();
  }

  ThemeMode get themeMode => _themeMode;

  bool get isDark {
    if (_themeMode == ThemeMode.system) {
      return SchedulerBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  void _loadTheme() {
    _themeMode = _preferenceService.getThemeMode();
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    await _preferenceService.setThemeMode(mode);
    notifyListeners();
  }

  void toggleTheme() {
    setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
  }
}
