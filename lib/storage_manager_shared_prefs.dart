import "package:aptabase_flutter/storage_manager.dart";
import "package:shared_preferences/shared_preferences.dart";

class StorageManagerSharedPrefs extends StorageManager {
  final _asyncPrefs = SharedPreferencesAsync();
  var _events = <String, String>{};

  @override
  Future<void> init() async {
    final items = await _asyncPrefs.getAll();
    _events = items.cast<String, String>();

    return super.init();
  }

  @override
  Future<void> addEvent(String key, String event) async {
    _events[key] = event;
    await _asyncPrefs.setString(key, event);
  }

  @override
  Future<void> deleteEvents(Set<String> keys) async {
    _events.removeWhere((k, _) => keys.contains(k));
    await _asyncPrefs.clear(allowList: keys);
  }

  @override
  Future<Iterable<MapEntry<String, String>>> getItems(int length) async {
    return _events.entries.take(length);
  }
}
