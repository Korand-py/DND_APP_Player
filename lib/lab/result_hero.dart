import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// ЛАБОРАТОРИЯ, вариант A: результат как типографический герой.
///
/// Идея: убрать кубик из центра, оставить число и подпись. Число читается
/// за один взгляд, декора нет. Минус: пропадает ощущение броска.
///
/// Файл одноразовый: выбран вариант — код переезжает в `lib/widgets/`,
/// остальные файлы лаборатории удаляются.
class ResultHero extends StatelessWidget {
  const ResultHero({
    super.key,
    required this.sides,
    required this.result,
    this.breakdown = '',
  });

  final int sides;
  final int result;
  final String breakdown;

  bool get _isEmpty => result == 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Caption(sides: sides, result: result),
        const SizedBox(height: AppSpacing.md),
        Text(
          _isEmpty ? '—' : '$result',
          style: AppTypography.displayHero.copyWith(
            color: _isEmpty ? AppColors.textMuted : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          width: AppSpacing.xxl,
          height: 1,
          color: _isEmpty ? AppColors.divider : AppColors.accent,
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 20,
          child: Text(breakdown, style: AppTypography.bodyMedium),
        ),
      ],
    );
  }
}

/// Подпись: что бросали и сколько. Одна строка вместо трёх элементов.
class _Caption extends StatelessWidget {
  const _Caption({required this.sides, required this.result});

  final int sides;
  final int result;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: result == 0 ? AppColors.textMuted : AppColors.accent,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          'D$sides',
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}
