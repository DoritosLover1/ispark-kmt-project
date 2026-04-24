class ParkingLot {
  final String name;
  final double lat;
  final double lng;
  final int capacity;
  final int empty;
  final int freeTime;
  final String parkType;
  final int isOpen;
  final String workHours;
  final String district;
  final int parkID;

  ParkingLot({
    required this.name,
    required this.lat,
    required this.lng,
    required this.capacity,
    required this.empty,
    required this.freeTime,
    required this.parkType,
    required this.isOpen,
    required this.workHours,
    required this.district,
    required this.parkID,
  });

  factory ParkingLot.fromJson(Map<String, dynamic> e) {
    return ParkingLot(
      parkID: e["parkID"] ?? 0,
      name: e["parkName"] ?? "Bilinmiyor",
      lat: double.tryParse(e["lat"].toString()) ?? 0,
      lng: double.tryParse(e["lng"].toString()) ?? 0,
      capacity: e["capacity"] ?? 0,
      empty: e["emptyCapacity"] ?? 0,
      freeTime: e["freeTime"] ?? 0,
      parkType: e["parkType"] ?? "-",
      isOpen: e["isOpen"] ?? 0,
      workHours: e["workHours"] ?? "-",
      district: e["district"] ?? "-",
    );
  }
}