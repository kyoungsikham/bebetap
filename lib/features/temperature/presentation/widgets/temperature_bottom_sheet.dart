import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/constants/medical_constants.dart';
import '../../../../shared/widgets/date_time_wheel_picker.dart';
import '../../../log/domain/models/timeline_entry.dart';
import '../providers/temperature_provider.dart';

class TemperatureBottomSheet extends ConsumerStatefulWidget {
  const TemperatureBottomSheet({super.key, this.editEntry});

  final TimelineEntry? editEntry;

  @override
  ConsumerState<TemperatureBottomSheet> createState() =>
      _TemperatureBottomSheetState();
}

class _TemperatureBottomSheetState
    extends ConsumerState<TemperatureBottomSheet> {
  late final TextEditingController _controller;
  late String _method;
  late DateTime _selectedDateTime;

  bool get _isEditMode => widget.editEntry != null;

  static const _methods = [
    ('axillary', '겨드랑이'),
    ('ear', '귀'),
    ('forehead', '이마'),
    ('rectal', '항문'),
  ];

  @override
  void initState() {
    super.initState();
    final edit = widget.editEntry;
    _controller = TextEditingController(
      text: edit?.rawCelsius?.toStringAsFixed(1) ?? '',
    );
    _method = edit?.rawMethod ?? 'ear';
    _selectedDateTime = edit?.occurredAt ?? DateTime.now();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDisplayDateTime(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dtDay = DateTime(dt.year, dt.month, dt.day);
    String datePart;
    if (dtDay == today) {
      datePart = '오늘';
    } else if (dtDay == yesterday) {
      datePart = '어제';
    } else {
      const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
      datePart = '${dt.month}월 ${dt.day}일 (${weekdays[dt.weekday - 1]})';
    }
    final period = dt.hour < 12 ? '오전' : '오후';
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final timePart = '$period $h:${dt.minute.toString().padLeft(2, '0')}';
    return '$datePart  $timePart';
  }

  Future<void> _pickDateTime() async {
    final result = await showDateTimeWheelPicker(
      context,
      initialDateTime: _selectedDateTime,
    );
    if (result != null && mounted) setState(() => _selectedDateTime = result);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(temperatureNotifierProvider).isLoading;
    final celsius = double.tryParse(_controller.text);
    final isFever =
        celsius != null && celsius >= MedicalConstants.feverThreshold;
    final isHighFever =
        celsius != null && celsius >= MedicalConstants.highFeverThreshold;

    Color? tempColor;
    if (isHighFever) {
      tempColor = AppColors.error;
    } else if (isFever) {
      tempColor = AppColors.warning;
    }

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

          // 날짜/시간 선택 칩 (edit 모드에서만 표시)
          if (_isEditMode) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: _pickDateTime,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.4),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _formatDisplayDateTime(_selectedDateTime),
                    style: AppTypography.bodyMedium
                        .copyWith(color: AppColors.primary),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          // 체온 입력
          TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            textAlign: TextAlign.center,
            style: AppTypography.displayLarge.copyWith(
              color: tempColor ?? AppColors.onSurface,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              hintText: '36.5',
              hintStyle: AppTypography.displayLarge.copyWith(
                color: AppColors.divider,
                fontWeight: FontWeight.w700,
              ),
              suffixText: '℃',
              suffixStyle: AppTypography.titleLarge.copyWith(
                color: tempColor ?? AppColors.onSurfaceMuted,
              ),
              border: InputBorder.none,
              filled: true,
              fillColor: isFever
                  ? (isHighFever
                      ? AppColors.error.withValues(alpha: 0.08)
                      : AppColors.warning.withValues(alpha: 0.1))
                  : AppColors.surfaceVariant,
              contentPadding: const EdgeInsets.symmetric(
                vertical: AppSpacing.lg,
                horizontal: AppSpacing.xl,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: tempColor ?? AppColors.divider,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: tempColor ?? AppColors.primary,
                  width: 1.5,
                ),
              ),
            ),
            onChanged: (_) => setState(() {}),
            autofocus: !_isEditMode,
          ),

          if (isFever) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              isHighFever ? '고열입니다. 즉시 의사에게 상담하세요.' : '미열입니다. 경과를 주의깊게 관찰하세요.',
              style: AppTypography.bodySmall.copyWith(
                color: tempColor,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],

          const SizedBox(height: AppSpacing.lg),

          // 측정 방법
          Text(
            '측정 방법',
            style:
                AppTypography.labelLarge.copyWith(color: AppColors.onSurface),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: _methods.map((m) {
              final isSelected = m.$1 == _method;
              return GestureDetector(
                onTap: () => setState(() => _method = m.$1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          isSelected ? AppColors.primary : AppColors.divider,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Text(
                    m.$2,
                    style: AppTypography.labelLarge.copyWith(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.onSurface,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: (isLoading || celsius == null)
                  ? null
                  : () async {
                      if (_isEditMode) {
                        await ref
                            .read(temperatureNotifierProvider.notifier)
                            .updateTemperature(
                              widget.editEntry!.id,
                              celsius: celsius,
                              method: _method,
                              occurredAt: _selectedDateTime,
                            );
                      } else {
                        await ref
                            .read(temperatureNotifierProvider.notifier)
                            .saveTemperature(
                              celsius: celsius,
                              method: _method,
                            );
                      }
                      if (context.mounted) Navigator.of(context).pop();
                    },
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
                  : Text(_isEditMode ? '수정' : '저장'),
            ),
          ),
        ],
      ),
    );
  }
}
