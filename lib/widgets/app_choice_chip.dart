import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Чип одиночного выбора: класс, раса, подраса.
///
/// Один вид на весь проект: выбранный — акцентная заливка `accentSoft` и
/// обводка `accentLine`, остальные — только обводка `divider`.
class AppChoiceChip extends StatelessWidget {
  const AppChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.enabled = true,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final Color textColor = selected
        ? AppColors.accent
        : (enabled ? AppColors.textSecondary : AppColors.textMuted);

    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      child: Material(
        color: selected ? AppColors.accentSoft : Colors.transparent,
        borderRadius: AppRadii.allSm,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: AppRadii.allSm,
          splashColor: AppColors.divider,
          highlightColor: AppColors.divider,
          child: Container(
            height: AppSpacing.huge,
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
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodyLarge.copyWith(color: textColor),
            ),
          ),
        ),
      ),
    );
  }
}

/// Ряд чипов с переносом. Общий для всех справочников: классы, расы, подрасы.
class ChoiceChipWrap<T> extends StatelessWidget {
  const ChoiceChipWrap({
    super.key,
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.onSelected,
    this.isEnabled,
    this.isSelected,
  });

  final List<T> values;
  final T? selected;
  final String Function(T value) labelOf;
  final ValueChanged<T> onSelected;

  /// `null` — все чипы активны. Иначе, например, Харизма у полуэльфа
  /// заблокирована: +2 к ней уже есть.
  final bool Function(T value)? isEnabled;

  /// Мультивыбор: набор выбранных значений вместо одного. Если задан, `selected`
  /// не используется.
  final bool Function(T value)? isSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: <Widget>[
        for (final T value in values)
          AppChoiceChip(
            label: labelOf(value),
            selected: isSelected?.call(value) ?? selected == value,
            enabled: isEnabled?.call(value) ?? true,
            onTap: () => onSelected(value),
          ),
      ],
    );
  }
}
