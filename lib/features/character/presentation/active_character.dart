import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/character.dart';
import 'character_providers.dart';

/// id персонажа, которого игрок выбрал активным.
///
/// `null` — это «самый свежий», а не «никого»: приложение стартует с последним
/// созданным героем, а не с пустого экрана. Поэтому выбор хранится как
/// `int?`, а не как обязательный id.
class ActiveCharacterIdNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  void select(int id) => state = id;

  /// Сброс после удаления всех персонажей: id больше не существует.
  void clear() => state = null;
}

final NotifierProvider<ActiveCharacterIdNotifier, int?>
activeCharacterIdProvider =
    NotifierProvider<ActiveCharacterIdNotifier, int?>(
      ActiveCharacterIdNotifier.new,
    );

/// Персонаж, чьи характеристики показывает главный экран.
///
/// Вычисляется из потока списка, а не хранится отдельно: удалили активного —
/// провайдер сам отдаст следующего, и на экране не останется «мёртвых» данных.
final Provider<Character?> activeCharacterProvider = Provider<Character?>((
  ref,
) {
  final List<Character> characters =
      ref.watch(charactersProvider).value ?? const <Character>[];
  if (characters.isEmpty) return null;

  final int? id = ref.watch(activeCharacterIdProvider);
  if (id == null) return characters.first;

  for (final Character character in characters) {
    if (character.id == id) return character;
  }

  // Активного удалили с листа или свайпом — показываем самого свежего.
  return characters.first;
});
