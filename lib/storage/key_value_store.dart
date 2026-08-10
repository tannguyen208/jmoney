abstract interface class KeyValueStore {
  String? readString(String key);

  bool writeString(String key, String value);

  bool remove(String key);
}

class MemoryKeyValueStore implements KeyValueStore {
  final Map<String, String> _values = {};

  @override
  String? readString(String key) => _values[key];

  @override
  bool writeString(String key, String value) {
    _values[key] = value;
    return true;
  }

  @override
  bool remove(String key) {
    _values.remove(key);
    return true;
  }
}
