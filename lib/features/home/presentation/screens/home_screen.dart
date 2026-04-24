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
import '../../../log/domain/models/timeline_entry.dart';
import '../../../log/presentation/providers/log_provider.dart';
import '../../../log/presentation/utils/log_sheet_actions.dart';
import '../../../log/presentation/widgets/date_navigator.dart';
import '../../../log/presentation/widgets/log_stats_strip.dart';
import '../../../log/presentation/widgets/timeline_item_tile.dart';
import '../../../statistics/presentation/providers/statistics_provider.dart';
import '../../../statistics/presentation/widgets/insight_card.dart';

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

    final timelineAsync = ref.watch(filteredLogTimelineProvider);
    final selectedDate = ref.watch(selectedLogDateProvider);
    final isToday = DateUtils.isSameDay(selectedDate, DateTime.now());

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
                AppSpacing.xs,
                AppSpacing.pagePadding,
                0,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const _ExpandableInsights(),
                  const SizedBox(height: AppSpacing.md),
                ]),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pagePadding - 4,
                ),
                child: const DateNavigator(),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pagePadding,
                ),
                child: LogStatsStrip(
                  onTapCategory: (type) =>
                      openAddSheetForType(context, ref, type),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
            const SliverToBoxAdapter(
              child: Divider(height: 1, color: Color(0xFFDDDDDD)),
            ),
            timelineAsync.when(
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => SliverFillRemaining(
                child: Center(
                  child: Text(
                    context.l10n.logLoadFailed,
                    style: AppTypography.bodyMedium.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.55),
                    ),
                  ),
                ),
              ),
              data: (entries) {
                if (entries.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.event_note_outlined,
                            size: 48,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            context.l10n.noLogForDay,
                            style: AppTypography.bodyMedium
                                .copyWith(color: AppColors.onSurfaceMuted),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            context.l10n.addLogHint,
                            style: AppTypography.bodySmall
                                .copyWith(color: AppColors.onSurfaceMuted),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                // 분유·모유·유축·이유식 중 가장 최근 기록된 단 하나의 항목 ID
                const feedingTypes = {
                  TimelineEntryType.formula,
                  TimelineEntryType.breast,
                  TimelineEntryType.pumped,
                  TimelineEntryType.babyFood,
                };
                final lastFeedingId = entries
                    .where((e) => feedingTypes.contains(e.type))
                    .map((e) => e.id)
                    .firstOrNull;

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pagePadding,
                    AppSpacing.md,
                    AppSpacing.pagePadding,
                    AppSpacing.pagePadding,
                  ),
                  sliver: SliverList.builder(
                    itemCount: entries.length,
                    itemBuilder: (context, i) => TimelineItemTile(
                      entry: entries[i],
                      isFirst: i == 0,
                      isLast: i == entries.length - 1,
                      showElapsed: isToday && lastFeedingId == entries[i].id,
                      onTap: () => openEditSheet(context, ref, entries[i]),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeHeader extends ConsumerStatefulWidget {
  const _HomeHeader({this.onMenuTap});

  final VoidCallback? onMenuTap;

  @override
  ConsumerState<_HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends ConsumerState<_HomeHeader> {
  final _avatarKey = GlobalKey();

  void _showBabyPopup(List babies, String? currentId) {
    final box =
        _avatarKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final pos = box.localToGlobal(Offset.zero);
    final size = box.size;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        pos.dx,
        pos.dy + size.height + 6,
        pos.dx + size.width,
        pos.dy + size.height + 6,
      ),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      items: babies.asMap().entries.map<PopupMenuEntry<String>>((entry) {
        final index = entry.key;
        final baby = entry.value;
        final isSelected = baby.id == currentId;
        return PopupMenuItem<String>(
          value: baby.id,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              BabyAvatarWidget(
                photoUrl: baby.photoUrl,
                gender: baby.gender,
                colorIndex: index,
                size: 36,
              ),
              const SizedBox(width: 10),
              Text(
                baby.name,
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.normal,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 6),
                const Icon(Icons.check, size: 16),
              ],
            ],
          ),
        );
      }).toList(),
    ).then((selectedId) {
      if (selectedId != null) {
        ref.read(selectedBabyIdProvider.notifier).select(selectedId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final baby = ref.watch(selectedBabyProvider).valueOrNull;
    final babies = ref.watch(babiesProvider).valueOrNull ?? [];
    final name = baby?.name ?? context.l10n.userLabel;
    final canSwitch = babies.isNotEmpty;
    final ageLabel =
        baby != null ? babyAgeLabel(context, baby.birthDate) : null;
    final babyColorIndex =
        baby != null ? babies.indexWhere((b) => b.id == baby.id) : 0;
    final selectedId = ref.watch(selectedBabyIdProvider);

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
        top: topPadding + AppSpacing.xs,
        bottom: AppSpacing.xs,
        left: AppSpacing.pagePadding,
        right: AppSpacing.pagePadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단 바: 아바타 + 이름 + 개월수 + 햄버거 메뉴
          Row(
            children: [
              Stack(
                key: _avatarKey,
                clipBehavior: Clip.none,
                children: [
                  BabyAvatarWidget(
                    photoUrl: baby?.photoUrl,
                    gender: baby?.gender,
                    colorIndex: babyColorIndex >= 0 ? babyColorIndex : null,
                    size: 48,
                    onTap: canSwitch
                        ? () => _showBabyPopup(babies, selectedId)
                        : null,
                  ),
                  if (babies.length > 1)
                    Positioned(
                      bottom: -2,
                      right: -2,
                      child: GestureDetector(
                        onTap: () => _showBabyPopup(babies, selectedId),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.55),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context)
                                  .scaffoldBackgroundColor
                                  .withValues(alpha: 0.7),
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.expand_more,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 8),
              Text(
                name,
                style: AppTypography.titleLarge,
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
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.menu),
                onPressed: widget.onMenuTap,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          // 일일 메시지 (부드러운 페이드인 + 살짝 위로)
          _DailyMessageText(
            message: ref.watch(dailyMessageProvider),
            color: ref.watch(
              dailyMessageColorProvider(
                isDark ? Brightness.dark : Brightness.light,
              ),
            ),
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

/// 일일 메시지: 최초 등장 시 페이드인 + 살짝 위로 슬라이드,
/// 메시지 변경 시 크로스페이드, 평상시 아주 느린 호흡 같은 투명도 변화.
class _DailyMessageText extends StatefulWidget {
  const _DailyMessageText({required this.message, required this.color});

  final String message;
  final Color color;

  @override
  State<_DailyMessageText> createState() => _DailyMessageTextState();
}

class _DailyMessageTextState extends State<_DailyMessageText>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _breathController;
  late final Animation<double> _entryOpacity;
  late final Animation<double> _entrySlide;
  late final Animation<double> _breath;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _entryOpacity = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOutCubic,
    );
    _entrySlide = Tween<double>(begin: 4, end: 0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
    );

    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );
    _breath = Tween<double>(begin: 1.0, end: 0.72).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );

    _entryController.forward().then((_) {
      if (mounted) _breathController.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    _breathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_entryController, _breathController]),
      builder: (context, child) {
        final opacity = _entryOpacity.value * _breath.value;
        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, _entrySlide.value),
            child: child,
          ),
        );
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: Text(
          widget.message,
          key: ValueKey(widget.message),
          style: AppTypography.bodySmall.copyWith(color: widget.color),
        ),
      ),
    );
  }
}
