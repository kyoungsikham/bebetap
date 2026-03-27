import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/constants/medical_constants.dart';
import '../../../baby/presentation/providers/baby_provider.dart';
import '../providers/feeding_provider.dart';

class FormulaBottomSheet extends ConsumerStatefulWidget {
  const FormulaBottomSheet({super.key});

  @override
  ConsumerState<FormulaBottomSheet> createState() =>
      _FormulaBottomSheetState();
}

class _FormulaBottomSheetState extends ConsumerState<FormulaBottomSheet> {
  int _selectedMl = MedicalConstants.formulaDefaultMl;
  late final FixedExtentScrollController _scrollController;

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
    final initialIndex =
        (_selectedMl - MedicalConstants.formulaPickerMinMl) ~/
            MedicalConstants.formulaPickerStepMl;
    _scrollController =
        FixedExtentScrollController(initialItem: initialIndex);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baby = ref.watch(selectedBabyProvider).valueOrNull;
    final recommendedMl = baby?.weightKg != null
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
          if (recommendedMl != null)
            Text(
              '오늘 권장량: ${recommendedMl}ml',
              style: AppTypography.bodySmall
                  .copyWith(color: AppColors.onSurfaceMuted),
            ),
          const SizedBox(height: AppSpacing.md),

          // 휠 피커
          SizedBox(
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 선택 영역 표시
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
                          .saveFormula(amountMl: _selectedMl);
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
                  : Text('$_selectedMl ml 저장'),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}
