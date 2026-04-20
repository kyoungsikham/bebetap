import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/extensions/l10n_ext.dart';
import '../../../../shared/utils/baby_age.dart';
import '../../../../shared/utils/quick_record.dart';
import '../../../../shared/widgets/app_bottom_sheet.dart';
import '../../../../shared/widgets/baby_avatar_widget.dart';
import '../../../../shared/widgets/hamburger_menu_panel.dart';
import '../../../../core/widget/widget_action_handler.dart';
import '../../../baby/presentation/providers/baby_provider.dart';
import '../../../diaper/presentation/widgets/diaper_bottom_sheet.dart';
import '../../../feeding/presentation/widgets/baby_food_bottom_sheet.dart';
import '../../../feeding/presentation/widgets/breast_bottom_sheet.dart';
import '../../../feeding/presentation/widgets/formula_bottom_sheet.dart' show FormulaBottomSheet, MlFeedingType;
import '../../../sleep/presentation/widgets/sleep_bottom_sheet.dart';
import '../../../temperature/presentation/widgets/temperature_bottom_sheet.dart';
import '../../../diary/presentation/providers/diary_provider.dart';
import '../../../diary/presentation/widgets/diary_bottom_sheet.dart';
import '../../domain/models/timeline_entry.dart';
import '../providers/log_provider.dart';
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
      _openAddSheetForTab(pendingTab);
    }
  }

  @override
  Widget build(BuildContext context) {
    // pendingWidgetTabProvider 변경 시 바텀 시트 자동 열기 (앱이 이미 열려 있는 경우)
    ref.listen(pendingWidgetTabProvider, (prev, next) {
      if (next != null) {
        ref.read(pendingWidgetTabProvider.notifier).state = null;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _openAddSheetForTab(next);
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
              onTapCategory: (type) => _openAddSheetForType(context, ref, type),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          const Divider(height: 1),

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
                      onTap: () => _openEditSheet(context, ref, entries[i]),
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

  void _openEditSheet(BuildContext context, WidgetRef ref, TimelineEntry entry) {
    late Widget sheet;
    late String title;
    switch (entry.type) {
      case TimelineEntryType.formula:
        sheet = FormulaBottomSheet(editEntry: entry);
        title = context.l10n.editFormula;
      case TimelineEntryType.pumped:
        sheet = FormulaBottomSheet(editEntry: entry, feedingType: MlFeedingType.pumped);
        title = context.l10n.editPumped;
      case TimelineEntryType.babyFood:
        sheet = BabyFoodBottomSheet(editEntry: entry);
        title = context.l10n.editBabyFood;
      case TimelineEntryType.breast:
        sheet = BreastBottomSheet(editEntry: entry);
        title = context.l10n.editBreast;
      case TimelineEntryType.diaper:
        sheet = DiaperBottomSheet(editEntry: entry);
        title = context.l10n.editDiaper;
      case TimelineEntryType.sleep:
        sheet = SleepBottomSheet(editEntry: entry);
        title = context.l10n.editSleep;
      case TimelineEntryType.temperature:
        sheet = TemperatureBottomSheet(editEntry: entry);
        title = context.l10n.editTemperature;
      case TimelineEntryType.diary:
        sheet = DiaryBottomSheet(editEntry: entry);
        title = context.l10n.diaryLog;
    }
    // 일기는 작성자만 삭제 가능
    final bool canDelete = entry.type != TimelineEntryType.diary ||
        entry.rawRecordedBy == Supabase.instance.client.auth.currentUser?.id;

    showAppBottomSheet(
      context: context,
      child: sheet,
      title: title,
      titleTrailing: canDelete
          ? IconButton(
              icon: const Icon(Icons.delete_outline),
              color: Theme.of(context).colorScheme.error,
              tooltip: context.l10n.delete,
              onPressed: () => _confirmDelete(context, ref, entry),
            )
          : null,
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    TimelineEntry entry,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.deleteConfirmTitle),
        content: Text(context.l10n.deleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(logRepositoryProvider).deleteEntry(entry);
    ref.invalidate(logTimelineProvider);
    if (context.mounted) Navigator.of(context).pop();
  }

  /// 위젯 딥링크 탭 이름으로 즉시 기록 or 바텀시트 열기.
  /// tab: 'formula' | 'breast' | 'pumped' | 'baby_food' | 'temperature' | 'sleep' | 'diaper'
  Future<void> _openAddSheetForTab(String tab) async {
    if (!mounted) return;
    switch (tab) {
      case 'formula':
        await quickAddRecord(context, ref, TimelineEntryType.formula);
      case 'breast':
        await quickAddRecord(context, ref, TimelineEntryType.breast);
      case 'pumped':
        await quickAddRecord(context, ref, TimelineEntryType.pumped);
      case 'baby_food':
        await quickAddRecord(context, ref, TimelineEntryType.babyFood);
      case 'sleep':
        await quickAddRecord(context, ref, TimelineEntryType.sleep);
      case 'diaper':
        await quickAddRecord(context, ref, TimelineEntryType.diaper);
      case 'temperature':
        if (!mounted) return;
        showAppBottomSheet(
          context: context,
          child: const TemperatureBottomSheet(),
          title: context.l10n.addTemperature,
        );
      case 'diary':
        final existing = await ref.read(todayDiaryForCurrentUserProvider.future);
        if (!mounted) return;
        showAppBottomSheet(
          context: context,
          child: existing != null
              ? DiaryBottomSheet(editEntry: existing.toTimelineEntry())
              : const DiaryBottomSheet(),
          title: existing != null ? context.l10n.editDiary : context.l10n.writeDiary,
        );
      default:
        return;
    }
  }

  Future<void> _openAddSheetForType(
      BuildContext context, WidgetRef ref, TimelineEntryType type) async {
    if (needsBottomSheet(type)) {
      if (type == TimelineEntryType.temperature) {
        showAppBottomSheet(
          context: context,
          child: const TemperatureBottomSheet(),
          title: context.l10n.addTemperature,
        );
      } else {
        // diary
        final existing = await ref.read(todayDiaryForCurrentUserProvider.future);
        if (!context.mounted) return;
        showAppBottomSheet(
          context: context,
          child: existing != null
              ? DiaryBottomSheet(editEntry: existing.toTimelineEntry())
              : const DiaryBottomSheet(),
          title: existing != null ? context.l10n.editDiary : context.l10n.writeDiary,
        );
      }
      return;
    }
    await quickAddRecord(context, ref, type);
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
