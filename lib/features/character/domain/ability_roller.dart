import 'dart:math';

import 'ability.dart';
import 'ability_scores.dart';

/// Результат одного броска характеристики: 4d6 с отброшенной младшей костью.
class AbilityRoll {
  const AbilityRoll({required this.dice, required this.total});

  /// Все четыре кости, включая отброшенную: игрок должен видеть, что выпало.
  final List<int> dice;

  /// Сумма трёх старших.
  final int total;

  /// Младшая кость. Если минимум выпал дважды, отбрасывается один экземпляр —
  /// на сумму это не влияет.
  int get dropped => dice.reduce((int a, int b) => a < b ? a : b);

  @override
  String toString() => 'AbilityRoll($dice → $total)';
}

/// Шесть бросков сразу, по одному на характеристику.
class AbilityRolls {
  const AbilityRolls(this.byAbility);

  final Map<Ability, AbilityRoll> byAbility;

  AbilityRoll operator [](Ability ability) => byAbility[ability]!;

  /// Голые значения без расовых бонусов: бонусы применяет [CharacterDraft],
  /// а не бросок. Иначе переключение расы не пересчитало бы характеристики.
  AbilityScores get scores => AbilityScores(
    strength: byAbility[Ability.strength]!.total,
    dexterity: byAbility[Ability.dexterity]!.total,
    constitution: byAbility[Ability.constitution]!.total,
    intelligence: byAbility[Ability.intelligence]!.total,
    wisdom: byAbility[Ability.wisdom]!.total,
    charisma: byAbility[Ability.charisma]!.total,
  );
}

/// Генератор характеристик методом «4d6, отбросить младшую».
///
/// [Random] передаётся снаружи: без этого тест не может проверить границы и
/// распределение, а «случайность» остаётся непроверяемой.
class AbilityRoller {
  AbilityRoller({Random? random}) : _random = random ?? Random();

  final Random _random;

  static const int diceCount = 4;
  static const int dieSides = 6;

  /// Минимум и максимум суммы: три единицы и три шестёрки.
  static const int minTotal = 3;
  static const int maxTotal = 18;

  AbilityRoll rollOne() {
    final List<int> dice = <int>[
      for (int i = 0; i < diceCount; i++) _random.nextInt(dieSides) + 1,
    ];

    final List<int> sorted = <int>[...dice]..sort();
    final int total = sorted.skip(1).fold(0, (int sum, int die) => sum + die);

    return AbilityRoll(dice: List<int>.unmodifiable(dice), total: total);
  }

  AbilityRolls rollAll() => AbilityRolls(<Ability, AbilityRoll>{
    for (final Ability ability in Ability.values) ability: rollOne(),
  });
}
