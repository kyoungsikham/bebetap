import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../domain/models/baby.dart';

class BabyRepository {
  final SupabaseClient _client;
  static const _uuid = Uuid();
  static const _cacheTtl = Duration(minutes: 5);

  BabyRepository(this._client);

  List<Baby>? _cachedBabies;
  DateTime? _babiesCacheTime;

  void _invalidateBabiesCache() {
    _cachedBabies = null;
    _babiesCacheTime = null;
  }

  /// 현재 로그인 사용자가 속한 가족의 아기 목록을 가져옵니다.
  /// [force]가 true이면 5분 캐시를 무시하고 서버에서 즉시 재조회합니다.
  Future<List<Baby>> fetchBabies({bool force = false}) async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    // 유효한 캐시가 있으면 바로 반환 (force 시 스킵)
    if (!force &&
        _cachedBabies != null &&
        _babiesCacheTime != null &&
        DateTime.now().difference(_babiesCacheTime!) < _cacheTtl) {
      return _cachedBabies!;
    }

    final memberRows = await _client
        .from('family_members')
        .select('family_id')
        .eq('user_id', user.id)
        .limit(1);

    if (memberRows.isEmpty) return [];

    final familyId = memberRows.first['family_id'] as String;

    final rows = await _client
        .from('babies')
        .select('id, family_id, name, birth_date, gender, weight_kg, height_cm, photo_url, is_active')
        .eq('family_id', familyId)
        .eq('is_active', true)
        .order('birth_date', ascending: false);

    final babies = rows.map(_fromMap).toList();
    _cachedBabies = babies;
    _babiesCacheTime = DateTime.now();
    return babies;
  }

  /// 아기 사진을 Supabase Storage에 업로드하고 public URL을 반환합니다.
  Future<String> uploadBabyPhoto(String babyId, File imageFile) async {
    if (!imageFile.existsSync()) {
      throw Exception('이미지 파일을 찾을 수 없습니다. 다시 선택해 주세요.');
    }
    final parts = imageFile.path.split('.');
    final ext = parts.length > 1 ? parts.last.toLowerCase() : 'jpg';
    final path = '$babyId.$ext';

    await _client.storage.from('baby-photos').upload(
          path,
          imageFile,
          fileOptions: const FileOptions(upsert: true),
        );

    final publicUrl = _client.storage.from('baby-photos').getPublicUrl(path);
    return '$publicUrl?t=${DateTime.now().millisecondsSinceEpoch}';
  }

  /// 새 가족을 생성하고 아기를 등록합니다 (온보딩 최초 1회).
  Future<Baby> createBabyWithFamily({
    required String name,
    required DateTime birthDate,
    String? gender,
    double? weightKg,
    double? heightCm,
    String? nickname,
    String? photoUrl,
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
      'nickname': ?nickname,
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
          'height_cm': heightCm,
          'photo_url': ?photoUrl,
        })
        .select()
        .single();

    _invalidateBabiesCache();
    return _fromMap(babyRow);
  }

  /// 기존 아기 정보를 수정합니다.
  Future<Baby> updateBaby({
    required String id,
    required String name,
    required DateTime birthDate,
    String? gender,
    double? weightKg,
    double? heightCm,
    String? photoUrl,
  }) async {
    final row = await _client
        .from('babies')
        .update({
          'name': name,
          'birth_date': _toDateString(birthDate),
          'gender': gender,
          'weight_kg': weightKg,
          'height_cm': heightCm,
          'photo_url': ?photoUrl,
        })
        .eq('id', id)
        .select()
        .single();
    _invalidateBabiesCache();
    return _fromMap(row);
  }

  /// 기존 가족에 새 아기를 추가합니다.
  Future<Baby> addBabyToFamily({
    required String familyId,
    required String name,
    required DateTime birthDate,
    String? gender,
    double? weightKg,
    double? heightCm,
    String? photoUrl,
  }) async {
    final babyId = _uuid.v4();
    final row = await _client
        .from('babies')
        .insert({
          'id': babyId,
          'family_id': familyId,
          'name': name,
          'birth_date': _toDateString(birthDate),
          'gender': gender,
          'weight_kg': weightKg,
          'height_cm': heightCm,
          'photo_url': ?photoUrl,
        })
        .select()
        .single();
    _invalidateBabiesCache();
    return _fromMap(row);
  }

  Baby _fromMap(Map<String, dynamic> map) => Baby(
        id: map['id'] as String,
        familyId: map['family_id'] as String,
        name: map['name'] as String,
        birthDate: DateTime.parse(map['birth_date'] as String),
        gender: map['gender'] as String?,
        weightKg: (map['weight_kg'] as num?)?.toDouble(),
        heightCm: (map['height_cm'] as num?)?.toDouble(),
        photoUrl: map['photo_url'] as String?,
        isActive: map['is_active'] as bool? ?? true,
      );

  String _toDateString(DateTime dt) =>
      '${dt.year.toString().padLeft(4, '0')}-'
      '${dt.month.toString().padLeft(2, '0')}-'
      '${dt.day.toString().padLeft(2, '0')}';
}
