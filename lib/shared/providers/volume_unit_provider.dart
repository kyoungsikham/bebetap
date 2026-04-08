import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/volume_unit.dart';

const _kKey = 'volume_unit';

final volumeUnitProvider =
    AsyncNotifierProvider<VolumeUnitNotifier, VolumeUnit>(
  VolumeUnitNotifier.new,
);

class VolumeUnitNotifier extends AsyncNotifier<VolumeUnit> {
  @override
  Future<VolumeUnit> build() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_kKey);
    return VolumeUnit.values.firstWhere(
      (e) => e.name == str,
      orElse: () => VolumeUnit.ml,
    );
  }

  Future<void> setUnit(VolumeUnit unit) async {
    state = AsyncData(unit);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kKey, unit.name);
  }
}
