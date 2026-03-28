// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'baby_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$babyRepositoryHash() => r'd619cf6afaa9dbe52703ed53b29ae2681b2d221e';

/// See also [babyRepository].
@ProviderFor(babyRepository)
final babyRepositoryProvider = AutoDisposeProvider<BabyRepository>.internal(
  babyRepository,
  name: r'babyRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$babyRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BabyRepositoryRef = AutoDisposeProviderRef<BabyRepository>;
String _$babiesHash() => r'5fae22dceabf9a11f1d764644102355b68635c92';

/// See also [babies].
@ProviderFor(babies)
final babiesProvider = AutoDisposeFutureProvider<List<Baby>>.internal(
  babies,
  name: r'babiesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$babiesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BabiesRef = AutoDisposeFutureProviderRef<List<Baby>>;
String _$selectedBabyHash() => r'599a4b4b6197229836b8d5a456b27561a9b66517';

/// 선택된 아기 (없으면 목록 첫 번째).
///
/// Copied from [selectedBaby].
@ProviderFor(selectedBaby)
final selectedBabyProvider = AutoDisposeFutureProvider<Baby?>.internal(
  selectedBaby,
  name: r'selectedBabyProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedBabyHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SelectedBabyRef = AutoDisposeFutureProviderRef<Baby?>;
String _$selectedBabyIdHash() => r'd0e083d689d7585166701be0f144e6a53c26389f';

/// 현재 선택된 아기 ID. null이면 목록의 첫 번째 아기를 사용.
///
/// Copied from [SelectedBabyId].
@ProviderFor(SelectedBabyId)
final selectedBabyIdProvider =
    AutoDisposeNotifierProvider<SelectedBabyId, String?>.internal(
      SelectedBabyId.new,
      name: r'selectedBabyIdProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$selectedBabyIdHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SelectedBabyId = AutoDisposeNotifier<String?>;
String _$babySetupNotifierHash() => r'd23c70b8fb414c5e6939ac8c1439b5192cf6670e';

/// 온보딩에서 가족 + 아기 생성을 처리하는 Notifier.
///
/// Copied from [BabySetupNotifier].
@ProviderFor(BabySetupNotifier)
final babySetupNotifierProvider =
    AutoDisposeNotifierProvider<BabySetupNotifier, AsyncValue<void>>.internal(
      BabySetupNotifier.new,
      name: r'babySetupNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$babySetupNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$BabySetupNotifier = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
