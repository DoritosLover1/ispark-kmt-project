import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ispark_project/database/databaseinstance.dart';
import 'package:ispark_project/database/entity/favorite.dart';

final favoriteParksProvider =
    StateNotifierProvider<FavoriteParksNotifier, List<Favorite>>((ref) {
  return FavoriteParksNotifier();
});

class FavoriteParksNotifier extends StateNotifier<List<Favorite>> {
  
  FavoriteParksNotifier() : super([]) {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    try {
      final db = await DBInstance.getInstance();
      final favorites = await db.favoritesDao.getAllFavorites();
      state = favorites;
    } catch (e) {
    }
  }

  Future<void> addFavorite(Favorite favorite) async {
    try {
      final db = await DBInstance.getInstance();
      await db.favoritesDao.insertFavorite(favorite);
      await loadFavorites();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeFavorite(int parkId) async {
    try {
      final db = await DBInstance.getInstance();
      await db.favoritesDao.deleteFavoriteByParkID(parkId);

      await loadFavorites();
    } catch (e) {
      rethrow;
    }
  }
}