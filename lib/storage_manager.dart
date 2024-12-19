abstract class StorageManager {
  Future<void> init() async {}

  Future<Iterable<MapEntry<String, String>>> getItems(int length);

  Future<void> addEvent(String key, String event);

  Future<void> deleteEvents(Set<String> keys);
}
