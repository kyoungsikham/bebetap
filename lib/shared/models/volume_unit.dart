enum VolumeUnit { ml, oz }

extension VolumeUnitX on VolumeUnit {
  /// ml 값을 현재 단위 문자열로 포맷 (예: "120ml" 또는 "4.0oz")
  String formatAmount(int ml) {
    if (this == VolumeUnit.oz) {
      // 1oz = 30ml (육아앱 표준 반올림)
      final oz = ml / 30.0;
      return '${oz.toStringAsFixed(1)}oz';
    }
    return '${ml}ml';
  }

  /// 피커용 아이템 목록 (항상 ml 단위 int 값)
  /// ml 모드: 10ml 단위, oz 모드: 0.5oz(=15ml) 단위
  List<int> pickerItems({required int minMl, required int maxMl, required int stepMl}) {
    if (this == VolumeUnit.oz) {
      // 0.5oz = 15ml 단위 (0 포함)
      const ozStepMl = 15;
      return List.generate(maxMl ~/ ozStepMl + 1, (i) => i * ozStepMl);
    }
    return List.generate(
      (maxMl - minMl) ~/ stepMl + 1,
      (i) => minMl + i * stepMl,
    );
  }

  /// 현재 ml 값을 가장 가까운 피커 단계로 스냅
  int snapToStep(int ml, {required int minMl, required int maxMl, required int stepMl}) {
    final items = pickerItems(minMl: minMl, maxMl: maxMl, stepMl: stepMl);
    if (items.isEmpty) return minMl;
    return items.reduce((a, b) => (a - ml).abs() < (b - ml).abs() ? a : b);
  }
}
