import 'ability.dart';
import 'character_rules.dart';

/// Шесть значений характеристик до расовых бонусов.
///
/// Иммутабельный value object: любое изменение — новый экземпляр. Так бонус
/// расы невозможно применить дважды, если экран перерисовался.
class AbilityScores {
  const AbilityScores({
    required this.strength,
    required this.dexterity,
    required this.constitution,
    required this.intelligence,
    required this.wisdom,
    required this.charisma,
  });

  final int strength;
  final int dexterity;
  final int constitution;
  final int intelligence;
  final int wisdom;
  final int charisma;

  int operator [](Ability ability) => switch (ability) {
    Ability.strength => strength,
    Ability.dexterity => dexterity,
    Ability.constitution => constitution,
    Ability.intelligence => intelligence,
    Ability.wisdom => wisdom,
    Ability.charisma => charisma,
  };

  /// Модификатор конкретной характеристики.
  int modifier(Ability ability) =>
      CharacterRules.abilityModifier(this[ability]);

  /// Сумма бонусов. Отсутствующая в карте характеристика — это ноль, а не ошибка.
  AbilityScores plus(Map<Ability, int> bonuses) {
    int boosted(Ability ability) => this[ability] + (bonuses[ability] ?? 0);

    return AbilityScores(
      strength: boosted(Ability.strength),
      dexterity: boosted(Ability.dexterity),
      constitution: boosted(Ability.constitution),
      intelligence: boosted(Ability.intelligence),
      wisdom: boosted(Ability.wisdom),
      charisma: boosted(Ability.charisma),
    );
  }

  Map<Ability, int> get asMap => {
    for (final Ability ability in Ability.values) ability: this[ability],
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AbilityScores &&
          other.strength == strength &&
          other.dexterity == dexterity &&
          other.constitution == constitution &&
          other.intelligence == intelligence &&
          other.wisdom == wisdom &&
          other.charisma == charisma;

  @override
  int get hashCode => Object.hash(
    strength,
    dexterity,
    constitution,
    intelligence,
    wisdom,
    charisma,
  );

  @override
  String toString() =>
      'AbilityScores(СИЛ $strength, ЛОВ $dexterity, ТЕЛ $constitution, '
      'ИНТ $intelligence, МУД $wisdom, ХАР $charisma)';
}
