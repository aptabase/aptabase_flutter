import 'package:aptabase_flutter/src/offline_logic/services/events_service.dart';
import 'package:sembast/sembast.dart';

class TestEventService {
  final Database db;
  late AddEvent addEvent;
  late GetAllEvents getAllEvents;
  late DeleteEvent deleteEvent;
  late EventsServiceSembast service;
  late RemoveObsoleteLinesFromDb removeObsoleteLinesFromDb;
  TestEventService(this.db) {
    addEvent = AddEvent(db);
    getAllEvents = GetAllEvents(db);
    deleteEvent = DeleteEvent(db);
    removeObsoleteLinesFromDb = RemoveObsoleteLinesFromDb(db);
    service = EventsServiceSembast(
      addEvent,
      getAllEvents,
      deleteEvent,
      removeObsoleteLinesFromDb,
    );
  }
}
