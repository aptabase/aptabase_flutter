import 'package:aptabase_flutter/src/offline_logic/services_asbtract/endpoint_base_abstract.dart';
import 'package:aptabase_flutter/src/offline_logic/event_offline.dart';
import 'package:sembast/sembast.dart';

abstract class EventsServiceAbstract {
  final AddEventAbstract addEvent;
  final GetAllEventsAbstract getAllEvents;
  final DeleteEventAbstract deleteEvent;
  final RemoveObsoleteLinesFromDbAbstract removeObsoleteLinesFromDb;
  EventsServiceAbstract(
    this.addEvent,
    this.getAllEvents,
    this.deleteEvent,
    this.removeObsoleteLinesFromDb,
  );
}

abstract class AddEventAbstract implements EndpointBase<bool, EventOffline> {
  const AddEventAbstract();
  @override
  Future<bool> request(EventOffline event);
}

abstract class GetAllEventsAbstract
    implements
        EndpointBase<List<RecordSnapshot<int, Map<String, Object?>>>, void> {
  const GetAllEventsAbstract();
  @override
  Future<List<RecordSnapshot<int, Map<String, Object?>>>> request(void data);
}

abstract class DeleteEventAbstract implements EndpointBase<bool, int> {
  const DeleteEventAbstract();
  @override
  Future<bool> request(int key);
}

abstract class RemoveObsoleteLinesFromDbAbstract
    implements EndpointBase<void, void> {
  const RemoveObsoleteLinesFromDbAbstract();
  @override
  Future<void> request(void _);
}
