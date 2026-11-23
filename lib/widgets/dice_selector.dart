import 'package:flutter/material.dart';

import '../data/dice_types.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Горизонтальный ряд чипов выбора кубика. Заменяет стрелки «назад/вперёд»:
/// пользователь видит весь набор и попадает в цель одним тапом.
class DiceSelector extends StatelessWidget {
  const DiceSelector({super.key, required this.sides, required this.onChanged});

  final int sides;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        for (final int value in diceTypes)
          _DiceChip(
            value: value,
            selected: value == sides,
            onTap: () => onChanged(value),
          ),
      ],
    );
  }
}

class _DiceChip extends StatelessWidget {
  const _DiceChip({
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final int value;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: 'Кубик D$value',
      child: Material(
        color: selected ? AppColors.accentSoft : Colors.transparent,
        borderRadius: AppRadii.allSm,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadii.allSm,
          splashColor: AppColors.accentSoft,
          highlightColor: AppColors.accentSoft,
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: AppRadii.allSm,
              border: Border.all(
                color: selected ? AppColors.accentLine : AppColors.divider,
                width: 0.5,
              ),
            ),
            child: Text(
              'D$value',
              style: AppTypography.labelLarge.copyWith(
                color: selected ? AppColors.accent : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
