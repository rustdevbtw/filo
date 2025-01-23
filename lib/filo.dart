import 'package:filo/services/navigator_service.dart';
import 'package:flutter/material.dart';
import 'package:filo/globals.dart';
import 'package:filo/ui/theme.dart';
import 'package:filo/pages/home.dart';
import 'package:veil/veil.dart';

class Filo extends StatelessWidget {
  const Filo({super.key});

  @override
  Widget build(BuildContext context) {
    currentTheme.value = checkDarkMode(context);

    return VlApp(
      title: "Filo",
      home: Home(),
      theme: currentTheme,
      showDebugBanner: false,
      navigatorKey: NavigatorService.navigatorKey,
    );
  }
}
