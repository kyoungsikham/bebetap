import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/diaper_provider.dart';

class DiaperBottomSheet extends ConsumerWidget {
  const DiaperBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          Text(
            '기저귀 종류를 선택하세요',
            style: AppTypography.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: _DiaperTypeButton(
                  label: '소변',
                  emoji: '💧',
                  type: 'wet',
                  color: const Color(0xFFE3F0FF),
                  textColor: const Color(0xFF3D7ED6),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _DiaperTypeButton(
                  label: '대변',
                  emoji: '🟤',
                  type: 'soiled',
                  color: const Color(0xFFFFF3E0),
                  textColor: const Color(0xFFB07040),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _DiaperTypeButton(
                  label: '소변+대변',
                  emoji: '🔄',
                  type: 'both',
                  color: const Color(0xFFE8F5E9),
                  textColor: const Color(0xFF388E3C),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _DiaperTypeButton(
                  label: '교체',
                  emoji: '✨',
                  type: 'dry',
                  color: AppColors.surfaceVariant,
                  textColor: AppColors.onSurfaceMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DiaperTypeButton extends ConsumerWidget {
  const _DiaperTypeButton({
    required this.label,
    required this.emoji,
    required this.type,
    required this.color,
    required this.textColor,
  });

  final String label;
  final String emoji;
  final String type;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(diaperNotifierProvider).isLoading;

    return GestureDetector(
      onTap: isLoading
          ? null
          : () async {
              await ref.read(diaperNotifierProvider.notifier).saveDiaper(
                    type: type,
                  );
              await Future<void>.delayed(
                const Duration(milliseconds: 400),
              );
              if (context.mounted) Navigator.of(context).pop();
            },
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.labelLarge.copyWith(color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}
