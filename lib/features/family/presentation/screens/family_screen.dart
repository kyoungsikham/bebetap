import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Family;

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/family.dart';
import '../../domain/models/family_member.dart';
import '../providers/family_provider.dart';
import '../widgets/invite_code_card.dart';
import '../widgets/join_family_form.dart';

class FamilyScreen extends ConsumerStatefulWidget {
  const FamilyScreen({super.key});

  @override
  ConsumerState<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends ConsumerState<FamilyScreen> {
  bool _showJoinForm = false;
  final _familyNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 실시간 동기화 활성화 (keepAlive: true이므로 이후 계속 유지됨)
    ref.read(familyRealtimeProvider);
  }

  @override
  void dispose() {
    _familyNameController.dispose();
    super.dispose();
  }

  Future<void> _createFamily(BuildContext ctx) async {
    final name = _familyNameController.text.trim();
    if (name.isEmpty) return;
    await ref.read(familyNotifierProvider.notifier).createFamily(name);
    if (ctx.mounted) Navigator.of(ctx).pop();
  }

  void _showCreateDialog() {
    _familyNameController.clear();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('가족 그룹 만들기'),
        content: TextField(
          controller: _familyNameController,
          decoration: const InputDecoration(
            hintText: '예: 김씨 가족',
            labelText: '가족 이름',
          ),
          autofocus: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _createFamily(ctx),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => _createFamily(ctx),
            child: const Text('만들기'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final familyAsync = ref.watch(myFamilyProvider);
    final membersAsync = ref.watch(familyMembersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('가족 공유', style: AppTypography.titleLarge),
      ),
      body: familyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Text(
            '오류가 발생했습니다',
            style: AppTypography.bodyLarge,
          ),
        ),
        data: (family) {
          if (family == null) {
            return _NoFamilyView(
              showJoinForm: _showJoinForm,
              onShowJoin: () => setState(() => _showJoinForm = true),
              onCreateTap: _showCreateDialog,
              onJoined: () {
                ref.invalidate(myFamilyProvider);
                setState(() => _showJoinForm = false);
              },
            );
          }
          return _FamilyView(family: family, membersAsync: membersAsync);
        },
      ),
    );
  }
}

class _NoFamilyView extends StatelessWidget {
  const _NoFamilyView({
    required this.showJoinForm,
    required this.onShowJoin,
    required this.onCreateTap,
    required this.onJoined,
  });

  final bool showJoinForm;
  final VoidCallback onShowJoin;
  final VoidCallback onCreateTap;
  final VoidCallback onJoined;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      children: [
        const SizedBox(height: AppSpacing.xxxl),
        const Icon(Icons.group_outlined, size: 64, color: AppColors.onSurfaceMuted),
        const SizedBox(height: AppSpacing.lg),
        Text(
          '가족 그룹이 없습니다',
          textAlign: TextAlign.center,
          style: AppTypography.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          '가족을 만들거나 초대 코드로 합류하세요',
          textAlign: TextAlign.center,
          style: AppTypography.bodySmall,
        ),
        const SizedBox(height: AppSpacing.xxl),
        FilledButton.icon(
          onPressed: onCreateTap,
          icon: const Icon(Icons.add),
          label: const Text('새 가족 그룹 만들기'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton.icon(
          onPressed: onShowJoin,
          icon: const Icon(Icons.login),
          label: const Text('초대 코드로 합류하기'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            side: const BorderSide(color: AppColors.divider),
          ),
        ),
        if (showJoinForm) ...[
          const SizedBox(height: AppSpacing.xxl),
          Text(
            '초대 코드 입력',
            style: AppTypography.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          JoinFamilyForm(onJoined: onJoined),
        ],
      ],
    );
  }
}

class _FamilyView extends StatelessWidget {
  const _FamilyView({required this.family, required this.membersAsync});

  final Family family;
  final AsyncValue<List<FamilyMember>> membersAsync;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      children: [
        Text(
          family.name,
          style: AppTypography.titleLarge,
        ),
        const SizedBox(height: AppSpacing.lg),
        InviteCodeCard(family: family),
        const SizedBox(height: AppSpacing.xxl),
        Text('가족 구성원', style: AppTypography.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        membersAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (_, _) => Text(
            '불러오기 실패',
            style: AppTypography.bodySmall,
          ),
          data: (members) => Column(
            children: members.map((m) => _MemberTile(member: m)).toList(),
          ),
        ),
      ],
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({required this.member});
  final FamilyMember member;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.surfaceVariant,
            backgroundImage: member.avatarUrl != null
                ? NetworkImage(member.avatarUrl!)
                : null,
            child: member.avatarUrl == null
                ? const Icon(
                    Icons.person_outline,
                    size: 20,
                    color: AppColors.onSurfaceMuted,
                  )
                : null,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              member.name ?? '사용자',
              style: AppTypography.bodyMedium,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: member.isOwner
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              member.roleLabel,
              style: AppTypography.labelSmall.copyWith(
                color: member.isOwner
                    ? AppColors.primary
                    : AppColors.onSurfaceMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
