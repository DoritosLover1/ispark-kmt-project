import 'package:floor/floor.dart';

@Entity(tableName: 'favorites')
class Favorite {
  @PrimaryKey()
  final int id;
  final int parkID;
  final String parkName;
  final String district;
  final String parkType;
  final String workHours;
  final int capacity;
  final int freeTime;
  final double lat;
  final double lng;

  Favorite({
    required this.id,
    required this.parkID,
    required this.parkName,
    required this.district,
    required this.parkType,
    required this.workHours,
    required this.capacity,
    required this.freeTime,
    required this.lat,
    required this.lng
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: (json['id'] as num).toInt(), 
      parkID: (json['parkID'] as num).toInt(), 
      parkName: json['parkName'] as String, 
      district: json['district'] as String, 
      parkType: json['parkType'] as String, 
      workHours: json['workHours'] as String, 
      capacity: (json['capacity'] as num).toInt(), 
      freeTime: (json['freeTime'] as num).toInt(),
      lat: double.parse(json['lat'].toString()),
      lng: double.parse(json['lng'].toString()),
    );
  }
}