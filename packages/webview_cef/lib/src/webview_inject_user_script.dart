enum _ScriptInjectTime { LOAD_START, LOAD_END }

class _UserScript {
  String? script;
  _ScriptInjectTime? injectTime;

  _UserScript(this.script, this.injectTime);
}

class _InjectUserScripts {
  List<_UserScript> userScripts = [];

  void add(_UserScript script) {
    userScripts.add(script);
  }

  List<_UserScript> retrieveLoadStartInjectScripts() {
    return userScripts.where((e) => e.injectTime == _ScriptInjectTime.LOAD_START).toList();
  }

  List<_UserScript> retrieveLoadEndInjectScripts() {
    return userScripts.where((e) => e.injectTime == _ScriptInjectTime.LOAD_END).toList();
  }
}