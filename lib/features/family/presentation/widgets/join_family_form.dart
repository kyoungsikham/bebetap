import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/family_provider.dart';

class JoinFamilyForm extends ConsumerStatefulWidget {
  const JoinFamilyForm({super.key, required this.onJoined});
  final VoidCallback onJoined;

  @override
  ConsumerState<JoinFamilyForm> createState() => _JoinFamilyFormState();
}

class _JoinFamilyFormState extends ConsumerState<JoinFamilyForm> {
  final _controller = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    final code = _controller.text.trim();
    if (code.isEmpty) {
      setState(() => _errorText = '초대 코드를 입력해주세요');
      return;
    }
    setState(() => _errorText = null);

    await ref.read(familyNotifierProvider.notifier).joinFamily(code);
    final result = ref.read(familyNotifierProvider);
    if (result.hasError) {
      if (mounted) {
        setState(
          () => _errorText =
              result.error.toString().replaceAll('Exception: ', ''),
        );
      }
    } else {
      widget.onJoined();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(familyNotifierProvider).isLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _controller,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            hintText: 'BT-XXXX',
            hintStyle: AppTypography.bodyLarge.copyWith(
              color: AppColors.onSurfaceMuted,
            ),
            errorText: _errorText,
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
        const SizedBox(height: AppSpacing.sm),
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
    );
  }
}
