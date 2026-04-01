import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_bottom_sheet.dart';
import '../../../../shared/widgets/baby_avatar_widget.dart';
import '../../domain/models/baby.dart';
import '../providers/baby_provider.dart';

class BabyManageScreen extends ConsumerWidget {
  const BabyManageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final babiesAsync = ref.watch(babiesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('아이 관리', style: AppTypography.titleLarge),
      ),
      body: babiesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            '불러오기 실패: $e',
            style: AppTypography.bodyMedium
                .copyWith(color: AppColors.onSurfaceMuted),
          ),
        ),
        data: (babies) => _BabyManageBody(babies: babies),
      ),
    );
  }
}

class _BabyManageBody extends StatelessWidget {
  const _BabyManageBody({required this.babies});

  final List<Baby> babies;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (babies.isNotEmpty) ...[
            Text('등록된 아이', style: AppTypography.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            ...babies.map((baby) => _BabyListTile(baby: baby)),
            const SizedBox(height: AppSpacing.xl),
            const Divider(),
            const SizedBox(height: AppSpacing.xl),
          ],
          ElevatedButton.icon(
            onPressed: () => _openForm(context, babies, null),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.add),
            label: const Text('새 아이 추가'),
          ),
        ],
      ),
    );
  }

  void _openForm(BuildContext context, List<Baby> babies, Baby? editBaby) {
    final familyId = babies.isNotEmpty ? babies.first.familyId : null;
    showAppBottomSheet(
      context: context,
      title: editBaby != null ? '아이 수정' : '아이 추가',
      child: _BabyFormSheet(editBaby: editBaby, familyId: familyId),
    );
  }
}

class _BabyListTile extends ConsumerWidget {
  const _BabyListTile({required this.baby});

  final Baby baby;

  static final _dateFormat = DateFormat('yyyy년 MM월 dd일');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(selectedBabyIdProvider);
    final babiesList = ref.watch(babiesProvider).valueOrNull ?? [];
    final effectiveId = selectedId ?? (babiesList.isNotEmpty ? babiesList.first.id : null);
    final isSelected = baby.id == effectiveId;

    return GestureDetector(
      onTap: () => ref.read(selectedBabyIdProvider.notifier).select(baby.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.05)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: ListTile(
          leading: BabyAvatarWidget(
            photoUrl: baby.photoUrl,
            gender: baby.gender,
            size: 44,
          ),
          title: Text(baby.name, style: AppTypography.bodyLarge),
          subtitle: Text(
            _dateFormat.format(baby.birthDate),
            style: AppTypography.bodySmall
                .copyWith(color: AppColors.onSurfaceMuted),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSelected)
                const Icon(Icons.check_circle, color: AppColors.primary),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                color: AppColors.onSurfaceMuted,
                onPressed: () => showAppBottomSheet(
                  context: context,
                  title: '아이 수정',
                  child:
                      _BabyFormSheet(editBaby: baby, familyId: baby.familyId),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BabyFormSheet extends ConsumerStatefulWidget {
  const _BabyFormSheet({this.editBaby, this.familyId});

  final Baby? editBaby;
  final String? familyId;

  @override
  ConsumerState<_BabyFormSheet> createState() => _BabyFormSheetState();
}

class _BabyFormSheetState extends ConsumerState<_BabyFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _weightController;
  DateTime? _birthDate;
  String? _gender;
  File? _imageFile;

  static final _dateFormat = DateFormat('yyyy년 MM월 dd일');

  @override
  void initState() {
    super.initState();
    final b = widget.editBaby;
    _nameController = TextEditingController(text: b?.name ?? '');
    _weightController = TextEditingController(
      text: b?.weightKg != null ? b!.weightKg!.toString() : '',
    );
    _birthDate = b?.birthDate;
    _gender = b?.gender;
  }

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
      firstDate: DateTime(now.year - 5),
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
    final notifier = ref.read(babyManageNotifierProvider.notifier);
    final repo = ref.read(babyRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);

    String? photoUrl = widget.editBaby?.photoUrl;
    if (_imageFile != null) {
      final babyId = widget.editBaby?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
      photoUrl = await repo.uploadBabyPhoto(babyId, _imageFile!);
    }

    if (widget.editBaby != null) {
      await notifier.updateBaby(
        id: widget.editBaby!.id,
        name: _nameController.text.trim(),
        birthDate: _birthDate!,
        gender: _gender,
        weightKg: weightKg,
        photoUrl: photoUrl,
      );
    } else {
      if (widget.familyId == null) {
        messenger.showSnackBar(
          const SnackBar(content: Text('가족 정보를 찾을 수 없습니다')),
        );
        return;
      }
      await notifier.addBaby(
        familyId: widget.familyId!,
        name: _nameController.text.trim(),
        birthDate: _birthDate!,
        gender: _gender,
        weightKg: weightKg,
        photoUrl: photoUrl,
      );
    }

    if (!mounted) return;
    final state = ref.read(babyManageNotifierProvider);
    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장 실패: ${state.error}')),
      );
    } else {
      Navigator.of(context).pop();
    }
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

  @override
  Widget build(BuildContext context) {
    final isLoading =
        ref.watch(babyManageNotifierProvider).isLoading;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pagePadding,
        AppSpacing.lg,
        AppSpacing.pagePadding,
        AppSpacing.xl,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 프로필 사진
            Center(
              child: BabyAvatarWidget(
                photoUrl: widget.editBaby?.photoUrl,
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

            // 이름
            Text('아기 이름 *',
                style: AppTypography.labelLarge
                    .copyWith(color: AppColors.onSurface)),
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
            Text('생년월일 *',
                style: AppTypography.labelLarge
                    .copyWith(color: AppColors.onSurface)),
            const SizedBox(height: AppSpacing.sm),
            GestureDetector(
              onTap: _pickBirthDate,
              child: Container(
                height: 52,
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
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

            // 성별
            Text('성별 (선택)',
                style: AppTypography.labelLarge
                    .copyWith(color: AppColors.onSurface)),
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

            // 체중
            Text('현재 체중 kg (선택)',
                style: AppTypography.labelLarge
                    .copyWith(color: AppColors.onSurface)),
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
                    : Text(widget.editBaby != null ? '수정하기' : '추가하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
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
