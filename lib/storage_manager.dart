abstract class StorageManager {
  Future<void> init();

  Future<int> add(String item);

  Iterable<MapEntry<dynamic, String>> getItems(int length);

  Future<void> deleteAllKeys(Iterable<dynamic> keys);
}
