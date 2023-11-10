import 'package:aptabase_flutter/persist_event.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  SharedPreferences.setMockInitialValues({});
  test('Counter increments smoke test', () async {
    // Build our app and trigger a frame.
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(PersistEvent.dummy.dateCreation.toIso8601String(),
        PersistEvent.dummy.toJson());
    prefs.setString(PersistEvent.dummy2.dateCreation.toIso8601String(),
        PersistEvent.dummy2.toJson());
    final keys = prefs.getKeys();
    expect(keys.length, 2);
    final events = <PersistEvent>[];
    for (final key in keys) {
      final eventRaw = prefs.getString(key);
      if (eventRaw != null) {
        final event = PersistEvent.fromJson(eventRaw);
        events.add(event);
      }
    }
    expect(events.length, 2);
    expect(events.orderAsc.last, PersistEvent.dummy2);
  });
}
