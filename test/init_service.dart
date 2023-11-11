import 'package:aptabase_flutter/event_service.dart';
import 'package:sembast/sembast.dart';

class TestEventService {
  final Database db;
  late AddEvent addEvent;
  late GetAllEvents getAllEvents;
  late DeleteEvent deleteEvent;
  late EventsService service;
  TestEventService(this.db) {
    addEvent = AddEvent(db);
    getAllEvents = GetAllEvents(db);
    deleteEvent = DeleteEvent(db);
    service = EventsService(addEvent, getAllEvents, deleteEvent);
  }
}
