import 'package:flutter/foundation.dart';

@immutable
class TemperatureEntry {
  const TemperatureEntry({
    required this.id,
    required this.babyId,
    required this.familyId,
    required this.celsius,
    required this.method,
    required this.occurredAt,
  });

  final String id;
  final String babyId;
  final String familyId;
  final double celsius;
  final String method; // rectal | axillary | ear | forehead
  final DateTime occurredAt;

  String get methodLabel {
    switch (method) {
      case 'rectal':
        return '항문';
      case 'axillary':
        return '겨드랑이';
      case 'ear':
        return '귀';
      case 'forehead':
        return '이마';
      default:
        return method;
    }
  }

  bool get isFever => celsius >= 37.5;
  bool get isHighFever => celsius >= 38.5;
}
