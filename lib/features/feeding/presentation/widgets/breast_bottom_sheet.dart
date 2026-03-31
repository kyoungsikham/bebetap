import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/extensions/datetime_ext.dart';
import '../../../../shared/widgets/date_time_wheel_picker.dart';
import '../../../log/domain/models/timeline_entry.dart';
import '../providers/feeding_provider.dart';
import '../providers/stopwatch_provider.dart';

class BreastBottomSheet extends ConsumerStatefulWidget {
  const BreastBottomSheet({super.key, this.editEntry});

  final TimelineEntry? editEntry;

  @override
  ConsumerState<BreastBottomSheet> createState() => _BreastBottomSheetState();
}

class _BreastBottomSheetState extends ConsumerState<BreastBottomSheet> {
  late DateTime _selectedDateTime;

  // Edit mode duration state (in minutes, 0–60)
  late int _editLeftMin;
  late int _editRightMin;
  late final FixedExtentScrollController _leftController;
  late final FixedExtentScrollController _rightController;

  bool get _isEditMode => widget.editEntry != null;

  static final _minItems = List.generate(61, (i) => i); // 0–60 min

  @override
  void initState() {
    super.initState();
    final edit = widget.editEntry;
    _selectedDateTime = edit?.occurredAt ?? DateTime.now();
    _editLeftMin = ((edit?.rawDurationLeftSec ?? 0) / 60).round().clamp(0, 60);
    _editRightMin =
        ((edit?.rawDurationRightSec ?? 0) / 60).round().clamp(0, 60);
    _leftController = FixedExtentScrollController(initialItem: _editLeftMin);
    _rightController = FixedExtentScrollController(initialItem: _editRightMin);
  }

  @override
  void dispose() {
    _leftController.dispose();
    _rightController.dispose();
    super.dispose();
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
    final period = dt.hour < 12 ? '오전' : '오후';
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final timePart = '$period $h:${dt.minute.toString().padLeft(2, '0')}';
    return '$datePart  $timePart';
  }

  Future<void> _pickDateTime() async {
    final result = await showDateTimeWheelPicker(
      context,
      initialDateTime: _selectedDateTime,
    );
    if (result != null && mounted) setState(() => _selectedDateTime = result);
  }

  @override
  Widget build(BuildContext context) {
    if (_isEditMode) {
      return _buildEditMode(context);
    }
    return _buildCreateMode(context);
  }

  Widget _buildEditMode(BuildContext context) {
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
          // 날짜/시간 선택 칩
          Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: _pickDateTime,
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
                  _formatDisplayDateTime(_selectedDateTime),
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.primary),
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // 좌/우 분 선택 휠
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '왼쪽',
                      style: AppTypography.labelLarge
                          .copyWith(color: AppColors.onSurfaceMuted),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _MinuteWheelPicker(
                      controller: _leftController,
                      items: _minItems,
                      selectedValue: _editLeftMin,
                      onChanged: (v) => setState(() => _editLeftMin = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '오른쪽',
                      style: AppTypography.labelLarge
                          .copyWith(color: AppColors.onSurfaceMuted),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _MinuteWheelPicker(
                      controller: _rightController,
                      items: _minItems,
                      selectedValue: _editRightMin,
                      onChanged: (v) => setState(() => _editRightMin = v),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      await ref
                          .read(feedingNotifierProvider.notifier)
                          .updateBreast(
                            widget.editEntry!.id,
                            durationLeftSec: _editLeftMin * 60,
                            durationRightSec: _editRightMin * 60,
                            startedAt: _selectedDateTime,
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
          // 날짜/시간 선택 칩
          Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: _pickDateTime,
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
                  _formatDisplayDateTime(_selectedDateTime),
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.primary),
                ),
              ),
            ),
          ),

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
                  onPressed: (isLoading ||
                          !sw.isActive && sw.totalDuration == Duration.zero)
                      ? null
                      : () async {
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
                                startedAt: _selectedDateTime,
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

class _MinuteWheelPicker extends StatelessWidget {
  const _MinuteWheelPicker({
    required this.controller,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
  });

  final FixedExtentScrollController controller;
  final List<int> items;
  final int selectedValue;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          ListWheelScrollView.useDelegate(
            controller: controller,
            itemExtent: 42,
            perspective: 0.004,
            diameterRatio: 1.8,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: (idx) => onChanged(items[idx]),
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: items.length,
              builder: (context, idx) {
                final val = items[idx];
                final isSelected = val == selectedValue;
                return Center(
                  child: Text(
                    '$val분',
                    style: AppTypography.bodyMedium.copyWith(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.onSurfaceMuted,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                );
              },
            ),
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
