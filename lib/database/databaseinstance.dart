import 'package:ispark_project/database/maindb.dart';
import 'package:floor/floor.dart';

class DBInstance {
  static AppDataBase? _db;

  static Future<AppDataBase> getInstance() async {
    if (_db != null) return _db!;

    final migration6to7 = Migration(6, 7, (database) async {
      await database.execute(
        'CREATE TABLE IF NOT EXISTS `reservations` (`id` INTEGER NOT NULL, `parkID` INTEGER NOT NULL, `parkName` TEXT NOT NULL, `district` TEXT NOT NULL, `parkType` TEXT NOT NULL, `workHours` TEXT NOT NULL, `capacity` INTEGER NOT NULL, `freeTime` INTEGER NOT NULL, `lat` REAL NOT NULL, `lng` REAL NOT NULL, `plate` TEXT NOT NULL, `phone` TEXT NOT NULL, `date` TEXT NOT NULL, PRIMARY KEY (`id`))',
      );
    });

    _db = await $FloorAppDataBase.databaseBuilder('ispark.db').addMigrations([
      migration6to7,
    ]).build();

    return _db!;
  }
}
