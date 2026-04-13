import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/extensions/l10n_ext.dart';
import '../../domain/models/date_range_selection.dart';

/// Date range bar for the life-pattern (생활패턴) page.
/// Only supports day/week presets with left/right arrow navigation.
class PatternDateRangeBar extends StatelessWidget {
  const PatternDateRangeBar({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final DateRangeSelection selected;
  final ValueChanged<DateRangeSelection> onChanged;

  bool get _isDay => selected.preset == DateRangePreset.day;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Day / Week toggle
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ToggleButton(
              label: l10n.periodDay,
              selected: _isDay,
              onTap: () => onChanged(DateRangeSelection.day()),
            ),
            const SizedBox(width: AppSpacing.sm),
            _ToggleButton(
              label: l10n.periodWeek,
              selected: !_isDay,
              onTap: () => onChanged(DateRangeSelection.week()),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        // Date navigation
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, size: 20),
              onPressed: _goBack,
              visualDensity: VisualDensity.compact,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            Text(
              _formatDateLabel(context),
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, size: 20),
              onPressed: _canGoForward ? _goForward : null,
              visualDensity: VisualDensity.compact,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDateLabel(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    if (_isDay) {
      // "4월 8일" style
      final fmt = DateFormat.MMMd(locale);
      return fmt.format(selected.from);
    } else {
      // "04.02 ~ 04.08"
      final fmt = DateFormat('MM.dd', locale);
      // `to` is exclusive (+1 day), so show to - 1 day
      final lastDay = selected.to.subtract(const Duration(days: 1));
      return '${fmt.format(selected.from)} ~ ${fmt.format(lastDay)}';
    }
  }

  bool get _canGoForward {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (_isDay) {
      return selected.from.isBefore(today);
    } else {
      // Can go forward if the last day of current range is before today
      final lastDay = selected.to.subtract(const Duration(days: 1));
      return lastDay.isBefore(today);
    }
  }

  void _goBack() {
    if (_isDay) {
      final prev = selected.from.subtract(const Duration(days: 1));
      onChanged(DateRangeSelection.day(prev));
    } else {
      final prevEnd = selected.from.subtract(const Duration(days: 1));
      onChanged(DateRangeSelection.week(prevEnd));
    }
  }

  void _goForward() {
    if (_isDay) {
      final next = selected.from.add(const Duration(days: 1));
      onChanged(DateRangeSelection.day(next));
    } else {
      // Move forward by 7 days
      final nextEnd = selected.to.add(const Duration(days: 6));
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      // Don't go past today
      final endDate = nextEnd.isAfter(today) ? today : nextEnd;
      onChanged(DateRangeSelection.week(endDate));
    }
  }
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? colorScheme.primary.withValues(alpha: 0.1)
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? colorScheme.primary.withValues(alpha: 0.4)
                : colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            color: selected
                ? colorScheme.primary
                : colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}
