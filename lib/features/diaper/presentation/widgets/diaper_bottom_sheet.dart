import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/date_time_wheel_picker.dart';
import '../../../log/domain/models/timeline_entry.dart';
import '../providers/diaper_provider.dart';

class DiaperBottomSheet extends ConsumerStatefulWidget {
  const DiaperBottomSheet({super.key, this.editEntry});

  final TimelineEntry? editEntry;

  @override
  ConsumerState<DiaperBottomSheet> createState() => _DiaperBottomSheetState();
}

class _DiaperBottomSheetState extends ConsumerState<DiaperBottomSheet> {
  late DateTime _selectedDateTime;

  bool get _isEditMode => widget.editEntry != null;

  @override
  void initState() {
    super.initState();
    _selectedDateTime = widget.editEntry?.occurredAt ?? DateTime.now();
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
            _isEditMode ? '기저귀 종류를 선택하세요' : '기저귀 종류를 선택하세요',
            style: AppTypography.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),

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
          Row(
            children: [
              Expanded(
                child: _DiaperTypeButton(
                  label: '소변',
                  emoji: '💧',
                  type: 'wet',
                  color: const Color(0xFFE3F0FF),
                  textColor: const Color(0xFF3D7ED6),
                  occurredAt: _selectedDateTime,
                  editId: _isEditMode ? widget.editEntry!.id : null,
                  isSelected: widget.editEntry?.rawDiaperType == 'wet',
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
                  occurredAt: _selectedDateTime,
                  editId: _isEditMode ? widget.editEntry!.id : null,
                  isSelected: widget.editEntry?.rawDiaperType == 'soiled',
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
                  occurredAt: _selectedDateTime,
                  editId: _isEditMode ? widget.editEntry!.id : null,
                  isSelected: widget.editEntry?.rawDiaperType == 'both',
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
                  occurredAt: _selectedDateTime,
                  editId: _isEditMode ? widget.editEntry!.id : null,
                  isSelected: widget.editEntry?.rawDiaperType == 'dry',
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
    required this.occurredAt,
    this.editId,
    this.isSelected = false,
  });

  final String label;
  final String emoji;
  final String type;
  final Color color;
  final Color textColor;
  final DateTime occurredAt;
  final String? editId;
  final bool isSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(diaperNotifierProvider).isLoading;

    return GestureDetector(
      onTap: isLoading
          ? null
          : () async {
              if (editId != null) {
                await ref.read(diaperNotifierProvider.notifier).updateDiaper(
                      editId!,
                      type: type,
                      occurredAt: occurredAt,
                    );
              } else {
                await ref.read(diaperNotifierProvider.notifier).saveDiaper(
                      type: type,
                      occurredAt: occurredAt,
                    );
              }
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
          border: Border.all(
            color: isSelected ? textColor : AppColors.divider,
            width: isSelected ? 2.0 : 1.0,
          ),
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
