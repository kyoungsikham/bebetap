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
    this.onTap,
  });

  final TimelineEntry entry;
  final bool isFirst;
  final bool isLast;
  final VoidCallback? onTap;

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unit = ref.watch(volumeUnitProvider).valueOrNull ?? VolumeUnit.ml;

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
              padding: const EdgeInsets.only(top: 14),
              child: Text(
                _formatTime(entry.occurredAt),
                style: AppTypography.bodySmall.copyWith(
                  color: entry.color,
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
                        left: BorderSide(color: Theme.of(context).dividerColor),
                        bottom: BorderSide(color: Theme.of(context).dividerColor),
                      ),
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 왼쪽 컬러 액센트 바
                          Container(
                            width: 4,
                            color: entry.color,
                          ),
                          // 카드 내용
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: 14,
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
                                  Icon(
                                    Icons.chevron_right,
                                    size: 18,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.4),
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
