import 'package:aptabase_flutter/persistence.dart';
import 'package:aptabase_flutter/src/offline_logic/event_offline.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_memory.dart';

import 'init_service.dart';

void main() async {
  final dbSembast = await databaseFactoryMemory.openDatabase('test.db');
  test('save and get', () async {
    final dbStore = intMapStoreFactory.store('aptabase');
    await dbStore.add(dbSembast, EventOffline.dummy.toMap());
    await dbStore.add(dbSembast, EventOffline.dummy2.toMap());
    // Build our app and trigger a frame.
    final recordSnapshot = await dbStore.find(dbSembast);
    final events =
        recordSnapshot.map((e) => EventOffline.fromMap(e.value)).toList();
    expect(events.length, 2);
    // final events = getAllPersistedEvents(prefs);
    expect(events.last, EventOffline.dummy2);
    await dbStore.delete(dbSembast);
  });

  test('test prevent from saving events if already 100', () async {
    final oneThousandEvents = List<EventOffline>.generate(
        100, (index) => const EventOffline('eventName'));
    final service = TestEventService(dbSembast);
    for (final e in oneThousandEvents) {
      await service.addEvent.request(e);
    }
    final isPersisted = await service.addEvent.request(EventOffline.dummy);
    expect(isPersisted, false);
  });
}
