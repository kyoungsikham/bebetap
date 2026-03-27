import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/extensions/datetime_ext.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../providers/sleep_provider.dart';

class SleepBottomSheet extends ConsumerWidget {
  const SleepBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSleepAsync = ref.watch(activeSleepProvider);
    final activeSleep = activeSleepAsync.valueOrNull;
    final isLoading = ref.watch(sleepSessionNotifierProvider).isLoading;

    // minuteTicker로 경과 시간 갱신
    ref.watch(minuteTickerProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pagePadding,
        AppSpacing.xl,
        AppSpacing.pagePadding,
        AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (activeSleep != null) ...[
            const Icon(Icons.bedtime, size: 48, color: AppColors.primary),
            const SizedBox(height: AppSpacing.md),
            Text(
              '수면 중',
              style: AppTypography.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              activeSleep.duration.formatKorean(),
              style: AppTypography.headlineMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              '${activeSleep.startedAt.hour.toString().padLeft(2, '0')}:${activeSleep.startedAt.minute.toString().padLeft(2, '0')} 시작',
              style: AppTypography.bodySmall
                  .copyWith(color: AppColors.onSurfaceMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        await ref
                            .read(sleepSessionNotifierProvider.notifier)
                            .endSleep(activeSleep.id);
                        if (context.mounted) Navigator.of(context).pop();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                    : const Text('수면 종료'),
              ),
            ),
          ] else ...[
            const Icon(
              Icons.bedtime_outlined,
              size: 48,
              color: AppColors.onSurfaceMuted,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '수면 기록',
              style: AppTypography.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '수면을 시작하면 타이머가 작동합니다.\n앱을 종료해도 기록이 유지됩니다.',
              style: AppTypography.bodySmall
                  .copyWith(color: AppColors.onSurfaceMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        await ref
                            .read(sleepSessionNotifierProvider.notifier)
                            .startSleep();
                        if (context.mounted) Navigator.of(context).pop();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                    : const Text('수면 시작'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
