import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  //TODO find better fonts. LCD?
  static final ThemeData _lightTheme = ThemeData(colorScheme: const ColorScheme.highContrastLight(), fontFamily: 'Red Hat Mono');
  static final ThemeData _darkTheme = ThemeData(colorScheme: const ColorScheme.highContrastDark(), fontFamily: 'Red Hat Mono');
  static final ThemeData _nightTheme = ThemeData(colorScheme: const ColorScheme.highContrastDark().copyWith(onSurface: Colors.red), fontFamily: 'Red Hat Mono');

  ThemeData __themeData = _darkTheme;

  ThemeData get themeData => __themeData;

  set _themeData (ThemeData themeData) {
    __themeData = themeData;
    notifyListeners();
  }

  void setDarkMode(bool darkMode) {
    _themeData = darkMode ? _darkTheme : _lightTheme;
  }

  void setNightMode() {
    _themeData = _nightTheme;
  }
}
