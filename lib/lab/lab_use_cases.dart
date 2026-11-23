import 'package:dice_roller/data/dice_types.dart';
import 'package:dice_roller/lab/result_card.dart';
import 'package:dice_roller/lab/result_hero.dart';
import 'package:dice_roller/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// Лаборатория: варианты одного блока, собранные подряд для сравнения.
///
/// Правило: сюда попадают варианты, а не готовая продуктовая вёрстка.
/// Выбранный вариант переезжает в `lib/widgets/`, папка `lib/lab/`
/// удаляется целиком — мёртвых файлов в проекте не остаётся.

@widgetbook.UseCase(
  name: 'A · герой-число',
  type: ResultHero,
  path: '[Лаборатория]',
)
Widget resultHeroUseCase(BuildContext context) {
  final int sides = _sidesKnob(context);

  return Center(
    child: ResultHero(
      sides: sides,
      result: _resultKnob(context, sides),
      breakdown: '8 + 9',
    ),
  );
}

@widgetbook.UseCase(
  name: 'B · карточка',
  type: ResultCard,
  path: '[Лаборатория]',
)
Widget resultCardUseCase(BuildContext context) {
  final int sides = _sidesKnob(context);
  final int count = context.knobs.int.slider(
    label: 'Бросков',
    initialValue: 2,
    min: 1,
    max: 10,
  );

  return Center(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: ResultCard(
        sides: sides,
        result: _resultKnob(context, sides),
        breakdown: '8 + 9',
        count: count,
      ),
    ),
  );
}

int _sidesKnob(BuildContext context) {
  return context.knobs.object.dropdown<int>(
    label: 'Кубик',
    options: diceTypes,
    initialOption: 20,
    labelBuilder: (int value) => 'D$value',
  );
}

int _resultKnob(BuildContext context, int sides) {
  final int raw = context.knobs.int.slider(
    label: 'Результат',
    initialValue: 17,
    min: 0,
    max: 100,
  );
  return raw.clamp(0, sides);
}
