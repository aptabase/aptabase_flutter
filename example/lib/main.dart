import 'dart:io';

import 'package:aptabase_flutter/aptabase_flutter.dart';
import 'package:aptabase_flutter/persistence.dart';
import 'package:example/matriochka_provider.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:path/path.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Aptabase.init("A-DEV-0000000000");
  runApp(
    const Directionality(
      textDirection: TextDirection.ltr,
      child: EntryPointGetDirPath(),
    ),
  );
}

class EntryPointGetDirPath extends StatelessWidget {
  const EntryPointGetDirPath({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Directory>(
        future: getApplicationDocumentsDirectory(),
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return ColoredBox(
                color: const Color.fromRGBO(222, 64, 122, 1),
                child: Text('appDirectory error ${snap.error}'));
          } else if (snap.hasError) {
            return ColoredBox(
                color: const Color.fromRGBO(236, 64, 122, 1),
                child: Text('appDirectory error ${snap.error}'));
          } else if ((snap.connectionState != ConnectionState.waiting &&
                  !snap.hasData) ||
              snap.data == null) {
            return const ColoredBox(
                color: Color.fromRGBO(244, 143, 177, 1),
                child: Text('no appDirectory'));
          } else {
            return GetDb(snap.data!);
          }
        });
  }
}

class GetDb extends StatelessWidget {
  final Directory directory;
  const GetDb(this.directory, {super.key});

  Future<DbMetrics> _getDb() async {
    DatabaseFactory dbFactory = databaseFactoryIo;
    final dir = await getApplicationDocumentsDirectory();

    final path = join(dir.path, 'do_not_delete', 'aptabase');
    final dbSembast =
        await dbFactory.openDatabase(path, mode: DatabaseMode.create);
    final dbMetrics = DbMetrics(dbSembast);
    return dbMetrics;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DbMetrics>(
        future: _getDb(),
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return ColoredBox(
                color: const Color.fromRGBO(122, 64, 122, 1),
                child: Text('getDb error ${snap.error}'));
          } else if (snap.hasError) {
            return ColoredBox(
                color: const Color.fromRGBO(136, 64, 122, 1),
                child: Text('getDb error ${snap.error}'));
          } else if ((snap.connectionState != ConnectionState.waiting &&
                  !snap.hasData) ||
              snap.data == null) {
            return const ColoredBox(
                color: Color.fromRGBO(144, 143, 177, 1),
                child: Text('no getDb'));
          } else {
            return MyApp(snap.data!);
          }
        });
  }
}

class MyApp extends StatelessWidget {
  final DbMetrics db;
  const MyApp(this.db, {super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return DatabaseProvider(
      database: db,
      child: SingleServiceProvider(
        child: AllServicesProvider(
          child: MaterialApp(
            title: 'Aptabase demo',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
            home: const MyHomePage(title: 'Flutter Demo Home Page'),
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    Aptabase.instance.trackEvent("increment", {"counter": _counter});
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final eventsService =
        Provider.of<EventsServiceSembast>(context, listen: false);
    Aptabase.init("A-DEV-0000000000", null);
    Aptabase.initPersistence(eventsService);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _incrementCounter();
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
