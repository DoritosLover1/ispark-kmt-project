
import 'package:ispark_project/database/maindb.dart';
import 'package:floor/floor.dart';

class DBInstance {
  static AppDataBase? _db;

  static Future<AppDataBase> getInstance() async {
    if (_db != null) return _db!;

    _db = await $FloorAppDatabase.databaseBuilder('ispark.db').build();

    return _db!;
  }
}