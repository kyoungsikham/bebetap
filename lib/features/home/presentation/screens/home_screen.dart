import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/providers/database_provider.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../baby/presentation/providers/baby_provider.dart';
import '../../../family/presentation/providers/family_provider.dart';
import '../../../../shared/widgets/baby_avatar_widget.dart';
import '../widgets/baby_selector_sheet.dart';
import '../widgets/status_card.dart';
import '../widgets/stats_strip.dart';
import '../widgets/tracking_grid.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(familyRealtimeProvider); // 실시간 동기화 + 초기 pull 활성화
    final babiesAsync = ref.watch(babiesProvider);

    // 세션 복원 시 babies 로딩 중이면 스피너만 표시 (깜빡임 방지)
    if (babiesAsync.isLoading && !babiesAsync.hasValue) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(selectedBabyProvider);
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _HomeHeader(
                onMenuTap: () => _showHamburgerMenu(context, ref),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pagePadding,
                AppSpacing.md,
                AppSpacing.pagePadding,
                AppSpacing.pagePadding,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _TodayLabel(),
                  const SizedBox(height: AppSpacing.md),
                  const StatusCard(),
                  const SizedBox(height: AppSpacing.md),
                  const StatsStrip(),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    '기록하기',
                    style: AppTypography.titleMedium
                        .copyWith(color: AppColors.onSurface),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const TrackingGrid(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHamburgerMenu(BuildContext context, WidgetRef ref) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, _, _) => Align(
        alignment: Alignment.centerRight,
        child: Material(
          color: Colors.white,
          borderRadius: const BorderRadius.horizontal(
            left: Radius.circular(20),
          ),
          child: SafeArea(
            child: SizedBox(
              width: 280,
              height: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.child_care),
                      title: const Text('아이 관리'),
                      onTap: () {
                        final router = GoRouter.of(context);
                        Navigator.of(context, rootNavigator: true).pop();
                        Future.microtask(() => router.push(AppRoutes.babyManage));
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.widgets_outlined),
                      title: const Text('위젯 추가'),
                      onTap: () {
                        final messenger = ScaffoldMessenger.of(context);
                        Navigator.of(context, rootNavigator: true).pop();
                        Future.microtask(() => messenger.showSnackBar(
                            const SnackBar(content: Text('준비 중입니다'))));
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.grid_view_outlined),
                      title: const Text('아이콘 설정'),
                      onTap: () {
                        final router = GoRouter.of(context);
                        Navigator.of(context, rootNavigator: true).pop();
                        Future.microtask(
                            () => router.push(AppRoutes.iconSettings));
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.logout, color: AppColors.error),
                      title: Text(
                        '로그아웃',
                        style: AppTypography.bodyLarge
                            .copyWith(color: AppColors.error),
                      ),
                      onTap: () async {
                        Navigator.of(context, rootNavigator: true).pop();
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('로그아웃'),
                            content: const Text('로그아웃 하시겠어요?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: const Text('취소'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(true),
                                child: Text(
                                  '로그아웃',
                                  style: TextStyle(color: AppColors.error),
                                ),
                              ),
                            ],
                          ),
                        );
                        if (confirmed == true) {
                          final db = ref.read(appDatabaseProvider);
                          try {
                            await db.clearAllData();
                          } catch (e) {
                            debugPrint('clearAllData error (ignored): $e');
                          }
                          ref.invalidate(babiesProvider);
                          await Supabase.instance.client.auth.signOut();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      transitionBuilder: (_, anim, _, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
        child: child,
      ),
    );
  }
}

class _HomeHeader extends ConsumerWidget {
  const _HomeHeader({this.onMenuTap});

  final VoidCallback? onMenuTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topPadding = MediaQuery.of(context).padding.top;
    final baby = ref.watch(selectedBabyProvider).valueOrNull;
    final babies = ref.watch(babiesProvider).valueOrNull ?? [];
    final name = baby?.name ?? '아기';
    final canSwitch = babies.length > 1;
    final babyColorIndex = baby != null ? babies.indexWhere((b) => b.id == baby.id) : 0;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFEEF0),
            Color(0xFFFFF5F6),
            Color(0xFFFFFFFF),
          ],
          stops: [0.0, 0.6, 1.0],
        ),
      ),
      padding: EdgeInsets.only(
        top: topPadding + AppSpacing.sm,
        bottom: AppSpacing.lg,
        left: AppSpacing.pagePadding,
        right: AppSpacing.pagePadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단 바: BebeTap 로고 + 햄버거 메뉴
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'BebeTap',
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.menu),
                color: AppColors.onSurface,
                onPressed: onMenuTap,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          // 인사 영역: 텍스트(좌) + 아바타(우)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '안녕, $name!',
                      style: AppTypography.headlineMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '아기도 힘들지만 엄마 아빠도\n정말 수고하고 있을 거예요 💛',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.onSurfaceMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  BabyAvatarWidget(
                    photoUrl: baby?.photoUrl,
                    gender: baby?.gender,
                    colorIndex: babyColorIndex >= 0 ? babyColorIndex : null,
                    onTap: canSwitch
                        ? () => showBabySelectorSheet(context, ref)
                        : null,
                  ),
                  if (canSwitch)
                    Positioned(
                      bottom: -2,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.expand_more,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}


class _TodayLabel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdays[now.weekday - 1];
    return Text(
      '${now.month}월 ${now.day}일 $weekday요일',
      style: AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceMuted),
    );
  }
}
