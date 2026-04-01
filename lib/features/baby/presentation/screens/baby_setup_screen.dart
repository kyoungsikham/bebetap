import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/baby_avatar_widget.dart';
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

  static final _dateFormat = DateFormat('yyyy년 MM월 dd일');

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
      helpText: '생년월일 선택',
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('생년월일을 선택해주세요')),
      );
      return;
    }
    if (_nickname == null || _nickname!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('아기와의 관계를 선택해주세요')),
      );
      return;
    }

    final weightText = _weightController.text.trim();
    final weightKg =
        weightText.isNotEmpty ? double.tryParse(weightText) : null;
    final repo = ref.read(babyRepositoryProvider);

    // 사진 먼저 업로드 (임시 ID 사용, 실제 babyId는 생성 후 알 수 있음)
    // 온보딩에서는 이름 기반 임시 key로 업로드 후 DB에 저장
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
        SnackBar(content: Text('저장 실패: $error')),
      );
    }
    // 성공 시 router가 자동으로 홈으로 리디렉션
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
        title: const Text('아기 정보 입력', style: AppTypography.titleLarge),
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
                    '사진 선택 (선택)',
                    style: AppTypography.bodySmall
                        .copyWith(color: AppColors.onSurfaceMuted),
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // 아기 이름
                const _SectionLabel('아기 이름 *'),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _nameController,
                  decoration: _inputDecoration('예: 김하늘'),
                  textInputAction: TextInputAction.next,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? '이름을 입력해주세요' : null,
                ),

                const SizedBox(height: AppSpacing.xl),

                // 생년월일
                const _SectionLabel('생년월일 *'),
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
                          ? _dateFormat.format(_birthDate!)
                          : '날짜를 선택하세요',
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
                const _SectionLabel('성별 (선택)'),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: _GenderButton(
                        label: '남자아이',
                        icon: Icons.boy,
                        selected: _gender == 'male',
                        onTap: () => setState(
                            () => _gender = _gender == 'male' ? null : 'male'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _GenderButton(
                        label: '여자아이',
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
                const _SectionLabel('현재 체중 kg (선택)'),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _weightController,
                  decoration: _inputDecoration('예: 4.5'),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return null;
                    final parsed = double.tryParse(v.trim());
                    if (parsed == null || parsed <= 0 || parsed > 30) {
                      return '올바른 체중을 입력해주세요 (0~30 kg)';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.md),
                Text(
                  '체중을 입력하면 분유 일일 권장량을 자동으로 계산해드립니다',
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.onSurfaceMuted),
                ),

                const SizedBox(height: AppSpacing.xl),

                // 아기와의 관계
                const _SectionLabel('아기와의 관계 *'),
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
                        : const Text('시작하기'),
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
                        '또는',
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
                    onJoined: () => ref.invalidate(babiesProvider),
                  ),
                  icon: const Icon(Icons.login, color: AppColors.primary),
                  label: Text(
                    '초대 코드로 합류하기',
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
