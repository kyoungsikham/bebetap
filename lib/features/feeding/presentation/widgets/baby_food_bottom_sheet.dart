import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/constants/medical_constants.dart';
import '../../../../shared/extensions/datetime_ext.dart';
import '../../../../shared/extensions/l10n_ext.dart';
import '../../../../shared/models/volume_unit.dart';
import '../../../../shared/providers/volume_unit_provider.dart';
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
  late FixedExtentScrollController _scrollController;
  VolumeUnit? _lastUnit;

  bool get _isEditMode => widget.editEntry != null;

  @override
  void initState() {
    super.initState();
    final edit = widget.editEntry;
    _selectedMl = edit?.rawAmountMl ?? MedicalConstants.babyFoodDefaultMl;
    _selectedDateTime = edit?.occurredAt ?? DateTime.now();
    _scrollController = FixedExtentScrollController(initialItem: 0);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _initScrollForUnit(VolumeUnit unit, List<int> items) {
    if (_lastUnit == unit) return;
    _lastUnit = unit;
    final snapped = unit.snapToStep(
      _selectedMl,
      minMl: MedicalConstants.babyFoodPickerMinMl,
      maxMl: MedicalConstants.babyFoodPickerMaxMl,
      stepMl: MedicalConstants.babyFoodPickerStepMl,
    );
    _selectedMl = snapped;
    final idx = items.indexOf(snapped).clamp(0, items.length - 1);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpToItem(idx);
      }
    });
  }

  String _formatDisplayDateTime(DateTime dt) =>
      dt.formatDisplayLocalized(context.l10n);

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
    final unit = ref.watch(volumeUnitProvider).valueOrNull ?? VolumeUnit.ml;

    final items = unit.pickerItems(
      minMl: MedicalConstants.babyFoodPickerMinMl,
      maxMl: MedicalConstants.babyFoodPickerMaxMl,
      stepMl: MedicalConstants.babyFoodPickerStepMl,
    );
    _initScrollForUnit(unit, items);

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

          // 휠 피커
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
                      setState(() => _selectedMl = items[idx]),
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: items.length,
                    builder: (context, idx) {
                      final ml = items[idx];
                      final isSelected = ml == _selectedMl;
                      return Center(
                        child: Text(
                          unit.formatAmount(ml),
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
                foregroundColor: AppColors.onPrimary,
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
                  : Text(
                      _isEditMode
                          ? context.l10n.editAmountMl(unit.formatAmount(_selectedMl))
                          : context.l10n.saveAmountMl(unit.formatAmount(_selectedMl)),
                    ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}
