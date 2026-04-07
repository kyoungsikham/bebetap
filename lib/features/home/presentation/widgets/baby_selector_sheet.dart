import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_bottom_sheet.dart';
import '../../../../shared/widgets/baby_avatar_widget.dart';
import '../../../baby/domain/models/baby.dart';
import '../../../baby/presentation/providers/baby_provider.dart';

void showBabySelectorSheet(BuildContext context, WidgetRef ref) {
  showAppBottomSheet(
    context: context,
    title: '아이 선택',
    child: _BabySelectorSheetContent(ref: ref),
  );
}

class _BabySelectorSheetContent extends ConsumerWidget {
  const _BabySelectorSheetContent({required this.ref});

  final WidgetRef ref;

  static final _dateFormat = DateFormat('yyyy년 MM월 dd일');

  @override
  Widget build(BuildContext context, WidgetRef widgetRef) {
    final babies = widgetRef.watch(babiesProvider).valueOrNull ?? [];
    final selectedId = widgetRef.watch(selectedBabyIdProvider);
    final effectiveId = selectedId ?? (babies.isNotEmpty ? babies.first.id : null);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pagePadding,
        AppSpacing.md,
        AppSpacing.pagePadding,
        AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: babies.asMap().entries.map((entry) {
          final index = entry.key;
          final baby = entry.value;
          final isSelected = baby.id == effectiveId;
          return _BabySelectorTile(
            baby: baby,
            colorIndex: index,
            isSelected: isSelected,
            dateFormat: _dateFormat,
            onTap: () {
              widgetRef.read(selectedBabyIdProvider.notifier).select(baby.id);
              Navigator.of(context).pop();
            },
          );
        }).toList(),
      ),
    );
  }
}

class _BabySelectorTile extends StatelessWidget {
  const _BabySelectorTile({
    required this.baby,
    required this.colorIndex,
    required this.isSelected,
    required this.dateFormat,
    required this.onTap,
  });

  final Baby baby;
  final int colorIndex;
  final bool isSelected;
  final DateFormat dateFormat;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.05)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            BabyAvatarWidget(
              photoUrl: baby.photoUrl,
              gender: baby.gender,
              colorIndex: colorIndex,
              size: 44,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(baby.name, style: AppTypography.bodyLarge),
                  Text(
                    dateFormat.format(baby.birthDate),
                    style: AppTypography.bodySmall
                        .copyWith(color: AppColors.onSurfaceMuted),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
