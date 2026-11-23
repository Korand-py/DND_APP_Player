import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_typography.dart';
import '../../domain/character.dart';

/// Строка списка персонажей: кто это и сколько у него хитов.
class CharacterTile extends StatelessWidget {
  const CharacterTile({
    super.key,
    required this.character,
    required this.onTap,
  });

  final Character character;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface1,
      borderRadius: AppRadii.allMd,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.allMd,
        splashColor: AppColors.accentSoft,
        highlightColor: AppColors.accentSoft,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: AppRadii.allMd,
            border: Border.all(color: AppColors.divider, width: 0.5),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      character.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      '${character.classLabel} · ${character.originLabel} · '
                      '${character.level} ур.',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    '${character.maxHitPoints}',
                    style: AppTypography.titleLarge,
                  ),
                  Text('ХИТЫ', style: AppTypography.labelSmall),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
