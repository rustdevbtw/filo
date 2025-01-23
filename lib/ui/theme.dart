// Theme Functions
import 'package:catppuccin_flutter/catppuccin_flutter.dart';
import 'package:filo/globals.dart';
import 'package:flutter/material.dart';

ThemeData getCatppuccinTheme(Flavor flavor) {
  return ThemeData(
    useMaterial3: true,
    appBarTheme: AppBarTheme(
      elevation: 0,
      titleTextStyle: TextStyle(
        color: flavor.text,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      backgroundColor: flavor.crust,
      foregroundColor: flavor.mantle,
    ),
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      error: flavor.surface2,
      onError: flavor.red,
      onPrimary: flavor.sapphire,
      onSecondary: flavor.subtext0,
      onSurface: flavor.text,
      primary: flavor.crust,
      secondary: flavor.mantle,
      surface: flavor.surface0,
    ),
    textTheme: const TextTheme().apply(
      bodyColor: flavor.text,
      displayColor: flavor.sapphire,
    ),
    textSelectionTheme: TextSelectionThemeData(selectionColor: flavor.overlay0),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      elevation: 0,
    ),
    fontFamily: 'Cas',
  );
}

ThemeData checkDarkMode(BuildContext ctx) {
  return (preferences.getBool("filo.ui.is_dark_theme") ??
      MediaQuery.of(ctx).platformBrightness == Brightness.dark) ? darkTheme : lightTheme;
}

void changeTheme() {
  currentTheme.value = (currentTheme.value == darkTheme) ? lightTheme : darkTheme;
  preferences.setBool("filo.ui.is_dark_theme", (currentTheme.value == darkTheme));
}
