import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:metro_next_taipei/services/database_service.dart';

class LocationResult {
  final Position? position;
  final bool permissionDenied;
  LocationResult(this.position, {this.permissionDenied = false});
}

Future<LocationResult> getCurrentPosition(BuildContext context) async {
  LocationPermission permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
    return LocationResult(null, permissionDenied: true);
  }

  if (!await Geolocator.isLocationServiceEnabled()) {
    return LocationResult(null);
  }

  try {
    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
    return LocationResult(pos);
  } catch (_) {
    return LocationResult(null);
  }
}

double haversine(double lat1, double lon1, double lat2, double lon2) {
  double degToRad(double deg) => deg * pi / 180;
  const R = 6371;
  final dLat = degToRad(lat2 - lat1);
  final dLon = degToRad(lon2 - lon1);
  final a =
      sin(dLat / 2) * sin(dLat / 2) +
      cos(degToRad(lat1)) * cos(degToRad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return R * c;
}

Future<List<Map<String, dynamic>>> findNearestStations(
  String jsonPath,
  double targetLat,
  double targetLon, {
  int count = 3,
}) async {
  final List<Map<String, dynamic>> stations = [];

  metroDb.forEach((name, stationData) {
    try {
      final entrances = stationData['Entrances'];
      if (entrances == null || entrances is! List || entrances.isEmpty) {
        return;
      }
      double minDistance = double.infinity;
      for (var e in entrances) {
        if (e == null) continue;
        final lat = (e['Latitude'] is num)
            ? (e['Latitude'] as num).toDouble()
            : null;
        final lon = (e['Longitude'] is num)
            ? (e['Longitude'] as num).toDouble()
            : null;
        if (lat == null || lon == null) continue;
        final d = haversine(targetLat, targetLon, lat, lon);
        if (d < minDistance) minDistance = d;
      }

      String id = '';
      try {
        final apiIds = stationData['ApiStnIds'];
        if (apiIds is List && apiIds.isNotEmpty && apiIds[0] != null) {
          id = apiIds[0].toString();
        }
      } catch (_) {
        id = '';
      }

      final stationName = stationData['Station']?.toString() ?? name;
      if (minDistance == double.infinity) return;
      stations.add({
        'station': stationName,
        'id': id,
        'distance': minDistance,
        'raw': stationData,
      });
    } catch (e) {
      debugPrint('findNearestStations: skip $name due to $e');
    }
  });

  stations.sort(
    (a, b) => (a['distance'] as double).compareTo(b['distance'] as double),
  );
  return stations.take(count).toList();
}
