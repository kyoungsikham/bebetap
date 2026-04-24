import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/providers/database_provider.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../extensions/l10n_ext.dart';
import '../models/default_landing.dart';
import '../models/theme_mode_setting.dart';
import '../models/volume_unit.dart';
import '../providers/ad_free_provider.dart';
import '../providers/default_landing_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/volume_unit_provider.dart';

void showHamburgerMenu(BuildContext context, WidgetRef ref) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: '',
    barrierColor: Colors.black45,
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (_, _, _) => HamburgerMenuPanel(ref: ref),
    transitionBuilder: (_, anim, _, child) => SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
      child: child,
    ),
  );
}

class HamburgerMenuPanel extends ConsumerStatefulWidget {
  const HamburgerMenuPanel({super.key, required this.ref});

  final WidgetRef ref;

  @override
  ConsumerState<HamburgerMenuPanel> createState() => _HamburgerMenuPanelState();
}

enum _ExpandedSection { none, theme, language, unit, defaultLanding }

class _HamburgerMenuPanelState extends ConsumerState<HamburgerMenuPanel> {
  _ExpandedSection _expanded = _ExpandedSection.none;

  void _toggle(_ExpandedSection section) {
    setState(() {
      _expanded = _expanded == section ? _ExpandedSection.none : section;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final currentLocale = ref.watch(localeProvider).valueOrNull;
    final themeSetting =
        ref.watch(themeSettingProvider).valueOrNull ?? const ThemeModeSetting();
    final currentUnit =
        ref.watch(volumeUnitProvider).valueOrNull ?? VolumeUnit.ml;
    final currentLanding =
        ref.watch(defaultLandingProvider).valueOrNull ?? DefaultLanding.log;
    final isPremium = ref.watch(adFreeProvider).valueOrNull ?? false;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final panelColor =
        isDark ? const Color(0xFF1E1B2E) : const Color(0xFFF4F4F6);
    final submenuColor =
        isDark ? const Color(0xFF161324) : const Color(0xFFE8E8EC);

    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        color: panelColor,
        borderRadius: const BorderRadius.horizontal(
          left: Radius.circular(20),
        ),
        child: SafeArea(
          child: SizedBox(
            width: 280,
            height: double.infinity,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // BebeTap 로고 헤더
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.pagePadding,
                      AppSpacing.lg,
                      AppSpacing.pagePadding,
                      AppSpacing.lg,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(
                        alpha: isDark ? 0.14 : 0.08,
                      ),
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Text(
                      'BebeTap',
                      style: AppTypography.titleLarge.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  ListTile(
                    leading: const Icon(Icons.child_care),
                    title: Text(l10n.menuBabyManage),
                    onTap: () {
                      final router = GoRouter.of(context);
                      Navigator.of(context, rootNavigator: true).pop();
                      Future.microtask(
                          () => router.push(AppRoutes.babyManage));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.grid_view_outlined),
                    title: Text(l10n.menuIconSettings),
                    onTap: () {
                      final router = GoRouter.of(context);
                      Navigator.of(context, rootNavigator: true).pop();
                      Future.microtask(
                          () => router.push(AppRoutes.iconSettings));
                    },
                  ),
                  // 테마 설정
                  ListTile(
                    leading: const Icon(Icons.brightness_6_outlined),
                    title: Text(l10n.menuTheme),
                    trailing: Icon(
                      _expanded == _ExpandedSection.theme
                          ? Icons.expand_less
                          : Icons.expand_more,
                      color: AppColors.onSurfaceMuted,
                    ),
                    onTap: () => _toggle(_ExpandedSection.theme),
                  ),
                  if (_expanded == _ExpandedSection.theme)
                    Container(
                      color: submenuColor,
                      child: Column(
                        children: [
                          _ThemeOption(
                            label: l10n.themeLight,
                            mode: AppThemeMode.light,
                            isSelected: themeSetting.mode == AppThemeMode.light,
                            onTap: () => _changeTheme(AppThemeMode.light),
                          ),
                          _ThemeOption(
                            label: l10n.themeDark,
                            mode: AppThemeMode.dark,
                            isSelected: themeSetting.mode == AppThemeMode.dark,
                            onTap: () => _changeTheme(AppThemeMode.dark),
                          ),
                          _ThemeOption(
                            label: l10n.themeSystem,
                            mode: AppThemeMode.system,
                            isSelected:
                                themeSetting.mode == AppThemeMode.system,
                            onTap: () => _changeTheme(AppThemeMode.system),
                          ),
                          _ThemeOption(
                            label: l10n.themeScheduled,
                            mode: AppThemeMode.scheduled,
                            isSelected:
                                themeSetting.mode == AppThemeMode.scheduled,
                            onTap: () => _changeTheme(AppThemeMode.scheduled),
                          ),
                          if (themeSetting.mode == AppThemeMode.scheduled) ...[
                            _ScheduleTimeTile(
                              label: l10n.themeScheduleStart,
                              hour: themeSetting.darkStartHour,
                              minute: themeSetting.darkStartMinute,
                              onTap: () => _pickTime(
                                context,
                                initialHour: themeSetting.darkStartHour,
                                initialMinute: themeSetting.darkStartMinute,
                                isStart: true,
                                setting: themeSetting,
                              ),
                            ),
                            _ScheduleTimeTile(
                              label: l10n.themeScheduleEnd,
                              hour: themeSetting.darkEndHour,
                              minute: themeSetting.darkEndMinute,
                              onTap: () => _pickTime(
                                context,
                                initialHour: themeSetting.darkEndHour,
                                initialMinute: themeSetting.darkEndMinute,
                                isStart: false,
                                setting: themeSetting,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  // 언어 설정
                  ListTile(
                    leading: const Icon(Icons.language),
                    title: Text(l10n.menuLanguage),
                    trailing: Icon(
                      _expanded == _ExpandedSection.language
                          ? Icons.expand_less
                          : Icons.expand_more,
                      color: AppColors.onSurfaceMuted,
                    ),
                    onTap: () => _toggle(_ExpandedSection.language),
                  ),
                  if (_expanded == _ExpandedSection.language)
                    Container(
                      color: submenuColor,
                      child: Column(
                        children: [
                          _LanguageOption(
                            label: '한국어',
                            locale: const Locale('ko'),
                            isSelected: currentLocale?.languageCode == 'ko',
                            onTap: () => _changeLocale(const Locale('ko')),
                          ),
                          _LanguageOption(
                            label: 'English',
                            locale: const Locale('en'),
                            isSelected: currentLocale?.languageCode == 'en',
                            onTap: () => _changeLocale(const Locale('en')),
                          ),
                          _LanguageOption(
                            label: '日本語',
                            locale: const Locale('ja'),
                            isSelected: currentLocale?.languageCode == 'ja',
                            onTap: () => _changeLocale(const Locale('ja')),
                          ),
                        ],
                      ),
                    ),
                  // 단위 설정
                  ListTile(
                    leading: const Icon(Icons.straighten_outlined),
                    title: Text(l10n.menuVolumeUnit),
                    trailing: Icon(
                      _expanded == _ExpandedSection.unit
                          ? Icons.expand_less
                          : Icons.expand_more,
                      color: AppColors.onSurfaceMuted,
                    ),
                    onTap: () => _toggle(_ExpandedSection.unit),
                  ),
                  if (_expanded == _ExpandedSection.unit)
                    Container(
                      color: submenuColor,
                      child: Column(
                        children: [
                          _UnitOption(
                            label: l10n.volumeUnitMl,
                            isSelected: currentUnit == VolumeUnit.ml,
                            icon: Icons.water_drop_outlined,
                            onTap: () => ref
                                .read(volumeUnitProvider.notifier)
                                .setUnit(VolumeUnit.ml),
                          ),
                          _UnitOption(
                            label: l10n.volumeUnitOz,
                            isSelected: currentUnit == VolumeUnit.oz,
                            icon: Icons.scale_outlined,
                            onTap: () => ref
                                .read(volumeUnitProvider.notifier)
                                .setUnit(VolumeUnit.oz),
                          ),
                        ],
                      ),
                    ),
                  // 기본 시작 화면
                  ListTile(
                    leading: const Icon(Icons.flag_outlined),
                    title: Text(l10n.menuDefaultLanding),
                    trailing: Icon(
                      _expanded == _ExpandedSection.defaultLanding
                          ? Icons.expand_less
                          : Icons.expand_more,
                      color: AppColors.onSurfaceMuted,
                    ),
                    onTap: () => _toggle(_ExpandedSection.defaultLanding),
                  ),
                  if (_expanded == _ExpandedSection.defaultLanding)
                    Container(
                      color: submenuColor,
                      child: Column(
                        children: [
                          _DefaultLandingOption(
                            label: l10n.menuDefaultLandingHome,
                            isSelected: currentLanding == DefaultLanding.home,
                            icon: Icons.home_outlined,
                            onTap: () => ref
                                .read(defaultLandingProvider.notifier)
                                .setLanding(DefaultLanding.home),
                          ),
                          _DefaultLandingOption(
                            label: l10n.menuDefaultLandingLog,
                            isSelected: currentLanding == DefaultLanding.log,
                            icon: Icons.list_alt_outlined,
                            onTap: () => ref
                                .read(defaultLandingProvider.notifier)
                                .setLanding(DefaultLanding.log),
                          ),
                        ],
                      ),
                    ),
                  // 광고 제거 (인앱결제)
                  ListTile(
                    leading: Icon(
                      Icons.block_outlined,
                      color: isPremium ? AppColors.success : null,
                    ),
                    title: Text(l10n.menuRemoveAds),
                    subtitle: Text(
                      isPremium ? l10n.removeAdsActive : l10n.removeAdsSubtitle,
                      style: AppTypography.bodySmall,
                    ),
                    trailing: isPremium
                        ? const Icon(Icons.check_circle,
                            color: AppColors.success, size: 18)
                        : const Icon(Icons.chevron_right,
                            color: AppColors.onSurfaceMuted),
                    onTap: () {
                      final router = GoRouter.of(context);
                      Navigator.of(context, rootNavigator: true).pop();
                      Future.microtask(() => router.push(AppRoutes.paywall));
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout, color: AppColors.error),
                    title: Text(
                      l10n.menuLogout,
                      style: AppTypography.bodyLarge
                          .copyWith(color: AppColors.error),
                    ),
                    onTap: () async {
                      final navigator =
                          Navigator.of(context, rootNavigator: true);
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(l10n.logoutConfirmTitle),
                          content: Text(l10n.logoutConfirmMessage),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: Text(l10n.cancel),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: Text(
                                l10n.menuLogout,
                                style: const TextStyle(color: AppColors.error),
                              ),
                            ),
                          ],
                        ),
                      );
                      if (confirmed != true) return;
                      final db = ref.read(appDatabaseProvider);
                      navigator.pop();
                      try {
                        await db.clearAllData();
                      } catch (e) {
                        debugPrint('clearAllData error (ignored): $e');
                      }
                      await Supabase.instance.client.auth.signOut();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _changeLocale(Locale locale) async {
    await ref.read(localeProvider.notifier).setLocale(locale);
    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  Future<void> _changeTheme(AppThemeMode mode) async {
    await ref.read(themeSettingProvider.notifier).setMode(mode);
  }

  Future<void> _pickTime(
    BuildContext context, {
    required int initialHour,
    required int initialMinute,
    required bool isStart,
    required ThemeModeSetting setting,
  }) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initialHour, minute: initialMinute),
    );
    if (picked == null) return;
    if (isStart) {
      await ref.read(themeSettingProvider.notifier).setSchedule(
            startHour: picked.hour,
            startMinute: picked.minute,
            endHour: setting.darkEndHour,
            endMinute: setting.darkEndMinute,
          );
    } else {
      await ref.read(themeSettingProvider.notifier).setSchedule(
            startHour: setting.darkStartHour,
            startMinute: setting.darkStartMinute,
            endHour: picked.hour,
            endMinute: picked.minute,
          );
    }
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.label,
    required this.locale,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final Locale locale;
  final bool isSelected;
  final VoidCallback onTap;

  String get _code => switch (locale.languageCode) {
        'ko' => 'KO',
        'en' => 'EN',
        'ja' => 'JA',
        _ => '??',
      };

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = isSelected ? AppColors.primary : colorScheme.onSurface.withValues(alpha: 0.6);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pagePadding,
          vertical: 10,
        ),
        child: Row(
          children: [
            const SizedBox(width: AppSpacing.md),
            Container(
              width: 26,
              height: 18,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: color, width: 1.2),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                _code,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: color,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: isSelected ? AppColors.primary : colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check, color: AppColors.primary, size: 18),
          ],
        ),
      ),
    );
  }
}

class _UnitOption extends StatelessWidget {
  const _UnitOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.icon,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = isSelected ? AppColors.primary : colorScheme.onSurface.withValues(alpha: 0.6);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pagePadding,
          vertical: 10,
        ),
        child: Row(
          children: [
            const SizedBox(width: AppSpacing.md),
            Icon(icon, size: 18, color: color),
            const SizedBox(width: AppSpacing.md),
            Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: isSelected ? AppColors.primary : colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check, color: AppColors.primary, size: 18),
          ],
        ),
      ),
    );
  }
}

class _DefaultLandingOption extends StatelessWidget {
  const _DefaultLandingOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.icon,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = isSelected ? AppColors.primary : colorScheme.onSurface.withValues(alpha: 0.6);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pagePadding,
          vertical: 10,
        ),
        child: Row(
          children: [
            const SizedBox(width: AppSpacing.md),
            Icon(icon, size: 18, color: color),
            const SizedBox(width: AppSpacing.md),
            Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: isSelected ? AppColors.primary : colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check, color: AppColors.primary, size: 18),
          ],
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.label,
    required this.mode,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final AppThemeMode mode;
  final bool isSelected;
  final VoidCallback onTap;

  IconData get _icon => switch (mode) {
        AppThemeMode.light => Icons.wb_sunny_outlined,
        AppThemeMode.dark => Icons.nights_stay_outlined,
        AppThemeMode.system => Icons.phone_android_outlined,
        AppThemeMode.scheduled => Icons.schedule_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = isSelected ? AppColors.primary : colorScheme.onSurface.withValues(alpha: 0.6);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pagePadding,
          vertical: 10,
        ),
        child: Row(
          children: [
            const SizedBox(width: AppSpacing.md),
            Icon(_icon, size: 18, color: color),
            const SizedBox(width: AppSpacing.md),
            Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: isSelected ? AppColors.primary : colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check, color: AppColors.primary, size: 18),
          ],
        ),
      ),
    );
  }
}

class _ScheduleTimeTile extends StatelessWidget {
  const _ScheduleTimeTile({
    required this.label,
    required this.hour,
    required this.minute,
    required this.onTap,
  });

  final String label;
  final int hour;
  final int minute;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final timeStr =
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pagePadding,
          vertical: 10,
        ),
        child: Row(
          children: [
            const SizedBox(width: 40 + AppSpacing.md + 16),
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              timeStr,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.access_time,
              size: 16,
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }
}
