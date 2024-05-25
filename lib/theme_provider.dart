import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  //TODO find better fonts. LCD?
  static final ThemeData lightTheme = ThemeData(colorScheme: const ColorScheme.highContrastLight(), fontFamily: 'Red Hat Mono');
  static final ThemeData darkTheme = ThemeData(colorScheme: const ColorScheme.highContrastDark(), fontFamily: 'Red Hat Mono');
  static final ThemeData nightTheme = ThemeData(colorScheme: const ColorScheme.highContrastDark().copyWith(onSurface: Colors.red), fontFamily: 'Red Hat Mono');

  ThemeData _themeData = nightTheme;

  ThemeData get themeData => _themeData;

  set themeData (ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }
}
