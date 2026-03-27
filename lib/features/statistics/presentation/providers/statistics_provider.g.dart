// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statistics_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$statisticsRepositoryHash() =>
    r'fd9d6dc9c03506a88b76a9b8a67ca8588b0c0cf8';

/// See also [statisticsRepository].
@ProviderFor(statisticsRepository)
final statisticsRepositoryProvider =
    AutoDisposeProvider<StatisticsRepository>.internal(
      statisticsRepository,
      name: r'statisticsRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$statisticsRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StatisticsRepositoryRef = AutoDisposeProviderRef<StatisticsRepository>;
String _$sleepStatsHash() => r'824ee8bec17624f84456be388c4b38a95c96cfdc';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [sleepStats].
@ProviderFor(sleepStats)
const sleepStatsProvider = SleepStatsFamily();

/// See also [sleepStats].
class SleepStatsFamily extends Family<AsyncValue<SleepStats>> {
  /// See also [sleepStats].
  const SleepStatsFamily();

  /// See also [sleepStats].
  SleepStatsProvider call(Period period) {
    return SleepStatsProvider(period);
  }

  @override
  SleepStatsProvider getProviderOverride(
    covariant SleepStatsProvider provider,
  ) {
    return call(provider.period);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'sleepStatsProvider';
}

/// See also [sleepStats].
class SleepStatsProvider extends AutoDisposeFutureProvider<SleepStats> {
  /// See also [sleepStats].
  SleepStatsProvider(Period period)
    : this._internal(
        (ref) => sleepStats(ref as SleepStatsRef, period),
        from: sleepStatsProvider,
        name: r'sleepStatsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$sleepStatsHash,
        dependencies: SleepStatsFamily._dependencies,
        allTransitiveDependencies: SleepStatsFamily._allTransitiveDependencies,
        period: period,
      );

  SleepStatsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.period,
  }) : super.internal();

  final Period period;

  @override
  Override overrideWith(
    FutureOr<SleepStats> Function(SleepStatsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SleepStatsProvider._internal(
        (ref) => create(ref as SleepStatsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        period: period,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<SleepStats> createElement() {
    return _SleepStatsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SleepStatsProvider && other.period == period;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, period.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SleepStatsRef on AutoDisposeFutureProviderRef<SleepStats> {
  /// The parameter `period` of this provider.
  Period get period;
}

class _SleepStatsProviderElement
    extends AutoDisposeFutureProviderElement<SleepStats>
    with SleepStatsRef {
  _SleepStatsProviderElement(super.provider);

  @override
  Period get period => (origin as SleepStatsProvider).period;
}

String _$feedingStatsHash() => r'54342b106a39b695867da9553cf5d29754d50061';

/// See also [feedingStats].
@ProviderFor(feedingStats)
const feedingStatsProvider = FeedingStatsFamily();

/// See also [feedingStats].
class FeedingStatsFamily extends Family<AsyncValue<FeedingStats>> {
  /// See also [feedingStats].
  const FeedingStatsFamily();

  /// See also [feedingStats].
  FeedingStatsProvider call(Period period) {
    return FeedingStatsProvider(period);
  }

  @override
  FeedingStatsProvider getProviderOverride(
    covariant FeedingStatsProvider provider,
  ) {
    return call(provider.period);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'feedingStatsProvider';
}

/// See also [feedingStats].
class FeedingStatsProvider extends AutoDisposeFutureProvider<FeedingStats> {
  /// See also [feedingStats].
  FeedingStatsProvider(Period period)
    : this._internal(
        (ref) => feedingStats(ref as FeedingStatsRef, period),
        from: feedingStatsProvider,
        name: r'feedingStatsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$feedingStatsHash,
        dependencies: FeedingStatsFamily._dependencies,
        allTransitiveDependencies:
            FeedingStatsFamily._allTransitiveDependencies,
        period: period,
      );

  FeedingStatsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.period,
  }) : super.internal();

  final Period period;

  @override
  Override overrideWith(
    FutureOr<FeedingStats> Function(FeedingStatsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FeedingStatsProvider._internal(
        (ref) => create(ref as FeedingStatsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        period: period,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<FeedingStats> createElement() {
    return _FeedingStatsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FeedingStatsProvider && other.period == period;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, period.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FeedingStatsRef on AutoDisposeFutureProviderRef<FeedingStats> {
  /// The parameter `period` of this provider.
  Period get period;
}

class _FeedingStatsProviderElement
    extends AutoDisposeFutureProviderElement<FeedingStats>
    with FeedingStatsRef {
  _FeedingStatsProviderElement(super.provider);

  @override
  Period get period => (origin as FeedingStatsProvider).period;
}

String _$diaperStatsHash() => r'cd54b13008cbbfe9a226a7efb8cfced81679a22b';

/// See also [diaperStats].
@ProviderFor(diaperStats)
const diaperStatsProvider = DiaperStatsFamily();

/// See also [diaperStats].
class DiaperStatsFamily extends Family<AsyncValue<int>> {
  /// See also [diaperStats].
  const DiaperStatsFamily();

  /// See also [diaperStats].
  DiaperStatsProvider call(Period period) {
    return DiaperStatsProvider(period);
  }

  @override
  DiaperStatsProvider getProviderOverride(
    covariant DiaperStatsProvider provider,
  ) {
    return call(provider.period);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'diaperStatsProvider';
}

/// See also [diaperStats].
class DiaperStatsProvider extends AutoDisposeFutureProvider<int> {
  /// See also [diaperStats].
  DiaperStatsProvider(Period period)
    : this._internal(
        (ref) => diaperStats(ref as DiaperStatsRef, period),
        from: diaperStatsProvider,
        name: r'diaperStatsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$diaperStatsHash,
        dependencies: DiaperStatsFamily._dependencies,
        allTransitiveDependencies: DiaperStatsFamily._allTransitiveDependencies,
        period: period,
      );

  DiaperStatsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.period,
  }) : super.internal();

  final Period period;

  @override
  Override overrideWith(
    FutureOr<int> Function(DiaperStatsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DiaperStatsProvider._internal(
        (ref) => create(ref as DiaperStatsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        period: period,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<int> createElement() {
    return _DiaperStatsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DiaperStatsProvider && other.period == period;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, period.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DiaperStatsRef on AutoDisposeFutureProviderRef<int> {
  /// The parameter `period` of this provider.
  Period get period;
}

class _DiaperStatsProviderElement extends AutoDisposeFutureProviderElement<int>
    with DiaperStatsRef {
  _DiaperStatsProviderElement(super.provider);

  @override
  Period get period => (origin as DiaperStatsProvider).period;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
