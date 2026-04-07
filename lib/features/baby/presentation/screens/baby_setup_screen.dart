import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/extensions/l10n_ext.dart';
import '../../../../shared/widgets/baby_avatar_widget.dart';
import '../../../../core/router/app_routes.dart';
import '../../../family/presentation/widgets/join_family_bottom_sheet.dart';
import '../../../family/presentation/widgets/relationship_selector.dart';
import '../providers/baby_provider.dart';

class BabySetupScreen extends ConsumerStatefulWidget {
  const BabySetupScreen({super.key});

  @override
  ConsumerState<BabySetupScreen> createState() => _BabySetupScreenState();
}

class _BabySetupScreenState extends ConsumerState<BabySetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _weightController = TextEditingController();

  DateTime? _birthDate;
  String? _gender;
  String? _nickname;
  File? _imageFile;


  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (picked != null) setState(() => _imageFile = File(picked.path));
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? now,
      firstDate: DateTime(now.year - 3),
      lastDate: now,
      helpText: context.l10n.birthDate,
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.birthDatePrompt)),
      );
      return;
    }
    if (_nickname == null || _nickname!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.babyRelationshipPrompt)),
      );
      return;
    }

    final weightText = _weightController.text.trim();
    final weightKg =
        weightText.isNotEmpty ? double.tryParse(weightText) : null;
    final repo = ref.read(babyRepositoryProvider);

    String? photoUrl;
    if (_imageFile != null) {
      final tempKey = 'setup_${DateTime.now().millisecondsSinceEpoch}';
      photoUrl = await repo.uploadBabyPhoto(tempKey, _imageFile!);
    }

    final baby = await ref.read(babySetupNotifierProvider.notifier).createBaby(
          name: _nameController.text.trim(),
          birthDate: _birthDate!,
          gender: _gender,
          weightKg: weightKg,
          nickname: _nickname,
          photoUrl: photoUrl,
        );

    if (!mounted) return;
    if (baby == null) {
      final error = ref.read(babySetupNotifierProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.saveFailed(error.toString()))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final setupState = ref.watch(babySetupNotifierProvider);
    final isLoading = setupState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(context.l10n.babySetupTitle, style: AppTypography.titleLarge),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.lg),

                // 프로필 사진
                Center(
                  child: BabyAvatarWidget(
                    localFile: _imageFile,
                    gender: _gender,
                    size: 96,
                    showEditOverlay: true,
                    onTap: _pickImage,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Center(
                  child: Text(
                    context.l10n.photoSelect,
                    style: AppTypography.bodySmall
                        .copyWith(color: AppColors.onSurfaceMuted),
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // 아기 이름
                _SectionLabel(context.l10n.babyName),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _nameController,
                  decoration: _inputDecoration(context.l10n.babyNameHint),
                  textInputAction: TextInputAction.next,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? context.l10n.babyNameRequired : null,
                ),

                const SizedBox(height: AppSpacing.xl),

                // 생년월일
                _SectionLabel(context.l10n.birthDate),
                const SizedBox(height: AppSpacing.sm),
                GestureDetector(
                  onTap: _pickBirthDate,
                  child: Container(
                    height: 52,
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.divider),
                    ),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _birthDate != null
                          ? DateFormat(context.l10n.dateFormat).format(_birthDate!)
                          : context.l10n.selectBirthDate,
                      style: AppTypography.bodyMedium.copyWith(
                        color: _birthDate != null
                            ? AppColors.onSurface
                            : AppColors.onSurfaceMuted,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // 성별 (선택)
                _SectionLabel(context.l10n.genderOptional),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: _GenderButton(
                        label: context.l10n.boy,
                        icon: Icons.boy,
                        selected: _gender == 'male',
                        onTap: () => setState(
                            () => _gender = _gender == 'male' ? null : 'male'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _GenderButton(
                        label: context.l10n.girl,
                        icon: Icons.girl,
                        selected: _gender == 'female',
                        onTap: () => setState(() =>
                            _gender = _gender == 'female' ? null : 'female'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xl),

                // 체중 (선택)
                _SectionLabel(context.l10n.currentWeight),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _weightController,
                  decoration: _inputDecoration(context.l10n.weightHint),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return null;
                    final parsed = double.tryParse(v.trim());
                    if (parsed == null || parsed <= 0 || parsed > 30) {
                      return context.l10n.invalidWeight;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.md),
                Text(
                  context.l10n.weightFormulaHint,
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.onSurfaceMuted),
                ),

                const SizedBox(height: AppSpacing.xl),

                // 아기와의 관계
                _SectionLabel(context.l10n.babyRelationship),
                const SizedBox(height: AppSpacing.sm),
                RelationshipSelector(
                  selected: _nickname,
                  onChanged: (v) => setState(() => _nickname = v),
                ),

                const SizedBox(height: AppSpacing.xxxl),

                // 저장 버튼
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
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
                        : Text(context.l10n.startButton),
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // 구분선
                Row(
                  children: [
                    const Expanded(child: Divider(color: AppColors.divider)),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md),
                      child: Text(
                        context.l10n.or,
                        style: AppTypography.bodySmall
                            .copyWith(color: AppColors.onSurfaceMuted),
                      ),
                    ),
                    const Expanded(child: Divider(color: AppColors.divider)),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),

                // 초대 코드 합류 버튼
                TextButton.icon(
                  onPressed: () => showJoinFamilyBottomSheet(
                    context,
                    onJoined: () {
                      ref.invalidate(babiesProvider);
                      if (mounted) context.go(AppRoutes.home);
                    },
                  ),
                  icon: const Icon(Icons.login, color: AppColors.primary),
                  label: Text(
                    context.l10n.joinWithInviteCode,
                    style: AppTypography.labelLarge
                        .copyWith(color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle:
            AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceMuted),
        filled: true,
        fillColor: AppColors.surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.md),
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
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      );
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: AppTypography.labelLarge.copyWith(color: AppColors.onSurface),
      );
}

class _GenderButton extends StatelessWidget {
  const _GenderButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 56,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color:
                    selected ? AppColors.primary : AppColors.onSurfaceMuted,
                size: 20),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: AppTypography.labelLarge.copyWith(
                color: selected ? AppColors.primary : AppColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
