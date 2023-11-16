import 'package:aptabase_flutter/persistence.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DatabaseProvider extends StatelessWidget {
  final DbMetrics database;
  final Widget child;
  const DatabaseProvider(
      {super.key, required this.child, required this.database});

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: database,
      child: child,
    );
  }
}

class SingleServiceProvider extends StatelessWidget {
  final Widget child;
  const SingleServiceProvider({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ProxyProvider<DbMetrics, AddEvent>(
          update: (c, database, prev) => prev ?? AddEvent(database),
        ),
        ProxyProvider<DbMetrics, GetAllEvents>(
          update: (c, database, prev) => prev ?? GetAllEvents(database),
        ),
        ProxyProvider<DbMetrics, DeleteEvent>(
          update: (c, database, prev) => prev ?? DeleteEvent(database),
        ),
        ProxyProvider<DbMetrics, RemoveObsoleteLinesFromDb>(
          update: (c, database, prev) =>
              prev ?? RemoveObsoleteLinesFromDb(database),
        ),
      ],
      child: child,
    );
  }
}

class AllServicesProvider extends StatelessWidget {
  final Widget child;
  const AllServicesProvider({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ProxyProvider4<AddEvent, GetAllEvents, DeleteEvent,
            RemoveObsoleteLinesFromDb, EventsServiceSembast>(
          update: (c, addEvent, getAllEvents, deleteEvent,
              removeObsoleteLinesFromDb, previousService) {
            return previousService ??
                EventsServiceSembast(addEvent, getAllEvents, deleteEvent,
                    removeObsoleteLinesFromDb);
          },
        )
      ],
      child: child,
    );
  }
}
