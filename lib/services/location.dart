import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:metro_next_taipei/services/database.dart';

import 'package:flutter/foundation.dart' show kIsWeb;

Future<bool> _checkAndRequestLocationPermission(BuildContext context) async {
  LocationPermission permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  if (permission == LocationPermission.deniedForever) {
    if (context.mounted) {
      final shouldRetry = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('需要位置權限'),
          content: const Text('請啟用位置權限以尋找附近捷運站。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('取消'),
            ),
            if (!kIsWeb)
              TextButton(
                onPressed: () => openAppSettings(),
                child: const Text('打開設定'),
              ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('重試'),
            ),
          ],
        ),
      );

      if (shouldRetry == true && context.mounted) {
        return await _checkAndRequestLocationPermission(context);
      }
    }
    return false;
  }

  return await Geolocator.isLocationServiceEnabled();
}

Future<Position?> getCurrentPosition(BuildContext context) async {
  final ok = await _checkAndRequestLocationPermission(context);
  if (!ok) return null;
  try {
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  } catch (_) {
    return null;
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
