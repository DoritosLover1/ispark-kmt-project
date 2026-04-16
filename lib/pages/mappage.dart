import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:ispark_project/functions/locationfunctions.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

/// MODEL
class ParkingLot {
  final String name;
  final double lat;
  final double lng;
  final int capacity;
  final int empty;

  ParkingLot({
    required this.name,
    required this.lat,
    required this.lng,
    required this.capacity,
    required this.empty,
  });
}

/// SERVICE
class IsparkService {
  Future<List<ParkingLot>> fetchParkings() async {
    final response =
        await http.get(Uri.parse("https://api.ibb.gov.tr/ispark/Park"));

    final data = json.decode(response.body);

    return data.map<ParkingLot>((e) {
      return ParkingLot(
        name: e["PARK_NAME"] ?? "Bilinmiyor",
        lat: double.tryParse(e["LAT"].toString()) ?? 0,
        lng: double.tryParse(e["LON"].toString()) ?? 0,
        capacity: int.tryParse(e["CAPACITY"].toString()) ?? 0,
        empty: int.tryParse(e["EMPTY_CAPACITY"].toString()) ?? 0,
      );
    }).toList();
  }
}

/// MAP PAGE
class MapPage extends StatefulWidget {
  final String keyAPI;
  const MapPage({super.key, required this.keyAPI});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  final LocationService _locationService = LocationService();
  final IsparkService _isparkService = IsparkService();

  LatLng? userLocation;
  List<ParkingLot> parkings = [];

  bool isLoading = true;
  int radius = 1000;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final loc = await _locationService.getCurrentLocation();

    if (loc != null) {
      userLocation = LatLng(loc.latitude, loc.longitude);
    } else {
      userLocation = const LatLng(41.0082, 28.9784);
    }

    final data = await _isparkService.fetchParkings();

    setState(() {
      parkings = data;
      isLoading = false;
    });
  }

  /// DISTANCE
  double calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295;
    final a = 0.5 -
        (cos((lat2 - lat1) * p)) / 2 +
        cos(lat1 * p) *
            cos(lat2 * p) *
            (1 - cos((lon2 - lon1) * p)) /
            2;
    return 12742000 * asin(sqrt(a));
  }

  /// RADIUS FILTER
  List<ParkingLot> getNearbyParkings() {
    if (userLocation == null) return [];

    return parkings.where((p) {
      final d = calculateDistance(
        userLocation!.latitude,
        userLocation!.longitude,
        p.lat,
        p.lng,
      );
      return d <= radius;
    }).toList();
  }

  /// ✅ EN YAKIN (RADIUS İÇİNDE)
  ParkingLot? getNearestParkingInRadius() {
    final nearby = getNearbyParkings();

    if (nearby.isEmpty) return null;

    ParkingLot? nearest;
    double minDistance = double.infinity;

    for (var p in nearby.where((e) => e.empty > 0)) {
      final d = calculateDistance(
        userLocation!.latitude,
        userLocation!.longitude,
        p.lat,
        p.lng,
      );

      if (d < minDistance) {
        minDistance = d;
        nearest = p;
      }
    }

    return nearest;
  }

  void goToNearestParking() {
    final nearest = getNearestParkingInRadius();

    if (nearest == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Bu yarıçap içinde uygun otopark yok"),
        ),
      );
      return;
    }

    final point = LatLng(nearest.lat, nearest.lng);

    _mapController.move(point, 17);
    showParkingDetail(nearest);
  }

  /// DETAIL
  void showParkingDetail(ParkingLot p) {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                p.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              Text("Kapasite: ${p.capacity}"),
              Text("Boş Yer: ${p.empty}"),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: p.capacity == 0 ? 0 : p.empty / p.capacity,
                color: colorScheme.primary,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final nearby = getNearbyParkings();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          /// MAP
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: userLocation!,
              initialZoom: 15,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://api.maptiler.com/maps/streets/256/{z}/{x}/{y}.png?key=${widget.keyAPI}",
              ),

              /// USER
              MarkerLayer(
                markers: [
                  Marker(
                    point: userLocation!,
                    width: 40,
                    height: 40,
                    child: Icon(
                      Icons.person,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),

              /// PARKINGS
              MarkerLayer(
                markers: nearby.map((p) {
                  final ratio =
                      p.capacity == 0 ? 0 : p.empty / p.capacity;

                  Color markerColor;
                  if (ratio > 0.5) {
                    markerColor = Colors.green;
                  } else if (ratio > 0.2) {
                    markerColor = Colors.orange;
                  } else {
                    markerColor = Colors.red;
                  }

                  return Marker(
                    point: LatLng(p.lat, p.lng),
                    width: 40,
                    height: 40,
                    child: GestureDetector(
                      onTap: () => showParkingDetail(p),
                      child: Icon(
                        Icons.local_parking,
                        color: markerColor,
                        size: 30,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          /// TITLE
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "İSPARK Haritası",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),

          /// BUTTONS
          Positioned(
            bottom: 40,
            left: 16,
            right: 16,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _mapController.move(userLocation!, 15);
                    },
                    icon: const Icon(Icons.my_location),
                    label: const Text("Beni Bul"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: goToNearestParking,
                    icon: const Icon(Icons.near_me),
                    label: const Text("En Yakın"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}