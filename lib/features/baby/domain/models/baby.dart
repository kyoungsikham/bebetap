import 'package:freezed_annotation/freezed_annotation.dart';

part 'baby.freezed.dart';

@freezed
abstract class Baby with _$Baby {
  const factory Baby({
    required String id,
    required String familyId,
    required String name,
    required DateTime birthDate,
    String? gender,   // 'male' | 'female' | 'unknown'
    double? weightKg,
    String? photoUrl,
    @Default(true) bool isActive,
  }) = _Baby;
}
