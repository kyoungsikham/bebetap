import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../baby/domain/models/baby.dart';
import '../../../baby/presentation/providers/baby_provider.dart';
import '../../../family/presentation/providers/family_provider.dart';
import '../widgets/status_card.dart';
import '../widgets/stats_strip.dart';
import '../widgets/tracking_grid.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(familyRealtimeProvider); // 실시간 동기화 + 초기 pull 활성화
    final babiesAsync = ref.watch(babiesProvider);
    final babyAsync = ref.watch(selectedBabyProvider);

    // 세션 복원 시 babies 로딩 중이면 스피너만 표시 (깜빡임 방지)
    if (babiesAsync.isLoading && !babiesAsync.hasValue) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final baby = babyAsync.valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(selectedBabyProvider);
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _HomeHeader(baby: baby),
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

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({this.baby});

  final Baby? baby;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final name = baby?.name ?? '아기';

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
                onPressed: () {},
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
              _BabyAvatar(photoUrl: baby?.photoUrl),
            ],
          ),
        ],
      ),
    );
  }
}

class _BabyAvatar extends StatelessWidget {
  const _BabyAvatar({this.photoUrl});

  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFFFD6DA),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB3BC).withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: photoUrl != null && photoUrl!.isNotEmpty
          ? Image.network(
              photoUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => _defaultIcon(),
            )
          : _defaultIcon(),
    );
  }

  Widget _defaultIcon() {
    return const Icon(
      Icons.child_care,
      color: Color(0xFFFF6B8A),
      size: 36,
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
