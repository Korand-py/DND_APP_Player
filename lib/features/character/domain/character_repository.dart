import 'character.dart';

/// Порт хранилища персонажей.
///
/// Домен не знает ни про Drift, ни про файлы. Реализация живёт в `data/`, а
/// UI зависит только от этого интерфейса — значит подменяется в тестах без
/// поднятия настоящей базы.
abstract interface class CharacterRepository {
  /// Поток всех персонажей, новые сверху. Поток, а не `Future`: после
  /// сохранения список обязан обновиться сам, без ручного `refresh`.
  Stream<List<Character>> watchAll();

  /// Возвращает id вставленной строки.
  Future<int> create(Character character);

  Future<void> delete(int id);

  /// Очистка базы целиком. Отдельный метод, а не цикл `delete` в UI: одна
  /// транзакция вместо N запросов и одного промежуточного состояния списка.
  Future<void> deleteAll();
}
