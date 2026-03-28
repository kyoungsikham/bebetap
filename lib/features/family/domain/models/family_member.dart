import 'package:flutter/foundation.dart';

@immutable
class FamilyMember {
  const FamilyMember({
    required this.userId,
    required this.familyId,
    required this.role,
    required this.joinedAt,
    this.name,
    this.avatarUrl,
    this.nickname,
  });

  final String userId;
  final String familyId;
  final String role; // 'owner' | 'caregiver'
  final DateTime joinedAt;
  final String? name;
  final String? avatarUrl;
  final String? nickname; // 아기와의 관계 (엄마, 아빠, 할머니 등)

  bool get isOwner => role == 'owner';
  String get roleLabel => nickname ?? (isOwner ? '양육자' : '가족');
}
