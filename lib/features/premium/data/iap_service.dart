import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 광고 제거 일회성 상품 ID (App Store Connect / Play Console에 동일 ID로 등록)
const kRemoveAdsProductId = 'com.bebetap.remove_ads';

/// IAP 처리 서비스.
/// [init]을 앱 시작 시 한 번 호출하고, [dispose]를 앱 종료 시 호출한다.
class IapService {
  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;

  /// 구매·복원 결과를 외부에 알리는 콜백 (PaywallScreen이 등록)
  void Function(bool success, String? errorMessage)? onPurchaseResult;

  Future<void> init() async {
    try {
      final available = await InAppPurchase.instance.isAvailable();
      if (!available) return;

      _purchaseSub = InAppPurchase.instance.purchaseStream
          .listen(_onPurchaseUpdate, onError: (e) {
        debugPrint('IAP stream error: $e');
      });
    } catch (e) {
      // 핫 리로드 직후 또는 네이티브 플러그인 미등록 상태에서 발생 가능.
      // 앱 시작을 막지 않도록 에러를 흡수한다.
      debugPrint('IAP init skipped: $e');
    }
  }

  void dispose() {
    _purchaseSub?.cancel();
  }

  // ── 현지화된 상품 정보 조회 ──────────────────────────────────
  Future<ProductDetails?> queryProduct() async {
    try {
      final response = await InAppPurchase.instance
          .queryProductDetails({kRemoveAdsProductId});
      if (response.error != null || response.productDetails.isEmpty) {
        return null;
      }
      return response.productDetails.first;
    } catch (e) {
      debugPrint('IAP queryProduct error: $e');
      return null;
    }
  }

  // ── 구매 시작 ────────────────────────────────────────────────
  Future<void> buy() async {
    try {
      final product = await queryProduct();
      if (product == null) {
        onPurchaseResult?.call(false, 'product_unavailable');
        return;
      }
      await InAppPurchase.instance.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: product),
      );
    } catch (e) {
      debugPrint('IAP buy error: $e');
      onPurchaseResult?.call(false, 'buy_failed');
    }
  }

  // ── 구매 복원 (재설치·기기변경 시) ──────────────────────────
  Future<void> restore() async {
    try {
      await InAppPurchase.instance.restorePurchases();
    } catch (e) {
      debugPrint('IAP restore error: $e');
      onPurchaseResult?.call(false, 'restore_failed');
    }
  }

  // ── 구매 스트림 처리 ─────────────────────────────────────────
  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _verifyAndActivate(purchase);
        case PurchaseStatus.error:
          onPurchaseResult?.call(false, purchase.error?.message);
        case PurchaseStatus.canceled:
          onPurchaseResult?.call(false, 'canceled');
        case PurchaseStatus.pending:
          break;
      }

      if (purchase.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(purchase);
      }
    }
  }

  // ── 서버 영수증 검증 → profiles.is_premium 업데이트 ──────────
  Future<void> _verifyAndActivate(PurchaseDetails purchase) async {
    final platform = Platform.isIOS ? 'ios' : 'android';

    final body = <String, dynamic>{
      'platform': platform,
      'productId': purchase.productID,
    };

    if (Platform.isIOS) {
      // iOS: verificationData.serverVerificationData = transactionId
      body['transactionId'] = purchase.verificationData.serverVerificationData;
    } else {
      // Android: verificationData.serverVerificationData = purchaseToken
      body['purchaseToken'] = purchase.verificationData.serverVerificationData;
    }

    try {
      await Supabase.instance.client.functions.invoke(
        'verify-iap-receipt',
        body: body,
      );
      // adFreeProvider는 realtime으로 자동 갱신되므로 별도 호출 불필요
      onPurchaseResult?.call(true, null);
    } catch (e) {
      debugPrint('IAP verify error: $e');
      onPurchaseResult?.call(false, 'verify_failed');
    }
  }
}
