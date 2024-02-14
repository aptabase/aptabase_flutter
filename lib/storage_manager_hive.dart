library aptabase_flutter;

import 'dart:io';

import 'package:aptabase_flutter/storage_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

class HiveStorage implements StorageManager {
  late final Box<String> _box;

  @override
  Future<void> init() async {
    if (!kIsWeb) Hive.init(Directory.current.path);

    _box = await Hive.openBox<String>('aptabase_events');
  }

  @override
  Future<void> deleteAllKeys(Iterable<dynamic> keys) {
    return _box.deleteAll(keys);
  }

  @override
  Iterable<MapEntry<dynamic, String>> getItems(int length) {
    return _box.toMap().entries.take(length);
  }

  @override
  Future<int> add(String item) {
    return _box.add(item);
  }
}
