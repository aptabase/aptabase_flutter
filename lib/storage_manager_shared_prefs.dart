import "package:aptabase_flutter/storage_manager.dart";
import "package:shared_preferences/shared_preferences.dart";

class StorageManagerSharedPrefs extends StorageManager {
  static const _keyPrefix = "aptabase_";

  final _events = <String, String>{};
  late final SharedPreferences _prefs;

  @override
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final keys = _prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_keyPrefix)) {
        final value = _prefs.getString(key);
        if (value != null) {
          final unprefixedKey = key.substring(_keyPrefix.length);
          _events[unprefixedKey] = value;
        }
      }
    }

    return super.init();
  }

  @override
  Future<void> addEvent(String key, String event) async {
    try {
      final success = await _prefs.setString("$_keyPrefix$key", event);

      if (success) {
        _events[key] = event;
      }
    } catch (e) {
      // If persistence fails, don't add to in-memory cache to maintain consistency
      rethrow;
    }
  }

  @override
  Future<void> deleteEvents(Set<String> keys) async {
    // Remove from in-memory cache first since events were already sent
    _events.removeWhere((k, _) => keys.contains(k));

    try {
      for (final key in keys) {
        await _prefs.remove("$_keyPrefix$key");
      }
    } catch (e) {
      // Events were already sent successfully and removed from memory.
      // Disk cleanup failure is not critical - orphaned keys will be cleaned
      // up on next init if they still exist.
      // Silently catch to avoid disrupting the event sending flow.
    }
  }

  @override
  Future<Iterable<MapEntry<String, String>>> getItems(int length) async {
    return _events.entries.take(length);
  }
}
