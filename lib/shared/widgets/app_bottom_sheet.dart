import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

/// 스타일이 적용된 모달 바텀시트를 표시하는 헬퍼 함수
Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  String? title,
  Widget? titleTrailing,
  bool isDismissible = true,
  bool isScrollControlled = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    backgroundColor: Colors.transparent,
    isDismissible: isDismissible,
    builder: (_) => _AppBottomSheetWrapper(title: title, titleTrailing: titleTrailing, child: child),
  );
}

class _AppBottomSheetWrapper extends StatelessWidget {
  const _AppBottomSheetWrapper({required this.child, this.title, this.titleTrailing});

  final Widget child;
  final String? title;
  final Widget? titleTrailing;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            if (title != null) ...[
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(title!, style: AppTypography.titleMedium),
                    if (titleTrailing != null)
                      Positioned(right: AppSpacing.pagePadding, child: titleTrailing!),
                  ],
                ),
              ),
            ],
            child,
          ],
        ),
      ),
    );
  }
}
