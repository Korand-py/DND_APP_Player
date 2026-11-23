import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/dice_shape.dart';

/// ЛАБОРАТОРИЯ, вариант B: результат в карточке, кубик уменьшен и сдвинут.
///
/// Идея: освободить центр экрана под историю бросков — карточка живёт в
/// списке и не перерисовывается целиком. Число остаётся только внутри
/// кубика: два экземпляра одного числа на одном экране — уже дефект.
/// Минус: кубик теряет роль главного элемента композиции.
///
/// Файл одноразовый: выбран вариант — код переезжает в `lib/widgets/`,
/// остальные файлы лаборатории удаляются.
class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.sides,
    required this.result,
    this.breakdown = '',
    this.count = 1,
  });

  final int sides;
  final int result;
  final String breakdown;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: AppRadii.allMd,
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Row(
        children: [
          SizedBox(
            width: AppSpacing.massive * 1.5,
            height: AppSpacing.massive * 1.5,
            child: FittedBox(
              fit: BoxFit.contain,
              child: DiceShape(sides: sides, result: result),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'D$sides · ${_rollsLabel(count)}',
                  style: AppTypography.labelSmall.copyWith(letterSpacing: 1.2),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  breakdown.isEmpty ? 'Один бросок' : breakdown,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// «1 бросок» / «3 броска». Русский счёт — не английский `1 rolls`.
String _rollsLabel(int count) {
  final int mod10 = count % 10;
  final int mod100 = count % 100;
  if (mod10 == 1 && mod100 != 11) return '$count бросок';
  if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
    return '$count броска';
  }
  return '$count бросков';
}
