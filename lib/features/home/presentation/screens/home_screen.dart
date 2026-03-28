import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../baby/presentation/providers/baby_provider.dart';
import '../widgets/status_card.dart';
import '../widgets/stats_strip.dart';
import '../widgets/tracking_grid.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final babiesAsync = ref.watch(babiesProvider);
    final babyAsync = ref.watch(selectedBabyProvider);

    // 세션 복원 시 babies 로딩 중이면 스피너만 표시 (깜빡임 방지)
    if (babiesAsync.isLoading && !babiesAsync.hasValue) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: babyAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const Text('BebeTap'),
          data: (baby) => Text(
            baby != null ? '${baby.name}의 하루' : 'BebeTap',
            style: AppTypography.titleLarge,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined),
            color: AppColors.onSurface,
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(selectedBabyProvider);
        },
        child: CustomScrollView(
          slivers: [
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
                  const SizedBox(height: AppSpacing.xl),
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
