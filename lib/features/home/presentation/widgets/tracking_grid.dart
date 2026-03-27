import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/extensions/datetime_ext.dart';
import '../../../../shared/widgets/app_bottom_sheet.dart';
import '../../../diaper/presentation/widgets/diaper_bottom_sheet.dart';
import '../../../feeding/presentation/widgets/breast_bottom_sheet.dart';
import '../../../feeding/presentation/widgets/formula_bottom_sheet.dart';
import '../../../sleep/presentation/providers/sleep_provider.dart';
import '../../../sleep/presentation/widgets/sleep_bottom_sheet.dart';
import '../../../temperature/presentation/widgets/temperature_bottom_sheet.dart';
import '../providers/home_provider.dart';
import 'tracking_tile.dart';

class TrackingGrid extends ConsumerWidget {
  const TrackingGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1분마다 재빌드 (경과 시간 갱신)
    ref.watch(minuteTickerProvider);
    final summaryAsync = ref.watch(homeSummaryProvider);
    final activeSleep = ref.watch(activeSleepProvider).valueOrNull;
    final summary = summaryAsync.valueOrNull;

    // 마지막 수유 경과 레이블
    String feedingElapsed = '탭해서 기록';
    if (summary?.lastFeedingAt != null) {
      feedingElapsed =
          DateTime.now().difference(summary!.lastFeedingAt!).formatElapsedKorean();
    }

    // 수면 상태 레이블
    String sleepLabel = '탭해서 기록';
    if (activeSleep != null) {
      sleepLabel = activeSleep.duration.formatKorean();
    } else if (summary?.todaySleepTotal != null &&
        summary!.todaySleepTotal > Duration.zero) {
      sleepLabel = '오늘 ${summary.todaySleepTotal.formatHhMm()}';
    }

    // 기저귀 레이블
    final diaperLabel = summary != null && summary.todayDiaperCount > 0
        ? '오늘 ${summary.todayDiaperCount}회'
        : '탭해서 기록';

    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        TrackingTile(
          icon: Icons.local_drink,
          label: '분유',
          sublabel: feedingElapsed,
          color: AppColors.primary,
          onTap: () => showAppBottomSheet(
            context: context,
            child: const FormulaBottomSheet(),
            title: '분유 수유',
          ),
        ),
        TrackingTile(
          icon: Icons.favorite_outline,
          label: '모유',
          sublabel: feedingElapsed,
          color: const Color(0xFFE91E8C),
          onTap: () => showAppBottomSheet(
            context: context,
            child: const BreastBottomSheet(),
            title: '모유 수유',
          ),
        ),
        TrackingTile(
          icon: Icons.baby_changing_station,
          label: '기저귀',
          sublabel: diaperLabel,
          color: const Color(0xFF52B788),
          onTap: () => showAppBottomSheet(
            context: context,
            child: const DiaperBottomSheet(),
          ),
        ),
        TrackingTile(
          icon: Icons.bedtime,
          label: '수면',
          sublabel: sleepLabel,
          color: const Color(0xFF7B68EE),
          isActive: activeSleep != null,
          onTap: () => showAppBottomSheet(
            context: context,
            child: const SleepBottomSheet(),
            title: '수면',
          ),
        ),
        TrackingTile(
          icon: Icons.device_thermostat,
          label: '체온',
          sublabel: '탭해서 기록',
          color: const Color(0xFFFF7043),
          onTap: () => showAppBottomSheet(
            context: context,
            child: const TemperatureBottomSheet(),
            title: '체온 기록',
          ),
        ),
        TrackingTile(
          icon: Icons.monitor_weight_outlined,
          label: '성장',
          sublabel: 'Phase 4',
          color: AppColors.onSurfaceMuted,
          onTap: () {},
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 260.ms, curve: Curves.easeOut)
        .slideY(begin: 0.04, end: 0, duration: 300.ms, curve: Curves.easeOut);
  }
}
