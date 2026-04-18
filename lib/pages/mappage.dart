import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:ispark_project/functions/locationfunctions.dart';
import 'package:ispark_project/pages/detailedparkpage.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

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

class IsparkService {
  Future<List<ParkingLot>> fetchParkings() async {
    final response =
        await http.get(Uri.parse("https://api.ibb.gov.tr/ispark/Park"));

    final List data = json.decode(response.body);

    return data
        .map<ParkingLot>((e) => ParkingLot.fromJson(e))
        .toList();
  }
}

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

  List<ParkingLot> top3Parkings = [];

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

  List<ParkingLot> getTop3Parkings() {
    final candidates = getNearbyParkings();

    candidates.sort((a, b) {
      double distA = calculateDistance(
          userLocation!.latitude, userLocation!.longitude, a.lat, a.lng);
      double distB = calculateDistance(
          userLocation!.latitude, userLocation!.longitude, b.lat, b.lng);

      double ratioA = a.capacity == 0 ? 0 : a.empty / a.capacity;
      double ratioB = b.capacity == 0 ? 0 : b.empty / b.capacity;

      double scoreA = distA - (ratioA * 1000);
      double scoreB = distB - (ratioB * 1000);

      return scoreA.compareTo(scoreB);
    });

    return candidates.take(3).toList();
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

              if (top3Parkings.isNotEmpty)
                MarkerLayer(
                  markers: ParkingMarkers.getParkingMarkers(
                    top3Parkings,
                    (_) {}, // onTap callback
                    context,
                  ),
                ),
            ],
          ),

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
                    onPressed: () {
                      final results = getTop3Parkings();

                      setState(() {
                        top3Parkings = results;
                      });

                      if (results.isNotEmpty) {
                        _mapController.move(
                          LatLng(results.first.lat, results.first.lng),
                          16,
                        );
                      }
                    },
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
                          top3Parkings = [];
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

class ParkingMarkers {
  static List<Marker> getParkingMarkers(
    List<dynamic> items,
    void Function(dynamic p) onTap,
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final screenWidth = MediaQuery.of(context).size.width;
    final scale = (screenWidth / 375.0).clamp(0.85, 1.3);

    return items.map((p) {
      final ratio = p.capacity == 0 ? 0 : p.empty / p.capacity;

      Color accent;
      if (ratio > 0.5) {
        accent = Colors.green;
      } else if (ratio > 0.2) {
        accent = Colors.orange;
      } else {
        accent = Colors.red;
      }

      return Marker(
        width: 170 * scale,
        height: 75 * scale,
        point: LatLng(p.lat, p.lng),

        child: GestureDetector(
          onTap: () {
            onTap(p);

            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => DetailedParkPage(
                  park: {
                    "parkID": p.parkID,
                    "parkName": p.name,
                    "capacity": p.capacity,
                    "emptyCapacity": p.empty,
                    "lat": p.lat,
                    "lng": p.lng,
                    "district": p.district,
                    "parkType": p.parkType,
                    "workHours": p.workHours,
                    "freeTime": p.freeTime,
                    "isOpen": p.isOpen,
                  },
                ),
              ),
            );
          },

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 14 * scale,
                  vertical: 8 * scale,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surface.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(30 * scale),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withOpacity(0.25),
                      blurRadius: 18 * scale,
                      offset: const Offset(0, 6),
                    ),
                  ],
                  border: Border.all(
                    color: accent.withOpacity(0.6),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10 * scale,
                      height: 10 * scale,
                      decoration: BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 8 * scale),
                    Flexible(
                      child: Text(
                        p.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontSize: 12 * scale,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 2,
                height: 10 * scale,
                color: accent.withOpacity(0.6),
              ),
              Container(
                width: 8 * scale,
                height: 8 * scale,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
}