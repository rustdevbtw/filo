import 'package:flutter/material.dart';
import 'package:filo/globals.dart';
import '../services/navigator_service.dart';

class Permission {
  final Widget reason;
  final String website;
  final String perm;

  Permission({required this.perm, required this.website, required this.reason});

  String permText() {
    String wb = Uri.parse(website).host;
    Map<String, String> perms = {
      "filo::api::exec": "$wb is trying to execute a command",
      "filo::api::whoami": "$wb is trying to get your username"
    };

    return perms[perm] ?? "Unknown reason";
  }

  Future<bool> check() async {
    bool res = false;
    await showDialog(context: NavigatorService.navigatorKey.currentContext!, builder: (BuildContext ctx) {
      return AlertDialog(
          title: Text(permText()),
          content: reason,
          actions: [
            TextButton(
              onPressed: () {
                res = false;
                Navigator.of(ctx).pop();
              },
              child: Text(
                "Deny",
                style: TextStyle(
                    color: frappe.red
                ),
              ),
            ),
            TextButton(
                onPressed: () {
                  res = true;
                  Navigator.of(ctx).pop();
                },
                child: Text(
                    "Allow",
                    style: TextStyle(
                        color: Theme.of(ctx).colorScheme.onSurface
                    )
                )
            )
          ]
      );
    });

    return res;
  }
}