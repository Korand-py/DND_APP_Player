import 'package:dice_roller/data/dice_types.dart';
import 'package:dice_roller/dev/playground.dart';
import 'package:dice_roller/features/character/domain/ability.dart';
import 'package:dice_roller/features/character/domain/ability_roller.dart';
import 'package:dice_roller/features/character/domain/ability_scores.dart';
import 'package:dice_roller/features/character/domain/character.dart';
import 'package:dice_roller/features/character/domain/character_rules.dart';
import 'package:dice_roller/features/character/domain/dnd_class.dart';
import 'package:dice_roller/features/character/domain/race.dart';
import 'package:dice_roller/features/character/presentation/widgets/ability_roll_tile.dart';
import 'package:dice_roller/features/character/presentation/widgets/character_tile.dart';
import 'package:dice_roller/widgets/app_choice_chip.dart';
import 'package:dice_roller/widgets/count_stepper.dart';
import 'package:dice_roller/widgets/dice_selector.dart';
import 'package:dice_roller/widgets/dice_shape.dart';
import 'package:dice_roller/widgets/modifier_card.dart';
import 'package:dice_roller/widgets/roll_button.dart';
import 'package:dice_roller/widgets/section_label.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'Кнопка броска',
  type: RollButton,
  path: '[Компоненты]/Кнопки',
)
Widget rollButtonUseCase(BuildContext context) {
  final String label = context.knobs.string(
    label: 'Подпись',
    initialValue: 'Бросить',
  );

  return RollButton(label: label, onPressed: () {});
}

@widgetbook.UseCase(
  name: 'Выбор кубика',
  type: DiceSelector,
  path: '[Компоненты]',
)
Widget diceSelectorUseCase(BuildContext context) {
  final int sides = context.knobs.object.dropdown<int>(
    label: 'Кубик',
    options: diceTypes,
    initialOption: 20,
    labelBuilder: (int value) => 'D$value',
  );

  return _SelectorDemo(sides: sides);
}

@widgetbook.UseCase(name: 'Счётчик', type: CountStepper, path: '[Компоненты]')
Widget countStepperUseCase(BuildContext context) {
  final int count = context.knobs.int.slider(
    label: 'Количество',
    initialValue: 1,
    min: 1,
    max: 100,
  );

  return _StepperDemo(count: count);
}

@widgetbook.UseCase(name: 'Кубик', type: DiceShape, path: '[Компоненты]')
Widget diceShapeUseCase(BuildContext context) {
  final int sides = context.knobs.object.dropdown<int>(
    label: 'Грани',
    options: diceTypes,
    initialOption: 20,
    labelBuilder: (int value) => 'D$value',
  );
  final int raw = context.knobs.int.slider(
    label: 'Результат',
    initialValue: 17,
    min: 0,
    max: 100,
  );

  return DiceShape(sides: sides, result: raw.clamp(0, sides));
}

@widgetbook.UseCase(
  name: 'Карточка модификатора',
  type: ModifierCard,
  path: '[Компоненты]',
)
Widget modifierCardUseCase(BuildContext context) {
  // Характеристики берём из реального справочника: в каталоге должно быть
  // видно, как карточка ведёт себя на длинном «Телосложение» и на отрицательном
  // модификаторе, а не только на демо-строке.
  final String specification = context.knobs.object.dropdown<String>(
    label: 'Характеристика',
    options: specificationsList,
    initialOption: specificationsList.first,
  );

  return ModifierCard(
    title: specification,
    modifier: specifications[specification]!.$2,
  );
}

@widgetbook.UseCase(name: 'Песочница', type: Playground, path: '[Песочница]')
Widget playgroundUseCase(BuildContext context) {
  return const Playground();
}

@widgetbook.UseCase(
  name: 'Чип выбора',
  type: AppChoiceChip,
  path: '[Компоненты]/Формы',
)
Widget appChoiceChipUseCase(BuildContext context) {
  final String label = context.knobs.string(
    label: 'Подпись',
    initialValue: 'Дварф',
  );
  final bool selected = context.knobs.boolean(
    label: 'Выбран',
    initialValue: true,
  );
  final bool enabled = context.knobs.boolean(
    label: 'Доступен',
    initialValue: true,
  );

  return AppChoiceChip(
    label: label,
    selected: selected,
    enabled: enabled,
    onTap: () {},
  );
}

@widgetbook.UseCase(
  name: 'Подпись группы',
  type: SectionLabel,
  path: '[Компоненты]',
)
Widget sectionLabelUseCase(BuildContext context) {
  final String text = context.knobs.string(
    label: 'Текст',
    initialValue: 'Характеристики',
  );

  return SectionLabel(text, trailing: const Text('справа'));
}

@widgetbook.UseCase(
  name: 'Плитка характеристики',
  type: AbilityRollTile,
  path: '[Компоненты]/Персонаж',
)
Widget abilityRollTileUseCase(BuildContext context) {
  final Ability ability = context.knobs.object.dropdown<Ability>(
    label: 'Характеристика',
    options: Ability.values,
    initialOption: Ability.strength,
    labelBuilder: (Ability value) => value.label,
  );
  final int total = context.knobs.int.slider(
    label: 'Выпало',
    initialValue: 14,
    min: AbilityRoller.minTotal,
    max: AbilityRoller.maxTotal,
  );

  return SizedBox(
    width: 220,
    child: AbilityRollTile(
      ability: ability,
      roll: AbilityRoll(dice: const <int>[6, 5, 3, 1], total: total),
      modifier: CharacterRules.abilityModifier(total),
    ),
  );
}

@widgetbook.UseCase(
  name: 'Строка персонажа',
  type: CharacterTile,
  path: '[Компоненты]/Персонаж',
)
Widget characterTileUseCase(BuildContext context) {
  // Данные фиксированные: в каталоге важно, как строка ведёт себя на длинном
  // «Драконорождённый» и на двузначных хитах, а не на случайном персонаже.
  final Character character = Character(
    name: context.knobs.string(
      label: 'Имя',
      initialValue: 'Торин Каменный Щит',
    ),
    dndClass: DndClass.fighter,
    subclass: DndClass.fighter.subclasses.first,
    race: Races.dwarf,
    subrace: Races.dwarf.subraces.last,
    level: 1,
    scores: const AbilityScores(
      strength: 16,
      dexterity: 12,
      constitution: 15,
      intelligence: 8,
      wisdom: 10,
      charisma: 9,
    ),
    createdAt: DateTime(2026),
  );

  return CharacterTile(character: character, onTap: () {});
}

/// Выбор кубика хранит последний тап, но сбрасывается при смене knob.
class _SelectorDemo extends StatefulWidget {
  const _SelectorDemo({required this.sides});

  final int sides;

  @override
  State<_SelectorDemo> createState() => _SelectorDemoState();
}

class _SelectorDemoState extends State<_SelectorDemo> {
  int? _picked;

  @override
  void didUpdateWidget(covariant _SelectorDemo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sides != widget.sides) _picked = null;
  }

  @override
  Widget build(BuildContext context) {
    return DiceSelector(
      sides: _picked ?? widget.sides,
      onChanged: (int value) => setState(() => _picked = value),
    );
  }
}

/// Счётчик живёт с собственным контроллером, knob задаёт стартовое значение.
class _StepperDemo extends StatefulWidget {
  const _StepperDemo({required this.count});

  final int count;

  @override
  State<_StepperDemo> createState() => _StepperDemoState();
}

class _StepperDemoState extends State<_StepperDemo> {
  late final TextEditingController _controller = TextEditingController(
    text: '${widget.count}',
  );
  late int _count = widget.count;

  @override
  void didUpdateWidget(covariant _StepperDemo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.count != widget.count) _apply(widget.count);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _apply(int value) {
    final int next = value.clamp(1, 100);
    setState(() => _count = next);
    _controller.text = '$next';
    _controller.selection = TextSelection.collapsed(
      offset: _controller.text.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CountStepper(
      controller: _controller,
      onDecrement: () => _apply(_count - 1),
      onIncrement: () => _apply(_count + 1),
      onChanged: (String value) {
        final int? parsed = int.tryParse(value);
        if (parsed == null) return;
        setState(() => _count = parsed.clamp(1, 100));
      },
    );
  }
}
