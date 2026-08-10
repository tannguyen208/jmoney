import 'package:web/web.dart' as web;

import 'key_value_store.dart';

Future<KeyValueStore> initializePlatformKeyValueStore() async {
  return _WebKeyValueStore();
}

class _WebKeyValueStore implements KeyValueStore {
  @override
  String? readString(String key) {
    return web.window.localStorage.getItem(key);
  }

  @override
  bool writeString(String key, String value) {
    try {
      web.window.localStorage.setItem(key, value);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  bool remove(String key) {
    try {
      web.window.localStorage.removeItem(key);
      return true;
    } catch (_) {
      return false;
    }
  }
}
