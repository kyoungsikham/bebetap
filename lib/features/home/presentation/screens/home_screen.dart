import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/providers/database_provider.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/extensions/l10n_ext.dart';
import '../../../../shared/models/theme_mode_setting.dart';
import '../../../../shared/models/volume_unit.dart';
import '../../../../shared/providers/locale_provider.dart';
import '../../../../shared/providers/theme_provider.dart';
import '../../../../shared/providers/volume_unit_provider.dart';
import '../../../../shared/widgets/baby_avatar_widget.dart';
import '../../../baby/presentation/providers/baby_provider.dart';
import '../../../daily_message/presentation/providers/daily_message_provider.dart';
import '../../../family/presentation/providers/family_provider.dart';
import '../widgets/baby_selector_sheet.dart';
import '../widgets/status_card.dart';
import '../widgets/stats_strip.dart';
import '../widgets/tracking_grid.dart';
import '../../../../core/config/ad_config.dart';
import '../../../../shared/widgets/banner_ad_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(familyRealtimeProvider); // 실시간 동기화 + 초기 pull 활성화
    final babiesAsync = ref.watch(babiesProvider);

    // 세션 복원 시 babies 로딩 중이면 스피너만 표시 (깜빡임 방지)
    if (babiesAsync.isLoading && !babiesAsync.hasValue) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(selectedBabyProvider);
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _HomeHeader(
                onMenuTap: () => _showHamburgerMenu(context, ref),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pagePadding,
                AppSpacing.md,
                AppSpacing.pagePadding,
                AppSpacing.pagePadding,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _TodayLabel(),
                  const SizedBox(height: AppSpacing.md),
                  const StatusCard(),
                  const SizedBox(height: AppSpacing.md),
                  const StatsStrip(),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    context.l10n.sectionRecord,
                    style: AppTypography.titleMedium.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const TrackingGrid(),
                  const SizedBox(height: AppSpacing.lg),
                  BannerAdWidget(adUnitId: AdConfig.homeBannerId),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHamburgerMenu(BuildContext context, WidgetRef ref) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, _, _) => _HamburgerMenuPanel(ref: ref),
      transitionBuilder: (_, anim, _, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
        child: child,
      ),
    );
  }
}

class _HamburgerMenuPanel extends ConsumerStatefulWidget {
  const _HamburgerMenuPanel({required this.ref});

  final WidgetRef ref;

  @override
  ConsumerState<_HamburgerMenuPanel> createState() =>
      _HamburgerMenuPanelState();
}

class _HamburgerMenuPanelState extends ConsumerState<_HamburgerMenuPanel> {
  bool _themeExpanded = false;
  bool _languageExpanded = false;
  bool _unitExpanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final currentLocale = ref.watch(localeProvider).valueOrNull;
    final themeSetting =
        ref.watch(themeSettingProvider).valueOrNull ?? const ThemeModeSetting();
    final currentUnit = ref.watch(volumeUnitProvider).valueOrNull ?? VolumeUnit.ml;

    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.horizontal(
          left: Radius.circular(20),
        ),
        child: SafeArea(
          child: SizedBox(
            width: 280,
            height: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                      _themeExpanded
                          ? Icons.expand_less
                          : Icons.expand_more,
                      color: AppColors.onSurfaceMuted,
                    ),
                    onTap: () =>
                        setState(() => _themeExpanded = !_themeExpanded),
                  ),
                  if (_themeExpanded) ...[
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
                      isSelected: themeSetting.mode == AppThemeMode.system,
                      onTap: () => _changeTheme(AppThemeMode.system),
                    ),
                    _ThemeOption(
                      label: l10n.themeScheduled,
                      mode: AppThemeMode.scheduled,
                      isSelected: themeSetting.mode == AppThemeMode.scheduled,
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
                  // 언어 설정
                  ListTile(
                    leading: const Icon(Icons.language),
                    title: Text(l10n.menuLanguage),
                    trailing: Icon(
                      _languageExpanded
                          ? Icons.expand_less
                          : Icons.expand_more,
                      color: AppColors.onSurfaceMuted,
                    ),
                    onTap: () =>
                        setState(() => _languageExpanded = !_languageExpanded),
                  ),
                  if (_languageExpanded) ...[
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
                  // 단위 설정
                  ListTile(
                    leading: const Icon(Icons.straighten_outlined),
                    title: Text(l10n.menuVolumeUnit),
                    trailing: Icon(
                      _unitExpanded ? Icons.expand_less : Icons.expand_more,
                      color: AppColors.onSurfaceMuted,
                    ),
                    onTap: () => setState(() => _unitExpanded = !_unitExpanded),
                  ),
                  if (_unitExpanded) ...[
                    _UnitOption(
                      label: l10n.volumeUnitMl,
                      isSelected: currentUnit == VolumeUnit.ml,
                      onTap: () => ref.read(volumeUnitProvider.notifier).setUnit(VolumeUnit.ml),
                    ),
                    _UnitOption(
                      label: l10n.volumeUnitOz,
                      isSelected: currentUnit == VolumeUnit.oz,
                      onTap: () => ref.read(volumeUnitProvider.notifier).setUnit(VolumeUnit.oz),
                    ),
                  ],
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout, color: AppColors.error),
                    title: Text(
                      l10n.menuLogout,
                      style: AppTypography.bodyLarge
                          .copyWith(color: AppColors.error),
                    ),
                    onTap: () async {
                      final navigator = Navigator.of(context, rootNavigator: true);
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
                                style:
                                    const TextStyle(color: AppColors.error),
                              ),
                            ),
                          ],
                        ),
                      );
                      if (confirmed != true) return;
                      // ref/db를 먼저 캡처한 후 메뉴를 닫아서 disposed 상태 방지
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pagePadding,
          vertical: 10,
        ),
        child: Row(
          children: [
            const SizedBox(width: 40 + AppSpacing.md), // icon + leading gap
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
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pagePadding,
          vertical: 10,
        ),
        child: Row(
          children: [
            const SizedBox(width: 40 + AppSpacing.md),
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pagePadding,
          vertical: 10,
        ),
        child: Row(
          children: [
            const SizedBox(width: 40 + AppSpacing.md),
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

class _HomeHeader extends ConsumerWidget {
  const _HomeHeader({this.onMenuTap});

  final VoidCallback? onMenuTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topPadding = MediaQuery.of(context).padding.top;
    final baby = ref.watch(selectedBabyProvider).valueOrNull;
    final babies = ref.watch(babiesProvider).valueOrNull ?? [];
    final name = baby?.name ?? context.l10n.userLabel;
    final canSwitch = babies.length > 1;
    final ageLabel = baby != null ? _babyAgeLabel(context, baby.birthDate) : null;
    final babyColorIndex =
        baby != null ? babies.indexWhere((b) => b.id == baby.id) : 0;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [
                  Color(0xFF1A1020),
                  Color(0xFF161520),
                  Color(0xFF121218),
                ]
              : const [
                  Color(0xFFFFEEF0),
                  Color(0xFFFFF5F6),
                  Color(0xFFFFFFFF),
                ],
          stops: const [0.0, 0.6, 1.0],
        ),
      ),
      padding: EdgeInsets.only(
        top: topPadding + AppSpacing.sm,
        bottom: AppSpacing.lg,
        left: AppSpacing.pagePadding,
        right: AppSpacing.pagePadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단 바: BebeTap 로고 + 햄버거 메뉴
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'BebeTap',
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.menu),
                onPressed: onMenuTap,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          // 인사 영역: 텍스트(좌) + 아바타(우)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          name,
                          style: AppTypography.headlineMedium,
                        ),
                        if (ageLabel != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            ageLabel,
                            style: AppTypography.bodyMedium.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      ref.watch(dailyMessageProvider),
                      style: AppTypography.bodyMedium.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  BabyAvatarWidget(
                    photoUrl: baby?.photoUrl,
                    gender: baby?.gender,
                    colorIndex: babyColorIndex >= 0 ? babyColorIndex : null,
                    onTap: canSwitch
                        ? () => showBabySelectorSheet(context, ref)
                        : null,
                  ),
                  if (canSwitch)
                    Positioned(
                      bottom: -2,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.expand_more,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _babyAgeLabel(BuildContext context, DateTime birthDate) {
    final today = DateTime.now();
    final days = today.difference(DateTime(birthDate.year, birthDate.month, birthDate.day)).inDays;
    if (days < 100) {
      return context.l10n.babyAgeDays(days);
    }
    final months = (today.year - birthDate.year) * 12 + (today.month - birthDate.month) -
        (today.day < birthDate.day ? 1 : 0);
    final remainDays = today.day < birthDate.day
        ? today.day + (DateTime(today.year, today.month, 0).day - birthDate.day)
        : today.day - birthDate.day;
    if (remainDays == 0) return context.l10n.babyAgeMonths(months);
    return context.l10n.babyAgeMonthsDays(months, remainDays);
  }
}


class _TodayLabel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final now = DateTime.now();
    final weekdays = [
      l10n.weekdayMon,
      l10n.weekdayTue,
      l10n.weekdayWed,
      l10n.weekdayThu,
      l10n.weekdayFri,
      l10n.weekdaySat,
      l10n.weekdaySun,
    ];
    final weekday = weekdays[now.weekday - 1];
    return Text(
      l10n.dateFormatFull(now.month, now.day, weekday),
      style:
          AppTypography.bodySmall.copyWith(color: AppColors.onSurfaceMuted),
    );
  }
}
