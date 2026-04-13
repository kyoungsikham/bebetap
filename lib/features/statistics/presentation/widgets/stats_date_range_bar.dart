import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/extensions/l10n_ext.dart';
import '../../../baby/presentation/providers/baby_provider.dart';
import '../../domain/models/date_range_selection.dart';

class StatsDateRangeBar extends ConsumerWidget {
  const StatsDateRangeBar({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final DateRangeSelection selected;
  final ValueChanged<DateRangeSelection> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;

    final presets = [
      (DateRangePreset.day, l10n.periodDay),
      (DateRangePreset.week, l10n.periodWeek),
      (DateRangePreset.month, l10n.periodMonth),
    ];

    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(3),
            child: Row(
              children: presets.map((entry) {
                final (preset, label) = entry;
                final isSelected =
                    selected.preset == preset;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      switch (preset) {
                        case DateRangePreset.day:
                          onChanged(DateRangeSelection.day());
                        case DateRangePreset.week:
                          onChanged(DateRangeSelection.week());
                        case DateRangePreset.month:
                          onChanged(DateRangeSelection.month());
                        case DateRangePreset.custom:
                          break;
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colorScheme.surface
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(9),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        label,
                        style: AppTypography.bodySmall.copyWith(
                          color: isSelected
                              ? colorScheme.onSurface
                              : colorScheme.onSurface.withValues(alpha: 0.55),
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(width: 8),
        _CalendarButton(
          isActive: selected.preset == DateRangePreset.custom,
          dateLabel: selected.preset == DateRangePreset.custom
              ? _formatCustomRange(context, selected)
              : null,
          onTap: () => _pickDateRange(context, ref),
        ),
      ],
    );
  }

  String _formatCustomRange(BuildContext context, DateRangeSelection sel) {
    final fmt = DateFormat.Md(Localizations.localeOf(context).toString());
    return '${fmt.format(sel.from)}-${fmt.format(sel.to.subtract(const Duration(days: 1)))}';
  }

  Future<void> _pickDateRange(BuildContext context, WidgetRef ref) async {
    final baby = await ref.read(selectedBabyProvider.future);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Allow up to 6 months back
    final sixMonthsAgo = today.subtract(const Duration(days: 180));
    final birthDate = baby?.birthDate;
    final birthDay = birthDate != null
        ? DateTime(birthDate.year, birthDate.month, birthDate.day)
        : sixMonthsAgo;
    // firstDate = whichever is more recent: birth date or 6 months ago
    final firstDate = birthDay.isAfter(sixMonthsAgo) ? birthDay : sixMonthsAgo;

    if (!context.mounted) return;
    final result = await showDateRangePicker(
      context: context,
      firstDate: firstDate,
      lastDate: today,
      initialDateRange: selected.preset == DateRangePreset.custom
          ? DateTimeRange(
              start: selected.from,
              end: selected.to.subtract(const Duration(days: 1)),
            )
          : DateTimeRange(
              start: today.subtract(const Duration(days: 6)),
              end: today,
            ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primary,
                ),
          ),
          child: child!,
        );
      },
    );

    if (result != null) {
      // Clamp selection to max 180 days (6 months)
      var start = result.start;
      var end = result.end;
      if (end.difference(start).inDays > 180) {
        start = end.subtract(const Duration(days: 180));
      }
      onChanged(DateRangeSelection.custom(start, end));
    }
  }
}

class _CalendarButton extends StatelessWidget {
  const _CalendarButton({
    required this.isActive,
    required this.onTap,
    this.dateLabel,
  });

  final bool isActive;
  final VoidCallback onTap;
  final String? dateLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.12)
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: isActive
              ? Border.all(color: AppColors.primary.withValues(alpha: 0.3))
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today,
              size: 16,
              color: isActive ? AppColors.primary : colorScheme.onSurface.withValues(alpha: 0.55),
            ),
            if (dateLabel != null) ...[
              const SizedBox(width: 4),
              Text(
                dateLabel!,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
