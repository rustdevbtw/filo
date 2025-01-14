import 'package:filo/services/navigator_service.dart';
import 'package:filo/utils/sysinfo.dart';
import 'package:filo/api/api.dart';
import 'package:filo/api/special/utility/exec.dart';
import 'package:filo/globals.dart';
import 'package:flutter/material.dart';

String wrapMethod(String name) {
  return '''
    $name = async (...args) => {
      return new Promise((resolve, reject) => {
        sendMsg({method: "$name", args}, (r) => {
          if (r.err) reject(r.err);
          else resolve(r);
        })
      });
    }
    ''';
}

Map<String, Future<ApiResult> Function(List<dynamic> args)> jsFunctions = {
  'navigator.whoami': (List<dynamic> args) async {
    ApiResult apiResult = ApiResult();
    apiResult.result = user();
    return apiResult;
  },
  'navigator.exec': (List<dynamic> args) async {
    ApiResult apiResult = ApiResult();
    if (args.isEmpty) {
      apiResult.error = "ERR_EXEC_CMD_REQUIRED";
      return apiResult;
    }

    String cmd = args[0];

    await showDialog(context: NavigatorService.navigatorKey.currentContext!, builder: (BuildContext ctx) {
      return AlertDialog(
        title: Text("A website is using the exec() API"),
        content: Text.rich(
          TextSpan(
            text: "A website is trying to run the command: ",
            children: <TextSpan>[
              TextSpan(
                text: cmd,
                style: TextStyle(
                  color: Theme.of(ctx).colorScheme.onSecondary
                )
              )
            ],
          )
        ),
        actions: [
          TextButton(
            onPressed: () {
              apiResult.error = "ERR_DENIED";
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
    apiResult.result = await execApi(args[0]);
    return apiResult;
  }
};

final Set<String> methods = jsFunctions.keys.map((String k) {
  return wrapMethod(k);
}).toSet();
