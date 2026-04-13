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
String _$sleepStatsHash() => r'5d80934e350d849898634669eae150ae8742e5ae';

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
  SleepStatsProvider call(DateRangeSelection range) {
    return SleepStatsProvider(range);
  }

  @override
  SleepStatsProvider getProviderOverride(
    covariant SleepStatsProvider provider,
  ) {
    return call(provider.range);
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
  SleepStatsProvider(DateRangeSelection range)
    : this._internal(
        (ref) => sleepStats(ref as SleepStatsRef, range),
        from: sleepStatsProvider,
        name: r'sleepStatsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$sleepStatsHash,
        dependencies: SleepStatsFamily._dependencies,
        allTransitiveDependencies: SleepStatsFamily._allTransitiveDependencies,
        range: range,
      );

  SleepStatsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.range,
  }) : super.internal();

  final DateRangeSelection range;

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
        range: range,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<SleepStats> createElement() {
    return _SleepStatsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SleepStatsProvider && other.range == range;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, range.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SleepStatsRef on AutoDisposeFutureProviderRef<SleepStats> {
  /// The parameter `range` of this provider.
  DateRangeSelection get range;
}

class _SleepStatsProviderElement
    extends AutoDisposeFutureProviderElement<SleepStats>
    with SleepStatsRef {
  _SleepStatsProviderElement(super.provider);

  @override
  DateRangeSelection get range => (origin as SleepStatsProvider).range;
}

String _$feedingStatsHash() => r'd733b8801ea87d3f3ebb24e64ce51994afec3a08';

/// See also [feedingStats].
@ProviderFor(feedingStats)
const feedingStatsProvider = FeedingStatsFamily();

/// See also [feedingStats].
class FeedingStatsFamily extends Family<AsyncValue<FeedingStats>> {
  /// See also [feedingStats].
  const FeedingStatsFamily();

  /// See also [feedingStats].
  FeedingStatsProvider call(DateRangeSelection range) {
    return FeedingStatsProvider(range);
  }

  @override
  FeedingStatsProvider getProviderOverride(
    covariant FeedingStatsProvider provider,
  ) {
    return call(provider.range);
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
  FeedingStatsProvider(DateRangeSelection range)
    : this._internal(
        (ref) => feedingStats(ref as FeedingStatsRef, range),
        from: feedingStatsProvider,
        name: r'feedingStatsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$feedingStatsHash,
        dependencies: FeedingStatsFamily._dependencies,
        allTransitiveDependencies:
            FeedingStatsFamily._allTransitiveDependencies,
        range: range,
      );

  FeedingStatsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.range,
  }) : super.internal();

  final DateRangeSelection range;

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
        range: range,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<FeedingStats> createElement() {
    return _FeedingStatsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FeedingStatsProvider && other.range == range;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, range.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FeedingStatsRef on AutoDisposeFutureProviderRef<FeedingStats> {
  /// The parameter `range` of this provider.
  DateRangeSelection get range;
}

class _FeedingStatsProviderElement
    extends AutoDisposeFutureProviderElement<FeedingStats>
    with FeedingStatsRef {
  _FeedingStatsProviderElement(super.provider);

  @override
  DateRangeSelection get range => (origin as FeedingStatsProvider).range;
}

String _$diaperStatsHash() => r'311a22164f2cb6b47a2464effbb973c761fb9c6e';

/// See also [diaperStats].
@ProviderFor(diaperStats)
const diaperStatsProvider = DiaperStatsFamily();

/// See also [diaperStats].
class DiaperStatsFamily extends Family<AsyncValue<DiaperStats>> {
  /// See also [diaperStats].
  const DiaperStatsFamily();

  /// See also [diaperStats].
  DiaperStatsProvider call(DateRangeSelection range) {
    return DiaperStatsProvider(range);
  }

  @override
  DiaperStatsProvider getProviderOverride(
    covariant DiaperStatsProvider provider,
  ) {
    return call(provider.range);
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
class DiaperStatsProvider extends AutoDisposeFutureProvider<DiaperStats> {
  /// See also [diaperStats].
  DiaperStatsProvider(DateRangeSelection range)
    : this._internal(
        (ref) => diaperStats(ref as DiaperStatsRef, range),
        from: diaperStatsProvider,
        name: r'diaperStatsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$diaperStatsHash,
        dependencies: DiaperStatsFamily._dependencies,
        allTransitiveDependencies: DiaperStatsFamily._allTransitiveDependencies,
        range: range,
      );

  DiaperStatsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.range,
  }) : super.internal();

  final DateRangeSelection range;

  @override
  Override overrideWith(
    FutureOr<DiaperStats> Function(DiaperStatsRef provider) create,
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
        range: range,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<DiaperStats> createElement() {
    return _DiaperStatsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DiaperStatsProvider && other.range == range;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, range.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DiaperStatsRef on AutoDisposeFutureProviderRef<DiaperStats> {
  /// The parameter `range` of this provider.
  DateRangeSelection get range;
}

class _DiaperStatsProviderElement
    extends AutoDisposeFutureProviderElement<DiaperStats>
    with DiaperStatsRef {
  _DiaperStatsProviderElement(super.provider);

  @override
  DateRangeSelection get range => (origin as DiaperStatsProvider).range;
}

String _$temperatureStatsHash() => r'5f5051ae4905618dc2040705001fa0acd786893b';

/// See also [temperatureStats].
@ProviderFor(temperatureStats)
const temperatureStatsProvider = TemperatureStatsFamily();

/// See also [temperatureStats].
class TemperatureStatsFamily extends Family<AsyncValue<TemperatureStats>> {
  /// See also [temperatureStats].
  const TemperatureStatsFamily();

  /// See also [temperatureStats].
  TemperatureStatsProvider call(DateRangeSelection range) {
    return TemperatureStatsProvider(range);
  }

  @override
  TemperatureStatsProvider getProviderOverride(
    covariant TemperatureStatsProvider provider,
  ) {
    return call(provider.range);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'temperatureStatsProvider';
}

/// See also [temperatureStats].
class TemperatureStatsProvider
    extends AutoDisposeFutureProvider<TemperatureStats> {
  /// See also [temperatureStats].
  TemperatureStatsProvider(DateRangeSelection range)
    : this._internal(
        (ref) => temperatureStats(ref as TemperatureStatsRef, range),
        from: temperatureStatsProvider,
        name: r'temperatureStatsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$temperatureStatsHash,
        dependencies: TemperatureStatsFamily._dependencies,
        allTransitiveDependencies:
            TemperatureStatsFamily._allTransitiveDependencies,
        range: range,
      );

  TemperatureStatsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.range,
  }) : super.internal();

  final DateRangeSelection range;

  @override
  Override overrideWith(
    FutureOr<TemperatureStats> Function(TemperatureStatsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TemperatureStatsProvider._internal(
        (ref) => create(ref as TemperatureStatsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        range: range,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<TemperatureStats> createElement() {
    return _TemperatureStatsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TemperatureStatsProvider && other.range == range;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, range.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TemperatureStatsRef on AutoDisposeFutureProviderRef<TemperatureStats> {
  /// The parameter `range` of this provider.
  DateRangeSelection get range;
}

class _TemperatureStatsProviderElement
    extends AutoDisposeFutureProviderElement<TemperatureStats>
    with TemperatureStatsRef {
  _TemperatureStatsProviderElement(super.provider);

  @override
  DateRangeSelection get range => (origin as TemperatureStatsProvider).range;
}

String _$activityHeatmapHash() => r'921d51495bdab06ce0b14bdb8c86f8c648338011';

/// See also [activityHeatmap].
@ProviderFor(activityHeatmap)
const activityHeatmapProvider = ActivityHeatmapFamily();

/// See also [activityHeatmap].
class ActivityHeatmapFamily extends Family<AsyncValue<HeatmapData>> {
  /// See also [activityHeatmap].
  const ActivityHeatmapFamily();

  /// See also [activityHeatmap].
  ActivityHeatmapProvider call(DateRangeSelection range) {
    return ActivityHeatmapProvider(range);
  }

  @override
  ActivityHeatmapProvider getProviderOverride(
    covariant ActivityHeatmapProvider provider,
  ) {
    return call(provider.range);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'activityHeatmapProvider';
}

/// See also [activityHeatmap].
class ActivityHeatmapProvider extends AutoDisposeFutureProvider<HeatmapData> {
  /// See also [activityHeatmap].
  ActivityHeatmapProvider(DateRangeSelection range)
    : this._internal(
        (ref) => activityHeatmap(ref as ActivityHeatmapRef, range),
        from: activityHeatmapProvider,
        name: r'activityHeatmapProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$activityHeatmapHash,
        dependencies: ActivityHeatmapFamily._dependencies,
        allTransitiveDependencies:
            ActivityHeatmapFamily._allTransitiveDependencies,
        range: range,
      );

  ActivityHeatmapProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.range,
  }) : super.internal();

  final DateRangeSelection range;

  @override
  Override overrideWith(
    FutureOr<HeatmapData> Function(ActivityHeatmapRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ActivityHeatmapProvider._internal(
        (ref) => create(ref as ActivityHeatmapRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        range: range,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<HeatmapData> createElement() {
    return _ActivityHeatmapProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ActivityHeatmapProvider && other.range == range;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, range.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ActivityHeatmapRef on AutoDisposeFutureProviderRef<HeatmapData> {
  /// The parameter `range` of this provider.
  DateRangeSelection get range;
}

class _ActivityHeatmapProviderElement
    extends AutoDisposeFutureProviderElement<HeatmapData>
    with ActivityHeatmapRef {
  _ActivityHeatmapProviderElement(super.provider);

  @override
  DateRangeSelection get range => (origin as ActivityHeatmapProvider).range;
}

String _$dailyTimelineHash() => r'21886641c88c71cdcd4f909d4bd0970d0c894b64';

/// See also [dailyTimeline].
@ProviderFor(dailyTimeline)
const dailyTimelineProvider = DailyTimelineFamily();

/// See also [dailyTimeline].
class DailyTimelineFamily extends Family<AsyncValue<TimelineData>> {
  /// See also [dailyTimeline].
  const DailyTimelineFamily();

  /// See also [dailyTimeline].
  DailyTimelineProvider call(DateRangeSelection range) {
    return DailyTimelineProvider(range);
  }

  @override
  DailyTimelineProvider getProviderOverride(
    covariant DailyTimelineProvider provider,
  ) {
    return call(provider.range);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'dailyTimelineProvider';
}

/// See also [dailyTimeline].
class DailyTimelineProvider extends AutoDisposeFutureProvider<TimelineData> {
  /// See also [dailyTimeline].
  DailyTimelineProvider(DateRangeSelection range)
    : this._internal(
        (ref) => dailyTimeline(ref as DailyTimelineRef, range),
        from: dailyTimelineProvider,
        name: r'dailyTimelineProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$dailyTimelineHash,
        dependencies: DailyTimelineFamily._dependencies,
        allTransitiveDependencies:
            DailyTimelineFamily._allTransitiveDependencies,
        range: range,
      );

  DailyTimelineProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.range,
  }) : super.internal();

  final DateRangeSelection range;

  @override
  Override overrideWith(
    FutureOr<TimelineData> Function(DailyTimelineRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DailyTimelineProvider._internal(
        (ref) => create(ref as DailyTimelineRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        range: range,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<TimelineData> createElement() {
    return _DailyTimelineProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DailyTimelineProvider && other.range == range;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, range.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DailyTimelineRef on AutoDisposeFutureProviderRef<TimelineData> {
  /// The parameter `range` of this provider.
  DateRangeSelection get range;
}

class _DailyTimelineProviderElement
    extends AutoDisposeFutureProviderElement<TimelineData>
    with DailyTimelineRef {
  _DailyTimelineProviderElement(super.provider);

  @override
  DateRangeSelection get range => (origin as DailyTimelineProvider).range;
}

String _$parentInsightsHash() => r'0b0a9a9af85f0355037545fc7d4bed5c34be531e';

/// See also [parentInsights].
@ProviderFor(parentInsights)
final parentInsightsProvider =
    AutoDisposeFutureProvider<List<Insight>>.internal(
      parentInsights,
      name: r'parentInsightsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$parentInsightsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ParentInsightsRef = AutoDisposeFutureProviderRef<List<Insight>>;
String _$babyComparisonHash() => r'1369dae0f1ff06a93918fd11dfed4c66fc0e5a2d';

/// See also [babyComparison].
@ProviderFor(babyComparison)
const babyComparisonProvider = BabyComparisonFamily();

/// See also [babyComparison].
class BabyComparisonFamily extends Family<AsyncValue<ComparisonResult>> {
  /// See also [babyComparison].
  const BabyComparisonFamily();

  /// See also [babyComparison].
  BabyComparisonProvider call(int ageDays) {
    return BabyComparisonProvider(ageDays);
  }

  @override
  BabyComparisonProvider getProviderOverride(
    covariant BabyComparisonProvider provider,
  ) {
    return call(provider.ageDays);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'babyComparisonProvider';
}

/// See also [babyComparison].
class BabyComparisonProvider
    extends AutoDisposeFutureProvider<ComparisonResult> {
  /// See also [babyComparison].
  BabyComparisonProvider(int ageDays)
    : this._internal(
        (ref) => babyComparison(ref as BabyComparisonRef, ageDays),
        from: babyComparisonProvider,
        name: r'babyComparisonProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$babyComparisonHash,
        dependencies: BabyComparisonFamily._dependencies,
        allTransitiveDependencies:
            BabyComparisonFamily._allTransitiveDependencies,
        ageDays: ageDays,
      );

  BabyComparisonProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.ageDays,
  }) : super.internal();

  final int ageDays;

  @override
  Override overrideWith(
    FutureOr<ComparisonResult> Function(BabyComparisonRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: BabyComparisonProvider._internal(
        (ref) => create(ref as BabyComparisonRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        ageDays: ageDays,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<ComparisonResult> createElement() {
    return _BabyComparisonProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BabyComparisonProvider && other.ageDays == ageDays;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, ageDays.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin BabyComparisonRef on AutoDisposeFutureProviderRef<ComparisonResult> {
  /// The parameter `ageDays` of this provider.
  int get ageDays;
}

class _BabyComparisonProviderElement
    extends AutoDisposeFutureProviderElement<ComparisonResult>
    with BabyComparisonRef {
  _BabyComparisonProviderElement(super.provider);

  @override
  int get ageDays => (origin as BabyComparisonProvider).ageDays;
}

String _$statsDateRangeHash() => r'4473e7de7eb6a3fb07a25f7ed278580c1b7b5464';

/// See also [StatsDateRange].
@ProviderFor(StatsDateRange)
final statsDateRangeProvider =
    AutoDisposeNotifierProvider<StatsDateRange, DateRangeSelection>.internal(
      StatsDateRange.new,
      name: r'statsDateRangeProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$statsDateRangeHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$StatsDateRange = AutoDisposeNotifier<DateRangeSelection>;
String _$feedingStatsDateRangeHash() =>
    r'29a5257e2f99391b9ee08a2d7527f7d6c3e4208f';

/// See also [FeedingStatsDateRange].
@ProviderFor(FeedingStatsDateRange)
final feedingStatsDateRangeProvider =
    AutoDisposeNotifierProvider<
      FeedingStatsDateRange,
      DateRangeSelection
    >.internal(
      FeedingStatsDateRange.new,
      name: r'feedingStatsDateRangeProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$feedingStatsDateRangeHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$FeedingStatsDateRange = AutoDisposeNotifier<DateRangeSelection>;
String _$babyFoodStatsDateRangeHash() =>
    r'457d8c77e511e4758440afdbc1256e91365115f1';

/// See also [BabyFoodStatsDateRange].
@ProviderFor(BabyFoodStatsDateRange)
final babyFoodStatsDateRangeProvider =
    AutoDisposeNotifierProvider<
      BabyFoodStatsDateRange,
      DateRangeSelection
    >.internal(
      BabyFoodStatsDateRange.new,
      name: r'babyFoodStatsDateRangeProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$babyFoodStatsDateRangeHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$BabyFoodStatsDateRange = AutoDisposeNotifier<DateRangeSelection>;
String _$sleepStatsDateRangeHash() =>
    r'01c8d31e4fd28500187dd77f9a698218b6b5c44f';

/// See also [SleepStatsDateRange].
@ProviderFor(SleepStatsDateRange)
final sleepStatsDateRangeProvider =
    AutoDisposeNotifierProvider<
      SleepStatsDateRange,
      DateRangeSelection
    >.internal(
      SleepStatsDateRange.new,
      name: r'sleepStatsDateRangeProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$sleepStatsDateRangeHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SleepStatsDateRange = AutoDisposeNotifier<DateRangeSelection>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
