import 'package:aptabase_flutter/persist_event.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool _isAboveCeiling(SharedPreferences? prefs) =>
    prefs == null ? true : prefs.getKeys().length > 999;

/// will not persist events if there are already 1000 saved
/// to avoid weighing on memory
Future<bool> persistIt(SharedPreferences? prefs, Event pEvent) async {
  if (prefs == null || _isAboveCeiling(prefs)) {
    return false;
  } else {
    return await prefs.setString(pEvent.key, pEvent.toJson());
  }
}

Future<bool> deleteIt(SharedPreferences? prefs, Event pEvent) async {
  if (prefs == null) {
    return false;
  } else {
    return prefs.remove(pEvent.key);
  }
}

List<Event> getAllPersistedEvents(SharedPreferences? prefs) {
  final events = <Event>[];
  if (prefs == null) {
    return events;
  }
  final keys = prefs.getKeys();
  for (final key in keys) {
    final eventRaw = prefs.getString(key);
    if (eventRaw != null) {
      final event = Event.fromJson(eventRaw);
      events.add(event);
    }
  }
  return events.orderAsc;
}
