import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_typography.dart';
import '../../domain/ability.dart';
import '../../domain/ability_roller.dart';
import '../../domain/character_rules.dart';

/// Плитка характеристики на экране создания: что выпало и что это даёт.
///
/// Кости показаны целиком, включая отброшенную: игрок должен видеть бросок, а
/// не доверять числу на слово.
class AbilityRollTile extends StatelessWidget {
  const AbilityRollTile({
    super.key,
    required this.ability,
    required this.roll,
    required this.modifier,
  });

  final Ability ability;
  final AbilityRoll roll;
  final int modifier;

  @override
  Widget build(BuildContext context) {
    final String signed = CharacterRules.signed(modifier);

    return Semantics(
      label: '${ability.label}: ${roll.total}, модификатор $signed',
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.surface1,
          borderRadius: AppRadii.allMd,
          border: Border.all(color: AppColors.divider, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(ability.shortLabel, style: AppTypography.labelSmall),
                const SizedBox(width: AppSpacing.xxs),
                Expanded(
                  child: Text(
                    ability.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelSmall,
                  ),
                ),
                Text(
                  signed,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text('${roll.total}', style: AppTypography.headlineMedium),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              roll.dice.join(' · '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
