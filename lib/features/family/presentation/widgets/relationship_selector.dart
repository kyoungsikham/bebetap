import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/extensions/l10n_ext.dart';
import '../../../../l10n/app_localizations.dart';

const kRelationshipPresets = [
  '엄마',
  '아빠',
  '할머니',
  '할아버지',
  '이모',
  '삼촌',
  '고모',
  '외삼촌',
];

String _localizedPreset(String preset, AppLocalizations l10n) {
  return switch (preset) {
    '엄마' => l10n.relationMom,
    '아빠' => l10n.relationDad,
    '할머니' => l10n.relationGrandma,
    '할아버지' => l10n.relationGrandpa,
    '이모' => l10n.relationAunt,
    '삼촌' => l10n.relationUncle,
    '고모' => l10n.relationPaternalAunt,
    '외삼촌' => l10n.relationMaternalUncle,
    _ => preset,
  };
}

class RelationshipSelector extends StatefulWidget {
  const RelationshipSelector({
    super.key,
    this.selected,
    required this.onChanged,
  });

  final String? selected;
  final ValueChanged<String?> onChanged;

  @override
  State<RelationshipSelector> createState() => _RelationshipSelectorState();
}

class _RelationshipSelectorState extends State<RelationshipSelector> {
  final _customController = TextEditingController();
  bool _isCustom = false;

  @override
  void initState() {
    super.initState();
    if (widget.selected != null && !kRelationshipPresets.contains(widget.selected)) {
      _isCustom = true;
      _customController.text = widget.selected!;
    }
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  bool _isSelected(String preset) =>
      !_isCustom && widget.selected == preset;

  void _selectPreset(String preset) {
    setState(() => _isCustom = false);
    widget.onChanged(preset);
  }

  void _toggleCustom() {
    setState(() {
      _isCustom = !_isCustom;
      if (!_isCustom) {
        _customController.clear();
        widget.onChanged(null);
      } else {
        widget.onChanged(_customController.text.isEmpty ? null : _customController.text);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            ...kRelationshipPresets.map((preset) => _Chip(
                  label: _localizedPreset(preset, l10n),
                  selected: _isSelected(preset),
                  onTap: () => _selectPreset(preset),
                )),
            _Chip(
              label: l10n.relationCustom,
              selected: _isCustom,
              onTap: _toggleCustom,
            ),
          ],
        ),
        if (_isCustom) ...[
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _customController,
            onChanged: (v) => widget.onChanged(v.trim().isEmpty ? null : v.trim()),
            decoration: InputDecoration(
              hintText: l10n.relationCustomHint,
              hintStyle: AppTypography.bodyMedium.copyWith(
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
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
            ),
            style: AppTypography.bodyLarge,
          ),
        ],
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: selected ? AppColors.onPrimary : AppColors.onSurface,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
