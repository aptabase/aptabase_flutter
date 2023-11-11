import 'package:aptabase_flutter/aptabase_flutter.dart';
import 'package:aptabase_flutter/persistence.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sembast/sembast.dart';

class DatabaseProvider extends StatelessWidget {
  final Database database;
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
        ProxyProvider<Database, AddEvent>(
          update: (c, database, prev) => prev ?? AddEvent(database),
        ),
        ProxyProvider<Database, GetAllEvents>(
          update: (c, database, prev) => prev ?? GetAllEvents(database),
        ),
        ProxyProvider<Database, DeleteEvent>(
          update: (c, database, prev) => prev ?? DeleteEvent(database),
        ),
        ProxyProvider<Database, RemoveObsoleteLinesFromDb>(
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
