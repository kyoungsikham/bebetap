import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/extensions/datetime_ext.dart';
import '../providers/feeding_provider.dart';
import '../providers/stopwatch_provider.dart';

class BreastBottomSheet extends ConsumerWidget {
  const BreastBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sw = ref.watch(breastfeedingStopwatchProvider);
    final isLoading = ref.watch(feedingNotifierProvider).isLoading;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pagePadding,
        AppSpacing.xl,
        AppSpacing.pagePadding,
        AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('모유 수유', style: AppTypography.titleMedium),
          const SizedBox(height: AppSpacing.xl),

          // 총 시간
          Text(
            sw.totalDuration.formatMmSs(),
            style: AppTypography.displayLarge.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // 좌/우 버튼
          Row(
            children: [
              Expanded(
                child: _SideButton(
                  label: '왼쪽',
                  duration: sw.leftDuration,
                  isActive: sw.activeSide == 'left',
                  onTap: () {
                    final notifier = ref.read(
                      breastfeedingStopwatchProvider.notifier,
                    );
                    if (sw.activeSide == 'left') {
                      notifier.pauseSide();
                    } else {
                      notifier.startSide('left');
                    }
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _SideButton(
                  label: '오른쪽',
                  duration: sw.rightDuration,
                  isActive: sw.activeSide == 'right',
                  onTap: () {
                    final notifier = ref.read(
                      breastfeedingStopwatchProvider.notifier,
                    );
                    if (sw.activeSide == 'right') {
                      notifier.pauseSide();
                    } else {
                      notifier.startSide('right');
                    }
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),

          // 저장 / 초기화
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ref
                        .read(breastfeedingStopwatchProvider.notifier)
                        .reset();
                    Navigator.of(context).pop();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.onSurfaceMuted,
                    side: const BorderSide(color: AppColors.divider),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(0, 52),
                  ),
                  child: const Text('취소'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: (isLoading || !sw.isActive && sw.totalDuration == Duration.zero)
                      ? null
                      : () async {
                          // 진행 중인 쪽 일시정지 후 저장
                          ref
                              .read(breastfeedingStopwatchProvider.notifier)
                              .pauseSide();
                          final updated =
                              ref.read(breastfeedingStopwatchProvider);
                          await ref
                              .read(feedingNotifierProvider.notifier)
                              .saveBreast(
                                durationLeftSec:
                                    updated.leftDuration.inSeconds,
                                durationRightSec:
                                    updated.rightDuration.inSeconds,
                                startedAt: updated.sessionStartedAt ??
                                    DateTime.now(),
                              );
                          ref
                              .read(breastfeedingStopwatchProvider.notifier)
                              .reset();
                          if (context.mounted) Navigator.of(context).pop();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(0, 52),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('저장'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SideButton extends StatelessWidget {
  const _SideButton({
    required this.label,
    required this.duration,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final Duration duration;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 80,
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.divider,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? Icons.pause_circle : Icons.play_circle_outline,
              color: isActive ? AppColors.primary : AppColors.onSurfaceMuted,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.labelLarge.copyWith(
                color: isActive ? AppColors.primary : AppColors.onSurface,
              ),
            ),
            Text(
              duration.formatMmSs(),
              style: AppTypography.bodySmall.copyWith(
                color: isActive ? AppColors.primary : AppColors.onSurfaceMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
