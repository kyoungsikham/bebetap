import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/widget/widget_action_handler.dart';
import 'core/widget/widget_initial_sync_provider.dart';
import 'l10n/app_localizations.dart';
import 'shared/providers/locale_provider.dart';
import 'shared/providers/theme_provider.dart';

class BebeTapApp extends ConsumerStatefulWidget {
  const BebeTapApp({super.key});

  @override
  ConsumerState<BebeTapApp> createState() => _BebeTapAppState();
}

class _BebeTapAppState extends ConsumerState<BebeTapApp> {
  @override
  void initState() {
    super.initState();
    // 라우터가 준비된 후 핸들러 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final router = ref.read(appRouterProvider);
      WidgetActionHandler.init(ref, router);
    });
  }

  @override
  void dispose() {
    WidgetActionHandler.dispose();
    super.dispose();
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
