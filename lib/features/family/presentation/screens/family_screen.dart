import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Family;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/extensions/l10n_ext.dart';
import '../../domain/models/family.dart';
import '../../domain/models/family_member.dart';
import '../providers/family_provider.dart';
import '../widgets/invite_code_card.dart';
import '../widgets/join_family_bottom_sheet.dart';

class FamilyScreen extends ConsumerStatefulWidget {
  const FamilyScreen({super.key});

  @override
  ConsumerState<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends ConsumerState<FamilyScreen> {
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
        title: Text(context.l10n.createFamilyDialog),
        content: TextField(
          controller: _familyNameController,
          decoration: InputDecoration(
            hintText: context.l10n.familyNameHint,
            labelText: context.l10n.familyGroupName,
          ),
          autofocus: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _createFamily(ctx),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => _createFamily(ctx),
            child: Text(context.l10n.makeFamily),
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
        title: Text(context.l10n.familyTitle, style: AppTypography.titleLarge),
      ),
      body: familyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Text(
            context.l10n.familyError,
            style: AppTypography.bodyLarge,
          ),
        ),
        data: (family) {
          if (family == null) {
            return _NoFamilyView(
              onShowJoin: () => showJoinFamilyBottomSheet(
                context,
                onJoined: () => ref.invalidate(myFamilyProvider),
              ),
              onCreateTap: _showCreateDialog,
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
    required this.onShowJoin,
    required this.onCreateTap,
  });

  final VoidCallback onShowJoin;
  final VoidCallback onCreateTap;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      children: [
        const SizedBox(height: AppSpacing.xxxl),
        const Icon(Icons.group_outlined, size: 64, color: AppColors.onSurfaceMuted),
        const SizedBox(height: AppSpacing.lg),
        Text(
          context.l10n.noFamily,
          textAlign: TextAlign.center,
          style: AppTypography.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          context.l10n.noFamilyHint,
          textAlign: TextAlign.center,
          style: AppTypography.bodySmall,
        ),
        const SizedBox(height: AppSpacing.xxl),
        FilledButton.icon(
          onPressed: onCreateTap,
          icon: const Icon(Icons.add),
          label: Text(context.l10n.createFamily),
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
          label: Text(context.l10n.joinWithInviteCode),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            side: const BorderSide(color: AppColors.divider),
          ),
        ),
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
        Text(context.l10n.familyMembers, style: AppTypography.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        membersAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (_, _) => Text(
            context.l10n.familyLoadFailed,
            style: AppTypography.bodySmall,
          ),
          data: (members) {
            final myId = Supabase.instance.client.auth.currentUser?.id;
            return Column(
              children: members
                  .map((m) => _MemberTile(member: m, isMe: m.userId == myId))
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({required this.member, required this.isMe});
  final FamilyMember member;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final badgeColor = isMe
        ? AppColors.success
        : member.isOwner
            ? AppColors.primary
            : AppColors.onSurfaceMuted;
    final badgeBg = isMe
        ? AppColors.success.withValues(alpha: 0.12)
        : member.isOwner
            ? AppColors.primary.withValues(alpha: 0.1)
            : AppColors.surfaceVariant;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 10),
      decoration: BoxDecoration(
        color: isMe ? AppColors.success.withValues(alpha: 0.05) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isMe
            ? Border.all(color: AppColors.success.withValues(alpha: 0.3))
            : null,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: isMe
                ? AppColors.success.withValues(alpha: 0.15)
                : AppColors.surfaceVariant,
            backgroundImage: member.avatarUrl != null
                ? NetworkImage(member.avatarUrl!)
                : null,
            child: member.avatarUrl == null
                ? Icon(
                    Icons.person_outline,
                    size: 20,
                    color: isMe ? AppColors.success : AppColors.onSurfaceMuted,
                  )
                : null,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              member.name ?? context.l10n.userLabel,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: isMe ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          if (isMe)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Text(
                context.l10n.me,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              member.nickname ?? (member.isOwner ? context.l10n.caregiverRole : context.l10n.familyRole),
              style: AppTypography.labelSmall.copyWith(color: badgeColor),
            ),
          ),
        ],
      ),
    );
  }
}
