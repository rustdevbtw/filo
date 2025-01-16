import 'package:filo/services/navigator_service.dart';
import 'package:flutter/material.dart';
import 'package:filo/globals.dart';
import 'package:filo/ui/theme.dart';
import 'package:filo/pages/home.dart';

class Filo extends StatelessWidget {
  const Filo({super.key});

  @override
  Widget build(BuildContext context) {
    isDarkMode.value = checkDarkMode(context);

    return ValueListenableBuilder<bool>(
      valueListenable: isDarkMode,
      builder: (context, isDarkMode, _) {
        return MaterialApp(
          title: 'Filo',
          theme: isDarkMode
              ? getCatppuccinTheme(frappe)
              : getCatppuccinTheme(latte),
          home: const Home(),
          debugShowCheckedModeBanner: false,
          navigatorKey: NavigatorService.navigatorKey,
        );
      },
    );
  }
}
