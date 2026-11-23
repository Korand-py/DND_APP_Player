import 'package:dice_roller/features/character/domain/ability.dart';
import 'package:dice_roller/features/character/domain/ability_roller.dart';
import 'package:dice_roller/features/character/domain/dnd_class.dart';
import 'package:dice_roller/features/character/domain/race.dart';
import 'package:dice_roller/features/character/presentation/character_draft.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Ровные броски: 12 у всех характеристик. Так бонусы видно без шума.
AbilityRolls _flatRolls() {
  return AbilityRolls(<Ability, AbilityRoll>{
    for (final Ability ability in Ability.values)
      ability: const AbilityRoll(dice: <int>[6, 5, 1, 1], total: 12),
  });
}

CharacterDraft _draft({
  String name = '',
  DndClass? dndClass,
  Subclass? subclass,
  Race? race,
  Subrace? subrace,
  Set<Ability> flexible = const <Ability>{},
}) {
  return CharacterDraft(
    name: name,
    dndClass: dndClass,
    subclass: subclass,
    race: race,
    subrace: subrace,
    rolls: _flatRolls(),
    flexibleAbilities: flexible,
  );
}

void main() {
  group('Проверка черновика', () {
    test('пустой черновик просит имя', () {
      expect(_draft().incompleteReason, 'Впиши имя персонажа');
      expect(_draft().isComplete, isFalse);
      expect(_draft().toCharacter(), isNull);
    });

    test('после имени просит класс, после класса — расу', () {
      final CharacterDraft named = _draft(name: 'Торин');
      expect(named.incompleteReason, 'Выбери класс');

      final CharacterDraft withClass = _draft(
        name: 'Торин',
        dndClass: DndClass.fighter,
      );
      expect(withClass.incompleteReason, 'Выбери расу');
    });

    test('раса с подрасой не считается выбранной без подрасы', () {
      final CharacterDraft draft = _draft(
        name: 'Торин',
        dndClass: DndClass.fighter,
        race: Races.dwarf,
      );

      expect(draft.incompleteReason, 'Выбери подрасу');
      expect(
        draft.copyWith(subrace: Races.dwarf.subraces.first).incompleteReason,
        isNull,
      );
    });

    test('человеку подраса не нужна', () {
      final CharacterDraft draft = _draft(
        name: 'Айвен',
        dndClass: DndClass.rogue,
        race: Races.human,
      );

      expect(draft.isComplete, isTrue);
    });

    test('подкласс не обязателен, но попадает в персонажа', () {
      final CharacterDraft without = _draft(
        name: 'Айвен',
        dndClass: DndClass.fighter,
        race: Races.human,
      );
      expect(without.isComplete, isTrue);
      expect(without.toCharacter()?.subclass, isNull);

      final CharacterDraft withSubclass = without.copyWith(
        subclass: DndClass.fighter.subclasses.first,
      );
      expect(withSubclass.toCharacter()?.subclass?.id, 'champion');
      expect(withSubclass.toCharacter()?.classLabel, 'Воин (Чемпион)');
    });
  });

  group('Итоговые значения', () {
    test('бонус расы применяется один раз', () {
      final CharacterDraft human = _draft(race: Races.human);
      expect(human.scores.strength, 13);
      expect(human.scores.charisma, 13);
    });

    test('подраса складывается с базовыми бонусами расы', () {
      final CharacterDraft dwarf = _draft(
        race: Races.dwarf,
        subrace: Races.dwarf.subraces.last,
      );

      // Горный дварф: +2 ТЕЛ и +2 СИЛ.
      expect(dwarf.scores.constitution, 14);
      expect(dwarf.scores.strength, 14);
      expect(dwarf.scores.dexterity, 12);
    });

    test('плавающий бонус полуэльфа даёт ровно +1', () {
      final CharacterDraft halfElf = _draft(
        race: Races.halfElf,
        flexible: <Ability>{Ability.strength, Ability.wisdom},
      );

      expect(halfElf.scores.charisma, 14);
      expect(halfElf.scores.strength, 13);
      expect(halfElf.scores.wisdom, 13);
      expect(halfElf.scores.dexterity, 12);
    });

    test('хиты считаются из итогового Телосложения', () {
      final CharacterDraft dwarf = _draft(
        dndClass: DndClass.fighter,
        race: Races.dwarf,
        subrace: Races.dwarf.subraces.last,
      );

      // d10 + 2 (ТЕЛ 14) = 12.
      expect(dwarf.maxHitPoints, 12);
    });
  });

  group('Состояние экрана создания', () {
    test('полуэльф: не больше двух +1, Харизма недоступна', () {
      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);

      final CharacterDraftNotifier notifier = container.read(
        characterDraftProvider.notifier,
      );

      notifier.selectRace(Races.halfElf);
      notifier.toggleFlexible(Ability.charisma);
      expect(container.read(characterDraftProvider).flexibleAbilities, isEmpty);

      notifier.toggleFlexible(Ability.strength);
      notifier.toggleFlexible(Ability.wisdom);
      notifier.toggleFlexible(Ability.dexterity);

      expect(
        container.read(characterDraftProvider).flexibleAbilities,
        <Ability>{Ability.strength, Ability.wisdom},
      );
    });

    test('смена класса сбрасывает подкласс', () {
      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);

      final CharacterDraftNotifier notifier = container.read(
        characterDraftProvider.notifier,
      );

      notifier.selectClass(DndClass.fighter);
      notifier.selectSubclass(DndClass.fighter.subclasses.first);
      expect(container.read(characterDraftProvider).subclass?.id, 'champion');

      notifier.selectClass(DndClass.rogue);
      expect(container.read(characterDraftProvider).subclass, isNull);
    });

    test('смена расы сбрасывает подрасу и плавающие бонусы', () {
      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);

      final CharacterDraftNotifier notifier = container.read(
        characterDraftProvider.notifier,
      );

      notifier.selectRace(Races.halfElf);
      notifier.toggleFlexible(Ability.strength);
      notifier.selectRace(Races.dwarf);

      final CharacterDraft draft = container.read(characterDraftProvider);
      expect(draft.subrace, isNull);
      expect(draft.flexibleAbilities, isEmpty);
      expect(draft.race, Races.dwarf);
    });
  });
}
