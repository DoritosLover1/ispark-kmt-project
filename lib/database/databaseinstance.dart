import 'package:ispark_project/database/maindb.dart';

class DBInstance {
  static AppDataBase? _db;

  static Future<AppDataBase> getInstance() async {
    if (_db != null) return _db!;

    _db = await $FloorAppDataBase.databaseBuilder('ispark.db').build();

    return _db!;
  }
}
