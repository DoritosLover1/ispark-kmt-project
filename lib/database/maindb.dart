

import 'package:floor/floor.dart';
import 'package:ispark_project/database/dao/favoritedao.dart';
import 'package:ispark_project/database/entity/favorite.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

/*
  Bunun olayı şu gidip senin bu dart dosyası gibi maindb.g.dart yazıp
  
  Genel kod bu çalışacak:
    flutter pub get
    flutter pub run build_runner build
  
  Hatalı kod çıkarsa:
    flutter pub run build_runner build --delete-conflicting-outputs
  part 'maindb.g.dart'; yapılacak
*/
@Database(version: 1, entities: [Favorite])
abstract class AppDataBase extends FloorDatabase {
  Favoritedao get favoritesDao;
}