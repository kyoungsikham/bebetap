import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/default_landing.dart';

const _kKey = 'default_landing';

DefaultLanding? _preloaded;

/// main()에서 GoRouter 생성 전에 호출해 synchronous 읽기를 보장한다.
Future<void> preloadDefaultLanding() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_kKey);
    _preloaded = DefaultLanding.values.firstWhere(
      (e) => e.name == s,
      orElse: () => DefaultLanding.log,
    );
  } catch (_) {
    _preloaded = DefaultLanding.log;
  }
}

/// GoRouter의 initialLocation 및 redirect에서 async 없이 즉시 사용.
DefaultLanding defaultLandingPreloadedOrFallback() =>
    _preloaded ?? DefaultLanding.log;

final defaultLandingProvider =
    AsyncNotifierProvider<DefaultLandingNotifier, DefaultLanding>(
  DefaultLandingNotifier.new,
);

class DefaultLandingNotifier extends AsyncNotifier<DefaultLanding> {
  @override
  Future<DefaultLanding> build() async {
    if (_preloaded != null) return _preloaded!;
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_kKey);
    final v = DefaultLanding.values.firstWhere(
      (e) => e.name == s,
      orElse: () => DefaultLanding.log,
    );
    _preloaded = v;
    return v;
  }

  Future<void> setLanding(DefaultLanding v) async {
    state = AsyncData(v);
    _preloaded = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kKey, v.name);
  }
}
