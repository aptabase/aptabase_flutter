import "package:aptabase_flutter/storage_manager.dart";

import "package:hive_flutter/hive_flutter.dart";

class HiveStorage implements StorageManager {
  late final Box<String> _box;

  @override
  Future<void> init() async {
    await Hive.initFlutter();

    _box = await Hive.openBox<String>("aptabase_events");
  }

  @override
  Future<void> deleteAllKeys(Iterable<dynamic> keys) {
    return _box.deleteAll(keys);
  }

  @override
  Future<Iterable<MapEntry<dynamic, String>>> getItems(int length) async {
    return _box.toMap().entries.take(length);
  }

  @override
  Future<void> add(String item) {
    return _box.add(item);
  }
}
