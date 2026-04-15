import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../providers/ad_free_provider.dart';

class BannerAdWidget extends ConsumerStatefulWidget {
  const BannerAdWidget({super.key, required this.adUnitId});

  final String adUnitId;

  @override
  ConsumerState<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends ConsumerState<BannerAdWidget> {
  BannerAd? _ad;
  bool _loaded = false;
  AdSize? _reservedSize;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAd();
  }

  Future<void> _loadAd() async {
    final width = MediaQuery.sizeOf(context).width.truncate();
    final adSize =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width);
    if (adSize == null || !mounted) return;

    // 광고가 도착하기 전에 회색 'AD' 플레이스홀더로 영역을 먼저 확보한다.
    setState(() => _reservedSize = adSize);

    final ad = BannerAd(
      adUnitId: widget.adUnitId,
      size: adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, _) {
          ad.dispose();
          // 실패 시에도 플레이스홀더는 유지해 레이아웃이 흔들리지 않게 한다.
        },
      ),
    );

    await ad.load();
    if (mounted) {
      setState(() => _ad = ad);
    } else {
      ad.dispose();
    }
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adFree = ref.watch(adFreeProvider).valueOrNull ?? false;
    if (adFree) return const SizedBox.shrink();

    final size = _reservedSize;
    if (size == null) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;
    final loaded = _ad != null && _loaded;

    return SizedBox(
      width: size.width.toDouble(),
      height: size.height.toDouble(),
      child: ColoredBox(
        color: cs.surfaceContainerHighest,
        child: loaded
            ? AdWidget(ad: _ad!)
            : Center(
                child: Text(
                  'AD',
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 11,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
      ),
    );
  }
}
