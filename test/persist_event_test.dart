import 'package:aptabase_flutter/persist_event.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('PersistEvent serialization dummy1', () {
    final json = Event.dummy.toJson();
    final fromJson = Event.fromJson(json);
    expect(fromJson, Event.dummy);
  });
  test('PersistEvent serialization dummy2', () {
    final json = Event.dummy2.toJson();
    final fromJson = Event.fromJson(json);
    expect(fromJson, Event.dummy2);
  });
  test('PersistEvents ordering', () {
    final pEventList = [Event.dummy2, Event.dummy];
    pEventList.orderAsc;
    expect(pEventList.orderAsc.first, Event.dummy);
  });
}
