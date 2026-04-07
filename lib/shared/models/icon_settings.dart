import 'dart:convert';

import '../../features/log/domain/models/timeline_entry.dart';
import 'tracking_category.dart';

class CategorySetting {
  const CategorySetting({
    required this.type,
    required this.visible,
    required this.order,
  });

  final TimelineEntryType type;
  final bool visible;
  final int order;

  CategorySetting copyWith({bool? visible, int? order}) => CategorySetting(
        type: type,
        visible: visible ?? this.visible,
        order: order ?? this.order,
      );

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'visible': visible,
        'order': order,
      };

  static CategorySetting? fromJson(Map<String, dynamic> json) {
    try {
      final type = TimelineEntryType.values.firstWhere(
        (e) => e.name == json['type'],
      );
      return CategorySetting(
        type: type,
        visible: json['visible'] as bool,
        order: json['order'] as int,
      );
    } catch (_) {
      return null;
    }
  }
}

class IconSettings {
  const IconSettings(this.categories);

  /// Sorted by [CategorySetting.order].
  final List<CategorySetting> categories;

  List<TimelineEntryType> get visibleOrdered => categories
      .where((c) => c.visible)
      .map((c) => c.type)
      .toList();

  static IconSettings defaultSettings() {
    final defaults = TrackingCategoryInfo.defaultOrder;
    return IconSettings([
      for (int i = 0; i < defaults.length; i++)
        CategorySetting(type: defaults[i], visible: true, order: i),
    ]);
  }

  IconSettings withToggled(TimelineEntryType type) {
    return IconSettings([
      for (final c in categories)
        if (c.type == type) c.copyWith(visible: !c.visible) else c,
    ]);
  }

  IconSettings withReordered(int oldIndex, int newIndex) {
    final list = List<CategorySetting>.from(categories);
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    return IconSettings([
      for (int i = 0; i < list.length; i++) list[i].copyWith(order: i),
    ]);
  }

  String toJsonString() => jsonEncode(categories.map((c) => c.toJson()).toList());

  static IconSettings fromJsonString(String json) {
    try {
      final list = (jsonDecode(json) as List)
          .map((e) => CategorySetting.fromJson(e as Map<String, dynamic>))
          .whereType<CategorySetting>()
          .toList();

      // Ensure all types present (in case new types added after save)
      final presentTypes = list.map((c) => c.type).toSet();
      final missing = TrackingCategoryInfo.defaultOrder
          .where((t) => !presentTypes.contains(t))
          .toList();
      for (final t in missing) {
        list.add(CategorySetting(type: t, visible: true, order: list.length));
      }

      list.sort((a, b) => a.order.compareTo(b.order));
      return IconSettings(list);
    } catch (_) {
      return defaultSettings();
    }
  }
}
