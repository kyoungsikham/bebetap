import 'dart:async' show unawaited;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/baby/presentation/providers/baby_provider.dart';
import 'widget_refresh_helper.dart';

/// 앱 시작 시 선택된 아기가 준비되면 자동으로 위젯 데이터를 동기화한다.
/// app.dart의 build 메서드에서 ref.listen으로 구독하여 provider를 활성화한다.
final widgetInitialSyncProvider = FutureProvider<void>((ref) async {
  final baby = await ref.watch(selectedBabyProvider.future);
  if (baby == null) return;

  unawaited(refreshWidget(ref));
});
