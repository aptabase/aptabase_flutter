abstract class StorageManager {
  Future<void> init() async {}

  Future<Iterable<MapEntry<dynamic, String>>> getItems(int length);

  Future<void> add(String item);

  Future<void> deleteAllKeys(Iterable<dynamic> keys);
}
