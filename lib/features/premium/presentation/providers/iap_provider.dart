import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../data/iap_service.dart';

/// 앱 전역 IapService 싱글톤
final iapServiceProvider = Provider<IapService>((ref) {
  final service = IapService();
  ref.onDispose(service.dispose);
  return service;
});

/// Paywall 화면에 표시할 현지화 상품 정보 (가격 포함)
final iapProductProvider = FutureProvider<ProductDetails?>((ref) async {
  final service = ref.watch(iapServiceProvider);
  return service.queryProduct();
});
