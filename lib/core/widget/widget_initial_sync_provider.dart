import 'dart:async' show unawaited;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/baby/presentation/providers/baby_provider.dart';
import '../../shared/providers/widget_settings_provider.dart';
import '../widget/widget_sync_service.dart';
import 'widget_refresh_helper.dart';

/// 앱 시작 시 선택된 아기와 전체 목록이 준비되면 위젯 데이터를 자동 동기화한다.
/// app.dart의 build 메서드에서 ref.listen으로 구독하여 provider를 활성화한다.
final widgetInitialSyncProvider = FutureProvider<void>((ref) async {
  // 두 provider를 모두 watch — 아기 목록 또는 선택이 바뀌면 재동기화
  final baby = await ref.watch(selectedBabyProvider.future);
  await ref.watch(babiesProvider.future); // 목록 변경 감지용
  if (baby == null) return;

  final settings = await ref.watch(widgetSettingsProvider.future);
  unawaited(WidgetSyncService.pushSettings(settings));
  unawaited(refreshWidget(ref));
});
