import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Счётчик количества кубиков: − [значение] +, в одной тонкой рамке.
class CountStepper extends StatelessWidget {
  const CountStepper({
    super.key,
    required this.controller,
    required this.onDecrement,
    required this.onIncrement,
    required this.onChanged,
  });

  final TextEditingController controller;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: AppRadii.allMd,
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Row(
        children: [
          _StepButton(
            icon: Icons.remove_rounded,
            label: 'Уменьшить количество',
            onTap: onDecrement,
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              textAlignVertical: TextAlignVertical.center,
              cursorColor: AppColors.accent,
              cursorWidth: 1.5,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(3),
              ],
              style: AppTypography.titleLarge,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: onChanged,
            ),
          ),
          _StepButton(
            icon: Icons.add_rounded,
            label: 'Увеличить количество',
            onTap: onIncrement,
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.allMd,
        splashColor: AppColors.accentSoft,
        highlightColor: AppColors.accentSoft,
        child: SizedBox(
          width: 56,
          height: 56,
          child: Icon(icon, color: AppColors.textSecondary, size: 22),
        ),
      ),
    );
  }
}
