import 'package:aptabase_flutter/persist_event.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('PersistEvent serialization', () {
    final json = PersistEvent.dummy.toJson();
    final fromJson = PersistEvent.fromJson(json);
    expect(fromJson, PersistEvent.dummy);
  });
  test('PersistEvents ordering', () {
    final pEventList = [PersistEvent.dummy2, PersistEvent.dummy];
    pEventList.orderAsc;
    expect(pEventList.orderAsc.first, PersistEvent.dummy);
  });
}
