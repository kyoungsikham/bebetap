import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/extensions/datetime_ext.dart';
import '../../../../shared/extensions/l10n_ext.dart';
import '../../../family/presentation/providers/family_provider.dart';
import '../../../log/domain/models/timeline_entry.dart';
import '../providers/diary_provider.dart';

class DiaryBottomSheet extends ConsumerStatefulWidget {
  const DiaryBottomSheet({super.key, this.editEntry});

  final TimelineEntry? editEntry;

  @override
  ConsumerState<DiaryBottomSheet> createState() => _DiaryBottomSheetState();
}

class _DiaryBottomSheetState extends ConsumerState<DiaryBottomSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _contentCtrl;

  bool get _isEditMode => widget.editEntry != null;

  @override
  void initState() {
    super.initState();
    _titleCtrl =
        TextEditingController(text: widget.editEntry?.rawTitle ?? '');
    _contentCtrl =
        TextEditingController(text: widget.editEntry?.rawContent ?? '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  bool get _canSave =>
      _titleCtrl.text.trim().isNotEmpty &&
      _contentCtrl.text.trim().isNotEmpty;

  /// 현재 사용자의 닉네임을 family members에서 찾아 반환
  String _resolveNickname(List members) {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    try {
      return members
              .cast<dynamic>()
              .where((m) => m.userId == userId)
              .firstOrNull
              ?.nickname ??
          context.l10n.diaryAuthorLabel;
    } catch (_) {
      return context.l10n.diaryAuthorLabel;
    }
  }

  String _formatDate(DateTime dt) => dt.formatLongLocalized(context.l10n);

  /// 다른 사람 일기인지 확인
  bool get _isOtherAuthor {
    if (!_isEditMode) return false;
    final myId = Supabase.instance.client.auth.currentUser?.id;
    final authorId = widget.editEntry?.rawRecordedBy;
    if (authorId == null) return false;
    return myId != authorId;
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(diaryNotifierProvider).isLoading;
    final membersAsync = ref.watch(familyMembersProvider);
    final now = DateTime.now();

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.pagePadding,
        right: AppSpacing.pagePadding,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.xl),

          // 날짜 + 작성자
          Row(
            children: [
              Text(
                _formatDate(_isEditMode ? widget.editEntry!.occurredAt : now),
                style: AppTypography.bodyMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              membersAsync.when(
                data: (members) {
                  final nick = _isEditMode
                      ? (widget.editEntry?.rawAuthorNickname ?? context.l10n.diaryAuthorLabel)
                      : _resolveNickname(members);
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF03A9F4).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      nick,
                      style: AppTypography.labelSmall.copyWith(
                        color: const Color(0xFF1E88E5),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (e, st) => const SizedBox.shrink(),
              ),
            ],
          ),

          if (_isOtherAuthor) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                context.l10n.diaryReadOnly,
                style: AppTypography.bodySmall.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            // 제목/내용 읽기 전용
            Text(
              _titleCtrl.text,
              style: AppTypography.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _contentCtrl.text,
              style: AppTypography.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xl),
          ] else ...[
            const SizedBox(height: AppSpacing.lg),

            // 제목
            TextField(
              controller: _titleCtrl,
              maxLines: 1,
              textInputAction: TextInputAction.next,
              autofocus: !_isEditMode,
              style: AppTypography.titleMedium,
              decoration: InputDecoration(
                hintText: context.l10n.diaryTitleHint,
                hintStyle: AppTypography.titleMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: AppSpacing.sm),

            // 내용
            TextField(
              controller: _contentCtrl,
              maxLines: 6,
              minLines: 4,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              style: AppTypography.bodyMedium,
              decoration: InputDecoration(
                hintText: context.l10n.diaryContentHint,
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(AppSpacing.lg),
              ),
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: AppSpacing.xl),

            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: (isLoading || !_canSave)
                    ? null
                    : () async {
                        if (_isEditMode) {
                          await ref
                              .read(diaryNotifierProvider.notifier)
                              .updateDiary(
                                widget.editEntry!.id,
                                title: _titleCtrl.text.trim(),
                                content: _contentCtrl.text.trim(),
                              );
                        } else {
                          await ref
                              .read(diaryNotifierProvider.notifier)
                              .saveDiary(
                                title: _titleCtrl.text.trim(),
                                content: _contentCtrl.text.trim(),
                              );
                        }
                        if (context.mounted) Navigator.of(context).pop();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF03A9F4),
                  foregroundColor: AppColors.onPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(_isEditMode ? context.l10n.edit : context.l10n.save),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
