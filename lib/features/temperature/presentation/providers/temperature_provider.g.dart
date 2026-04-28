// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'temperature_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$temperatureRepositoryHash() =>
    r'ba827c2c8c0f8386620f29ab9038609df0cb3774';

/// See also [temperatureRepository].
@ProviderFor(temperatureRepository)
final temperatureRepositoryProvider =
    AutoDisposeProvider<TemperatureRepository>.internal(
      temperatureRepository,
      name: r'temperatureRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$temperatureRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TemperatureRepositoryRef =
    AutoDisposeProviderRef<TemperatureRepository>;
String _$temperatureNotifierHash() =>
    r'87f98bc2e92c2707e6aa2cb046c6f6ec483d4bd9';

/// See also [TemperatureNotifier].
@ProviderFor(TemperatureNotifier)
final temperatureNotifierProvider =
    AutoDisposeNotifierProvider<TemperatureNotifier, AsyncValue<void>>.internal(
      TemperatureNotifier.new,
      name: r'temperatureNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$temperatureNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TemperatureNotifier = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
