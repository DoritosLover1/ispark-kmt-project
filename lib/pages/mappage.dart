import 'dart:convert';
import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:ispark_project/extras/localservices.dart';
import 'package:ispark_project/extras/locationfunctions.dart';
import 'package:ispark_project/extras/parkingmarkers.dart';
import 'package:ispark_project/localentity/parkinglot.dart';
import 'package:ispark_project/pages/detailedparkpage.dart';
import 'package:ispark_project/pages/settingspage.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class MapPage extends StatefulWidget {
  final String keyAPI;
  const MapPage({super.key, required this.keyAPI});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with WidgetsBindingObserver {
  final MapController _mapController = MapController();
  final Localfunctions _localfunctions = Localfunctions();
  final IsparkService _isparkService = IsparkService();

  LatLng? userLocation;
  List<ParkingLot> parkings = [];
  List<ParkingLot> displayedParkings = [];
  bool showAllParks = true;

  bool isLoading = true;
  int radius = 1000;

  LatLng? _lastRefreshLocation;
  static const double _refreshDistanceThreshold = 200;

  Timer? _refreshTimer;
  StreamSubscription<LatLng>? _locationStreamSubscription;
  static const Duration _refreshInterval = Duration(minutes: 5);
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  void _checkLocationAndRefresh(LatLng newLocation) {
    if (_lastRefreshLocation == null) {
      _lastRefreshLocation = newLocation;
      return;
    }

    const Distance distance = Distance();
    final double meters = distance(_lastRefreshLocation!, newLocation);

    if (meters >= _refreshDistanceThreshold) {
      _lastRefreshLocation = newLocation;
      _refreshParkingData();
    }
  }

  Future<void> _init() async {
    try {
      final loc = await _localfunctions.getCurrentLocation();

      userLocation = loc != null
          ? LatLng(loc.latitude, loc.longitude)
          : const LatLng(41.0082, 28.9784);

      final data = await _isparkService.fetchParkings();

      if (mounted) {
        setState(() {
          parkings = data;
          displayedParkings = data;
          isLoading = false;
        });
      }

      _startAutoRefresh();
    } catch (e) {
      print('Error in _init: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(_refreshInterval, (_) async {
      if (!_isRefreshing) await _refreshParkingData();
    });

    _locationStreamSubscription?.cancel();
    _locationStreamSubscription = _localfunctions.getLocationStream().listen((newLoc) {
      if (mounted) setState(() => userLocation = newLoc);
      _checkLocationAndRefresh(newLoc);
    });
  }

  Future<void> _refreshParkingData() async {
    if (_isRefreshing) return;

    _isRefreshing = true;

    try {
      final data = await _isparkService.fetchParkings();

      if (mounted) {
        setState(() {
          parkings = data;

          if (showAllParks) {
            displayedParkings = data;
          } else {
            displayedParkings = _localfunctions.getTop5NearestParkings(
              userLocation!,
              data,
              radius.toDouble(),
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Veriler güncellenemedi',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> _manualRefresh() async {
    await _refreshParkingData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Güncel veriler getirilmiştir.',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
          ),
          backgroundColor: SettingsPage.primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startAutoRefresh();
      _refreshParkingData();
    } else if (state == AppLifecycleState.paused) {
      _locationStreamSubscription?.cancel();
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _locationStreamSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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

              if (!showAllParks)
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

              if (displayedParkings.isNotEmpty)
                MarkerLayer(
                  markers: ParkingMarkers.getParkingMarkers(
                    displayedParkings,
                    (_) {},
                    context,
                    () => _refreshParkingData(),
                  ),
                ),

              MarkerLayer(
                markers: [
                  Marker(
                    point: userLocation!,
                    width: 40,
                    height: 40,
                    child: Icon(
                      Icons.person,
                      color: colorScheme.primary,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ],
          ),

          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
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
                  const SizedBox(width: 8),
                  if (_isRefreshing)
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorScheme.primary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 40,
            left: 10,
            right: 10,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _mapController.move(userLocation!, 15),
                    icon: Icon(Icons.my_location, color: colorScheme.onPrimary),
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
                const SizedBox(width: 8),

                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        showAllParks = true;
                        displayedParkings = parkings;
                      });
                      _mapController.move(userLocation!, 15);
                    },
                    icon: Icon(Icons.list, color: colorScheme.onPrimary),
                    label: Text(
                      "Tam Harita",
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
                const SizedBox(width: 8),

                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final results = _localfunctions.getTop5NearestParkings(
                        userLocation!,
                        parkings,
                        radius.toDouble(),
                      );

                      setState(() {
                        showAllParks = false;
                        displayedParkings = results;
                      });

                      if (results.isNotEmpty) {
                        _mapController.move(
                          LatLng(results.first.lat, results.first.lng),
                          16,
                        );
                      }
                    },
                    icon: Icon(Icons.near_me, color: colorScheme.onPrimary),
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

          if (!showAllParks)
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
                        inactiveColor: colorScheme.primary.withOpacity(0.15),
                        onChanged: (value) {
                          setState(() {
                            radius = value.toInt();
                            displayedParkings =
                                _localfunctions.getTop5NearestParkings(
                              userLocation!,
                              parkings,
                              radius.toDouble(),
                            );
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

          Positioned(
            top: 50,
            right: 16,
            child: FloatingActionButton.small(
              onPressed: _isRefreshing ? null : _manualRefresh,
              tooltip: 'Verileri yenile',
              child: _isRefreshing
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : Icon(Icons.refresh, color: colorScheme.onPrimary),
            ),
          ),
        ],
      ),
    );
  }
}