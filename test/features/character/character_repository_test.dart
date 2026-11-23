import 'dart:async';

import 'package:dice_roller/features/character/data/app_database.dart';
import 'package:dice_roller/features/character/data/drift_character_repository.dart';
import 'package:dice_roller/features/character/domain/ability.dart';
import 'package:dice_roller/features/character/domain/ability_scores.dart';
import 'package:dice_roller/features/character/domain/character.dart';
import 'package:dice_roller/features/character/domain/dnd_class.dart';
import 'package:dice_roller/features/character/domain/race.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

Character _sample({String name = 'Торин', String? subraceId = 'mountain'}) {
  final Subrace? subrace = subraceId == null
      ? null
      : Races.dwarf.subraces.firstWhere(
          (Subrace value) => value.id == subraceId,
        );

  return Character(
    name: name,
    dndClass: DndClass.fighter,
    subclass: DndClass.fighter.subclasses.first,
    race: Races.dwarf,
    subrace: subrace,
    level: 1,
    scores: const AbilityScores(
      strength: 16,
      dexterity: 12,
      constitution: 15,
      intelligence: 8,
      wisdom: 10,
      charisma: 9,
    ),
    createdAt: DateTime(2026, 1, 1),
  );
}

void main() {
  late AppDatabase database;
  late DriftCharacterRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftCharacterRepository(database);
  });

  tearDown(() => database.close());

  test('сохраняет персонажа и читает его обратно', () async {
    final int id = await repository.create(_sample());

    final List<Character> saved = await repository.watchAll().first;

    expect(saved, hasLength(1));
    expect(saved.single.id, id);
    expect(saved.single.name, 'Торин');
    expect(saved.single.dndClass, DndClass.fighter);
    expect(saved.single.subclass?.id, 'champion');
    expect(saved.single.race, Races.dwarf);
    expect(saved.single.subrace?.id, 'mountain');
    expect(saved.single.scores, _sample().scores);
  });

  test('модификаторы не хранятся в базе, а вычисляются', () async {
    await repository.create(_sample());

    final Character saved = (await repository.watchAll().first).single;

    expect(saved.modifier(Ability.strength), 3);
    expect(saved.savingThrow(Ability.strength), 5);
    expect(saved.maxHitPoints, 12);
  });

  test('поток отдаёт новый список после вставки', () async {
    final List<List<Character>> emissions = <List<Character>>[];
    final StreamSubscription<List<Character>> subscription = repository
        .watchAll()
        .listen(emissions.add);
    addTearDown(subscription.cancel);

    await pumpEventQueue();
    await repository.create(_sample());
    await pumpEventQueue();

    expect(emissions.last, hasLength(1));
    expect(emissions.last.single.name, 'Торин');
  });

  test('удаление убирает персонажа из потока', () async {
    final int id = await repository.create(_sample());
    expect(await repository.watchAll().first, hasLength(1));

    await repository.delete(id);

    expect(await repository.watchAll().first, isEmpty);
  });

  test('раса без подрасы сохраняется с пустой подрасой', () async {
    await repository.create(_sample(name: 'Айвен', subraceId: null));

    final Character saved = (await repository.watchAll().first).single;

    expect(saved.subrace, isNull);
    expect(saved.originLabel, 'Дварф');
  });
}
