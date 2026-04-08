import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_typography.dart';
import '../../../../shared/extensions/l10n_ext.dart';
import '../providers/log_provider.dart';

class DateNavigator extends ConsumerWidget {
  const DateNavigator({super.key});

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = ref.watch(selectedLogDateProvider);
    final isToday = _isToday(date);
    final l10n = context.l10n;

    final weekdays = [
      l10n.weekdayMon,
      l10n.weekdayTue,
      l10n.weekdayWed,
      l10n.weekdayThu,
      l10n.weekdayFri,
      l10n.weekdaySat,
      l10n.weekdaySun,
    ];
    final weekday = weekdays[date.weekday - 1];
    final dateLabel = isToday
        ? l10n.dateFormatTodayNav(date.month, date.day, weekday)
        : l10n.dateFormatFull(date.month, date.day, weekday);

    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () =>
              ref.read(selectedLogDateProvider.notifier).previousDay(),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context,
                initialDate: date,
                firstDate: DateTime(now.year - 1),
                lastDate: now,
              );
              if (picked != null) {
                ref.read(selectedLogDateProvider.notifier).setDate(picked);
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.55),
                ),
                const SizedBox(width: 6),
                Text(
                  dateLabel,
                  style: AppTypography.titleMedium,
                ),
              ],
            ),
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.chevron_right,
            color: isToday ? Theme.of(context).dividerColor : null,
          ),
          onPressed: isToday
              ? null
              : () => ref.read(selectedLogDateProvider.notifier).nextDay(),
        ),
      ],
    );
  }
}
