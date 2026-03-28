import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../domain/models/baby.dart';

class BabyRepository {
  final SupabaseClient _client;
  static const _uuid = Uuid();

  BabyRepository(this._client);

  /// 현재 로그인 사용자가 속한 가족의 아기 목록을 가져옵니다.
  Future<List<Baby>> fetchBabies() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    final memberRows = await _client
        .from('family_members')
        .select('family_id')
        .eq('user_id', user.id);

    if (memberRows.isEmpty) return [];

    final familyId = memberRows.first['family_id'] as String;

    final rows = await _client
        .from('babies')
        .select()
        .eq('family_id', familyId)
        .eq('is_active', true)
        .order('birth_date', ascending: false);

    return rows.map(_fromMap).toList();
  }

  /// 새 가족을 생성하고 아기를 등록합니다 (온보딩 최초 1회).
  Future<Baby> createBabyWithFamily({
    required String name,
    required DateTime birthDate,
    String? gender,
    double? weightKg,
    String? nickname,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('로그인이 필요합니다');

    // 1. 가족 생성 (초대 코드는 DB 트리거에서 자동 생성)
    final familyRow = await _client
        .from('families')
        .insert({'name': '$name의 가족', 'created_by': user.id})
        .select()
        .single();
    final familyId = familyRow['id'] as String;

    // 2. 가족 구성원으로 등록 (owner)
    await _client.from('family_members').insert({
      'family_id': familyId,
      'user_id': user.id,
      'role': 'owner',
      if (nickname != null) 'nickname': nickname,
    });

    // 3. 아기 생성
    final babyId = _uuid.v4();
    final babyRow = await _client
        .from('babies')
        .insert({
          'id': babyId,
          'family_id': familyId,
          'name': name,
          'birth_date': _toDateString(birthDate),
          'gender': gender,
          'weight_kg': weightKg,
        })
        .select()
        .single();

    return _fromMap(babyRow);
  }

  Baby _fromMap(Map<String, dynamic> map) => Baby(
        id: map['id'] as String,
        familyId: map['family_id'] as String,
        name: map['name'] as String,
        birthDate: DateTime.parse(map['birth_date'] as String),
        gender: map['gender'] as String?,
        weightKg: (map['weight_kg'] as num?)?.toDouble(),
        photoUrl: map['photo_url'] as String?,
        isActive: map['is_active'] as bool? ?? true,
      );

  String _toDateString(DateTime dt) =>
      '${dt.year.toString().padLeft(4, '0')}-'
      '${dt.month.toString().padLeft(2, '0')}-'
      '${dt.day.toString().padLeft(2, '0')}';
}
