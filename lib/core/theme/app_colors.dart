import 'package:flutter/material.dart';

abstract class AppColors {
  // Backgrounds
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF8F8F8);
  static const Color surfaceVariant = Color(0xFFF2F2F5);

  // Brand
  static const Color primary = Color(0xFF5B7FFF);
  static const Color secondary = Color(0xFFB4C5FF);

  // Text
  static const Color onSurface = Color(0xFF1A1A2E);
  static const Color onSurfaceMuted = Color(0xFF8A8A9A);

  // Semantic
  static const Color success = Color(0xFF6BCB77);
  static const Color warning = Color(0xFFFFD166);
  static const Color error = Color(0xFFEF767A);

  // Divider
  static const Color divider = Color(0xFFEBEBEF);

  // White / on-primary
  static const Color onPrimary = Color(0xFFFFFFFF);

  // Bottom nav 활성 색상 (헤더 그라디언트와 어울리는 따뜻한 코랄)
  static const Color bottomNavActive = Color(0xFFE85D7A);

  // ── Dark mode ────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF121218);
  static const Color darkSurface = Color(0xFF1E1E26);
  static const Color darkSurfaceVariant = Color(0xFF2A2A34);
  static const Color darkOnSurface = Color(0xFFE8E8EC);
  static const Color darkOnSurfaceMuted = Color(0xFF9A9AAA);
  static const Color darkDivider = Color(0xFF2E2E38);
}
