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
  });

  final String userId;
  final String familyId;
  final String role; // 'owner' | 'caregiver'
  final DateTime joinedAt;
  final String? name;
  final String? avatarUrl;

  bool get isOwner => role == 'owner';
  String get roleLabel => isOwner ? '보호자' : '양육자';
}
