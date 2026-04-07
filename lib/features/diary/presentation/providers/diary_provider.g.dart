// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diary_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$diaryRepositoryHash() => r'5c4b43489d2ad3ded0080989aebf280765c612a1';

/// See also [diaryRepository].
@ProviderFor(diaryRepository)
final diaryRepositoryProvider = AutoDisposeProvider<DiaryRepository>.internal(
  diaryRepository,
  name: r'diaryRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$diaryRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DiaryRepositoryRef = AutoDisposeProviderRef<DiaryRepository>;
String _$todayDiaryForCurrentUserHash() =>
    r'eed4c287b78d8f06fe491595edb21cf4d0dc16ee';

/// 오늘 날짜에 현재 로그인 사용자가 쓴 일기 (있으면 반환, 없으면 null)
///
/// Copied from [todayDiaryForCurrentUser].
@ProviderFor(todayDiaryForCurrentUser)
final todayDiaryForCurrentUserProvider =
    AutoDisposeFutureProvider<DiaryEntry?>.internal(
      todayDiaryForCurrentUser,
      name: r'todayDiaryForCurrentUserProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$todayDiaryForCurrentUserHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TodayDiaryForCurrentUserRef = AutoDisposeFutureProviderRef<DiaryEntry?>;
String _$diaryNotifierHash() => r'58e9b359acb1fdae2d93e819e1b21e5b0c4db158';

/// See also [DiaryNotifier].
@ProviderFor(DiaryNotifier)
final diaryNotifierProvider =
    AutoDisposeNotifierProvider<DiaryNotifier, AsyncValue<void>>.internal(
      DiaryNotifier.new,
      name: r'diaryNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$diaryNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$DiaryNotifier = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
