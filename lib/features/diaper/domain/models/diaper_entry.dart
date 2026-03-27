import 'package:flutter/foundation.dart';

@immutable
class DiaperEntry {
  const DiaperEntry({
    required this.id,
    required this.babyId,
    required this.familyId,
    required this.type,
    required this.occurredAt,
  });

  final String id;
  final String babyId;
  final String familyId;
  final String type; // wet | soiled | both | dry
  final DateTime occurredAt;

  String get typeLabel {
    switch (type) {
      case 'wet':
        return '소변';
      case 'soiled':
        return '대변';
      case 'both':
        return '소변+대변';
      case 'dry':
        return '교체';
      default:
        return type;
    }
  }
}
