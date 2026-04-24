import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/extensions/l10n_ext.dart';
import '../../../../shared/utils/baby_age.dart';
import '../../../../shared/widgets/baby_avatar_widget.dart';
import '../../../../shared/widgets/hamburger_menu_panel.dart';
import '../../../../core/widget/widget_action_handler.dart';
import '../../../baby/presentation/providers/baby_provider.dart';
import '../../domain/models/timeline_entry.dart';
import '../providers/log_provider.dart';
import '../utils/log_sheet_actions.dart';
import '../widgets/date_navigator.dart';
import '../widgets/log_stats_strip.dart';
import '../widgets/timeline_item_tile.dart';

class LogScreen extends ConsumerStatefulWidget {
  const LogScreen({super.key});

  @override
  ConsumerState<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends ConsumerState<LogScreen> {
  @override
  void initState() {
    super.initState();
    // 위젯 클릭으로 pendingWidgetTabProvider가 설정된 경우 바텀 시트 자동 열기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndOpenPendingTab();
    });
  }

  void _checkAndOpenPendingTab() {
    final pendingTab = ref.read(pendingWidgetTabProvider);
    if (pendingTab != null) {
      ref.read(pendingWidgetTabProvider.notifier).state = null;
      openAddSheetForTab(context, ref, pendingTab);
    }
  }

  @override
  Widget build(BuildContext context) {
    // pendingWidgetTabProvider 변경 시 바텀 시트 자동 열기 (앱이 이미 열려 있는 경우)
    ref.listen(pendingWidgetTabProvider, (prev, next) {
      if (next != null) {
        ref.read(pendingWidgetTabProvider.notifier).state = null;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) openAddSheetForTab(context, ref, next);
        });
      }
    });

    final timelineAsync = ref.watch(filteredLogTimelineProvider);

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LogHeader(onMenuTap: () => showHamburgerMenu(context, ref)),
          // 날짜 네비게이터
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pagePadding - 4,
            ),
            child: const DateNavigator(),
          ),
          const SizedBox(height: AppSpacing.md),

          // 요약 스트립 (탭 시 해당 카테고리 기록 추가)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pagePadding,
            ),
            child: LogStatsStrip(
              onTapCategory: (type) => openAddSheetForType(context, ref, type),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          const Divider(height: 1, color: Color(0xFFDDDDDD)),

          // 타임라인
          Expanded(
            child: timelineAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text(
                  context.l10n.logLoadFailed,
                  style: AppTypography.bodyMedium.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.55)),
                ),
              ),
              data: (entries) {
                if (entries.isEmpty) {
                  return Center(
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
                  );
                }
                // 분유·모유·유축·이유식 중 가장 최근 기록된 단 하나의 항목 ID
                // (entries는 최신순 정렬 → 4개 타입 중 첫 번째로 나오는 항목)
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

                final selectedDate = ref.watch(selectedLogDateProvider);
                final isToday = DateUtils.isSameDay(selectedDate, DateTime.now());

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pagePadding,
                    AppSpacing.md,
                    AppSpacing.pagePadding,
                    AppSpacing.pagePadding,
                  ),
                  itemCount: entries.length,
                  itemBuilder: (context, i) {
                    return TimelineItemTile(
                      entry: entries[i],
                      isFirst: i == 0,
                      isLast: i == entries.length - 1,
                      showElapsed: isToday && lastFeedingId == entries[i].id,
                      onTap: () => openEditSheet(context, ref, entries[i]),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LogHeader extends ConsumerWidget {
  const _LogHeader({this.onMenuTap});

  final VoidCallback? onMenuTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topPadding = MediaQuery.of(context).padding.top;
    final baby = ref.watch(selectedBabyProvider).valueOrNull;
    final babies = ref.watch(babiesProvider).valueOrNull ?? [];
    final colorIndex =
        baby != null ? babies.indexWhere((b) => b.id == baby.id) : -1;
    final ageLabel =
        baby != null ? babyAgeLabel(context, baby.birthDate) : null;

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
        bottom: AppSpacing.md,
        left: AppSpacing.pagePadding,
        right: AppSpacing.pagePadding,
      ),
      child: Row(
        children: [
          if (baby != null) ...[
            BabyAvatarWidget(
              photoUrl: baby.photoUrl,
              gender: baby.gender,
              colorIndex: colorIndex >= 0 ? colorIndex : null,
              size: 32,
            ),
            const SizedBox(width: 8),
          ],
          Text(
            baby?.name ?? context.l10n.logTitle,
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
            onPressed: onMenuTap,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
