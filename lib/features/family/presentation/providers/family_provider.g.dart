// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'family_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$familyRepositoryHash() => r'bad219946f241cfb599315063e1c38c07e3942e8';

/// See also [familyRepository].
@ProviderFor(familyRepository)
final familyRepositoryProvider = Provider<FamilyRepository>.internal(
  familyRepository,
  name: r'familyRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$familyRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FamilyRepositoryRef = ProviderRef<FamilyRepository>;
String _$myFamilyHash() => r'cea4f0b9417724370da9e249ef9295c0759d9992';

/// See also [myFamily].
@ProviderFor(myFamily)
final myFamilyProvider = AutoDisposeFutureProvider<Family?>.internal(
  myFamily,
  name: r'myFamilyProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$myFamilyHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MyFamilyRef = AutoDisposeFutureProviderRef<Family?>;
String _$familyMembersHash() => r'87710254af22135dc96dc720fb36295ba5c7ac09';

/// See also [familyMembers].
@ProviderFor(familyMembers)
final familyMembersProvider =
    AutoDisposeFutureProvider<List<FamilyMember>>.internal(
      familyMembers,
      name: r'familyMembersProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$familyMembersHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FamilyMembersRef = AutoDisposeFutureProviderRef<List<FamilyMember>>;
String _$familyRealtimeHash() => r'a7f8e7bffd288f5b30314b4752ef2340321bc7aa';

/// 가족 실시간 동기화 활성화 — keepAlive: true로 한번 활성화되면 계속 유지
///
/// Copied from [familyRealtime].
@ProviderFor(familyRealtime)
final familyRealtimeProvider = Provider<void>.internal(
  familyRealtime,
  name: r'familyRealtimeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$familyRealtimeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FamilyRealtimeRef = ProviderRef<void>;
String _$familyNotifierHash() => r'272d559d77eacee885958b0ccf76560fe38476fb';

/// See also [FamilyNotifier].
@ProviderFor(FamilyNotifier)
final familyNotifierProvider =
    AutoDisposeNotifierProvider<FamilyNotifier, AsyncValue<void>>.internal(
      FamilyNotifier.new,
      name: r'familyNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$familyNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$FamilyNotifier = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
