import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'dice_painter.dart';

/// Кубик с результатом внутри. Результат — несущий элемент композиции.
class DiceShape extends StatelessWidget {
  const DiceShape({super.key, required this.sides, required this.result});

  final int sides;
  final int result;

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = result == 0;

    return SizedBox(
      width: 200,
      height: 200,
      child: CustomPaint(
        painter: DicePainter(sides: sides),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            switchInCurve: Curves.easeOutCubic,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.92, end: 1).animate(animation),
                child: child,
              ),
            ),
            child: Text(
              isEmpty ? '—' : '$result',
              key: ValueKey<int>(result),
              style: AppTypography.displayHero.copyWith(
                color: isEmpty ? AppColors.textMuted : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
