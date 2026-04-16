import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/extensions/l10n_ext.dart';
import '../../../../shared/providers/ad_free_provider.dart';
import '../../data/iap_service.dart';
import '../providers/iap_provider.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  bool _loading = false;
  IapService? _iapService;

  @override
  void initState() {
    super.initState();
    // 구매 결과 콜백 등록. dispose()에서 ref를 쓸 수 없으므로
    // 여기서 싱글톤 참조를 캐싱해두고 dispose에서 그대로 사용한다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _iapService = ref.read(iapServiceProvider);
      _iapService!.onPurchaseResult = _onPurchaseResult;
    });
  }

  @override
  void dispose() {
    _iapService?.onPurchaseResult = null;
    super.dispose();
  }

  void _onPurchaseResult(bool success, String? errorMessage) {
    if (!mounted) return;
    setState(() => _loading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.paywallPurchaseSuccess),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop();
    } else if (errorMessage != 'canceled') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.paywallPurchaseFailed),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _onBuyTap() async {
    setState(() => _loading = true);
    await ref.read(iapServiceProvider).buy();
    // 결과는 _onPurchaseResult 콜백에서 처리
  }

  Future<void> _onRestoreTap() async {
    setState(() => _loading = true);
    await ref.read(iapServiceProvider).restore();
    // 복원 결과도 purchaseStream → _onPurchaseResult로 수신
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final isPremium = ref.watch(adFreeProvider).valueOrNull ?? false;
    final productAsync = ref.watch(iapProductProvider);

    // 현지화된 가격 문자열 (로딩 중엔 '...' 표시)
    final priceLabel = productAsync.whenOrNull(
          data: (p) => p?.price,
        ) ??
        '...';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.paywallTitle),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              // 아이콘
              Center(
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.block_outlined,
                    size: 44,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // 제목
              Text(
                l10n.paywallTitle,
                style: AppTypography.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),

              // 혜택 설명
              Center(
                child: Text(
                  l10n.paywallBenefit,
                  style: AppTypography.bodyLarge.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // 혜택 체크리스트 (1개)
              _BenefitRow(
                icon: Icons.ads_click_outlined,
                label: l10n.paywallBenefit,
              ),

              const Spacer(),

              // 이미 구매한 경우
              if (isPremium) ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle,
                          color: AppColors.success, size: 20),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        l10n.paywallAlreadyPurchased,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // 가격 카드
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.removeAdsSubtitle,
                        style: AppTypography.bodyMedium.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      Text(
                        priceLabel,
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // 구매 버튼
                FilledButton(
                  onPressed: _loading ? null : _onBuyTap,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          l10n.paywallPurchaseCta,
                          style: AppTypography.bodyLarge
                              .copyWith(color: Colors.white),
                        ),
                ),
              ],

              const SizedBox(height: AppSpacing.sm),

              // 구매 복원 버튼
              Center(
                child: TextButton(
                  onPressed: _loading ? null : _onRestoreTap,
                  child: Text(
                    l10n.paywallRestoreCta,
                    style: AppTypography.bodySmall.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: cs.onSurface.withValues(alpha: 0.85),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
