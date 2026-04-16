import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/email_auth_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/baby/presentation/providers/baby_provider.dart';
import '../../features/baby/presentation/screens/baby_setup_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/log/presentation/screens/log_screen.dart';
import '../../features/statistics/presentation/screens/baby_food_stats_screen.dart';
import '../../features/statistics/presentation/screens/feeding_stats_screen.dart';
import '../../features/statistics/presentation/screens/growth_stats_screen.dart';
import '../../features/statistics/presentation/screens/sleep_stats_screen.dart';
import '../../features/statistics/presentation/screens/statistics_screen.dart';
import '../../features/family/presentation/screens/family_screen.dart';
import '../../features/baby/presentation/screens/baby_manage_screen.dart';
import '../../features/premium/presentation/screens/paywall_screen.dart';
import '../../features/settings/presentation/screens/icon_settings_screen.dart';
import '../../shared/widgets/bottom_nav_bar.dart';
import '../providers/auth_provider.dart';
import 'app_routes.dart';

part 'app_router.g.dart';

/// 페이드 전환 페이지 헬퍼.
CustomTransitionPage<void> _fadePage({
  required LocalKey key,
  required Widget child,
  Duration duration = const Duration(milliseconds: 200),
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    transitionsBuilder: (_, animation, _, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}

/// GoRouter의 refreshListenable로 사용. 인증/아기 상태 변경 시 리디렉션 재평가.
class _RouterRefreshNotifier extends ChangeNotifier {
  void refresh() => notifyListeners();
}

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final notifier = _RouterRefreshNotifier();

  ref.listen(authStateProvider, (prev, next) => notifier.refresh());
  ref.listen(babiesProvider, (prev, next) => notifier.refresh());
  ref.onDispose(notifier.dispose);

  return GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: notifier,
    redirect: (context, state) {
      final authAsync = ref.read(authStateProvider);
      final babiesAsync = ref.read(babiesProvider);

      final isLoggedIn = authAsync.valueOrNull?.session != null;
      final babies = babiesAsync.valueOrNull;
      final hasBaby = babies?.isNotEmpty ?? false;
      final babiesLoaded = babiesAsync.hasValue && !babiesAsync.isLoading;
      final loc = state.matchedLocation;

      // 0. 위젯 딥링크(bebetap://...)는 WidgetActionHandler가 처리하므로
      //    GoRouter에서는 홈으로 리다이렉트.
      if (state.uri.scheme == 'bebetap' ||
          loc.startsWith('bebetap://') ||
          loc.startsWith('/log/') ||
          loc.startsWith('/action/')) {
        return AppRoutes.home;
      }

      // 1. 비밀번호 재설정 이벤트 → 재설정 화면으로
      final authEvent = authAsync.valueOrNull?.event;
      if (authEvent == AuthChangeEvent.passwordRecovery) {
        return AppRoutes.resetPassword;
      }

      // 2. 미인증 → 로그인 화면으로 (email-auth는 회원가입용으로 허용)
      if (!isLoggedIn) {
        const publicRoutes = {AppRoutes.login, AppRoutes.emailAuth};
        return publicRoutes.contains(loc) ? null : AppRoutes.login;
      }

      // 3. 로그인/이메일인증 화면에서 인증됨 → 홈으로 이동
      if (loc == AppRoutes.login || loc == AppRoutes.emailAuth) {
        return AppRoutes.home;
      }

      // 4. babies 로딩 중이면 현재 위치 유지 (섣부른 리다이렉트 방지)
      if (!babiesLoaded) return null;

      // 5. babies 로딩 완료 후 아기 미등록 → 아기 설정 화면으로
      if (!hasBaby && loc != AppRoutes.babySetup) {
        return AppRoutes.babySetup;
      }

      // 6. 이미 아기가 있는데 설정 화면 접근 → 홈으로
      if (hasBaby && loc == AppRoutes.babySetup) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      // 인증
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (_, s) => _fadePage(
          key: s.pageKey,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.emailAuth,
        pageBuilder: (_, s) => _fadePage(
          key: s.pageKey,
          child: const EmailAuthScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.babySetup,
        pageBuilder: (_, s) => _fadePage(
          key: s.pageKey,
          child: const BabySetupScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.babyManage,
        pageBuilder: (_, s) => _fadePage(
          key: s.pageKey,
          child: const BabyManageScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.iconSettings,
        pageBuilder: (_, s) => _fadePage(
          key: s.pageKey,
          child: const IconSettingsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        pageBuilder: (_, s) => _fadePage(
          key: s.pageKey,
          child: const ResetPasswordScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.paywall,
        pageBuilder: (_, s) => _fadePage(
          key: s.pageKey,
          child: const PaywallScreen(),
        ),
      ),

      // 통계 하위 페이지 (바텀 네비 없음)
      GoRoute(
        path: AppRoutes.feedingStats,
        pageBuilder: (_, s) => _fadePage(
          key: s.pageKey,
          child: const FeedingStatsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.babyFoodStats,
        pageBuilder: (_, s) => _fadePage(
          key: s.pageKey,
          child: const BabyFoodStatsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.sleepStats,
        pageBuilder: (_, s) => _fadePage(
          key: s.pageKey,
          child: const SleepStatsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.growthStats,
        pageBuilder: (_, s) => _fadePage(
          key: s.pageKey,
          child: const GrowthStatsScreen(),
        ),
      ),

      // 메인 ShellRoute (5탭 바텀 네비)
      ShellRoute(
        builder: (context, state, child) =>
            ScaffoldWithBottomNav(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (_, s) => _fadePage(
              key: const ValueKey('home'),
              child: const HomeScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.statistics,
            pageBuilder: (_, s) => _fadePage(
              key: const ValueKey('statistics'),
              child: const StatisticsScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.log,
            pageBuilder: (_, s) => _fadePage(
              key: const ValueKey('log'),
              child: const LogScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.family,
            pageBuilder: (_, s) => _fadePage(
              key: const ValueKey('family'),
              child: const FamilyScreen(),
            ),
          ),
        ],
      ),
    ],
  );
}
