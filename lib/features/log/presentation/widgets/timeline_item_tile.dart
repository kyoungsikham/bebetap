import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/timeline_entry.dart';

class TimelineItemTile extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // 세로선 + 점
          Column(
            children: [
              // 위쪽 선분
              SizedBox(
                width: 2,
                height: 16,
                child: ColoredBox(
                  color: isFirst ? Colors.transparent : AppColors.primary,
                ),
              ),
              // 원형 점
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: entry.color,
                  shape: BoxShape.circle,
                ),
              ),
              // 아래쪽 선분 (flex)
              Expanded(
                child: SizedBox(
                  width: 2,
                  child: ColoredBox(
                    color: isLast ? Colors.transparent : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),

          // 카드 내용
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                top: AppSpacing.sm,
                bottom: isLast ? AppSpacing.sm : AppSpacing.md,
              ),
              child: GestureDetector(
                onTap: onTap,
                child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: entry.color.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(entry.icon, color: entry.color, size: 16),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            entry.title,
                            style: AppTypography.labelLarge.copyWith(
                              color: AppColors.onSurface,
                            ),
                          ),
                          Text(
                            entry.subtitle,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.onSurfaceMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: AppColors.onSurfaceMuted,
                    ),
                  ],
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
