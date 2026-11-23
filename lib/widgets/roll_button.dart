import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Основное действие экрана. Одна кнопка на экран, полная ширина.
///
/// [label] переопределяет подпись: на экране характеристик та же кнопка
/// уводит на бросок, а не бросает кубик здесь.
class RollButton extends StatelessWidget {
  const RollButton({
    super.key,
    required this.onPressed,
    this.label = 'Бросить',
  });

  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          textStyle: AppTypography.titleMedium.copyWith(
            color: AppColors.onAccent,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}
