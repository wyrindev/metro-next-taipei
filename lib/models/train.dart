import 'package:flutter/material.dart';

class Train {
  final String stnid;
  final String destination;
  final String countdown;
  final String updatetime;
  final String nowtime;
  final DateTime fetchedAt;
  final int baseRemainingSeconds;
  final Color lineColor;

  Train._internal({
    required this.stnid,
    required this.destination,
    required this.countdown,
    required this.updatetime,
    required this.nowtime,
    required this.fetchedAt,
    required this.baseRemainingSeconds,
    required this.lineColor,
  });

  factory Train.fromJson(Map<String, dynamic> json) {
    final stnid = (json['stnid'] ?? '').toString();
    final destination = (json['destination'] ?? '').toString();
    final countdown = (json['countdown'] ?? '0:00').toString();
    final updatetime = (json['updatetime'] ?? '').toString();
    final nowtime = (json['nowtime'] ?? '').toString();

    Color lineColor;
    final match = RegExp(r'[A-Za-z]+').firstMatch(stnid)?.group(0);

    switch (match) {
      case 'BL':
        lineColor = Colors.blue;
        break;
      case 'G':
        lineColor = Colors.green;
        break;
      case 'R':
        lineColor = Colors.red;
        break;
      case 'Y':
        lineColor = Colors.yellow;
        break;
      case 'BR':
        lineColor = Colors.brown;
        break;
      case 'O':
        lineColor = Colors.orange;
        break;
      case 'B':
        lineColor = Colors.brown;
        break;
      default:
        lineColor = Colors.grey;
    }

    int countdownSeconds = 0;
    try {
      final parts = countdown.split(':');
      if (parts.length >= 2) {
        countdownSeconds = int.parse(parts[0]) * 60 + int.parse(parts[1]);
      } else {
        countdownSeconds = int.parse(parts[0]) * 60;
      }
    } catch (_) {
      countdownSeconds = 0;
    }

    int remaining = countdownSeconds;
    if (remaining < 0) remaining = 0;

    return Train._internal(
      stnid: stnid,
      destination: destination,
      countdown: countdown,
      updatetime: updatetime,
      nowtime: nowtime,
      fetchedAt: DateTime.now(),
      baseRemainingSeconds: remaining,
      lineColor: lineColor,
    );
  }

  /// 當前剩餘秒數 = baseRemainingSeconds - (now - fetchedAt)
  int get remainingTime {
    final elapsed = DateTime.now().difference(fetchedAt).inSeconds;
    final updateLatency = DateTime.parse(
      nowtime.trim(),
    ).difference(DateTime.parse(updatetime.trim())).inSeconds;
    final rem = baseRemainingSeconds - elapsed - updateLatency;
    return rem > 0 ? rem : 0;
  }

  String get displayCountdown {
    final rt = remainingTime;
    if (rt <= 0) return '已到站';
    if (rt <= 35) return '即將進站';
    // 無條件進位到 5 秒倍數
    final rounded = ((rt + 4) ~/ 5) * 5;
    final m = rounded ~/ 60;
    final s = rounded % 60;
    if (m > 0) {
      return '$m分${s.toString().padLeft(2, '0')}秒';
    } else {
      return '0分${s.toString()}秒';
    }
  }
}
