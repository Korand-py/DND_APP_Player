import 'package:drift/drift.dart';

import '../domain/ability_scores.dart';
import '../domain/character.dart';
import '../domain/character_repository.dart';
import '../domain/dnd_class.dart';
import '../domain/race.dart';
import 'app_database.dart';

/// Drift-реализация порта [CharacterRepository].
///
/// SQLite вместо JSON-файла: одна строка — один персонаж, запись атомарная,
/// список читается потоком из индекса, а не перезаписью всего файла целиком.
class DriftCharacterRepository implements CharacterRepository {
  DriftCharacterRepository(this._db);

  final AppDatabase _db;

  @override
  Stream<List<Character>> watchAll() {
    final SimpleSelectStatement<CharacterRecords, CharacterRecord> query =
        _db.select(_db.characterRecords)
          ..orderBy(<OrderClauseGenerator<CharacterRecords>>[
            (CharacterRecords table) => OrderingTerm.desc(table.createdAt),
            (CharacterRecords table) => OrderingTerm.desc(table.id),
          ]);

    return query.watch().map(
      (List<CharacterRecord> rows) => rows.map(_toDomain).toList(),
    );
  }

  @override
  Future<int> create(Character character) {
    return _db
        .into(_db.characterRecords)
        .insert(
          CharacterRecordsCompanion.insert(
            name: character.name,
            classId: character.dndClass.id,
            subclassId: Value<String?>(character.subclass?.id),
            raceId: character.race.id,
            subraceId: Value<String?>(character.subrace?.id),
            level: Value<int>(character.level),
            strength: character.scores.strength,
            dexterity: character.scores.dexterity,
            constitution: character.scores.constitution,
            intelligence: character.scores.intelligence,
            wisdom: character.scores.wisdom,
            charisma: character.scores.charisma,
            createdAt: character.createdAt,
          ),
        );
  }

  @override
  Future<void> delete(int id) async {
    await (_db.delete(
      _db.characterRecords,
    )..where((CharacterRecords table) => table.id.equals(id))).go();
  }

  @override
  Future<void> deleteAll() async {
    await _db.delete(_db.characterRecords).go();
  }

  Character _toDomain(CharacterRecord row) {
    final DndClass dndClass = DndClass.fromId(row.classId);
    final Race race = Race.fromId(row.raceId);

    return Character(
      id: row.id,
      name: row.name,
      dndClass: dndClass,
      subclass: dndClass.subclassById(row.subclassId),
      race: race,
      subrace: _subraceOf(race, row.subraceId),
      level: row.level,
      scores: AbilityScores(
        strength: row.strength,
        dexterity: row.dexterity,
        constitution: row.constitution,
        intelligence: row.intelligence,
        wisdom: row.wisdom,
        charisma: row.charisma,
      ),
      createdAt: row.createdAt,
    );
  }

  /// Без `firstOrNull` из `package:collection`: лишняя зависимость ради одной
  /// строки не нужна.
  Subrace? _subraceOf(Race race, String? subraceId) {
    if (subraceId == null) return null;
    for (final Subrace subrace in race.subraces) {
      if (subrace.id == subraceId) return subrace;
    }
    return null;
  }
}
