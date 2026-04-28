import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_keys.dart';
import 'core/widget/widget_action_handler.dart';
import 'core/widget/widget_initial_sync_provider.dart';
import 'features/baby/presentation/providers/baby_provider.dart';
import 'l10n/app_localizations.dart';
import 'shared/providers/locale_provider.dart';
import 'shared/providers/theme_provider.dart';

class BebeTapApp extends ConsumerStatefulWidget {
  const BebeTapApp({super.key});

  @override
  ConsumerState<BebeTapApp> createState() => _BebeTapAppState();
}

class _BebeTapAppState extends ConsumerState<BebeTapApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final router = ref.read(appRouterProvider);
      WidgetActionHandler.init(ref, router);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    WidgetActionHandler.dispose();
    super.dispose();
  }

  /// 앱이 foreground로 돌아올 때 Android 위젯에서 변경된 아기 ID를 동기화한다.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _syncBabyFromWidget();
    }
  }

  Future<void> _syncBabyFromWidget() async {
    final widgetBabyId =
        await HomeWidget.getWidgetData<String>('widget_selected_baby_id');
    if (widgetBabyId == null || widgetBabyId.isEmpty) return;
    final currentId = ref.read(selectedBabyIdProvider);
    if (widgetBabyId != currentId) {
      await ref.read(selectedBabyIdProvider.notifier).select(widgetBabyId);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 앱 시작 시 DB 데이터를 위젯에 초기 동기화 (baby가 준비되면 자동 실행)
    ref.listen(widgetInitialSyncProvider, (_, _) {});

    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(localeProvider).valueOrNull ?? const Locale('ko');
    final themeMode = ref.watch(resolvedThemeModeProvider);
    ref.watch(scheduledThemeRefreshProvider);

    return MaterialApp.router(
      title: 'BebeTap',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
    );
  }
}
