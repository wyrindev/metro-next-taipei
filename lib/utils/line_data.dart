import 'package:flutter/material.dart';

class LineData {
  final String id;
  final String name;
  final Color color;

  const LineData(this.id, this.name, this.color);
}

const List<LineData> taipeiMetroLines = [
  LineData('BR', '文湖線', Color(0xFFC48C31)),
  LineData('R', '淡水信義線', Color(0xFFE3002C)),
  LineData('G', '松山新店線', Color(0xFF008659)),
  LineData('O', '中和新蘆線', Color(0xFFF8B61C)),
  LineData('BL', '板南線', Color(0xFF0070BD)),
  LineData('Y', '環狀線', Color(0xFFFFD400)),
];

Color getLineColor(String lineId) {
  return taipeiMetroLines.firstWhere((line) => line.id == lineId, orElse: () => const LineData('U', '未知', Colors.grey)).color;
}
