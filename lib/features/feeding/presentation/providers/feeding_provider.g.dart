// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feeding_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$feedingRepositoryHash() => r'89dacd53cca0f793ab23d7195e53cda8b1c05bbf';

/// See also [feedingRepository].
@ProviderFor(feedingRepository)
final feedingRepositoryProvider =
    AutoDisposeProvider<FeedingRepository>.internal(
      feedingRepository,
      name: r'feedingRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$feedingRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FeedingRepositoryRef = AutoDisposeProviderRef<FeedingRepository>;
String _$todayFeedingsHash() => r'304778b1de83dcd0c85286b229e539bc9fd29b17';

/// See also [todayFeedings].
@ProviderFor(todayFeedings)
final todayFeedingsProvider =
    AutoDisposeStreamProvider<List<FeedingEntry>>.internal(
      todayFeedings,
      name: r'todayFeedingsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$todayFeedingsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TodayFeedingsRef = AutoDisposeStreamProviderRef<List<FeedingEntry>>;
String _$dailyFormulaTotalHash() => r'0d0e6fcf6ac0c72e6a584752a3444d89f6496130';

/// See also [dailyFormulaTotal].
@ProviderFor(dailyFormulaTotal)
final dailyFormulaTotalProvider = AutoDisposeFutureProvider<int>.internal(
  dailyFormulaTotal,
  name: r'dailyFormulaTotalProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$dailyFormulaTotalHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DailyFormulaTotalRef = AutoDisposeFutureProviderRef<int>;
String _$dailyBabyFoodTotalHash() =>
    r'bae942e471900930fde0ba15cc5f6166e0cea4d2';

/// See also [dailyBabyFoodTotal].
@ProviderFor(dailyBabyFoodTotal)
final dailyBabyFoodTotalProvider = AutoDisposeFutureProvider<int>.internal(
  dailyBabyFoodTotal,
  name: r'dailyBabyFoodTotalProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$dailyBabyFoodTotalHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DailyBabyFoodTotalRef = AutoDisposeFutureProviderRef<int>;
String _$feedingNotifierHash() => r'167aa8b8e6eee1fe95f2801327e5d076a5ab94f7';

/// See also [FeedingNotifier].
@ProviderFor(FeedingNotifier)
final feedingNotifierProvider =
    AutoDisposeNotifierProvider<FeedingNotifier, AsyncValue<void>>.internal(
      FeedingNotifier.new,
      name: r'feedingNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$feedingNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$FeedingNotifier = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
