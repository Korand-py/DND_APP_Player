import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Карточка модификатора выбранной характеристики.
///
/// Показывает одно число и то, к чему оно применяется: в D&D модификатор не
/// живёт сам по себе, он всегда часть броска d20. Поэтому рядом с «+2» стоит
/// «к броску d20», а не пустая подпись.
class ModifierCard extends StatelessWidget {
  const ModifierCard({super.key, required this.title, required this.modifier});

  /// Название характеристики: «Ловкость», «Сила»…
  final String title;

  /// Модификатор характеристики. Может быть отрицательным.
  final int modifier;
  Color get color => modifier > 0 ? AppColors.success : AppColors.error;

  /// Знак обязателен: «2» читается как значение характеристики, «+2» — как
  /// модификатор. В D&D это разные числа, путать их нельзя.
  String get _signed => modifier >= 0 ? '+$modifier' : '$modifier';

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Модификатор $title: $_signed',
      child: Container(
        padding: AppSpacing.card,
        decoration: const BoxDecoration(
          color: AppColors.surface1,
          borderRadius: AppRadii.allMd,
          border: Border.fromBorderSide(
            BorderSide(color: AppColors.divider, width: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'МОДИФИКАТОР',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textMuted,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                // Expanded, а не Spacer: длинное «Телосложение» на 320 px
                // иначе вылезет за карточку.
                Expanded(
                  child: Text(
                    title,
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  _signed,
                  style: AppTypography.displayMedium.copyWith(color: color),
                ),
                const SizedBox(width: AppSpacing.sm),
                Flexible(
                  child: Text(
                    'к броску',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
