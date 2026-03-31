// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$logRepositoryHash() => r'd44cec7ea750920d18853b019f34169f015b8953';

/// See also [logRepository].
@ProviderFor(logRepository)
final logRepositoryProvider = AutoDisposeProvider<LogRepository>.internal(
  logRepository,
  name: r'logRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$logRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LogRepositoryRef = AutoDisposeProviderRef<LogRepository>;
String _$logTimelineHash() => r'f511bd784f36570591bc63ca17c6086b0bdead33';

/// See also [logTimeline].
@ProviderFor(logTimeline)
final logTimelineProvider =
    AutoDisposeFutureProvider<List<TimelineEntry>>.internal(
      logTimeline,
      name: r'logTimelineProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$logTimelineHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LogTimelineRef = AutoDisposeFutureProviderRef<List<TimelineEntry>>;
String _$filteredLogTimelineHash() =>
    r'cf8c521237aec2163a82a11e76e5d88673509926';

/// See also [filteredLogTimeline].
@ProviderFor(filteredLogTimeline)
final filteredLogTimelineProvider =
    AutoDisposeFutureProvider<List<TimelineEntry>>.internal(
      filteredLogTimeline,
      name: r'filteredLogTimelineProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$filteredLogTimelineHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FilteredLogTimelineRef =
    AutoDisposeFutureProviderRef<List<TimelineEntry>>;
String _$logDaySummaryHash() => r'4054eb8331b85e9ca1d35f4dd6a470d373d1625e';

/// See also [logDaySummary].
@ProviderFor(logDaySummary)
final logDaySummaryProvider = AutoDisposeFutureProvider<LogDaySummary>.internal(
  logDaySummary,
  name: r'logDaySummaryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$logDaySummaryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LogDaySummaryRef = AutoDisposeFutureProviderRef<LogDaySummary>;
String _$selectedLogDateHash() => r'f2cb1bb8ca16d5d0d2ba4754333b2ad2a963e667';

/// See also [SelectedLogDate].
@ProviderFor(SelectedLogDate)
final selectedLogDateProvider =
    AutoDisposeNotifierProvider<SelectedLogDate, DateTime>.internal(
      SelectedLogDate.new,
      name: r'selectedLogDateProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$selectedLogDateHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SelectedLogDate = AutoDisposeNotifier<DateTime>;
String _$selectedTimelineFilterHash() =>
    r'546329f8c86509f980642de8b28fdb79984a0965';

/// See also [SelectedTimelineFilter].
@ProviderFor(SelectedTimelineFilter)
final selectedTimelineFilterProvider =
    AutoDisposeNotifierProvider<
      SelectedTimelineFilter,
      TimelineEntryType
    >.internal(
      SelectedTimelineFilter.new,
      name: r'selectedTimelineFilterProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$selectedTimelineFilterHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SelectedTimelineFilter = AutoDisposeNotifier<TimelineEntryType>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
