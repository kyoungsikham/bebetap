// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sleep_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sleepRepositoryHash() => r'f0157158d557950ce9921a011a30fecdf70f7584';

/// See also [sleepRepository].
@ProviderFor(sleepRepository)
final sleepRepositoryProvider = AutoDisposeProvider<SleepRepository>.internal(
  sleepRepository,
  name: r'sleepRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sleepRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SleepRepositoryRef = AutoDisposeProviderRef<SleepRepository>;
String _$activeSleepHash() => r'f698a4a11b79c706f6d49fdbeda80f562314b2f1';

/// See also [activeSleep].
@ProviderFor(activeSleep)
final activeSleepProvider = AutoDisposeStreamProvider<SleepEntry?>.internal(
  activeSleep,
  name: r'activeSleepProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeSleepHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveSleepRef = AutoDisposeStreamProviderRef<SleepEntry?>;
String _$sleepSessionNotifierHash() =>
    r'744a537b46c49e102647ed96aa0bde018b8c7433';

/// See also [SleepSessionNotifier].
@ProviderFor(SleepSessionNotifier)
final sleepSessionNotifierProvider =
    AutoDisposeNotifierProvider<
      SleepSessionNotifier,
      AsyncValue<void>
    >.internal(
      SleepSessionNotifier.new,
      name: r'sleepSessionNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$sleepSessionNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SleepSessionNotifier = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
