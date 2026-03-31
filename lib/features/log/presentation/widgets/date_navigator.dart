import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/log_provider.dart';

class DateNavigator extends ConsumerWidget {
  const DateNavigator({super.key});

  static const _weekdays = ['월', '화', '수', '목', '금', '토', '일'];

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(date.year, date.month, date.day);
    final weekday = _weekdays[date.weekday - 1];
    final base = '${date.month}월 ${date.day}일 ($weekday)';
    return selected == today ? '$base  오늘' : base;
  }

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

    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          color: AppColors.onSurface,
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
                locale: const Locale('ko'),
              );
              if (picked != null) {
                ref.read(selectedLogDateProvider.notifier).setDate(picked);
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: AppColors.onSurfaceMuted,
                ),
                const SizedBox(width: 6),
                Text(
                  _formatDate(date),
                  style: AppTypography.titleMedium,
                ),
              ],
            ),
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.chevron_right,
            color: isToday ? AppColors.divider : AppColors.onSurface,
          ),
          onPressed: isToday
              ? null
              : () => ref.read(selectedLogDateProvider.notifier).nextDay(),
        ),
      ],
    );
  }
}
