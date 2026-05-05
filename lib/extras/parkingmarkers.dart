import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:ispark_project/localentity/parkinglot.dart';
import 'package:ispark_project/pages/detailedparkpage.dart';
import 'package:latlong2/latlong.dart';

class ParkingMarkers {
  static List<Marker> getParkingMarkers(
    List<dynamic> items,
    void Function(dynamic p) onTap,
    BuildContext context,
    VoidCallback? onReservationChanged
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final screenWidth = MediaQuery.of(context).size.width;
    final scale = (screenWidth / 375.0).clamp(0.85, 1.3);

    return items.map((p) {
      final ratio = p.capacity == 0 ? 0 : p.empty_capacity / p.capacity;
      
      Color accent;
      if(p.is_open == 1) {
        if (ratio > 0.5) {
          accent = Colors.green;
        } else if (ratio > 0.2) {
          accent = Colors.orange;
        } else {
          accent = Colors.red;
        }
      } else {
        accent =  Colors.grey;
      }

      return Marker(
        width: 170 * scale,
        height: 75 * scale,
        point: LatLng(p.lat, p.lng),

        child: GestureDetector(
          onTap: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => DetailedParkPage(
                  park: {
                    "parkID": p.otopark_id,
                    "parkName": p.otopark_adi,
                    "capacity": p.capacity,
                    "emptyCapacity": p.empty_capacity,
                    "lat": p.lat,
                    "lng": p.lng,
                    "district": p.district,
                    "parkType": p.park_type,
                    "workHours": p.work_hours,
                    "freeTime": p.free_time,
                    "isOpen": p.is_open,
                  },
                  onReservationChanged: onReservationChanged,
                ),
              ),
            );
            onTap(p);
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
                  color: p.is_open == 1 ? colorScheme.surface.withOpacity(0.95) : Colors.grey.withOpacity(0.95),
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
                        p.otopark_adi,
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

  static Marker getSingleParkingMarker(
    Map<String, dynamic> park,
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final screenWidth = MediaQuery.of(context).size.width;
    final scale = (screenWidth / 375.0).clamp(0.85, 1.3);

    final int isOpen = park["isOpen"];
    final int capacity = int.tryParse(park["capacity"].toString()) ?? 0;
    final int empty = int.tryParse(park["emptyCapacity"].toString()) ?? 0;
    final double ratio = capacity == 0 ? 0 : empty / capacity;

    Color accent;
    if(isOpen == 1) {
      if (ratio > 0.5) {
        accent = Colors.green;
      } else if (ratio > 0.2) {
        accent = Colors.orange;
      } else {
        accent = Colors.red;
      }
    } else {
      accent =  Colors.grey;
    }

    final double lat = double.tryParse(park["lat"].toString()) ?? 0;
    final double lng = double.tryParse(park["lng"].toString()) ?? 0;

    return Marker(
      width: 170 * scale,
      height: 75 * scale,
      point: LatLng(lat, lng),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 14 * scale,
              vertical: 8 * scale,
            ),
            decoration: BoxDecoration(
              color: isOpen == 1 ? colorScheme.surface.withOpacity(0.95) : Colors.grey.withOpacity(0.95),
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
                    park["parkName"] ?? "Otopark",
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
    );
  }
}