// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$homeRepositoryHash() => r'573364bd72d8a18268bebc77e92bb954b7d426f1';

/// See also [homeRepository].
@ProviderFor(homeRepository)
final homeRepositoryProvider = AutoDisposeProvider<HomeRepository>.internal(
  homeRepository,
  name: r'homeRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$homeRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HomeRepositoryRef = AutoDisposeProviderRef<HomeRepository>;
String _$homeSummaryHash() => r'ad525846aa3790dfb53d0a41af8699c473e79ecb';

/// See also [homeSummary].
@ProviderFor(homeSummary)
final homeSummaryProvider = AutoDisposeFutureProvider<HomeSummary>.internal(
  homeSummary,
  name: r'homeSummaryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$homeSummaryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HomeSummaryRef = AutoDisposeFutureProviderRef<HomeSummary>;
String _$minuteTickerHash() => r'deef5ad210d0bdd3681e4eb6a731018d34d1eae1';

/// 1분마다 틱 — elapsed time 표시를 위해 UI 위젯이 구독
///
/// Copied from [minuteTicker].
@ProviderFor(minuteTicker)
final minuteTickerProvider = AutoDisposeStreamProvider<int>.internal(
  minuteTicker,
  name: r'minuteTickerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$minuteTickerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MinuteTickerRef = AutoDisposeStreamProviderRef<int>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
