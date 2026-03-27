import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/models/family.dart';
import '../domain/models/family_member.dart';

class FamilyRepository {
  const FamilyRepository(this._client);
  final SupabaseClient _client;

  String? get _userId => _client.auth.currentUser?.id;

  Future<Family?> getMyFamily() async {
    if (_userId == null) return null;
    try {
      final data = await _client
          .from('family_members')
          .select('family_id, families!inner(id, name, invite_code, created_at)')
          .eq('user_id', _userId!)
          .limit(1)
          .maybeSingle();

      if (data == null) return null;
      final f = data['families'] as Map<String, dynamic>;
      return Family(
        id: f['id'] as String,
        name: f['name'] as String,
        inviteCode: f['invite_code'] as String,
        createdAt: DateTime.parse(f['created_at'] as String),
      );
    } catch (e) {
      debugPrint('getMyFamily error: $e');
      return null;
    }
  }

  Future<Family> createFamily(String name) async {
    final uid = _userId!;
    final familyData = await _client
        .from('families')
        .insert({'name': name, 'created_by': uid})
        .select()
        .single();

    await _client.from('family_members').insert({
      'family_id': familyData['id'],
      'user_id': uid,
      'role': 'owner',
    });

    return Family(
      id: familyData['id'] as String,
      name: familyData['name'] as String,
      inviteCode: familyData['invite_code'] as String,
      createdAt: DateTime.parse(familyData['created_at'] as String),
    );
  }

  Future<Family> joinFamily(String inviteCode) async {
    final uid = _userId!;
    final familyData = await _client
        .from('families')
        .select()
        .eq('invite_code', inviteCode.toUpperCase().trim())
        .maybeSingle();

    if (familyData == null) throw Exception('초대 코드를 찾을 수 없습니다');

    final familyId = familyData['id'] as String;

    final existing = await _client
        .from('family_members')
        .select()
        .eq('family_id', familyId)
        .eq('user_id', uid)
        .maybeSingle();

    if (existing == null) {
      await _client.from('family_members').insert({
        'family_id': familyId,
        'user_id': uid,
        'role': 'caregiver',
      });
    }

    return Family(
      id: familyId,
      name: familyData['name'] as String,
      inviteCode: familyData['invite_code'] as String,
      createdAt: DateTime.parse(familyData['created_at'] as String),
    );
  }

  Future<List<FamilyMember>> getMembers(String familyId) async {
    try {
      final data = await _client
          .from('family_members')
          .select('*, profiles(display_name, avatar_url)')
          .eq('family_id', familyId)
          .order('joined_at');

      return data.map((m) {
        final profile = m['profiles'] as Map<String, dynamic>?;
        return FamilyMember(
          userId: m['user_id'] as String,
          familyId: m['family_id'] as String,
          role: m['role'] as String? ?? 'caregiver',
          name: profile?['display_name'] as String?,
          avatarUrl: profile?['avatar_url'] as String?,
          joinedAt: DateTime.parse(m['joined_at'] as String),
        );
      }).toList();
    } catch (_) {
      final data = await _client
          .from('family_members')
          .select()
          .eq('family_id', familyId)
          .order('joined_at');

      return data
          .map(
            (m) => FamilyMember(
              userId: m['user_id'] as String,
              familyId: m['family_id'] as String,
              role: m['role'] as String? ?? 'caregiver',
              joinedAt: DateTime.parse(m['joined_at'] as String),
            ),
          )
          .toList();
    }
  }
}
