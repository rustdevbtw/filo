import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  SharedPreferences? _preferences;

  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  bool? getBool(String key) {
    return _preferences?.getBool(key);
  }

  String? getString(String key) {
    return _preferences?.getString(key);
  }

  int? getInt(String key) {
    return _preferences?.getInt(key);
  }

  Future<void> setBool(String key, bool b) async {
    await _preferences?.setBool(key, b);
  }

  Future<void> setString(String key, String s) async {
    await _preferences?.setString(key, s);
  }

  Future<void> setInt(String key, int d) async {
    await _preferences?.setInt(key, d);
  }
}
