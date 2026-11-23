import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// Таблица персонажей.
///
/// Характеристики — отдельные колонки, а не JSON-блоб в тексте: их можно
/// индексировать, сортировать и фильтровать SQL-ом, не разбирая весь список.
/// Модификаторы и хиты здесь отсутствуют намеренно — они вычисляются из
/// значений, поэтому не могут разойтись с ними.
class CharacterRecords extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().withLength(min: 1, max: 60)();

  /// `DndClass.id`: `barbarian`, `wizard`…
  TextColumn get classId => text()();

  /// `Subclass.id` или `null`, если подкласс не выбран.
  TextColumn get subclassId => text().nullable()();

  /// `Race.id`: `half-elf`, `dwarf`…
  TextColumn get raceId => text()();

  /// `Subrace.id` или `null`, если у расы нет подрас.
  TextColumn get subraceId => text().nullable()();

  IntColumn get level => integer().withDefault(const Constant(1))();

  IntColumn get strength => integer()();
  IntColumn get dexterity => integer()();
  IntColumn get constitution => integer()();
  IntColumn get intelligence => integer()();
  IntColumn get wisdom => integer()();
  IntColumn get charisma => integer()();

  DateTimeColumn get createdAt => dateTime()();
}

@DriftDatabase(tables: <Type>[CharacterRecords])
class AppDatabase extends _$AppDatabase {
  /// Боевая база: файл в приватной папке приложения, без ручной настройки пути.
  AppDatabase() : super(driftDatabase(name: 'dnd_characters'));

  /// Та же схема в памяти — для тестов. Код репозитория не меняется.
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async => m.createAll(),
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.addColumn(characterRecords, characterRecords.subclassId);
      }
    },
  );
}
