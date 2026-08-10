import 'package:mmkv/mmkv.dart';

import 'key_value_store.dart';

Future<KeyValueStore> initializePlatformKeyValueStore() async {
  await MMKV.initialize();
  return _MMKVKeyValueStore();
}

class _MMKVKeyValueStore implements KeyValueStore {
  _MMKVKeyValueStore() : _mmkv = MMKV('jmoney.finance');

  final MMKV _mmkv;

  @override
  String? readString(String key) => _mmkv.decodeString(key);

  @override
  bool writeString(String key, String value) => _mmkv.encodeString(key, value);

  @override
  bool remove(String key) {
    try {
      _mmkv.removeValue(key);
      return true;
    } catch (_) {
      return false;
    }
  }
}
