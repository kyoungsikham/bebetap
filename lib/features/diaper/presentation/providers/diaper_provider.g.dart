// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diaper_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$diaperRepositoryHash() => r'126e6fb87f6ee073435e9077c1e064e3c4b579ae';

/// See also [diaperRepository].
@ProviderFor(diaperRepository)
final diaperRepositoryProvider = AutoDisposeProvider<DiaperRepository>.internal(
  diaperRepository,
  name: r'diaperRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$diaperRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DiaperRepositoryRef = AutoDisposeProviderRef<DiaperRepository>;
String _$diaperNotifierHash() => r'7e33960b14e3af50898e50d1529daedb451ef272';

/// See also [DiaperNotifier].
@ProviderFor(DiaperNotifier)
final diaperNotifierProvider =
    AutoDisposeNotifierProvider<DiaperNotifier, AsyncValue<void>>.internal(
      DiaperNotifier.new,
      name: r'diaperNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$diaperNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$DiaperNotifier = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
