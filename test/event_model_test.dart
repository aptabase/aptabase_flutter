import 'package:aptabase_flutter/src/offline_logic/event_offline.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('PersistEvent serialization dummy1', () {
    final json = EventOffline.dummy.toJson();
    final fromJson = EventOffline.fromJson(json);
    expect(fromJson, EventOffline.dummy);
  });
  test('PersistEvent serialization dummy2', () {
    final json = EventOffline.dummy2.toJson();
    final fromJson = EventOffline.fromJson(json);
    expect(fromJson, EventOffline.dummy2);
  });
}
