import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Твой рабочий файл: каталог рендерит его как use case «Песочница».
///
/// Цикл: правишь здесь → сохраняешь → hot reload → смотришь в каталоге.
/// Меняешь структуру `build` или поля класса — жми `R` (hot restart).
///
/// Токены уже подключены: `AppColors`, `AppSpacing`, `AppRadii`,
/// `AppTypography`. Других цветов и отступов не бывает.
class Playground extends StatelessWidget {
  const Playground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: AppRadii.allMd,
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Пустая карточка', style: AppTypography.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Замени содержимое на своё. Каркас из токенов можно оставить.',
            style: AppTypography.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          const Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              _Tag('AppColors.surface1'),
              _Tag('AppRadii.md'),
              _Tag('AppSpacing.lg'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: AppRadii.allSm,
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Text(label, style: AppTypography.labelSmall),
    );
  }
}
