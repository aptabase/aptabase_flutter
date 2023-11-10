import 'package:aptabase_flutter/persist_event.dart';
import 'package:aptabase_flutter/shared_prefs.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  SharedPreferences.setMockInitialValues({});
  test('save and get', () async {
    // Build our app and trigger a frame.
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await persistIt(prefs, Event.dummy);
    await persistIt(prefs, Event.dummy2);
    final keys = prefs.getKeys();
    expect(keys.length, 2);
    final events = getAllPersistedEvents(prefs);
    expect(events.length, 2);
    expect(events.orderAsc.last, Event.dummy2);
    await prefs.clear();
  });

  test('test prevent from saving events if already too many', () async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final oneThousandEvents = List<Event>.generate(1000,
        (index) => Event('eventName', DateTime(2000, 1, 1, 12, 30, index)));

    for (final e in oneThousandEvents) {
      await persistIt(prefs, e);
    }
    final isPersisted = await persistIt(prefs, Event.dummy);
    expect(isPersisted, false);
  });
}
