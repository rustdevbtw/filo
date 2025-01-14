import 'package:filo/utils/sysinfo.dart';
import 'package:filo/api/api.dart';
import 'package:filo/api/special/utility/exec.dart';

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
    apiResult.result = await execApi(args[0]);
    return apiResult;
  },
  'navigator.isFilo': (List<dynamic> args) async {
    ApiResult apiResult = ApiResult();
    apiResult.result = true;
    return apiResult;
  },
};

final Set<String> methods = jsFunctions.keys.map((String k) {
  return wrapMethod(k);
}).toSet();
