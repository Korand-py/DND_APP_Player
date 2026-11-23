import 'package:flutter/material.dart';

import '../features/character/domain/ability.dart';
import '../features/character/domain/character.dart';
import '../features/character/domain/character_rules.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Выбор характеристики активного персонажа.
class SpecificationsSelector extends StatelessWidget {
  const SpecificationsSelector({
    super.key,
    required this.selected,
    required this.character,
    required this.onChanged,
  });

  final Ability selected;
  final Character character;
  final ValueChanged<Ability> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: <Widget>[
        for (final Ability ability in Ability.values)
          _AbilityChip(
            ability: ability,
            score: character.scores[ability],
            modifier: character.modifier(ability),
            selected: ability == selected,
            onTap: () => onChanged(ability),
          ),
      ],
    );
  }
}

class _AbilityChip extends StatelessWidget {
  const _AbilityChip({
    required this.ability,
    required this.score,
    required this.modifier,
    required this.selected,
    required this.onTap,
  });

  final Ability ability;
  final int score;
  final int modifier;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String signed = CharacterRules.signed(modifier);

    return Semantics(
      button: true,
      selected: selected,
      label: '${ability.label}: $score, модификатор $signed',
      child: Material(
        color: selected ? AppColors.accentSoft : Colors.transparent,
        borderRadius: AppRadii.allSm,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadii.allSm,
          splashColor: AppColors.accentSoft,
          highlightColor: AppColors.accentSoft,
          child: Container(
            constraints: const BoxConstraints(minHeight: 56),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              borderRadius: AppRadii.allSm,
              border: Border.all(
                color: selected ? AppColors.accentLine : AppColors.divider,
                width: 0.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  ability.shortLabel,
                  style: AppTypography.labelSmall.copyWith(
                    color: selected ? AppColors.accent : AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  '$score  $signed',
                  style: AppTypography.labelLarge.copyWith(
                    color: selected ? AppColors.textPrimary : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
