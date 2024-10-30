import "package:aptabase_flutter/storage_manager.dart";

import "package:hive_ce_flutter/hive_flutter.dart";

class StorageManagerHive implements StorageManager {
  late final Box<MapEntry<String, String>> _box;

  @override
  Future<void> init() async {
    await Hive.initFlutter();

    _box = await Hive.openBox<MapEntry<String, String>>("aptabase_events");
  }

  @override
  Future<void> deleteEvents(Iterable<String> keys) async {
    await _box.deleteAll(keys);
  }

  @override
  Future<Iterable<MapEntry<String, String>>> getItems(int length) async {
    return _box.values.take(length);
  }

  @override
  Future<void> addEvent(String key, String value) async {
    await _box.add(MapEntry(key, value));
  }
}
