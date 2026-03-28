import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_bottom_sheet.dart';
import '../providers/family_provider.dart';
import 'relationship_selector.dart';

Future<void> showJoinFamilyBottomSheet(
  BuildContext context, {
  required VoidCallback onJoined,
}) {
  return showAppBottomSheet(
    context: context,
    title: '초대 코드로 합류하기',
    child: _JoinFamilyBottomSheet(onJoined: onJoined),
  );
}

class _JoinFamilyBottomSheet extends ConsumerStatefulWidget {
  const _JoinFamilyBottomSheet({required this.onJoined});
  final VoidCallback onJoined;

  @override
  ConsumerState<_JoinFamilyBottomSheet> createState() =>
      _JoinFamilyBottomSheetState();
}

class _JoinFamilyBottomSheetState
    extends ConsumerState<_JoinFamilyBottomSheet> {
  final _codeController = TextEditingController();
  String? _nickname;
  String? _errorText;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() => _errorText = '초대 코드를 입력해주세요');
      return;
    }
    if (_nickname == null || _nickname!.isEmpty) {
      setState(() => _errorText = '아기와의 관계를 선택해주세요');
      return;
    }
    setState(() => _errorText = null);

    await ref
        .read(familyNotifierProvider.notifier)
        .joinFamily(code, nickname: _nickname);
    final result = ref.read(familyNotifierProvider);
    if (result.hasError) {
      if (mounted) {
        setState(
          () => _errorText =
              result.error.toString().replaceAll('Exception: ', ''),
        );
      }
    } else {
      if (mounted) Navigator.of(context).pop();
      widget.onJoined();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(familyNotifierProvider).isLoading;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.pagePadding,
        AppSpacing.lg,
        AppSpacing.pagePadding,
        AppSpacing.lg + bottomInset,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 초대 코드 입력
            Text('초대 코드', style: AppTypography.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _codeController,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: 'BT-XXXX',
                hintStyle: AppTypography.bodyLarge.copyWith(
                  color: AppColors.onSurfaceMuted,
                ),
                filled: true,
                fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.divider),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.divider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.onSurface,
                letterSpacing: 2,
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // 관계 선택
            Text('아기와의 관계', style: AppTypography.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            RelationshipSelector(
              selected: _nickname,
              onChanged: (v) => setState(() => _nickname = v),
            ),

            // 에러 메시지
            if (_errorText != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                _errorText!,
                style: AppTypography.bodySmall.copyWith(color: AppColors.error),
              ),
            ],

            const SizedBox(height: AppSpacing.xxl),

            // 합류 버튼
            FilledButton(
              onPressed: isLoading ? null : _join,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
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
                  : Text(
                      '가족 합류하기',
                      style: AppTypography.labelLarge.copyWith(
                        color: Colors.white,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
