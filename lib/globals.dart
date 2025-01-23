import 'dart:io';
import 'package:catppuccin_flutter/catppuccin_flutter.dart';
import 'package:filo/pages/home.dart';
import 'package:filo/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:filo/utils/prefs.dart';
import 'package:veil/veil.dart';

// Global Variables
final Preferences preferences = Preferences();
final IconData iconLight = Icons.wb_sunny;
final IconData iconDark = Icons.nights_stay;
final ValueNotifier<bool> isDarkMode = ValueNotifier(true);
final ValueNotifier<String> qrScanResult =
    ValueNotifier("Press on the Scan button to continue");
final bool isMobile = Platform.isAndroid || Platform.isIOS;
final bool isDesktop =
    Platform.isLinux || Platform.isWindows || Platform.isMacOS;
final Flavor frappe = catppuccin.frappe;
final Flavor latte = catppuccin.latte;
final ThemeData darkTheme = getCatppuccinTheme(frappe);
final ThemeData lightTheme = getCatppuccinTheme(latte);
final VlTheme currentTheme = VlTheme(darkTheme);
final String initialUrl = "https://flutter.dev";
final ValueNotifier<String> currentUrl = ValueNotifier(initialUrl);
final homeKey = GlobalKey<HomeState>();
