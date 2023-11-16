import 'package:sembast/sembast.dart' show Database;

abstract class WrapperAptabase {
  final Database db;
  const WrapperAptabase(this.db);
}

class DbMetrics extends WrapperAptabase {
  final Database dbMt;
  const DbMetrics(this.dbMt) : super(dbMt);
}
