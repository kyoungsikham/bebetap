import 'package:flutter/material.dart';

enum InsightType { prediction, correlation, anomaly }

enum InsightSeverity { info, warning, alert }

@immutable
class Insight {
  const Insight({
    required this.type,
    required this.severity,
    required this.titleKey,
    required this.bodyKey,
    this.bodyArgs = const {},
    required this.icon,
  });

  final InsightType type;
  final InsightSeverity severity;
  final String titleKey;
  final String bodyKey;
  final Map<String, String> bodyArgs;
  final IconData icon;

  Color get color {
    switch (severity) {
      case InsightSeverity.info:
        return const Color(0xFF5B7FFF);
      case InsightSeverity.warning:
        return const Color(0xFFFFD166);
      case InsightSeverity.alert:
        return const Color(0xFFEF767A);
    }
  }
}
