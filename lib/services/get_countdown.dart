import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:metro_next_taipei/models/train.dart';

Future<Map<String, Train>> _processTrainData(
  Map<String, dynamic> jsonData,
) async {
  Map<String, Train> bestTrains = {};
  final details = jsonData['data']?['Details'] ?? [];
  if (details is! List) return bestTrains;

  for (var item in details) {
    try {
      final train = Train.fromJson(item as Map<String, dynamic>);
      if (train.destination.isEmpty) continue;
      if (!bestTrains.containsKey(train.destination) ||
          train.baseRemainingSeconds <
              bestTrains[train.destination]!.baseRemainingSeconds) {
        bestTrains[train.destination] = train;
      }
    } catch (_) {
      continue;
    }
  }

  return bestTrains;
}

Future<Map<String, Train>?> cd(String stnId) async {
  try {
    final targetUrl =
        'https://ws.metro.taipei/TrtcAppWeb/GetNextTrain?stnid=$stnId';

    final url = kIsWeb
        ? Uri.parse('https://api.allorigins.win/raw?url=$targetUrl')
        : Uri.parse(targetUrl);

    final response = await http.post(
      url,
      headers: {
        'User-Agent': 'okhttp/4.9.3',
        'Accept-Encoding': 'gzip',
        'Content-Type': 'text/plain; charset=utf-8',
      },
    );

    if (response.statusCode.toString().startsWith('2')) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      if (body['status'] == true || body['status'] == 'true') {
        return await _processTrainData(body);
      }
    } else {
      debugPrint('cd(): Failed to fetch with status: ${response.statusCode}');
    }
  } catch (e) {
    debugPrint('cd(): Exception $e');
  }
  return null;
}