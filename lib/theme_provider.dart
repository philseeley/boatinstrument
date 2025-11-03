import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  static final ThemeData _lightTheme = ThemeData(colorScheme: const ColorScheme.highContrastLight(), fontFamily: 'Red Hat Mono');
  static final ThemeData _darkTheme = ThemeData(colorScheme: const ColorScheme.highContrastDark(), fontFamily: 'Red Hat Mono');
  static final ThemeData _nightTheme = ThemeData(colorScheme: const ColorScheme.highContrastDark().copyWith(onSurface: Colors.red, onSurfaceVariant: Colors.red), fontFamily: 'Red Hat Mono');

  ThemeData __themeData = _darkTheme;

  ThemeData get themeData => __themeData;

  set _themeData (ThemeData themeData) {
    __themeData = themeData;
    notifyListeners();
  }

  void setDarkMode(bool on) {
    _themeData = on ? _darkTheme : _lightTheme;
  }

  void toggleNightMode(bool darkMode) {
    if(themeData == _nightTheme) {
      setDarkMode(darkMode);
    } else {
      _themeData = _nightTheme;
    }
  }

  void setNightMode(bool darkMode, bool on) {
    if(on) {
      _themeData = _nightTheme;
    } else {
      setDarkMode(darkMode);
    }
  }
}
