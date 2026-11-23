import 'ability.dart';

/// Подкласс: название и id. Правил пока не несёт — как [Subrace] у рас.
///
/// В D&D 5.1 подкласс выбирается с 3 уровня, поэтому на старте он необязателен.
/// Свой подкласс добавляется в список [DndClass.subclasses] справочника
/// [DndClasses] — ни один другой слой править не нужно.
class Subclass {
  const Subclass({required this.id, required this.label});

  final String id;
  final String label;
}

/// Класс персонажа SRD 5.1.
///
/// Был `enum`, из-за чего список был зашит в языке: добавить подкласс или свой
/// класс без правки этого файла было невозможно. Теперь данные живут в
/// [DndClasses], а экземпляр класса — обычный иммутабельный объект.
class DndClass {
  const DndClass({
    required this.id,
    required this.label,
    required this.hitDie,
    required this.savingThrows,
    this.subclasses = const <Subclass>[],
  });

  /// Стабильный id для базы: `fighter`, `wizard`…
  final String id;

  /// Название для UI: «Воин», «Плут».
  final String label;

  /// Размер кости хитов: 6, 8, 10 или 12.
  final int hitDie;

  /// Две характеристики, к спасброскам которых класс даёт владение.
  final (Ability, Ability) savingThrows;

  final List<Subclass> subclasses;

  bool get hasSubclasses => subclasses.isNotEmpty;

  /// Подпись кости для карточек: `d10`.
  String get hitDiceLabel => 'd$hitDie';

  bool hasSavingThrowProficiency(Ability ability) =>
      savingThrows.$1 == ability || savingThrows.$2 == ability;

  /// Подкласс по id из базы. `null` — подкласс не выбран или id устарел.
  Subclass? subclassById(String? id) {
    if (id == null) return null;
    for (final Subclass value in subclasses) {
      if (value.id == id) return value;
    }
    return null;
  }

  /// Восстановление из БД по строковому id.
  static DndClass fromId(String id) {
    for (final DndClass value in DndClasses.all) {
      if (value.id == id) return value;
    }
    throw ArgumentError.value(id, 'id', 'Неизвестный класс персонажа');
  }

  // Алиасы для обратной совместимости с кодом, который уже использует
  // `DndClass.fighter` и `DndClass.values`.
  static const DndClass barbarian = DndClasses.barbarian;
  static const DndClass bard = DndClasses.bard;
  static const DndClass cleric = DndClasses.cleric;
  static const DndClass druid = DndClasses.druid;
  static const DndClass fighter = DndClasses.fighter;
  static const DndClass monk = DndClasses.monk;
  static const DndClass paladin = DndClasses.paladin;
  static const DndClass ranger = DndClasses.ranger;
  static const DndClass rogue = DndClasses.rogue;
  static const DndClass sorcerer = DndClasses.sorcerer;
  static const DndClass warlock = DndClasses.warlock;
  static const DndClass wizard = DndClasses.wizard;

  static List<DndClass> get values => DndClasses.all;
}

/// Справочник классов. единственный источник данных о костях, владениях и
/// подклассах. Чтобы добавить свой класс или подкласс — допиши здесь.
abstract final class DndClasses {
  static const DndClass barbarian = DndClass(
    id: 'barbarian',
    label: 'Варвар',
    hitDie: 12,
    savingThrows: (Ability.strength, Ability.constitution),
    subclasses: <Subclass>[],
  );

  static const DndClass bard = DndClass(
    id: 'bard',
    label: 'Бард',
    hitDie: 8,
    savingThrows: (Ability.dexterity, Ability.charisma),
    subclasses: <Subclass>[],
  );

  static const DndClass cleric = DndClass(
    id: 'cleric',
    label: 'Жрец',
    hitDie: 8,
    savingThrows: (Ability.wisdom, Ability.charisma),
    subclasses: <Subclass>[
      Subclass(id: 'life', label: 'Домен жизни'),
      Subclass(id: 'light', label: 'Домен света'),
    ],
  );

  static const DndClass druid = DndClass(
    id: 'druid',
    label: 'Друид',
    hitDie: 8,
    savingThrows: (Ability.intelligence, Ability.wisdom),
    subclasses: <Subclass>[],
  );

  static const DndClass fighter = DndClass(
    id: 'fighter',
    label: 'Воин',
    hitDie: 10,
    savingThrows: (Ability.strength, Ability.constitution),
    subclasses: <Subclass>[],
  );

  static const DndClass monk = DndClass(
    id: 'monk',
    label: 'Монах',
    hitDie: 8,
    savingThrows: (Ability.strength, Ability.dexterity),
    subclasses: <Subclass>[],
  );

  static const DndClass paladin = DndClass(
    id: 'paladin',
    label: 'Паладин',
    hitDie: 10,
    savingThrows: (Ability.wisdom, Ability.charisma),
    subclasses: <Subclass>[],
  );

  static const DndClass ranger = DndClass(
    id: 'ranger',
    label: 'Следопыт',
    hitDie: 10,
    savingThrows: (Ability.strength, Ability.dexterity),
    subclasses: <Subclass>[],
  );

  static const DndClass rogue = DndClass(
    id: 'rogue',
    label: 'Плут',
    hitDie: 8,
    savingThrows: (Ability.dexterity, Ability.intelligence),
    subclasses: <Subclass>[],
  );

  static const DndClass sorcerer = DndClass(
    id: 'sorcerer',
    label: 'Чародей',
    hitDie: 6,
    savingThrows: (Ability.constitution, Ability.charisma),
    subclasses: <Subclass>[],
  );

  static const DndClass warlock = DndClass(
    id: 'warlock',
    label: 'Колдун',
    hitDie: 8,
    savingThrows: (Ability.wisdom, Ability.charisma),
    subclasses: <Subclass>[Subclass(id: 'fiend', label: 'Пакт с демоном')],
  );

  static const DndClass wizard = DndClass(
    id: 'wizard',
    label: 'Волшебник',
    hitDie: 6,
    savingThrows: (Ability.intelligence, Ability.wisdom),
    subclasses: <Subclass>[Subclass(id: 'evocation', label: 'Эвокация')],
  );

  static const List<DndClass> all = <DndClass>[
    barbarian,
    bard,
    cleric,
    druid,
    fighter,
    monk,
    paladin,
    ranger,
    rogue,
    sorcerer,
    warlock,
    wizard,
  ];
}
