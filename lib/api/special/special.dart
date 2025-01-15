import 'package:filo/services/navigator_service.dart';
import 'package:filo/utils/sysinfo.dart';
import 'package:filo/api/api.dart';
import 'package:filo/api/special/utility/exec.dart';
import 'package:filo/globals.dart';
import 'package:flutter/material.dart';
import 'package:filo/utils/permission.dart';

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
  'window.alert': (List<dynamic> args) async {
    ApiResult apiResult = ApiResult();
    final wb = Uri.parse(currentUrl.value).host;
    Widget s = await showDialog(
        context: NavigatorService.navigatorKey.currentContext!,
        builder: (ctx) => AlertDialog(
              title: Text(wb),
              content: Text(args[0]),
              actions: <Widget>[
                TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    child: Text(
                      "OK",
                      style:
                          TextStyle(color: Theme.of(ctx).colorScheme.onSurface),
                    ))
              ],
            ));
    apiResult.result = s.hashCode;
    return apiResult;
  },
  'navigator.exec': (List<dynamic> args) async {
    ApiResult apiResult = ApiResult();
    if (args.isEmpty) {
      apiResult.error = "ERR_EXEC_CMD_REQUIRED";
      return apiResult;
    }

    String cmd = args[0];

    Permission perm = Permission(
        perm: "filo::api::exec",
        website: currentUrl.value,
        reason: Text.rich(TextSpan(
          text: "The website is trying to run the command: ",
          children: <TextSpan>[
            TextSpan(
                text: cmd,
                style: TextStyle(
                    color:
                        Theme.of(NavigatorService.navigatorKey.currentContext!)
                            .colorScheme
                            .onSecondary))
          ],
        )));

    bool allowed = await perm.check();

    if (allowed) {
      apiResult.result = await execApi(args[0]);
    } else {
      apiResult.error = "PERMISSION_DENIED";
    }

    return apiResult;
  }
};

final Set<String> methods = jsFunctions.keys.map((String k) {
  return wrapMethod(k);
}).toSet();
