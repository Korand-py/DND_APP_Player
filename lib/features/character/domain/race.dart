import 'ability.dart';

/// Подраса: только бонусы и название. Своих правил у неё нет.
class Subrace {
  const Subrace({required this.id, required this.label, required this.bonuses});

  final String id;
  final String label;
  final Map<Ability, int> bonuses;
}

/// Раса SRD 5.1.
///
/// [flexibleBonus] — сколько характеристик игрок выбирает сам (полуэльф).
/// [flexibleExcluded] — что выбирать нельзя: у полуэльфа +2 к Харизме уже есть,
/// второй раз её брать нечестно.
class Race {
  const Race({
    required this.id,
    required this.label,
    this.subraces = const <Subrace>[],
    this.bonuses = const <Ability, int>{},
    this.flexibleBonus = 0,
    this.flexibleExcluded = const <Ability>{},
  });

  final String id;
  final String label;
  final List<Subrace> subraces;
  final Map<Ability, int> bonuses;
  final int flexibleBonus;
  final Set<Ability> flexibleExcluded;

  bool get hasSubraces => subraces.isNotEmpty;

  /// Полный бонус расы с подрасой. Подраса добавляется поверх базовых бонусов,
  /// а не заменяет их: у Горного дварфа +2 ТЕЛ и +2 СИЛ одновременно.
  Map<Ability, int> totalBonuses(Subrace? subrace) {
    final Map<Ability, int> total = <Ability, int>{...bonuses};
    if (subrace == null) return total;

    subrace.bonuses.forEach((Ability ability, int value) {
      total[ability] = (total[ability] ?? 0) + value;
    });
    return total;
  }

  static Race fromId(String id) =>
      Races.all.firstWhere((Race value) => value.id == id);
}

/// Справочник рас. Единственный источник данных о бонусах.
///
/// В прототипе часть бонусов была потеряна или перепутана: Горному дварфу не
/// давали +2 СИЛ, Холмовому — +1 МУД, а Тифлингу вместо +1 ИНТ давали +1 ЛОВ.
abstract final class Races {
  static const Race dwarf = Race(
    id: 'dwarf',
    label: 'Дварф',
    subraces: <Subrace>[
      Subrace(
        id: 'hill',
        label: 'Холмовой',
        bonuses: <Ability, int>{Ability.constitution: 2, Ability.wisdom: 1},
      ),
      Subrace(
        id: 'mountain',
        label: 'Горный',
        bonuses: <Ability, int>{Ability.constitution: 2, Ability.strength: 2},
      ),
    ],
  );

  static const Race elf = Race(
    id: 'elf',
    label: 'Эльф',
    subraces: <Subrace>[
      Subrace(
        id: 'high',
        label: 'Высший',
        bonuses: <Ability, int>{Ability.dexterity: 2, Ability.intelligence: 1},
      ),
      Subrace(
        id: 'wood',
        label: 'Лесной',
        bonuses: <Ability, int>{Ability.dexterity: 2, Ability.wisdom: 1},
      ),
      Subrace(
        id: 'drow',
        label: 'Тёмный (Дроу)',
        bonuses: <Ability, int>{Ability.dexterity: 2, Ability.charisma: 1},
      ),
    ],
  );

  static const Race halfling = Race(
    id: 'halfling',
    label: 'Полурослик',
    subraces: <Subrace>[
      Subrace(
        id: 'lightfoot',
        label: 'Легконогий',
        bonuses: <Ability, int>{Ability.dexterity: 2, Ability.charisma: 1},
      ),
      Subrace(
        id: 'stout',
        label: 'Коренастый',
        bonuses: <Ability, int>{Ability.dexterity: 2, Ability.constitution: 1},
      ),
    ],
  );

  static const Race gnome = Race(
    id: 'gnome',
    label: 'Гном',
    subraces: <Subrace>[
      Subrace(
        id: 'forest',
        label: 'Лесной',
        bonuses: <Ability, int>{Ability.intelligence: 2, Ability.dexterity: 1},
      ),
      Subrace(
        id: 'rock',
        label: 'Каменный',
        bonuses: <Ability, int>{
          Ability.intelligence: 2,
          Ability.constitution: 1,
        },
      ),
    ],
  );

  static const Race human = Race(
    id: 'human',
    label: 'Человек',
    bonuses: <Ability, int>{
      Ability.strength: 1,
      Ability.dexterity: 1,
      Ability.constitution: 1,
      Ability.intelligence: 1,
      Ability.wisdom: 1,
      Ability.charisma: 1,
    },
  );

  static const Race dragonborn = Race(
    id: 'dragonborn',
    label: 'Драконорождённый',
    bonuses: <Ability, int>{Ability.strength: 2, Ability.charisma: 1},
  );

  static const Race tiefling = Race(
    id: 'tiefling',
    label: 'Тифлинг',
    bonuses: <Ability, int>{Ability.intelligence: 1, Ability.charisma: 2},
  );

  static const Race halfElf = Race(
    id: 'half-elf',
    label: 'Полуэльф',
    bonuses: <Ability, int>{Ability.charisma: 2},
    flexibleBonus: 2,
    flexibleExcluded: <Ability>{Ability.charisma},
  );

  static const Race halfOrc = Race(
    id: 'half-orc',
    label: 'Полуорк',
    bonuses: <Ability, int>{Ability.strength: 2, Ability.constitution: 1},
  );

  static const List<Race> all = <Race>[
    dwarf,
    elf,
    halfling,
    gnome,
    human,
    dragonborn,
    tiefling,
    halfElf,
    halfOrc,
  ];
}
