import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/extensions/l10n_ext.dart';
import '../../../../shared/models/volume_unit.dart';
import '../../../../shared/providers/volume_unit_provider.dart';
import '../../domain/models/timeline_entry.dart';

class TimelineItemTile extends ConsumerWidget {
  const TimelineItemTile({
    super.key,
    required this.entry,
    required this.isFirst,
    required this.isLast,
    this.showElapsed = false,
    this.onTap,
  });

  final TimelineEntry entry;
  final bool isFirst;
  final bool isLast;
  final bool showElapsed;
  final VoidCallback? onTap;

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  String _formatElapsed(DateTime occurredAt) {
    final diff = DateTime.now().difference(occurredAt);
    if (diff.inMinutes < 1) return '방금';
    if (diff.inHours < 1) return '${diff.inMinutes}분 경과';
    final hours = diff.inHours;
    final minutes = diff.inMinutes - hours * 60;
    if (minutes == 0) return '$hours시간 경과';
    return '$hours시간 $minutes분 경과';
  }

  Color _resolvedColor(BuildContext context) {
    if (entry.type == TimelineEntryType.sleep &&
        Theme.of(context).brightness == Brightness.dark) {
      return const Color(0xFF607D8B);
    }
    return entry.color;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unit = ref.watch(volumeUnitProvider).valueOrNull ?? VolumeUnit.ml;
    final color = _resolvedColor(context);

    String subtitle = entry.localizedSubtitle(context.l10n);
    // ml 기반 타입이면 unit에 맞게 포맷
    if (entry.rawAmountMl != null &&
        (entry.type == TimelineEntryType.formula ||
            entry.type == TimelineEntryType.pumped ||
            entry.type == TimelineEntryType.babyFood)) {
      subtitle = unit.formatAmount(entry.rawAmountMl!);
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 시간 컬럼
          SizedBox(
            width: 52,
            child: Padding(
              padding: const EdgeInsets.only(top: 9),
              child: Text(
                _formatTime(entry.occurredAt),
                style: AppTypography.bodySmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // 카드 내용
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                top: 1,
                bottom: isLast ? 1 : 2,
              ),
              child: GestureDetector(
                onTap: onTap,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.white
                          : Theme.of(context).colorScheme.surfaceContainerHigh,
                      border: Border(
                        left: BorderSide(color: color),
                        bottom: BorderSide(color: color.withValues(alpha: 0.15)),
                      ),
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 왼쪽 컬러 액센트 바
                          Container(
                            width: 4,
                            color: color,
                          ),
                          // 카드 내용
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: 9,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          entry.localizedTitle(context.l10n),
                                          style: AppTypography.labelLarge.copyWith(
                                            color: Theme.of(context).colorScheme.onSurface,
                                          ),
                                        ),
                                        Text(
                                          subtitle,
                                          style: AppTypography.bodySmall.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withValues(alpha: 0.55),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (showElapsed) ...[
                                    Text(
                                      _formatElapsed(entry.occurredAt),
                                      style: AppTypography.bodySmall.copyWith(
                                        color: color.withValues(alpha: 0.75),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                  ],
                                  Icon(
                                    Icons.chevron_right,
                                    size: 18,
                                    color: color.withValues(alpha: 0.4),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
