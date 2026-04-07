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
import '../../../../shared/providers/locale_provider.dart';
import '../../../../shared/widgets/baby_avatar_widget.dart';
import '../../../baby/presentation/providers/baby_provider.dart';
import '../../../family/presentation/providers/family_provider.dart';
import '../widgets/baby_selector_sheet.dart';
import '../widgets/status_card.dart';
import '../widgets/stats_strip.dart';
import '../widgets/tracking_grid.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(familyRealtimeProvider); // 실시간 동기화 + 초기 pull 활성화
    final babiesAsync = ref.watch(babiesProvider);

    // 세션 복원 시 babies 로딩 중이면 스피너만 표시 (깜빡임 방지)
    if (babiesAsync.isLoading && !babiesAsync.hasValue) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
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
                    style: AppTypography.titleMedium
                        .copyWith(color: AppColors.onSurface),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const TrackingGrid(),
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
  bool _languageExpanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final currentLocale = ref.watch(localeProvider).valueOrNull;

    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        color: Colors.white,
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
                    leading: const Icon(Icons.widgets_outlined),
                    title: Text(l10n.menuWidgetAdd),
                    onTap: () {
                      final messenger = ScaffoldMessenger.of(context);
                      Navigator.of(context, rootNavigator: true).pop();
                      Future.microtask(() => messenger.showSnackBar(
                          SnackBar(content: Text(l10n.comingSoon))));
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
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout, color: AppColors.error),
                    title: Text(
                      l10n.menuLogout,
                      style: AppTypography.bodyLarge
                          .copyWith(color: AppColors.error),
                    ),
                    onTap: () async {
                      Navigator.of(context, rootNavigator: true).pop();
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
                      if (confirmed == true) {
                        final db = ref.read(appDatabaseProvider);
                        try {
                          await db.clearAllData();
                        } catch (e) {
                          debugPrint('clearAllData error (ignored): $e');
                        }
                        ref.invalidate(babiesProvider);
                        await Supabase.instance.client.auth.signOut();
                      }
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
                color: isSelected ? AppColors.primary : AppColors.onSurface,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w400,
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
    final babyColorIndex =
        baby != null ? babies.indexWhere((b) => b.id == baby.id) : 0;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFEEF0),
            Color(0xFFFFF5F6),
            Color(0xFFFFFFFF),
          ],
          stops: [0.0, 0.6, 1.0],
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
                color: AppColors.onSurface,
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
                    Text(
                      context.l10n.homeGreeting(name),
                      style: AppTypography.headlineMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      context.l10n.homeEncouragement,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.onSurfaceMuted,
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
