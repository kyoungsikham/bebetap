import 'package:flutter/material.dart';

import '../../../../core/theme/app_typography.dart';
import '../../domain/models/daily_timeline.dart';

class DailyTimelineChart extends StatelessWidget {
  const DailyTimelineChart({
    super.key,
    required this.data,
    required this.activeFilters,
  });

  final TimelineData data;
  final Set<TimelineEventType> activeFilters;

  static const _chartHeight = 480.0;
  static const _hourCount = 24;
  static const _hourHeight = _chartHeight / _hourCount;
  static const _yAxisWidth = 28.0;
  static const _yAxisGap = 4.0;

  // Colors — must match icon colors in TimelineEntry (timeline_entry.dart)
  static const _sleepColor = Color(0xFF5C6BC0);
  static const _formulaColor = Color(0xFF4A90E2);
  static const _breastColor = Color(0xFFD81B60);
  static const _pumpedColor = Color(0xFF9C27B0);
  static const _babyFoodColor = Color(0xFFFFA000);
  static const _diaperColor = Color(0xFF00BFA5);

  static Color colorFor(TimelineEventType type) {
    return switch (type) {
      TimelineEventType.sleep => _sleepColor,
      TimelineEventType.formula => _formulaColor,
      TimelineEventType.breast => _breastColor,
      TimelineEventType.pumped => _pumpedColor,
      TimelineEventType.babyFood => _babyFoodColor,
      TimelineEventType.diaper => _diaperColor,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final numDays = data.days.length;
    if (numDays == 0) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth =
            constraints.maxWidth - _yAxisWidth - _yAxisGap;
        final columnWidth = numDays > 0 ? availableWidth / numDays : 48.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chart area
            SizedBox(
              height: _chartHeight + 24, // extra for date labels
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Y-axis
                  _YAxisLabels(
                    chartHeight: _chartHeight,
                    hourHeight: _hourHeight,
                    colorScheme: colorScheme,
                  ),
                  SizedBox(width: _yAxisGap),
                  // Day columns
                  Expanded(
                    child: Row(
                      children: data.days.map((day) {
                        return Expanded(
                          child: _DayColumn(
                            day: day,
                            activeFilters: activeFilters,
                            chartHeight: _chartHeight,
                            hourHeight: _hourHeight,
                            columnWidth: columnWidth,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _YAxisLabels extends StatelessWidget {
  const _YAxisLabels({
    required this.chartHeight,
    required this.hourHeight,
    required this.colorScheme,
  });

  final double chartHeight;
  final double hourHeight;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: DailyTimelineChart._yAxisWidth,
      height: chartHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: List.generate(13, (i) {
          final hour = i * 2;
          return Positioned(
            top: hour * hourHeight - 6,
            left: 0,
            right: 0,
            child: Text(
              hour.toString().padLeft(2, '0'),
              style: AppTypography.labelSmall.copyWith(
                fontSize: 10,
                color: colorScheme.onSurface.withValues(alpha: 0.4),
              ),
              textAlign: TextAlign.right,
            ),
          );
        }),
      ),
    );
  }
}

class _DayColumn extends StatelessWidget {
  const _DayColumn({
    required this.day,
    required this.activeFilters,
    required this.chartHeight,
    required this.hourHeight,
    required this.columnWidth,
  });

  final DayTimeline day;
  final Set<TimelineEventType> activeFilters;
  final double chartHeight;
  final double hourHeight;
  final double columnWidth;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final filteredEvents =
        day.events.where((e) => activeFilters.contains(e.type)).toList();

    // Sort: sleep first (behind), then feeding types, then diaper on top
    filteredEvents.sort((a, b) => a.type.index.compareTo(b.type.index));

    // Date label: just day number
    final dayNum = day.date.day.toString();

    return Column(
      children: [
        // Chart column with events
        Container(
          height: chartHeight,
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: colorScheme.onSurface.withValues(alpha: 0.06),
                width: 0.5,
              ),
              right: BorderSide(
                color: colorScheme.onSurface.withValues(alpha: 0.06),
                width: 0.5,
              ),
            ),
          ),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              // Hour grid lines
              ...List.generate(24, (i) {
                return Positioned(
                  top: i * hourHeight,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 0.5,
                    color: colorScheme.onSurface.withValues(alpha: 0.04),
                  ),
                );
              }),
              // Event blocks
              ...filteredEvents.map((event) {
                return _buildEventBlock(event, context);
              }),
            ],
          ),
        ),
        // Date label
        const SizedBox(height: 4),
        Text(
          dayNum,
          style: AppTypography.labelSmall.copyWith(
            fontSize: 10,
            color: colorScheme.onSurface.withValues(alpha: 0.55),
          ),
        ),
      ],
    );
  }

  Widget _buildEventBlock(TimelineEvent event, BuildContext context) {
    final dayStart = DateTime(day.date.year, day.date.month, day.date.day);

    final startMinutes = event.start.difference(dayStart).inMinutes;
    final endMinutes = event.end.difference(dayStart).inMinutes;
    final durationMinutes = endMinutes - startMinutes;

    final top = (startMinutes / 60.0) * hourHeight;
    final height = (durationMinutes / 60.0) * hourHeight;

    if (event.type == TimelineEventType.diaper) {
      return Positioned(
        top: top,
        left: 2,
        right: 2,
        child: _DiaperMarker(
          subType: event.subType,
          color: DailyTimelineChart.colorFor(TimelineEventType.diaper),
        ),
      );
    }

    final color = DailyTimelineChart.colorFor(event.type);
    final minHeight =
        event.type == TimelineEventType.sleep ? 1.0 : 3.0;

    return Positioned(
      top: top,
      left: 2,
      right: 2,
      height: height.clamp(minHeight, chartHeight - top),
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _DiaperMarker extends StatelessWidget {
  const _DiaperMarker({required this.subType, required this.color});

  final String? subType;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isSoiled = subType == 'soiled' || subType == 'both';
    return SizedBox(
      height: 14,
      child: Center(
        child: Container(
          width: double.infinity,
          height: 12,
          decoration: BoxDecoration(
            color: color.withValues(alpha: isSoiled ? 0.6 : 0.35),
            borderRadius: BorderRadius.circular(2),
          ),
          alignment: Alignment.center,
          child: isSoiled
              ? const Text('\u{1F4A9}', style: TextStyle(fontSize: 8))
              : Icon(Icons.water_drop, size: 8,
                  color: color.withValues(alpha: 0.8)),
        ),
      ),
    );
  }
}

/// Filter chip used by the parent screen for timeline event type filtering.
class TimelineFilterChip extends StatelessWidget {
  const TimelineFilterChip({
    super.key,
    required this.label,
    required this.type,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final TimelineEventType type;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = DailyTimelineChart.colorFor(type);
    return GestureDetector(
      onTap: () => onSelected(!selected),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.15)
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? color.withValues(alpha: 0.5)
                : colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: selected ? color : color.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: selected
                    ? colorScheme.onSurface
                    : colorScheme.onSurface.withValues(alpha: 0.45),
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
