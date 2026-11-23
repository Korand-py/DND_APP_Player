import 'ability.dart';
import 'ability_scores.dart';
import 'character_rules.dart';
import 'dnd_class.dart';
import 'race.dart';

/// Сохранённый персонаж.
///
/// Модификаторы, бонус мастерства и хиты **не хранятся**: они вычисляются из
/// значений. Прототип держал `stats` и `modifiers` рядом в JSON — после любой
/// правки значения модификатор оставался старым, и персонаж врал.
class Character {
  const Character({
    this.id,
    required this.name,
    required this.dndClass,
    this.subclass,
    required this.race,
    this.subrace,
    required this.level,
    required this.scores,
    required this.createdAt,
  });

  /// `null` до сохранения: id выдаёт база.
  final int? id;

  final String name;
  final DndClass dndClass;

  /// Подкласс необязателен: в 5.1 он выбирается с 3 уровня.
  final Subclass? subclass;
  final Race race;
  final Subrace? subrace;
  final int level;

  /// Итоговые значения с расовыми бонусами.
  final AbilityScores scores;

  final DateTime createdAt;

  int modifier(Ability ability) => scores.modifier(ability);

  int get proficiencyBonus => CharacterRules.proficiencyBonus(level);

  /// Спасбросок = модификатор + бонус мастерства, если класс даёт владение.
  int savingThrow(Ability ability) {
    final int base = modifier(ability);
    return dndClass.hasSavingThrowProficiency(ability)
        ? base + proficiencyBonus
        : base;
  }

  int get maxHitPoints => CharacterRules.maxHitPoints(
    level: level,
    hitDie: dndClass.hitDie,
    constitutionModifier: modifier(Ability.constitution),
  );

  String get hitDiceLabel => dndClass.hitDiceLabel;

  /// «Дварф (Горный)» или «Человек», если подрасы нет.
  String get originLabel {
    final Subrace? sub = subrace;
    return sub == null ? race.label : '${race.label} (${sub.label})';
  }

  /// «Воин (Чемпион)» или «Воин», если подкласс ещё не выбран.
  String get classLabel {
    final Subclass? sub = subclass;
    return sub == null ? dndClass.label : '${dndClass.label} (${sub.label})';
  }

  Character copyWith({int? id}) => Character(
    id: id ?? this.id,
    name: name,
    dndClass: dndClass,
    subclass: subclass,
    race: race,
    subrace: subrace,
    level: level,
    scores: scores,
    createdAt: createdAt,
  );
}
