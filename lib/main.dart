import 'dart:async';
import 'package:flutter/material.dart';
import 'package:window_size/window_size.dart';
import 'package:filo/globals.dart';
import 'package:filo/filo.dart';

Future<void> main() async {
  runApp(const Filo());
  if (isDesktop) {
    setWindowTitle("Filo");
  }
  preferences.init();
}
