import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'stopwatch_provider.g.dart';

@immutable
class BreastfeedingState {
  const BreastfeedingState({
    this.isActive = false,
    this.activeSide,
    this.leftDuration = Duration.zero,
    this.rightDuration = Duration.zero,
    this.sessionStartedAt,
  });

  final bool isActive;
  final String? activeSide; // 'left' | 'right' | null (일시정지)
  final Duration leftDuration;
  final Duration rightDuration;
  final DateTime? sessionStartedAt;

  Duration get totalDuration => leftDuration + rightDuration;

  BreastfeedingState copyWith({
    bool? isActive,
    Object? activeSide = _sentinel,
    Duration? leftDuration,
    Duration? rightDuration,
    Object? sessionStartedAt = _sentinel,
  }) =>
      BreastfeedingState(
        isActive: isActive ?? this.isActive,
        activeSide:
            activeSide == _sentinel ? this.activeSide : activeSide as String?,
        leftDuration: leftDuration ?? this.leftDuration,
        rightDuration: rightDuration ?? this.rightDuration,
        sessionStartedAt: sessionStartedAt == _sentinel
            ? this.sessionStartedAt
            : sessionStartedAt as DateTime?,
      );

  static const Object _sentinel = Object();
}

@riverpod
class BreastfeedingStopwatch extends _$BreastfeedingStopwatch {
  Timer? _timer;
  DateTime? _sideStartedAt;

  @override
  BreastfeedingState build() {
    ref.onDispose(() => _timer?.cancel());
    return const BreastfeedingState();
  }

  void startSide(String side) {
    _pauseCurrent();
    _sideStartedAt = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    state = state.copyWith(
      isActive: true,
      activeSide: side,
      sessionStartedAt: state.sessionStartedAt ?? DateTime.now(),
    );
  }

  void pauseSide() {
    _pauseCurrent();
    state = state.copyWith(activeSide: null);
  }

  void reset() {
    _timer?.cancel();
    _timer = null;
    _sideStartedAt = null;
    state = const BreastfeedingState();
  }

  void _pauseCurrent() {
    _timer?.cancel();
    _timer = null;
    if (state.activeSide != null && _sideStartedAt != null) {
      final elapsed = DateTime.now().difference(_sideStartedAt!);
      if (state.activeSide == 'left') {
        state = state.copyWith(leftDuration: state.leftDuration + elapsed);
      } else {
        state = state.copyWith(rightDuration: state.rightDuration + elapsed);
      }
      _sideStartedAt = null;
    }
  }

  void _tick() {
    if (state.activeSide == null) return;
    if (state.activeSide == 'left') {
      state = state.copyWith(
        leftDuration: state.leftDuration + const Duration(seconds: 1),
      );
    } else {
      state = state.copyWith(
        rightDuration: state.rightDuration + const Duration(seconds: 1),
      );
    }
  }
}
