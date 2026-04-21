import 'package:floor/floor.dart';
import 'package:ispark_project/database/entity/favorite.dart';

@dao
abstract class Favoritedao {
  
  @Query('SELECT * FROM favorites')
  Future<List<Favorite>> getAllFavorites();

  @Query('SELECT * FROM favorites WHERE parkID = :id')
  Future<Favorite?> findFavorite(int id);

  @Query('DELETE FROM favorites WHERE id = :id')
  Future<void> deleteFavorite(int id);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertFavorite(Favorite favorite);
}