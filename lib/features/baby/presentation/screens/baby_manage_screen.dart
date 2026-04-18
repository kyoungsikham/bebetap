import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/config/ad_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/providers/interstitial_ad_provider.dart';
import '../../../../shared/widgets/banner_ad_widget.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/extensions/l10n_ext.dart';
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(context.l10n.babyManageTitle, style: AppTypography.titleLarge),
      ),
      body: babiesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            context.l10n.loadFailed(e.toString()),
            style: AppTypography.bodyMedium.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.55)),
          ),
        ),
        data: (babies) => _BabyManageBody(babies: babies),
      ),
    );
  }
}

class _BabyManageBody extends ConsumerWidget {
  const _BabyManageBody({required this.babies});

  final List<Baby> babies;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (babies.isNotEmpty) ...[
            Text(context.l10n.registeredBabies, style: AppTypography.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            ...babies.asMap().entries.map((e) => _BabyListTile(baby: e.value, colorIndex: e.key)),
            const SizedBox(height: AppSpacing.xl),
            const Divider(),
            const SizedBox(height: AppSpacing.xl),
          ],
          ElevatedButton.icon(
            onPressed: () => _openForm(context, ref, babies, null, colorIndex: babies.length),
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
            label: Text(context.l10n.addNewBaby),
          ),
          const SizedBox(height: AppSpacing.lg),
          BannerAdWidget(adUnitId: AdConfig.babyManageBannerId),
        ],
      ),
    );
  }

  Future<void> _openForm(
    BuildContext context,
    WidgetRef ref,
    List<Baby> babies,
    Baby? editBaby, {
    int? colorIndex,
  }) async {
    final familyId = babies.isNotEmpty ? babies.first.familyId : null;
    await showAppBottomSheet(
      context: context,
      title: editBaby != null ? context.l10n.babyEditTitle : context.l10n.babyAddTitle,
      child: _BabyFormSheet(editBaby: editBaby, familyId: familyId, colorIndex: colorIndex),
    );
    // 새 아기 추가 완료 후 인터스티셜 표시 (편집은 제외)
    if (editBaby == null) {
      await ref.read(interstitialAdProvider).showIfReady();
    }
  }
}

class _BabyListTile extends ConsumerWidget {
  const _BabyListTile({required this.baby, required this.colorIndex});

  final Baby baby;
  final int colorIndex;

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
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Theme.of(context).dividerColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: ListTile(
          leading: BabyAvatarWidget(
            photoUrl: baby.photoUrl,
            gender: baby.gender,
            colorIndex: colorIndex,
            size: 44,
          ),
          title: Text(baby.name, style: AppTypography.bodyLarge),
          subtitle: Text(
            DateFormat(context.l10n.dateFormat).format(baby.birthDate),
            style: AppTypography.bodySmall
                .copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55)),
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
                  title: context.l10n.babyEditTitle,
                  child: _BabyFormSheet(editBaby: baby, familyId: baby.familyId, colorIndex: colorIndex),
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
  const _BabyFormSheet({this.editBaby, this.familyId, this.colorIndex});

  final Baby? editBaby;
  final String? familyId;
  final int? colorIndex;

  @override
  ConsumerState<_BabyFormSheet> createState() => _BabyFormSheetState();
}

class _BabyFormSheetState extends ConsumerState<_BabyFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _weightController;
  late final TextEditingController _heightController;
  DateTime? _birthDate;
  String? _gender;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    final b = widget.editBaby;
    _nameController = TextEditingController(text: b?.name ?? '');
    _weightController = TextEditingController(
      text: b?.weightKg != null ? b!.weightKg!.toString() : '',
    );
    _heightController = TextEditingController(
      text: b?.heightCm != null ? b!.heightCm!.toString() : '',
    );
    _birthDate = b?.birthDate;
    _gender = b?.gender;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (picked == null || !mounted) return;

      // 캐시 디렉토리에 복사하여 파일 경로 안정성 확보 (Android 실기기 크래시 방지)
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
        '${tempDir.path}/pick_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await File(picked.path).copy(tempFile.path);

      if (!mounted) return;

      final photoSelectLabel = context.l10n.photoSelect;
      final primaryColor = Theme.of(context).colorScheme.primary;

      CroppedFile? cropped;
      try {
        cropped = await ImageCropper().cropImage(
          sourcePath: tempFile.path,
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
          maxWidth: 512,
          maxHeight: 512,
          compressQuality: 85,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: photoSelectLabel,
              toolbarColor: primaryColor,
              toolbarWidgetColor: Colors.white,
              lockAspectRatio: true,
              cropStyle: CropStyle.circle,
            ),
            IOSUiSettings(
              title: photoSelectLabel,
              aspectRatioLockEnabled: true,
              resetAspectRatioEnabled: false,
              cropStyle: CropStyle.circle,
            ),
          ],
        );
      } catch (_) {
        // crop 실패 시 원본 이미지를 fallback으로 사용
      }

      if (!mounted) return;
      setState(() {
        _imageFile = cropped != null ? File(cropped.path) : tempFile;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.saveFailed(e.toString()))),
        );
      }
    }
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? now,
      firstDate: DateTime(now.year - 5),
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

    final weightText = _weightController.text.trim();
    final weightKg =
        weightText.isNotEmpty ? double.tryParse(weightText) : null;
    final heightText = _heightController.text.trim();
    final heightCm =
        heightText.isNotEmpty ? double.tryParse(heightText) : null;
    final notifier = ref.read(babyManageNotifierProvider.notifier);
    final repo = ref.read(babyRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;

    String? photoUrl = widget.editBaby?.photoUrl;
    if (_imageFile != null) {
      final babyId = widget.editBaby?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
      try {
        photoUrl = await repo.uploadBabyPhoto(babyId, _imageFile!);
      } catch (e) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.saveFailed(e.toString()))),
        );
        return;
      }
    }

    if (widget.editBaby != null) {
      await notifier.updateBaby(
        id: widget.editBaby!.id,
        name: _nameController.text.trim(),
        birthDate: _birthDate!,
        gender: _gender,
        weightKg: weightKg,
        heightCm: heightCm,
        photoUrl: photoUrl,
      );
    } else {
      if (widget.familyId == null) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.noFamilyFound)),
        );
        return;
      }
      await notifier.addBaby(
        familyId: widget.familyId!,
        name: _nameController.text.trim(),
        birthDate: _birthDate!,
        gender: _gender,
        weightKg: weightKg,
        heightCm: heightCm,
        photoUrl: photoUrl,
      );
    }

    if (!mounted) return;
    final state = ref.read(babyManageNotifierProvider);
    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.saveFailed(state.error.toString()))),
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  InputDecoration _inputDecoration(String hint) {
    final cs = Theme.of(context).colorScheme;
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTypography.bodyMedium.copyWith(
        color: cs.onSurface.withValues(alpha: 0.55),
      ),
      filled: true,
      fillColor: cs.surfaceContainerHighest,
      contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).dividerColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).dividerColor),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: AppColors.error, width: 1.5),
      ),
    );
  }

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
                colorIndex: widget.colorIndex,
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
                    .copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55)),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // 이름
            Text(context.l10n.babyName,
                style: AppTypography.labelLarge.copyWith(
                    color: Theme.of(context).colorScheme.onSurface)),
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
            Text(context.l10n.birthDate,
                style: AppTypography.labelLarge.copyWith(
                    color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: AppSpacing.sm),
            GestureDetector(
              onTap: _pickBirthDate,
              child: Container(
                height: 52,
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                alignment: Alignment.centerLeft,
                child: Text(
                  _birthDate != null
                      ? DateFormat(context.l10n.dateFormat).format(_birthDate!)
                      : context.l10n.selectBirthDate,
                  style: AppTypography.bodyMedium.copyWith(
                    color: _birthDate != null
                        ? Theme.of(context).colorScheme.onSurface
                        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // 성별
            Text(context.l10n.genderOptional,
                style: AppTypography.labelLarge.copyWith(
                    color: Theme.of(context).colorScheme.onSurface)),
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

            // 체중
            Text(context.l10n.currentWeight,
                style: AppTypography.labelLarge.copyWith(
                    color: Theme.of(context).colorScheme.onSurface)),
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
            const SizedBox(height: AppSpacing.xl),

            // 키
            Text(context.l10n.currentHeight,
                style: AppTypography.labelLarge.copyWith(
                    color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _heightController,
              decoration: _inputDecoration(context.l10n.heightHint),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;
                final parsed = double.tryParse(v.trim());
                if (parsed == null || parsed <= 0 || parsed > 150) {
                  return context.l10n.invalidHeight;
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
                    : Text(widget.editBaby != null ? context.l10n.editButton : context.l10n.addButton),
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
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : Theme.of(context).dividerColor,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: selected
                    ? AppColors.primary
                    : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
                size: 20),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: AppTypography.labelLarge.copyWith(
                color: selected
                    ? AppColors.primary
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
