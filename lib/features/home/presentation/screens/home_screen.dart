import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/extensions/l10n_ext.dart';
import '../../../../shared/utils/baby_age.dart';
import '../../../../shared/widgets/baby_avatar_widget.dart';
import '../../../../shared/widgets/hamburger_menu_panel.dart';
import '../../../baby/presentation/providers/baby_provider.dart';
import '../../../daily_message/presentation/providers/daily_message_provider.dart';
import '../../../family/presentation/providers/family_provider.dart';
import '../widgets/baby_selector_sheet.dart';
import '../widgets/stats_strip.dart';
import '../../../statistics/presentation/providers/statistics_provider.dart';
import '../../../statistics/presentation/widgets/insight_card.dart';
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
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(selectedBabyProvider);
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _HomeHeader(
                onMenuTap: () => showHamburgerMenu(context, ref),
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
                  const _ExpandableInsights(),
                  const SizedBox(height: AppSpacing.md),
                  const StatsStrip(),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    context.l10n.sectionRecord,
                    style: AppTypography.titleMedium.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
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

class _HomeHeader extends ConsumerWidget {
  const _HomeHeader({this.onMenuTap});

  final VoidCallback? onMenuTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topPadding = MediaQuery.of(context).padding.top;
    final baby = ref.watch(selectedBabyProvider).valueOrNull;
    final babies = ref.watch(babiesProvider).valueOrNull ?? [];
    final name = baby?.name ?? context.l10n.userLabel;
    final canSwitch = babies.length > 1;
    final ageLabel = baby != null ? babyAgeLabel(context, baby.birthDate) : null;
    final babyColorIndex =
        baby != null ? babies.indexWhere((b) => b.id == baby.id) : 0;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [
                  Color(0xFF1A1020),
                  Color(0xFF161520),
                  Color(0xFF121218),
                ]
              : const [
                  Color(0xFFFFEEF0),
                  Color(0xFFFFF5F6),
                  Color(0xFFFFFFFF),
                ],
          stops: const [0.0, 0.6, 1.0],
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          name,
                          style: AppTypography.headlineMedium,
                        ),
                        if (ageLabel != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            ageLabel,
                            style: AppTypography.bodyMedium.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      ref.watch(dailyMessageProvider),
                      style: AppTypography.bodyMedium.copyWith(
                        color: ref.watch(
                          dailyMessageColorProvider(
                            isDark ? Brightness.dark : Brightness.light,
                          ),
                        ),
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


class _ExpandableInsights extends ConsumerStatefulWidget {
  const _ExpandableInsights();

  @override
  ConsumerState<_ExpandableInsights> createState() =>
      _ExpandableInsightsState();
}

class _ExpandableInsightsState extends ConsumerState<_ExpandableInsights> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final insightsAsync = ref.watch(parentInsightsProvider);
    return insightsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (insights) {
        if (insights.isEmpty) return const SizedBox.shrink();
        final l10n = context.l10n;
        final first = insights.first;
        final firstBody = resolveInsightBody(l10n, first);
        final hasMore = insights.length > 1;

        return Column(
          children: [
            // 첫 번째 인사이트 (접힌 상태에서도 항상 표시)
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm + 2,
                  vertical: AppSpacing.xs + 2,
                ),
                decoration: BoxDecoration(
                  color: first.color.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: first.color.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(first.icon, color: first.color, size: 14),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        firstBody,
                        style: AppTypography.bodySmall.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.8),
                          height: 1.4,
                        ),
                        maxLines: _expanded ? null : 1,
                        overflow:
                            _expanded ? null : TextOverflow.ellipsis,
                      ),
                    ),
                    if (hasMore || firstBody.length > 20)
                      Icon(
                        _expanded
                            ? Icons.expand_less
                            : Icons.expand_more,
                        size: 16,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.4),
                      ),
                  ],
                ),
              ),
            ),
            // 나머지 인사이트 (펼침 상태에서만 표시)
            if (_expanded && hasMore)
              for (final insight in insights.skip(1)) ...[
                const SizedBox(height: AppSpacing.xs),
                InsightCard(
                  insight: insight,
                  resolvedBody: resolveInsightBody(l10n, insight),
                ),
              ],
          ],
        );
      },
    );
  }
}

class _TodayLabel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final now = DateTime.now();
    final weekdays = [
      l10n.weekdayMon,
      l10n.weekdayTue,
      l10n.weekdayWed,
      l10n.weekdayThu,
      l10n.weekdayFri,
      l10n.weekdaySat,
      l10n.weekdaySun,
    ];
    final weekday = weekdays[now.weekday - 1];
    return Text(
      l10n.dateFormatFull(now.month, now.day, weekday),
      style:
          AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceMuted),
    );
  }
}
