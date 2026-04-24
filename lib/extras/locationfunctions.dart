
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:ispark_project/localentity/parkinglot.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math';

class Localfunctions {
  StreamSubscription<Position>? _streamSubscription;

  Future<bool> _checkPermissions() async {
    try {
      var reqStatus = await Permission.locationWhenInUse.status;

      if (reqStatus.isDenied) {
        reqStatus = await Permission.locationWhenInUse.request();
        if (reqStatus.isDenied) {
          return false;
        }
      } else if (reqStatus.isPermanentlyDenied) {
        return false;
      }

      LocationPermission locationPermission = await Geolocator.checkPermission();
      if (locationPermission == LocationPermission.denied) {
        locationPermission = await Geolocator.requestPermission();
        if (locationPermission == LocationPermission.denied) {
          return false;
        }
      }
      if (locationPermission == LocationPermission.deniedForever) {
        return false;
      }

      return true;
    } catch (e) {
      print('İzin kontrolü hatası: $e');
      return false;
    }
  }

  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<LatLng?> getCurrentLocation() async {
    try {
      final hasPermission = await _checkPermissions();
      if (!hasPermission) return null;

      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5,
        ),
      );

      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      print('Konum alınamadı: $e');
      return null;
    }
  }

  Future<Position?> getUserCurrentLocation() async {
    try {
      final hasPermission = await _checkPermissions();
      if (!hasPermission) return null;

      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      final userCurrentLocation = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5,
        ),
      );

      return userCurrentLocation;
    } catch (e) {
      print('Konum alınamadı: $e');
      return null;
    }
  }

  Stream<LatLng> getLocationStream() async* {
    final hasPermission = await _checkPermissions();
    if (!hasPermission) return;

    final serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) return;

    yield* Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).map((position) => LatLng(position.latitude, position.longitude));
  }

  Future<StreamSubscription<Position>?> startUpdateUserCurrentLocation({
    required void Function(Position) onLocationChanged,
  }) async {
    try {
      final hasPermission = await _checkPermissions();
      if (!hasPermission) return null;

      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      await _streamSubscription?.cancel();

      final stream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );

      _streamSubscription = stream.listen(
        (Position pos) {
          onLocationChanged(pos);
        },
        onError: (error) {
          print('Konum stream hatası: $error');
        },
      );

      return _streamSubscription;
    } catch (e) {
      print('Konum stream başlatma hatası: $e');
      return null;
    }
  }

  Future<void> stopUserLocationUpdates() async {
    try {
      await _streamSubscription?.cancel();
      _streamSubscription = null;
    } catch (e) {
      print('Konum stream durdurma hatası: $e');
    }
  }

  Future<void> openSettings() async {
    await openAppSettings();
  }

  void dispose() {
    _streamSubscription?.cancel();
    _streamSubscription = null;
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

  List<ParkingLot> getNearbyParkings(
      LatLng userLocation, List<ParkingLot> parkings, double radius) {
    if (userLocation == null) return [];

    return parkings.where((p) {
      final d = calculateDistance(
        userLocation.latitude,
        userLocation.longitude,
        p.lat,
        p.lng,
      );
      return d <= radius;
    }).toList();
  }

  List<ParkingLot> getTop5NearestParkings(
      LatLng userLocation, List<ParkingLot> parkings, double radius) {
    final candidates = getNearbyParkings(userLocation, parkings, radius);

    candidates.sort((a, b) {
      double distA = calculateDistance(
          userLocation.latitude, userLocation.longitude, a.lat, a.lng);
      double distB = calculateDistance(
          userLocation.latitude, userLocation.longitude, b.lat, b.lng);

      double ratioA = a.capacity == 0 ? 0 : a.empty / a.capacity;
      double ratioB = b.capacity == 0 ? 0 : b.empty / b.capacity;

      double scoreA = distA - (ratioA * 1000);
      double scoreB = distB - (ratioB * 1000);

      return scoreA.compareTo(scoreB);
    });

    return candidates.take(5).toList();
  }
}
