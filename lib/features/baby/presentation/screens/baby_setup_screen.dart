import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
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
  String? _gender; // 'male' | 'female' | null

  static final _dateFormat = DateFormat('yyyy년 MM월 dd일');

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    super.dispose();
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

    final weightText = _weightController.text.trim();
    final weightKg =
        weightText.isNotEmpty ? double.tryParse(weightText) : null;

    final baby = await ref.read(babySetupNotifierProvider.notifier).createBaby(
          name: _nameController.text.trim(),
          birthDate: _birthDate!,
          gender: _gender,
          weightKg: weightKg,
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
