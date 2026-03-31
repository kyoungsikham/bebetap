import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/extensions/datetime_ext.dart';
import '../../../../shared/widgets/date_time_wheel_picker.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../../log/domain/models/timeline_entry.dart';
import '../providers/sleep_provider.dart';

class SleepBottomSheet extends ConsumerStatefulWidget {
  const SleepBottomSheet({super.key, this.editEntry});

  final TimelineEntry? editEntry;

  @override
  ConsumerState<SleepBottomSheet> createState() => _SleepBottomSheetState();
}

class _SleepBottomSheetState extends ConsumerState<SleepBottomSheet> {
  late DateTime _startDateTime;
  late DateTime _endDateTime;

  bool get _isEditMode => widget.editEntry != null;

  @override
  void initState() {
    super.initState();
    final edit = widget.editEntry;
    _startDateTime = edit?.occurredAt ?? DateTime.now();
    _endDateTime = edit?.rawEndedAt ?? DateTime.now();
  }

  String _formatDisplayDateTime(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dtDay = DateTime(dt.year, dt.month, dt.day);
    String datePart;
    if (dtDay == today) {
      datePart = '오늘';
    } else if (dtDay == yesterday) {
      datePart = '어제';
    } else {
      const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
      datePart = '${dt.month}월 ${dt.day}일 (${weekdays[dt.weekday - 1]})';
    }
    final h = dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    return '$datePart  $h:$m';
  }

  Future<void> _pickStartDateTime() async {
    final result = await showDateTimeWheelPicker(
      context,
      initialDateTime: _startDateTime,
    );
    if (result != null && mounted) setState(() => _startDateTime = result);
  }

  Future<void> _pickEndDateTime() async {
    final result = await showDateTimeWheelPicker(
      context,
      initialDateTime: _endDateTime,
    );
    if (result != null && mounted) setState(() => _endDateTime = result);
  }

  @override
  Widget build(BuildContext context) {
    if (_isEditMode) {
      return _buildEditMode(context);
    }
    return _buildCreateMode(context);
  }

  Widget _buildEditMode(BuildContext context) {
    final isLoading = ref.watch(sleepSessionNotifierProvider).isLoading;
    final isActive = widget.editEntry?.rawEndedAt == null;
    final hasEnd = !isActive;

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
          const Icon(Icons.bedtime, size: 48, color: AppColors.primary),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '수면 수정',
            style: AppTypography.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),

          Row(
            children: [
              Expanded(
                child: _TimeChip(
                  label: '시작',
                  displayText:
                      '${_startDateTime.hour}시 ${_startDateTime.minute.toString().padLeft(2, '0')}분',
                  onTap: _pickStartDateTime,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _TimeChip(
                  label: '종료',
                  displayText: hasEnd
                      ? '${_endDateTime.hour}시 ${_endDateTime.minute.toString().padLeft(2, '0')}분'
                      : '자는 중',
                  onTap: hasEnd ? _pickEndDateTime : null,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xxl),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (hasEnd && _endDateTime.isBefore(_startDateTime)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('종료 시간이 시작 시간보다 이전일 수 없어요'),
                          ),
                        );
                        return;
                      }
                      await ref
                          .read(sleepSessionNotifierProvider.notifier)
                          .updateSleep(
                            widget.editEntry!.id,
                            startedAt: _startDateTime,
                            endedAt: hasEnd ? _endDateTime : null,
                          );
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
                  : const Text('수정'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateMode(BuildContext context) {
    final activeSleepAsync = ref.watch(activeSleepProvider);
    final activeSleep = activeSleepAsync.valueOrNull;
    final isLoading = ref.watch(sleepSessionNotifierProvider).isLoading;

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
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _TimeChip(
                    label: '시작',
                    displayText:
                        '${activeSleep.startedAt.hour}시 ${activeSleep.startedAt.minute.toString().padLeft(2, '0')}분',
                    onTap: null,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _TimeChip(
                    label: '종료',
                    displayText:
                        '${_endDateTime.hour}시 ${_endDateTime.minute.toString().padLeft(2, '0')}분',
                    onTap: _pickEndDateTime,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        if (_endDateTime.isBefore(activeSleep.startedAt)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('종료 시간이 시작 시간보다 이전일 수 없어요'),
                            ),
                          );
                          return;
                        }
                        await ref
                            .read(sleepSessionNotifierProvider.notifier)
                            .endSleep(activeSleep.id, endedAt: _endDateTime);
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
            const SizedBox(height: AppSpacing.md),
            Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: _pickStartDateTime,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.4),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _formatDisplayDateTime(_startDateTime),
                    style: AppTypography.bodyMedium
                        .copyWith(color: AppColors.primary),
                  ),
                ),
              ),
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
                            .startSleep(startedAt: _startDateTime);
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

class _TimeChip extends StatelessWidget {
  const _TimeChip({
    required this.label,
    required this.displayText,
    required this.onTap,
  });

  final String label;
  final String displayText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isActive = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.05)
              : AppColors.surfaceVariant,
          border: Border.all(
            color: isActive
                ? AppColors.primary.withValues(alpha: 0.4)
                : AppColors.divider,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.onSurfaceMuted,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              displayText,
              style: AppTypography.bodyMedium.copyWith(
                color: isActive ? AppColors.primary : AppColors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
