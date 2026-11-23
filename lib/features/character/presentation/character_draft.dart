import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/ability.dart';
import '../domain/ability_roller.dart';
import '../domain/ability_scores.dart';
import '../domain/character.dart';
import '../domain/character_rules.dart';
import '../domain/dnd_class.dart';
import '../domain/race.dart';
import 'active_character.dart';
import 'character_providers.dart';

/// Черновик нового персонажа.
///
/// Хранит только выбор игрока и броски. Итоговые значения, модификаторы и хиты
/// вычисляются — их нельзя рассинхронизировать с выбором.
class CharacterDraft {
  const CharacterDraft({
    required this.name,
    required this.dndClass,
    this.subclass,
    required this.race,
    required this.subrace,
    required this.rolls,
    required this.flexibleAbilities,
  });

  /// Стартовый уровень: создание всегда с первого.
  static const int startLevel = 1;

  final String name;
  final DndClass? dndClass;
  final Subclass? subclass;
  final Race? race;
  final Subrace? subrace;
  final AbilityRolls rolls;

  /// Характеристики, выбранные под плавающий бонус (полуэльф).
  final Set<Ability> flexibleAbilities;

  /// Первое, чего не хватает. `null` — можно сохранять.
  ///
  /// Одна строка вместо шести флагов: UI показывает ровно её и не изобретает
  /// собственные проверки, которые разойдутся с этой.
  String? get incompleteReason {
    if (name.trim().isEmpty) return 'Впиши имя персонажа';

    if (dndClass == null) return 'Выбери класс';

    final Race? selected = race;
    if (selected == null) return 'Выбери расу';
    if (selected.hasSubraces && subrace == null) return 'Выбери подрасу';
    if (flexibleAbilities.length < selected.flexibleBonus) {
      return 'Выбери +1 к двум характеристикам';
    }

    return null;
  }

  bool get isComplete => incompleteReason == null;

  /// Итоговые значения: бросок + раса + подраса + плавающий бонус.
  AbilityScores get scores {
    final Map<Ability, int> bonuses = <Ability, int>{};

    final Race? selected = race;
    if (selected != null) bonuses.addAll(selected.totalBonuses(subrace));

    for (final Ability ability in flexibleAbilities) {
      bonuses[ability] = (bonuses[ability] ?? 0) + 1;
    }

    return rolls.scores.plus(bonuses);
  }

  /// Хиты до сохранения: игрок видит, с чем пришёл, до нажатия кнопки.
  int get maxHitPoints {
    final DndClass? selected = dndClass;
    if (selected == null) return 0;

    return CharacterRules.maxHitPoints(
      level: startLevel,
      hitDie: selected.hitDie,
      constitutionModifier: scores.modifier(Ability.constitution),
    );
  }

  Character? toCharacter({DateTime? now}) {
    if (!isComplete) return null;

    return Character(
      name: name.trim(),
      dndClass: dndClass!,
      subclass: subclass,
      race: race!,
      subrace: subrace,
      level: startLevel,
      scores: scores,
      createdAt: now ?? DateTime.now(),
    );
  }

  CharacterDraft copyWith({
    String? name,
    DndClass? dndClass,
    Subclass? subclass,
    bool clearSubclass = false,
    Race? race,
    Subrace? subrace,
    bool clearSubrace = false,
    AbilityRolls? rolls,
    Set<Ability>? flexibleAbilities,
  }) {
    return CharacterDraft(
      name: name ?? this.name,
      dndClass: dndClass ?? this.dndClass,
      subclass: clearSubclass ? null : (subclass ?? this.subclass),
      race: race ?? this.race,
      subrace: clearSubrace ? null : (subrace ?? this.subrace),
      rolls: rolls ?? this.rolls,
      flexibleAbilities: flexibleAbilities ?? this.flexibleAbilities,
    );
  }
}

/// Состояние экрана создания. Живёт в Riverpod, а не в `State`: черновик
/// переживает перерисовку и его видно в тестах без поднятия виджета.
class CharacterDraftNotifier extends Notifier<CharacterDraft> {
  final AbilityRoller _roller = AbilityRoller();

  @override
  CharacterDraft build() => _fresh();

  CharacterDraft _fresh() => CharacterDraft(
    name: '',
    dndClass: null,
    race: null,
    subrace: null,
    rolls: _roller.rollAll(),
    flexibleAbilities: const <Ability>{},
  );

  void setName(String value) => state = state.copyWith(name: value);

  /// Смена класса сбрасывает подкласс: он принадлежит старому классу.
  void selectClass(DndClass value) => state = state.copyWith(
    dndClass: value,
    clearSubclass: true,
  );

  void selectSubclass(Subclass value) =>
      state = state.copyWith(subclass: value);

  /// Смена расы сбрасывает подрасу и плавающие бонусы: они принадлежат старой
  /// расе, оставлять их — значит молча дать персонажу чужие +2.
  void selectRace(Race value) => state = state.copyWith(
    race: value,
    clearSubrace: true,
    flexibleAbilities: const <Ability>{},
  );

  void selectSubrace(Subrace value) => state = state.copyWith(subrace: value);

  /// Переброс всех шести. Отдельного переброса одной характеристики нет:
  /// это уже распределение очков, другое правило.
  void reroll() => state = state.copyWith(rolls: _roller.rollAll());

  void toggleFlexible(Ability ability) {
    final Race? race = state.race;
    if (race == null || race.flexibleExcluded.contains(ability)) return;

    final Set<Ability> next = <Ability>{...state.flexibleAbilities};

    if (!next.remove(ability)) {
      if (next.length >= race.flexibleBonus) return;
      next.add(ability);
    }

    state = state.copyWith(flexibleAbilities: next);
  }

  /// Сохраняет персонажа и делает его активным.
  ///
  /// `null` — черновик неполный, база не тронута. Возвращается id, а не `bool`:
  /// вызывающему экрану нужно знать, кого показывать после сохранения.
  Future<int?> save() async {
    final Character? character = state.toCharacter();
    if (character == null) return null;

    final int id = await ref.read(characterRepositoryProvider).create(character);
    ref.read(activeCharacterIdProvider.notifier).select(id);
    return id;
  }
}

/// Черновик живёт ровно столько, сколько открыт экран создания: `autoDispose`
/// убивает состояние при выходе. Ручной сброс в `initState` невозможен —
/// Riverpod 3 запрещает менять провайдер во время построения дерева.
final NotifierProvider<CharacterDraftNotifier, CharacterDraft>
characterDraftProvider =
    NotifierProvider<CharacterDraftNotifier, CharacterDraft>(
      CharacterDraftNotifier.new,
      isAutoDispose: true,
    );
