import 'dart:ui';
import 'package:flutter/material.dart';

Future<OverlayEntry> openOverlay({
  required BuildContext context,
  required Widget child,
}) async {
  final overlay = Overlay.of(context);

  // Create the overlay entry
  late OverlayEntry overlayEntry;
  overlayEntry = OverlayEntry(
      builder: (context) => Actions(
              actions: <Type, Action<Intent>>{
                DismissIntent: CallbackAction<DismissIntent>(
                    onInvoke: (DismissIntent intent) {
                  overlayEntry.remove();
                  return null;
                })
              },
              child: Stack(
                children: [
                  // Semi-transparent background over the existing content
                  GestureDetector(
                    onTap: () {
                      // Dismiss the overlay when tapping outside
                      overlayEntry.remove();
                    },
                  ),
                  // Centered overlay content
                  Center(
                    child: Material(
                      color: Colors.transparent,
                      child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                          child: Center(child: child)),
                    ),
                  ),
                ],
              )),
      canSizeOverlay: true);

  // Insert the overlay entry
  overlay.insert(overlayEntry);

  return overlayEntry;
}
