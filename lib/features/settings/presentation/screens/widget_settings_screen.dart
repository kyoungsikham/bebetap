import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/ad_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/extensions/l10n_ext.dart';
import '../../../../shared/models/widget_settings.dart';
import '../../../../shared/providers/widget_settings_provider.dart';
import '../../../../shared/widgets/banner_ad_widget.dart';

class WidgetSettingsScreen extends ConsumerStatefulWidget {
  const WidgetSettingsScreen({super.key});

  @override
  ConsumerState<WidgetSettingsScreen> createState() =>
      _WidgetSettingsScreenState();
}

class _WidgetSettingsScreenState extends ConsumerState<WidgetSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final settings =
        ref.watch(widgetSettingsProvider).valueOrNull ?? WidgetSettings.defaultSettings();
    final notifier = ref.read(widgetSettingsProvider.notifier);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(l10n.widgetSettingsTitle, style: AppTypography.titleMedium),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        children: [
          // ── 테마 섹션 ────────────────────────────────────────
          _SectionHeader(title: l10n.widgetSettingsTheme),
          RadioGroup<WidgetThemeMode>(
            groupValue: settings.themeMode,
            onChanged: (v) {
              if (v != null) notifier.setThemeMode(v);
            },
            child: Column(
              children: WidgetThemeMode.values.map((mode) {
                final label = switch (mode) {
                  WidgetThemeMode.system => l10n.widgetSettingsThemeSystem,
                  WidgetThemeMode.light  => l10n.widgetSettingsThemeLight,
                  WidgetThemeMode.dark   => l10n.widgetSettingsThemeDark,
                };
                return RadioListTile<WidgetThemeMode>(
                  title: Text(label, style: AppTypography.bodyLarge),
                  value: mode,
                  activeColor: AppColors.primary,
                );
              }).toList(),
            ),
          ),

          const Divider(height: 1),

          // ── 투명도 섹션 ──────────────────────────────────────
          _SectionHeader(title: l10n.widgetSettingsOpacity),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.pagePadding, 0, AppSpacing.pagePadding, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: settings.opacity,
                        min: 0.1,
                        max: 1.0,
                        divisions: 9,
                        activeColor: AppColors.primary,
                        onChanged: (v) => notifier.setOpacity(v),
                      ),
                    ),
                    SizedBox(
                      width: 40,
                      child: Text(
                        l10n.widgetSettingsOpacityLabel(
                            (settings.opacity * 100).round()),
                        style: AppTypography.bodySmall
                            .copyWith(color: AppColors.primary),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Text(
                    l10n.widgetSettingsOpacityHint,
                    style: AppTypography.bodySmall
                        .copyWith(color: AppColors.onSurfaceMuted),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),
          BannerAdWidget(adUnitId: AdConfig.iconSettingsBannerId),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.pagePadding, AppSpacing.lg, AppSpacing.pagePadding, AppSpacing.xs),
      child: Text(
        title,
        style: AppTypography.labelLarge
            .copyWith(color: AppColors.onSurfaceMuted),
      ),
    );
  }
}

