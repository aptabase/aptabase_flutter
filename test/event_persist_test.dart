import 'package:aptabase_flutter/event.dart';
import 'package:aptabase_flutter/event_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_memory.dart';

import 'init_service.dart';

void main() async {
  final db = await databaseFactoryMemory.openDatabase('test.db');
  test('save and get', () async {
    final dbStore = intMapStoreFactory.store('aptabase');
    final int key = await dbStore.add(db, Event.dummy.toMap());
    final int key2 = await dbStore.add(db, Event.dummy2.toMap());
    // Build our app and trigger a frame.
    final recordSnapshot = await dbStore.find(db);
    final events = recordSnapshot.map((e) => Event.fromMap(e.value)).toList();
    expect(events.length, 2);
    // final events = getAllPersistedEvents(prefs);
    expect(events.last, Event.dummy2);
    await dbStore.delete(db);
  });

  test('test prevent from saving events if already too many', () async {
    final oneThousandEvents =
        List<Event>.generate(1000, (index) => const Event('eventName'));
    final service = TestEventService(db);
    for (final e in oneThousandEvents) {
      await service.addEvent.request(e);
    }
    final isPersisted = await service.addEvent.request(Event.dummy);
    expect(isPersisted, false);
  });
}
