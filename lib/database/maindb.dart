import 'dart:async';
import 'package:floor/floor.dart';
import 'package:ispark_project/database/dao/favoritedao.dart';
import 'package:ispark_project/database/entity/favorite.dart';
import 'package:ispark_project/database/dao/reservationdao.dart';
import 'package:ispark_project/database/entity/reservation.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

part 'maindb.g.dart';

@Database(version: 7, entities: [Favorite, Reservation])
abstract class AppDataBase extends FloorDatabase {
  Favoritedao get favoritesDao;
  ReservationDao get reservationDao;
}