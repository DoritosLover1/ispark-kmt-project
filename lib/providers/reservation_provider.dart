import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ispark_project/database/databaseinstance.dart';
import 'package:ispark_project/database/entity/reservation.dart';

final reservationParksProvider =
    StateNotifierProvider<ReservationParksNotifier, List<Reservation>>((ref) {
  return ReservationParksNotifier();
});

class ReservationParksNotifier extends StateNotifier<List<Reservation>> {
  ReservationParksNotifier() : super([]) {
    loadReservations();
  }

  Future<void> loadReservations() async {
    try {
      final db = await DBInstance.getInstance();
      final reservations = await db.reservationDao.getAllReservations();
      state = reservations;
    } catch (e) {
    }
  }

  Future<void> addReservation(Reservation reservation) async {
    try {
      final db = await DBInstance.getInstance();
      await db.reservationDao.insertReservation(reservation);
      await loadReservations();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeReservation(int parkId, String plate) async {
    try {
      final db = await DBInstance.getInstance();
      await db.reservationDao.deleteReservationByParkIDAndPlate(parkId, plate);
      await loadReservations();
    } catch (e) {
      rethrow;
    }
  }
}
