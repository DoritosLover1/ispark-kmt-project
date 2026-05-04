class ParkingLot {
  final String otopark_adi;
  final double lat;
  final double lng;
  final int capacity;
  final int empty_capacity;
  final int free_time;
  final String park_type;
  final int is_open;
  final String work_hours;
  final String district;
  final int otopark_id;

  ParkingLot({
    required this.otopark_adi,
    required this.lat,
    required this.lng,
    required this.capacity,
    required this.empty_capacity,
    required this.free_time,
    required this.park_type,
    required this.is_open,
    required this.work_hours,
    required this.district,
    required this.otopark_id,
  });

  factory ParkingLot.fromJson(Map<String, dynamic> e) {
    return ParkingLot(
      otopark_id: e["otopark_id"] ?? 0,
      otopark_adi: e["otopark_adi"] ?? "Bilinmiyor",
      lat: double.tryParse(e["lat"].toString()) ?? 0,
      lng: double.tryParse(e["lng"].toString()) ?? 0,
      capacity: e["capacity"] ?? 0,
      empty_capacity: e["empty_capacity"] ?? 0,
      free_time: e["free_time"] ?? 0,
      park_type: e["park_type"] ?? "-",
      is_open: e["is_open"] ?? 0,
      work_hours: e["work_hours"] ?? "-",
      district: e["district"] ?? "-",
    );
  }
}