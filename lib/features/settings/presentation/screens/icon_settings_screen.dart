import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/models/tracking_category.dart';
import '../../../../shared/providers/icon_settings_provider.dart';

class IconSettingsScreen extends ConsumerWidget {
  const IconSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(allCategoriesOrderedProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('아이콘 설정', style: AppTypography.titleMedium),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              '드래그로 순서를 변경하고, 스위치로 표시 여부를 설정하세요.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.onSurfaceMuted,
              ),
            ),
          ),
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: categories.length,
              // onReorderItem provides already-adjusted newIndex (no need for newIndex--)
              onReorderItem: (oldIndex, newIndex) {
                ref
                    .read(iconSettingsProvider.notifier)
                    .reorder(oldIndex, newIndex);
              },
              itemBuilder: (context, index) {
                final setting = categories[index];
                final info = TrackingCategoryInfo.all[setting.type]!;
                return _CategoryTile(
                  key: ValueKey(setting.type),
                  index: index,
                  info: info,
                  visible: setting.visible,
                  onToggle: () => ref
                      .read(iconSettingsProvider.notifier)
                      .toggleVisibility(setting.type),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    super.key,
    required this.index,
    required this.info,
    required this.visible,
    required this.onToggle,
  });

  final int index;
  final TrackingCategoryInfo info;
  final bool visible;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: AppColors.background,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: visible
              ? info.color.withValues(alpha: 0.15)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          info.icon,
          color: visible ? info.color : AppColors.onSurfaceMuted,
          size: 20,
        ),
      ),
      title: Text(
        info.label,
        style: AppTypography.bodyLarge.copyWith(
          color: visible ? AppColors.onSurface : AppColors.onSurfaceMuted,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Switch(
            value: visible,
            onChanged: (_) => onToggle(),
            activeThumbColor: info.color,
            activeTrackColor: info.color.withValues(alpha: 0.3),
          ),
          ReorderableDragStartListener(
            index: index,
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.drag_handle, color: AppColors.onSurfaceMuted),
            ),
          ),
        ],
      ),
    );
  }
}
