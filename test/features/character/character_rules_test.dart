import 'dart:math';

import 'package:dice_roller/features/character/domain/ability.dart';
import 'package:dice_roller/features/character/domain/ability_roller.dart';
import 'package:dice_roller/features/character/domain/ability_scores.dart';
import 'package:dice_roller/features/character/domain/character.dart';
import 'package:dice_roller/features/character/domain/character_rules.dart';
import 'package:dice_roller/features/character/domain/dnd_class.dart';
import 'package:dice_roller/features/character/domain/race.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Модификатор характеристики', () {
    test('чётные значения считаются по таблице', () {
      expect(CharacterRules.abilityModifier(10), 0);
      expect(CharacterRules.abilityModifier(12), 1);
      expect(CharacterRules.abilityModifier(8), -1);
      expect(CharacterRules.abilityModifier(20), 5);
      expect(CharacterRules.abilityModifier(3), -4);
    });

    test('нечётные округляются вниз, а не к нулю', () {
      // Главная ловушка: `(9 - 10) ~/ 2` в Dart даёт 0, а по правилам нужно −1.
      expect(CharacterRules.abilityModifier(9), -1);
      expect(CharacterRules.abilityModifier(7), -2);
      expect(CharacterRules.abilityModifier(11), 0);
      expect(CharacterRules.abilityModifier(15), 2);
    });
  });

  group('Бонус мастерства', () {
    test('растёт каждые четыре уровня', () {
      expect(CharacterRules.proficiencyBonus(1), 2);
      expect(CharacterRules.proficiencyBonus(4), 2);
      expect(CharacterRules.proficiencyBonus(5), 3);
      expect(CharacterRules.proficiencyBonus(8), 3);
      expect(CharacterRules.proficiencyBonus(9), 4);
      expect(CharacterRules.proficiencyBonus(12), 4);
      expect(CharacterRules.proficiencyBonus(13), 5);
      expect(CharacterRules.proficiencyBonus(16), 5);
      expect(CharacterRules.proficiencyBonus(17), 6);
      expect(CharacterRules.proficiencyBonus(20), 6);
    });
  });

  group('Хиты', () {
    test('первый уровень — максимум кости плюс Телосложение', () {
      expect(
        CharacterRules.maxHitPoints(
          level: 1,
          hitDie: 10,
          constitutionModifier: 2,
        ),
        12,
      );
    });

    test('следующие уровни — среднее, а не максимум', () {
      // d10: 10 + 2 на первом, затем 4 × (5 + 1 + 2) = 32.
      expect(
        CharacterRules.maxHitPoints(
          level: 5,
          hitDie: 10,
          constitutionModifier: 2,
        ),
        44,
      );
    });

    test('отрицательное Телосложение не опускает хиты ниже единицы', () {
      expect(
        CharacterRules.maxHitPoints(
          level: 1,
          hitDie: 6,
          constitutionModifier: -5,
        ),
        1,
      );
    });
  });

  group('Броски 4d6', () {
    test('сумма равна трём старшим костям', () {
      final AbilityRoller roller = AbilityRoller(random: Random(7));

      for (int i = 0; i < 300; i++) {
        final AbilityRoll roll = roller.rollOne();
        final int sum = roll.dice.reduce((int a, int b) => a + b);

        expect(roll.dice, hasLength(AbilityRoller.diceCount));
        expect(roll.dice.every((int die) => die >= 1 && die <= 6), isTrue);
        expect(roll.total, sum - roll.dropped);
        expect(roll.total, inInclusiveRange(3, 18));
      }
    });

    test('бросок всех шести покрывает все характеристики', () {
      final AbilityRolls rolls = AbilityRoller(random: Random(3)).rollAll();

      expect(rolls.byAbility.keys, containsAll(Ability.values));
      for (final Ability ability in Ability.values) {
        expect(rolls.scores[ability], rolls[ability].total);
      }
    });
  });

  group('Бонусы рас', () {
    test('Тифлинг: +1 Интеллект, +2 Харизма', () {
      expect(Races.tiefling.totalBonuses(null), <Ability, int>{
        Ability.intelligence: 1,
        Ability.charisma: 2,
      });
    });

    test('Горный дварф: +2 Телосложение и +2 Сила', () {
      final Subrace mountain = Races.dwarf.subraces.firstWhere(
        (Subrace value) => value.id == 'mountain',
      );

      expect(Races.dwarf.totalBonuses(mountain), <Ability, int>{
        Ability.constitution: 2,
        Ability.strength: 2,
      });
    });

    test('Холмовой дварф: +2 Телосложение и +1 Мудрость', () {
      final Subrace hill = Races.dwarf.subraces.firstWhere(
        (Subrace value) => value.id == 'hill',
      );

      expect(Races.dwarf.totalBonuses(hill), <Ability, int>{
        Ability.constitution: 2,
        Ability.wisdom: 1,
      });
    });

    test('Полуэльф: +2 Харизма и два плавающих +1, Харизма исключена', () {
      expect(Races.halfElf.totalBonuses(null), <Ability, int>{
        Ability.charisma: 2,
      });
      expect(Races.halfElf.flexibleBonus, 2);
      expect(Races.halfElf.flexibleExcluded, contains(Ability.charisma));
    });
  });

  group('Персонаж', () {
    final Character fighter = Character(
      name: 'Торин',
      dndClass: DndClass.fighter,
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

    test('владение спасброском добавляет бонус мастерства', () {
      // Воин владеет СИЛ и ТЕЛ: 3 + 2 и 2 + 2.
      expect(fighter.savingThrow(Ability.strength), 5);
      expect(fighter.savingThrow(Ability.constitution), 4);
    });

    test('без владения спасбросок равен модификатору', () {
      expect(fighter.savingThrow(Ability.intelligence), -1);
      expect(fighter.savingThrow(Ability.dexterity), 1);
    });

    test('хиты и происхождение вычисляются из данных', () {
      expect(fighter.maxHitPoints, 12);
      expect(fighter.hitDiceLabel, 'd10');
      expect(fighter.originLabel, 'Дварф (Горный)');
    });
  });
}
