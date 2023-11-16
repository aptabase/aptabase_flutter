import 'package:aptabase_flutter/src/offline_logic/event_offline.dart';
import 'package:aptabase_flutter/src/offline_logic/services/sembast_wrapper.dart';
import 'package:aptabase_flutter/src/offline_logic/services_asbtract/events_service_abstract.dart';
import 'package:sembast/sembast.dart';

class EventsServiceSembast extends EventsServiceAbstract {
  EventsServiceSembast(
    AddEvent addEvent,
    GetAllEvents getAllEvents,
    DeleteEvent deleteEvent,
    RemoveObsoleteLinesFromDb removeObsoleteLinesFromDb,
  ) : super(addEvent, getAllEvents, deleteEvent, removeObsoleteLinesFromDb);
}

class AddEvent extends AddEventAbstract {
  final DbMetrics _db;
  static const maxNumberEventsPersistedByDefault = 100;
  final int? maxNumberEventsPersisted;
  int get _maxNumberEvents =>
      maxNumberEventsPersisted ?? maxNumberEventsPersistedByDefault;
  const AddEvent(this._db, {this.maxNumberEventsPersisted});

  @override
  Future<bool> request(EventOffline event) async {
    final dbStore = intMapStoreFactory.store('aptabase');
    final count = await dbStore.count(_db.db);
    if (count < _maxNumberEvents) {
      await dbStore.add(_db.db, event.toMap());
      return true;
    } else {
      return false;
    }
  }
}

class GetAllEvents extends GetAllEventsAbstract {
  final DbMetrics _db;
  const GetAllEvents(this._db);
  @override
  Future<List<RecordSnapshot<int, Map<String, Object?>>>> request(
      void data) async {
    final dbStore = intMapStoreFactory.store('aptabase');
    final recordSnapshot = await dbStore.find(_db.db);
    if (recordSnapshot.isNotEmpty) {
      return recordSnapshot;
    } else {
      return [];
    }
  }
}

class DeleteEvent extends DeleteEventAbstract {
  final DbMetrics _db;
  const DeleteEvent(this._db);
  @override
  Future<bool> request(int key) async {
    final dbStore = intMapStoreFactory.store('aptabase');
    final keyReturned = await dbStore.record(key).delete(_db.db);
    return keyReturned != null && keyReturned == key;
  }
}

class RemoveObsoleteLinesFromDb extends RemoveObsoleteLinesFromDbAbstract {
  final DbMetrics _db;
  const RemoveObsoleteLinesFromDb(this._db);

  @override
  Future<void> request(void _) async {
    await _db.db.compact();
    return;
  }
}
