import "package:aptabase_flutter/storage_manager.dart";
import "package:shared_preferences/shared_preferences.dart";

class StorageManagerSharedPrefs extends StorageManager {
  final _events = <String, String>{};

  @override
  Future<void> init() async {
    final sharedPrefs = await SharedPreferences.getInstance();
    final keys = sharedPrefs.getKeys();
    for (final key in keys) {
      final value = sharedPrefs.getString(key);
      if (value != null) _events[key] = value;
    }

    return super.init();
  }

  @override
  Future<void> addEvent(String key, String event) async {
    _events[key] = event;

    final sharedPrefs = await SharedPreferences.getInstance();
    await sharedPrefs.setString(key, event);
  }

  @override
  Future<void> deleteEvents(Set<String> keys) async {
    _events.removeWhere((k, _) => keys.contains(k));

    final sharedPrefs = await SharedPreferences.getInstance();
    for (final key in keys) {
      await sharedPrefs.remove(key);
    }
  }

  @override
  Future<Iterable<MapEntry<String, String>>> getItems(int length) async {
    return _events.entries.take(length);
  }
}
