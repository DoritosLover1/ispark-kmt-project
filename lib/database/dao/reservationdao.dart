import 'package:floor/floor.dart';
import 'package:ispark_project/database/entity/reservation.dart';

@dao
abstract class ReservationDao {
  @Query('SELECT * FROM reservations')
  Future<List<Reservation>> getAllReservations();

  @Query('SELECT * FROM reservations WHERE parkID = :id')
  Future<Reservation?> findReservation(int id);

  @Query('DELETE FROM reservations WHERE id = :id')
  Future<void> deleteReservation(int id);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertReservation(Reservation reservation);

  @Query('DELETE FROM reservations WHERE parkID = :parkID AND plate = :plate')
  Future<void> deleteReservationByParkIDAndPlate(int parkID, String plate);
}
