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

    userLocation = loc != null
        ? LatLng(loc.latitude, loc.longitude)
        : const LatLng(41.0082, 28.9784);

    final data = await _isparkService.fetchParkings();

    setState(() {
      parkings = data;
      isLoading = false;
    });
  }

  double calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295;
    final a = 0.5 -
        (cos((lat2 - lat1) * p)) / 2 +
        cos(lat1 * p) *
            cos(lat2 * p) *
            (1 - cos((lon2 - lon1) * p)) /
            2;

    return 12742000 * asin(min(1.0, sqrt(a)));
  }

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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final nearby = getNearbyParkings();

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: userLocation!,
              initialZoom: 15,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://api.maptiler.com/maps/hybrid/256/{z}/{x}/{y}.jpg?key=${widget.keyAPI}",
                userAgentPackageName: "com.example.app",
              ),

              CircleLayer(
                circles: [
                  CircleMarker(
                    point: userLocation!,
                    radius: radius.toDouble(),
                    useRadiusInMeter: true,
                    color: colorScheme.primary.withOpacity(0.12),
                    borderColor: colorScheme.primary.withOpacity(0.6),
                    borderStrokeWidth: 2,
                  ),
                ],
              ),

              MarkerLayer(
                markers: [
                  Marker(
                    point: userLocation!,
                    width: 40,
                    height: 40,
                    child: Icon(Icons.person, color: colorScheme.primary),
                  ),
                ],
              ),

              MarkerLayer(
                markers: nearby.map((p) {
                  final ratio =
                      p.capacity == 0 ? 0 : p.empty / p.capacity;

                  Color color;
                  if (ratio > 0.5) {
                    color = Colors.green;
                  } else if (ratio > 0.2) {
                    color = Colors.orange;
                  } else {
                    color = Colors.red;
                  }

                  return Marker(
                    point: LatLng(p.lat, p.lng),
                    width: 40,
                    height: 40,
                    child: Icon(Icons.local_parking,
                        color: color, size: 30),
                  );
                }).toList(),
              ),
            ],
          ),

          /// TITLE (THEME UYUMLU)
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "İSPARK Haritası",
                style: textTheme.headlineLarge?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.8),
                      blurRadius: 15,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// BUTTONS (PRIMARY THEME)
          Positioned(
            bottom: 40,
            left: 16,
            right: 16,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        _mapController.move(userLocation!, 15),
                    icon: Icon(Icons.my_location,
                        color: colorScheme.onPrimary),
                    label: Text(
                      "Beni Bul",
                      style: textTheme.labelLarge?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.near_me,
                        color: colorScheme.onPrimary),
                    label: Text(
                      "En Yakın",
                      style: textTheme.labelLarge?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// RADIUS SLIDER
          Positioned(
            right: 16,
            bottom: 120,
            child: Column(
              children: [
                Container(
                  height: 220,
                  width: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: Slider(
                      value: radius.toDouble(),
                      min: 200,
                      max: 5000,
                      divisions: 24,
                      activeColor: colorScheme.onPrimary,
                      inactiveColor:
                          colorScheme.primary.withOpacity(0.15),
                      onChanged: (value) {
                        setState(() {
                          radius = value.toInt();
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Container(
                  width: 90,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "${(radius / 100).toStringAsFixed(2)} km",
                    textAlign: TextAlign.center,
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
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