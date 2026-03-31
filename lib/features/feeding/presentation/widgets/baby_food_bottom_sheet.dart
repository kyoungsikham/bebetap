import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/constants/medical_constants.dart';
import '../../../../shared/widgets/date_time_wheel_picker.dart';
import '../../../log/domain/models/timeline_entry.dart';
import '../providers/feeding_provider.dart';

class BabyFoodBottomSheet extends ConsumerStatefulWidget {
  const BabyFoodBottomSheet({super.key, this.editEntry});

  final TimelineEntry? editEntry;

  @override
  ConsumerState<BabyFoodBottomSheet> createState() =>
      _BabyFoodBottomSheetState();
}

class _BabyFoodBottomSheetState extends ConsumerState<BabyFoodBottomSheet> {
  late int _selectedMl;
  late DateTime _selectedDateTime;
  late final FixedExtentScrollController _scrollController;

  bool get _isEditMode => widget.editEntry != null;

  static final _items = List.generate(
    (MedicalConstants.babyFoodPickerMaxMl - MedicalConstants.babyFoodPickerMinMl) ~/
            MedicalConstants.babyFoodPickerStepMl +
        1,
    (i) => MedicalConstants.babyFoodPickerMinMl +
        i * MedicalConstants.babyFoodPickerStepMl,
  );

  @override
  void initState() {
    super.initState();
    final edit = widget.editEntry;
    _selectedMl = edit?.rawAmountMl ?? MedicalConstants.babyFoodDefaultMl;
    _selectedDateTime = edit?.occurredAt ?? DateTime.now();
    final initialIndex = ((_selectedMl - MedicalConstants.babyFoodPickerMinMl) ~/
            MedicalConstants.babyFoodPickerStepMl)
        .clamp(0, _items.length - 1);
    _scrollController =
        FixedExtentScrollController(initialItem: initialIndex);
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
    if (result != null && mounted) {
      setState(() => _selectedDateTime = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(feedingNotifierProvider).isLoading;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.pagePadding,
        right: AppSpacing.pagePadding,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSpacing.xl),

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

          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1),

          // ml 휠 피커
          SizedBox(
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                ListWheelScrollView.useDelegate(
                  controller: _scrollController,
                  itemExtent: 50,
                  perspective: 0.004,
                  diameterRatio: 1.6,
                  physics: const FixedExtentScrollPhysics(),
                  onSelectedItemChanged: (idx) =>
                      setState(() => _selectedMl = _items[idx]),
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: _items.length,
                    builder: (context, idx) {
                      final ml = _items[idx];
                      final isSelected = ml == _selectedMl;
                      return Center(
                        child: Text(
                          '$ml ml',
                          style: (isSelected
                                  ? AppTypography.titleMedium
                                  : AppTypography.bodyMedium)
                              .copyWith(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.onSurfaceMuted,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (_isEditMode) {
                        await ref
                            .read(feedingNotifierProvider.notifier)
                            .updateBabyFood(
                              widget.editEntry!.id,
                              amountMl: _selectedMl,
                              startedAt: _selectedDateTime,
                            );
                      } else {
                        await ref
                            .read(feedingNotifierProvider.notifier)
                            .saveBabyFood(
                              amountMl: _selectedMl,
                              startedAt: _selectedDateTime,
                            );
                      }
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
                  : Text(_isEditMode ? '$_selectedMl ml 수정' : '$_selectedMl ml 저장'),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}
