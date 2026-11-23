import 'dart:math';

import 'package:flutter/material.dart';

import '../features/character/domain/character_rules.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/count_stepper.dart';
import '../widgets/dice_selector.dart';
import '../widgets/dice_shape.dart';
import '../widgets/roll_button.dart';

class DiceScreen extends StatefulWidget {
  const DiceScreen({
    super.key,
    this.embedded = false,
    this.rollModifier,
    this.rollLabel,
    this.onClearRollContext,
  });

  /// Встроенный режим для нижнего меню: без собственного [Scaffold].
  final bool embedded;

  /// Модификатор броска (проверка/спасбросок), добавляется к сумме кубиков.
  final int? rollModifier;

  /// Подпись контекста броска, например «Ловкость · проверка».
  final String? rollLabel;

  /// Сброс контекста броска (для встроенного режима во вкладке).
  final VoidCallback? onClearRollContext;

  @override
  State<DiceScreen> createState() => _DiceScreenState();
}

class _DiceScreenState extends State<DiceScreen> {
  final Random _random = Random();
  final TextEditingController _countController = TextEditingController(
    text: '1',
  );

  int _sides = 6;
  int _count = 1;
  int _baseTotal = 0;
  String _breakdown = '';

  int get _modifier => widget.rollModifier ?? 0;
  int get _displayTotal => _baseTotal == 0 ? 0 : _baseTotal + _modifier;

  @override
  void dispose() {
    _countController.dispose();
    super.dispose();
  }

  void _selectSides(int value) {
    if (value == _sides) return;
    setState(() {
      _sides = value;
      _baseTotal = 0;
      _breakdown = '';
    });
  }

  int _clampCount(int value) => value.clamp(1, 100);

  void _changeCount(int value) {
    final int next = _clampCount(value);
    setState(() {
      _count = next;
      _countController.text = '$next';
    });
    _countController.selection = TextSelection.collapsed(
      offset: _countController.text.length,
    );
  }

  void _onCountChanged(String value) {
    final int? parsed = int.tryParse(value);
    if (parsed == null) return;

    final int clamped = _clampCount(parsed);
    if (clamped != parsed) {
      _countController.text = '$clamped';
      _countController.selection = TextSelection.collapsed(
        offset: _countController.text.length,
      );
    }

    setState(() => _count = clamped);
  }

  void _roll() {
    int total = 0;
    final List<int> rolls = <int>[];

    for (int i = 0; i < _count; i++) {
      final int roll = _random.nextInt(_sides) + 1;
      total += roll;
      rolls.add(roll);
    }

    setState(() {
      _baseTotal = total;
      _breakdown = _buildBreakdown(rolls, total);
    });
  }

  String _buildBreakdown(List<int> rolls, int total) {
    final String dicePart = rolls.length > 1 ? '${rolls.join(' + ')} = $total' : '$total';
    if (_modifier == 0) return rolls.length > 1 ? dicePart : '';
    return '$dicePart ${CharacterRules.signed(_modifier)} = ${total + _modifier}';
  }

  @override
  Widget build(BuildContext context) {
    final String? rollLabel = widget.rollLabel;

    final Widget content = SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _TopBar(
              label: rollLabel,
              modifier: widget.rollModifier,
              onClear: widget.onClearRollContext,
            ),
            const SizedBox(height: AppSpacing.xl),
            DiceSelector(sides: _sides, onChanged: _selectSides),
            Expanded(
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Semantics(
                        liveRegion: true,
                        label: _displayTotal == 0
                            ? 'Результат ещё не получен'
                            : 'Результат: $_displayTotal',
                        child: DiceShape(sides: _sides, result: _displayTotal),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      SizedBox(
                        height: AppSpacing.lg,
                        child: Text(
                          _breakdown,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Text('КОЛИЧЕСТВО', style: AppTypography.labelSmall),
            const SizedBox(height: AppSpacing.xs),
            CountStepper(
              controller: _countController,
              onDecrement: () => _changeCount(_count - 1),
              onIncrement: () => _changeCount(_count + 1),
              onChanged: _onCountChanged,
            ),
            const SizedBox(height: AppSpacing.sm),
            RollButton(onPressed: _roll),
          ],
        ),
      ),
    );

    if (widget.embedded) return content;
    return Scaffold(body: content);
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({this.label, this.modifier, this.onClear});

  final String? label;
  final int? modifier;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final String? rollLabel = label;
    return Row(
      children: <Widget>[
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: AppColors.accent,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            rollLabel ?? 'D&D DICE',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.labelSmall.copyWith(
              color:
                  rollLabel == null ? AppColors.textSecondary : AppColors.accent,
              letterSpacing: rollLabel == null ? 2 : 0.6,
            ),
          ),
        ),
        if (modifier != null) ...<Widget>[
          Text(
            CharacterRules.signed(modifier!),
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textPrimary,
              letterSpacing: 1.2,
            ),
          ),
          if (onClear != null)
            IconButton(
              onPressed: onClear,
              tooltip: 'Сбросить модификатор',
              icon: const Icon(Icons.close_rounded, size: 18),
              visualDensity: VisualDensity.compact,
            ),
        ] else
          Text(
            'SRD 5.1',
            style: AppTypography.labelSmall.copyWith(letterSpacing: 1.2),
          ),
      ],
    );
  }
}
