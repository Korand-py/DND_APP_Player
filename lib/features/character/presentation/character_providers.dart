import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_database.dart';
import '../data/drift_character_repository.dart';
import '../domain/character.dart';
import '../domain/character_repository.dart';

/// Одна база на приложение: живёт столько же, сколько `ProviderScope`.
final Provider<AppDatabase> appDatabaseProvider = Provider<AppDatabase>((ref) {
  final AppDatabase database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

/// Порт хранилища для UI. Единственное место, где домен встречается с Drift.
final Provider<CharacterRepository> characterRepositoryProvider =
    Provider<CharacterRepository>((ref) {
      return DriftCharacterRepository(ref.watch(appDatabaseProvider));
    });

/// Список персонажей потоком: сохранение и удаление обновляют экран сами.
final StreamProvider<List<Character>> charactersProvider =
    StreamProvider<List<Character>>((ref) {
      return ref.watch(characterRepositoryProvider).watchAll();
    });
