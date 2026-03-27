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
import '../../features/statistics/presentation/screens/statistics_screen.dart';
import '../../features/family/presentation/screens/family_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../shared/widgets/bottom_nav_bar.dart';
import '../providers/auth_provider.dart';
import 'app_routes.dart';

part 'app_router.g.dart';

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
      final hasBaby = babiesAsync.valueOrNull?.isNotEmpty ?? false;
      final babiesLoaded = babiesAsync.hasValue;
      final loc = state.matchedLocation;

      // 비밀번호 재설정 이벤트 → 재설정 화면으로 (인증 여부 무관)
      final authEvent = authAsync.valueOrNull?.event;
      if (authEvent == AuthChangeEvent.passwordRecovery) {
        return AppRoutes.resetPassword;
      }

      // 미인증 → 로그인 화면으로 (email-auth는 회원가입용으로 허용)
      if (!isLoggedIn) {
        const publicRoutes = {AppRoutes.login, AppRoutes.emailAuth};
        return publicRoutes.contains(loc) ? null : AppRoutes.login;
      }

      // 로그인 화면에 있고 이미 인증됨 → 적절한 화면으로
      if (loc == AppRoutes.login) {
        if (!babiesLoaded) return AppRoutes.home; // 아기 로딩 중엔 홈으로 (스켈레톤 표시)
        return hasBaby ? AppRoutes.home : AppRoutes.babySetup;
      }

      // 아기 미등록 → 아기 설정 화면으로 (email-auth는 비밀번호 설정 완료까지 유지)
      if (babiesLoaded && !hasBaby && loc != AppRoutes.babySetup && loc != AppRoutes.emailAuth) {
        return AppRoutes.babySetup;
      }

      // 이미 아기가 있는데 설정 화면 접근 → 홈으로
      if (hasBaby && loc == AppRoutes.babySetup) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      // 인증
      GoRoute(
        path: AppRoutes.login,
        builder: (_, s) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.emailAuth,
        builder: (_, s) => const EmailAuthScreen(),
      ),
      GoRoute(
        path: AppRoutes.babySetup,
        builder: (_, s) => const BabySetupScreen(),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        builder: (_, s) => const ResetPasswordScreen(),
      ),

      // 메인 ShellRoute (5탭 바텀 네비)
      ShellRoute(
        builder: (context, state, child) =>
            ScaffoldWithBottomNav(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (_, s) =>
                const NoTransitionPage(child: HomeScreen()),
          ),
          GoRoute(
            path: AppRoutes.statistics,
            pageBuilder: (_, s) =>
                const NoTransitionPage(child: StatisticsScreen()),
          ),
          GoRoute(
            path: AppRoutes.log,
            pageBuilder: (_, s) =>
                const NoTransitionPage(child: HomeScreen()),
          ),
          GoRoute(
            path: AppRoutes.family,
            pageBuilder: (_, s) =>
                const NoTransitionPage(child: FamilyScreen()),
          ),
          GoRoute(
            path: AppRoutes.settings,
            pageBuilder: (_, s) =>
                const NoTransitionPage(child: SettingsScreen()),
          ),
        ],
      ),
    ],
  );
}
