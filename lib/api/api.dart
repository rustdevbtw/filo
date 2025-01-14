import 'dart:convert';

class ApiResult {
  String? res;
  String? err;

  set result(dynamic d) {
    res = jsonEncode(d);
  }

  set error(String s) {
    err = jsonEncode({"error": s});
  }

  String get out {
    if (err != null) {
      return err!;
    } else {
      return res!;
    }
  }
}
