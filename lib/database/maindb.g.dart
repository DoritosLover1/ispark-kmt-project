// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'maindb.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AppDataBaseBuilderContract {
  /// Adds migrations to the builder.
  $AppDataBaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AppDataBaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AppDataBase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAppDataBase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDataBaseBuilderContract databaseBuilder(String name) =>
      _$AppDataBaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDataBaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AppDataBaseBuilder(null);
}

class _$AppDataBaseBuilder implements $AppDataBaseBuilderContract {
  _$AppDataBaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AppDataBaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AppDataBaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<AppDataBase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDataBase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDataBase extends AppDataBase {
  _$AppDataBase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  Favoritedao? _favoritesDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 6,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `favorites` (`id` INTEGER NOT NULL, `parkID` INTEGER NOT NULL, `parkName` TEXT NOT NULL, `district` TEXT NOT NULL, `parkType` TEXT NOT NULL, `workHours` TEXT NOT NULL, `capacity` INTEGER NOT NULL, `freeTime` INTEGER NOT NULL, `lat` REAL NOT NULL, `lng` REAL NOT NULL, PRIMARY KEY (`id`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  Favoritedao get favoritesDao {
    return _favoritesDaoInstance ??= _$Favoritedao(database, changeListener);
  }
}

class _$Favoritedao extends Favoritedao {
  _$Favoritedao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _favoriteInsertionAdapter = InsertionAdapter(
            database,
            'favorites',
            (Favorite item) => <String, Object?>{
                  'id': item.id,
                  'parkID': item.parkID,
                  'parkName': item.parkName,
                  'district': item.district,
                  'parkType': item.parkType,
                  'workHours': item.workHours,
                  'capacity': item.capacity,
                  'freeTime': item.freeTime,
                  'lat': item.lat,
                  'lng': item.lng
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Favorite> _favoriteInsertionAdapter;

  @override
  Future<List<Favorite>> getAllFavorites() async {
    return _queryAdapter.queryList('SELECT * FROM favorites',
        mapper: (Map<String, Object?> row) => Favorite(
            id: row['id'] as int,
            parkID: row['parkID'] as int,
            parkName: row['parkName'] as String,
            district: row['district'] as String,
            parkType: row['parkType'] as String,
            workHours: row['workHours'] as String,
            capacity: row['capacity'] as int,
            freeTime: row['freeTime'] as int,
            lat: row['lat'] as double,
            lng: row['lng'] as double));
  }

  @override
  Future<Favorite?> findFavorite(int id) async {
    return _queryAdapter.query('SELECT * FROM favorites WHERE parkID = ?1',
        mapper: (Map<String, Object?> row) => Favorite(
            id: row['id'] as int,
            parkID: row['parkID'] as int,
            parkName: row['parkName'] as String,
            district: row['district'] as String,
            parkType: row['parkType'] as String,
            workHours: row['workHours'] as String,
            capacity: row['capacity'] as int,
            freeTime: row['freeTime'] as int,
            lat: row['lat'] as double,
            lng: row['lng'] as double),
        arguments: [id]);
  }

  @override
  Future<void> deleteFavorite(int id) async {
    await _queryAdapter
        .queryNoReturn('DELETE FROM favorites WHERE id = ?1', arguments: [id]);
  }

  @override
  Future<void> deleteFavoriteByParkID(int parkID) async {
    await _queryAdapter.queryNoReturn('DELETE FROM favorites WHERE parkID = ?1',
        arguments: [parkID]);
  }

  @override
  Future<void> insertFavorite(Favorite favorite) async {
    await _favoriteInsertionAdapter.insert(
        favorite, OnConflictStrategy.replace);
  }
}
