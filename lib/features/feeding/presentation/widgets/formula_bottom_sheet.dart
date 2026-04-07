import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/constants/medical_constants.dart';
import '../../../../shared/extensions/datetime_ext.dart';
import '../../../../shared/extensions/l10n_ext.dart';
import '../../../../shared/widgets/date_time_wheel_picker.dart';
import '../../../baby/presentation/providers/baby_provider.dart';
import '../../../log/domain/models/timeline_entry.dart';
import '../providers/feeding_provider.dart';

enum MlFeedingType { formula, pumped }

class FormulaBottomSheet extends ConsumerStatefulWidget {
  const FormulaBottomSheet({super.key, this.editEntry, this.feedingType = MlFeedingType.formula});

  final TimelineEntry? editEntry;
  final MlFeedingType feedingType;

  @override
  ConsumerState<FormulaBottomSheet> createState() =>
      _FormulaBottomSheetState();
}

class _FormulaBottomSheetState extends ConsumerState<FormulaBottomSheet> {
  late int _selectedMl;
  late DateTime _selectedDateTime;
  late final FixedExtentScrollController _scrollController;

  bool get _isEditMode => widget.editEntry != null;

  static final _items = List.generate(
    (MedicalConstants.formulaPickerMaxMl - MedicalConstants.formulaPickerMinMl) ~/
            MedicalConstants.formulaPickerStepMl +
        1,
    (i) => MedicalConstants.formulaPickerMinMl +
        i * MedicalConstants.formulaPickerStepMl,
  );

  @override
  void initState() {
    super.initState();
    final edit = widget.editEntry;
    _selectedMl = edit?.rawAmountMl ?? MedicalConstants.formulaDefaultMl;
    _selectedDateTime = edit?.occurredAt ?? DateTime.now();
    final initialIndex = ((_selectedMl - MedicalConstants.formulaPickerMinMl) ~/
            MedicalConstants.formulaPickerStepMl)
        .clamp(0, _items.length - 1);
    _scrollController =
        FixedExtentScrollController(initialItem: initialIndex);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
    final baby = ref.watch(selectedBabyProvider).valueOrNull;
    final isPumped = widget.feedingType == MlFeedingType.pumped;
    final recommendedMl = (!isPumped && baby?.weightKg != null)
        ? MedicalConstants.formulaDailyTargetMl(baby!.weightKg!).toInt()
        : null;
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

          // 권장량 (분유 모드에서만 표시)
          if (!isPumped)
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                recommendedMl != null
                    ? context.l10n.formulaRecommendation(baby!.weightKg!.toStringAsFixed(1), recommendedMl)
                    : context.l10n.formulaWeightHint,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.onSurfaceMuted,
                  fontSize: 11,
                ),
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
                        if (widget.feedingType == MlFeedingType.pumped) {
                          await ref
                              .read(feedingNotifierProvider.notifier)
                              .updatePumped(
                                widget.editEntry!.id,
                                amountMl: _selectedMl,
                                startedAt: _selectedDateTime,
                              );
                        } else {
                          await ref
                              .read(feedingNotifierProvider.notifier)
                              .updateFormula(
                                widget.editEntry!.id,
                                amountMl: _selectedMl,
                                startedAt: _selectedDateTime,
                              );
                        }
                      } else {
                        if (widget.feedingType == MlFeedingType.pumped) {
                          await ref
                              .read(feedingNotifierProvider.notifier)
                              .savePumped(
                                amountMl: _selectedMl,
                                startedAt: _selectedDateTime,
                              );
                        } else {
                          await ref
                              .read(feedingNotifierProvider.notifier)
                              .saveFormula(
                                amountMl: _selectedMl,
                                startedAt: _selectedDateTime,
                              );
                        }
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
                  : Text(_isEditMode ? context.l10n.editAmountMl(_selectedMl) : context.l10n.saveAmountMl(_selectedMl)),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}
