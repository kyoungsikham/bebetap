import 'package:flutter/material.dart';

import '../../../../core/theme/app_typography.dart';
import '../../../../shared/extensions/l10n_ext.dart';
import '../../domain/models/period.dart';

class PeriodTabBar extends StatelessWidget {
  const PeriodTabBar({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final Period selected;
  final ValueChanged<Period> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: Period.values.map((p) {
          final isSelected = p == selected;
          final colorScheme = Theme.of(context).colorScheme;
          return GestureDetector(
            onTap: () => onChanged(p),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? colorScheme.surface : Colors.transparent,
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
              child: Text(
                p.localizedLabel(context.l10n),
                style: AppTypography.bodySmall.copyWith(
                  color: isSelected
                      ? colorScheme.onSurface
                      : colorScheme.onSurface.withValues(alpha: 0.55),
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
