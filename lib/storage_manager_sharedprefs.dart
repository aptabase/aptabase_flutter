import "package:aptabase_flutter/random_string.dart";
import "package:aptabase_flutter/storage_manager.dart";
import "package:shared_preferences/shared_preferences.dart";

class SharedPrefsStorage extends StorageManager {
  @override
  Future<void> deleteAllKeys(Iterable<dynamic> keys) async {
    final prefs = await SharedPreferences.getInstance();

    for (final key in keys) {
      await prefs.remove(key);
    }
  }

  @override
  Future<Iterable<MapEntry<dynamic, String>>> getItems(int length) async {
    final prefs = await SharedPreferences.getInstance();

    final items = <MapEntry<dynamic, String>>[];

    for (final key in prefs.getKeys().take(length)) {
      final value = prefs.getString(key);
      if (value == null) continue;
      items.add(MapEntry(key, value));
    }

    return items;
  }

  @override
  Future<void> add(String item) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(RandomString.randomize(), item);
  }
}
