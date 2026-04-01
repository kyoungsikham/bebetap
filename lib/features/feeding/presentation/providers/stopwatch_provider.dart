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
  // _tick()에서 화면 갱신용으로 사용. 일시정지된 쪽의 누적 시간을 보존.
  Duration _leftAccumulated = Duration.zero;
  Duration _rightAccumulated = Duration.zero;

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
    _leftAccumulated = Duration.zero;
    _rightAccumulated = Duration.zero;
    state = const BreastfeedingState();
  }

  void _pauseCurrent() {
    _timer?.cancel();
    _timer = null;
    if (state.activeSide != null && _sideStartedAt != null) {
      final elapsed = DateTime.now().difference(_sideStartedAt!);
      if (state.activeSide == 'left') {
        _leftAccumulated += elapsed;
      } else {
        _rightAccumulated += elapsed;
      }
      state = state.copyWith(
        leftDuration: _leftAccumulated,
        rightDuration: _rightAccumulated,
      );
      _sideStartedAt = null;
    }
  }

  /// 화면 갱신 전용: 누적값 + 현재 진행 중인 경과 시간을 표시
  void _tick() {
    if (state.activeSide == null || _sideStartedAt == null) return;
    final elapsed = DateTime.now().difference(_sideStartedAt!);
    if (state.activeSide == 'left') {
      state = state.copyWith(leftDuration: _leftAccumulated + elapsed);
    } else {
      state = state.copyWith(rightDuration: _rightAccumulated + elapsed);
    }
  }
}
