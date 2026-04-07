import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/extensions/l10n_ext.dart';

/// 날짜·시·분을 3열 휠로 선택하는 통합 피커를 모달 바텀시트로 표시합니다.
///
/// 반환값: 선택한 [DateTime], 취소 시 null.
Future<DateTime?> showDateTimeWheelPicker(
  BuildContext context, {
  required DateTime initialDateTime,
}) {
  return showModalBottomSheet<DateTime>(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => _DateTimeWheelPickerContent(initial: initialDateTime),
  );
}

class _DateTimeWheelPickerContent extends StatefulWidget {
  const _DateTimeWheelPickerContent({required this.initial});

  final DateTime initial;

  @override
  State<_DateTimeWheelPickerContent> createState() =>
      _DateTimeWheelPickerContentState();
}

class _DateTimeWheelPickerContentState
    extends State<_DateTimeWheelPickerContent> {
  static const _itemExtent = 50.0;
  static const _dayCount = 30; // 오늘 포함 30일

  late final List<DateTime> _dates;
  late int _dateIdx;
  late int _hour;
  late int _minute;

  late final FixedExtentScrollController _dateCtrl;
  late final FixedExtentScrollController _hourCtrl;
  late final FixedExtentScrollController _minCtrl;

  @override
  void initState() {
    super.initState();

    // 날짜 목록: 오늘부터 29일 전까지 (최신이 마지막)
    final today = DateTime.now();
    _dates = List.generate(
      _dayCount,
      (i) => DateTime(today.year, today.month, today.day - (_dayCount - 1 - i)),
    );

    // 초기 선택 날짜 인덱스
    final initDay = DateTime(
      widget.initial.year,
      widget.initial.month,
      widget.initial.day,
    );
    final idx = _dates.indexWhere(
      (d) => d.year == initDay.year && d.month == initDay.month && d.day == initDay.day,
    );
    _dateIdx = idx >= 0 ? idx : _dates.length - 1;
    _hour = widget.initial.hour;
    _minute = widget.initial.minute;

    _dateCtrl = FixedExtentScrollController(initialItem: _dateIdx);
    _hourCtrl = FixedExtentScrollController(initialItem: _hour);
    _minCtrl = FixedExtentScrollController(initialItem: _minute);
  }

  @override
  void dispose() {
    _dateCtrl.dispose();
    _hourCtrl.dispose();
    _minCtrl.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d, BuildContext context) {
    final l10n = context.l10n;
    final today = DateTime.now();
    if (d.year == today.year && d.month == today.month && d.day == today.day) {
      return l10n.pickerToday;
    }
    final weekdays = [
      l10n.weekdayMon,
      l10n.weekdayTue,
      l10n.weekdayWed,
      l10n.weekdayThu,
      l10n.weekdayFri,
      l10n.weekdaySat,
      l10n.weekdaySun,
    ];
    return l10n.dateFormatFull(d.month, d.day, weekdays[d.weekday - 1]);
  }

  Widget _buildWheelColumn({
    required FixedExtentScrollController controller,
    required int itemCount,
    required String Function(int) labelOf,
    required String? unit, // 선택 행 옆에 붙는 단위 (시, 분) — null이면 없음
    required int selectedIdx,
    required ValueChanged<int> onChanged,
    int flex = 2,
  }) {
    return Expanded(
      flex: flex,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 선택 행 하이라이트
          Container(
            height: _itemExtent,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          ListWheelScrollView.useDelegate(
            controller: controller,
            itemExtent: _itemExtent,
            perspective: 0.004,
            diameterRatio: 1.6,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: (i) {
              setState(() => onChanged(i));
            },
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: itemCount,
              builder: (_, i) {
                final isSelected = i == selectedIdx;
                final label = labelOf(i);
                final textStyle = (isSelected
                        ? AppTypography.titleMedium
                        : AppTypography.bodyMedium)
                    .copyWith(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.onSurfaceMuted,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w400,
                );
                return Center(
                  child: unit != null && isSelected
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(label, style: textStyle),
                            const SizedBox(width: 2),
                            Text(
                              unit,
                              style: textStyle.copyWith(fontSize: 13),
                            ),
                          ],
                        )
                      : Text(label, style: textStyle),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 핸들
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.onSurfaceMuted.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // 3열 휠
          SizedBox(
            height: 220,
            child: Row(
              children: [
                // 날짜 열
                _buildWheelColumn(
                  controller: _dateCtrl,
                  itemCount: _dates.length,
                  labelOf: (i) => _formatDate(_dates[i], context),
                  unit: null,
                  selectedIdx: _dateIdx,
                  onChanged: (i) => _dateIdx = i,
                  flex: 3,
                ),
                const SizedBox(width: 4),
                // 시 열
                _buildWheelColumn(
                  controller: _hourCtrl,
                  itemCount: 24,
                  labelOf: (i) => i.toString().padLeft(2, '0'),
                  unit: context.l10n.pickerHour,
                  selectedIdx: _hour,
                  onChanged: (i) => _hour = i,
                ),
                const SizedBox(width: 4),
                // 분 열
                _buildWheelColumn(
                  controller: _minCtrl,
                  itemCount: 60,
                  labelOf: (i) => i.toString().padLeft(2, '0'),
                  unit: context.l10n.pickerMinute,
                  selectedIdx: _minute,
                  onChanged: (i) => _minute = i,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // 확인 버튼
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                final d = _dates[_dateIdx];
                Navigator.of(context).pop(
                  DateTime(d.year, d.month, d.day, _hour, _minute),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(context.l10n.pickerConfirm),
            ),
          ),
        ],
      ),
    );
  }
}
