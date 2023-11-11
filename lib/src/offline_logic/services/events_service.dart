import 'package:aptabase_flutter/src/offline_logic/services/endpoint_base_abstract.dart';
import 'package:aptabase_flutter/src/offline_logic/event_offline.dart';
import 'package:aptabase_flutter/src/offline_logic/services/events_service_abstract.dart';
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
  final Database _db;
  static const maxNumberEventsPersistedByDefault = 100;
  final int? maxNumberEventsPersisted;
  int get _maxNumberEvents =>
      maxNumberEventsPersisted ?? maxNumberEventsPersistedByDefault;
  const AddEvent(this._db, {this.maxNumberEventsPersisted});

  @override
  Future<bool> request(EventOffline event) async {
    final dbStore = intMapStoreFactory.store('aptabase');
    final count = await dbStore.count(_db);
    if (count < _maxNumberEvents) {
      await dbStore.add(_db, event.toMap());
      return true;
    } else {
      return false;
    }
  }
}

class GetAllEvents extends GetAllEventsAbstract {
  final Database _db;
  const GetAllEvents(this._db);
  @override
  Future<List<RecordSnapshot<int, Map<String, Object?>>>> request(
      void data) async {
    final dbStore = intMapStoreFactory.store('aptabase');
    final recordSnapshot = await dbStore.find(_db);
    if (recordSnapshot.isNotEmpty) {
      return recordSnapshot;
    } else {
      return [];
    }
  }
}

class DeleteEvent extends DeleteEventAbstract {
  final Database _db;
  const DeleteEvent(this._db);
  @override
  Future<bool> request(int key) async {
    final dbStore = intMapStoreFactory.store('aptabase');
    final keyReturned = await dbStore.record(key).delete(_db);
    return keyReturned != null && keyReturned == key;
  }
}

class RemoveObsoleteLinesFromDb extends RemoveObsoleteLinesFromDbAbstract {
  final Database _db;
  const RemoveObsoleteLinesFromDb(this._db);

  @override
  Future<void> request(void _) async {
    await _db.compact();
  }
}
