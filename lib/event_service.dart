import 'package:aptabase_flutter/endpoint.dart';
import 'package:aptabase_flutter/event.dart';
import 'package:sembast/sembast.dart';

class EventsService {
  final AddEvent addEvent;
  final GetAllEvents getAllEvents;
  final DeleteEvent deleteEvent;
  EventsService(
    this.addEvent,
    this.getAllEvents,
    this.deleteEvent,
  );
}

class DeleteEvent implements EndpointBase<bool, int> {
  final Database _db;
  const DeleteEvent(this._db);
  @override
  Future<bool> request(int key) async {
    final dbStore = intMapStoreFactory.store('aptabase');
    final keyReturned = await dbStore.record(key).delete(_db);
    return keyReturned != null && keyReturned == key;
  }
}

class AddEvent implements EndpointBase<bool, Event> {
  final Database _db;
  const AddEvent(this._db);
  @override
  Future<bool> request(Event event) async {
    final dbStore = intMapStoreFactory.store('aptabase');
    final count = await dbStore.count(_db);
    if (count < 1000) {
      await dbStore.add(_db, event.toMap());
      return true;
    } else {
      return false;
    }
  }
}

class GetAllEvents
    implements
        EndpointBase<List<RecordSnapshot<int, Map<String, Object?>>>, void> {
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
